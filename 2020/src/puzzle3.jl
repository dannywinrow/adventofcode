using CSV, DataFrames

input = read("2020\\inputs\\input3.txt", String);
input = split(input,"\r\n")
rep = length(input[1])
steps = length(input)

function trees(slope)
  xspeed = slope[1]
  yspeed = slope[2]
  ycoord = collect(1:yspeed:steps)
  xcoord = [((xspeed*y) % rep) + 1 for y in 0:length(ycoord)-1]
  sum(getindex.(getindex(input,ycoord),xcoord) .== '#')
end

slopes = [[1,1],[3,1],[5,1],[7,1],[1,2]]
slope = slopes[2]
trees(slopes[2])
tests = trees.(slopes)
*(tests...)