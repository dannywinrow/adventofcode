using CSV, DataFrames

input = CSV.read("2020\\inputs\\input1.txt", header=[:num], DataFrame)

function firs(input, target)
    input[:,:found] = in(input[:,:num]).(target .- input[:,:num])
    input
end

*(input[input.found,:num]...)

input[:,:match] = 2020 .- input[:,:num]

i = 0
x = []
for row in eachrow(input)
    i += 1
    res = firs(input[Not(i),:], 2020-row[:num])
    if sum(res.found) == 2
      x = [row[:num],res[res.found,:num]...]
    end
end
x
*(x...)