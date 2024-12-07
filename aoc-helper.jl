using HTTP
using Dates
using JSON3

include("personal.jl")
#personal.jl is not on GitHub because it contains my sessioncookie
#you need to find sessioncookie from the browser when you log on to
#adventofcode.com
#create file "personal.jl" with line `sessioncookie="Your session cookie here"`

#PATHS
getfilename() = getfilename(getyearday()...)
getfilename(year::AbstractString,day,part=1,problem="p") = getfilename(parse(Int,year),day,part,problem)
getfilename(year,day,part=1,problem="p") = "$year/inputs/$(day)" * (year >= 2024 ? "$(problem)$(part)" : "") * ".txt"

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

    if !(@isdefined sessioncookie)
        @warn """You need to set a global variable `sessioncookie` with your AoC session
                    cookie if you want to automate downloading inputs"""
        return nothing
    end

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
    
    if !(@isdefined sessioncookie)
        @warn """You need to set a global variable `sessioncookie` with your AoC session
                    cookie if you want to automate getting the answers you gave"""
        return nothing
    end

    headers = ["cookie" => "session=$sessioncookie"]
    r = HTTP.request("GET",url,headers)
    em = eachmatch(r"Your puzzle answer was <code>(\d+)", String(r.body))
    isnothing(em) ? nothing : parse.(Int,x[1] for x in em)
end

function downloadAoCexample(year,day)
    url = puzzleurl(year,day)
    if !(@isdefined sessioncookie)
        @warn """You need to set a global variable `sessioncookie` with your AoC session
                    cookie if you want to automate downloading the example"""
        return nothing
    end
    headers = ["cookie" => "session=$sessioncookie"]
    r = HTTP.request("GET",url,headers)
    m = match(r"<p>For example:</p>\n<pre><code>(.+?)\n</code></pre>"s, String(r.body))
    isnothing(m) ? nothing : m[1]
end

getinput(;kwargs...) = getinput(getyearday()...;kwargs...)
function getinput(year,day;type=String)
    !isfile(getfilename(year,day)) && downloadAoCinput(year,day)
    read(getfilename(year,day),type) |> strip
end

submitanswer(level, answer) = submitanswer(getyearday()...,level,answer)
function submitanswer(year, day, level, answer)
    url = getsubmiturl(year,day)
    @info url, level, answer

    if !(@isdefined sessioncookie)
        @warn """You need to set a global variable `sessioncookie` with your AoC session
                    cookie if you want to automate answer submission"""
        return nothing
    end

    headers = ["cookie" => "session=$sessioncookie"]
    
    body = Dict("level" => level,"answer" => answer)
    r = HTTP.request("POST",url,headers,body)

    s = String(r.body)
    correct = !occursin("not the right answer",s)
    logaction("$year-$day-$level","submit,$answer,$correct")
    if occursin("<article>",s)
        return match(r"<article><p>(.+)</p></article>"s,s)[1]
    else
        return s
    end
end