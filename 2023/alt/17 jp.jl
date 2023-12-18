include("../../helper.jl")

# Port of Jonathan Paulson's solution

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

sz = size(grid)

function solve()
    queue = PriorityQueue()
    queue[(start,-1,0)] = 0
    visited = Dict()

    while !isempty(queue)
        v,score = peek(queue)
        (place,dir,moves) = dequeue!(queue)
        haskey(visited,v) && continue
        visited[v] = score
        for (i,ci) in enumerate([D,R,U,L])
            p = place + ci
            newdir = i
            newmoves = newdir != dir ? 1 : moves + 1
            if p in CartesianIndices(grid) && newmoves <= 3 && (((newdir + 2) % 4) != dir % 4)
                s = score + grid[p]
                k = (p,newdir,newmoves)
                if !haskey(queue,k) || s < queue[k]
                    queue[k] = s
                end
            end
        end
    end
    minimum(values(filter(x->x[1][1]==dest,visited)))
end

pt1 = solve()

function solve2()
    queue = PriorityQueue()
    queue[(start,-1,-1)] = 0
    visited = Dict()

    while !isempty(queue)
        v,score = peek(queue)
        (place,dir,moves) = dequeue!(queue)
        haskey(visited,v) && continue
        visited[v] = score
        for (i,ci) in enumerate([D,R,U,L])
            p = place + ci
            newdir = i
            newmoves = newdir != dir ? 1 : moves + 1
            if p in CartesianIndices(grid) && newmoves <= 10 && (((newdir + 2) % 4) != (dir % 4)) && (dir == newdir || moves >= 4 || moves == -1)
                s = score + grid[p]
                k = (p,newdir,newmoves)
                if !haskey(queue,k) || s < queue[k]
                    queue[k] = s
                end
            end
        end
    end
    minimum(values(filter(x->x[1][1]==dest && x[1][3]>=4,visited)))
end
pt2 = solve2()

println("Part 1: $pt1")
println("Part 2: $pt2")