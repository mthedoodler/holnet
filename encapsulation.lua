

A = {prop=1}


function A:new(o)
    local o = o or {}
    setmetatable(o, A)
    A.__index = A
    return o
end

function A:testMethod() 
    return self.prop+1
end

function A:testMethod2() 
    return self.prop-1
end

local privateVars 

instance = TestClass(10)
print(instance.public_property)
print(instance.private_property)
print(instance:privateGetter())
