include("../../helper.jl")

using Colors
using CircularArrays

example = """R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)"""

function solve()
    lines = loadlines()
    start = CartesianIndex(0,0)
    curr = start
    digoutedge = [start]
    colours = [colorant"Black"]
    for line in lines
        m = match(r"(\w) (\d+) \((#\w+)\)",line)
        dir, len, colour = m
        dir = eval(Meta.parse(dir))
        len = parse(Int,len)
        colour = parse(Colorant,colour)
        #@info dir,len,colour
        for _ in 1:len
            push!(digoutedge,curr+=dir)
            push!(colours,colour)
        end
    end
        
    digoutedge = digoutedge .- Ref(minimum(digoutedge) - CartesianIndex(2,2))

    grid = fill(colorant"White",Tuple(maximum(digoutedge)+CartesianIndex(1,1)))
    grid[digoutedge] .= colours

    function floodfill(grid,cell,fillwith)
        fillfrom = grid[cell]
        queue = [cell]
        while !isempty(queue)
            ci = pop!(queue)
            for ni in neighbours(ci)
                if ni in CartesianIndices(grid)
                    if grid[ni] == fillfrom
                        grid[ni] = fillwith
                        push!(queue,ni)
                    end
                end
            end
        end
    end
    floodfill(grid,CartesianIndex(1,1),colorant"Yellow")
    *(size(grid)...) - count(==(colorant"Yellow"),grid)
end

pt1 = solve()

function parsefirst(lines)
    instrs = []
    for line in lines
        dir, len = match(r"(\w) (\d+) \(#\w+\)",line)
        dir = eval(Meta.parse(dir))
        len = parse(Int,len)
        push!(instrs,(dir,len))
    end
    CircularArray(instrs)
end
function parsesecond(lines)
    instrs = []
    directions = [R,D,L,U]
    for line in lines
        len, dir = match(r"\w \d+ \(#(\w{5})(\d)\)",line)
        dir = directions[parse(Int,dir)+1]
        len = parse(Int,len;base=16)
        push!(instrs,(dir,len))
    end
    CircularArray(instrs)
end

# Assumes anti-clockwise
function solve2(instrs)
    start = CartesianIndex(0,0)
    curr = start
    j = 0
    for (i,(dir,len)) in enumerate(instrs)
        lastdir = instrs[i-1][1]
        nextdir = instrs[i+1][1]
        if dir == U
            j += (len-1)*(curr[2]-1)
            if lastdir == L
                j += (curr[2]-1)
            end
            if nextdir == R
                j += (curr[2]-1)
            end
        elseif dir == D
            j -= (len-1)*(curr[2])
            if lastdir == R
                j -= (curr[2])
            end
            if nextdir == L
                j -= (curr[2])
            end
        end
        #@info dir,len
        newcurr = curr+dir*len
        curr = newcurr
    end
    abs(j)
end
pt2 = solve2(parsesecond(loadlines()))

println("Part 1: $pt1")
println("Part 2: $pt2")

#square = """R 2 (#70c710)
#D 2 (#0dc571)
#L 2 (#5713f0)
#U 2 (#d2c081)"""
#@run solve2(parsefirst(parselines(square)))
