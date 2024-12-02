include("../../helper.jl")

function solveit()
    lines = loadlines()
    lines = split.(lines,"   ")
    list1 = sort(parse.(Int,getindex.(lines,1)))
    list2 = sort(parse.(Int,getindex.(lines,2)))
    sum(abs.(list1 .- list2))
end

pt1 = solveit()
submitanswer(1,pt1)

function solveit2()
    lines = loadlines()
    lines = split.(lines,"   ")
    list1 = sort(parse.(Int,getindex.(lines,1)))
    list2 = sort(parse.(Int,getindex.(lines,2)))
    sum(filter(in(list1),list2))
end

pt2 = solveit2()
submitanswer(2,pt1)

# For reddit solutions thread
lines = readlines("2024/inputs/1p1.txt")
lines = split.(lines,"   ")
list1 = sort(parse.(Int,getindex.(lines,1)))
list2 = sort(parse.(Int,getindex.(lines,2)))

pt1answer = sum(abs.(list1 .- list2))
pt2answer = sum(filter(in(list1),list2))