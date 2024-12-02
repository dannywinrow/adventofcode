using SimpleWeightedGraphs
using Graphs

include("../../helper.jl")

example = """#.#####################
#.......#########...###
#######.#########.#.###
###.....#.>.>.###.#.###
###v#####.#v#.###.#.###
###.>...#.#.#.....#...#
###v###.#.#.#########.#
###...#.#.#.......#...#
#####.#.#.#######.#.###
#.....#.#.#.......#...#
#.#####.#.#.#########v#
#.#...#...#...###...>.#
#.#.#v#######v###.###v#
#...#.>.#...>.>.#.###.#
#####v#.#.###v#.#.###.#
#.....#...#...#.#.#...#
#.#########.###.#.#.###
#...###...#...#...#.###
###.###.#.###v#####v###
#...#...#.#.>.>.#.>.###
#.###.###.#.###.#.#v###
#.....###...###...#...#
#####################.#"""

function solve(grid = loadgrid())

    function getdirs(ci)
        if !isnothing(findfirst(==(grid[ci]),arrows))
            return [directions[findfirst(==(grid[ci]),arrows)]]
        end
        filter(x-> (x+ci) in CartesianIndices(grid) && grid[x+ci]!='#',directions)
    end

    function edgesfrom(place)
        list = []
        for dir in getdirs(place)
            np = place + dir
            lp = place
            cnt = 1
            while np ∉ vertices
                p = filter(!=(lp),Ref(np) .+ getdirs(np))
                lp = np
                isempty(p) ? break : (np = p[1])
                cnt += 1
            end
            lp != np && push!(list,(place,np,cnt))
        end
        list
    end

    function paths(g,path,e)
        path[end] == e && return [path]
        ret = []
        for nv in neighbors(g,path[end])
            !in(nv,path) && append!(ret,paths(g,[path...,nv],e))
        end
        return ret
    end

    function pathlength(g,path)
        cnt = 0
        for x in zip(path[1:end-1],path[2:end])
            cnt += get_weight(wdg,x...)
        end
        cnt
    end

    entrance = CartesianIndex(1,findfirst(==('.'),grid[1,:]))
    exit = CartesianIndex(size(grid,1),findfirst(==('.'),grid[end,:]))

    vertices = [entrance,findall(ci->grid[ci] != '#' && length(getdirs(ci))>2,CartesianIndices(grid))...,exit]
    edgelist = vcat([edgesfrom(vertex) for vertex in vertices]...)

    vdict = Dict(vertices .=> eachindex(vertices))

    sources = [vdict[edge[1]] for edge in edgelist]
    destinations = [vdict[edge[2]] for edge in edgelist]
    weights = [edge[3] for edge in edgelist]
    wdg = SimpleWeightedDiGraph(sources,destinations,weights)

    maximum(pathlength.(Ref(wdg),paths(wdg,[1],length(vertices))))
end

pt1 = solve()
pt2 = solve(begin
            grid = loadgrid()
            [replace!(grid,arrow => '.') for arrow in arrows]
            grid
        end)

println("Part 1: $pt1")
println("Part 2: $pt2")