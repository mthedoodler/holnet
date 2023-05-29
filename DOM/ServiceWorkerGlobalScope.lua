local classutils = require("classutils")
local tableutils = require("tableutils")
local DOMutils = require("DOMutils")
local pretty = require("cc.pretty")

local Event = require("DOM.Event")
local EventTarget = require("DOM.EventTarget")
local WorkerGlobalScope = require("DOM.WorkerGlobalScope")

local type = classutils.type
local instanceof = classutils.instanceof
local class = classutils.class
local extend = classutils.extend
local expect = classutils.expect
local assertImplementsParent = classutils.assertImplementsParent

---A ServiceWorkerGlobalScope object represents the global execution context of a service worker.

---[ ] - unimplemented, [x] - implemented fully, [a] - abstract method/property, [*] - implemented and tested
--- **** WorkerGlobalScope - Abstract ****
---
--- [x] 

--- [x]


local ServiceWorkerGlobalScope = {
}

ServiceWorkerGlobalScope = extend(WorkerGlobalScope, "WorkerGlobalScope", ServiceWorkerGlobalScope)

function ServiceWorkerGlobalScope:addEventListener(...)
    print("Warning: EventTarget is a ServiceWorkerGlobalScope. This might give unexpected results.")
    EventTarget.addEventListener(self, table.unpack(arg))
end

function ServiceWorkerGlobalScope:removeEventListener(...)
    print("Warning: EventTarget is a ServiceWorkerGlobalScope. This might give unexpected results.")
    EventTarget.removeEventListener(self, table.unpack(arg))
end
