import Base.parse
import Base.getindex
import Base.setindex
import Base.show
import Base.copy
import Base.size
using DataStructures

struct Game
   row::Vector{Char}
   homes::Vector{Vector{Char}}
end

struct GameIndex
   home::Bool
   i::Int
   j::Int
end

Base.size(game::Game) = (length(game.homes[1])+3,length(game.homes)*2+5)

function Base.show(io::IO, game::Game)
   x = size(game)
   println(io, repeat("#",x[2]))
   println(io, join(["#",join(game.row[1:2]),"#",join([i*"#" for i in game.row[3:(end-2)]]),join(game.row[(end-1):end]),"#"]))
   print(io,"###"*join([home[1]*"#" for home in game.homes])*"##\n")
   print(io,join(["  #"*join([home[i]*"#" for home in game.homes])*"\n" for i in 2:length(game.homes[1])]))
   println(io,"  "*repeat("#",x[2]-4))
end
Base.show(io::IO, ::MIME"text/plain", game::Game) = print(io, "Game:\n", game)

function Base.:(==)(game::Game, game2::Game)
   game.homes == game2.homes &&
   game.row == game2.row
end

function Base.copy(game::Game)
   row = copy(game.row)
   homes = [copy(home) for home in game.homes]
   Game(row,homes)
end

function Base.parse(Game,str)
   str = replace(str,r"#| "=>"")
   input = split(str,r"\n")
   row = [i for i in input[2]]
   homecount = length(input[3])
   homelength = length(input)-3
   homes = [[str[i] for str in input[3:(end-1)]] for i in 1:homelength]
   Game(row,homes)
end

function valid(game,arr)
   d = Dict([ch => sum(y-> y == ch,arr) for ch in unique(arr)])
   p = pieces(game)
   for key in keys(d)
      !in(key,keys(p)) && return false
      d[key] > p[key] && return false
   end
   return true
end

function pieces(game::Game)
   x = sort(wholegame(game))
   Dict([ch => sum(y-> y == ch,x) for ch in unique(x)])
end

function wholegame(game::Game)
   vcat(game.row,vcat([home for home in game.homes]...))
end

function remainingcharacters(game::Game,arr)
   p = pieces(game)
   d = Dict([ch => sum(y-> y == ch,arr) for ch in union(keys(p),unique(arr))])
   out = []
   for key in keys(p)
      out = append!(out,fill(key,p[key] - d[key]))
   end
   out
end

function states(game,gameend)
   homelen = length(game.homes[1])
   homecnt = length(game.homes)
   emptyhome = fill('.',homelen)
   gstates = []
   function homestates(h)
      homestates = []
      takefrom = [game.homes[h],gameend.homes[h]]
      for i in 1:homelen
      homestates = vcat(homestates,[vcat(emptyhome[1:(i-1)],home[i:homelen]) for home in takefrom])
      end
      push!(homestates,emptyhome)
      unique(homestates)
   end
   homests = [homestates(h) for h in 1:homecnt]
   for i in eachindex(homests[1])
      for j in eachindex(homests[2])
         arr = vcat(homests[1][i],homests[2][j])
         if valid(game,arr)
            for k in eachindex(homests[3])
               arr2 = vcat(arr,homests[3][k])
               if valid(game,arr2)
                  for m in eachindex(homests[4])
                     arr3 = vcat(arr2,homests[4][m])
                     if valid(game,arr3)
                        rows = unique_permutations(remainingcharacters(game,arr3))
                        for row in rows
                           push!(gstates,Game(row,[homests[1][i],homests[2][j],homests[3][k],homests[4][m]]))
                        end
                     end
                  end
               end
            end
         end
      end
   end
   gstates
end

function Base.similar(game::Game)
   homes = similar(game.homes)
   for i in eachindex(homes)
      homes[i] = similar(game.homes[1])
   end
   row = similar(game.row)
   Game(homes,row)
end

function Base.setindex!(game::Game,i,location::Tuple)
   field = location[1]
   if field == :home
      game.homes[location[2]][location[3]] = i
   else
      game.row[location[2]] = i
   end
end

manhattandistance(v,u) = sum(abs.(v .- u))
manhattandistance(v::CartesianIndex,u::CartesianIndex) = manhattandistance(Tuple(v),Tuple(u))

function unique_permutations(x::T, prefix=T()) where T
   if length(x) == 1
      return [[prefix; x]]
   else
      t = T[]
      for i in eachindex(x)
         if i > firstindex(x) && x[i] == x[i-1]
               continue
         end
         append!(t, unique_permutations([x[begin:i-1];x[i+1:end]], [prefix; x[i]]))
      end
      return t
   end
end

function validmove(gamefrom,gameto)
   gf = wholegame(gamefrom)
   gt = wholegame(gameto)
   moved = findall(gf .!= gt)
   move = location.(Ref(game),moved)
   #@show length(moved) != 2
   #@show sum(gf[moved] .== '.') != 1
   if length(moved) != 2 || sum(gf[moved] .== '.') != 1
      return false
   else
      gf[moved[1]] == '.' && reverse!(moved)
      #@show clearpath(gamefrom,moved) 
      #@show validhome(gamefrom,moved)
      return clearpath(gamefrom,move) && validhome(gamefrom,moved)
   end
