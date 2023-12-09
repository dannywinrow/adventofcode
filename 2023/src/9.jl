include("../../helper.jl")

parseinput(lines = loadlines()) = [parse.(Int,split(line," ")) for line in lines]

diffs(nums) = nums[2:end] .- nums[1:end-1]

function next(seq)
    if length(unique(seq)) == 1
        return last(seq)
    else
        return last(seq) + next(diffs(seq))
    end
end

function previous(seq)
    if length(unique(seq)) == 1
        return first(seq)
    else
        return first(seq) - previous(diffs(seq))
    end
end

pt1 = sum(next.(parseinput()))
pt2 = sum(previous.(parseinput()))

println("Part 1: $pt1")
println("Part 2: $pt2")