local classutils = require("classutils")

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
   _nextSibling = {},
   _nodeName = "",
   _nodeType = -1,
   nodeValue = 0,
   _ownerDocument = 0,
   _parentNode = {},
   _parentElement = {},
   _previousSibling = {},
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

Node = class("Node", Node)

local function Node:_aappendChild(node)
    error("Not Implemented!")
end

local function Node:_acloneNode(other)
    error("Not Implemented!")
end

local function Node:compareDocumentPosition(other)
    error("Not currently implemented yet!")
end

local function Node:_acontains(other)
    error("Not Implemented")
end

local function Node:getRootNode()
    if self._parentNode then
        return self._parentNode:getRootNode()
    else
        return self
    end
end

local function Node:_ahasChildNodes()
    error("Not Implemented!")
end

local function Node:_ainsertBefore(node)
    error("Not Implemented!")
end

local function Node:isDefaultNamespace(uri)
    error("Not currently implemented yet!")
end

local function Node:isEqualNode(other)
    error("Not currently implemented yet!")
end

local function Node:isSameNode(other)
    return self == other
end

local function Node:lookupNamespaceURI(prefix)
    error("Not currently implemented yet!")
end

local function Node:_anormalize()
    error("Not Implemented!")
end

local function Node:_aremoveChild(child)
    error("Not Implemented!")
end

local function Node:_areplaceChild(child)
    error("Not Implemented!")
end

local function Node:tostring()
    return "Node object"
end

return Node

