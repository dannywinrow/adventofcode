include("../../helper.jl")

grid = loadgrid(Char;permute=false)

function nums(grid)
    nums = CartesianIndices[]
    for col in eachcol(CartesianIndices(grid))
        firstdigit = nothing
        lastdigit = nothing
        for I in col
            if isdigit(grid[I])
                isnothing(firstdigit) && (firstdigit = I)
                lastdigit = I
                if I == col[end]
                    push!(nums,firstdigit:lastdigit)
                end
            else
                if !isnothing(firstdigit)
                    push!(nums,firstdigit:lastdigit)
                    firstdigit = nothing
                end
            end
        end
    end
    nums
end

issymbol(x::Char) = x != '.' && !isdigit(x)
symbols(grid) = findall(issymbol,grid)

unit = CartesianIndex(1,1)
surround(area::CartesianIndices) = (first(area) - unit) : (last(area) + unit)
surround(index::CartesianIndex) = index - unit : index + unit

ispart(num,grid=grid) = !isempty(intersect(symbols(grid),surround(num)))
partvalue(part,grid=grid) = parse(Int,join(grid[part]))
parts(grid) = filter(ispart,nums(grid))
solveit() = sum(partvalue.(parts(grid)))

pt1 = solveit()

isadjacent(num,symbol) = first(num) in surround(symbol) || last(num) in surround(symbol)
isadjacent(symbol) = num -> isadjacent(num,symbol)
adjacentparts(symbol) = filter(isadjacent(symbol),nums(grid))
gears(grid) = findall(==('*'),grid)

function gearpower(gear)
    gearparts = adjacentparts(gear)
    if length(gearparts) == 2
        return *(partvalue.(gearparts)...)
    end
    false
end

solveit2() = sum(gearpower.(gears(grid)))
pt2 = solveit2()

println("Part 1: $pt1")
println("Part 2: $pt2")