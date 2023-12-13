include("../../helper.jl")

# divide and conquer
# turns out this is super slow see ../alt/12 copy jonathon paulson.jl for fast version

import Base.repeat
import Base.parse
import Base.show

struct Line
    cond
    contig
end
function Base.parse(::Type{Line},str::AbstractString)
    cond,contig = split(str," ")
    contig = [parse(Int,x) for x in split(contig,",")]
    Line(cond,contig)
end
function Base.repeat(line::Line,i::Int64)
    Line(repeat(line.cond*"?",i)[1:end-1],repeat(line.contig,i))
end
function Base.show(io::IO, line::Line)
    println(io,line.cond)
    print(io,line.contig)
end
Base.show(io::IO, ::MIME"text/plain", line::Line) = print(io, "Line:\n", line)

function solve(line::Line)
    parts = [x.match for x in eachmatch(r"[^.]+",line.cond)]
    _solveparts(parts,line.contig)
end

_solveparts(part::AbstractString,contig) = _solveparts([part],contig)
function _solveparts(parts,contig)
    isempty(parts) && return isempty(contig)
    isempty(contig) && return !in('#',join(parts))
    
    part = parts[1]
    length(parts) == 1 && return _solvepart(part,contig)

    len = length(part)
    maxcontigs = 0
    minlen = 0
    for i in eachindex(contig)
        minlen += contig[i]
        len < minlen ? break : (maxcontigs += 1)
    end

    cnt = 0
    for i in 0:maxcontigs
        if (p = _solveparts([part],contig[1:i])) > 0
            cnt += p * _solveparts(parts[2:end],contig[i+1:end])
        end
    end
    cnt
end


_solvepart(part::Char,contig) = _solvepart(string(part),contig)
function _solvepart(part,contig)
    length(part) < mincondlen(contig) && return 0
    
    if (hash = findfirst(r"#+",part)) === nothing
        return combos(length(part),contig)
    else
        cnt = 0
        for i in eachindex(contig)
            pos = max(1,hash[end]-contig[i]+1):min(length(part)-contig[i]+1,hash[1])
            for x in pos
                next = x + contig[i]
                if next > length(part) || part[next] != '#'
                    if (p = _solvepart(part[1:x-2],contig[1:i-1])) > 0
                        cnt += p * _solvepart(part[next+1:end],contig[i+1:end])
                    end
                end
            end
        end
        return cnt
    end
end
mincondlen(contig) = sum(contig) + length(contig) - 1

function combos(len,contig)
    mpartitions(len-mincondlen(contig),length(contig)+1)
end

let _nipartitions = Dict{Tuple{Int,Int},Int}()
    global mpartitions
    function mpartitions(n::Int, m::Int)
        if n == 0 || m == 1
            1
        elseif (np = get(_nipartitions, (n,m), 0)) > 0
            np
        else
            _nipartitions[(n, m)] = 1 + sum(mpartitions.(1:n, m-1))
        end
    end
end

lines = parse.(Line,loadlines())
pt1 = sum(solve.(lines))
pt2 = sum(solve.(repeat.(lines,5)))

println("Part 1: $pt1")
println("Part 2: $pt2")