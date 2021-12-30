using CSV, DataFrames

input = CSV.read("inputs\\input2.txt", delim=" ", header=[:direction,:move], DataFrame)

function first()
    depth = 0
    horiz = 0
    for row in eachrow(input)
        if row[:direction] == "forward"
            horiz += row[:move]
        elseif row[:direction] == "up"
            depth -= row[:move]
        elseif row[:direction] == "down"
            depth += row[:move]
        end
    end
    depth*horiz
end
first()

function second()
    aim = 0
    depth = 0
    horiz = 0
    for row in eachrow(input)
        if row[:direction] == "forward"
            horiz += row[:move]
            depth += aim*row[:move]
        elseif row[:direction] == "up"
            aim -= row[:move]
        elseif row[:direction] == "down"
            aim += row[:move]
        end
    end
    depth*horiz
end
second()