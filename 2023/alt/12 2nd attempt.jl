include("../../helper.jl")

function parseline(line)
    cond, contig = split(line," ")
    cond = [x for x in cond]
    contig = [parse(Int,x) for x in split(contig,",")]
    cond,contig
end

mincondlen(contig) = sum(contig) + length(contig) - 1
function mincond(contig)
    cond = []
    for x in contig[1:end-1]
        cond = [cond...,fill('#',x)...,'.']
    end
    cond = [cond...,fill('#',contig[end])...]
end
function isitvalid(cond,template)
    length(cond) != length(template) && return false
    for (c,d) in zip(cond,template)
        d != '?' && d != c && return false
    end
    true
end
function reducecontig(contig)
    contig[1] == 1 && return contig[2:end]
    return [contig[1]-1,contig[2:end]...]
end
function solve(cond,contig)
    i = findfirst(!=('.'),cond)
    isnothing(i) && return isempty(contig)
    cond = cond[i:end]
    length(cond) < mincondlen(contig) && return 0
    length(cond) == mincondlen(contig) && return isitvalid(mincond(contig),cond)
    isempty(contig) && return isitvalid(fill('.',length(cond)), cond)

    if cond[1] == '?'
        return solve(['#',cond[2:end]...],copy(contig)) + solve(['.',cond[2:end]...],copy(contig))
    elseif cond[1] == '#'
        g = popfirst!(contig)
        !isitvalid([fill('#',g)...,'.'],cond[1:g+1]) && return 0
        return solve(cond[g+2:end],contig)
    else
        return solve(cond[2:end],contig)
    end
end

function solveit(lines = loadlines())
    cnt = 0
    answers = []
    for line in lines
        j = solve(parseline(line)...)*1
        push!(answers,j)
        #@info j, line
        cnt += j
    end
    cnt, answers
end

pt1, a1 = solveit()

function solveit2(lines = loadlines())
    answers = []
    for line in lines
        @info cond,contig = parseline(line)
        cond = vcat(fill(cond,5)...)
        contig = vcat(fill(contig,5)...)
        j = solve(cond,contig)*1
        @info j
        push!(answers,j)
    end
    sum(answers)
end

pt2, a2 = solveit2()