local unittests = require("unittests")
local classutils = require("classutils")

local type = classutils.type
local instanceof = classutils.instanceof
local class = classutils.class
local extend = classutils.extend
local expect = classutils.expect
local assertImplementsParent = classutils.assertImplementsParent

local logger = unittests.Logger("log.txt")
logger.silent = true
local tester = unittests.Tester(logger)

Animal = {
    public = 1,
    public2 = 20,
    __private = 1,
    __private2 = 2,
    _readonly = 5,
    _ggetter = true,
    _ssetter = true,
}

Animal = class("Animal", Animal)

function Animal.new(public1, private1)
    local o = {}
    setmetatable(o, Animal)
    o.public = public1
    o.__private = private1
    return o
end

function Animal:_ggetter()
    return 1
end

function Animal:_ssetter(val)
    self.setValue = val
end

Canid = {
    public3 = 1,
    __private3 = "Fuck you",
    _readonly2 = 5,
    _readonly3 = -6,
    _ggetter2 = true,
    _ssetter2 = true
}

Canid = extend(Animal, "Canid", Canid)

function Canid.new(public1, private1)
    local o = {}
    o.public = public1 
    o.__private = private1
    o._readonly2 = 15
    setmetatable(o, Canid)
    return o
end

function Canid:_ggetter2()
    return 3
end

function Canid:_ssetter2(val)
    self.setValue2 = val
end

local animal = Animal.new(-5, 10)
local canid = Canid.new(7, 30)

tester.startTests("Expect Function")
tester.ensureRuns(function() expect(1, 1, "number") end, "Expecting number works with number.")
tester.ensureErrors(function() expect(1, "NotANumber", "number") end, "Expecting number fails when not a number.")

tester.ensureRuns(function() expect(1, "1", "string") end, "Expecting string works.")
tester.ensureErrors(function() expect(1, 6, "string") end, "Expecting string fails when not a string.")

tester.ensureRuns(function() expect(1, false, "boolean") end, "Expecting boolean works.")
tester.ensureErrors(function() expect(1, "NotABool", "boolean") end, "Expecting boolean fails when not a string.")

tester.ensureRuns(function() expect(1, tester.ensureRuns, "function") end, "Expecting function works.")
tester.ensureErrors(function() expect(1, "NotAFunc", "function") end, "Expecting function fails when not a function")

tester.ensureRuns(function() expect(1, {}, "table") end, "Expecting table works.")
tester.ensureErrors(function() expect(1, 2, "table") end, "Expecting table fails when not table.")

tester.ensureRuns(function() expect(1, Animal, "class") end, "Expecting class works.")
tester.ensureRuns(function() expect(1, Animal, "class", "string") end, "Expecting class multiple types works.")
tester.ensureErrors(function() expect(1, animal, "class") end, "Expecting class fails when instance.")
tester.ensureErrors(function() expect(1, animal, "class", "string") end, "Expecting class fails when instance multiple arguments.")

tester.ensureErrors(function() expect(1, {}, "class") end, "Expecting class fails when non-class table.")
tester.ensureErrors(function() expect(1, "Animal", "class") end, "Expecting class fails when not class or table.")

tester.ensureRuns(function() expect(1, Canid, "class") end, "Expecting subclass class works.")
tester.ensureErrors(function() expect(1, canid, "class") end, "Expecting subclass fails when instance.")
tester.ensureRuns(function() expect(1, canid, Canid) end, "Expecting subclassclass works when subclass.")

tester.ensureErrors(function() expect(1, animal, Canid) end, "Expecting parent class fails when instance.")
tester.ensureRuns(function() expect(1, canid, Animal) end, "Expecting subclass when superclass - Polymorphism")
tester.ensureErrors(function() expect(1, Canid, Animal) end, "Expecting subclass when superclass fails when class is passed - Class is not instance.")
tester.ensureErrors(function() expect(1, Canid, Animal, "number", "string") end, "Expecting subclass when superclass fails when class is passed - Class is not instance.")


tester.endTests()

tester.startTests("Base Class + Encapsulation")

--Test Basic Classes Methods
tester.ensureEquals(function() return animal.public end, "Ensure reading public properties works.", -5)
tester.ensureEquals(function() return animal.public2 end, "Ensure reading default public properties works.", 20)

