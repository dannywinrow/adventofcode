include("aoc-helper.jl")

# READ INPUTS

parselines(input) = split(strip(input),r"\r?\n")
loadlines(;part=1,problem="p") = loadlines(getyearday()...,part,problem)
function loadlines(year,day,part=1,problem="p")
    fn = getfilename(year,day,part,problem)
    !isfile(fn) && downloadAoCinput(year,day)
    loadlines(fn)
end
function loadlines(filename::String)
    lines = readlines(filename)
    while lines[end] == ""
        lines = lines[1:end-1]
    end
    lines
end

loadgrid(filename::String;type=Char,delim="") = parsegrid(loadlines(filename);type=type,delim=delim)
loadgrid(;part=1,problem="p",type=Char,delim="") = parsegrid(loadlines(;part=part,problem=problem);type=type,delim=delim)
function  parsegrid(linesin;type = Char,permute = true,delim="")
    maxline = maximum(length.(linesin))
    lines = rpad.(linesin,maxline," ")
    grid = hcat(split.(lines,delim)...)
    if type != Char
        grid = parse.(type,grid)
    else
        grid = getindex.(grid,1)
    end
    permute && return permutedims(grid,(2,1))
    grid
end

loadhashgrid(filename::String) =loadhashgrid(loadlines(filename))
loadhashgrid(;part=1,problem="p",kwargs...) = parsehashgrid(loadlines(;part=part,problem=problem);kwargs...)
function parsehashgrid(lines;truechar="#")
    @assert length(unique(length.(lines))) == 1
    (x -> x ==truechar).(hcat(split.(lines,"")...))'
end

function splitvect(a::Vector,delim)
    inds = vcat(0,findall(==(delim),a),length(a)+1)
    view.(Ref(a), (:).(inds[1:end-1].+1,inds[2:end].-1))
end

function getyearday()
    st = stacktrace()
    i = 1
    while occursin(r"helper.jl$",String(st[i].file))
        i += 1
    end
    year = match(r"\d\d\d\d",String(st[i].file)).match
    day = match(r"(\d+)[^\\]*.jl",String(st[i].file)).captures[1]
    year,day
end

function logaction(p,m)
    io = open(logfile, "a")
    write(io,join(["$(now())",p,m*"\n"],logdelim))
    close(io)
end

function loadlog()
    for (t,p,m) in split.(readlines(logfile)," | ")
        tp = parse(DateTime,t)
        split(p,"-")
        puzzledictionary[puzzle] = Dict(:submissions)
    end
end

# Frequency Dictionary
freqdict(str) = Dict([i => count(x->x==i,str) for i in str])

# DIRECTIONS
U = CartesianIndex(-1,0)
D = CartesianIndex(1,0)
L = CartesianIndex(0,-1)
R = CartesianIndex(0,1)

using CircularArrays
directions = CircularArray([R,D,L,U])
arrows = CircularArray(['>','v','<','^'])

# CARTESIAN INDICES NEIGHBOURS
neighbours(ci) = Ref(ci) .+ cartesiancube(length(ci))
adjacents(ci) = Ref(ci) .+ directions

function cartesiancube(dims,i=false)
    ret = CartesianIndices(Tuple(fill(-1:1,dims)))
    i || (ret = filter(x->x!=CartesianIndex(Tuple(fill(0,dims))),ret))
    ret
end

# CARTESIAN INDICES ROTATION
import Base.rotr90, Base.rot180
Base.rotr90(ci::CartesianIndex{2}) = CartesianIndex(ci[2],-ci[1])
Base.rotl90(ci::CartesianIndex{2}) = CartesianIndex(-ci[2],ci[1])
Base.rot180(ci::CartesianIndex{2}) = CartesianIndex(-ci[1],-ci[2])


# UNIT RANGE SIMPLIFICATION
function simplify(a::Int64,b::Int64)
    a == b && return a\
    a == b + 1 && return b:a
    a + 1 == b && return a:b
    nothing
end
simplify(a::Int64,b::UnitRange) = simplify(b,a)
function simplify(a::UnitRange,b::Int64)
    b in a && return a
    a[1] == b + 1 && return b:a[2]
    a[end] == b - 1 && return a[1]:b
    nothing
end
function simplify(a::UnitRange,b::UnitRange)
    ret = min(a[1],b[1]):max(a[end],b[end])
    length(ret) <= length(a) + length(b) ? ret : nothing
end
function simplify(a::UnitRange,b::UnitRange)
    ret = min(a[1],b[1]):max(a[end],b[end])
    length(ret) <= length(a) + length(b) ? ret : nothing
end

function simplify(v)
    ranges = Any[v...]
    outranges=[]
    while !isempty(ranges)
        range = popfirst!(ranges)
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