using JuMP, GLPK

function ler_dados(arquivo, offset)
    open(arquivo, "r") do f
        n, m, k, p = parse.(Int, split(readline(f)))

        arestas = []
        for _ in 1:m
            linha = readline(f)
            numeros = split(linha)
            u, v = parse(Int, numeros[1]), parse(Int, numeros[2])
            push!(arestas, (u + offset, v + offset))
        end

        return n, m, k, p, arestas
    end
end

function resolve_pim(n, m, k, p, arestas)
    modelo = Model(GLPK.Optimizer)

    @variable(modelo, removidos[1:n], Bin)
    @variable(modelo, contidos[1:n], Bin)

    @constraint(modelo, sum(removidos[i] for i = 1:n) == p)

    for u in 1:n
        @constraint(modelo, contidos[u] + removidos[u] <= 1)
    end

    for u in 1:n
        vizinhos = [aresta[2] for aresta in arestas if aresta[1] == u]
        @constraint(modelo, sum(contidos[v] for v in vizinhos) >= k * contidos[u])
    end

    @objective(modelo, Min, sum(contidos[i] for i = 1:n))

    optimize!(modelo)

    vertices_removidos = [i for i = 1:n if value(removidos[i]) > 0.5]
    vertices_contidos = [i for i = 1:n if value(contidos[i]) > 0.5]

    valor_obj = length(vertices_contidos)

    return vertices_removidos, vertices_contidos, valor_obj
end

function grau_vertex(arestas, v)
    return sum(1 for (u, w) in arestas if u == v || w == v)
end


# Lê os dados do arquivo
arquivo = "/Users/matheuscruz/git/final/instance_34_78_2_3.dat"
n, m, k, p, arestas = ler_dados(arquivo, 0)

println("p:", p)
println("k:", k)
println("vertices len:", n)
println("arestas len:", m)

# Resolve o programa inteiro
vertices_removidos, contidos, valor_obj = resolve_pim(n, m, k, p, arestas)

println("Vértices contidos: ", contidos)
println("Vértices a serem removidos: ", vertices_removidos)
println("Valor da função objetivo: ", valor_obj)
