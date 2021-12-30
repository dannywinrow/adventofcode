import Base.show
import Base.parse

input = read("2021\\inputs\\input9.txt",String);
input = split(input,"\r\n")
input = split.(input,"")
input = reshape(vcat(input...),length(input[1]),length(input))
input = parse.(Int,input)

struct Ground
    matrix
    riskpoints
    basins
end

function Base.parse(Ground, input)
    matrix = input
    riskpoints = getriskpoints(input)
    riskindices = CartesianIndices(riskpoints)[riskpoints]
    basin = getbasin.(Ref(matrix),riskindices)
    Ground(matrix,riskpoints,basin)
end

function Base.show(io::IO, ground::Ground)
    print(io, "\n")
    dim = size(ground.matrix)[1]
    for ci in CartesianIndices(ground.matrix)
        num = ground.matrix[ci]
        if ground.riskpoints[ci]
            printstyled(io,lpad(num, 3," "),color=:red)
        elseif ci in vcat(ground.basins...)
            printstyled(io,lpad(num, 3," "),color=:blue)
        else
            print(io,lpad(num, 3," "))
        end
        if ci[1] == dim
            print(io, "\n")
        end
    end
end


function getriskpoints(input)
    dim = size(input)
    filler = maximum(input)
    borders = hcat(fill(filler,dim[1]+2),vcat(fill(filler,dim[2])',input,fill(filler,dim[2])'),fill(filler,dim[1]+2))
    below = borders[2:end-1,2:end-1] .< borders[3:end,2:end-1]
    above = borders[1:end-2,2:end-1] .> borders[2:end-1,2:end-1]
    left = borders[2:end-1,2:end-1] .< borders[2:end-1,3:end]
    right = borders[2:end-1,1:end-2] .> borders[2:end-1,2:end-1]
    below .& right .& left .& above
end

function getadjacent(ci,xbound = 100, ybound = 100)
    adj = []
    for xadd in [-1,1]
        x = ci[1] + xadd
        y = ci[2] + xadd
        if (1 <= x <= xbound)
            push!(adj,CartesianIndex(x,ci[2]))
        end
        if (1 <= y <= ybound)
            push!(adj,CartesianIndex(ci[1],y))
        end
    end
    return adj
end

function getbasin(input,ci)
    tosearch = [ci]
    searched = []
    while length(tosearch) > 0
        ci = splice!(tosearch,1)
        for adj in getadjacent(ci,size(input)[1],size(input)[2])
            if (input[ci] < input[adj]) && (input[adj] != 9) && !in(adj,searched) && !in(adj,tosearch)
                push!(tosearch,adj)
            end
        end
        push!(searched,ci)
    end
    return searched
end


function part1()
    sum(input[getriskpoints(input)] .+ 1)
end

function part2()
    ground = parse(Ground,input);
    *(sort(length.(ground.basins),rev=true)[1:3]...)
end

#@show part1();
@show part2();

ground = parse(Ground,input)

     
for ci in CartesianIndices(t)
    @show ci
end
for ci in CartesianIndices(t')
    @show ci
end