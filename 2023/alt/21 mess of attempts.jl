include("../../helper.jl")

using CircularArrays

example = """...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
..........."""
grid = loadgrid(parselines(example))
function makebig(grid,m)
    start = findfirst(==('S'),grid)
    newgrid = repeat(grid,m,m)
    replace!(newgrid,'S'=>'.')
    newgrid[start + (m ÷ 2) * CartesianIndex(size(grid))] = 'S'
    newgrid
end


#colorme(grid)
grid = loadgrid()
cgrid = CircularArray(grid)
biggrid = makebig(grid,5)
colorme(biggrid)
fneighbours(ci) = filter(x->x in CartesianIndices(grid) && grid[x] != '#',adjacents(ci))


start = findfirst(==('S'),grid)
function getsteps(grid,m;allsteps = false)
    allsteps && (steps = [])
    for _ in 1:m
        allsteps && push!(steps, copy(grid))
        nb = union(fneighbours.(findall(==('S'),grid))...)
        newgrid = replace(grid,'S'=>'.')
        #@info newgrid, nb
        newgrid[nb] .= 'S'
        grid = newgrid
    end
    allsteps && return steps
    grid
end

function getlayers(grid,m)
    start = findall(==('S'),grid)
    neighbours(ci) = filter(x->CircularArray(grid)[x] != '#',adjacents(ci))
    layers = [start]
    push!(layers,union(neighbours.(layers[end])...))
    for i in 1:m
        layer = setdiff(union(neighbours.(layers[end])...),layers[end-1])
        push!(layers, layer)
        i % 100 == 0 && (@info "$i/$m")
    end
    layers
end

layers = getlayers(grid,131*2)
layers[66]
colorme(union(layers[1:2:65]...))
getsteps(grid,131;allsteps=true)
layers[1:5]
using ImageShow
using Colors
colors = Dict('.' => colorant"White", '#' => colorant"Black", 'S' => colorant"Green")
colorme(grid) = [colors[c] for c in grid]
layers[66]
gridb = CircularArray(copy(grid))
replace!(gridb,'S'=>'.')
imggrids = [copy(gridb),copy(gridb)]
i = 1
function nextimg()
    global i
    n = 2 - (i%2)
    imggrids[n][layers[i]] .= 'S'
    i += 1
    colorme(imggrids[n][start[1]-i-5:start[2]+i+5,start[1]-i-5:start[2]+i+5])
end

function getlayerscnt(grid,m)
    start = findall(==('S'),grid)
    neighbours(ci) = filter(x->CircularArray(grid)[x] != '#',adjacents(ci))
    unblocked = findall(!=('#'),grid)
    flips = [filter(x->(x[1]+x[2]) % 2 == 1, unblocked),
    filter(x->(x[1]+x[2]) % 2 == 0, unblocked)]
    if (start[1][1] + start[1][2]) % 2 == 1
        gridsplit = filter.(x->grid[x] != '#',[[CartesianIndex(x,y) for x in 1:2:size(grid,1), y in 1:2:size(grid,2)], [CartesianIndex(x,y) for x in 2:2:size(grid,1), y in 2:2:size(grid,2)]])
    end
    cnta = fill(0,size(grid))
    cnta[start] = 1
    cis = findall(>(0),cnta)
    neighbours
    layers = [start]
    push!(layers,union(neighbours.(layers[end])...))
    for i in 1:m
        layer = setdiff(union(neighbours.(layers[end])...),layers[end-1])
        push!(layers, layer)
        i % 100 == 0 && (@info m)
    end
    layers
end
layers = getlayers(grid,5000)

function sweepcnt(moves)
    indices = [CartesianIndex(moves,0)+start+CartesianIndex(-i,i) for i in moves]
    acnt = 0
    for j in 1:moves
        acnt += cnt(indices)
        indices .+ CartesianIndex(-1,-1)
    end
end
sweepcnt(5000)

