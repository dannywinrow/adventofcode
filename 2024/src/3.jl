include("../../helper.jl")

function solveit()
    lines = loadlines()
    em = eachmatch(r"mul\((\d+),(\d+)\)"s,join(lines))
    list1 = parse.(Int,getindex.(collect(em),1))
    list2 = parse.(Int,getindex.(collect(em),2))
    sum(list1 .* list2)
    list1,list2
end

pt1 = solveit()

write("test.csv",join(["$(x[1]),$(x[2])" for x in zip(pt1...)],"\n"))

clipboard(pt1)
submitanswer(1,pt1)

function solveit2()
    lines = loadlines()
    function multthem(lines)
        em = eachmatch(r"mul\((\d+),(\d+)\)"s,join(lines))
        list1 = parse.(Int,getindex.(collect(em),1))
        list2 = parse.(Int,getindex.(collect(em),2))
        sum(list1 .* list2)
    end
    em = eachmatch(r"(?:do\(\)|^)(.+?)(?:don't\(\)|$)"s,join(lines))
    
    multthem(join(getindex.(collect(em),1)))
end

# Wrote the above but typed `multthem(lines)` so was returning an answer based on the input
# instead of on the matches!  Ended up spending another 10 minutes writing the below to 
# solve, before debugging the above.

function solveit2alternative()
    lines = loadlines()
    line = join(lines)
    on = true
    tot = 0
    for i in eachindex(line)
        if startswith(line[i:end],"do()")
            on = true
        elseif startswith(line[i:end],"don't()")
            on = false
        elseif on
            m = match(r"^mul\((\d+),(\d+)\)",line[i:end])
            if !isnothing(m)
                tot += parse(Int,m[1])*parse(Int,m[2])
            end
        end
    end
    tot
end

pt2 = solveit2()
clipboard(pt2)
submitanswer(2,pt2)



#### Clean for Reddit


    input = read("2024/inputs/3p1.txt",String)

    function multandsum(input)
        em = eachmatch(r"mul\((\d+),(\d+)\)"s,input)
        sum(*(parse.(Int,x)...) for x in em)
    end

    pt1answer = multandsum(input)

    validem = eachmatch(
        r"(?:do\(\)|^)(.+?)(?:don't\(\)|$)"s,
        input
    );
        
    pt2answer = sum(multandsum(x[1]) for x in validem)