end
function location(game,i)
   if i <= length(game.row)
      return (:row,i)
   else
      i = i - length(game.row)
      homeloc = ((i-1) % length(game.homes))+1
      homeind = ((i-1) ÷ length(game.homes))+1 
      return (:home,homeind,homeloc)
   end
end
function clearpath(game,move)
   i = move[1][1] == :home ? move[1][2] + 1.5 : move[1][2]
   j = move[2][1] == :home ? move[2][2] + 1.5 : move[2][2]
   rng = i > j ? (ceil(Int,j):floor(Int,i-0.4)) : (ceil(Int,i+0.4):floor(Int,j))
   #@show rng
   all(game.row[rng] .== '.')
end

function validhome(game,moved)
   move = location.(Ref(game),moved)
   if move[1][1] == :home
      allowed = ['A' + move[1][2] - 1,'.']
      return !all(in(allowed).(game.homes[move[1][2]]))
   end
   if move[2][1] == :home
      allowed = ['A' + move[2][2] - 1,'.']
      return (game[move[2]] in allowed) && all(in(allowed).(game.homes[move[2][2]]))
   end
   return true
end
function getindex(game::Game,location::Tuple)
   field = location[1]
   if field == :home
         game.homes[location[2]][location[3]]
   else
      game.row[location[2]]
   end
end
getindex(game::Game,i) = getindex(game,location(game,i))

function outneighbors(game::Game)
   neighbours = Game[]
   costs = Int[]
   for i in outhomes(game)
      for j in findall(x->x.=='.',game.row)
         mv = (:home,i)=>(:row,j)
         if clearpath(game,mv)
            g,c = move(game,mv)
            while true
               mms = magnetmoves(g)
               length(mms) == 0 && break
               for mm in mms
                  g, c1 = move(g,mm)
                  c += c1
               end
            end
            push!(neighbours,g)
            push!(costs,c)
         end
      end
   end
   collect(zip(neighbours, costs))
end

using DataStructures
function leastcostgame(src::Game,dest::Game)
      
      H = PriorityQueue{Int,Int}()
      nodes = Game[src]
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
               (length(H) % 100) == 0 && @show length(H)
            end
         end
      end
      return nodes,dists
end

function cartesian(move)
   if move[1]==:home
      CartesianIndex(move[2]*2+1,move[3]+1)
   else
      CartesianIndex(move[2]+min(max(move[2]-2,0),4),1)
   end
end

movecost(piecename) = 10^(piecename - 'A')
function move(game,move;safe=true)
   if move[1][1] == :home
      move1 = Tuple((move[1][1],move[1][2],sum(x->x=='.',game.homes[move[1][2]])+1))
   else
      move1 = move[1]
   end
   if move[2][1] == :home
      move2 = Tuple((move[2][1],move[2][2],sum(x->x=='.',game.homes[move[2][2]])))
   else
      move2 = move[2]
   end
   steps = 0
   from = game[move1]
   to = game[move2]
   g = copy(game)
   g[move1] = to
   g[move2] = from
   #@show movecost(from)
   #@show cartesian(move1)
   #@show cartesian(move2)
   ci1 = cartesian(move1)
   ci2 = cartesian(move2)
   ci3 = CartesianIndex((ci1[1]+ci2[1]) ÷ 2,1)
   c = (manhattandistance(ci1,ci3)+manhattandistance(ci3,ci2)) * movecost(from)
   (!safe || validmove(game,g)) && return g, c
   nothing
end

tochar(i) = 'A' + i - 1
toind(ch) = ch - 'A' + 1
function inhomes(game)
   findall([all(in([tochar(i),'.']).(home)) && in('.',home) for (i,home) in enumerate(game.homes)])
end
function outhomes(game)
   findall([!all(in([tochar(i),'.']).(home)) for (i,home) in enumerate(game.homes)])
end
function magnetmoves(game)
   moves = []
   for inhome in inhomes(game)
      for (i,ch) in enumerate(game.row)
         if ch == tochar(inhome)
            move = (:row,i)=>(:home,inhome)
            if clearpath(game,move)
               push!(moves,move)
            end
         end
      end
      for outhome in outhomes(game)
         if topchar(game,outhome) == tochar(inhome)
            move = (:home,outhome)=>(:home,inhome)
            if clearpath(game,move)
               push!(moves,move)
            end
         end
      end
   end
   return moves
end
   
function topchar(game,homeindex)
   for ch in game.homes[homeindex]
      (ch != '.') && return ch
   end
   return '.'
end

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
gameend = parse(Game,endstate)

#leastcostgame(game,gameend)

function solveitdict(src::Game,dest::Game)
   game in keys(DJ) && return DJ[game]
   src == dest && return 0
   x = outneighbors(src)
   ans = 1_000_000_000
   for (neighbour, cost) in outneighbors(src)
      ans = min(ans,cost + solveit(neighbour, dest))
   end
   DJ[src] = ans
   return ans
end
function solveit(src::Game,dest::Game)
   src == dest && return 0
   x = outneighbors(src)
   ans = 1_000_000_000
   for (neighbour, cost) in x
      ans = min(ans,cost + solveit(neighbour, dest))
   end
   return ans
end
@time solveit(game,gameend)

DJ = Dict{Game,Int}()
@time solveitdict(game,gameend)