include("../../helper.jl")

function solveit(ops=[*,+])
    lines = loadlines()
    lines = split.(lines,": ")
    testnumbers = parse.(Int,getindex.(lines,1))
    othernums = [parse.(Int,x) for x in split.(getindex.(lines,2)," ")]
    sum(testnumbers[[canbesolved(x...,ops) for x in zip(testnumbers,othernums)]])
end

function canbesolved(testnum, othernums, ops)
    if length(othernums) == 1
        othernums[1] == testnum
    elseif testnum < othernums[1] # increasing ops only, no negative numbers
        false
    else
        x = false
        for op in ops
            x = x || canbesolved(testnum,[op(othernums[1:2]...),othernums[3:end]...],ops)
        end
        x
    end
end

pt1 = solveit()

function concat(x,y)
    x*10^ceil(Int,log10(y+1)) + y
end

pt2 = solveit([concat,*,+])