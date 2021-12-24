using Graphs, MetaGraphs

function getinput(file)
   input = read(file,String)
   input = split(input,r"\r\n\r\n")
   input = split.(input,r"\r\n")
   input = [i[2:end] for i in input]
   input = [split.(i,",") for i in input]
   input = [[parse.(Int,j) for j in i] for i in input]
   #input = [CartesianIndex.(Tuple.(i)) for i in input]
end

function distance(a,b;accuracy=3)
   floor(Int,sqrt(sum(abs.(a .- b) .^ 2)*10^accuracy))
end

function scannergraph(scanner)
   dim = length(scanner)
   graph = complete_graph(dim)
   graph = MetaGraph(graph)
   for i in 1:25, j in i:dim
      i!=j && set_prop!(graph, Edge(i, j), :weight, distance(scanner[i],scanner[j]))
   end
   graph
end 
    
function gettransformationmatrix(v,u)
   for i in 1:3, p in [-1,1]
      for j in setdiff(1:3,i), q in [-1,1]
         for k in setdiff(1:3,[i,j]), r in [-1,1]
            mat = zeros(Int,3,3)
            mat[1,i] = p
            mat[2,j] = q
            mat[3,k] = r
            mat*v == u && return mat
         end
      end
   end    
end

function solveit(scanners)
   scannerst = copy(scanners)
   dim = length(scanners)
   gs = scannergraph.(scanners)
   rng = 1:dim
   transformed = zeros(Bool,dim)
   transformed[1] = true
   while sum(.!transformed) > 0
      for p in rng[transformed]
         for q in rng[.!transformed]
            t = [length(intersect(weights(gs[p])[i,:],weights(gs[q])[j,:])) for i in 1:25, j in 1:25]
            if maximum(t) >= 12
               cis = CartesianIndices(t)[t .== 12]
               beaconmap = [scannerst[p][i[1]] => scanners[q][i[2]] for i in cis]
               r = beaconmap[1][1] .- beaconmap[2][1]
               s = beaconmap[1][2] .- beaconmap[2][2]
               transformation = gettransformationmatrix(s,r)
               translation = beaconmap[1][1] .- transformation*beaconmap[1][2]
               scannerst[q] = [transformation * s + translation for s in scanners[q]]
               transformed[q] = true
            end
         end
      end
   end

   length(union(scannerst...))
end

scanners = getinput("2021\\inputs\\input19test.txt")
solveit(scanners)