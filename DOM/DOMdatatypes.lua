function OrderedSet(t)
    return setmetatable(t, {
        __index = rawget,
        __newindex = function (t, k, v)
            if not contains(t, v) then
                rawset(t, k, v)
            end
        end
    })
    
end