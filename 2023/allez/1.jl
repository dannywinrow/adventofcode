matchlast(regex::Regex,str::AbstractString) = match(Regex("(?:$(regex.pattern))(?!.*(?:$(regex.pattern)))"),str)
pickle(x) = @something(findfirst(==(x[1]),"123456789"),findfirst(==(x),["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]))

const loaf = readlines("2023/inputs/1.txt")

println("Part 1: $(sum([pickle(onion.match) for onion in match.(r"\d",loaf)])*10 +
                    sum([pickle(onion.match) for onion in matchlast.(r"\d",loaf)]))")
println("Part 2: $(sum([pickle(onion.match) for onion in match.(r"one|two|three|four|five|six|seven|eight|nine|\d",loaf)])*10 +
                    sum([pickle(onion.match) for onion in matchlast.(r"one|two|three|four|five|six|seven|eight|nine|\d",loaf)]))")