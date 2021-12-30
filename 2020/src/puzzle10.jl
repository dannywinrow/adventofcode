using CSV, DataFrames

input = read("2020\\inputs\\input10.txt",String);
input = split(input,"\r\n")
input = [parse(Int,i) for i in input]

values = sort(input)
pushfirst!(values,0)
push!(values,values[end]+3)
diffs = values[2:end] .- values[1:end-1] 
groups = []
val = 0
for i in eachindex(diffs)
    if diffs[i] == 1
        val += 1
    end
    if (diffs[i] == 3) && (val > 0)
        (val > 1) && push!(groups, val)
        val = 0
    end    
end
groups[groups .== 4] .= 7
groups[groups .== 3] .= 4

*(groups...)
groups


function part1()
    values = sort(input)
    pushfirst!(values,0)
    push!(values,values[end]+3)
    diffs = values[2:end] .- values[1:end-1] 
    ans = [(i, sum(x->x==i,diffs)) for i in unique(diffs)]
    return ans[1][2]*ans[2][2]      
end

function part2()    

end

@show part1();
@show part2();
