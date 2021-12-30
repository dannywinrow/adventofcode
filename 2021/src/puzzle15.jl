using Graphs,MetaGraphs

function getinput(file)
    input = read(file,String);
    input = split(input,r"\r\n")
    input = split.(input,"")
    input = hcat(input...)
    input = parse.(Int,input)'
end

function getadjacent(ci, xbound, ybound; diagonals = true, future = true)
    adj = []
    for xadd in [-1,0,1], yadd in [-1,0,1] 
        if !((xadd == 0) && (yadd == 0)) && (diagonals || (abs(xadd) != abs(yadd))) && (future || ((xadd <= 0) && (yadd <= 0)))
            x = ci[1] + xadd
            y = ci[2] + yadd
            if (1 <= x <= xbound) && (1 <= y <= ybound)
                push!(adj,CartesianIndex(x,y))
            end
        end
    end
    return adj
end

function solvemy(risk)
    paths = zeros(Int,size(risk)[1],size(risk)[1])
    indices = CartesianIndex[]
    for n in 3:size(risk)[1]*2
        for x in max(n-size(risk)[1],1):min(n-1,size(risk)[1])
            push!(indices,CartesianIndex(x,n-x))
        end
    end
    for index in indices
        paths[index] = min(getindex.(Ref(paths),getadjacent(index,size(risk)[1],size(risk)[2];diagonals=false, future=false))...) + risk[index]
    end
    changed = true
    m=1
    while changed == true
        paths1 = copy(paths)
        for index in indices
            paths[index] = min(getindex.(Ref(paths),getadjacent(index,size(risk)[1],size(risk)[2];diagonals=false))...) + risk[index]
        end
        changed = paths != paths1
        m += 1
    end
    paths[end,end]
end

function nextnode(paths,visited)
    val = minimum(paths[.!visited])
    i = findfirst(x->x==val,paths[.!visited])
    CartesianIndices(paths)[.!visited][i]
end
function dikjsolve(risk)
    dim1 = size(risk)[1]
    dim2 = size(risk)[2]
    paths = fill(typemax(Int),dim1,dim2)
    visited = falses(dim1,dim2)
    dest = CartesianIndex(dim1,dim2)
    start = CartesianIndex(1,1)
    paths[start] = 0
    curr = start
    while curr != dest
        neighbours = getadjacent(curr,dim1,dim2;diagonals=false)
        for neighbour in neighbours
            paths[neighbour] = min(paths[neighbour], paths[curr] + risk[neighbour])
        end
        visited[curr] = true
        curr = nextnode(paths,visited)
    end
    paths[dest]
end

function graphsolve(risk)
    dims = size(risk)
    g = grid([dims[1],dims[2]])
    mg = MetaDiGraph(g)
    for i in 1:nv(mg)
        for v in neighbors(mg,i)
            set_prop!(mg, i, v, :weight, risk[v])
        end
    end
    path = enumerate_paths(dijkstra_shortest_paths(mg, 1), nv(mg))
    sum(risk[path[2:end]])
end    
    
function part1(file,f=graphsolve)
    risk = getinput(file)
    @time f(risk)
end

function part2(file,f=graphsolve)
    risktile = getinput(file)
    risk = zeros(Int,size(risktile,1)*5,size(risktile,2)*5)
    for index in CartesianIndices(risk)
        dim = size(risktile)[1]
        addon = ((index[1] - 1) ÷ dim) + ((index[2] - 1) ÷ dim)
        x = ((index[1]-1) % dim) + 1
        y = ((index[2]-1) % dim) + 1
        risk[index] = (addon + risktile[x,y]-1) % (dim-1) + 1
    end
    @time f(risk)
end
function part2mult(file,f=graphsolve)
    risktile = getinput(file)
    multiplier = [0:4...]
    bigrowrisk = vcat(increment.(Ref(risktile),9,multiplier)...)
    risk = hcat(increment.(Ref(bigrowrisk),9,multiplier)...)
    
    @time f(risk)
end
risktile
function examplerisk()
    risk = [
            1 9 1 1 1 9 9
            1 9 1 9 1 9 9
            1 1 1 9 1 9 9
            9 9 9 9 1 9 9
            9 9 9 1 1 9 9
            9 9 9 1 9 9 9
            9 9 9 1 1 1 1
            ]
    @time solvemy(risk)
    @time dikjsolve(risk)
end

risk = [
    1 2 3
    1 5 6
    1 1 1
    ]
@show examplerisk()
file = "2021\\inputs\\input15.txt"
testfile = "2021\\inputs\\input15test.txt"
@show part1(testfile)
@show part1(file)
part1(file,solvemy)
@show part2(testfile)
@show part2(file)
@show part2(file,solvemy)
@show part2mult(file)

maximum(risk)
vcat(risk)
r = Risk(risk,9)
struct Risk
    risk
    maxval
end
r = increment(r)
increment(risk::Risk) = Risk(increment(risk.risk,risk.maxval),risk.maxval)
increment(risk, maxval, amt) = (x->((x+amt-1) % maxval) + 1).(risk)
increment(risk, maxval) = increment(risk,maxval,1)
increment(risk, 9, 3)
repeat(risk,2,2)


hcat(eachrow(bigrisk)...)

[1 2 3 4
 5 6 7 8] .+ [10 20 30 40]