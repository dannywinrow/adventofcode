eql(x,y) = x==y ? 1 : [:eql,x,y]
eql(x::Int,y::Int) = Int(x==y)
eql(x::Symbol,y::Int) = y>9 ? 0 : [:eql,x,y]
eql(x::Int,y::Symbol) = eql(y,x)
eql(x::Int,y::Vector) = eql(y,x)
function eql(x::Vector,y)
    x[1] in [:add,:mult] && (mx(x) < mn(y) || mn(x) > mx(y)) && return 0
    return [:eql,x,y]
end
add(x,y) = [:add,x,y]
add(x::Int,y::Int) = x+y
add(x::Int,y) = add(y,x)
add(x,y::Int) = y==0 ? x : [:add,x,y]
add(x::Vector,y::Int) = y==0 ? x : ((x[1] == :add && typeof(x[3]) <: Int) ? [:add,x[2],x[3]+y] : [:add,x,y])
function add(x::Vector,y::Vector)
    if x[1] == :add && typeof(x[3]) <: Int
        if y[1] == :add && typeof(y[3]) <: Int
            return [:add,add(x[2],y[2]),x[3]+y[3]]
        end
    else
        return [:add,x,y]
    end
end
mul(x,y) = y==1 ? x : (y==0 ? 0::Int : [:mul,x,y])
mul(x::Int,y::Int) = x*y
mul(x::Int,y::Vector) = mul(y,x)
function mul(x::Vector,y::Int)
    y==0 && return 0
    x[1] == :add && return add(mul(x[2],y),mul(x[3],y))
    x[1] == :mul && return mul(x[2],mul(x[3],y))
    [:mul,x,y]
end
dv(x,y) = [:div,x,y]
dv(x::Int,y::Int) = x÷y
function dv(x::Vector,y::Int)
    x==:mult && y == x[3] && return 0
    [:div,x,y]
end
md(x,y) = y==1 ? 0 : [:mod,x,y]
md(x::Int,y::Int) = x%y
function md(x::Vector,y::Int)
    mx(x) < y && return x
    if x[1] == :add || x[1] == :mul
        doit = false
        z = md(x[2],y)
        z != [:mod,x[2],y] && z!= x[2] && (x[2]=z;doit=true)
        g = md(x[3],y)
        g != [:mod,x[3],y] && g!= x[3] && (x[3]=g;doit=true)
        return doit ? md(funcs[x[1]](z,g),y) : [:mod,x,y]
    end
    x[1] == :eql && return x
    [:mod,x,y]
end
md(x::Symbol,y::Int) = y>9 ? x : [:mod,x,y]

mx(x::Symbol) = 9
function mx(x::Vector)
    ins, y, z = x
    ins==:eql && return 1
    ins in [:add,:mult] && funcs[ins](mx(y),mx(z))
    ins==:div && return funcs[ins](mx(y),mn(z))
    ins==:mod && (mx(y) >= z ? z-1 : mx(y))
end
mx(x) = x
mn(x::Symbol) = 1
function mn(x::Vector)
    ins, y, z = x
    ins==:eql && return 0
    ins in [:add,:mult] && funcs[ins](mn(y),mn(z))
    ins==:div && return funcs[ins](mn(y),mx(z))
    ins==:mod && (mx(y) >= z ? 0 : mx(y))
end
mn(x) = x

funcs = Dict([:div=>dv,:mod=>md,:add=>add,:mul=>mul,:eql=>eql])
prefix = ""
function APU(i,registers)
    funcs = Dict([:div=>÷,:mod=>%,:add=>+,:mul=>*,:eql=>==])
    function inp(ch)
        digit =9
        while true
            registers[ch] = digit
            x = APU(i,copy(registers))
            x!=0 && return string(digit)*x
            digit != 1 ? digit -= 1 : (prefix = prefix[1:end-1]; return 0)
            @show prefix*digit
        end
    end
    while i ≤ length(instructions)
        instr = Symbol(instructions[i][1:3])
        reg = instructions[i][5]
        i += 1
        instr == :inp && return inp(reg)
        num = instructions[i-1][7:end]
        if num[1] in 'w':'z'
            num = registers[num[1]]
        else
            num = parse(Int,num)
        end
        instr == :div && num == 0 && return 0
        instr == :mod && num <= 0 && return 0
        registers[reg] = funcs[instr](registers[reg],num)
    end
    return registers['z'] == 0 ? "" : 0
end

function simplifyAPU(instructions,n = 0)
    digit = 1
    n == 0 && (n = length(instructions))
    registers = Dict{Char,Any}(['w'=>0,'x'=>0,'y'=>0,'z'=>0])
    for i in 1:n
        instruction = instructions[i]
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
registers = Dict{Char,Any}(['w'=>0,'x'=>0,'y'=>0,'z'=>0])
APU(1,registers)
sa = simplifyAPU(instructions)
saex = simplifyAPU(instructionsex,15)
sa['z']
saex['z']


