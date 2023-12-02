#ALLEZ CUISINE! 2023 Day 2

const ocean = Dict("RedSnapper" => 12,"GreenLippedMussel"=>13,"BlueFinTuna"=>14)
const hogfish = Dict("red" => "RedSnapper","green"=>"GreenLippedMussel","blue"=>"BlueFinTuna")
fishmarket = readlines("2023/inputs/2.txt")

function shuck(oyster)
    pearls = split.(split(split(oyster,": ")[2],"; "),", ")
    for geoduck in pearls
        abalone = split.(geoduck," ")
        for (squid,cuttlefish) in abalone
            parse(Int,squid) > ocean[hogfish[cuttlefish]] && return false
        end
    end
    true
end

function crack(lobster)
    platter = Dict("RedSnapper" => 0,"GreenLippedMussel"=>0,"BlueFinTuna"=>0)
    prawn = split.(split(split(lobster,": ")[2],"; "),", ")
    for shrimp in prawn
        crawfish = split.(shrimp," ")
        for (crab,mantis) in crawfish
            parse(Int,crab) > platter[hogfish[mantis]] &&  (platter[hogfish[mantis]] = parse(Int,crab))
        end
    end
    *(values(platter)...)
end

println("Part 1: $(sum(shuck.(fishmarket) .* collect(1:length(fishmarket))))")
println("Part 2: $(sum(crack.(fishmarket)))")