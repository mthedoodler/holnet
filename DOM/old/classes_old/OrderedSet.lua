---@diagnostic disable: lowercase-global, undefined-global
--OrderedSet as specified in DOM level 1

require("utils")
OrderedSet = {}

function OrderedSet:new(o)
    --Constructor

    if o then
        if not _isArray(o) then error("Set must be constructed from an array/list.") end
    else
        o = {}
    end

    setmetatable(o, self)
    OrderedSet.__index = self
    return o
end

function OrderedSet:append(el)
    --Add a new element to the end of the  set(only if it's not there already)
    if not _isIn(self, el) then
        table.insert(self, el)
    end
end

function OrderedSet:prepend(el)
    --Add a new element to the start of the set(only if it's not there already)
    if not _isIn(self, el) then
        table.insert(self, 1, el)
    end
end

function OrderedSet:remove(el)
    --Remove an element from the set.
    local index = _isIn(self, el)
    if index then
        table.remove(self, index)
    end
end

function OrderedSet:union(other)
    --Set union that returns a new set, preserves order. {a1, a2, ...an, b1, b2, ... bn}
    local newSet = OrderedSet:new({})
    for i=1,#self do
        newSet:append(self[i])
    end
    for i=1, #other do
        newSet:append(other[i])
    end
    return newSet
end

function OrderedSet:intersection(other)
    --Set inersection that returns a new set, preserves order. {a1, a2, ...an, b1, b2, ... bn}
    local newSet = {}
    for k, v in pairs(self) do
        if _isIn(other, v) then
            table.insert(newSet,v)
        end
    end
    return OrderedSet:new(newSet)
end

function OrderedSet:difference(other)
    --Set inersection that returns a new set, preserves order.
    local newSet = {}
    for k, v in pairs(self) do
        if not _isIn(other, v) then
            table.insert(newSet,v)
        end
    end
    return OrderedSet:new(newSet)
end

function OrderedSet.parse(str)
    --Split a string by whitespace and turn each word into an element of an OrderedSet
    local newSet = {}
    for w in s:gmatch("%S+") do
        newSet:append(w)
    end
    return newSet
end

function OrderedSet:serialize()
    --Reverse OrderedSet.parse, joining all elements of the set into a string seperated by a space.
    local str = ""
    for k, v in ipairs(self) do
        str = str .. v .. " "
    end
    str = str:sub(1,-2)
    return str
end

y = OrderedSet:new({"a",2,3})
y:append("b")
y:append("a")
y:prepend("c")
y:prepend("a")
y:remove(2)

print(textutils.serialise(y)) --Should print (c, a, b, 3)

print("Testing set operators")
print(textutils.serialize(y:union(OrderedSet:new({"d", "a"})))) --Should print c, a, b, 3, d

print(textutils.serialize(y:intersection(OrderedSet:new({"d", "a"})))) --Should print a

print(textutils.serialize(y:difference(OrderedSet:new({"d", "a"})))) --Should print c, b, 3, d

--return OrderedSet