# For some reason this is super slow try 17jp for speed


include("../../helper.jl")

using DataStructures

example = """2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533"""

grid = loadgrid(parselines(example);type=Int)
grid = loadgrid(;type=Int)
start = first(CartesianIndices(grid))
dest = last(CartesianIndices(grid))

U = CartesianIndex(-1,0)
D = CartesianIndex(1,0)
L = CartesianIndex(0,-1)
R = CartesianIndex(0,1)

function tracepath(nodefrom,v)
    path = [v]
    while haskey(nodefrom,path[1])
        pushfirst!(path,nodefrom[path[1]])
    end
    [p[1] for p in path]
end
function solve()
    queue = PriorityQueue()
    queue[(start,false)] = 0
    queue[(start,true)] = 0
    visited = Set()
    nodefrom = Dict()
    while !isempty(queue)
        v,score = peek(queue)
        (place,dir) = dequeue!(queue)
        if place == dest
            return score #, tracepath(nodefrom,v), nodefrom, v
        else
            push!(visited,v)
            newdir = dir ? D : R
            for j in [1,-1], i in 1:3
                p = place+newdir*j*i
                if p in CartesianIndices(grid)
                    k = (p,!dir)
                    if !in(k,visited)
                        if j == 1
                            s = score + sum(grid[place+newdir*j:p])
                        else
                            s = score + sum(grid[p:place+newdir*j])
                        end
                        if !haskey(queue,k) || s < queue[k]
                            queue[k] = s
                            nodefrom[k] = v
                        end
                    end
                end
            end
        end
    end
end

pt1, = solve()

function solve2()
    queue = PriorityQueue()
    queue[(start,false)] = 0
    queue[(start,true)] = 0
    visited = []
    nodefrom = Dict()
    while !isempty(queue)
        v,score = peek(queue)
        (place,dir) = dequeue!(queue)
        if place == dest
            return score, tracepath(nodefrom,v), nodefrom, v
        else
            push!(visited,v)
            newdir = dir ? D : R
            for j in [1,-1]
                for i in 4:10
                    p = place+newdir*j*i
                    if p in CartesianIndices(grid)
                        k = (p,!dir)
                        if !in(k,visited)
                            if j == 1
                                s = score + sum(grid[place+newdir*j:p])
                            else
                                s = score + sum(grid[p:place+newdir*j])
                            end
                            if !haskey(queue,k) || s < queue[k]
                                queue[k] = s
                                nodefrom[k] = v
                            end
                        end
                    else
                        break
                    end
                end
            end
        end
    end
end
pt2, = solve2()

println("Part 1: $pt1")
println("Part 2: $pt2")