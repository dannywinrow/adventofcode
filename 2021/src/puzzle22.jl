function readinput(file)
   input = read(file,String)
   input = replace(input,"off"=>"0")
   input = replace(input,"on"=>"1")
   m = eachmatch(r"(\d) x=([\d,-]+)\.\.([\d,-]+),y=([\d,-]+)\.\.([\d,-]+),z=([\d,-]+)\.\.([\d,-]+)",input)
   v = [parse.(Int,j) for j in [x.captures for x in m]]
   [(Bool(x[1]),x[2:end]) for x in v]
end

function solveit(file)
   f = readinput(file)
   f = [(x[1],x[2].+51) for x in f]

   x = falses(101,101,101);
   n=f[1]
   for n in f
      if maximum(n[2][[1,3,5]]) < 101 && minimum(n[2][[2,4,6]]) > 0
         ind = min.(max.(n[2],0),101)
         x[ind[1]:ind[2],ind[3]:ind[4],ind[5]:ind[6]] .= n[1]
      end
   end
   sum(x)
end

function getinstr(file)
   f = readinput(file)
   [(x[1],Tuple([x[2][i*2-1]:x[2][i*2] for i in 1:3])) for x in f]
end

function solveit2(file)

   mins = [minimum([x[2][[1,3,5]][i] for x in f]) for i in 1:3]
   maxs =  [maximum([x[2][[2,4,6]][i] for x in f]) for i in 1:3]
   instructions = [(x[1],x[2][[1,3,5]] .- mins .+ 1, x[2][[2,4,6]] .- mins .+ 1) for x in f]
   @info maxs .- mins
   
   x = falses(Tuple(maxs .- mins .+ 1))
   for n in instructions
      x[n[2][1]:n[3][1],n[2][2]:n[3][2],n[2][3]:n[3][3]] .= n[1]
   end
   sum(x)
end

function processinstruction(arr,instr, window)
   if (maximum(instr[2]) < 101) && (minimum(instr[3]) > 0)
      ind = min.(max.(n[2],0),101)
      x[ind[1]:ind[2],ind[3]:ind[4],ind[5]:ind[6]] .= n[1]
   end
end

function makegroups(instructions)
   groups = []
   instrs = [(i,a[1],a[2]) for (i,a) in enumerate(instructions)]
   for a in instrs
      x = findfirst(g->a in g, groups)
      if isnothing(x)
         groups = [groups...,Set([a])]
         x = length(groups)
      end
      selector = [rngsect(a[3],b[3]) for b in instrs]
      groups[x] = union(groups[x],Set(instrs[selector]))
   end
   groups = stripgroup.(groups)
   groups[.!isnothing.(groups)]
end

rngsect(a,b) = validrng(intersect.(a,b))
validrng(rng) = all(length.(rng) .> 0)
function stripgroup(instrs)
   group = sort([instrs...])
   for instr in group
      if instr[2]
         return group
      else
         group = group[2:end]
      end
   end
end

shift(ur::UnitRange,i::Int) = (ur[1]+i):(ur[2]+i)

function solvegroup(group)
   group = stripgroup(group)
   if isnothing(group)
      return 0
   elseif length(group) == 1
      return prod(length.(group[1][3]))
   else
      mins = [minimum([instr[3][i][1] for instr in group]) for i in 1:3]
      maxs =  [maximum([instr[3][i][end] for instr in group]) for i in 1:3]
      
      @show mins
      @show maxs
      @show maxs .- mins .+ 1
      
      x = falses(Tuple(maxs .- mins .+ 1))
      for instr in group
         x[shift.(instr[3],-1 .* (mins .- 1))...] .= instr[2]
      end
      sum(x)
   end
end

function solvegroup2(group)
   rngs = []
   for instr in group
      nrngs = []
      for rng in rngs
         append!(nrngs,breakold(instr[3],rng))
      end
      instr[2] && append!(nrngs,[instr[3]])
      rngs = copy(nrngs)
   end
   length(rngs) == 0 && return 0
   sum([prod(length.(rng)) for rng in rngs])
end

function breakold(new_t,old_t)
   sect = intersect.(new_t,old_t)
   if all(length.(sect) .> 0)
      ret = [
      (old_t[1][1]:(sect[1][1]-1),old_t[2],old_t[3]),
      ((sect[1][end]+1):old_t[1][end],old_t[2],old_t[3]),
      (max(sect[1][1],old_t[1][1]):min(sect[1][end],old_t[1][end]),old_t[2][1]:(sect[2][1]-1),old_t[3]),
      (max(sect[1][1],old_t[1][1]):min(sect[1][end],old_t[1][end]),(sect[2][end]+1):old_t[2][end],old_t[3]),
      (max(sect[1][1],old_t[1][1]):min(sect[1][end],old_t[1][end]),max(sect[2][1],old_t[2][1]):min(sect[2][end],old_t[2][end]),old_t[3][1]:(sect[3][1]-1)),
      (max(sect[1][1],old_t[1][1]):min(sect[1][end],old_t[1][end]),max(sect[2][1],old_t[2][1]):min(sect[2][end],old_t[2][end]),(sect[3][end]+1):old_t[3][end])
      ]
      val = validrng.(ret)
      return ret[val]
   else
      return [old_t]
   end
end

function solveit3(file)
   instructions = getinstr(file)
   groups = makegroups(instructions)
   sum(solvegroup2.(groups))
end
function solveit4(file)
   instructions = getinstr(file)
   instructions = [(i,a[1],a[2]) for (i,a) in enumerate(instructions)]
   sum(solvegroup2(instructions))
end

function solveit3(file)
   instructions = getinstr(file)

   groups = makegroups(instructions)
   sum(solvegroup2.(groups))
end

file = "2021//inputs/22ex3.txt"
solveit("2021//inputs/22ex1.txt")
solveit("2021//inputs/22ex2.txt")
solveit("2021//inputs/22ex3.txt")
solveit("2021//inputs/22.txt")
solveit2("2021//inputs/22ex1.txt")
solveit2("2021//inputs/22ex2.txt")
solveit2("2021//inputs/22.txt")
@time solveit3("2021//inputs/22ex1.txt")
solveit3("2021//inputs/22ex2.txt")
solveit3("2021//inputs/22ex3.txt")
@time solveit4("2021//inputs/22ex1.txt")
@time solveit4("2021//inputs/22ex2.txt")
@time solveit4("2021//inputs/22ex3.txt")
@time solveit4("2021//inputs/22.txt")
