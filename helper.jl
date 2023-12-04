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

#

createfile() = createfile(year(now()),day(now()))
function createfile(year,day)
    filepath = getjuliafilename(year,day)
    if !isfile(filepath)
        mkpath(dirname(filepath))
        cp(templatefile,filepath)
    end
end

getinput() = getinput(getyearday()...)
function getinput(year,day;type=String)
    !isfile(getfilename(year,day)) && downloadAoCinput(year,day)
    read(getfilename(year,day),type)
end

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

loadlines(splitbyempty=false) = loadlines(getyearday()...,splitbyempty)
function loadlines(year,day,splitbyempty = false)
    !isfile(getfilename(year,day)) && downloadAoCinput(year,day)
    lines = readlines(getfilename(year,day))
    while lines[end] == ""
        lines = lines[1:end-1]
    end
    if splitbyempty
        lines = splitvect(lines,"")
    end
    lines
end

function loadgrid(type = Int,lines=loadlines();permute = true)
    grid = hcat(split.(lines,"")...)
    if type != Char
        grid = parse.(type,grid)
    else
        grid = getindex.(grid,1)
    end
    permute && return permutedims(grid,(2,1))
    grid
end
loadhashgrid() = parsehashgrid(loadlines())
function parsehashgrid(lines)
    @assert length(unique(length.(lines))) == 1
    (x -> x =="#").(hcat(split.(lines,"")...))'
end

# Broken from 2023
submitanswer(level, answer) = submitanswer(getyearday()...,level,answer)
function submitanswer(year, day, level, answer)
    url = getsubmiturl(year,day)
    @info url, level, answer
    #headers = Dict("cookie" => "session=$sessioncookie")
    #r = HTTP.request("POST",url,headers,body="level=$level&answer=$answer")
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

function splitvect(a::Vector,delim)
    inds = vcat(0,findall(==(delim),a),length(a)+1)
    view.(Ref(a), (:).(inds[1:end-1].+1,inds[2:end].-1))
end

freqdict(str) = Dict([i => count(x->x==i,str) for i in str])

neighbours(ci) = Ref(ci) .+ cartesiancube(length(ci))
function cartesiancube(dims,i=false)
    ret = CartesianIndices(Tuple(fill(-1:1,dims)))
    i || (ret = filter(x->x!=CartesianIndex(Tuple(fill(0,dims))),ret))
    ret
end