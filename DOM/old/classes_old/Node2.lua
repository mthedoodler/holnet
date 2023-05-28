Node = {prop = 1}

function Node:new(o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Node:appendChild()
  error("Not Implemented!")
end

return {Node=Node}
