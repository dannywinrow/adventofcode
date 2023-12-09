include("../../helper.jl")

function solveit()
    lines = loadlines()
    dirs = lines[1]
    maps = Dict(m[1] => split(m[2][2:end-1],", ") for m in split.(lines[3:end]," = "))
    place = "AAA"
    cnt = 0
    while place != "ZZZ"
        place = maps[place][dirs[(cnt % length(dirs))+1] == 'R' ? 2 : 1]
        cnt += 1   
    end
    cnt
end

pt1 = solveit()

function endreached(places)
    lasts = unique([p[3] for p in places])
    @info lasts
    length(lasts) == 1 && lasts[1] == 'Z'
end

function loopedfrom(visited,len)
    vs = findall(==(visited[end]),visited[1:end-1])
    pos = findfirst(==(0),(length(visited) .- vs) .% len)
    isnothing(pos) ? 0 : vs[pos]
end

function solveit2()
    lines = loadlines()
    dirs = lines[1]
    maps = Dict(m[1] => split(m[2][2:end-1],", ") for m in split.(lines[3:end]," = "))
    
    move(place,cnt) = maps[place][dirs[(cnt % length(dirs))+1] == 'R' ? 2 : 1]

    function findperiod(place)
        visited = [place]
        cnt = 0
        while loopedfrom(visited,length(dirs)) == 0
            push!(visited,move(visited[end],cnt))
            cnt += 1
        end
        firstloop = loopedfrom(visited,length(dirs))
        looplength = (length(visited)-firstloop) ÷ length(dirs)
        inloop = findall(x->x[3]=='Z',visited[firstloop:end])
        beforeloop = findall(x->x[3]=='Z',visited[1:firstloop])
        firstloop, looplength, inloop, beforeloop
    end

    places = filter(x->x[3]=='A',collect(keys(maps)))
    periods = findperiod.(places)

    # Using knowledge that only one z is found for each a for my input
    p(period) = (period[3][1] + period[1] - 1,period[2]*length(dirs))
    periods = p.(periods)
    
    # Using knowledge that the steps to the first z is equal to the loop length for my input
    # This step shortcuts, I think there's a way we can make this assumption
    # without seeing the input, but I'm not sure of the reasoning.
    #return lcm(getindex.(periods,2))
    
    lcm(periods[1][2],periods[2][2])
    p1 = periods[1]; p2 = periods[2]
    lcp(periods[1],periods[2])

    p1 = periods[1]
    for p2 in periods[2:end]
        #@info p1
        p1 = lcp(p1,p2)
    end
    p1[1]-1
end

function lcp(p1,p2)
    step(p,z) = p[1] + z*p[2]
    x = 0
    y = 0
    m = step(p1,x)
    n = step(p2,y)
    while m != n
        if m > n
            y+=1
            n = step(p2,y)
        else
            x+=1
            m = step(p1,x)
        end
    end
    step(p1,x),lcm(p1[2],p2[2])
end

pt2 = solveit2()

println("Part 1: $pt1")
println("Part 2: $pt2")