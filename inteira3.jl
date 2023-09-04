using JuMP, GLPK

function ler_dados(arquivo)
    open(arquivo, "r") do f
        n, m, k, p = parse.(Int, split(readline(f)))
        arestas = [tuple(parse.(Int, split(readline(f)))...) for _ = 1:m]
        return n, m, k, p, arestas
    end
end


function resolve_pim(n, m, k, p, arestas)
    model = Model(GLPK.Optimizer)

    @variable(model, removidos[1:n], Bin) # Vertices a serem removidos
    @variable(model, contidos[1:n], Bin) # Vértices no subconjunto k-relacionado
    @variable(model, arestas_selecionadas[1:n, 1:n], Bin)

    M = 10 * n + 100 # BIG M
    penalidade = sum(1 - contidos[u] for u in 1:n)

    # Remover exatamente p vértices
    @constraint(model, sum(removidos[i] for i = 1:n) == p)

    # Se um vértice está no subconjunto k-relacionado, ele não deve ser um dos vértices "importantes" removidos
    for u in 1:n
        @constraint(model, contidos[u] + removidos[u] <= 1)
    end

    # Restrições
    for (u, v) in arestas
        @constraint(model, arestas_selecionadas[u] <= contidos[v] + removidos[v])
        @constraint(model, contidos[v] <= contidos[u] + removidos[u])
        @constraint(model, arestas_selecionadas[u, v] <= contidos[u])
        @constraint(model, arestas_selecionadas[u, v] <= contidos[v])
    end


    for u in 1:n
        @constraint(model, sum(arestas_selecionadas[u, :]) >= k * contidos[u])
    end

    for u in 1:n
        @constraint(model, contidos[u] + removidos[u] == 1)
    end

    # Objetivo é minimizar a quantidade de vértices no subconjunto k-relacionado
    @objective(model, Min, sum(contidos[i] for i = 1:n) + M * penalidade)

    optimize!(model)

    vertices_removidos = [i for i = 1:n if value(removidos[i]) > 0.5]
    vertices_contidos = [i for i = 1:n if value(contidos[i]) > 0.5]

    valor_obj = length(vertices_contidos)

    return vertices_removidos, vertices_contidos, valor_obj
end

function vizinhos_de(j, arestas)
    return [i for (i, k) in arestas if k == j || (k, i) == j]
end


# Lê os dados do arquivo
arquivo = "/Users/matheuscruz/git/final/instance_34_78_2_3.dat"
n, m, k, p, arestas = ler_dados(arquivo)

println("p:", p)
println("k:", k)
println("vertices len:", n)
println("arestas len:", m)

# Resolve o programa inteiro
vertices_removidos, contidos, valor_obj = resolve_pim(n, m, k, p, arestas)

println("Vértices contidos: ", contidos)
println("Vértices a serem removidos: ", vertices_removidos)
println("Valor da função objetivo: ", valor_obj)
