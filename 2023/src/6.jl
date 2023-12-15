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

function solveit2()
    lines = loadlines()
    time, distance = [parse(Int,replace(x.match," "=>"")) for x in match.(r"[\d ]+",lines)]

    bound = distance ÷ time
    first = findfirst(x->win(time,distance,x), bound : time) + bound - 1
    last = (time - distance ÷ time + 1) - findfirst(x->win(time,distance,x), (time-bound):-1:1)
    length(first:last)
end

pt2 = solveit2()

println("Part 1: $pt1")
println("Part 2: $pt2")