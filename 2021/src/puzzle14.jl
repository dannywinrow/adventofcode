import Base.parse

struct PolymerChain
    chains
    substitutions
end

function Base.parse(PolymerChain,file)
    input = read(file,String);
    input = split(input,r"\r\n\r\n")
    chain = input[1]
    substitutions = split(input[2],r"\r\n")
    substitutions = split.(substitutions,r" -> ")
    substitutions = Dict([i[1] => i[2] for i in substitutions])
    PolymerChain([chain],substitutions)
end

function sub!(pc::PolymerChain, keep = true)
    chain = pc.chains[end]
    newchain = ""
    for n in 1:length(chain)-1
        newchain *= chain[n] * pc.substitutions[chain[n:n+1]]
    end
    newchain *= chain[end]
    keep || empty!(pc.chains)
    append!(pc.chains,[newchain])  
end
freqdict(str) = Dict([i => count(x->x==i,str) for i in str])

function part1()
    file = "2021\\inputs\\input14.txt"
    pc = parse(PolymerChain,file)
    for n in 1:10
        sub!(pc)
    end
    maximum(values(freqdict(pc.chains[end])))-minimum(values(freqdict(pc.chains[end])))
end

function part2()
    file = "2021\\inputs\\input14.txt"
    pc = parse(PolymerChain,file)
    for n in 1:40
        sub!(pc)
        @info n
    end
    maximum(values(freqdict(pc.chains[end])))-minimum(values(freqdict(pc.chains[end])))
end

@show part1()
@show part2()