include("../../helper.jl")

function parseline(line)
    cond, contig = split(line," ")
    cond = [x for x in cond]
    contig = [parse(Int,x) for x in split(contig,",")]
    cond,contig
end
function isitvalid(cond,template)
    length(cond) != length(template) && return false
    for (c,d) in zip(cond,template)
        d != '?' && d != c && return false
    end
    true
end
# Generate all arrays of m integers that sum to n (including 0)
function perms(n,m)
    if n == 0
        return [fill(0,m)]
    elseif m == 1
        return [[n]]
    else
        p = []
        for x in 0:n
            for v in perms(n-x,m-1)
                push!(p,[x,v...])
            end
        end
        return p
    end
end

function brutesolve(cond,contig)
    sum(isitvalid.(possconds(contig,length(cond)),Ref(cond)))
end



function possconds(contig,len)
    conds = []
    midlen = length(contig)+1
    adj = [0,fill(1,midlen-2)...,0]
    for comb in perms(len-sum(contig)-midlen+2,midlen) .+ Ref(adj)
        cond = []
        for (i,x) in enumerate(comb)
            append!(cond,fill('.',x))
            i <= length(contig) && append!(cond,fill('#',contig[i])) 
        end
        push!(conds,cond)
    end
    conds
end



function calccontig(cond)
    cnt = 0
    contig = []
    for c in cond
        c == '#' && (cnt+=1)
        c == '.' && cnt>0 && (push!(contig,cnt);cnt=0)
    end
end

function solveit()
    lines = loadlines()
    cnt = 0
    answers = []
    for line in lines
        j = sum(brutesolve(parseline(line)...))
        @info line, j
        push!(answers,j)
        cnt += j
    end
    cnt, answers
end

pt1,answers = solveit()


function brutesolve2(cond,contig)
    conds = possconds(contig,length(cond))
    conds = conds[isvalid.(conds,Ref(cond))]
    allcnt = length(conds)
    bb = blankblank = count(x->x[1] == '.' && x[end] == '.',conds)
    ff = fullfull = count(x->x[1] == '#' && x[end] == '#',conds)
    fb = fullblank = count(x->x[1] == '#' && x[end] == '.',conds)
    bf = blankfull = count(x->x[1] == '.' && x[end] == '#',conds)
    for _ in 2:5
        bb,ff,fb,bf = jointhem(bb,ff,fb,bf)
    end
    bb+ff+fb+bf
end
function jointhem(bb,ff,fb,bf)
    bb*(bb+fb) + bf*bb,
    ff*bf + fb,
    fb*bb + fb*fb,
    bf*bf + bb*bf
end

function solveit2()
    lines = loadlines()
    cnt = 0
    for line in lines
        @info cond,contig = parseline(line)
        cond = vcat(fill(cond,5)...)
        contig = vcat(fill(contig,5)...)
        cnt += sum(brutesolve(cond,contig))
    end
    cnt
end

pt2 = solveit2()