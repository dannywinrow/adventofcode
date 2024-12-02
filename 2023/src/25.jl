include("../../helper.jl")

using Graphs

using Plots
using GraphRecipes

using Karnak
using NetworkLayout
using Colors


example = """jqt: rhn xhk nvd
rsh: frs pzl lsr
xhk: hfx
cmg: qnr nvd lhk bvb
rhn: xhk bvb hfx
bvb: xhk hfx
pzl: lsr hfx nvd
qnr: nvd
ntq: jqt hfx bvb xhk
nvd: lhk
lsr: lhk
rzs: qnr cmg lsr rsh
frs: qnr lhk lsr"""


function parsegraph(lines = loadlines())
    edgecol = []
    function parseline(line)
        e,fs = split(line,": ")
        for f in split(fs," ")
            push!(edgecol,(e,f))
        end
    end
    [parseline(line) for line in lines]

    vs = unique(vcat([e[1] for e in edgecol],[e[2] for e in edgecol]))
    vdict = Dict(vs .=> 1:length(vs))
    edgenums = [(vdict[e[1]],vdict[e[2]]) for e in edgecol]

    g = Graph(length(vs))
    for e in edgenums
        add_edge!(g,e)
    end
    g
end

g = parsegraph(parselines(example))
g = parsegraph()

k = []
j = 1
while j < 2
    k = karger_min_cut(g)
    j = count(==(2),k)
end
k

group = findall(==(1),k)
776*705

[(h,f) for h in group, f in filter(!in(group),1:nv(g))][findall(==(true),connections(g,group))]

k = normalized_cut(g, 0)

function connections(g,group)
    adjacency_matrix(g)[group,filter(!in(group),1:nv(g))]
end


externalneighbours()
gs =

groups = [collect(1:nv(g)÷2),collect(nv(g)÷2+1:nv(g))]
function connections(groups)
    neighbors
end

process(p)
if length(p[1]) > length(p[2])
argmin(length,first(ps))
argmax(length,[[1],[2]])

first(ps)
ps = partitions(1:3,2)
collect(ps)

graphplot(g)
@drawsvg begin
    background("black")
    sethue("grey40")
    fontsize(8)
    drawgraph(g, 
        layout=stress, 
        vertexlabels = 1:nv(g),
        vertexfillcolors = 
            [RGB(rand(3)/2...) 
               for i in 1:nv(g)]
    )
end 600 400