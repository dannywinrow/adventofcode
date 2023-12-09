include("../../helper.jl")

input = getinput()

s = findfirst(==('\n'),input) - 1
grid = replace(input,"\n"=>"")
symbols = [y[1] for y in findall(r"[^.\d]",grid)]
nums = findall(r"\d+",grid)

# In case num wraps around lines (doesn't handle num taking up whole line)
for (i,num) in enumerate(nums)
    line1 = (num[1]-1) ÷ s + 1
    line2 = (num[end]-1) ÷ s + 1
    if line2 > line1
        nums[i] = num[1]:s*line1
        push!(nums,s*line1+1:num[end])
    end
end

function surround(num)
    a = num[1] % s == 1 ? num[1] : num[1] - 1
    b = num[end] % s == 0 ? num[end] : num[end] + 1
    vcat(collect(a:b),collect(a-s:b-s),collect(a+s:b+s))
end

ispart(num) = !isempty(intersect(surround(num),symbols))
getnum(num) = parse(Int,grid[num])

pt1 = sum(ispart.(nums) .* getnum.(nums))

gears = [y for y in findall(r"\*",grid)]

function numssurround(gear)
    gearnums = []
    for n in surround(gear)
        f = findfirst(x->in(n,x),nums)
        !isnothing(f) && push!(gearnums,nums[f])
    end
    unique!(gearnums)
end

function gearpower(gear)
    gearnums = numssurround(gear)
    if length(gearnums) == 2
        return *(getnum.(gearnums)...)
    end
    0
end

pt2 = sum(gearpower.(gears))

println("Part 1: $pt1")
println("Part 2: $pt2")