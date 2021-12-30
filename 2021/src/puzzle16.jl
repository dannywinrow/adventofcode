import Base.parse

function parse(BitVector,str)
    len = length(str) * 4
    dim = (len ÷ 64) + 1
    res = BitVector(undef, len)
    n = 1
    while length(str) > 16
        res.chunks[n] = parse(UInt64,"0x"*str[end-15:end])%UInt64 
        str = str[1:end-16]
        n += 1
    end
    if length(str) > 0
        res.chunks[n] = parse(UInt64,"0x"*str)%UInt64
    end
    res
end

struct Packet
    version
    type
    contents
end

getPacket(str::String) = getPacket(parse(BitVector,str))

function getPacket(bv::BitVector)
    version = sum([pop!(bv)*2^(3-n) for n in 1:3])
    type = sum([pop!(bv)*2^(3-n) for n in 1:3])
    if type == 4
        cont = true
        num = 0
        while cont
            cont = pop!(bv)
            num = sum([pop!(bv)*2^(4-n) for n in 1:4]) + num * 16
        end
        contents = [num]
    else
        lengthtype = pop!(bv)
        contents = []
        if !lengthtype
            L = sum([pop!(bv)*2^(15-n) for n in 1:15])
            while L > 0
                len = length(bv)
                pkg, bv = getPacket(bv)
                append!(contents,[pkg])
                L -= len - length(bv)
            end
        else
            N = sum([pop!(bv)*2^(11-n) for n in 1:11])
            while N > 0
                pkg, bv = getPacket(bv)
                append!(contents,[pkg])
                N -= 1
            end
        end
    end
    Packet(version,type,contents), bv
end

function getVersions(pkg)
    versions = [pkg.version]
    if typeof(pkg.contents[1]) == Packet
        append!(versions,getVersions.(pkg.contents)...)
    end
    versions
end

evalu(i) = i
function evalu(pkg::Packet)
    if pkg.type == 4
        pkg.contents[1]
    else
        fs = [sum,prod,minimum,maximum,x->x,>,<,==]
        f = fs[pkg.type + 1]
        if pkg.type >= 5
            Int(f(evalu.(pkg.contents)...))
        else
            Int(f(evalu.(pkg.contents)))
        end
    end
end

function solveit(input)
    pkg, bv = getPacket(input)
    @info "input = $input"
    @info "Part 1: versionsum = $(sum(getVersions(pkg)))"
    @info "Part 2: evaluation = $(evalu(pkg))"
end

examples = [
    "D2FE28"
    "38006F45291200"
    "EE00D40C823060"
    "8A004A801A8002F478"
    "620080001611562C8802118E34"
    "C0015000016115A2E0802F182340"
    "A0016C880162017C3686B18A3D4780"
    ];

solveit.(examples);

examples2 = [
    "C200B40A82"
    "04005AC33890"
    "880086C3E88112"
    "CE00C43D881120"
    "D8005AC2A8F0"
    "F600BC2D8F"
    "9C005AC2F8F0"
    "9C0141080250320F1802104A08"
    ];
solveit.(examples2);

input = "0054FEC8C54DC02295D5AE9B243D2F4FEA154493A43E0E60084E61CE802419A95E38958DE4F100B9708300466AB2AB7D80291DA471EB9110010328F820084D5742D2C8E600AC8DF3DBD486C010999B44CCDBD401C9BBCE3FD3DCA624652C400007FC97B113B8C4600A6002A33907E9C83ECB4F709FD51400B3002C4009202E9D00AF260290D400D70038400E7003C400A201B01400B401609C008201115003915002D002525003A6EB49C751ED114C013865800BFCA234E677512952E20040649A26DFA1C90087D600A8803F0CA1AC1F00042A3E41F8D31EE7C8D800FD97E43CCE401A9E802D377B5B751A95BCD3E574124017CF00341353E672A32E2D2356B9EE79088032AF005E7E8F33F47F95EC29AD3018038000864658471280010C8FD1D63C080390E61D44600092645366202933C9FA2F460095006E40008742A8E70F80010F8DF0AA264B331004C52B647D004E6EEF534C8600BCC93E802D38B5311AC7E7B02D804629DD034DFBB1E2D4E2ACBDE9F9FF8ED2F10099DE828803C7C0068E7B9A7D9EE69F263B7D427541200806582E49725CFA64240050A20043E25C148CC600F45C8E717C8010E84506E1F18023600A4D934DC379B9EC96B242402504A027006E200085C6B8D51200010F89913629A805925FBD3322191A1C45A9EACB4733FBC5631A210805315A7E3BC324BCE8573ACF3222600BCD6B3997E7430F004E37CED091401293BEAC2D138402496508873967A840E00E41E99DE6B9D3CCB5E3F9A69802B2368E7558056802E200D4458AF1180010A82B1520DB80212588014C009803B2A3134DD32706009498C600664200F4558630F840188E11EE3B200C292B59124AFF9AE6775ED8BE73D4FEEFFAD4CE7E72FFBB7BB49005FB3BEBFA84140096CD5FEDF048C011B004A5B327F96CC9E653C9060174EA0CF15CA0E4D044F9E4B6258A5065400D9B68";
solveit(input);
