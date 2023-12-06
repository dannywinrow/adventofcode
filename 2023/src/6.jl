include("../../helper.jl")

win(time,distance,charge) = charge * (time - charge) > distance
win(time,distance) = charge -> win(time,distance,charge)
countwins(time,distance) = count(win(time,distance),1:time-1)

function solveit()
    lines = loadlines()
    times, distances = [[parse(Int,x.match) for x in y] for y in eachmatch.(r"\d+",lines)]

   *(countwins.(times,distances)...)
end

pt1 = solveit()
clipboard(pt1)
submitanswer(1,pt1)

function solveit2()
    lines = loadlines()
    time, distance = [parse(Int,replace(x.match," "=>"")) for x in match.(r"[\d ]+",lines)]

    bound = distance ÷ time
    first = findfirst(x->win(time,distance,x), bound : time) + bound - 1
    last = (time - distance ÷ time + 1) - findfirst(x->win(time,distance,x))
    length(first:last)
end

win(time,distance,d-1)
length(c:d)
pt2 = solveit2()
clipboard(pt2)
submitanswer(2,pt2)

#Benchmarking
using BenchmarkTools
@benchmark pt1 = solveit()
@benchmark pt2 = solveit2()

#VISUALISATION
using Colors, ImageShow