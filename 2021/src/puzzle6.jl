using CSV, DataFrames
import Base.parse
import Base.show
import Base.iterate

input = read("2021\\inputs\\input6.txt",String);
input = split(input,",")
input = parse.(Int,input)


function agefish!(fish, years = 1)
    for n in 1:years
        fish[8] += fish[1]
        fish[:] = vcat(fish[2:end],[fish[1]])
    end
end

function part1()
    fish = [sum(x->x==i,input) for i in 0:8]
    agefish!(fish,80)
    return sum(fish)
end

function part2()
    fish = [sum(x->x==i,input) for i in 0:8]
    agefish!(fish,256)
    return sum(fish)
end

@show part1()
@show part2()