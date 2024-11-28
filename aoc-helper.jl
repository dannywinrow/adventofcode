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

getinput(;kwargs...) = getinput(getyearday()...;kwargs...)
function getinput(year,day;type=String)
    !isfile(getfilename(year,day)) && downloadAoCinput(year,day)
    read(getfilename(year,day),type) |> strip
end
