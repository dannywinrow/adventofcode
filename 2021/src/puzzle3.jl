using CSV, DataFrames

input = read("inputs\\input3.txt", String);

input = split(input,"\n")

input = [getindex(getindex(input,row),col).=='1' for row in 1:cnt, col in 1:strln]


function bitarr_to_int5(arr,s=0)
    v = 1
    for i in view(arr,length(arr):-1:1)
        s += v*i
        v <<= 1
    end 
    s
end

function part1(input)

    cnts = sum.(input[:,col] for col in 1:size(input)[2])
 
    gamma = cnts .> 500
    epsilon = .!gamma


    g = bitarr_to_int5(gamma)
    e = bitarr_to_int5(epsilon)
    g*e

end

function part2(input)

    filtered = input
    for i in 1:size(filtered)[2]
        keep = sum(filtered[:,i]) >= size(filtered)[1]/2
        filtered = filtered[filtered[:,i] .== keep ,:]
    end
    oxy = bitarr_to_int5(filtered)

    filtered = input
    for i in 1:size(filtered)[2]
        keep = sum(filtered[:,i]) < size(filtered)[1]/2
        filtered = filtered[filtered[:,i] .== keep ,:]
        if size(filtered)[1] < 2
            break
        end
    end
    filtered
    co2 =  bitarr_to_int5(filtered)

    oxy*co2
    
end

@show part1(input)
@show part2(input)
