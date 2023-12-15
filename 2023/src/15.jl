include("../../helper.jl")

example = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"
#instr = split(example,",")

function parseinput(line = loadlines()[1])
    split(line,",")
end

asciiadd(x,c) = ((x + Int(c)) * 17) % 256

function hash(s)
    x = 0
    for c in s
        x = asciiadd(x,c)
    end
    x
end
pt1 = sum(hash.(parseinput()))

function runreg(instr = parseinput())
    register = [[] for _ in 1:256]
    for i in instr
        m = match(r"(\w+)([=-])(\d*)",i)
        word,op,len = m.captures
        updateregister!(register,word,op[1],op == "=" ? parse(Int,len) : nothing)
    end
    register
end

function updateregister!(register,word,op,len)
    #@info word,op,len
    n = hash(word)+1
    if op == '-'
        filter!(x->x[1]!=word,register[n])
    else
        m = findfirst(x->x[1]==word,register[n])
        isnothing(m) ? push!(register[n],(word,len)) : register[n][m] = (word,len)
    end
    #@info filter(!isempty,register)
end

function val(register)
    cnt = 0
    for i in eachindex(register)
        for j in eachindex(register[i])
            cnt += i * j * register[i][j][2]
        end
    end
    cnt
end

pt2 = val(runreg())

println("Part 1: $pt1")
println("Part 2: $pt2")