tester.ensureEquals(function() return animal.readonly end, "Ensure reading readonly properties via __index works.", 5)
tester.ensureEquals(function() return animal._readonly end, "Ensure reading readonly via _readonly works", 5)
tester.ensureErrors(function() animal.readonly = 2 end, "Ensure read-only variables can't be set.")

tester.ensureErrors(function() return animal.private end, "Ensure private variables can't be read.")
tester.ensureEquals(function() return animal.__private end, "Ensure private variable accessable by __.", 10)

tester.endTests()

tester.startTests("Interhitance + Encapsulation")

--Test inheritance

tester.ensureEquals(function() return canid.public end, "Ensure reading overridden public property works.", 7)
tester.ensureEquals(function() return canid.public2 end, "Ensure reading inherited public property works.", 20)

tester.ensureEquals(function() return canid.readonly2 end, "Ensure reading overridden readonly property from __index works.", 15)
tester.ensureEquals(function() return canid.readonly end, "Ensure reading inherited readonly property from __index works.", 5)

tester.ensureEquals(function() return canid._readonly2 end, "Ensure reading overridden readonly property via _ works.", 15)
tester.ensureEquals(function() return canid._readonly end, "Ensure reading inherited readonly property via _ works.", 5)

tester.ensureEquals(function() return canid.readonly3 end, "Ensure reading new readonly property via _ works.", -6)
tester.ensureEquals(function() return canid._readonly3 end, "Ensure reading new readonly property via _ works.", -6)

tester.ensureErrors(function() canid.readonly3 = 5 end, "Ensure setting new read only property fails")
tester.ensureErrors(function() canid.readonly2 = 5 end, "Ensure setting inherited read only property fails")

tester.ensureErrors(function() return canid.private3 end, "Ensure reading new private property fails.")
tester.ensureErrors(function() return canid.private2 end, "Ensure reading inherited property fails.")
tester.ensureEquals(function() return canid.__private3 end, "Ensure reading new private property via _ works.", "Fuck you")
tester.ensureEquals(function() return canid.__private2 end, "Ensure reading inherited private property via _ works.", 2)

--Test new type function
tester.ensureEquals(function() return type(animal) end, "Ensure Type works on base instance.", "Animal")
tester.ensureEquals(function() return type(Animal) end, "Ensure Type works on base class.", "class")

tester.ensureEquals(function() return type(canid) end, "Ensure Type works on base instance.", "Canid")
tester.ensureEquals(function() return type(Canid) end, "Ensure Type works on base class.", "class")

--Test instanceof function
tester.ensureEquals(function() return type(1) end, "Ensure Type works on primitives.", "number")
tester.ensureEquals(function() return instanceof(animal, Animal) end, "Ensure instanceof works on same class.", true)
tester.ensureEquals(function() return instanceof(canid, Canid) end, "Ensure instanceof works on same subclass.", true)
tester.ensureEquals(function() return instanceof(canid, Animal) end, "Ensure instanceof works on parent class.", true)
tester.ensureEquals(function() return instanceof(animal, Canid) end, "Ensure instanceof fails on child class.", false)

tester.ensureEquals(function() return instanceof(Animal, Animal) end, "Ensure instanceof class works on same class.", true)
tester.ensureEquals(function() return instanceof(Canid, Canid) end, "Ensure instanceof class works on same subclass.", true)
tester.ensureEquals(function() return instanceof(Canid, Animal) end, "Ensure instanceof class works on parent class.", true)
tester.ensureEquals(function() return instanceof(Animal, Canid) end, "Ensure instanceof class fails on child class.", false)

--Test class-based instanceof function
tester.ensureEquals(function() return animal:instanceof(Animal) end, "Ensure class instance:instanceof works on same class.", true)
tester.ensureEquals(function() return canid:instanceof(Canid) end, "Ensure child instance:instanceof works on same class.", true)
tester.ensureEquals(function() return Animal:instanceof(Animal) end, "Ensure class instance:instanceof works on same class.", true)
tester.ensureEquals(function() return Canid:instanceof(Canid) end, "Ensure child instance:instanceof works on same class.", true)