using Memoization
@memoize function cnt(indices)
    cgrid = CircularArray(grid)
    count(!=('#'),cgrid[indices])
end

moves = 26501365
function findrepeat(ci)
    corner = start + CartesianIndex(moves,0)
    carr = CircularArray(CartesianIndices(grid))
    cornershort = carr[corner]
    @info cornershort
    cornerrepeat = corner
    while true
        cornerrepeat += ci
        @info carr[cornerrepeat]
        carr[cornerrepeat] == cornershort && break
    end
    cornerrepeat
end
findrepeat(CartesianIndex(-1,-1))

len = size(grid,1)
cgrid = CircularArray(grid)
acnt = 0
rep = [carr[corner + x*CartesianIndex(-1,1) + y*CartesianIndex(-1,-1)] for x in 0:len-1, y in 0:len-1]
acnt += (moves ÷ len)^2*count(!=('#'),cgrid[rep])
edge = moves % len
repedge = [carr[corner + x*CartesianIndex(-1,1) + y*CartesianIndex(-1,-1)] for x in 0:edge-1, y in 0:len-1]
cnt += (moves ÷ len)*count(!=('#'),cgrid[repedge])
repedge = [carr[corner + x*CartesianIndex(-1,1) + y*CartesianIndex(-1,-1)] for x in 0:len-1, y in 0:edge-1]
cnt += (moves ÷ len)*count(!=('#'),cgrid[repedge])
repedge = [carr[corner + x*CartesianIndex(-1,1) + y*CartesianIndex(-1,-1)] for x in 0:edge-1, y in 0:edge-1]
cnt += count(!=('#'),cgrid[repedge])
pt2 = cnt
clipboard(pt2)

total = count(!=('#'),grid)
innerodd = length(vcat(layers[2:2:66]...))
innereven = length(vcat(layers[1:2:65]...))
outerodd = hcat
outer = 
((moves ÷ len)*2+1)^2*count(!=('#'),grid)

reptotal = [carr[corner + x*CartesianIndex(-1,1) + y*CartesianIndex(-1,-1)] for x in 0:edge-1, y in 0:edge-1]

#!590595761380176

# VISUALISE expanding lines
function group(i)
    ret = [CartesianIndex(0,i),CartesianIndex(i,0)]
    for x in 1:i
        push!(ret,CartesianIndex(x,i-x))
        push!(ret,CartesianIndex(-x,i-x))
        if x != i
            push!(ret,CartesianIndex(x,x-i))
            push!(ret,CartesianIndex(-x,x-i))
        end
    end
    ret
end
group(2)
function line(i)
    ret = []
    for x in 0:i
        push!(ret,CartesianIndex(x,i-x))
    end
    Ref(start) .+ ret
end

function showstep(i)
    g = copy(cgrid)
    g[group(i)] .= 'S'
    colorme(g)
end

function showline(i)
    g = copy(cgrid)
    g[line(i)] .= 'S'
    colorme(g)
end

showstep(26501365)
showline(100)

#VISUALISATION

using Colors, Images

count(==('S'),grid)


submitanswer(2,pt2)

#Benchmarking
using BenchmarkTools
@benchmark pt1 = solveit()
@benchmark pt2 = solveit2()


1
#normals = 4 x 1 even, 2 odd, 2 even, 3 odd, 3 even, 4 odd, 4 eve
#joiners = 4 x 1 even, 1 odd, 2 even, 2 odd, 3 even, 3 odd, 

1*innerodd +
4*(1*innereven,1*outereven,2*innerodd,2*outerodd)

n = moves ÷ len ÷ 2

a = n*(n+1) ÷ 2
b = (n+1)*(n+2) ÷ 2 - 1
b - a

# n*(n+1)*4 full
# n*4 + 1 odd diamonds

layers = getlayers(grid,131*6+65)
sum(length.(layers[131*2+65+1:-2:1]))


[(x,) for x in 0:2]
replicate[ioci .+ Ref(CartesianIndex(x*162,0))]
replicate[ioci + CartesianIndex(162,162)]
replicate[ioci + CartesianIndex(162,162)]

