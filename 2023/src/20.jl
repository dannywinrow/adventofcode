include("../../helper.jl")

@enum Pulse high low

abstract type AbstractModule end
mutable struct Flipflop <: AbstractModule
    name
    on
    dests
end
Flipflop(name,dests) = Flipflop(name,false,dests)
mutable struct Conjunction <: AbstractModule
    name
    inputs
    dests
end
mutable struct Broadcaster <: AbstractModule
    name
    dests
end
Conjunction(name,dests) = Conjunction(name,Dict{AbstractString,Pulse}(),dests)


function pulse(m::Flipflop,p::Pulse,n)
    if p == low
        m.on = !m.on
        s = m.on ? high : low
        for d in m.dests
            push!(stack,(d,s,m.name))
        end
    end
end
function pulse(m::Conjunction,p::Pulse,n)
    m.inputs[n] = p
    s = all(values(m.inputs) .== high) ? low : high
    for d in m.dests
        push!(stack,(d,s,m.name))
    end  
end
function pulse(m::Broadcaster,p::Pulse,n)
    s = p
    for d in m.dests
        push!(stack,(d,s,m.name))
    end
end

function buildmodules(line)
    switch, dests = line
    #@info switch,dests
    if switch[1] == 'b'
        modules["broadcaster"] = Broadcaster("broadcaster",dests)
    elseif switch[1] == '%'
        modules[switch[2:end]] = Flipflop(switch[2:end],dests)
    elseif switch[1] == '&'
        modules[switch[2:end]] = Conjunction(switch[2:end],dests)
    end
end
function resetmodules()
    for key in keys(modules)
        m = modules[key]
        typeof(m) == Flipflop && (m.on = false)
        for d in m.dests
            if haskey(modules,d) && typeof(modules[d]) == Conjunction
                modules[d].inputs[m.name] = low
            end
        end
    end
end

function setup(lines)
    lines = split(lines,"\n")
    lines = split.(lines," -> ")
    lines = [[line[1],split(line[2],", ")] for line in lines]
    global modules = Dict{AbstractString,AbstractModule}()
    buildmodules.(lines)
    resetmodules()
end

function solve(input)
    setup(input)
    highcnt = 0
    lowcnt = 0
    for _ in 1:1000
        global stack = [("broadcaster",low,"button")]
        while !isempty(stack)
            d,p,n = popfirst!(stack)
            #@info "$n -$p-> $d"
            p == high ? (highcnt += 1) : (lowcnt += 1)
            haskey(modules,d) && pulse(modules[d],p,n)
        end
    end
    highcnt*lowcnt,lowcnt,highcnt
end

solve(getinput())


function giveinfo(d,p,n)
    t = ""
    if haskey(modules,n)
        m = typeof(modules[n])
        if m == Conjunction
            t = "&"
        elseif m == Flipflop
            t = "%"
        end
    end
    @info "$t$n -$p-> $d"
end

function printstate(m::Conjunction)
    println("$(m.name)-$(m.inputs), ")
end
function printstate(m::Broadcaster)
end
function printstate(m::Flipflop)
    println("$(m.name)-$(m.on), ")
end
function printstate()
    for m in modules
        printstate(m[2])
    end
end

function solve2(input)
    setup(input)
    i = 0
    reps = Dict()
    while true
        global stack = [("broadcaster",low,"button")]
        i += 1
        while !isempty(stack)
            d,p,n = popfirst!(stack)
            d == "rx" && p == low && break
            haskey(modules,d) && pulse(modules[d],p,n)
            if d == "th" && p == high
                get!(reps,n,i)
                # Attempted to solve this way without being able to prove it works
                length(reps) == 4 && return lcm(values(reps)...)
                @info "buttonpress $i"
                @info printstate(modules["th"])
            end
        end
    end
    i
end

solve2(getinput())

# Way to visualise the inputs
using Graphs
function getgraph()
    g = SimpleDiGraph()
    mods = collect(values(modules))
    add_vertices!(g,length(mods))
    for (i,m) in enumerate(mods)
        for d in m.dests
            ff = findfirst(m->m.name==d,mods)
            if isnothing(ff)
                @info "adding $d"
                add_vertex!(g)
                add_edge!(g,i,nv(g))
            else
                add_edge!(g,i,ff)
            end

        end
    end
    g
end
g = getgraph()

names = replace(vcat(getfield.(mods,:name),["rx"]),
"broadcaster"=>"BR")
types = typeof.(mods)
typetocolor = Dict(Broadcaster=>3,Flipflop=>1,Conjunction=>2)
nodecolors = vcat([typetocolor[type] for type in types],[4])

using Plots, GraphRecipes

default(size=(1500, 1500))
graphplot(g,
    names = names,
    nodeshape = :circle,
    nodesize = 0.05,
    nodecolor = nodecolors,
    fontsize = 15
)

example = """broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a"""

example2 = """broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output"""

setup(example)
setup(example2)