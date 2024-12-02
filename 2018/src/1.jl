include("../../helper.jl")

function solveit()
    lines = loadlines()
    sum(parse.(Int,lines))
end

pt1 = solveit()

clipboard(pt1)
pt1 = 15
r = submitanswer(1,pt1)

function solveit2()
    lines = loadlines()
    actions = CircularArray(parse.(Int,lines))
    i = 0
    v = 0
    visited = Set()
    while true
        i += 1
        v += actions[i]
        if v in visited
            return v
        else
            push!(visited,v)
        end
    end
end

pt2 = solveit2()
clipboard(pt2)
submitanswer(2,pt2)

#Benchmarking
using BenchmarkTools
@benchmark pt1 = solveit()
@benchmark pt2 = solveit2()

#VISUALISATION
using Colors, Images