using CSV, DataFrames

input = read("2020\\inputs\\input4.txt", String);
input = split(input,"\r\n\r\n");
input = replace.(input,"\r\n"=>" ");
input = split.(input," ")

checks=[
  "byr"
  "iyr"
  "eyr"
  "hgt"
  "hcl"
  "ecl"
  "pid"
  "cid"
]

function part1()
    fieldsinput = [getindex.(i,Ref(1:3)) for i in input]
    sum([sum(in(i).(checks[1:7])) == 7 for i in fieldsinput])
end

function validatefield(field)
    field, entry = split(field,":")  
    return (
            (field == "byr") && occursin(r"^\d{4}$",entry) && (1920 <= parse(Int,entry) <= 2002)
            || (field == "iyr") && occursin(r"^\d{4}$",entry) && (2010 <= parse(Int,entry) <= 2020)
            || (field == "eyr") && occursin(r"^\d{4}$",entry) && (2020 <= parse(Int,entry) <= 2030)
            || (field == "hgt") && (
                 (entry[end-1:end] == "cm") && occursin(r"^\d{3}$",entry[1:end-2]) && (150 <= parse(Int,entry[1:end-2]) <= 193)
              || (entry[end-1:end] == "in") && occursin(r"^\d{2}$",entry[1:end-2]) && (59 <= parse(Int,entry[1:end-2]) <= 76)
            )
            || (field == "hcl") && occursin(r"^#[0-9,a-f]{6}$",entry)
            || (field == "ecl") && in(entry,["amb" "blu" "brn" "gry" "grn" "hzl" "oth"])
            || (field == "pid") && occursin(r"^[0-9]{9}$",entry)
    )
end

function part2()
  sum([sum(validatefield.(i)) == 7 for i in input])
end