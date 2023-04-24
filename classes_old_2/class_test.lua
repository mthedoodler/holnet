classutils = require("classUtils")
supportReadOnly = classutils.supportReadOnly
supportReadOnlyInstance = classutils.supportReadOnlyInstance

type = classutils.type
simpleClass = classutils.simpleClass
readOnlyNewIndex = classutils.readOnlyNewIndex

ClassA = simpleClass("ClassA", {prop=2, readonly=3})
supportReadOnly(ClassA, {"readonly"})

ClassB = simpleClass("ClassB", {readonly2=3}, ClassA)
supportReadOnly(ClassB, {"readonly2"})

function ClassB.new(prop)
    local instance = setmetatable({}, ClassB)
    instance.prop = prop
    return instance
end

ClassC = simpleClass("ClassC", {readonly3=3}, ClassB)
supportReadOnly(ClassC, {"readonly3"})

function ClassC.new(args)
    local instance = args or {}
    setmetatable(instance, ClassC)
    supportReadOnlyInstance(instance, {"readonly3"})
    return instance
end

classA4 = ClassC.new({property=4})

classA1 = ClassB.new(7)
term.setTextColor(colors.yellow)
print("Attempting to set Class A read only variable")
term.setTextColor(colors.white)
print(pcall(function() classA1.readonly = 3 end))
print()

term.setTextColor(colors.yellow)
print("Attempting to set Class B read only variable")
term.setTextColor(colors.white)
print(pcall(function() classA1.readonly2 = 3 end))
print()

classA3 = ClassC.new({readonly3=23, property=4})
classA4 = ClassC.new({property=4})

term.setTextColor(colors.yellow)
print("Attempting to set Class C read only variable - this fails due to")
term.setTextColor(colors.white)
print(pcall(function() classA3.readonly3 = 3 end))
print()




term.setTextColor(colors.yellow)
print("Attempting to set Class C read only variable")
term.setTextColor(colors.white)
print(pcall(function() classA4.readonly3 = 3 end))

print(ClassA.__classType)
print(ClassC.__classType)

print(classA4.__classType)