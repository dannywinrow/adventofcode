import Base.show
import Base.parse
import Base.size

using Colors, ImageShow

file = "2021\\inputs\\input13.txt"

struct Paper
    grid
    instructions
end

function Base.parse(Paper,file)
    input = read(file,String);
    input = split(input,r"\r\n\r\n")
    gridinput = split(input[1],r"\r\n|,")
    gridinput = reshape(gridinput,2,:)
    gridinput = parse.(Int,gridinput)
    dim1 = maximum(gridinput[1,:])+1
    dim2 = maximum(gridinput[2,:])+1
    grid = falses(dim1,dim2)
    for coord in eachcol(gridinput)
        grid[CartesianIndex(coord[1]+1,coord[2]+1)] = true
    end
    insinput = eachmatch(r"fold along (x|y)=(\d*)",input[2])
    instructions = [(i[1][1],parse(Int,i[2])) for i in insinput]
    Paper(grid,instructions)
end

function size(paper::Paper)
    maxrow = findlast(x->x>0,[sum(i) for i in eachrow(paper.grid)])
    maxcol = findlast(x->x>0,[sum(i) for i in eachcol(paper.grid)])
    maxrow,maxcol
end
function Base.show(io::IO, paper::Paper)
    Gray.(getgridtoshow(paper))
end
Base.show(io::IO, ::MIME"text/plain", paper::Paper) = print(io, "Paper:\n", paper)
getgridtoshow(paper) = paper.grid[1:size(paper)[1],1:size(paper)[2]]
foldnext(paper) = fold(paper,popfirst!(paper.instructions))

function fold(paper::Paper, instr)
    axis = instr[1]
    val = instr[2]
    if axis == 'y'
        moves = min(size(paper.grid)[2] - 1 - val, val)
        for x in 1:moves
            paper.grid[:,val+1-x] .= paper.grid[:,val+1+x] .| paper.grid[:,val+1-x]
            paper.grid[:,val+1+x] .= false
        end
    elseif axis == 'x'
        moves = min(size(paper.grid)[1] - 1 - val, val)
        for x in 1:moves
            paper.grid[val+1-x,:] .= paper.grid[val+1+x,:] .| paper.grid[val+1-x,:]
            paper.grid[val+1+x,:] .= false
        end
    end
end

paper = parse(Paper,file)
Gray.(getgridtoshow(paper)')

img = [ 0 1
        1 0]

Gray.(img)
paper.instructions
while length(paper.instructions) > 0
    foldnext(paper)
end

paper.grid'
sum(paper.grid)
paper.instructions
instr = paper.instructions[1]
l = [i for i in insinput]

maze = parse(Maze,file)

cavesfrom(maze::Maze, from) = maze.paths[2,maze.paths[1,:].==from]
smallcaves(maze::Maze) = filter(issmallcave,unique(maze.paths[:]))
issmallcave(cave) = cave[1] in 'a':'z'
bigcaves(maze::Maze) = filter(!issmallcave,unique(maze.paths[:]))
findpathsfrom(maze,cave::String) = findpathsfrom(maze,[cave])
findpaths(maze::Maze) = findpathsfrom(maze,"start")

function findpathsfrom(maze,path,singlecave=true)
    paths = []
    for nextcave in cavesfrom(maze,path[end])
        if nextcave == "end"
            push!(paths,[path...,nextcave])
        elseif nextcave == "start"

        elseif !issmallcave(nextcave) || !(nextcave in path) || singlecave
            if (nextcave in path) && issmallcave(nextcave)
                scave = false
            else
                scave = singlecave
            end
            push!(paths,findpathsfrom(maze,[path...,nextcave],scave)...)
        end
    end
    return paths
end

findpaths(maze)
