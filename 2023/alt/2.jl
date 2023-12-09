include("../../helper.jl")
import Base.parse
import Base.<

struct Game
    draws
end
function Base.parse(::Type{Game},str)
    x = split(str,": ")[2]
    Game(parse.(Draw,split(x,"; ")))
end

struct Draw
    balls
end
function Base.parse(::Type{Draw},str)
    function extract(ballstr)
        num, colour = split.(ballstr," ")
        num = parse(Int,num)
        colour => num
    end
    Draw(Dict([extract(ballstr) for ballstr in split(str,", ")]))
end

const bag = Draw(Dict("red" => 12,"green"=>13,"blue"=>14))

function solveit()
    lines = loadlines()
    sum(possible.(lines) .* collect(1:length(lines)))
end

function Base.:(<=)(draw::Draw,draw2::Draw)
    for colour in keys(draw.balls)
        draw.balls[colour] > draw2.balls[colour] && return false
    end
    true
end

function minbag(game::Game)
    bag = Draw("red"=>0,"green"=>0,"blue"=>0)
    for draw in game.draws
        for key in keys(draw)
            if draw[key] > bag[key]
        end
    end
end
function possible(game::Game,bag)

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