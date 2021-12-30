import Base.parse

struct PolymerPairs
    substitutions
    pairs
    firstchar
    lastchar
end

function Base.parse(PolymerPairs,file)
    input = read(file,String);
    input = split(input,r"\r\n\r\n")
    chain = input[1]
    substitutions = split(input[2],r"\r\n")
    substitutions = split.(substitutions,r" -> ")
    substitutions = Dict([i[1] => [i[1][1]*i[2],i[2]*i[1][2]] for i in substitutions])
    pairsarr = []
    for n in 1:length(chain)-1
        append!(pairsarr,chain[n:n+1])
    end
    pairs = Dict([i => length(collect(eachmatch(r""*i, chain))) for i in keys(substitutions)])
    PolymerPairs(substitutions,pairs,chain[1],chain[end])
end

function sub!(pp::PolymerPairs, keep = true)
    newpairs = Dict([pair => 0 for pair in keys(pp.pairs)])
    for pair in keys(pp.pairs)
        newpairs[pp.substitutions[pair][1]] += pp.pairs[pair]
        newpairs[pp.substitutions[pair][2]] += pp.pairs[pair] 
    end
    for pair in keys(pp.pairs)
        pp.pairs[pair] = newpairs[pair] 
    end
end

freqdict(str) = Dict([i => count(x->x==i,str) for i in str])
function freqdict(pp::PolymerPairs)
    chars = unique(join(keys(pp.pairs)))
    charpairs = []
    for i in chars
        n = 0
        for pair in keys(pp.pairs)
            n += pp.pairs[pair] * count(x->x==i,pair)
        end
        append!(charpairs,[i=>n])
    end
    charpairs = Dict(charpairs)
    charpairs[pp.firstchar] += 1
    charpairs[pp.lastchar] += 1
    for ch in keys(charpairs)
        charpairs[ch] = floor(Int,charpairs[ch] / 2)
    end
    charpairs
end


function part1()
    file = "2021\\inputs\\input14test.txt"
    pp = parse(PolymerPairs,file)
    for n in 1:10
        sub!(pp)
    end
    maximum(values(freqdict(pp)))-minimum(values(freqdict(pp)))
end

function part2()
    file = "2021\\inputs\\input14.txt"
    pp = parse(PolymerPairs,file)
    for n in 1:40
        sub!(pp)
    end
    maximum(values(freqdict(pp)))-minimum(values(freqdict(pp)))
end

@show part1();
@show part2();