tester.ensureEquals(function() return animal:instanceof(Canid) end, "Ensure child instance:instanceof fails on parent class.", false)
tester.ensureEquals(function() return Animal:instanceof(Canid) end, "Ensure class instanceof fails on parent class.", false)

--tester.ensureEquals(function() return canid.readonly end, "Ensure reading readonly properties via __index works.", 5)
tester.endTests()

--Test getters and setters - Need to test more.
tester.startTests("Getters and Setters")

tester.ensureEquals(function() return animal.getter end, "Ensure base class getter works.", 1)
tester.ensureEquals(function() animal.setter = 5 return animal.setValue end, "Ensure base class setter works.", 5)
tester.ensureEquals(function() return animal.getter end , "Ensure inherited class getter works.", 1)
tester.ensureEquals(function() canid.setter = 5 return canid.setValue end, "Ensure inherited class setter works.", 5)
tester.ensureEquals(function() return canid.getter2 end , "Ensure subclass getter works.", 3)
tester.ensureEquals(function() canid.setter2 = 6 return canid.setValue2 end, "Ensure subclass setter works.", 6)

tester.endTests()

AbstractBaseClass = {
    public_prop = 2,
    _readonly_prop = 3,
    __private_prop = 4,
    _ggetter = "",
}

AbstractBaseClass = class("AbstractBaseClass", AbstractBaseClass)

function AbstractBaseClass:_aabstractMethod()
    error("Not Implemented!")
end

function AbstractBaseClass:_aabstractMethod2()
    error("Not Implemented!")
end


function AbstractBaseClass:concreteMethod()
    return 2
end

ConcreteClass = {
    public_prop = 3
}

ConcreteClass = extend(AbstractBaseClass, "ConcreteClass", ConcreteClass)

tester.startTests("Test assertImplementsParent; which checks if the subclass implements all the methods of its superclass.")
tester.ensureErrors(function() assertImplementsParent(animal) end, "Ensure errors when instance supplied.")
tester.ensureErrors(function() assertImplementsParent(canid) end, "Ensure errors when subclass instance supplied.")

tester.ensureErrors(function() assertImplementsParent(AbstractBaseClass) end, "Ensure error when supplied class has no parent.")
tester.ensureErrors(function() assertImplementsParent(Animal) end, "Ensure error when supplied non-abstract class has no parent.")

tester.ensureErrors(function() assertImplementsParent() end, "Ensure errors when non-instance table supplied.")

tester.ensureErrors(function() assertImplementsParent(ConcreteClass) end, "Ensure errors when subclass doesnt implement parent class.")

function ConcreteClass:abstractMethod2()
    print("Hello!")
end

tester.ensureErrors(function() assertImplementsParent(ConcreteClass) end, "Ensure errors when subclass doesnt implement part of parent class.")


function ConcreteClass:_aabstractMethod()
    print("Hello!")
end

tester.ensureErrors(function() assertImplementsParent(ConcreteClass) end, "Ensure errors when subclass includes an abstract method is used to implement the parent's.")

function ConcreteClass:abstractMethod()
    print("Hello!")
end

tester.ensureErrors(function() assertImplementsParent(ConcreteClass) end, "Ensure errors when subclass doesnt implement getter.")

function ConcreteClass:_ggetter()
    return 0
end

tester.ensureRuns(function() assertImplementsParent(ConcreteClass) end, "Ensure passes when subclass fully implements parent class's methods")


AbstractChildClass2 = extend(AbstractBaseClass, "AbstractChildClass2", {})

function AbstractChildClass2:_ggetter()
    return 0
end

function AbstractChildClass2:aabstractMethod()
    print("Yo!")
end

function AbstractChildClass2:_aabstractMethod2()
    error("Still Not Implemented!")
end


ChildOfAbstractClass2 = extend(AbstractChildClass2, "ChildOfAbstractClass2", {})


tester.ensureErrors(function() assertImplementsParent(AbstractChildClass2) end, "Ensure errors when abstract class's parent is not implemented.")

function AbstractChildClass2:_aabstractMethod3()
    print("Yo!")
end

tester.ensureErrors(function() assertImplementsParent(ChildOfAbstractClass2) end, "Ensure errors when abstract class's parent is not implemented.")

function ChildOfAbstractClass2:aabstractMethod3()
    print("Yo!")
end
tester.endTests()
