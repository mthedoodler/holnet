Node = require("Node").Node

DocumentType = {publicID = "", systemID = "", name=""}

DocumentType.__newIndex = function(tbl, key, value)
    error("Attempt to modify read-only attribute " .. key, 2)
end

function DocumentType:new(o)
    local o = o or {}
    setmetatable(o, DocumentType)
    self.__index = self
    return o
end

Document = {
    URL = "about:blank",
    documentURI = URL,
    compatMode = nil,
    characterSet = nil,
    charset = characterSet,
    inputEncoding = characterSet,
    contentType = "",
    doctype = {},
    documentElement = {}
}

local readOnly = {
  URL = true,
  documentURI = true,
  compatMode = true,
  characterSet = true,
  charset = true,
  inputEncoding = true,
  contentType = true
}


Document.__newindex = function(tbl, key, value)
    print(key)
  if readOnly[key] then
    error("Attempt to modify read-only attribute " .. key, 2)
  end
  Node.__newindex(tbl, key, value)
end

function Document:new()
    local o = o or Node:new()
    setmetatable(o, Document)
    self.__index = self
    return o
end

Document:new().URL = false

