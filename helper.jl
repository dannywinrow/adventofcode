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

getinput() = getinput(getyearday()...)
function getinput(year,day;type=String)
    !isfile(getfilename(year,day)) && downloadAoCinput(year,day)
    read(getfilename(year,day),type)
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

function loadgrid(type = Int,lines=loadlines())
    grid = hcat(split.(lines,"")...)
    if type != Char
        grid = parse.(type,grid)
    else
        grid = getindex.(grid,1)
    end
    permutedims(grid,(2,1))
end
loadhashgrid() = parsehashgrid(loadlines())
function parsehashgrid(lines)
    @assert length(unique(length.(lines))) == 1
    (x -> x =="#").(hcat(split.(lines,"")...))'
end

submitanswer(level, answer) = submitanswer(getyearday()...,level,answer)
function submitanswer(year, day, level, answer)
    url = getsubmiturl(year,day)
    @info url, level, answer
    headers = Dict("cookie" => "session=$sessioncookie")
    r = HTTP.request("POST",url,headers,"level=$level&answer=$answer")
    s = String(r.body)
    correct = !occursin("not the right answer",s)
    logaction("$year-$day-$level","submit $answer, $correct")
    if occursin("<article>",s)
        return match(r"<article><p>(.+)</p></article>"s,s)[1]
    else
        return s
    end
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

function downloadAoCinput(year,day)
    ###############NEED ERROR HANDLING
    io = open(getfilename(year,day), "w")
    url = getinputurl(year,day)
    headers = ["cookie" => "session=$sessioncookie"]
    HTTP.request("GET",url,headers,response_stream=io)
    close(io)
    logaction("$year-$day","downloaded")
end

function splitvect(a::Vector,delim)
    inds = vcat(0,findall(==(delim),a),length(a)+1)
    view.(Ref(a), (:).(inds[1:end-1].+1,inds[2:end].-1))
end

freqdict(str) = Dict([i => count(x->x==i,str) for i in str])

createfile() = createfile(year(now()),day(now()))
function createfile(year,day)
    !isfile(getjuliafilename(year,day)) && cp(templatefile,getjuliafilename(year,day))
end


neighbours(ci) = Ref(ci) .+ cartesiancube(length(ci))
function cartesiancube(dims,i=false)
    ret = CartesianIndices(Tuple(fill(-1:1,dims)))
    i || filter!(x->x!=CartesianIndex(Tuple(fill(0,dims))),ret)
    ret
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

#puzzledictionary = loadlog()


using CircularArrays

function Base.insert!(a::CircularVector, i::Integer, item)
    insert!(a.data,linearindex(a,i),item)
    return a
end
function Base.deleteat!(a::CircularVector, i::Integer)
    deleteat!(a.data,linearindex(a,i))
    return a
end
function Base.deleteat!(a::CircularVector, inds)
    deleteat!(a.data, sort!(unique(linearindices(a,inds))))
    a
end

linearindices(a::CircularVector,inds) = map(i -> linearindex(a,i), inds)
linearindices(a::CircularVector,i::Integer) = linearindex(a,i)
linearindex(a::CircularVector,i::Integer) = mod(i, eachindex(IndexLinear(), a.data))
function standardrange(a::CircularVector,r::AbstractUnitRange{<:Integer})
    f = mod(first(r), eachindex(IndexLinear(), a.data))
    l = f + length(r) - 1
    f:l
end
function splitrange(a::CircularVector,r::AbstractUnitRange{<:Integer})
    first(r) > last(r) && return [r]
    f = mod(first(r), eachindex(IndexLinear(), a.data))
    if length(r) > length(a.data)
        l = mod(first(r)-1, eachindex(IndexLinear(), a.data))
    else
        l = mod(last(r), eachindex(IndexLinear(), a.data))
    end
    if f > l
        [f:length(a.data), 1:l]
    else
        [f:l]
    end
end
function shift!(a::CircularVector, i::Integer, steps)
    item = a[i]
    ind = mod(i, eachindex(IndexLinear(), a.data))
    deleteat!(a.data,ind)
    newind = linearindex(a,i+steps)
    insert!(a.data,newind,item)
    newind
end

function shiftmove!(a::CircularVector, i::Integer, steps)
    #this is slower than shiftdel for some reason
    steps = mod(steps,1:length(a)-1)
    item = a[i]
    a[i:i+steps-1] = a[i+1:i+steps]
    a[i+steps] = item
    a
end

function shift!(a::CircularVector, inds, steps)
    items = a[inds]
    ind = sort!(unique(map(i -> mod(i, eachindex(IndexLinear(), a.data)), inds)))
    deleteat!(a.data,ind)
    newind = mod(i+steps, eachindex(IndexLinear(), a.data))
    insert!(a.data,newind,item)
    newind
end

Base.splice!(a::CircularVector, i::Integer, ins=Base._default_splice) = splice!(a.data,linearindex(a,i),ins)
Base.splice!(a::CircularVector, inds) = (dltds = eltype(a.data)[]; _deleteat!(a.data, sort!(unique(linearindices(inds,i))), dltds); dltds)

function Base.splice!(a::CircularVector, r::AbstractUnitRange{<:Integer}, ins=Base._default_splice)
    v = a[r]
    m = length(ins)
    if m == 0
        deleteat!(a, r)
        return v
    end

    rn = splitrange(a,r)

    if length(rn) == 2
        inslen = min(length(rn[1]),length(ins))
        v = splice!(a.data,rn[1],ins[1:inslen])
        w = splice!(a.data,rn[2],ins[inslen+1:end])
        return vcat(v,w)
    else
        return splice!(a.data,r,ins)
    end

end