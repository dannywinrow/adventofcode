import Base.show
import Base.parse


function readinput(file)
    input = read(file,String);
    input = split(input,"\r\n")
    input = split.(input,"")
    dim1 = length(input)
    dim2 = length(input[1])
    input = parse.(Int,vcat(input...))
    input = reshape(input,dim1,dim2)
    OctopusGrid(input)
end


struct OctopusGrid
    grid
end
grid = steps[2]
function step(grid::OctopusGrid)
    newgrid = OctopusGrid(copy(grid.grid))

    newgrid.grid[:,:] .+= 1

    flashing = CartesianIndices(newgrid.grid)[newgrid.grid .== 10]
    while length(flashing) > 0
        ci = splice!(flashing,1)
        for adj in getadjacent(ci,size(newgrid.grid)...)
            if newgrid.grid[adj] != 10
                newgrid.grid[adj] += 1
                if newgrid.grid[adj] == 10
                    push!(flashing,adj)
                end
            end
        end
    end
    newgrid.grid[newgrid.grid .== 10] .= 0
    newgrid
end

step(steps[2])
function Base.show(io::IO, grid::OctopusGrid)
    print(io, "\n")
    dim = size(grid.grid)[1]
    for ci in CartesianIndices(grid.grid)
        num = grid.grid[ci]
        if num == 0
            printstyled(io,lpad(num, 3," "),color=:red)
        else
            print(io,lpad(num, 3," "))
        end
        if ci[1] == dim
            print(io, "\n")
        end
    end
end
Base.show(io::IO, ::MIME"text/plain", grid::OctopusGrid) = print(io, "OctopusGrid:\n", grid)
for xadd in [-1,0,1], yadd in [-1,0,1] 
    @show xadd
    @show yadd
end

function getadjacent(ci,xbound = 100, ybound = 100)
    adj = []
    for xadd in [-1,0,1], yadd in [-1,0,1] 
        if !((xadd == 0) && (yadd == 0))
            x = ci[1] + xadd
            y = ci[2] + yadd
            if (1 <= x <= xbound) && (1 <= y <= ybound)
                push!(adj,CartesianIndex(x,y))
            end
        end
    end
    return adj
end

function part1test()
    grid = readinput("2021\\inputs\\input11test.txt")
    steps = [grid]
    for n in 1:101
        push!(steps,step(steps[n]))
    end
    sum([sum(grid.grid .== 0) for grid in steps])
end
steps[1]
steps[2]
steps[3]
steps[4]
steps[101]
function part1()
    grid = readinput("2021\\inputs\\input11.txt")
    steps = [grid]
    for n in 1:101
        push!(steps,step(steps[n]))
    end
    sum([sum(grid.grid .== 0) for grid in steps])
end

function part2test()
    grid = readinput("2021\\inputs\\input11test.txt")
    i = 0
    while sum(grid.grid .> 0) > 0
        grid = step(grid)
        i += 1
    end
    i
end
function part2()
    grid = readinput("2021\\inputs\\input11.txt")
    i = 0
    while sum(grid.grid .> 0) > 0
        grid = step(grid)
        i += 1
    end
    i
end

@show part1test();
@show part1();
@show part2test();
@show part2();
ground = parse(Ground,input)

     
for ci in CartesianIndices(t)
    @show ci
end
for ci in CartesianIndices(t')
    @show ci
end