


function nextinput!(input)
    righties = (input .== '>') .& (input[:,[2:end...,1]] .== '.')
    input[righties] .= '.'
    input[righties[:,[end,1:end-1...]]] .= '>'
    downies = (input .== 'v') .& (input[[2:end...,1],:] .== '.')
    input[downies] .= '.'
    input[downies[[end,1:end-1...],:]] .= 'v'
    input
end

input = read("2021\\inputs\\25.txt",String);
input = split(input,"\r\n")
input = [i[j] for i in input, j in 1:length(input[1])]

i = 1
ni = copy(input)
ni = nextinput!(ni)
history = []
while ni != input
    input = copy(ni)
    nextinput!(ni)
    i += 1
    #push!(history,input)
end
i
