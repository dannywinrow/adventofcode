using CSV, DataFrames
import Base.parse
import Base.show
import Base.iterate


input = read("2021\\inputs\\input7.txt",String);
input = split(input,",")
input = parse.(Int,input)

function part1()
    av = round(mean(input))
    minimum([sum(abs.(input .- av)) for av in 300:500])
end

function part2()
    f(x) = x*(x+1)/2
    minimum([sum(f.(abs.(input .- av))) for av in 300:500])
end

@show part1()
@show part2()