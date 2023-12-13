include("../../helper.jl")

# Recreating Jonathan Paulson's solution

function parseline(line)
    dots,blocks = split(line," ")
    blocks = [parse(Int,x) for x in split(blocks,",")]
    dots,blocks
end

function solve(dots,blocks)
    DP = Dict()
    function f(i,bi,current)
        key = (i,bi,current)
        haskey(DP,key) && return DP[key]
        if i > length(dots)
            bi == length(blocks)+1 && current==0 && return 1
            return bi == length(blocks) && current==blocks[bi]
        end
        ans = 0
        for c in ['.', '#']
            if dots[i]==c || dots[i]=='?'
                if c=='.' && current==0
                    ans += f(i+1, bi, 0)
                elseif c=='.' && current>0 && bi<=length(blocks) && blocks[bi]==current
                    ans += f(i+1, bi+1, 0)
                elseif c=='#'
                    ans += f(i+1, bi, current+1)
                end
            end
        end
        DP[key] = ans
    end
    f(1,1,0)
end

lines = parseline.(loadlines())
pt1 = sum([solve(line...) for line in lines])
pt2 = sum([solve(join(fill(line[1],5),"?"),repeat(line[2],5)) for line in lines])