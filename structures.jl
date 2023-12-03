mutable struct ListNode{T}
    data::T
    prev::ListNode{T}
    next::ListNode{T}
    function ListNode{T}() where T
        node = new{T}()
        node.next = node
        node.prev = node
        return node
    end
    function ListNode{T}(data) where T
        node = new{T}(data)
        return node
    end
end

mutable struct MutableLinkedList{T}
    len::Int
    node::ListNode{T}
    function MutableLinkedList{T}() where T
        l = new{T}()
        l.len = 0
        l.node = ListNode{T}()
        l.node.next = l.node
        l.node.prev = l.node
        return l
    end
end

next!(l::MutableLinkedList{T}) = l.node = l.node.next
prev!(l::MutableLinkedList{T}) = l.node = l.node.next
function splice!(l::MutableLinkedList{T},r::UnitRange)
    l2 = MutableLinkedList{T}()
    node = l.node
    for i in 1:first(r)
        node = node.next
    end
    len = length(r)
    for j in 1:len
        push!(l2, node.data)
        node = node.next
    end
    l2.len = len
    return l2
end

using CircularArrays

function Base.insert!(a::CircularVector, i::Integer, item)
    insert!(a.data,linearindex(a,i),item)
    return a
end
function Base.deleteat!(a::CircularVector, i::Integer)
    deleteat!(a.data,linearindex(a,i))
    return a
end
function Base.deleteat!(a::CircularVector, inds)
    deleteat!(a.data, sort!(unique(linearindices(a,inds))))
    a
end

linearindices(a::CircularVector,inds) = map(i -> linearindex(a,i), inds)
linearindices(a::CircularVector,i::Integer) = linearindex(a,i)
linearindex(a::CircularVector,i::Integer) = mod(i, eachindex(IndexLinear(), a.data))
function standardrange(a::CircularVector,r::AbstractUnitRange{<:Integer})
    f = mod(first(r), eachindex(IndexLinear(), a.data))
    l = f + length(r) - 1
    f:l
end
function splitrange(a::CircularVector,r::AbstractUnitRange{<:Integer})
    first(r) > last(r) && return [r]
    f = mod(first(r), eachindex(IndexLinear(), a.data))
    if length(r) > length(a.data)
        l = mod(first(r)-1, eachindex(IndexLinear(), a.data))
    else
        l = mod(last(r), eachindex(IndexLinear(), a.data))
    end
    if f > l
        [f:length(a.data), 1:l]
    else
        [f:l]
    end
end
function shift!(a::CircularVector, i::Integer, steps)
    item = a[i]
    ind = mod(i, eachindex(IndexLinear(), a.data))
    deleteat!(a.data,ind)
    newind = linearindex(a,i+steps)
    insert!(a.data,newind,item)
    newind
end

function shiftmove!(a::CircularVector, i::Integer, steps)
    #this is slower than shiftdel for some reason
    steps = mod(steps,1:length(a)-1)
    item = a[i]
    a[i:i+steps-1] = a[i+1:i+steps]
    a[i+steps] = item
    a
end

function shift!(a::CircularVector, inds, steps)
    items = a[inds]
    ind = sort!(unique(map(i -> mod(i, eachindex(IndexLinear(), a.data)), inds)))
    deleteat!(a.data,ind)
    newind = mod(i+steps, eachindex(IndexLinear(), a.data))
    insert!(a.data,newind,item)
    newind
end

Base.splice!(a::CircularVector, i::Integer, ins=Base._default_splice) = splice!(a.data,linearindex(a,i),ins)
Base.splice!(a::CircularVector, inds) = (dltds = eltype(a.data)[]; _deleteat!(a.data, sort!(unique(linearindices(inds,i))), dltds); dltds)

function Base.splice!(a::CircularVector, r::AbstractUnitRange{<:Integer}, ins=Base._default_splice)
    v = a[r]
    m = length(ins)
    if m == 0
        deleteat!(a, r)
        return v
    end

    rn = splitrange(a,r)

    if length(rn) == 2
        inslen = min(length(rn[1]),length(ins))
        v = splice!(a.data,rn[1],ins[1:inslen])
        w = splice!(a.data,rn[2],ins[inslen+1:end])
        return vcat(v,w)
    else
        return splice!(a.data,r,ins)
    end

end