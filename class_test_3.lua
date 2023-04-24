unittests = require("unittests")
local logger = unittests.Logger("log.txt")
local tester = unittests.Tester(logger)

classutils = require("classutils")
local type = classutils.type
local instanceof = classutils.instanceof
local class = classutils.class
local extend = classutils.extend

Animal = {
    public = 1,
    public2 = 20,
    __private = 1,
    __private2 = 2,
    _readonly = 5,
}

Animal = class("Animal", Animal)

function Animal.new(public1, private1)
    local o = {}
    setmetatable(o, Animal)
    o.public = public1
    o.__private = private1
    return o
end

Canid = {
    public3 = 1,
    __private3 = "Fuck you",
    _readonly2 = 5,
    _readonly3 = -6,
    __type = "Canid",
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

animal = Animal.new(-5, 10)


--Test Basic Classes Methods
tester.ensureEquals(function() return animal.public end, "Ensure reading public properties works.", -5)
tester.ensureEquals(function() return animal.public2 end, "Ensure reading default public properties works.", 20)

tester.ensureEquals(function() return animal.readonly end, "Ensure reading readonly properties via __index works.", 5)
tester.ensureEquals(function() return animal._readonly end, "Ensure reading readonly via _readonly works", 5)
tester.ensureErrors(function() animal.readonly = 2 end, "Ensure read-only variables can't be set.")

tester.ensureErrors(function() return animal.private end, "Ensure private variables can't be read.")
tester.ensureEquals(function() return animal.__private end, "Ensure private variable accessable by __.", 10)

--Test inheritance
canid = Canid.new(7, 30)

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
tester.ensureEquals(function() return type(Animal) end, "Ensure Type works on base class.", "Animal")

tester.ensureEquals(function() return type(canid) end, "Ensure Type works on base instance.", "Canid")
tester.ensureEquals(function() return type(Canid) end, "Ensure Type works on base class.", "Canid")

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

canid = Canid.new(3)

--tester.ensureEquals(function() return canid.readonly end, "Ensure reading readonly properties via __index works.", 5)
tester.endTests()
if false then 

end
