local classutils = require("classutils")
local tableutils = require("tableutils")
local DOMutils = require("DOMutils")
local pretty = require("cc.pretty")


local relativeHighResolutionCoarseTime = DOMutils.relativeHighResolutionCoarseTime
local type = classutils.type
local instanceof = classutils.instanceof
local class = classutils.class
local extend = classutils.extend
local expect = classutils.expect
local assertImplementsParent = classutils.assertImplementsParent

Window = {
    event = "Event"
}

Window = class("Window", Window)