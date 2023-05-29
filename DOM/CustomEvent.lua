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

-- [ ] - unimplemented, [x] - implemented fully, [a] - abstract method/property, [*] - implemented and tested
--- **** CustomEvent ****
--- [x] detail - readonly any 

--- [x] initCustomEvent(type, bubbles, cancelable, detail)

local Event = require("DOM.Event")

local CustomEvent = {
    _detail = "any"
}

CustomEvent = extend(Event, "CustomEvent", CustomEvent)

function CustomEvent:new(_type, eventInitDict)
    local o = Event:new(_type, eventInitDict)
    setmetatable(o, CustomEvent)
    o._detail = eventInitDict.detail --Reduntant?
    return o
end

function CustomEvent:initCustomEvent(_type, bubbles, cancelable, detail)
    if self.__dispatchFlag then
        return
    end

    self._isTrusted = false
    self._target = nil
    self._type = _type
    self._bubbles = bubbles
    self._cancelable = cancelable
    self._detail = detail
end

return CustomEvent