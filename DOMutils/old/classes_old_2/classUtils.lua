local function readOnlyNewIndex(class, readOnlyVars) --Returns a __newindex that throws an error if the variable being set is read only.

    local readOnlySet = {}
    for _, var in ipairs(readOnlyVars) do
        readOnlySet[var] = true
    end

    local newIndex = function(instance, key, value, i)
        term.setTextColor(colors.orange)
        print("Setting key " .. key)
        term.setTextColor(colors.white)

        if readOnlySet[key] then
            error("Attempt to modify read-only attribute " .. key, (i or 2))
        end
        
        local meta = getmetatable(class)
        if meta and meta.__newindex then
            meta.__newindex(instance, key, value, (i or 2) + 1)
        else
            rawset(instance, key, value)
        end
    end

    return newIndex
end

local function supportReadOnlyInstance(instance, readOnlyVars)
    local readOnlySet = {}
    for _, var in ipairs(readOnlyVars) do
        readOnlySet[var] = true
    end

    local mt = getmetatable(instance) or {}
    
    mt.__newindex = function(self, key, value, i)
        if readOnlySet[key] then
            error("Attempt to modify read-only attribute " .. key, (i or 2))
        else
            rawset(self, key, value)
        end
    end
    setmetatable(instance, mt)
end

local function supportReadOnly(class, readOnlyVars)
    term.setTextColor(colors.lime)
    print("Supporting read-only properties for a class")
    term.setTextColor(colors.white)
    class.__newindex = readOnlyNewIndex(class, readOnlyVars)
end

local function simpleClass(name, defaultVars, parent)
    local cls = defaultVars

    local oldIndex = cls.__index
    cls.__index = function(instance, key)
        if key == "__classType" then
            return name
        elseif oldIndex then
            return cls(instance, key)
        else
            return instance[key]
        end
    end

    local meta = getmetatable(cls)
    if not meta then
        meta = {}
        setmetatable(cls, meta)
    end

    local oldMetaIndex = meta.__index
    meta.__index = function(cls, key)
        if key == "__classType" then
            return name
        elseif oldMetaIndex then
            return oldMetaIndex(cls, key)
        end
    end

    if parent then
        setmetatable(cls, parent)
    end

    return cls
end

local oldtype = type

local function type(cls)
    if oldtype(cls) == "table" and cls.__classType then
        return cls.__classType
    end
    return oldtype(cls)
end

local function isinstance(cls, o)
    if cls.__classType == o.__classType then
        return true
    end
    
    local mt = getmetatable(cls)
    if mt then
        return isinstance(mt, o)
    end

    return false
end


return {
    simpleClass=simpleClass, 
    readOnlyNewIndex=readOnlyNewIndex, 
    supportReadOnly=supportReadOnly,
    supportReadOnlyInstance=supportReadOnlyInstance,
    type=type,
    isinstance=isinstance}