ioci = vcat(layers[2:2:66]...)
ieci = vcat(layers[1:2:65]...)
ooci = setdiff(foci,ioci)
oeci = setdiff(feci,ieci)
foci = filter(in(CartesianIndices(grid)),(vcat(layers[2:2:131]...))) 
feci = filter(in(CartesianIndices(grid)),(vcat(layers[1:2:131]...))) 

14419*4
innerodd = length(vcat(layers[2:2:66]...))
innereven = length(vcat(layers[1:2:65]...))
outerodd = sum(in(CartesianIndices(grid)).(vcat(layers[2:2:230]...))) - innerodd
outereven = sum(in(CartesianIndices(grid)).(vcat(layers[1:2:230]...))) - innereven
innerodd + innereven + outerodd + outereven
fullgrid = sum(in(CartesianIndices(grid)).(vcat(layers[1:230]...)))
fullgridodd = sum(in(CartesianIndices(grid)).(vcat(layers[2:2:230]...))) 
fullgrideven = sum(in(CartesianIndices(grid)).(vcat(layers[1:2:230]...))) 
filter(in(CartesianIndices(grid)),layers[131])
pt2(n) = (n*(n+1)÷2)*4*fullgrid + 4*n * fullgridodd + 1 * innerodd
pt2(1)

4*fullgrid + 1* fullgridodd + 4*innereven + 3*outereven

n
1*fullgridodd + 4*innerodd + 2*outerodd +
n*(n+1) * outereven
n^2 * (4*fullgrideven + 4*innerodd +  3*outerodd)

function pt2(x)
    1*fullgridodd + 4*innerodd + 2*outerodd +
        x*(x+1)÷2 * 2*outereven +
        x^2 * (4*fullgrideven + 4*innerodd +  3*outerodd)
end

pt2(1)

function pt2(x)
    1*fullgridodd + 4*innerodd + 2*outerodd +
        (x*2) * outereven +
        (x*2-1) * (4*innerodd +  3*outerodd) +
        x^2 * 4*fullgrideven +
        x*(x-1) * 4*fullgridodd
end

realsolve(n) = sum(length.(layers[131*2*n+65+1:-2:1]))
rs = realsolve.(1:3)
p2 = pt2.(1:3)
pt2(n)
clipboard(ans)
diff = rs .- p2
diff[3] ./ parts
parts = [innerodd,
innereven,
outerodd,
outereven,
innerodd,
fullgrid,
fullgridodd,
fullgrideven]



sumodds(3)
sumodds(p) = p*(p+1)

n1grid = vcat(layers[131*2+65+1:-2:2]...)
n1grid - 
len = size(grid,1)
cgrid = CircularArray(grid)
acnt = 0
repsqs = moves ÷ len ÷ 2
rep = [carr[corner + x*CartesianIndex(-1,1) + y*CartesianIndex(-1,-1)] for x in 0:len*2-1 for y in x%2:2:len*2-1]
acnt += (moves ÷ len ÷ 2)^2*count(!=('#'),cgrid[rep])

edge = moves % len
repedge = [carr[corner + x*CartesianIndex(-1,1) + y*CartesianIndex(-1,-1)] for x in 0:edge-1, y in 0:len-1]
cnt += (moves ÷ len)*count(!=('#'),cgrid[repedge])
repedge = [carr[corner + x*CartesianIndex(-1,1) + y*CartesianIndex(-1,-1)] for x in 0:len-1, y in 0:edge-1]
cnt += (moves ÷ len)*count(!=('#'),cgrid[repedge])
repedge = [carr[corner + x*CartesianIndex(-1,1) + y*CartesianIndex(-1,-1)] for x in 0:edge-1, y in 0:edge-1]
cnt += count(!=('#'),cgrid[repedge])
pt2 = cnt
clipboard(pt2)


fulldiamond = group.(0:65)