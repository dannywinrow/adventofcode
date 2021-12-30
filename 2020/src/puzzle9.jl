using CSV, DataFrames

input = read("2020\\inputs\\input9.txt",String);
input = split(input,"\r\n")
input = [parse(Int,i) for i in input]

x = 25

function part1()
    possible = zeros(Int,x,x)
    for i in 1:x-1, j in i+1:x
        possible[i,j] = input[i] + input[j]
    end
    possible
    for (i,val) in enumerate(input[x+1:end])
        if val in possible
            possible = possible[2:end,2:end]
            newvals = input[i+1:i+x-1] .+ val
            possible = hcat(possible,newvals)
            possible = vcat(possible,zeros(Int,x)')
        else
            return val
        end
    end
end

function part2()    
    num = part1()
    i = 1
    j = 2
    while sum(input[i:j]) != num
        while sum(input[i:j]) < num
            j += 1
        end
        while sum(input[i:j]) > num
            i += 1
            (j==i) && (j += 1)
        end
    end
    return maximum(input[i:j]) + minimum(input[i:j])
end

@show part1()
@show part2()
