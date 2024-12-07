include("../../helper.jl")


function nextmove(guard,facing,grid)
    newloc = guard + facing
    if newloc in CartesianIndices(grid)
        if grid[newloc] != '#'
            return newloc,facing
        else
            return guard, rotr90(facing)
        end
    else
        return newloc,facing
    end
end

function getpath(grid)
    guard = findfirst(==('^'),grid)
    facing = CartesianIndex(-1,0)
    visited = fill(false,size(grid))
    while true
        visited[guard] = true
        guard,facing = nextmove(guard,facing,grid)
        !(guard in CartesianIndices(grid)) && break
    end
    visited
end

function solveit(filename=getfilename())
    sum(getpath(loadgrid(filename)))
end

pt1 = solveit()

function solveit2(filename=getfilename())
    grid = loadgrid(filename)
    start = findfirst(==('^'),grid)
    empties = setdiff(findall(==(true),getpath(grid)),[start])
    loops = fill(false,size(grid))
    for e in empties
        newgrid = copy(grid)
        newgrid[e] = '#'
        guard = start
        facing = CartesianIndex(-1,0)
        visited = Set()
        while true
            push!(visited,(guard,facing))
            guard,facing = nextmove(guard,facing,newgrid)
            if !(guard in CartesianIndices(grid))
                loops[e] = false
                break
            elseif (guard,facing) in visited
                loops[e] = true
                break
            end
        end
    end
    sum(loops)
end

pt2 = solveit2()