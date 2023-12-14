include("../../helper.jl")

example = """O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#...."""

function tiltcol!(col)
    j = 1
    for (i,c) in enumerate(col)
        if c == 'O'
            col[i] = '.'
            col[j] = 'O'
            j += 1
        elseif c == '#'
            j = i+1
        end
    end
    col
end
tilt!(grid) = hcat(tiltcol!.(eachcol(grid))...)

function cycle!(grid)
    for _ in 1:4
        grid = rotr90(tilt!(grid))
    end
    grid
end

function value(grid)
    sum(size(grid,1) - x[1] + 1 for x in findall(==('O'),grid))
end

function solve(grid,n)
    grids = []
    i = 1
    while i < n
        grid=cycle!(copy(grid))
        x = findfirst(==(grid),grids)
        if isnothing(x)
            push!(grids,grid)
        else
            len = length(grids) - x + 1
            bef = x-1
            r = (n - bef) % len
            return value(grids[r + bef])
        end
        i += 1
    end
end

n = 1000000000
#grid = loadgrid(Char,split(example,"\n"))
grid = loadgrid(Char)
pt1 = value(tilt!(copy(grid)))
pt2 = solve(grid,n)

println("Part 1: $pt1")
println("Part 2: $pt2")