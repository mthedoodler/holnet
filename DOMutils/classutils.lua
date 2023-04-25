
---Utilities for creating simple classes.

---Supports private + read only variables via python-like syntax:

----Private variables are prefixed by __(double underscore)
----Read only variables are prefixed by _(single underscore)

---The __index and __newindex will enforce encapsulation of these variables
---when modifying them without the prefix underscores.

---The raw properties can still be modified, but at least the intention is known like python.

---TODO: Add support for getters.

local expect = require "cc.expect"
local expect, field = expect.expect, expect.field

local rawtype = type
local rawexpect = expect

--- New type function that adds class type support.
--- 
--- @param[any] - The object whose type to find.
--- @return[string] - The type of the object.

local function type(obj)
    local currentType = rawtype(obj)

    if currentType ~= "table" then
        return currentType
    end

    if obj.__type then
        return obj.__type
    end

    return "table"
end

--- Checks if an object is an instance of a class or its superclasses.
--- 
--- @param[any] obj - The object to check.
--- @param[any] class - The class to check against.
--- @return[boolean] true if obj is an instance of class, false otherwise.

local function instanceof(obj, class)
    expect(1, obj, "table")
    expect(2, class, "table")
    if rawtype(obj) ~= "table" then
        return false
    end
    
    if rawequal(obj.__type, class.__type) then
        return true
    end

    local obj_mt = getmetatable(obj)
    if obj_mt == nil then
        return false
    end

    return instanceof(obj_mt, class)
end


local function expect(index, var, varType)
    rawexpect(1, index, "number")

    local currentType = type(var)

    if currentType ~= "table" then
        return rawexpect(index, var, varType)
    end

    if (var.__type == nil) then
        return rawexpect(index, var, "table")
    end

    if varType == "class" then
        return var
    end

    if not instanceof(var, varType) then
        error("bad argument #" .. index .. " to 'expect' (expected " .. varType .. ", got " .. type(var) .. ")")
    end

    return var
end

--- Check if the class cls implements all of its parent class's methods.

--- @param[table] cls - The new 'type' of the class. This is stored in the cls.__type private property will be what type(cls) returns.
---
local function ensureImplementsAbstract(cls)

    local parent = getmetatable(cls)

    for key, value in pairs(cls) do
        if rawtype(rawget(parent, key)) == "function" and rawtype(rawget(cls, key)) ~= "function" then
            error("Method " .. key .. " from parent class not supported", 2)
        end
    end
end

--- Create a new base class given its name(type) and variables.
    
--- @param[string] name - The new 'type' of the class. This is stored in the cls.__type private property will be what type(cls) returns.
--- @param[table] vars - The properties(instance variables) that the class stores, along with default values.
---
local function class(name, vars)
    --Enforce typing. 
    expect(1, name, "string")
    expect(2, vars, "table")

    --Create initial class and populate it with default variables.
    local cls = {__type = name}
    cls.__index = cls

    for k, v in pairs(vars) do
        cls[k] = v
    end
    
    -- Identify private and read-only variables defined in the `vars` parameter.
    local clsPrivateVars = {}
    local clsReadOnlyVars = {}
    for key, _ in pairs(cls) do
        if key:sub(1,1) == "_" then
            if key:sub(2,2) == "_" then
                clsPrivateVars[key:sub(3,-1)] = true
            else
                clsReadOnlyVars[key:sub(2,-1)] = true
            end
        end
    end

    -- Make `__newindex` and `__index` functions that enforce read-only and private variables.
    function cls.__index(tbl, key)
        if clsPrivateVars[key] then
            error("Attempt to access private variable " .. key, 2)
        elseif clsReadOnlyVars[key] then
            return tbl["_" .. key]
        else
            return cls[key]
        end
    end

    function cls.__newindex(tbl, key, value)
        if clsReadOnlyVars[key] then
            error("Attempt to set read-only variable " .. key, 2)
        else
            rawset(tbl, key, value)
        end
    end

    --Add a method to support `instanceof` on instances.
    function cls:instanceof(class)
        return instanceof(cls, class)
    end

    -- Return the new class table, along with tables of its private and read-only variables.
    return cls, clsReadOnlyVars
end


--- Extend a base class given the class table and its new name and vars.
    
--- @param[table] super - The superclass table. This will be the parent of cls.
--- @param[string] name - The namme of the new subclass. This is stored in the cls.__type private property will be what type(cls) returns.
--- @param[table] vars - The properties(instance variables) that the subclass stores, along with default values.
--- @return[table] cls - The new subclass table.

local function extend(super, name, vars) 
    expect(1, super, "table")
    expect(2, name, "string")
    expect(3, vars, "table")

    --Create class and set metatable to the parent.
    local cls, clsReadOnlyVars = class(name, vars)
    setmetatable(cls, super)

    --Override the __newindex method so it looks at the metatable if it can't find it in the object.
    function cls.__newindex(tbl, key, value)
        if clsReadOnlyVars[key] then
            error("Attempt to set read-only variable " .. key)
        else
            getmetatable(cls).__newindex(tbl, key, value)
        end
    end
    
    return cls
end


return {type=type, expect=expect, rawtype=rawtype, instanceof=instanceof, class=class, extend=extend}