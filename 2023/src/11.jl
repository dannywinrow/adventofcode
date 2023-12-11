include("../../helper.jl")

function solveit()
    grid = loadhashgrid()
    emptycols = findall(col->all(.!(col)),eachcol(grid))
    for x in reverse(emptycols)
        grid = hcat(grid[:,1:x],fill(false,size(grid,1)),grid[:,x+1:end])
    end
    emptyrows = findall(col->all(.!(col)),eachrow(grid))
    for x in reverse(emptyrows)
        grid = vcat(grid[1:x,:],fill(false,size(grid,2))',grid[x+1:end,:])
    end
    galaxies = findall(grid)
    cnt = 0
    while !isempty(galaxies)
        galaxy = pop!(galaxies)
        for galaxyto in galaxies
            cnt += abs(galaxy[1] - galaxyto[1]) + abs(galaxy[2] - galaxyto[2])
        end
    end
    cnt
end

pt1 = solveit()

function solveit2()
    grid = loadhashgrid() #function to load grid with . => false and # => true
    emptycols = findall(x->all(.!(x)),eachcol(grid))
    emptyrows = findall(x->all(.!(x)),eachrow(grid))
    galaxies = findall(grid)
    cnt = 0
    while !isempty(galaxies)
        galaxy = pop!(galaxies)
        for galaxyto in galaxies
            cnt += abs(galaxy[1] - galaxyto[1]) + abs(galaxy[2] - galaxyto[2])
            cnt += 999999 * count(x->in(x,min(galaxy[1],galaxyto[1]):max(galaxy[1],galaxyto[1])),emptyrows)
            cnt += 999999 * count(x->in(x,min(galaxy[2],galaxyto[2]):max(galaxy[2],galaxyto[2])),emptycols)
        end
    end
    cnt
end

pt2 = solveit2()

println("Part 1: $pt1")
println("Part 2: $pt2")