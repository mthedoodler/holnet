---@diagnostic disable: undefined-global, duplicate-set-field, lowercase-global
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[orig_key] = orig_value
        end
        setmetatable(copy, getmetatable(orig))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

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
    if (index >= self.length) then
        return nil
    end

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

function Node:new(o, doc, attributes, parentNode, children, previousSibling, nextSibling)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    --Attributes
    self.parentNode = parentNode

    self.attributes = {} or attributes
    self.childNodes = {} or children
    self.firstNode = self.childNodes[1]
    self.lastNode = self.childNodes[#(self.childNodes)]

    self.previousSibling = previousSibling
    self.nextSibling = nextSibling

    self.nodeName = nil
    self.nodeType = nil
    self.nodeValue = nil
    self.ownerDocument = doc

    return o
end

function Node:_validateNoAncestors(node)
    parent = self.parentNode
    repeat
        if parent == node then
            error("DOMException: HIERARCHY_REQUEST_ERR")
        end
        parent = parent.parentNode
    until parent == nil
end

function Node:appendChild(node)
    self:validateNoAncestors(node)

    node.previousSibling = self.lastNode
    node.parentNode = self
    self.ownerDocument = node.ownerDocument

    self.childNodes[#(self.childNodes)+1] = node

    if (node.ownerDocument ~= null and self.ownerDocument ~= node.ownerDocument) then
        error("DOMException: WRONG_DOCUMENT_ERR")
    end

    return Node
end

function Node:insertBefore(newChild, refChild)

    self:validateNoAncestors(node)

    for k, node in pairs(self.childNodes) do
        if node == refChild then
            node.previousSibling = self.lastNode
            node.parentNode = self
            self.ownerDocument = node.ownerDocument

        end
    end
end

function Node:cloneNode(deep)
    local clone
    if deep then
        clone = deepcopy(self)
    else
        clone = shallowcopy(self)
    end
    clone.parentNode = nil

    return clone
end

function Node:hasAttributes()
    if next(self.attributes) == nil then
        return false
    else
        return true
    end
end

function Node:hasChildNodes()
    if next(self.childNodes) == nil then
        return false
    else
        return true
    end
end
