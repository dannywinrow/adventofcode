include("../../helper.jl")

function parseinput()
    input = getinput()
    rules,updates = split.(split(input,"\n\n"),"\n")
    rules = [parse.(Int,x) for x in split.(rules,"|")]
    updates = [parse.(Int,x) for x in split.(updates,",")]
    rules, updates
end

function checkcorrect(update,rules)
    valid = true
    for r in rules
        b,a = r
        bf = findfirst(==(b),update)
        if !isnothing(bf)
            af = findfirst(==(a),update)
            if !isnothing(af)
                valid = valid && bf < af
                if !valid
                    return update,r
                end
            end
        end
    end
    valid
end

function getmiddle(arr)
    arr[(length(arr)+1) ÷ 2]
end

function solveit()
    rules, updates = parseinput()
    sum(getmiddle.(filter(u->checkcorrect(u,rules),updates)))
end

pt1 = solveit()
clipboard(pt1)
submitanswer(1,pt1)

function correct(update,rules)
    nu = copy(update)
    valid = false
    usedrules = filter(x->length(intersect(x,nu)) == 2,rules)
    while valid == false
        valid = true
        for r in usedrules
            b,a = r
            bf = findfirst(==(b),nu)
            af = findfirst(==(a),nu)
            if af < bf
                deleteat!(nu,af)
                insert!(nu,bf,a)
                valid = false
            end
        end
    end
    nu
end

function solveit2()
    rules,updates = parseinput()
    tocorrect = filter(u->!checkcorrect(u,rules),updates)
    corr = correct.(tocorrect,Ref(rules))
    sum(getmiddle.(corr))
end

pt2 = solveit2()
clipboard(pt2)
submitanswer(2,pt2)