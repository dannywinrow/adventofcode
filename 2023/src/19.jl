include("../../helper.jl")

example = """px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}"""

workflows,parts = splitvect(loadlines(),"")

import Base.cp, Base.in

A(x,m,a,s) = +(x,m,a,s)
RR(x,m,a,s) = 0

function parseworkflow(workflow)
    workflow = replace(workflow,","=>"\n    ")
    workflow = replace(workflow,"R"=>"RR")
    workflow = replace(workflow,r"(\w+){"=>s"function \1(x,m,a,s)\n    ")
    workflow = replace(workflow,r":(\w+)"=>s" && return \1(x,m,a,s)")
    workflow = replace(workflow,r"(\w+)}"=>s"\1(x,m,a,s)\nend")
end
eval.(Meta.parse.(parseworkflow.(workflows)))

function parsepart(part)
    @info part
    x,m,a,s = parse.(Int,match(r"=(\d+).+=(\d+).+=(\d+).+=(\d+)",part).captures)
    in(x,m,a,s)
end
pt1 = sum(parsepart.(parts))


# PART 2
function parseworkflow(workflow)
    name, tests = match(r"(\w+)\{(.+)\}",workflow).captures
    tests = split(tests,",")
    tests = [match(r"(?:([xmas])([<>])(\d+):)?(\w+)",test).captures for test in tests]
    for i in length(tests)-1:-1:1
        if tests[i][end] == tests[end][end]
            deleteat!(tests,i)
        else
            break
        end
    end
    name => tests
end
workflowpairs = Dict(parseworkflow.(workflows))

counter(wf,rng) = testrange(1,rng,workflowpairs[wf])
function testrange(i,rng,tests)
    var,op,num,ret = tests[i]
    if isnothing(op)
        cnt(rng,ret)
    else
        rt,rf = splitrange(rng,var,op,num)
        return cnt(rt,ret) + testrange(i+1,rf,tests)
    end
end
function splitrange(r,v,o,num)
    v = findfirst(==(v[1]),"xmas")
    num = parse(Int,num)
    #@info r,v,o,num
    rt = copy(r)
    rf = copy(r)
    if o == ">"
        rt[v] = max(num+1,r[v][1]):r[v][end]
        rf[v] = r[v][1]:min(num,r[v][end])
    else
        rt[v] = r[v][1]:min(num-1,r[v][end])
        rf[v] = max(num,r[v][1]):r[v][end]
    end
    rt,rf
end
function cnt(rng,ret)
    if ret == "R"
        return 0
    elseif ret == "A"
        return *(length.(rng)...)
    else
        return counter(ret,rng)
    end
end
pt2 = counter("in",fill(1:4000,4))

println("Part 1: $pt1")
println("Part 2: $pt2")