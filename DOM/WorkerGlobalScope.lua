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

---WorkerGlobalScope serves as the base class for specific types of worker global scope objects, including DedicatedWorkerGlobalScope, SharedWorkerGlobalScope, and ServiceWorkerGlobalScope.

---[ ] - unimplemented, [x] - implemented fully, [a] - abstract method/property, [*] - implemented and tested
--- **** WorkerGlobalScope - Abstract ****
---
--- [x] 

--- [x]


local WorkerGlobalScope = {
}

WorkerGlobalScope = extend(EventTarget, "WorkerGlobalScope", WorkerGlobalScope)

