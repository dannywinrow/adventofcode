include("../../helper.jl")

function points(card)
    winnums, yournums = split(split(card,": ")[2]," | ")
    winnums = parse.(Int,split(replace(strip(winnums),"  "=>" ")," "))
    yournums = parse.(Int,split(replace(strip(yournums),"  "=>" ")," "))
    wincnt = length(intersect(winnums,yournums))
    wincnt == 0 && return 0
    2 ^ (wincnt-1)
end

function solveit()
    lines = loadlines()
    sum(points.(lines))
end

pt1 = solveit()

function wins(card)
    winnums, yournums = split(split(card,": ")[2]," | ")
    winnums = parse.(Int,split(replace(strip(winnums),"  "=>" ")," "))
    yournums = parse.(Int,split(replace(strip(yournums),"  "=>" ")," "))
    wincnt = length(intersect(winnums,yournums))
    wincnt == 0 && return 0
    wincnt
end

function solveit2()
    lines = loadlines()
    cards = fill(1,length(lines))
    for (i,line) in enumerate(lines)
        cards[i+1:i+wins(line)] .+= cards[i]
    end
    sum(cards)
end

pt2 = solveit2()

println("Part 1: $pt1")
println("Part 2: $pt2")