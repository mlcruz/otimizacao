using JuMP, GLPK

function ler_dados(arquivo)
    open(arquivo, "r") do f
        n, m, k, p = parse.(Int, split(readline(f)))
        arestas = [tuple(parse.(Int, split(readline(f)))...) for _ = 1:m]
        return n, m, k, p, arestas
    end
end


function resolve_pim(n, m, k, p, arestas)
    modelo = Model(GLPK.Optimizer)

    @variable(modelo, removidos[1:n], Bin) # Vertices a serem removidos
    @variable(modelo, contidos[1:n], Bin) # Vértices no subconjunto k-relacionado
    @variable(modelo, removidos_grau[1:n], Bin) # Vertices removidos por grau < k 

    # Remover exatamente p vértices
    @constraint(modelo, sum(removidos[i] for i = 1:n) == p)

    # Se um vértice está no subconjunto k-relacionado, ele não deve ser um dos vértices "importantes" removidos
    for u in 1:n
        @constraint(modelo, contidos[u] + removidos[u] <= 1)
        @constraint(modelo, contidos[u] + removidos[u] + removidos_grau[u] == 1)
    end

    # Garantir que todos os vértices no subconjunto k-relacionado tenham grau pelo menos k
    for u in 1:n
        neighbors = [aresta[2] for aresta in arestas if aresta[1] == u]  # Pega todos os vizinhos de u
        grau = length(neighbors)
        @constraint(modelo, removidos_grau[u] * grau <= k)
    end


    # Objetivo é minimizar a quantidade de vértices no subconjunto k-relacionado
    @objective(modelo, Min, sum(contidos[i] for i = 1:n))

    optimize!(modelo)

    vertices_removidos = [i for i = 1:n if value(removidos[i]) > 0.5]
    vertices_contidos = [i for i = 1:n if value(contidos[i]) > 0.5]
    vertices_removidos_grau = [i for i = 1:n if value(removidos_grau[i]) > 0.5]


    valor_obj = length(vertices_contidos)

    return vertices_removidos, vertices_contidos, vertices_removidos_grau, valor_obj
end


# Lê os dados do arquivo
arquivo = "/Users/matheuscruz/git/final/instance_34_78_2_3.dat"
n, m, k, p, arestas = ler_dados(arquivo)

println("p:", p)
println("k:", k)
println("vertices len:", n)
println("arestas len:", m)

# Resolve o programa inteiro
vertices_removidos, contidos, vertices_removidos_grau, valor_obj = resolve_pim(n, m, k, p, arestas)

println("Vértices contidos: ", contidos)
println("Vértices a serem removidos: ", vertices_removidos)
println("Vértices a serem removidos por grau < k: ", vertices_removidos_grau)

println("Valor da função objetivo: ", valor_obj)
