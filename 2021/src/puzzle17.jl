import Base.in
import Base.step

struct Target
    xmin
    xmax
    ymin
    ymax
end
struct Probe
    pos
    dir
end
struct Attempt
    target
    steps
    success
end
function step(p::Probe)
    pos = (p.pos[1] + p.dir[1], p.pos[2] + p.dir[2])
    dir = (max(p.dir[1]-1,0) , p.dir[2] - 1)
    Probe(pos,dir)
end

function in(p::Probe,t::Target)
    (t.xmin <= p.pos[1] <= t.xmax) &&
    (t.ymin <= p.pos[2] <= t.ymax)
end

overshot(p,t) = (p.pos[1] > t.xmax) || ((p.pos[2] < t.ymin) && (p.dir[2] < 0))
cantreach(p,t) = ((p.pos[1] < t.xmin) && ((p.pos[1] + ((p.dir[1]+1)*p.dir[1]/2)) < t.xmin))

function process(t,x,y;stephistory=true,info=false)
    p = Probe((0,0),(x,y))
    info && @info "start ($x,$y)"
    n = 1
    info && @info "Step $n:", p
    steps = []
    stephistory && append!(steps,[p])
    while !overshot(p,t) && !in(p,t)
       p = step(p)
       n = n + 1
       stephistory && append!(steps,[p])
       info && @info "Step $n:", p
    end
    stephistory || append!(steps,[p])
    Attempt(t,steps,in(p,t))
end

quadsolve(y) = (√(1 + 8y) - 1) / 2
 
function solveit(t)
    xmin = ceil(Int,quadsolve(t.xmin))
    attempts = [process(t,x,y) for x in xmin:t.xmax, y in t.ymin:-t.ymin]
    successes = filter(x->x.success,attempts)
    solutions = [(s.steps[1].dir,s.steps[end].pos) for s in successes]
    ymax = maximum([i[1][2] for i in solutions])
    maxheight = (ymax*(ymax+1)) ÷ 2
    @info t
    @info "Part 1: max height is $maxheight"
    @info "Part 2: $(length(solutions)) solutions"
end

example = Target(20,30,-10,-5)
input = Target(14,50,-267,-225)

solveit(example)
solveit(input)