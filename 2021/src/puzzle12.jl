import Base.show
import Base.parse

file = "2021\\inputs\\input12.txt"

struct Maze
    paths
end

function Base.parse(Maze,file)
    input = read(file,String);
    input = split(input,r"\r\n|-")
    input = reshape(input,2,:)
    input = hcat(input,input[[2,1],:])
    Maze(input)
end

cavesfrom(maze::Maze, from) = maze.paths[2,maze.paths[1,:].==from]
smallcaves(maze::Maze) = filter(issmallcave,unique(maze.paths[:]))
issmallcave(cave) = cave[1] in 'a':'z'
bigcaves(maze::Maze) = filter(!issmallcave,unique(maze.paths[:]))
findpathsfrom(maze,cave::String,singlecave::Bool=true) = findpathsfrom(maze,[cave],singlecave)
findpaths(maze::Maze,singlecave::Bool=true) = findpathsfrom(maze,["start"],singlecave)

function findpathsfrom(maze,path::Vector,singlecave=true)
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

function part1()
    maze = parse(Maze,file)
    length(findpaths(maze,false))
end

function part2()
    maze = parse(Maze,file)
    length(findpaths(maze,true))
end


@show part1()
@show part2()