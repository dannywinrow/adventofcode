include("../../helper.jl")

function solveit()
    lines = loadlines()
    s = 0
    for x in lines
        s += parse(Int,x[findfirst(r"\d",x)])*10 + parse(Int,reverse(x)[findfirst(r"\d",reverse(x))])
    end
    s
end

pt1 = solveit()

const nums = split("one, two, three, four, five, six, seven, eight, nine",", ")

function solveit2(lines = loadlines())
    sum(parseline.(lines))
end

#regex didn't work because eachmatch doesn't pick up overlapping numbers
function parseline(x)
    a = []
    for n in 1:length(x)
        z = findfirst(x[n],"123456789")
        if isnothing(z)
            for (i,num) in enumerate(nums)
                if n+length(num)-1 <= length(x)
                    if x[n:n+length(num)-1] == num
                        push!(a,i)
                    end
                end
            end
        else
            push!(a, z[1])
        end
    end
    a[1]*10 + a[end]
end

pt2 = solveit2()

println("Part 1: $pt1")
println("Part 2: $pt2")