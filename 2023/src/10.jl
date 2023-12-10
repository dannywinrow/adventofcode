include("../../helper.jl")

example = """..F7.
.FJ|.
SJ.L7
|F--J
LJ..."""

example2 = """FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJIF7FJ-
L---JF-JLJIIIIFJLJJ7
|F|F-JF---7IIIL7L|7|
|FFJF7L7F-JF7IIL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L"""


U = CartesianIndex(-1,0)
D = CartesianIndex(1,0)
L = CartesianIndex(0,-1)
R = CartesianIndex(0,1)
directions = [U,D,L,R]
pipes = Dict(
    '.'=>[],
    '|' => Set([U,D]), 
    '-' => Set([L,R]), 
    '7' => Set([D,L]), 
    'L' => Set([U,R]),
    'J' => Set([U,L]), 
    'F' => Set([D,R])
)

import Base.rotr90, Base.rot180
Base.rotr90(ci::CartesianIndex{2}) = CartesianIndex(ci[2],-ci[1])
Base.rot180(ci::CartesianIndex{2}) = CartesianIndex(-ci[1],-ci[2])

validmove(grid,cell,move) = (cell+move) in CartesianIndices(grid) && rot180(move) in pipes[grid[cell + move]]

newdirection(pipe,directionentered) = collect(filter(!=(rot180(directionentered)),pipes[pipe]))[1]
function traverse(grid,start,firstmove)
    cell = start
    nextmove = firstmove
    stepcnt = 0
    while true
        cell = cell + nextmove
        stepcnt += 1
        grid[cell] == 'S' && break
        nextmove = newdirection(grid[cell],nextmove)
    end
    stepcnt
end

function solveit(grid = loadgrid(Char))
    start = findfirst(==('S'),grid)
    move = directions[findfirst(move->validmove(grid,start,move),directions)]
    traverse(grid,start,move) ÷ 2
end

pt1 = solveit()
#solveit(loadgrid(Char,split(example,"\n")))

function getpath(grid,start,move)
    path = [start]
    while true
        cell = path[end] + move
        push!(path,cell)
        grid[cell] == 'S' && break
        move = newdirection(grid[cell],move)
    end
    path
end

function replaceS!(grid)
    start = findfirst(==('S'),grid)
    moves = Set(filter(move->validmove(grid,start,move),directions))
    pipe = collect(filter(key->pipes[key]==moves, keys(pipes)))[1]
    grid[start] = pipe
end

function fillgroup!(grid,cell,char)
    tovisit = [cell]
    grid[cell] = char
    while !isempty(tovisit)
        visiting = pop!(tovisit)
        for move in directions
            if (visiting + move) in CartesianIndices(grid)
                if grid[visiting + move] == '.'
                    if !in(visiting + move, tovisit)
                        grid[visiting + move] = char
                        push!(tovisit,visiting + move)
                    end
                end
            end
        end
    end
end

function solveit2(grid = loadgrid(Char))
    start = findfirst(==('S'),grid)
    move = directions[findfirst(move->validmove(grid,start,move),directions)]
    path = getpath(grid,start,move)

    areagrid = similar(grid)
    areagrid .= '.'
    areagrid[path] .= grid[path]
    replaceS!(areagrid)
    B = nothing
    for x in findall(==('L'),areagrid)
        B = x
        toout = unique(vcat(areagrid[B[1]+1:end,B[2]],areagrid[B[1],1:B[2]-1]))
        isempty(toout) || length(toout) == 1 && toout[1] == '.'  && break
    end
    move = U
    cell = B
    while true
        cell += move
        cell == B && break
        move = newdirection(areagrid[cell],move)
        if areagrid[cell] == '|' || areagrid[cell] == '-'
            outcell = cell + rotr90(move)
            areagrid[outcell] == '.' && fillgroup!(areagrid,outcell,'I')
        elseif !in(rotr90(move),pipes[areagrid[cell]])
            outcell = cell + rotr90(move)
            areagrid[outcell] == '.' && fillgroup!(areagrid,outcell,'I')
            outcell = cell + rot180(move)
            areagrid[outcell] == '.' && fillgroup!(areagrid,outcell,'I')
        end
    end
    count(==('I'),areagrid)
end

pt2 = solveit2()
#solveit(loadgrid(Char,split(example,"\n")))

println("Part 1: $pt1")
println("Part 2: $pt2")