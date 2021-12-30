using FreqTables
import Base.parse
import Base.show
import Base.iterate

input = read("2021\\inputs\\input8.txt",String);
input = split(input,"\r\n")
input = split.(input," | ")

inputs = split.(getindex.(input,1)," ")
outputs = split.(getindex.(input,2)," ")
ident = ["abcefg","cf","acdeg","acdfg","bcdf","abdfg","abdefg","acf","abcdefg","abcdfg"]


bittranslate(sigset) = reshape([ch in i for ch in 'a':'g' for i in sigset],10,7)
identityset = bittranslate(ident)

struct FullSignal
    signals
    bitmatrix
    numbers
    chars
    FullSignal(input) = new(input,bittranslate(input),1:10,'a':'g')
end


sumcols(x::FullSignal) = [sum(i) for i in eachcol(x.bitmatrix)]
sumrows(x::FullSignal) = [sum(i) for i in eachrow(x.bitmatrix)]

identsig = FullSignal(ident)

identcols = sumcols(identsig)
identcolsunq = names(filter(x->x==1,freqtable(identcols)))[1]
identpos = [findfirst(x->x==i,identcols) for i in identcolsunq]
letters = [string(i) for i in 'a':'g']
digitmap = Dict(ident .=> [i for i in 0:9])

function solve(screwin,screwout)
    screwsig = FullSignal(screwin)
    screwcols = sumcols(screwsig)
    screwpos = [findfirst(x->x==i,screwcols) for i in identcolsunq]
    charmap = letters[screwpos] .=> letters[identpos]
    identrows = sumrows(identsig)
    identrowsunq = names(filter(x->x==1,freqtable(identrows)))[1]
    identrowspos = [findfirst(x->x==i,identrows) for i in identrowsunq]
    screwrows = sumrows(screwsig)
    screwrowspos = [findfirst(x->x==i,screwrows) for i in identrowsunq]
    screwsig.signals[screwrowspos] .=> identsig.signals[identrowspos]
    signalmap = screwsig.signals[screwrowspos] .=> identsig.signals[identrowspos]
    for j in 1:3
        for (i,n) in enumerate(signalmap)
            for ch in charmap
                n = replace(n[1],ch[1]=>"") => replace(n[2],ch[2]=>"")
            end
            signalmap[i] = n
            if length(signalmap[i][1]) == 1
                push!(charmap,signalmap[i])
                deleteat!(signalmap,i)
            end
        end
    end
    strsort(str) = join(sort(collect(str)))
    organised = strsort.(replace.(screwout,r"[a-g]" => s -> Dict(charmap)[s]))
    parse(Int,join([(digitmap[i]) for i in organised]))
end

function part1()

end

function part2()
    sum(solve.(inputs,outputs))
end

@show part1()
@show part2()