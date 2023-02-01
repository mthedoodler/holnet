function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function NamedNodeMap:new(o, inputTable)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.length = tableLength(o)
    return o
end

function NamedNodeMap:getNamedItem(name)
    return self[name]
end

function NamedNodeMap:item(index)

    if (index >= self.length) then return nil end

    local i = 0
    for _, v in pairs(self) do
        if (i == index) then
             return v
        end
        i = i + 1
    end 
end

function NamedNodeMap:removeNamedItem(name)
    if self[name] then 
        self[name] = nil
    else
        error("DOMException: NOT_FOUND_ERROR")
    end
end

function Node:new(o, childrenNodes)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    --Attributes
    self.attributes = {} or 
    self.childNodes = {} or childrenNodes
    
    return o
end