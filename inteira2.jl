using JuMP, GLPK, Combinatorics

function ler_dados(arquivo)
    open(arquivo, "r") do f
        n, m, k, p = parse.(Int, split(readline(f)))
        arestas = [tuple(parse.(Int, split(readline(f)))...) for _ = 1:m]
        return n, m, k, p, arestas
    end
end

function tamanho_max_k_relacionado(n, k, arestas, vertices_excluidos)
    grafo = [i for i in 1:n if i ∉ vertices_excluidos]
    arestas_restantes = filter(a -> !(a[1] in vertices_excluidos) && !(a[2] in vertices_excluidos), arestas)
    while true
        removidos = false
        for v in grafo
            grau = count([(u, v) ∈ arestas_restantes || (v, u) ∈ arestas_restantes ? true : false for u in grafo])
            if grau < k
                removidos = true
                deleteat!(grafo, findfirst(==(v), grafo))
                filter!(a -> a[1] != v && a[2] != v, arestas_restantes)
                break
            end
        end
        if !removidos
            break
        end
    end
    return length(grafo)
end

function resolve_pim_iterativo(n, m, k, p, arestas)
    min_tamanho = n
    best_combinacao = []
    for comb in combinations(1:n, p)
        excluidos = Set(comb)
        tamanho = tamanho_max_k_relacionado(n, k, arestas, excluidos)
        if tamanho < min_tamanho
            min_tamanho = tamanho
            best_combinacao = comb
        end
    end
    return best_combinacao, min_tamanho
end

# Lê os dados do arquivo
arquivo = "/Users/matheuscruz/git/final/instance_34_78_2_3.dat"
n, m, k, p, arestas = ler_dados(arquivo)

println("p:", p)
println("k:", k)
println("vertices len:", n)
println("arestas len:", m)
println("arestas", arestas)



# Resolve o programa inteiro
vertices_removidos, valor_obj = resolve_pim_iterativo(n, m, k, p, arestas)

println("Vértices a serem removidos: ", vertices_removidos)
println("Valor da função objetivo: ", valor_obj)
