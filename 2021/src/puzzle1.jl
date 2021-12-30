using CSV, DataFrames

input = CSV.read("inputs\\input1.txt", header=[:num], DataFrame)

first() = sum(input[:,:num][1:end-1] .< input[:,:num][2:end])
second() = sum(input[:,:num][1:end-3] .< input[:,:num][4:end])

@show first();
@show second();