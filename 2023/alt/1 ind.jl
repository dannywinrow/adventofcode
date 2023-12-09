include("../../helper.jl")


function getdigits(line)
    digits = []
    for (i,x) in enumerate(line)
        d = findfirst(==(x),"123456789")
        if isnothing(d)
            for (j,num) in enumerate(nums)
                if startswith(line[i:end],num)
                    push!(digits,j)
                end
            end
        else
            push!(digits,d)
        end
    end
    (digits[1],digits[end])
end

pt1 = solveit()
sum([x[1]*10+x[end] for x in solveit()])
submitanswer(1,pt1)

const nums = split("one, two, three, four, five, six, seven, eight, nine",", ")

function solveit()
    lines = loadlines()
    getdigits.(lines)
end

pt2 = solveit2()
submitanswer(2,pt2)

#Benchmarking
using BenchmarkTools
@benchmark pt1 = solveit()
@benchmark pt2 = solveit2()

#VISUALISATION
using Colors, ImageShow