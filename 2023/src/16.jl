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

function arrow(dir)
    dir == U && return '^'
    dir == D && return 'v'
    dir == R && return '>'
    dir == L && return '<'
end

isarrow(c) = c in ['^','v','>','<']
function visit(dir=R,place=CartesianIndex(1,0);snapit=false)
    
    snapshots = []
    snap = copy(grid)
    queue = [(place,dir)]
    path = fill(false,size(grid))
    visitedpipes = []
    while !isempty(queue)
        place,dir = pop!(queue)
        if haskey(dp,(place,dir))
            path .|= dp[(place,dir)]
        else
            while (place += dir) in CartesianIndices(grid)
                path[place] = true
                if snapit
                    if isarrow(snap[place])
                        snap[place] = '+'
                    elseif snap[place] == '.'
                        snap[place] = arrow(dir)
                    end
                    push!(snapshots,copy(snap))
                end
                
                if grid[place] == '\\'
                    dir = dir in [U,D] ? rotl90(dir) : rotr90(dir)
                elseif grid[place] == '/'
                    dir = dir in [U,D] ? rotr90(dir) : rotl90(dir)
                elseif grid[place] in ['-','|']
                    if (grid[place] == '-' && dir in [U,D]) ||
                        (grid[place] == '|' && dir in [R,L])
                        if haskey(dp,place)
                            #@info typeof(dp[place]), typeof(path)
                            path .|= dp[place]
                        else
                            fpipe=findfirst(==(place),visitedpipes)
                            if !isnothing(fpipe)
                                addloop(visitedpipes[fpipe:end])
                            else
                                push!(visitedpipes, place)
                                if grid[place] == '|'
                                    append!(queue,[(place,U),(place,D)])
                                else
                                    append!(queue,[(place,R),(place,L)])
                                end
                            end
                        end
                        break
                    end
                end
            end
        end
    end
    if snapit
        return path,snapshots
    end
    path
end

function condense!(loops)
    loopsout = []
    while !isempty(loops)
        loop = popfirst!(loops)
        broke = false
        for i in eachindex(loops)
            !isempty(intersect(loops[i],loop)) && union!(loops[i],loop)
            broke = true
            break
        end
        !broke && push!(loopsout,loop)
    end
    append!(loops,loopsout)
end
function addloop(loop)
    push!(loops,loop)
    condense!(loops)
end


dp = Dict()
pipes = findall(in(['|','-']),grid)
loops = []

for ci in pipes
    if !haskey(dp,ci)
        if grid[ci] == '|'
            dp[ci] = visit(R,ci - R)
        else
            dp[ci] = visit(D,ci - D)
        end
        floop = findfirst(x->ci in x, loops)
        if !isnothing(floop)
            for y in loops[floop]
                dp[y] = dp[ci]
            end
        end
    end
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
    maximum(sum.(nums)) 
end

pt2 = solve2()

println("Part 1: $pt1")
println("Part 2: $pt2")