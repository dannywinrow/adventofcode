using HTTP
using Dates
using JSON3

include("personal.jl")
#personal.jl is not on GitHub because it contains my sessioncookie
#you need to find sessioncookie from the browser when you log on to
#adventofcode.com


#PATHS
getfilename(year,day) = "$year/inputs/$(day).txt"
getjuliafilename(year,day) = "$year/src/$(day).jl"
puzzleurl(year,day) = "https://adventofcode.com/$year/day/$day"
getinputurl(year,day) = puzzleurl(year,day) * "/input"
getsubmiturl(year,day) = puzzleurl(year,day) * "/answer"
const templatefile = "puzzletemplate.jl"
const logfile = "log.txt"
const logdelim = " | "

# FILE HANDLING
createfile() = createfile(year(now()),day(now()))
function createfile(year,day)
    filepath = getjuliafilename(year,day)
    if !isfile(filepath)
        mkpath(dirname(filepath))
        cp(templatefile,filepath)
    end
end

# ACCESS AoC
function downloadAoCinput(year,day)
    filepath = getfilename(year,day)
    !ispath(dirname(filepath)) && mkpath(dirname(filepath))
    io = open(filepath, "w")
    url = getinputurl(year,day)
    headers = ["cookie" => "session=$sessioncookie"]
    HTTP.request("GET",url,headers,response_stream=io)
    close(io)
    logaction("$year-$day","downloaded")
end

function getanswers(year,day)
    url = puzzleurl(year,day)
    headers = ["cookie" => "session=$sessioncookie"]
    r = HTTP.request("GET",url,headers)
    em = eachmatch(r"Your puzzle answer was <code>(\d+)", String(r.body))
    isnothing(em) ? nothing : parse.(Int,x[1] for x in em)
end

function downloadAoCexample(year,day)
    url = puzzleurl(year,day)
    headers = ["cookie" => "session=$sessioncookie"]
    r = HTTP.request("GET",url,headers)
    m = match(r"<p>For example:</p>\n<pre><code>(.+?)\n</code></pre>"s, String(r.body))
    isnothing(m) ? nothing : m[1]
end

# READ INPUTS
getinput(;kwargs...) = getinput(getyearday()...;kwargs...)
function getinput(year,day;type=String)
    !isfile(getfilename(year,day)) && downloadAoCinput(year,day)
    read(getfilename(year,day),type) |> strip
end

parselines(input) = split(strip(input),"\n")
loadlines() = loadlines(getyearday()...)
function loadlines(year,day,splitbyempty = false)
    !isfile(getfilename(year,day)) && downloadAoCinput(year,day)
    lines = readlines(getfilename(year,day))
    while lines[end] == ""
        lines = lines[1:end-1]
    end
    lines
end

parsegrid(input = getinput();kwargs...) = parsegrid(split(input,"\n");kwargs...)
function loadgrid(lines = loadlines();type = Char,permute = true)
    grid = hcat(split.(lines,"")...)
    if type != Char
        grid = parse.(type,grid)
    else
        grid = getindex.(grid,1)
    end
    permute && return permutedims(grid,(2,1))
    grid
end

parsehashgrid(input = getinput()) = loadhashgrid(split(input,"\n"))
function loadhashgrid(lines = loadlines())
    @assert length(unique(length.(lines))) == 1
    (x -> x =="#").(hcat(split.(lines,"")...))'
end

function splitvect(a::Vector,delim)
    inds = vcat(0,findall(==(delim),a),length(a)+1)
    view.(Ref(a), (:).(inds[1:end-1].+1,inds[2:end].-1))
end

# Broken from 2023
submitanswer(level, answer) = submitanswer(getyearday()...,level,answer)
function submitanswer(year, day, level, answer)
    url = getsubmiturl(year,day)
    @info url, level, answer
    #headers = Dict("cookie" => "session=$sessioncookie")
    #r = HTTP.request("POST",url,headers;
    #          body=HTTP.Form(["level" => level,"answer" => answer]))
    #s = String(r.body)
    #correct = !occursin("not the right answer",s)
    logaction("$year-$day-$level","submit $answer")
    #if occursin("<article>",s)
    #    return match(r"<article><p>(.+)</p></article>"s,s)[1]
    #else
    #    return s
    #end
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

# CARTESIAN INDICES NEIGHBOURS
neighbours(ci) = Ref(ci) .+ cartesiancube(length(ci))
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

# DIRECTIONS
U = CartesianIndex(-1,0)
D = CartesianIndex(1,0)
L = CartesianIndex(0,-1)
R = CartesianIndex(0,1)

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