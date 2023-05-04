local classutils = require("classutils")
local tableutils = require("tableutils")
local pretty = require("cc.pretty")
Document = {}
Element = {}


local type = classutils.type
local instanceof = classutils.instanceof
local class = classutils.class
local extend = classutils.extend
local expect = classutils.expect
local assertImplementsParent = classutils.assertImplementsParent

local Node = {
    _baseURI = "",
    _gchildNodes = {},
    _gfirstChild = {},
    _gisConnected = false,
    _glastChild = {},
    _gparentElement = {},
    _gnextSibling = {},
    _gpreviousSibling = {},
    _nodeName = "",
    _nodeType = -1,
    nodeValue = 0,
    _ownerDocument = {},
    _parentNode = {},
    textContent = "",

    children = {}, --For testing, will remove later

    _ELEMENT_NODE = 1,
    _ATTRIBUTE_NODE = 2,
    _TEXT_NODE = 3,
    _CDATA_SECTION_NODE = 4,
    _ENTITY_REFERENCE_NODE = 5,
    _ENTITY_NODE = 6,
    _PROCESSING_INSTRUCTION_NODE = 7,
    _COMMENT_NODE = 8,
    _DOCUMENT_NODE = 9,
    _DOCUMENT_TYPE_NODE = 10,
    _DOCUMENT_FRAGMENT_NODE = 11,
    _NOTATION_NODE = 12,

    _DOCUMENT_POSITION_DISCONNECTED = 1
    _DOCUMENT_POSITION_PRECEDING = 2
    _DOCUMENT_POSITION_FOLLOWING = 4
    _DOCUMENT_POSITION_CONTAINS = 8
    _DOCUMENT_POSITION_CONTAINED_BY = 16
    _DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC = 32
}

local x = { 67, 26, 63, 34, 15 }
print(indexOf(x, 63))


Node = class("Node", Node)

local function length(node)
    local typeOf = type(node)
    
    if typeOf == "DocumentType" or typeOf == "Attr" then
        return 0
    elseif typeOf == "CharacterData" then
        return node.data:len()
    end

    return #node.childNodes
end

local function descendants(node)
    local tbl = {}
    for _, child in pairs(node.childNodes) do
        table.insert(tbl, child)
        for _, grandchild in pairs(child.childNodes) do
            table.insert(tbl, grandchild)
        end
    end

    return tbl
end

function Node:_gisConnected()
    return self:getRootNode():instanceof(Document)
end

function Node:_gparentElement()
    if self._parentNode:instanceOf(Element) then
        return self._parentNode
    end
end

function Node:_gfirstChild()
    return self.childNodes[1]
end

