---@diagnostic disable: duplicate-set-field, lowercase-global, duplicate-index
Node = {
    attributes = {},
    baseURI = "",
    childNodes = {},
    firstChild = nil,
    isConnected = false,
    lastChild = nil,
    nextSibling = nil,
    nodeName = nil,
    nodeType = nil,
    nodeValue = nil,
    ownerDocument = nil, 
    parentElement = nil,
    parentNode = nil,
    previousSibling = nil,
    textContent= ""
}

readOnly = {
  baseURI = true,
  childNodes = true,
  firstChild = true,
  lastChild = true,
  isConnected = true,
  lastChild = true,
  nextSibling = true,
  nodeName = true,
  nodeType = true,
  ownerDocument = true,
  parentNode = true,
  parentElement = true,
  previousSibling = true
}


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


Node.__newindex = function(tbl, key, value)
  if readOnly[key] then
    error("Attempt to modify read-only attribute " .. key, 2)
  end
  rawset(tbl, key, value)
end

function Node:new(o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Node:appendChild()
  error("Not Implemented!")
end

function Node:cloneNode()
  error("Not Implemented!")
end

function Node:compareDocumentPosition()
  error("Not Implemented!")
end

function Node:contains()
  error("Not Implemented!")
end

function Node:getRootNode()
  error("Not Implemented!")
end

function Node:hasChildNodes()
  error("Not Implemented!")
end

function Node:insertBefore()
  error("Not Implemented!")
end

function Node:isDefaultNamespace()
  error("Not Implemented!")
end

function Node:isEqualNode()
  error("Not Implemented!")
end

function Node:isSameNode()
  error("Not Implemented!")
end

function Node:lookupNamespaceURI()
  error("Not Implemented!")
end

function Node:lookupPrefix()
  error("Not Implemented!")
end

function Node:normalize()
  error("Not Implemented!")
end

function Node:removeChild()
  error("Not Implemented!")
end

function Node:replaceChild()
  error("Not Implemented!")
end


return {Node=Node}