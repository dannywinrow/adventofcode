include("../../helper.jl")

using Memoization

example = """1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9"""

function parsebrick(line)
    cis = split(line,"~")
    cis = split.(cis,",")
    cis = [parse.(Int,ci) for ci in cis]
    CartesianIndices(Tuple(cis[1][i]:cis[2][i] for i in 1:length(cis[1])))
end

bricks = parsebrick.(loadlines())
#bricks = parsebrick.(parselines(example))

xmax = maximum([last(x)[1] for x in bricks])
ymax = maximum([last(x)[2] for x in bricks])
zmax = maximum([last(x)[3] for x in bricks])

xmin = minimum([last(x)[1] for x in bricks])
ymin = minimum([last(x)[2] for x in bricks])
zmin = minimum([last(x)[3] for x in bricks])

floor = CartesianIndices((xmin:xmax,ymin:ymax,0:0))
fixedbricks = [floor]
for z in 1:zmax
    for b in findall(x->first(x)[3]==z,bricks)
        bdown = bricks[b]
        for i in 1:z
            bdown = bdown .- CartesianIndex(0,0,1)
            if !isnothing(findfirst(x->!isempty(intersect(bdown,x)),fixedbricks))
                push!(fixedbricks,bdown .+ CartesianIndex(0,0,1))
                break
            end
        end
    end
end

supportedby = [findall(x->x!=fb && !isempty(intersect(fb .- CartesianIndex(0,0,1),x)),fixedbricks) for fb in fixedbricks]
pt1 = length(fixedbricks) - length(unique(vcat(filter(x->length(x)==1,supportedby)...)))

println("Part 1: $pt1")

@memoize function bricksfall(brem)
    falling = findall(x->!isempty(x) && x ⊆ brem,supportedby)
    fell = union(falling,brem)
    return length(fell) == length(brem) ? fell : bricksfall(fell)
end

pt2 = sum(length.([bricksfall([i]) for i in 2:length(fixedbricks)]) .- 1)


println("Part 2: $pt2")