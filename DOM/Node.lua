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


--- **** Node[Abstract] ****
--- [x] baseURI - readonly string
--- [x] childNodes - private readonlytable
--- [x] firstChild - getter Node
--- [x] isConnected - getter boolean
--- [x] lastChild - getter Node --These getters will need to be replaced with a traversal algorithim according to the DOM spec later, but they work for now.
--- [x] nextSibling - getter Node
--- [a] nodeName - readonly string
--- [a] nodeType - readonly number
--- [a] nodeValue - public string(any possibly)
--- [x] ownerDocument - readonly Document
--- [x] parentNode - readonly Node
--- [x] parentElement - readonly Element
--- [x] previousSibling - getter Node
--- [a] textContent - public string
 
--- [x] appendChild(Node) - nil --Add pre-inserstion validity here
--- [a] cloneNode() - Node - abstract 
--- [x] compareDocumentPosition(Node) - number
--- [x] contains(Node) - boolean
--- [x] getRootNode(table?) - Node --Doesn't include shadow roots
--- [x] hasChildNodes() - boolean
--- [x] insertBefore(Node, Node) - nil
--- [a] isDefaultNameSpace() - boolean - abstract 
--- [a] isEqualNode(Node) - boolean - Abstract
--- [x] isSameNode(Node) - boolean
--- [a] lookupPrefix(string) - string
--- [x] normalize() - nil
--- [x] removeChild(Node) - nil
--- [x] replaceChild(Node) - nil



local Node = {
    --Static readonly vars
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

    _DOCUMENT_POSITION_DISCONNECTED = 1,
    _DOCUMENT_POSITION_PRECEDING = 2,
    _DOCUMENT_POSITION_FOLLOWING = 4,
    _DOCUMENT_POSITION_CONTAINS = 8,
    _DOCUMENT_POSITION_CONTAINED_BY = 16,
    _DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC = 32,

    --For children/parents/siblings
    __children = {},
    _parentNode = {},

    _gchildNodes = {},

    _gparentElement = {},

    _gfirstChild = {},
    _glastChild = {},
    _gnextSibling = {},
    _gprevSibling = {},

    --For root purposes
    _ownerDocument = {},
    _gisConnected = false,

    --For URI purpuses
    _baseURI = "",

    --For type/value purposes
    __textContent = "",
    _gtextContent = "",
    _stextContent = "",
    _snodeValue = "",   
    _gnodeValue = -1,
    _gnodeType = "",
    _gnodeName = "",
    
    __tostring = function(t) return "Node " .. t.name end
}

Node = class("Node", Node)

local function nodelength(node)
    expect(1, node, "Node")

    typ = type(node)
    if typ == "DocumentType" or typ == "Attr" then
        return 0
    elseif typ == "CharacterData" then
        return node.length
    else
        return #node.__children
    end
end

local function descendants(node)
    local tbl = {}
    pretty.pretty_print(node)
    for _, child in ipairs(node.__children) do
        table.insert(tbl, child)
        for _, grandchild in pairs(descendants(child)) do
            table.insert(tbl, grandchild)
        end
    end

    return tbl
end

function Node:_gchildNodes()
    return makeReadOnlyProxy(self.__children)
end

function Node:_gparentElement()
    if type(self.parentNode) == "Element" then
        return self.parentNode
    else
        return nil
    end
end

function Node:_gnodeType()
    error("Not Implemented! Switches on type!")
end

function Node:_gnodeName()
    error("Not Implemented! Switches on type!")
end

function Node:removeChild(o)
    expect(1, o, "Node")

    pretty.pretty_print(o.__children)
    local index = indexOf(self.__children, o)
    if index ~= -1 then
        table.remove(self.__children, index)
    end

    o.__parentNode = nil
    return o
end

function Node:appendChild(o)
    expect(1, o, "Node")

    Node:removeChild(o)

    table.insert(self.__children, o)

    if type(o.parentNode) == "Node" then
        print(o.parentNode)
        o.parentNode:removeChild(o)
    end
    o._parentNode = self

    return o
end

function Node:replaceChild(o, ref)
    expect(1, o, "Node")
    expect(2, ref, "Node")

    if o == ref then
        return 
    end

    local index = indexOf(self.__children, ref)
    if index ~= -1 then
        table.remove(self.__children, index)
        table.insert(self.__children, index, o)
    end

    if type(o.parentNode) == "Node" then
        o.parentNode:removeChild(o)
    end

    o._parentNode = self
    return o
end


function Node:insertBefore(o, ref)
    expect(1, o, "Node")
    expect(2, ref, "Node")

    if o == ref then
        return
    end

    self:removeChild(o)

    local index = indexOf(self.__children, ref)
    if index ~= -1 then
        table.insert(self.__children, index, o)
    end

    if type(o.parentNode) == "Node" then
        print(o)
        o.parentNode:removeChild(o)
    end

    o._parentNode = self
    return o
end

function Node:_gfirstChild()
    return self.__children[1]
end

