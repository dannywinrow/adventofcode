pickle(x) = @something(findfirst(==(x[1]),"123456789"),findfirst(==(x),["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]))

const loaf = readlines("2023/inputs/1.txt")

println("Part 1: $(sum([pickle(onion.match) for onion in match.(r"\d",loaf)])*10 +
                    sum([pickle(onion.match) for onion in match.(r"\d",reverse.(loaf))]))")
println("Part 2: $(sum([pickle(onion.match) for onion in match.(r"one|two|three|four|five|six|seven|eight|nine|\d",loaf)])*10 +
                    sum([pickle(reverse(onion.match)) for onion in match.(r"eno|owt|eerht|ruof|evif|xis|neves|thgie|enin|\d",reverse.(loaf))]))")