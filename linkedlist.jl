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
