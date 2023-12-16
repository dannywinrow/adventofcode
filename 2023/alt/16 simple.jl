include("../../helper.jl")

using CircularArrays

example = """.|...\\....
|.-.\\.....
.....|-...
........|.
..........
.........\\
..../.\\\\..
.-.-/..|..
.|....-|.\\
..//.|...."""


grid = loadgrid()
#grid = loadgrid(parselines(example))

U = CartesianIndex(-1,0)
D = CartesianIndex(1,0)
L = CartesianIndex(0,-1)
R = CartesianIndex(0,1)

function visit(dir=R,place=CartesianIndex(1,0))
    
    visitedpipes = []
    queue = [(place,dir)]
    path = fill(false,size(grid))
    while !isempty(queue)
        place,dir = pop!(queue)
        while (place += dir) in CartesianIndices(grid)
            path[place] = true
            
            if grid[place] == '\\'
                dir = dir in [U,D] ? rotl90(dir) : rotr90(dir)
            elseif grid[place] == '/'
                dir = dir in [U,D] ? rotr90(dir) : rotl90(dir)
            elseif grid[place] in ['-','|']
                if (grid[place] == '-' && dir in [U,D]) ||
                    (grid[place] == '|' && dir in [R,L])
                    if place in visitedpipes
                    else
                        push!(visitedpipes, place)
                        if grid[place] == '|'
                            append!(queue,[(place,U),(place,D)])
                        else
                            append!(queue,[(place,R),(place,L)])
                        end
                    end
                    break
                end
            end
        end
    end
    path
end

pt1 = sum(visit())

function solve2()
    nums=[]
    for i in 1:size(grid,1)
        place = CartesianIndex(i,0)
        push!(nums,sum(visit(R,place)))
        place = CartesianIndex(i,size(grid,2)+1)
        push!(nums,sum(visit(L,place)))
    end
    for i in 1:size(grid,2)
        place = CartesianIndex(0,i)
        push!(nums,sum(visit(D,place)))
        place = CartesianIndex(size(grid,1)+1,i)
        push!(nums,sum(visit(U,place)))
    end
    maximum(nums) 
end

pt2 = solve2()

println("Part 1: $pt1")
println("Part 2: $pt2")