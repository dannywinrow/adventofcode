include("../../helper.jl")

using Combinatorics

function solveit()
    grid = loadgrid()
    gridlocs = Dict(k=>findall(==(k),grid) for k in unique(grid))

    antinode = fill(false,size(grid))
    for (k,v) in gridlocs
        if k != '.'
            for c in combinations(v,2)
                x,y = c
                a = 2y - x 
                b = 2x - y
                a in CartesianIndices(grid) && (antinode[a] = true)
                b in CartesianIndices(grid) && (antinode[b] = true)
            end
        end
    end
    sum(antinode)
end

pt1 = solveit()

function Base.gcd(ci::CartesianIndex)
    CartesianIndex(Tuple(ci) .÷ gcd(Tuple(ci)...))
end

function solveit2()
    grid = loadgrid()
    gridlocs = Dict(k=>findall(==(k),grid) for k in unique(grid))

    
    antinode = fill(false,size(grid))
    for (k,v) in gridlocs
        if k != '.'
            for c in combinations(v,2)
                x,y = c
                a = gcd(y - x)
                ci = x
                while ci in CartesianIndices(grid)
                    antinode[ci] = true
                    ci += a
                end
                ci = x-a
                while ci in CartesianIndices(grid)
                    antinode[ci] = true
                    ci -= a
                end
            end
        end
    end
    sum(antinode)
end

pt2 = solveit2()