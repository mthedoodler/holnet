A = {prop = 1}

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


B = A:new()
B["prop2"] = 10

function B:testMethod2()
    return self.prop + 30
end

print(B:new():testMethod2())
print(B:new():testMethod())
print(B:new().prop2)
print(B:new().prop)