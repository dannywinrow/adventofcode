include("../../helper.jl")

function solveit()
    lines = loadlines()
    reports = [parse.(Int,x) for x in split.(lines, " ")]
    count(issafe,reports)
end

function issafe(report)
    diffs = report[2:end] .- report[1:end-1]
    all(3 .>= diffs .> 0) || all(0 .> diffs .>= -3) 
end

function issaferem(report)
    issafe(report) && return true
    for i in 1:length(report)
        rep = deleteat!(copy(report),i)
        issafe(rep) && return true
    end
    return false
end

pt1 = solveit()

submitanswer(1,pt1)

function solveit2()
    lines = loadlines()
    reports = [parse.(Int,x) for x in split.(lines, " ")]
    count(issaferem,reports)
end

pt2 = solveit2()
clipboard(pt2)
submitanswer(2,pt2)


# For Reddit (no helper use)

    lines = readlines("2024/inputs/2p1.txt")
    reports = [parse.(Int,line) for line in split.(lines, " ")]

    function issafe(report)
        diffs = diff(report)
        all(3 .>= diffs .> 0) || all(0 .> diffs .>= -3) 
    end

    pt1answer = count(issafe,reports)

    function issaferem(report)
        issafe(report) && return true
        for i in 1:length(report)
            rep = deleteat!(copy(report),i)
            issafe(rep) && return true
        end
        return false
    end

    pt2answer = count(issaferem,reports)