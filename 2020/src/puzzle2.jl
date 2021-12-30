using CSV, DataFrames

input = read("2020\\inputs\\input2.txt", String);
input = replace(input,":"=>"");
input = replace(input,"-"=>" ");
io = IOBuffer(input)
input = CSV.read(io,DataFrame,header=[:min,:max,:ch,:pass])

function f()
  input[:,:passred] .= replace.(input.pass, input.ch .=> "")
  input[:,:cntch] .= length.(input.pass) .- length.(input.passred)
  input[:,:success] .= input.min .<= input.cntch .<= input.max
  sum(input.success)
end

x=[]
y=[]
function s()
  x = getindex.(input.pass,input.min) .== getindex.(input.ch,1)
  y = getindex.(input.pass,input.max) .== getindex.(input.ch,1)
  z = x .+ y
  sum(z .== 1)

end
s()
