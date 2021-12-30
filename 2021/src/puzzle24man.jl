
function solveit()
    input = read("2021\\inputs\\24.txt",String);
    instructions = split(input,r"\r\n")

    #We take advantage of the instructions being the same after each input, with 3 variables
    instructions = reshape(instructions,(:,14))
    instructions = instructions[[!all(row[1] .== row) for row in eachrow(instructions)],:]
    instructions = [parse(Int,i[7:end]) for i in instructions]

    stack = []
    conditions = []
    for (i, col) in enumerate(eachcol(instructions))
        popit, x, y = col
        if length(stack) == 0
            popit = true
            pushit = true
        else
            diff = instructions[3,stack[end]] + x
            pushit = abs(diff) > 8
            !pushit && push!(conditions,(i, stack[end],diff))
        end
        popit == 26 && pop!(stack)
        pushit && push!(stack,i)
    end

    #Here we take advantage of the fact that all the conditions are distinct pairs of numbers
    mins = zeros(Int,14)
    maxs = zeros(Int,14)

    for cond in conditions
        x, y, diff = cond
        if diff > 0
            maxs[x] = 9
            maxs[y] = 9 - diff
            mins[x] = 1 + diff
            mins[y] = 1
        else
            maxs[x] = 9 + diff
            maxs[y] = 9
            mins[x] = 1
            mins[y] = 1 - diff
        end
    end

    @info "Maximum = $(join(maxs))"
    @info "Minimum = $(join(mins))"
end

@time solveit()