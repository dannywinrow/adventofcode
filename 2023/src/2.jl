include("../../helper.jl")

const bag = Dict("red" => 12,"green"=>13,"blue"=>14)

function solveit()
    lines = loadlines()
    sum(possible.(lines) .* collect(1:length(lines)))
end

function possible(game)
    draws = split.(split(split(game,": ")[2],"; "),", ")
    for draw in draws
        draw = split.(draw," ")
        for ball in draw
            parse(Int,ball[1]) > bag[ball[2]] && return false
        end
    end
    true
end

pt1 = solveit()

function solveit2()
    lines = loadlines()
    sum(powerof.(lines))
end

function powerof(game)
    minbag = Dict("red" => 0,"green"=>0,"blue"=>0)
    draws = split.(split(split(game,": ")[2],"; "),", ")
    for draw in draws
        draw = split.(draw," ")
        for ball in draw
            parse(Int,ball[1]) > minbag[ball[2]] && (minbag[ball[2]] = parse(Int,ball[1]))
        end
    end
    *(values(minbag)...)
end

pt2 = solveit2()

println("Part 1: $pt1")
println("Part 2: $pt2")