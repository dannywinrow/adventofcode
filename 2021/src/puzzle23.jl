import Base.parse
import Base.getindex
import Base.show
import Base.copy

struct Game
   grid
end
function Base.show(io::IO, game::Game)
   for row in eachrow(game.grid)
      println(io,join(row))
   end
end
Base.show(io::IO, ::MIME"text/plain", game::Game) = print(io, "Game:\n", game)

Base.:(==)(game::Game, game2::Game) = game.grid == game2.grid

Base.getindex(game::Game,i) = Base.getindex(game.grid,i)

function Base.parse(Game,str)
   input = split(str,r"\n")
   rows = length(input)
   cols = length(input[1])
   input = vcat([[i for i in str] for str in input]...)
   input = permutedims(reshape(input,cols,rows))
   Game(input)
end
Base.copy(game::Game) = Game(copy(game.grid))
pieces(game::Game) = findall(x -> 'A' ≤ x ≤ 'D', game.grid)
empty(game::Game) = findall(x -> x == '.', game.grid)

homecol(game,piece) = x = 2*(game[piece] - 'A' + 1)
homecolindices(game,piece) = CartesianIndices((3:6,homecol(game,piece):homecol(game,piece)))

nearhomecol(game,piece) = piece in CartesianIndices((2:2,homecol(game,piece)-1:homecol(game,piece)+1))
function homecolindex(game,piece)
   col = homecolindices(game,piece)
   pname = game[piece]
   ps = sum(x->x==pname,game.grid)
   empties = sum(x->x=='.',game.grid)
   if (ps + empties) == 4
      return col[empties]
   else
      return nothing
   end
end 

movecost(piecename) = 10^(piecename - 'A')

function move(game,piece,move)
   game = copy(game)
   game.grid[move] = game.grid[piece]
   game.grid[piece] = '.'
   manhattandistance(piece,move)*movecost(game[move]), game
end
function moves(game,piece)
   e = empty(game)
   mvs = []
   if piece[1] == 2
      adds = CartesianIndices((0:0,-2:2))
      mvs = intersect(piece .+ adds,e)
      if nearhomecol(game,piece)
         x = homecolindex(game,piece)
         if !isnothing(x)
            mvs = union(mvs,[x])
         end
      end
   else
      if !in(piece,homecolindices(game,piece)) || isnothing(homecolindex(game,piece))
         rowmove = 2-piece[1]
         if isclear(game,CartesianIndices(((piece[1]-1):-1:3,piece[2]:piece[2])))
            up = CartesianIndices((rowmove:rowmove,-1:2:1))
            mvs = intersect(piece .+ up, e)
         end
      end
   end
   mvs
end

isclear(game,carts) = carts == [] || all(game[carts] .== '.')

function outneighbors(game::Game)
   neighbours = Game[]
   costs = Int[]
   for piece in pieces(game)
      for mv in moves(game,piece)
         c, g = move(game,piece,mv)
         push!(neighbours,g)
         push!(costs,c)
      end
   end
   collect(zip(neighbours, costs))
end

using DataStructures

function leastcostgame(src::Game,dest::Game)
      
      H = PriorityQueue{Int,Int}()
      # fill creates only one array.

      nodes = [src]
      dists = [0]
      visited = [true]
      H[1] = 0
      parent = [0]
      function getnodeindex(game)
         i = findfirst(x->x==game,nodes)
         isnothing(i) && return addnode(game)
         return i
      end
      function addnode(game)
         push!(nodes,game)
         push!(dists,typemax(Int))
         push!(visited,false)
         push!(parent,0)
         return length(nodes)
      end
      function pathto(i)
         games = Game[]
         costs = Int[]
         stop = false
         while !stop
            pushfirst!(games,nodes[i])
            pushfirst!(costs,dists[i])
            i == 1 && break
            i = parent[i]
         end
         games, costs
      end
      while !isempty(H)
          i = dequeue!(H)
          d = dists[i]
          if nodes[i] == dest
            return pathto(i)
          end
          for (neighbour,cost) in outneighbors(nodes[i])
               v = getnodeindex(neighbour)
               alt = d + cost
              if alt < dists[v]
                  dists[v] = alt
                  parent[v] = i
                  H[v] = alt
              end
          end
      end
      return nodes,dists
end
manhattandistance(v,u) = sum(abs.(v .- u))
manhattandistance(v::CartesianIndex,u::CartesianIndex) = manhattandistance(Tuple(v),Tuple(u))

input = "#############
#..#.#.#.#..#
###D#A#C#C###
  #D#C#B#A#  
  #D#B#A#C#  
  #D#A#B#B#  
  #########  "

endstate = "#############
#..#.#.#.#..#
###A#B#C#D###
  #A#B#C#D#  
  #A#B#C#D#  
  #A#B#C#D#  
  #########  "
game = parse(Game,input)
endgame = parse(Game,endstate)
out = leastcostgame(game,endgame)
sum(sum.(x->x=='.',[x.grid[4,:] for x in out[1]]))