function Node:_glastChild()
    return self.__children[#self.__children]
end

function Node:_gnextSibling()
    if self._parentNode then
        local index = indexOf(self._parentNode.__children, self)
        return self._parentNode.__children[index + 1]
    end
end

function Node:_gprevSibling()
    if self._parentNode then
        local index = indexOf(self._parentNode.__children, self)
        return self._parentNode.__children[index - 1]
    end
end

function Node:getRootNode(options)
    if self.isConnected then return self.ownerDocument end

    if self._parentNode then return self._parentNode:getRootNode() end
    
    return self
end

function Node:hasChildNodes()
    return #self.__children > 0
end

function Node:contains(o)
    expect(1, o, "Node")

    if self == o then return true end

    for _, child in ipairs(self.__children) do
        if child:contains(o) then return true end
    end
    return false
end

function Node:_aisEqualNode(o)
    error("Not Implemented! Dependant on type of node")
end

function Node:isSameNode(o)
    expect(1, o, "Node")
    return self == o
end

function Node:_acompareDocumentPosition(other)
    if self == other then return 0 end

    local node1 = other
    local node2 = self
    local attr1, attr2
    if type(node1) == "Attr" then 
        attr1 = node1
        node1 = attr1.ownerElement
    end

    if type(node2) == "Attr" then 
        attr2 = node2
        node2 = attr2.ownerElement

        if attr1 ~= nil and node1 ~= nil and node2 == node1 then
            for k, v in pairs(attr1.attributes) do -- temp name
                if v == attr1 then
                    return Node.DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC + Node.DOCUMENT_POSITION_PRECEDING
                elseif v == attr2 then
                    return Node.DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC + Node.DOCUMENT_POSITION_FOLLOWING
                end
            end
        end
    end

    if node1 == nil or node2 == nil or node1:getRootNode() ~= node2:getRootNode() then
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

function Node:_gisConnected()
    return type(self.ownerDocument) == "Document"
end

function Node:normalize()

    local allChildren = descendants(self)
    local toRemove = {}
    local i = 1
    while i < #allChildren do --Marks text to remove instead of doing shit with length to shorten code.
        local node = allChildren[i]
        if type(node) == "Text" then
            local length = nodelength(self)

            if length == 0 then
                node.parentNode:remove(node)
            end

            local data = ""
            while true do
                i = i + 1
                local newNode = allChildren[i]
                if type(newNode) == "Text" then
                    data = data .. newNode.wholeText
                    table.insert(toRemove,newNode)
                else
                    break
                end
            end

            node._wholeText = data
            node.length = #data
        end
        i = i+1
    end

    for _, v in toRemove do
        self:removeChild(v)
    end
end

function Node:_aisDefaultNamespace(namespace)
    error("Not Implemented, switches on interfaces!")
end

function Node:_alookupNamespaceURI(prefix)
    error("Not Implemented, switches on interfaces!")
end

function Node:_acloneNode(prefix)
    error("Not Implemented, switches on interfaces!")
end

function Node:_gtextContent()
    error("Not Implemented, switches on interfaces!")
end

function Node:_stextContent()
    error("Not Implemented, switches on interfaces!")
end

function Node:_gnodeValue()
    error("Not Implemented, switches on interfaces!")
end

function Node:_snodeValue()
    error("Not Implemented, switches on interfaces!")
end

local function manualNodeConstructor(name)
    local o = {name=name}
    o.__children = {}
    o._parentNode = {}
    setmetatable(o, Node)
    return o
end

x = manualNodeConstructor("x")

local children = x.childNodes

x:appendChild(manualNodeConstructor("y"))
x:appendChild(manualNodeConstructor("z"))
print("!")

children[2]:appendChild(manualNodeConstructor("a"))
pretty.pretty_print(#children)
pretty.pretty_print(#children[2].childNodes)

--pretty.pretty_print(children[1].parentNode)
--pretty.pretty_print(children[1].nextSibling)
--pretty.pretty_print(children[2].prevSibling)
--pretty.pretty_print(children[1].prevSibling)
print("!")

--pretty.pretty_print(x.lastChild)
--pretty.pretty_print(x.firstChild)
--pretty.pretty_print(x.lastChild.firstChild)
--pretty.pretty_print(x.firstChild.firstChild)

x:appendChild(x.childNodes[1])
pretty.pretty_print(#children)
pretty.pretty_print(#children[1].childNodes)
pretty.pretty_print(x.childNodes[1])

print("!")
x:replaceChild(manualNodeConstructor("b"), x.childNodes[2])
pretty.pretty_print(x.childNodes[1])

x:insertBefore(manualNodeConstructor("c"), x.childNodes[1])

pretty.pretty_print(x.__children)
--pretty.pretty_print(x.childNodes[2])
--pretty.pretty_print(x.childNodes[3])

pretty.pretty_print(x:contains(manualNodeConstructor("no")))

--pretty.pretty_print(x.childNodes[1].__children)
pretty.pretty_print(x:contains(x.childNodes[2].__children[1]))
--pretty.pretty_print(x.childNodes[3].__children)
pretty.pretty_print(descendants(x))

return Node