import Base.show
import Base.parse

function getinput(file)
    input = read(file,String)
    input = split(input,"\r\n")
end


syntax = ['(' ')' 3
'[' ']' 57
'{' '}' 1197
'<' '>' 25137]

function syntaxcheck(str)
    check = []
    buff = [i for i in str]
    while length(buff) > 0
        ch = popfirst!(buff)
        if ch in syntax[:,2]
            if (length(check) > 0)
                ch1 = (pop!(check))
                if ch != ch1
                    return syntax[findfirst(x->x==ch,syntax[:,2]),3]
                end
            end
        else
            i = findfirst(x->x==ch,syntax[:,1])
            if !isnothing(i)
                push!(check,syntax[i,2])
            else
                return -1
            end
        end
    end
    return 0
end

function autocomplete(str)
    check = []
    buff = [i for i in str]
    while length(buff) > 0
        ch = popfirst!(buff)
        if ch in syntax[:,2]
            if (length(check) > 0)
                ch1 = (pop!(check))
                if ch != ch1
                    return 0
                end
            end
        else
            i = findfirst(x->x==ch,syntax[:,1])
            if !isnothing(i)
                push!(check,syntax[i,2])
            else
                return -1
            end
        end
    end
    score = 0
    for ch in reverse(check)
        i = findfirst(x->x==ch,syntax[:,2])
        score = score * 5 + i
    end
    return score
end

function part1test()
    input = getinput("2021\\inputs\\input10test.txt")
    sum(syntaxcheck.(input))
end

function part1()
    input = getinput("2021\\inputs\\input10test.txt")
    sum(syntaxcheck.(input))
end

function part2test()
    input = getinput("2021\\inputs\\input10test.txt")
    autocomplete.(input)
end

function part2()
    input = getinput("2021\\inputs\\input10.txt")
    outs = sort(filter(x->x>0,autocomplete.(input)))
    outs[ceil(Int,length(outs) / 2)]
end

#@show part1();
@show part2();

ground = parse(Ground,input)

     
for ci in CartesianIndices(t)
    @show ci
end
for ci in CartesianIndices(t')
    @show ci
end