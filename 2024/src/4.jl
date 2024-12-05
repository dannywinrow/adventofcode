include("../../helper.jl")

function solveit()
    grid = loadgrid()
    length(findalloverlap("XMAS",grid))
end

findalloverlap(word::AbstractString,grid::Matrix{Char}) = 
    filter(rng->last(rng) in CartesianIndices(grid) && join(grid[rng]) in [word,reverse(word)],
        [ [ci + d*(i-1) for i in 1:length(word)] for ci in CartesianIndices(grid) for d in [D,R,CartesianIndex(1,1),CartesianIndex(1,-1)]])

findallcrosses(word::AbstractString,grid::Matrix{Char}) = 
    filter(rng->join(grid[rng[1]]) in [word,reverse(word)] && join(grid[rng[2]]) in [word,reverse(word)],
        [ ([ci + CartesianIndex(1,1)*(i-1) for i in 1:length(word)],[ci+CartesianIndex(0,2) + CartesianIndex(1,-1)*(i-1) for i in 1:length(word)]) for ci in CartesianIndices(grid[1:end-length(word)+1,1:end-length(word)+1])])

pt1 = solveit()

clipboard(pt1)
submitanswer(1,pt1)

function solveit2()
    grid = loadgrid()
    length(findallcrosses("MAS",grid))
end

pt2 = solveit2()
clipboard(pt2)
submitanswer(2,pt2)


# Cleaned for Reddit (no helper.jl)

[LANGUAGE: Julia]

lines = readlines("2024/inputs/4p1.txt")
grid = hcat(split.(lines,"")...)

findallwords(word,grid) = 
    filter(
        rng->
            last(rng) in CartesianIndices(grid) &&
            join(grid[rng]) in [word,reverse(word)],

        [[ci + d*i for i in 0:length(word)-1]
            for ci in CartesianIndices(grid)
            for d in [D,R,CartesianIndex(1,1),CartesianIndex(1,-1)]
        ]
    )

pt1answer = length(findallwords("XMAS",grid))

findallcrosses(word,grid) = 
    filter(
        rng->
            join(grid[rng[1]]) in [word,reverse(word)] &&
            join(grid[rng[2]]) in [word,reverse(word)],
        [(
            [ci + CartesianIndex(1,1)*(i-1) for i in 1:length(word)],
            [ci+CartesianIndex(0,2) + CartesianIndex(1,-1)*(i-1) for i in 1:length(word)]
        ) for ci in CartesianIndices(grid[1:end-length(word)+1,1:end-length(word)+1])]
    )

pt2answer = length(findallcrosses("MAS",grid))


