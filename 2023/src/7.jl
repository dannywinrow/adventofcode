include("../../helper.jl")

ranks = "123456789TJQKA"
jokerranks = "J23456789TQKA"

struct Hand
    hand
    bid
end

toranks(hand::Hand,ranks=ranks) = [findfirst(x,ranks) for x in hand.hand]
isless(hand1::Hand,hand2::Hand) = handtype(hand1) == handtype(hand2) ? toranks(hand1) < toranks(hand2) : handtype(hand1) < handtype(hand2)
islessjokers(hand1::Hand,hand2::Hand) = handtype(hand1,true) == handtype(hand2,true) ? toranks(hand1,jokerranks) < toranks(hand2,jokerranks) : handtype(hand1,true) < handtype(hand2,true)

function sortedranks(hand::Hand)
    fd = freqdict(toranks(hand))
    s = Int[]
    for r in 5:-1:1
        cardranks = sort(collect(keys(filter(x->x[2] == r,fd))),rev=true)
        for card in cardranks, _ in 1:r
            push!(s,card)
        end
    end
    s
end

handtype(hand::Hand,jokers=false) = handtype(hand.hand,jokers)
function handtype(hand,jokers=false)
    fd = freqdict(hand)
    if jokers && haskey(fd,'J') && fd['J'] < 5
        j = fd['J']
        delete!(fd,'J')
        fd[argmax(fd)] += j
    end
    if length(values(fd)) == 1 return 7
    elseif length(values(fd)) == 2
        return maximum(values(fd)) == 4 ? 6 : 5
    elseif length(values(fd)) == 3
        return maximum(values(fd)) == 3 ? 4 : 3
    else
        return 6-length(values(fd))
    end
end
bid(hand::Hand) = hand.bid

function solveit()
    lines = loadlines()
    hands = [Hand(x[1],parse(Int,x[2])) for x in split.(lines," ")]
    hands = sort(hands,lt=isless)
    sum(bid.(hands) .* (1:length(hands)))
end

pt1 = solveit()

function solveit2()
    lines = loadlines()
    hands = [Hand(x[1],parse(Int,x[2])) for x in split.(lines," ")]
    hands = sort(hands,lt=islessjokers)
    sum(bid.(hands) .* (1:length(hands)))
end

pt2 = solveit2()

println("Part 1: $pt1")
println("Part 2: $pt2")

#Normal poker rules of sorting for tiebreaks (was incorrect)
#isless(hand1::Hand,hand2::Hand) = handtype(hand1) == handtype(hand2) ? sortedranks(hand1) < sortedranks(hand2) : handtype(hand1) < handtype(hand2)
#function sorthand(hand)
#    Hand(ranks[sortedranks(hand)],hand.bid)
#end