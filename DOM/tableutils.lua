local classutils = require("classutils")
local expect = classutils.expect

function indexOf(tbl, x) --IndexOf function, will remove later.
    expect(1, tbl, "table")
    for k, v in pairs(tbl) do
        if v == x then
            return k
        end
    end
    return -1
end

function contains(tbl, x) --Will remove later
    expect(1, tbl, "table")
    for _, v in pairs(tbl) do
        if v == x then
            return true
        end
    end
    return false
end

function shallowclone(tbl)
    local out = {}

    for k, v in pairs(tbl) do
        out[k] = v
    end
    return out
end

function shallowequals(x, y)
    for k, v in pairs(x) do
        if y[k] ~= v then
            return false
        end
    end

    for k, v in pairs(y) do
        if x[k] ~= v then
            return false
        end
    end

    return true
end

function makeReadOnlyProxy(t)
    expect(1, t, "table")
    local proxy = {}

    local mt = {
        __index = t,
        __len = function(tbl) return #t end,
        __eq = function(tbl) return t == tbl end,
        __newindex = function (t,k,v)
            error("attempt to modify read-only table", 2)
        end
      }
    setmetatable(proxy, mt)
    return proxy
end  

print(shallowequals({"a","b"},{"a","b"}))
print(shallowequals({b="a",a="b"},{b="a",a="b"}))

print(shallowequals({b="a",a="b"},{b="a",a="c"}))

print(shallowequals({b="a",a="b"},{b="a",a="b", c="3"}))

