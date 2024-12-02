include("../../helper.jl")

using CircularArrays

example = """...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
..........."""

#grid = loadgrid(parselines(example))

grid = loadgrid()

function getlayers(grid,m)
    start = findall(==('S'),grid)
    neighbours(ci) = filter(x->CircularArray(grid)[x] != '#',adjacents(ci))
    layers = [start]
    push!(layers,union(neighbours.(layers[end])...))
    for _ in 1:m
        layer = setdiff(union(neighbours.(layers[end])...),layers[end-1])
        push!(layers, layer)
    end
    layers
end

function solve(grid,stepcnt)
    #brute
    layers = getlayers(grid,stepcnt)
    length(vcat(layers[stepcnt+1:-2:1]...))
end

pt1 = solve(grid,64)


function solve2(grid,stepcnt)

    len = size(grid,1)
    layers = getlayers(grid,len+1)

    innerodd = length(vcat(layers[2:2:len÷2+1]...))
    innereven = length(vcat(layers[1:2:len÷2]...))
    outerodd = sum(in(CartesianIndices(grid)).(vcat(layers[2:2:len+1]...))) - innerodd
    outereven = sum(in(CartesianIndices(grid)).(vcat(layers[1:2:len+1]...))) - innereven
    
    #fullgrid = sum(in(CartesianIndices(grid)).(vcat(layers[1:len+1]...)))
    fullgridodd = sum(in(CartesianIndices(grid)).(vcat(layers[2:2:len+1]...))) 
    fullgrideven = sum(in(CartesianIndices(grid)).(vcat(layers[1:2:len+1]...))) 

    # Need to realise that the grid repeats and that it has nice blank
    # space around a diamond to ensure that all the reachable spaces are
    # reached before starting a new diamond
    x = stepcnt ÷ len ÷ 2

    # See 21.png for the visualisation which led to this formula
    # First letter - E is even parity, O is odd parity tile, 
    # Second letter - I is the inner diamond of the tile, O is the outer diamond
    #                   1,2,3,4 relate to the outer diamond triangles

    1*fullgridodd + 4*innerodd + 2*outerodd +
        (x*2) * outereven +
        (x*2-1) * (4*innerodd +  3*outerodd) +
        x^2 * 4*fullgrideven +
        x*(x-1) * 4*fullgridodd
end

pt2 = solve2(grid,26501365)


println("Part 1: $pt1")
println("Part 2: $pt2")

