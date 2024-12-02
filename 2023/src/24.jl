include("../../helper.jl")

lines = loadlines()
function parseline(line)
    p,v = split(line," @ ")
    p = parse.(Int,split(p,", "))
    v = parse.(Int,split(v,", "))
    p,v
end

# Hailstone paths on x and y axis
function solveeqxy((p1,v1),(p2,v2))
    eq1 = [v1[1],-v2[1],p2[1]-p1[1]]
    eq2 = [v1[2],-v2[2],p2[2]-p1[2]]
    l = lcm(v1[1],v1[2])
    s2 = eq1 .* (l ÷ v1[1]) .- eq2 .* (l ÷ v1[2])
    if s2[2] != 0
        y = s2[3] / s2[2]
        if  y > 0
            x = (eq1[3]-eq1[2]*y) / eq1[1]
            x >= 0 && return (v1[1]3*x+p1[1],v1[2]*x+p1[2])
        end
    end
    nothing
end
f 
eqs = parseline.(lines)

sols = []
for x in 1:length(eqs)-1
    for y in x+1:length(eqs)
        sol = solveeqxy(eqs[x],eqs[y])
        !isnothing(sol) && push!(sols,sol)
    end
end
sols
count(x->inspace(x[1]) && inspace(x[2]),sols)

inspace(x) = 200000000000000 <= x <= 400000000000000

q + w * y = p + v * y

function divides(ci1::CartesianIndex,ci2::CartesianIndex)
    t = Tuple(ci1) ./ Tuple(ci2)
    all(t .== t[1]) && t

end
divides(CartesianIndex(12,12,12),CartesianIndex(4,4,4))

gcm(CartesianIndex(6,12,18))
gcm(ci::CartesianIndex) = 

q-p1 = (v1-w) * t1
q-p2 = (v2-w) * t2
q-p3 = (v3-w) * t3

x1 = p1x + v1x * t1 = qx + wx * t1
y1 = p1y + v1y * t1 = qy + wy * t1
z1 = p1z + v1z * t1 = qz + wz * t1

x2 = p2x + v2x * t2 = qx + wx * t2
y2 = p2y + v2y * t2 = qy + wy * t2
z2 = p2z + v2z * t2 = qz + wz * t2

x3 = p3x + v3x * t3 = qx + wx * t3
y3 = p3y + v3y * t3 = qy + wy * t3
z3 = p3z + v3z * t3 = qz + wz * t3

x3 = p3x + v3x * t3 = qx + wx * t3
y3 = p3y + v3y * t3 = qy + wy * t3
z3 = p3z + v3z * t3 = qz + wz * t3

eqs

function ploteq!(p,eq)
    q = hcat(eq[1],eq[1]+1e15 / qlen(eq[2]) * eq[2])
    plot!(p,q[1,:],q[2,:],q[3,:])
end

using LinearAlgebra
norm([2,3,4])

p = ploteq!(plot(),eqs[1])
ploteq!(p,eqs[2])
ploteq!(p,eqs[3])
ploteq!(p,eqs[4])
ploteq!(p,eqs[5])
ploteq!(p,eqs[6])

p = plot();
for i in 1:10
    ploteq!(p,eqs[i])
end
p

using Plots

scatter((eq[1]./2e14)...)

Vector.(eqs[1][1]./2e14)
x = plot()
arrow
2e14