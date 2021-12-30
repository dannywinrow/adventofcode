using CSV, DataFrames

input = read("2020\\inputs\\input5.txt",String);
input = split(input,"\r\n")
input = replace.(input,"F"=>"0")
input = replace.(input,"B"=>"1")
input = replace.(input,"R"=>"1")
input = replace.(input,"L"=>"0")

rows = parse.(Int,[i[1:7] for i in input];base=2)
seats = parse.(Int,[i[8:10] for i in input];base=2)
seatids = sort(rows .* 8 .+ seats)


function part1(input)
    seatids[end]
end

function part2(input)    
    seatids[2:end][seatids[1:end-1] .!= (seatids[2:end] .- 1)][1] - 1
end

@show part1(input)
@show part2(input)
