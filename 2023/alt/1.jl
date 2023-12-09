include("../../helper.jl")

function solveit()
    lines = loadlines()
    s = 0
    for x in lines
        s += parse(Int,match(r"\d",x).match)*10 + parse(Int,matchlast(r"\d",x).match)
    end
    s
end

pt1 = solveit()
submitanswer(1,pt1)

const nums = split("one, two, three, four, five, six, seven, eight, nine",", ")

function solveit2()
    lines = loadlines()
    mat = Regex(join(nums,"|")*"|\\d")
    matrev = Regex(join(reverse.(nums),"|")*"|\\d") 
    s = 0
    pars(x) = @something(findfirst(==(x[1]),"123456789"),findfirst(==(x),nums))
    for line in lines
        s += pars(match(mat,line).match)*10
        s += pars(reverse(match(matrev,reverse(line)).match))
    end
    s
end

pt2 = solveit2()
submitanswer(2,pt2)

#Benchmarking
using BenchmarkTools
@benchmark pt1 = solveit()
@benchmark pt2 = solveit2()

#VISUALISATION
using Colors, ImageShow