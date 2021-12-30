using CSV, DataFrames
import Base.parse
import Base.show

input = read("2021\\inputs\\input4.txt",String);
input = split(input,"\r\n\r\n")

struct BingoCard
    card 
    state
    dim
    BingoCard() = BingoCard(5)
    BingoCard(num::Int) = new(zeros(Int,num,num),falses(num,num),num)
    BingoCard(card) = new(card,falses(size(card)[1],size(card)[2]),size(card)[1])
end


function Base.parse(BingoCard, str)
    v = split.(strip.(split(replace(str,"  "=>" "),"\r\n"))," ",)
    card = reshape(parse.(Int,vcat(v...)),5,5)
    BingoCard(card)
end

function Base.show(io::IO, card::BingoCard)
    print(io, "\n")
    for i in eachindex(card.card)
        num = card.card[i]
        if card.state[i]
            printstyled(io,lpad(num, 3," "),color=:red)
        else
            print(io,lpad(num, 3," "))
        end
        if (i % card.dim) == 0
            print(io, "\n")
        end
    end
end
Base.show(io::IO, ::MIME"text/plain", card::BingoCard) = print(io, "Bingo Card:\n", card)

function mark(card,num)
    ind = findfirst(x->x==num,card.card)
    if !isnothing(ind)
        card.state[ind] = true
    end
end

function checkwin(card)
    rows = [all(row) for row in eachrow(card.state)]
    cols = [all(col) for col in eachcol(card.state)]
    succ = hcat(rows,cols)
    any(succ), findall(succ)
end

function sumunmarked(card)
    sum(card.card[findall(x->x==false, card.state)])
end




function part1()

    
numberscalled = parse.(Int,split(input[1],","))
bingocards = parse.(BingoCard,input[2:end])


    ans = 0
    for n in numberscalled
        mark.(bingocards,n)
        wins = checkwin.(bingocards)
        x = findfirst([i[1] for i in wins])
        if !isnothing(x)
            ans = sumunmarked(bingocards[x]) * n
            show(bingocards[x])
            @info x
            @info "ans", ans
            break
        end
    end
    ans
end


numberscalled = parse.(Int,split(input[1],","))
bingocards = parse.(BingoCard,input[2:end])



    ans = 0
    winstate = falses(length(bingocards))
    for n in numberscalled
        mark.(bingocards,n)
        wins = checkwin.(bingocards)
        if all([i[1] for i in wins])
            x = findfirst(x->x==false,winstate)
            ans = sumunmarked(bingocards[x]) * n
            show(bingocards[x])
            @info "winstate", winstate
            @info x
            @info "ans", ans
            break
        else
            winstate = [i[1] for i in wins]
        end
    end
    ans
[mark.(bingocards,numberscalled[i]) for i in 1:70]

bingocards[48]

part2()
@show part1()
@show part2()
