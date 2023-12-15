include("../../helper.jl")

function solveit()
    lines = loadlines()
end

pt1 = solveit()
clipboard(pt1)
submitanswer(1,pt1)

function solveit2()
    lines = loadlines()
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