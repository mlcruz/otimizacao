using Random
using StatsBase
using Plots

cache = Dict()

function read_instance(filename, offset=0)
    open(filename, "r") do f
        n, m, k, p = parse.(Int, split(readline(f)))

        graph = zeros(Int, n, n)

        for _ in 1:m
            u, v = parse.(Int, split(readline(f)))
            graph[u+offset, v+offset] = 1
            graph[v+offset, u+offset] = 1
        end

        return graph, k, p, n
    end
end


function fitness(chromosome, graph, k)
    key = hash(string(chromosome))

    if haskey(cache, key)
        return cache[key]
    end
    tamanho = tamanho_max_k_relacionado(graph, k, chromosome)
    cache[key] = tamanho

    return tamanho
end

function crossover(chromo1, chromo2, p)
    combined_indices = unique(vcat(chromo1, chromo2))
    selected_indices = sample(combined_indices, p)

    return sort(selected_indices)
end

# Mutação
function mutate(chromo, p, n)

    newzero = rand(1:p)
    newone = rand(1:n)

    while newone in chromo
        newone = rand(1:n)
    end

    chromo[newzero] = newone

    return sort(chromo)
end


# Função auxiliar para criar um cromossomo inicial
function generate_chromosome(n, p)
    chromo = sort(sample(1:n, p))
    return chromo
end

# Função de seleção do torneio
function tournament_selection(population, fitness_values, k)
    indices = sample(1:length(population), k)
    selected_index = argmin(fitness_values[indices])
    return population[indices[selected_index]]
end

function genetic_algorithm(graph, k, p, n, population_size, generations, mutation_rate)
    cache = Dict([])
    # 1. Inicialização
    population = [generate_chromosome(n, p) for _ in 1:population_size]

    for gen in 1:generations
        # 2. Avaliação
        fitness_values = [fitness(chromo, graph, k) for chromo in population]

        # 3. Seleção
        parents = [tournament_selection(population, fitness_values, 3) for _ in 1:population_size]

        # 4. Crossover
        children = []
        for i in 1:2:length(parents)-1
            child = crossover(parents[i], parents[i+1], p)
            push!(children, child)
        end

        # 5. Mutação
        for i in 1:length(children)
            if rand() < mutation_rate
                children[i] = mutate(children[i], p, n)
            end
        end

        # 6. Substituição
        combined = vcat(population, children)
        combined_fitness = vcat(fitness_values, [fitness(chromo, graph, k) for chromo in children])
        sort_indices = sortperm(combined_fitness)
        population = combined[sort_indices[1:population_size]]
    end

    # 7. Retorne o melhor cromossomo após todas as gerações
    best_chromo = population[1]
    return best_chromo
end


function tamanho_max_k_relacionado(graph, k, vertices_excluidos)
    n = size(graph, 1)

    excluded_set = Set(vertices_excluidos)

    degree = Dict(i => 0 for i in 1:n if i ∉ excluded_set)

    for i in 1:n
        for j in (i+1):n
            if graph[i, j] == 1 && (i ∉ excluded_set) && (j ∉ excluded_set)
                degree[i] += 1
                degree[j] += 1
            end
        end
    end

    changed = true
    while changed
        changed = false
        for (vertex, deg) in degree
            if deg < k
                for j in 1:n
                    if graph[vertex, j] == 1 && haskey(degree, j)
                        degree[j] -= 1
                    end
                end
                delete!(degree, vertex)
                changed = true
            end
        end
    end

    return length(degree)
end

files = [
    ("instance_34_78_2_3.dat", 0), ("instance_62_159_2_3.dat", 1), ("instance_77_254_6_4.dat", 1), ("instance_105_441_4_5.dat", 1), ("instance_112_425_5_3.dat", 1), ("instance_115_613_8_5.dat", 1), ("instance_1589_2742_5_3.dat", 1), ("instance_4941_6594_3_5.dat", 1), ("instance_8361_15751_7_3.dat", 1), ("instance_16706_121251_42_5.dat", 1), ("instance_22963_48436_15_4.dat", 1)]

for (file, offset) in files
    pop_x = []
    sample_y = []
    result_z = []

    pops = [5, 10, 15, 20, 25, 30]
    samples = [5, 10, 50, 100, 250, 1000, 2000]


    for pop in pops
        for sample in samples
            println(file, pop, sample)
            graph, k, p, n = read_instance(file, offset)
            result = genetic_algorithm(graph, k, p, n, pop, sample, 0.2)
            tamanho = tamanho_max_k_relacionado(graph, k, result)
            push!(pop_x, pop)
            push!(sample_y, sample)
            push!(result_z, tamanho)
        end
    end

    plot = scatter3d(pop_x, sample_y, result_z, title="PopulacaoXSample", xlabel="Populacao", ylabel="Sample", zlabel="Resultado", marker=:circle, color=:blue, legend=false)
    savefig(plot, "$(file).png")


end