function Node:_glastChild()
    return self.childNodes[#self.childNodes]
end

function Node:_gpreviousSibling()
    local nodeIndex = indexOf(self._parentNode.childNodes, self)
    if nodeIndex > 1 then
        return self._parentNode.childNodes[nodeIndex - 1]
    end
end

function Node:_gnextChild()
    local nodeIndex = indexOf(self._parentNode.childNodes, self)
    if nodeIndex < #(self._parentNode.childNodes) then
        return self._parentNode.childNodes[nodeIndex + 1]
    end
end

function Node:normalize()

    local toRemove = {}
    local index = 1

    while true do
        local child = self.childNodes[index]
        if child:instanceOf("Text") and type(child) != "CDATASection" then
            local length = length(child)
            if length == 0 then
                table.insert(toRemove, child)
            end

            child.data = child.wholeText
            
            while true do
                local nextChild = self.childNodes[index]
                index = index + 1
                if nextChild:instanceOf("Text") and type(nextChild) != "CDATASection" then
                    table.insert(toRemove, index)
                else
                    break
                end
            end

            index = index + 1
    end

    for _, index in pairs(toRemove) do
        table.remove(index)
    end
end

function Node:appendChild(node)
    if contains(self.__childNodes, node) then
        table.remove(self.__childNodes, indexOf(self.__childNodes, node))
    end

    table.insert(self.__childNodes, node)
end

function Node:_acloneNode(deep)
    error("Not Implemented; Node Specific. Requires cloning children, which is dependent on subclasses.")
end

function Node:_acompareDocumentPosition(other)
    if this == other then return 0 end

    local node1 = other
    local node2 = self

    if type(node1) == "Attr" then 
        attr1 = node1
        node1 = attr1.ownerElement
    end

    if type(node2) == "Attr" then 
        attr2 = node2
        node2 = attr2.ownerElement

        if attr1 ~= nil and node1 ~= nil and node2 == node1 then
            for k, v in pairs(attr1.attributes) do -- temp name
                if v = attr1 then
                    return Node.DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC + Node.DOCUMENT_POSITION_PRECEDING
                else if v = atte2 then
                    return Node.DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC + Node.DOCUMENT_POSITION_FOLLOWING
                end
    
            end
        end
    end

    if node1 == nil or node2 == nil, or node1:getRootNode() ~= node2:getRootNode() then
        return Node.DOCUMENT_POSITION_DISCONNECTED + Node.DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC + Node.DOCUMENT_POSITION_PRECEDING
    end

    if (node1:contains(node2) and attr1 == nil) or (node1 == node2 and attr2 ~= nil) then
        return Node.DOCUMENT_POSITION_CONTAINS + Node.DOCUMENT_POSITION_PRECEDING
    end

    if (node2:contains(node1) and attr2 == nil) or (node1 == node2 and attr1 ~= nil) then
        return Node.DOCUMENT_POSITION_CONTAINED_BY + Node.DOCUMENT_POSITION_FOLLOWING
    end

    local siblings = node1.parentNode.childNodes

    if indexOf(siblings, node1) < indexOf(siblings, node2) then
        return Node.DOCUMENT_POSITION_PRECEDING
    else
        return Node.DOCUMENT_POSITION_FOLLOWING
    end
end

function Node:contains(other)
    return self == other or contains(descendants(self), other)
end

function Node:getRootNode(options)
    if self._parentNode then
        if type(self._parentNode) ~= "ShadowRoot" or options.composed then
            return self._parentNode:getRootNode()
        end
    end
    return self
end

function Node:_ahasChildNodes()
    return #self.childNodes > 0
end

function Node:_ainsertBefore(node, child)
    if contains(node, )
end

function Node:isDefaultNamespace(uri)
    error("Not currently implemented yet!")
end

function Node:isEqualNode(other)
    error("Not currently implemented yet!")
end

function Node:isSameNode(other)
    return self == other
end

function Node:lookupNamespaceURI(prefix)
    error("Not currently implemented yet!")
end

function Node:_aremoveChild(child)
    error("Not Implemented! Dependent on children!")
end

function Node:_areplaceChild(child)
    error("Not Implemented! Dependent on children!")
end

function Node:tostring()
    return "Node object"
end

function Node:_gchildNodes()
    return self.__childNodes
end

local function manualNodeConstructor()
    local o = {}
    o.children = {}
    setmetatable(o, Node)
    return o
end

local x = manualNodeConstructor()
local y = manualNodeConstructor()
local z = manualNodeConstructor()


x.children[1] = y
x.children[2] = z

x.children[2].children[1] = manualNodeConstructor()

pretty.pretty_print(x.childNodes)

return Node
    error("Not Implemented!")
end

function Node:isDefaultNamespace(uri)
    error("Not currently implemented yet!")
end

function Node:isEqualNode(other)
    error("Not currently implemented yet!")
end

function Node:isSameNode(other)
    return self == other
end

function Node:lookupNamespaceURI(prefix)
    error("Not currently implemented yet!")
end

function Node:_anormalize()
    error("Not Implemented yet! ")
end

function Node:_aremoveChild(child)
    error("Not Implemented! Dependent on children!")
end

function Node:_areplaceChild(child)
    error("Not Implemented! Dependent on children!")
end

function Node:tostring()
    return "Node object"
end

function Node:_gchildNodes()
    self.__childNodes
end


local function manualNodeConstructor(str) 
    local o = {}
    o.children = {}
    o.str = str

    o.__childNodes = {}
    setmetatable(o, Node)
    return o
end

local x = manualNodeConstructor("x")
local y = manualNodeConstructor("y")
local z = manualNodeConstructor("z")


table.insert(x.children, y)
table.insert(x.children, z)

pretty.pretty_print(x.childNodes)
read()
x.children[1].children[1] = manualNodeConstructor("p")


c = x.childNodes
pretty.pretty_print(c)

read()
x.children[2].children[1] = manualNodeConstructor("g")

x:__refreshChildNodes()
pretty.pretty_print(c)

return Node

