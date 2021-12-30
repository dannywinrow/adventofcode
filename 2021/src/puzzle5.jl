using CSV, DataFrames
import Base.parse
import Base.show
import Base.iterate

input = "0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2"


input = read("2021\\inputs\\input5.txt",String);
input = split(input,"\n")


struct Line
    x1
    y1
    x2
    y2
end

struct Grid
    grid
    Grid(x::Int) = Grid(zeros(Int,x,x))
    Grid(grid) = new(grid)
end

function Base.parse(Line, str)
    mat = match(r"(?<x1>\d*),(?<y1>\d*) -> (?<x2>\d*),(?<y2>\d*)",str)
    x1 = parse(Int,mat["x1"])+1
    x2 = parse(Int,mat["x2"])+1
    y1 = parse(Int,mat["y1"])+1
    y2 = parse(Int,mat["y2"])+1
    ((x1<x2) || (y1<y2)) ? Line(x1,y1,x2,y2) : Line(x2,y2,x1,y1)
end

function Base.show(io::IO, line::Line)
    print(io, "($(line.x1),$(line.y1)) -> ($(line.x2),$(line.y2))")
end
Base.show(io::IO, ::MIME"text/plain", line::Line) = print(io, "Line:\n", line)
isorthogonal(line) = (line.x1 == line.x2) || (line.y1 == line.y2)

Base.iterate(line::Line,state=1) = state > 4 ? nothing : ([line.x1,line.y1,line.x2,line.y2][state], state+1)

function points(line::Line)
    if line.x1 == line.x2
        [CartesianIndex(line.x1,y) for y in (line.y1):(line.y2)]
    elseif line.y1 == line.y2
        [CartesianIndex(x,line.y1) for x in (line.x1):(line.x2)]
    else
        xmult = (line.x1 < line.x2) ? 1 : -1
        ymult = (line.y1 < line.y2) ? 1 : -1
        [CartesianIndex(line.x1+i*xmult,line.y1+i*ymult) for i in 0:abs(line.x2-line.x1) ]
    end
end

collect(zip(1:4,1:4 ))
[(x,y) for x in 1:4, y in 1:4]

function mark!(grid, line)
    grid.grid[points(line)] .+= 1
end

dangerpoints(grid) = sum(x->x>1,grid.grid)

function part1()
    lines = parse.(Line, input)
    grid = Grid(maximum(maximum.(lines)))
    
    mark!.(Ref(grid),lines[isorthogonal.(lines)])
    dangerpoints(grid)    
end

function part2()
    lines = parse.(Line, input)
    grid = Grid(maximum(maximum.(lines)))
    
    mark!.(Ref(grid),lines)
    dangerpoints(grid)  
end

@show part1()
@show part2()
