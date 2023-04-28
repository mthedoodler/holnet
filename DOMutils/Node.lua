local classutils = require("classutils")
local tableutils = require("tableutils")
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
}

local x = {67,26,63,34,15}
print(indexOf(x, 63))


Node = class("Node", Node)

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

function Node:_aappendChild(node)
    error("Not Implemented; Node Specific. Children depends on Node types.")
end

function Node:_acloneNode(deep)
    error("Not Implemented; Node Specific. Requires cloning children, which is dependent on subclasses.")
end

function Node:_acompareDocumentPosition(other)
    error("Will implement later!")
end

function Node:contains(other)
    return other == self or contains(self.childNodes, other)
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
    error("Not Implemented Yet! Dependent on Children!")
end

function Node:_ainsertBefore(node)
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

return Node

