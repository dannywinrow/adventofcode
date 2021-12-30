import Base.parse
import Base.replace

function firstpair(input;depth=5)
    index = 1
    n = 0
    while (n < depth) && (index <= length(input))
        input[index] == '[' && (n += 1)
        input[index] == ']' && (n -= 1)
        index += 1
    end
    (index > length(input)) ? nothing : (index - 1):(index-1+findfirst(']',input[index:end]))
end
firstbloat(input) = findfirst(r"\d\d+",input)

function cutit(input,rng)
    [
        input[1:(rng[1]-1)]
        input[rng]
        input[(rng[end]+1):end]
    ]
end

function onestep(input;info=false)

    inrng=[]
    outrng=[]
    fp = firstpair(input)
    if !isnothing(fp)
        #explode
        s = cutit(input,fp)
        pair = eval(Meta.parse(s[2]))
        leftp = findfirst(r"\d+",reverse(s[1]))
        if isnothing(leftp)
            left = nothing
        else
            left = (length(s[1])-leftp[end]+1):(length(s[1])-leftp[1]+1)
        end
        if !isnothing(left) 
            leftnum = parse(Int,s[1][left])
            len = length(s[1])
            s[1] = replace(s[1],left,"$(leftnum+pair[1])")
            append!(inrng,[left])
            append!(outrng,[left[1]:(left[end]+length(s[1])-len)])
        end
        s[2] = "0"
        append!(inrng,[fp])
        append!(outrng,[(length(s[1])+1):(length(s[1])+1)])

        right = findfirst(r"\d+",s[3])
        if !isnothing(right) 
            rightnum = parse(Int,s[3][right])
            len = length(s[3])
            s[3] = replace(s[3],right,"$(rightnum+pair[2])")
            append!(inrng,[(fp[end]+right[1]):(fp[end]+right[end])])
            append!(outrng,[(length(s[1])+length(s[2])+right[1]):(length(s[1])+length(s[2])+right[end]+length(s[3])-len)])
        end
    else
        fb = firstbloat(input)
        if !isnothing(fb)
            s = cutit(input,fb)
            num = parse(Int,input[fb]) / 2
            inrng = [fb]
            s[2] = "[$(floor(Int,num)),$(ceil(Int,num))]"
            outrng = [fb[1]:(fb[1]+length(s[2])-1)]
        else
            return nothing
        end
    end
    outstr = join(s)
    if info
        print(stdout,"in:  ")
        printhighlightranges(stdout,input,inrng)
        print(stdout,"out: ")
        printhighlightranges(stdout,outstr,outrng)
        print(stdout,"\n")
    end 
    outstr
end

function printhighlightranges(io,str,rngs)
    index = 0
    n = 1
    colors = [:red,:blue,:green,:orange,:purple]
    for rng in rngs
        print(io,str[index+1:(rng[1]-1)])
        printstyled(io,str[rng],color=colors[n])
        index = rng[end]
        n += 1
    end
    print(io,str[index+1:end])
    print(io,"\n")
end

function Base.replace(input::String,u::UnitRange,replacement::String)
    s = cutit(input,u)
    s[2] = replacement
    join(s)
end

function process(newinput;info=false)
    input = ""
    while !isnothing(newinput)
        input = newinput
        newinput = onestep(input,info=info)
    end
    input
end

addsnail(input1,input2) = "[$input1,$input2]"

function check(str)
    m = match(r"(?<snail1>.+)\n\+ (?<snail2>.+)\n= (?<result>.+)",strip(str))
    process(addsnail(m["snail1"],m["snail2"]),info=true)
    m["result"]
end
function solveit(input)
    snails = split(input,r"\r\n|\n")
    snail = snails[1]
    for i in 2:length(snails)
        snail = process(addsnail(snail,snails[i]))
    end
    snail
end
example0 = "[1,1]
[2,2]
[3,3]
[4,4]"
example1 = "[1,1]
[2,2]
[3,3]
[4,4]
[5,5]"
example2 = "[1,1]
[2,2]
[3,3]
[4,4]
[5,5]
[6,6]"
example3 = "[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
[7,[5,[[3,8],[1,4]]]]
[[2,[2,2]],[8,[8,1]]]
[2,9]
[1,[[[9,3],9],[[9,0],[0,7]]]]
[[[5,[7,4]],7],1]
[[[[4,2],2],6],[8,7]]"
example4 = "[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]"

solveit(example0)
solveit(example1)
solveit(example2)
solveit(example3)

input = read("2021\\inputs\\input18.txt",String)

result = solveit(input)
result = replace(result,r"\[([^\[\]\,]+),([^\[\]\,]+)\]" => s"(\1*3+\2*2)")
eval(Meta.parse(result))
match(r"\[([^\[\]\,]+),([^\[\]\,]+)\]",result)
function magnitude(str)
  res = replace(str,r"\[([^\[\]\,]+),([^\[\]\,]+)\]" => s"(\1*3+\2*2)")
  while res != str
    str = res
    res = replace(str,r"\[([^\[\]\,]+),([^\[\]\,]+)\]" => s"(\1*3+\2*2)")
  end
  eval(Meta.parse(res))
end

input = read("2021\\inputs\\input18.txt",String)
input = split(input,"\r\n")
maximum([magnitude(process(addsnail(str,str2))) for str in input, str2 in input if str != str2])