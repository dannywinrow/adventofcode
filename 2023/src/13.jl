include("../../helper.jl")

exampleinput = """#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#"""

function parseinput(input = getinput())
    grids = strip.(split(input,"\n\n"))
    parsehashgrid.(split.(grids,"\n"))
end
function f(grid)
    for i in 1:size(grid,1)-1
        rows = min(i,size(grid,1)-i)
        grid[i:-1:i-rows+1,:] == grid[i+1:i+rows,:] && return i
    end
end
solve(grid) = @something f(rotr90(grid)) 100*f(grid)
#ex = sum(solve.(parseinput(exampleinput)))
pt1 = sum(solve.(parseinput()))


function g(grid)
    for i in 1:size(grid,1)-1
        rows = min(i,size(grid,1)-i)
        sum(grid[i:-1:i-rows+1,:] .!= grid[i+1:i+rows,:]) == 1 && return i
    end
end
solve2(grid) = @something g(rotr90(grid)) 100*g(grid)
pt2 = sum(solve2.(parseinput()))

println("Part 1: $pt1")
println("Part 2: $pt2")