--Node = require("Node").Node

local function copyTable(datatable)
    local tblRes={}
    if type(datatable)=="table" then
      for k,v in pairs(datatable) do tblRes[k]=copyTable(v) end
    else
      tblRes=datatable
    end
    return tblRes
end

Element = Node:new()

Element_props = {
    assignedSlot = nil,
    attributes = {},
    childElementCount = 0,
    children = {},
    classList = {},
    className = "",
    clientHeight = nil,
    clientLeft = nil,
    clientRight = nil,
    clientTop = nil,
    clientBottom = nil,
    clientWidth = nil,
    elementTiming = "",
    firstElementChild = nil,
    id = "",
    innerHTML = "",
    lastElementChild = nil,
    localName = "",
    namespaceURI = "http://www.w3.org/1999/xhtml",
    nextElementSibling = nil,
    outerHTML = nil,
    part = nil,
    prefix = nil,
    previousElementSibling = nil,
    scrollHeight = nil,
    scrollLeft = nil,
    scrollLeftMax = nil,
    scrollTop = nil,
    scrollTopMax = nil,
    scrollWidth = nil,
    shadowRoot = nil,
    slot = "",
    tagName = "",

    nodeType = 1,
}

local readOnly = {
    assignedSlot,
    attributes,
    childElementCount,
    children,
    classList,
    clientHeight,
    clientLeft,
    clientTop,
    clientWidth,
    firstElementChild,
    lastElementChild,
    localName,
    namespaceURI,
    nextElementSibling,
    prefix,
    previousElementSibling,
    scrollHeight,
    scrollLeftMax,
    scrollTopMax,
    scrollWidth,
    shadowRoot,
    tagName
}


Element.__newindex = function(tbl, key, value)
    print(key)
    if readOnly[key] then
        error("Attempt to modify read-only attribute " .. key, 2)
    end
    if key == "children" then print("!") else end
    Node.__newindex(tbl, key, value)
end

function Element:appendChild(node)

    table.insert(self.children, node)
    if (type(node) == "number" or type(node) == "string") then
        error("Child must be a table.")
    end

    if (node.nodeType == 1) then
        for _, child in ipairs(node.children) do
            print(child)
            rawset(self, "childNodes", {self.childNodes, table.unpack(child.childNodes)})
        end
    end
end

function Element:cloneElement()
    return Element:new(copyTable(self))
end

function Element:compareDocumentPosition()
    error("Not Implemented!")
end

function Element:contains()
    error("Not Implemented!")
end

function Element:getRootElement()
    error("Not Implemented!")
end

function Element:hasChildElements()
    error("Not Implemented!")
end

function Element:insertBefore()
    error("Not Implemented!")
end

function Element:isDefaultNamespace()
    error("Not Implemented!")
end

function Element:isEqualElement()
    error("Not Implemented!")
end

function Element:isSameElement()
    error("Not Implemented!")
end

function Element:lookupNamespaceURI()
    error("Not Implemented!")
end

function Element:lookupPrefix()
    error("Not Implemented!")
end

--function Element:normalize()
  --  error("Not Implemented!")
--end

function Element:removeChild()
    error("Not Implemented!")
end

function Element:replaceChild()
    error("Not Implemented!")
end

x = Element:new()
x:appendChild(Element:new())
print(x.childNodes)