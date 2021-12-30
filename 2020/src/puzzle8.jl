using CSV, DataFrames

input = read("2020\\inputs\\input8.txt",String);
input = split(input,"\r\n")
input = split.(input," ")

instructions = [i[1] for i in input]
values = [parse(Int,i[2]) for i in input]

function runprog(instructions, values)
    @assert length(instructions) == length(values)
    firstvisit = falses(length(instructions))
    val = 0
    i = 1
    succ = false
    while i <= length(instructions) && firstvisit[i] == false
        firstvisit[i] = true
        if instructions[i] == "nop"
            i += 1
        elseif instructions[i] == "acc"
            val += values[i]
            i += 1
        elseif instructions[i] == "jmp"
            i += values[i]
        end
    end
    if i == length(instructions) + 1
        succ = true
    elseif i > length(instructions)
    end
    succ, val
end

swap(x) = x == "jmp" ? "nop" : "jmp"

function getinstswap(i)
    tryinst = copy(instructions)
    tryinst[candidates[i]] = swap(tryinst[candidates[i]])
    tryinst
end

function part1()
    runprog(instructions, values)
end

function part2()    
    val = 0
    candidates = [i for i in 1:length(instructions)][in(["jmp","nop"]).(instructions)]
    i = 1
    succ = false
    while succ == false
        succ, val = runprog(getinstswap(candidates[i]),values)
        i += 1
    end
    val
end

@show part1()
@show part2()
