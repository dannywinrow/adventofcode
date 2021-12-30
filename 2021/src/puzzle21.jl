
mutable struct DetDie
   total
   index
end

DetDie(x) = DetDie(x,x)
roll!(dd::DetDie) = (dd.index = ((dd.index % dd.total) + 1))
roll!(dd::DetDie,n) = sum([roll!(dd) for _ in 1:n])

dd = DetDie(100)

mutable struct DiracGame
   players
   currplayer
   boardsize
   die
   target
   moves
end

mutable struct Player
   position
   points
end   

DiracGame(x,y,dd) = DiracGame([Player(x,0),Player(y,0)],1,10,dd,1000,0)
DiracGame(x,y) = DiracGame(x,y,nothing)
function move!(dg::DiracGame)
   dice = [roll!(dg.die) for _ in 1:3]
   dicescore = sum(dice)
   player = dg.players[dg.currplayer]
   player.position = ((player.position + dicescore -1) % dg.boardsize) + 1
   player.points += player.position
   @info "Player $(dg.currplayer) rolls $dice and moves to space $(player.position) for a total score of $(player.points)"
   dg.currplayer = (dg.currplayer % length(dg.players)) + 1
   dg.moves += 1
end

won(dg::DiracGame) = maximum(getfield.(dg.players,:points)) >= dg.target
function score(dg::DiracGame)
   minimum(getfield.(dg.players,:points)) * dg.moves * 3
end

function solveit(p1,p2)
   dg = DiracGame(p1,p2,DetDie(100))
   while !won(dg)
      move!(dg)
   end
   part1 = score(dg)
   #println("$file solution:")
   println("Part 1: $part1 score times moves")
   #println("Part 2: $part2 on pixels after 50 enhances")
   println("")
end

import Base.copy
Base.copy(x::T) where T = T([deepcopy(getfield(x, k)) for k ∈ fieldnames(T)]...)

function quantummove!(dg::DiracGame)
   dice = [roll!(dg.die) for _ in 1:3]
   dicescore = sum(dice)
   player = dg.players[dg.currplayer]
   player.position = ((player.position + dicescore -1) % dg.boardsize) + 1
   player.points += player.position
   @info "Player $(dg.currplayer) rolls $dice and moves to space $(player.position) for a total score of $(player.points)"
   dg.currplayer = (dg.currplayer % length(dg.players)) + 1
   dg.moves += 1
   DiracGame()
end

struct QuantDie
   rng
end

function move(dg,dicescore::Int)
   dg = copy(dg)
   player = dg.players[dg.currplayer]
   player.position = ((player.position + dicescore - 1) % dg.boardsize) + 1
   player.points += player.position
   dg.currplayer = (dg.currplayer % length(dg.players)) + 1
   dg.moves += 1
   dg
end

function roll(dg,die::QuantDie)
   if typeof(dg[1]) <: Int
      dg
   else
      roll.([move(dg[1],outcomes[i]) for i in eachindex(outcomes)],Ref(die))
   end
end
add_dim(x::Array,n::Int) = reshape(x, (size(x)...,n))
rng = 1:3
nrolls = 3
function getWeightedDie(rng, nrolls)
   arr = [sum(getindex.(Ref(rng),Tuple(ci)))  for ci in CartesianIndices(Tuple(fill(length(rng),nrolls)))]
   outcomes = unique(arr)
   weights = sum(x->x .== outcomes, arr)
   WeightedDie(outcomes,weights)
end


struct WeightedDie
   outcomes
   weights
end

function paths(dg,die::WeightedDie,weight=1)
   won(dg) && return (weight,dg.moves)
   vcat([paths(move(dg,die.outcomes[i]),die,die.weights[i]*weight) for i in eachindex(die.outcomes)]...)
end

function pathsto(x,y)
   dg = DiracGame([Player(y,0)],1,10,0,x,0)
   p = paths(dg,getWeightedDie(1:3,3),1)
   movelengths = sort(unique([i[2] for i in p]))
   num = sum((v->((v[2] .== movelengths) .* v[1])), p)
   (lens=movelengths, cnt=num)
end

function cntwins(target,p1pos,p2pos) 
   x = pathsto(target,p1pos)
   y = pathsto(target,p2pos)

   ynw = []
   rncnt = 0
   for i in eachindex(y.cnt)
      append!(ynw,[27^(y.lens[i]-1)-rncnt])
      rncnt = rncnt*27 + y.cnt[i]
   end
   xwins = sum(ynw .* x.cnt)
   xnw = []
   rncnt = 0 
   for i in eachindex(x.cnt)
      rncnt = rncnt*27 + x.cnt[i]
      append!(xnw,[27^(x.lens[i])-rncnt])
   end
   ywins = sum(xnw .* y.cnt)
   xwins,ywins
end

#example
solveit(4,8)

#personal input
solveit(8,6)

cntwins(21,4,8)
cntwins(21,8,6)


