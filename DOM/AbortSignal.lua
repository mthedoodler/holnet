local classutils = require("classutils")
local tableutils = require("tableutils")
local DOMutils = require("DOMutils")
local pretty = require("cc.pretty")

local Event = require("DOM.Event")
local EventTarget = require("DOM.EventTarget")

local relativeHighResolutionCoarseTime = DOMutils.relativeHighResolutionCoarseTime
local type = classutils.type
local instanceof = classutils.instanceof
local class = classutils.class
local extend = classutils.extend
local expect = classutils.expect
local assertImplementsParent = classutils.assertImplementsParent

---[ ] - unimplemented, [x] - implemented fully, [a] - abstract method/property, [*] - implemented and tested
--- **** AbortSignal - Abstract ****
---
--- [ ] aborted - readonly boolean
--- [ ] reason - readonly any
--- [ ] onabort - function(EventHandler)

--- [ ] abort(any) - AbortSignal static
--- [ ] timeout(number) - AbortSignal static
--- [ ] _any(sequence<AbortSignal>) signals 
--- [ ] throwIfAborted() - nil

local AbortSignal = {
    __algorithims = {},
    _aborted = false,
    _reason = "",

}

local function newAbortSignal()
    local o = setmetatable({}, AbortSignal)
    
    o.__algorithims = OrderedSet({})
end
AbortSignal = extend(EventTarget, "WorkerGlobalScope", AbortSignal)

function AbortSignal:addEventListener(...)
    print("Warning: EventTarget is a ServiceWorkerGlobalScope. This might give unexpected results.")
    EventTarget.addEventListener(self, table.unpack(arg))
end

