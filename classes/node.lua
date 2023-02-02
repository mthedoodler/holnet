--Node 'Interface' according to DOM Level 1, implemented as an 'abstract' class

Node = {}

local self = {}
    
Node.ELEMENT_NODE = 1
Node.ATTRIBUTE_NODE = 2
Node.TEXT_NODE = 3
Node.CDATA_SECTION_NODE = 4
Node.ENTITY_REFRENCE_NODE = 5 --Legacy
Node.ENTITY_NODE = 6 --Legacy
Node.PROCESSING_INSTRUCTION_NODE = 7
Node.COMMENT_NODE = 8
Node.DOCUMENT_NODE = 9
Node.DOCUMENT_TYPE_NODE = 10
Node.DOCUMENT_FRAGMENT_NODE = 11
Node.NOTATION_NODE = 12 --Legacy

function Node:new(o)
    --Constructor
    self.nodeType = ""
    self.nodeName = ""

    self.baseURI = ""

    self.isConnected = ""
    self.ownerDocument = ""
    self.parentNode = ""
    self.hasChildNodes = ""
    self.firstChild = ""
    self.lastChild = ""
    self.previousSibling = ""
    self.nextSibling = ""

    self.nodeValue = ""
    self.textContent = ""

    self.isEqualNode()

    setmetatable(o, self)
    OrderedSet.__index = self
    return o
end

function Node:getRootNode()
    error("NotImplementedError")
end

function Node:normalize()
    error("NotImplementedError")
end

function Node:hasChildNodes()
    error("NotImplementedError")
end

function Node:cloneNode()
    error("NotImplementedError")
end
