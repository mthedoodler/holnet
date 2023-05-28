local classutils = require("classutils")
local tableutils = require("tableutils")

local type = classutils.type
local instanceof = classutils.instanceof
local class = classutils.class
local extend = classutils.extend
local expect = classutils.expect
local assertImplementsParent = classutils.assertImplementsParent

local Node = require("Node")

Document = {
    _implementation = {},
    _URL = "about:blank",
    _gdocumentURI = "about:blank", --Alias of URL
    _compatMode = "",
    _characterSet = "",
    _gcharset = "", --Alias of characterSet
    _ginputEncoding = "", --Alias of characterSet
    _contentType = "",
    _doctype = {name="html", publicId="", systemId=""},
    _documentElement = {}
}

Document = extend(Node, "Document", Document)

function Document:new(options)

