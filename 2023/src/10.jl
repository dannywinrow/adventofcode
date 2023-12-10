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

directions = Dict('U' => CartesianIndex(-1,0),'D' => CartesianIndex(1,0),'L' => CartesianIndex(0,-1),'R' => CartesianIndex(0,1))
pipes = Dict('.'=>[],'|' => ['U','D'], '-' => ['L','R'], '7' => ['D','L'], 'L' => ['U','R'], 'J' => ['U','L'], 'F' => ['D','R'])
opposites = Dict('L'=>'R','R'=>'L','U'=>'D','D'=>'U')

function solveit(grid = loadgrid(Char))
    start = findfirst(==('S'),grid)
    direction = 'S'
    for (key,val) in directions
        if validentry(key, grid[start + val])
            direction = key
            break
        end
    end
    traverse(grid,start,direction) / 2
end

validentry(direction,pipe) = opposites[direction] in pipes[pipe]

newdirection(pipe,directionentered) = filter(!=(opposites[directionentered]),pipes[pipe])[1]

function traverse(grid,start,direction)
    cell = start + directions[direction]
    direction = newdirection(grid[cell],direction)
    stepcnt = 1
    while cell != start
        stepcnt < 100 && @info direction, grid[cell]
        stepcnt += 1
        cell = cell + directions[direction]
        grid[cell] == 'S' && break
        direction = newdirection(grid[cell],direction)
    end
    stepcnt
end


pt1 = solveit()
#solveit(loadgrid(Char,split(example,"\n")))

function solveit2(grid = loadgrid(Char))
    start = findfirst(==('S'),grid)
    direction = 'S'
    for (key,val) in directions
        if start + val in CartesianIndices(grid) && validentry(key, grid[start + val])
            direction = key
            break
        end
    end
    path = getpath(grid,start,direction)

    areagrid = similar(grid)
    areagrid .= '.'
    areagrid[path] .= grid[path]
    replaceS!(areagrid)
    L = nothing
    for x in findall(==('L'),areagrid)
        L = x
        toout = unique(vcat(areagrid[L[1]+1:end,L[2]],areagrid[L[1],1:L[2]-1]))
        isempty(toout) || length(toout) == 1 && toout[1] == '.'  && break
    end
    direction = 'U'
    cell = L
    while true
        cell += directions[direction]
        cell == L && break
        direction = newdirection(areagrid[cell],direction)
        if areagrid[cell] == '|' || areagrid[cell] == '-'
            outcell = cell + directions[rotations[direction]]
            areagrid[outcell] == '.' && fillgroup!(areagrid,outcell,'I')
        elseif !in(rotations[direction],pipes[areagrid[cell]])
            outcell = cell + directions[rotations[direction]]
            areagrid[outcell] == '.' && fillgroup!(areagrid,outcell,'I')
            outcell = cell + directions[rotations[rotations[direction]]]
            areagrid[outcell] == '.' && fillgroup!(areagrid,outcell,'I')
        end
    end
    count(==('I'),areagrid)
end

rotations = Dict('R'=>'D','D'=>'L','L'=>'U','U'=>'R')

function replaceS!(grid)
    start = findfirst(==('S'),grid)
    dirs = []
    for (key,val) in directions
        if start + val in CartesianIndices(grid) && validentry(key, grid[start + val])
            push!(dirs,key)
        end
    end
    function reversepipe()
        for (key,val) in pipes
            if sort(val) == sort(dirs)
                return key
            end
        end
    end
    grid[start] = reversepipe()
end
function fillgroup!(grid,cell,char)
    tovisit = [cell]
    grid[cell] = char
    while !isempty(tovisit)
        visiting = pop!(tovisit)
        for x in values(directions)
            if (visiting + x) in CartesianIndices(grid)
                if grid[visiting + x] == '.'
                    if !in(visiting + x, tovisit)
                        grid[visiting + x] = char
                        push!(tovisit,visiting + x)
                    end
                end
            end
        end
    end
end
function getpath(grid,start,direction)
    path = [start]
    while true
        cell = path[end] + directions[direction]
        push!(path,cell)
        grid[cell] == 'S' && break
        direction = newdirection(grid[cell],direction)
    end
    path
end

pt2 = solveit2()
#solveit(loadgrid(Char,split(example,"\n")))

println("Part 1: $pt1")
println("Part 2: $pt2")