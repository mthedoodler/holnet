local classutils = require("classutils")
local tableutils = require("tableutils")
local DOMutils = require("DOMutils")
local pretty = require("cc.pretty")

local Event = require("Event")
local Node = require("Node")
local ShadowRoot = require("ShadowRoot")

local relativeHighResolutionCoarseTime = DOMutils.relativeHighResolutionCoarseTime
local isDescendant = DOMutils.isDescendant

local type = classutils.type
local instanceof = classutils.instanceof
local class = classutils.class
local extend = classutils.extend
local expect = classutils.expect
local assertImplementsParent = classutils.assertImplementsParent


local function flattenOptions(options)
    if type(options) == "boolean" then return options else return options.capture end
end

local function flattenMoreOptions(options)
    local capture = flattenOptions(options)
    local once = false
    local passive, signal

    if type(options) == "table" then
        once = options.once
        passive = options.passive
        signal = options.signal
    end

    return capture, passive, once, signal
end

local PASSIVE_TYPES = {
    touchstart = true,
    touchmove = true,
    wheel = true,
    mousewheel = true
}

local function isPassiveEventTarget(eventTarget)
    local eventTargetType = type(eventTarget)
    if eventTargetType == "Window" then return true end
    if instanceof(eventTarget, Node) then
        return eventTarget.ownerDocument == eventTarget
            or eventTarget.documentElement == eventTarget
            or eventTarget.ownerDocument.body == eventTarget
    end
end

local function defaultPassiveValue(_type, eventTarget)
    return PASSIVE_TYPES[_type] and isPassiveEventTarget(eventTarget)
end

local function addAnEventListener(eventTarget, listener)
    if listener.signal then
        if listener.signal.reason then return end
    end

    if listener.callback == nil then
        return
    end

    if listener.passive == nil then
        listener.passive = defaultPassiveValue(listener.type, eventTarget)
    end

    for _, v in pairs(eventTarget.__listeners) do
        if shallowequals(v, listener) then
            return
        end
    end

    table.insert(eventTarget.__listeners, listener)

    if listener.signal then
        table.insert(listener.signal.__algorithims, function() return "Placeholder" end)
    end
end

local function removeAnEventListener(eventTarget, listener)
    local i = 1
    for _, targetListener in pairs(eventTarget.__listeners) do
        if shallowequals(targetListener, listener) then
            break
        end
        i = i+1
    end

    listener.removed = true
    table.remove(eventTarget.__listeners, i)
end

local function retarget(A, B)
    while true do
        if (not instanceof(A, Node)
            or not instanceof(A:getRootNode(), ShadowRoot) 
            or (instanceof(B, Node) and (isDescendant(B, A) or A==B))
        ) then return A end
        
        A = A:getRootNode().host
    end
end


local function appendToAnEventPath(event, invocationTarget, shadowAdjustedTarget, relatedTarget, touchTargets, slotInClosedTree)
    local invocationTargetInShadowTree = false
    
    if instanceof(invocationTarget, Node) and type(invocationTarget:getRootNode()) == "ShadowRoot" then
        invocationTargetInShadowTree = true
    end

    local rootOfClosedTree = false
    if type(invocationTarget) == "ShadowRoot" and invocationTarget.mode == "closed" then
        rootOfClosedTree = true
    end

    table.insert(event.__path, {
        invocationTarget = invocationTarget,
        invocationTargetInShadowTree = invocationTargetInShadowTree,
        shadowAdjustedTarget = shadowAdjustedTarget,
        relatedTarget = relatedTarget,
        touchTargetList = touchTargets,
        rootOfClosedTree = rootOfClosedTree,
        slotInClosedTree = slotInClosedTree
    })
end


local function dispatch(target, event, legacyTargetOverrideFlag, legacyOutputDidListenersThrowFlag)
    event.__dispatchFlag = true
    local targetOverride
    if legacyTargetOverrideFlag then targetOverride = target.document else targetOverride = target end

    local activationTarget
    local relatedTarget = retarget(event._relatedTarget or nil, target)

    if target ~= relatedTarget or target == event._relatedTarget then
        local touchTargets = {}
        local touchTargetList = event.touchTargetList or {}
        for _, touchTarget in pairs(touchTargetList) do
            table.insert(touchTargets, retarget(touchTarget, target))
        end

        appendToAnEventPath(event, target, targetOverride, relatedTarget, touchTargets, false)

        local isActivationEvent = type(event) == "MouseEvent" and event.type == "click"
        if isActivationEvent and target.__activationBehaviour then
            activationTarget = target
        end

        local slottable
        if (type(target) == "Element" or type(target) == "Text") and target.slot then
            slottable = target
        end

        local slotInClosedTree = false

        local parent = event.__getTheParent()

        while parent ~= nil do
            if slottable ~= nil then
                assert(parent ) --is Slot
            end
        end
    end
end

---An EventTarget object represents a target to which an event can be dispatched when something has occurred.

---[ ] - unimplemented, [x] - implemented fully, [a] - abstract method/property, [*] - implemented and tested
--- **** EventTarget - Abstract ****
---
--- [x] 

--- [x] addEventListener(string, function/EventListener, boolean/table) - nil -callback interface for EventListener; table with handleEvent
--- [x] removeEventListener(string, function/EventListener, boolean/table) - nil
--- [x] dispatchEvent(Event) - nil

local EventTarget = {
    __listeners = {}, --Event listener list
    _a__getTheParent = "function", --Get the parent algorithim, which all subclasses override.
    __relatedTarget = "EventTarget"
}

EventTarget = class("EventTarget", EventTarget)

function EventTarget:new()
    return setmetatable({}, EventTarget)
end

function EventTarget:addEventListener(_type, callback, options)
    expect(1, _type, "string")
    expect(2, callback, "function", "table", "nil")
    expect(3, options, "boolean", "table", "nil")
    
    options = options or {}
    local capture, passive, once, signal = flattenMoreOptions(options)
    
    local listener = {
        type = _type,
        callback = callback,
        capture = capture,
        passive = passive,
        once = once,
        signal = signal,
        removed = false
    }

    addAnEventListener(self, listener)
end

function EventTarget:removeEventListener(_type, callback, options)
    local capture = flattenOptions(options)

    for _, listener in pairs(self.__listeners) do
        if listener.__type == _type and listener.callback == callback and listener.capture == capture then
            removeAnEventListener(self, listener)
        end
    end
end

function EventTarget:_a__getTheParent()
    return nil
end

--function EventTarget:__activationBehaviour(event)
    --return nil
--end

function EventTarget:dispatchEvent(event)
    if event.__dispatchFlag then
        error("InvalidStateError: DOMException", 2)
    end

    event._isTrusted = false

    dispatch(self, event)
end

expect(1, x, "number")


