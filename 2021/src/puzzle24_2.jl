
function process(registers,instruction)
    
end
function simplifyAPU(instructions,n = 0)
    digit = 1
    n == 0 && (n = length(instructions))
    registers = Dict{Char,Any}(['w'=>0,'x'=>0,'y'=>0,'z'=>0])
    for i in 1:n
        processinstruction(registers,instructions[i])
        instr = Symbol(instructions[i][1:3])
        reg = instructions[i][5]
        i += 1
        if instr == :inp
            registers[reg] = Symbol("i"*string(digit))
            digit += 1
            continue
        end
        num = instructions[i-1][7:end]
        if num[1] in 'w':'z'
            y = deepcopy(registers[num[1]])
        else
            y = parse(Int,num)
        end
        instr == :div && y == 1 && continue
        instr == :mul && y == 1 && continue
        instr == :add && y == 0 && continue
        x = deepcopy(registers[reg])
        registers[reg] = funcs[instr](x,y)
    end
    return registers
end

isnum(x) = tryparse(Int,x) !== nothing

input = read("2021\\inputs\\24.txt",String);
instructions = split(input,r"\r\n")
inputex = read("2021\\inputs\\24ex1.txt",String);
instructionsex = split(inputex,r"\r\n")

sa = simplifyAPU(instructions)
saex = simplifyAPU(instructionsex,15)
sa['z']
saex['z']