using CSV, DataFrames

input = read("2020\\inputs\\input6.txt",String);
input = split(input,"\r\n\r\n")

function part1(input)
    input = replace.(input,"\r\n"=>"")
    sum(length.(unique.(input)))
end

function part2(input)    
    sum([sum([count(i->(i==j), z) for j in 'a':'z'] .== (count("\r\n", z) + 1)) for z in input])
end

@show part1(input)
@show part2(input)
