include("../../helper.jl")


example = """seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4"""

function parseinput(input = getinput())
    parts = split(input,"\n\n")
    seeds = parse.(Int,split(split(parts[1],": ")[2]," "))

    function parsemap(m)
        p = split(m,"\n")[2:end]
        filter!(!=(""),p)
        [parse.(Int,x) for x in split.(p," ")]
    end
    maps = parsemap.(parts[2:end])

    mapnames = [split(x,"\n")[1] for x in parts[2:end]]

    seeds,maps,mapnames
end

function solveit()
    minloc = Inf
    for seed in seeds
        num = seed
        for map in maps
            for r in map
                gap = num - r[2]
                if 0 <= gap <= r[3]
                    num = r[1] + gap
                    break
                end
            end
        end
        minloc = floor(Int,min(num,minloc))
    end
    minloc
end

pt1 = solveit()
clipboard(pt1)
submitanswer(1,pt1)

function simplify(a::UnitRange,b::UnitRange)
    ret = min(a[1],b[1]):max(a[end],b[end])
    length(ret) <= length(a) + length(b) ? ret : nothing
end
function simplify(v)
    ranges = copy(v)
    outranges=UnitRange[]
    while !isempty(ranges)
        range = pop!(ranges)
        broke = false
        for (i,r) in enumerate(ranges)
            if !isnothing(simplify(range,r))
                ranges[i] = simplify(range,r)
                broke = true
                break
            end
        end
        if !broke
            push!(outranges,range)
        end
    end
    outranges
end
function maprange(map,range)
    ranges = [range]
    outranges = []
    while !isempty(ranges)
        range = pop!(ranges)
        found = false
        for r in map
            mrng = intersect(range,r[2]:r[2]+r[3])
            if !isempty(mrng)
                push!(outranges,mrng .+ (r[1]-r[2]))
                append!(ranges,filter(!isempty,[range[1]:r[2]-1,r[2]+r[3]+1:range[end]]))
                found = true
                break
            end
        end
        !found && push!(outranges,range)
    end
    outranges
end

function solveit2(input = getinput();simplify=x->x)
    seeds,maps,mapnames = parseinput(input) 
    seedranges = [seeds[x]:seeds[x]+seeds[x+1] for x in 1:2:length(seeds)]
    ranges = seedranges
    for map in maps
        newranges = []
        for range in ranges
            append!(newranges,maprange(map,range))
        end
        ranges = simplify(newranges)
    end
    minimum([x[1] for x in ranges])
end

pt2 = solveit2()
clipboard(pt2)
submitanswer(2,pt2)

#Benchmarking
using BenchmarkTools
@benchmark pt1 = solveit()
@benchmark pt2 = solveit2()
@benchmark pt2s = solveit2(;simplify=simplify)

#VISUALISATION
using Colors, ImageShow