using Colors, ImageShow
import Base.show

function getinput(file)
   input = read(file,String)
   input = replace(input,"#"=>"1")
   input = replace(input,"."=>"0")
   algo, img = split(input,r"\r\n\r\n")
   img = split(img,r"\r\n")
   img = split.(img,"")
   img = hcat(img...)
   img = parse.(Bool,img)
   Img(img',algo, false)
end

struct Img
   img
   algo
   infi
end

function imgenhance(img::Img)
   imgbord = fill(img.infi,size(img.img,1)+4,size(img.img,2)+4)
   imgbord[3:end-2,3:end-2]=img.img
   newimg = imgbord[2:end-1,2:end-1]
   for ci in CartesianIndices(newimg)
      x = imgbord[ci[1]:(ci[1]+2),ci[2]:(ci[2]+2)]
      newimg[ci] = parse(Bool,img.algo[parse(Int,"0b"*join(Int.([x'...])))+1])
   end
   infi = parse(Bool,img.algo[img.infi*0b111111111+1])
   Img(newimg,img.algo,infi)
end

function Base.show(io::IO, img::Img)
   Gray.(img.img)
end
Base.show(io::IO, ::MIME"text/plain", img::Img) = print(io, "Image:\n", img)

function solveit(file)
   img = getinput(file)
   img = imgenhance(img)
   img = imgenhance(img)
   part1 = sum(img.img)
   for _ in 1:48
      img = imgenhance(img)
   end
   part2 = sum(img.img)
   println("$file solution:")
   println("Part 1: $part1 on pixels after 2 enhances")
   println("Part 2: $part2 on pixels after 50 enhances")
   println("")
end

file = "2021\\inputs\\input20test.txt"
solveit("2021\\inputs\\input20test.txt")
solveit("2021\\inputs\\input20.txt")

