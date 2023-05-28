---@diagnostic disable: undefined-doc-name

---Utilities for creating simple classes.

---Supports private + read only variables via python-like syntax:

----Private variables are prefixed by __(double underscore)
----Read only variables are prefixed by _(single underscore)

---The __index and __newindex will enforce encapsulation of these variables
---when modifying them without the prefix underscores.

---The raw properties can still be modified, but at least the intention is known like python.

---TODO: Add support for getters.

local expect = require "cc.expect"
expect = expect.expect

local rawtype = type
local rawexpect = expect

--- New type function that adds class type support.
--- 
--- @param obj any - The object whose type to find.
--- @return string - The type of the object.

local function type(obj)
    local currentType = rawtype(obj)

    if currentType ~= "table" then
        return currentType
    end

    if rawget(obj, "__type") then
        return "class"
    elseif getmetatable(obj).__type then
        return obj.__type
    end

    return "table"
end

--- Checks if an object is an instance of a class or its superclasses.
--- 
--- @param obj any - The object to check.
--- @param class class - The class to check against.
--- @return boolean - true if obj is an instance of class, false otherwise.

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

--- Returns true if var is of the expectedType
--- 
--- @param obj any - The object to check.
--- @param expectedType class|string - The type to check for; either a Class for a class or a string for a primitive/table.
--- @return boolean - true if var is of type expectedType.

local function isType(obj, expectedType)
    if type(expectedType) == "string" then -- check for built-in types
        if expectedType == "class" then
            return rawtype(obj) == "table" and rawget(obj, "__type") ~= nil
        else
            return type(obj) == expectedType
        end
    elseif rawtype(expectedType) == "table" then -- check for instances of classes
        return not rawget(obj, "__type") and obj:instanceof(expectedType)
    end
    return false
end

--- Reimplemtation of cc.expect's expect function that supports classes.
--- If value doesnt match expectedType, throws an error. Otherwise, returns value.
--- 
--- @param index number - The 1-based argument index.
--- @param var any - The argument value.
--- @param expectedTypes string | class - The types to check against.
--- @return var any - Returns the value itself.

local function expect(index, var, ...)
    rawexpect(1, index, "number")

    local expectedTypes = {...}
    local var = var

    --Iterate through all the types in the expectedTypes table.
    --If there's a match, return var. Otherwise, throw an error.

    local expectedTypesString = "" --Error message.

    for i, expectedType in ipairs(expectedTypes) do 
        if isType(var, expectedType) then --If match, return var.
            return var
        end
        --Use each iteration of the loop to add on to the error message.
        if i > 1 then
            expectedTypesString = expectedTypesString .. ", "
        end

        if rawtype(expectedType) == "table" then --If a table/class/instance:
            if type(expectedType) == "class" then --If class(appends 'instance of ' and the class's __type)
                expectedTypesString = expectedTypesString .. "instance of " .. expectedType.__type
            else --If instance(appends class __type) or table(appends 'table')
                expectedTypesString = expectedTypesString .. type(expectedType)
            end
        else
            expectedTypesString = expectedTypesString .. expectedType
        end
    end
    --Throw the error
    error("bad argument #"..index.." (expected "..expectedTypesString..", got "..type(var)..")", 2)
end

--- Create a new base class given its name(type) and variables.

--- @param name string - The new 'type' of the class. This is stored in the cls.__type private property will be what type(cls) returns.
--- @param vars table - The properties(instance variables) that the class stores, along with default values.
--- @return cls class - The new class table.

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
    local clsGetters = {}
    local clsSetters = {}

    for key, _ in pairs(cls) do
        if key:sub(1,1) == "_" then
            if key:sub(2,2) == "_" then
                clsPrivateVars[key:sub(3,-1)] = true
            else
                clsReadOnlyVars[key:sub(2,-1)] = true
                if key:sub(2,2) == "g" then
                    clsGetters[key:sub(3,-1)] = true
                    cls[key] = function() return nil end
                elseif key:sub(2,2) == "s" then
                    clsSetters[key:sub(3,-1)] = true
                    cls[key] = function() return nil end
                end
            end
        end
    end

    -- Make `__newindex` and `__index` functions that enforce read-only and private variables.
    function cls.__index(tbl, key)
        if clsPrivateVars[key] then
            error("Attempt to access private variable " .. key, 2)
        elseif clsReadOnlyVars[key] then
            return tbl["_" .. key]
        elseif clsGetters[key] then
            return cls["_g" .. key](tbl)
        else
            return cls[key]
        end
    end

    function cls.__newindex(tbl, key, value)
        if clsSetters[key] then
            cls["_s" .. key](tbl, value)
        elseif clsReadOnlyVars[key] then
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
    return cls, clsReadOnlyVars, clsSetters
end


--- Extend a base class given the class table and its new name and vars.

--- @param super table - The superclass table. This will be the parent of cls.
--- @param name string - The namme of the new subclass. This is stored in the cls.__type private property will be what type(cls) returns.
--- @param vars table - The properties(instance variables) that the subclass stores, along with default values.
--- @return class - The new subclass table.

local function extend(super, name, vars) 
    expect(1, super, "class")
    expect(2, name, "string")
    expect(3, vars, "table")

    --Create class and set metatable to the parent.
    local cls, clsReadOnlyVars, clsSetters = class(name, vars)
    setmetatable(cls, super)

    --Override the __newindex method so it looks at the metatable if it can't find it in the object.
    function cls.__newindex(tbl, key, value)
        if clsSetters[key] then
            cls["_s" .. key](tbl, value)
        elseif clsReadOnlyVars[key] then
            error("Attempt to set read-only variable " .. key)
        else
            getmetatable(cls).__newindex(tbl, key, value)
        end
    end
    
    return cls
end

local abstractFunctionPrefixes = {
    _a = true,
    _g = true,
    _s = true
}

--- Check if the class cls implements all of its parent class's abstract methods.

--- @param cls class - The new 'type' of the class. This is stored in the cls.__type private property will be what type(cls) returns.
local function assertImplementsParent(cls)
    expect(1, cls, "class")
    local parent = getmetatable(cls)

    if not parent then
        error("class " .. cls.__type .. " has no parent.")
    end
    for key, value in pairs(parent) do

        if abstractFunctionPrefixes[key:sub(1, 2)] and rawtype(rawget(parent, key)) == "function" then
            local abstractKey = key:gsub("_a", "") --The inclusion of the check here allows for _a abstract functions to still count as implementing - allowing for abstract classes to  extend abstract classes.

            if rawtype(rawget(cls, abstractKey)) ~= "function" and rawtype(rawget(cls, key)) ~= "function" then
                local methodType = ""

                if key:sub(1,2) == "_g" then
                    methodType = "getter"
                elseif key:sub(1,2) == "_s" then
                    methodType = "setter"
                else
                    methodType = "method"
                end

                local unimplementedParent = parent

                while rawget(unimplementedParent, key) == nil do --Find the parent with the missing method
                    unimplementedParent = getmetatable(unimplementedParent)
                end

                error("class " .. cls.__type .. " doesn't implement " .. methodType .. " " .. abstractKey .. " from parent class " .. unimplementedParent.__type .. ".",  2)
            end
        end
    end
end

return {type=type, expect=expect, rawtype=rawtype, instanceof=instanceof, class=class, extend=extend, assertImplementsParent=assertImplementsParent}