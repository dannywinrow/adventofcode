using CSV, DataFrames

input = read("2020\\inputs\\input7.txt",String);
input = split(input,"\r\n")
m = match.(r"(?<outer>[a-z]* [a-z]*) bag.* contain (?<inner>.*)\.",input)
outerbags = [m[:outer] for m in m]
innerms = [m[:inner] for m in m]
innermatches = collect.(eachmatch.(r"(\d*) *([a-z]* [a-z]*) bag",innerms))
innerbags = [[i[2] for i in j] for j in innermatches] 
innerbagcount = [[i[1]=="" ? 0 : parse(Int,i[1]) for i in j] for j in innermatches] 

bagsin(bag) = outerbags[[in(bag,x) for x in innerbags]]

function bagsinrec(bag)
    b = bagsin(bag)
    i = 1
    while i <= length(b)
        b = unique(vcat(b,bagsin(b[i])))
        i += 1
    end
    b
end

function bagscontained(bag)
    cnt = 0
    @info bag
    for innerbag in zip(innerbags[outerbags .== bag][1],innerbagcount[outerbags .== bag][1])
        if innerbag[2] > 0
            cnt += innerbag[2] * (1 + bagscontained(innerbag[1]))      
        end
    end
    cnt
end

function part1()
    length(bagsinrec("shiny gold"))
end

function part2()    
    bagscontained("shiny gold")
end

@show part1()
@show part2()
