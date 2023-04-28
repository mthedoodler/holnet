function indexOf(tbl, x) --IndexOf function, will remove later.
    for k, v in pairs(tbl) do
        if v == x then
            return k
        end
    end
end

function contains(tbl, x) --Will remove later
    for _, v in pairs(tbl) do
        if v == x then
            return true
        end
    end
    return false
end
