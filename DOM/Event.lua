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
--- **** Event ****
--- [x] type - readonly string 
--- [x] target - readonly EventTarget?
--- [x] srcElement - readonly EventTarget? //legacy
--- [x] currentTarget - readonly EventTarget? 
--- [x] eventPhase - readonly number
--- [x] cancelBubble - boolean //legacy alias of .stopPropagation() - uses getters and setters for the dlag
--- [x] bubbles - readonly boolean
--- [x] cancelable - readonly boolean
--- [x] returnValue - public boolean //legacy - uses getters and setters for the flag
--- [x] defaultPrevented - readonly boolean- uses getter
--- [x] composed - readonly boolean - getter for the flag
--- [x] isTrusted - readonly unforegable boolean 
--- [x] timeStamp - readonly number (DOMHighResTimeStamp)

--- [x] Event(string, table)
--- [x] composedPath() - table<EventTarget> (sequence)
--- [x] stopPropagation() - nil
--- [x] stopImmediatePropagation() - nil
--- [x] preventDefault()
--- [x] initEvent(String, boolean?, boolean?)

local Event = {

    --Static variables
    NONE = 0,
    CAPTURING_PHASE = 1,
    AT_TARGET = 2,
    BUBBLING_PHASE = 3,

    _isTrusted = "boolean",
    _timeStamp = "number",

    _type = "string?",

    --Options
    _bubbles = "boolean",
    _cancelable = "boolean",
    _gcomposed = "boolean",
    _gcancelBubble = "boolean",
    _scancelBubble = "boolean",
    _greturnValue = "boolean",
    _sreturnValue = "boolean",

    --Targets
    _target = "EventTarget?",
    _currentTarget = "EventTarget?",
    _srcElement = "EventTarget?",
    _relatedTarget = "EventTarget?", -- defined by other shit
    _touchTargetList = "table", --defined by other shit

    --Flags
    _eventPhase = 0, --Event.NONE
    _gdefaultPrevented = false,

    __stopPropagationFlag = false,
    __stopImmediatePropagationFlag = false,
    __stopProgagationFlag = false,
    __cancelledFlag = false,
    __inPassiveListenerFlag = false,
    __composedFlag = false,
    __initializedFlag = false,
    __dispatchFlag = false,

    --Path for composedPath()
    __path = {}
}

Event = class("Event", Event)

local function innerEventCreationSteps(eventInitDict)
    local o = setmetatable({}, Event)
    o.__initializedFlag = true

    o._timeStamp = relativeHighResolutionCoarseTime(os.clock())
    o._touchTargetList = {}
    eventInitDict = eventInitDict or {}
    for k, v in pairs(eventInitDict) do
        if Event[k] or Event["_" .. k] then
            o["_" .. k] = v
        end
    end

    return o
end

function Event:new(_type, eventInitDict)
    expect(1, _type, "string")
    if eventInitDict then
        expect(2, eventInitDict, "table")
    end

    local o = innerEventCreationSteps(eventInitDict)

    o._type = _type
    o._isTrusted = true

    o._relatedTarget = nil --Fixes dispatchEvent()

    return o
end

function Event:initEvent(_type, bubbles, cancelable)
    expect(1, _type, "string")
    expect(2, bubbles, "boolean")
    expect(3, cancelable, "boolean")

    if self.__dispatchFlag then
        return
    end

    self._isTrusted = false
    self._target = nil
    self._type = _type
    self._bubbles = bubbles
    self._cancelable = cancelable
end

function Event:stopPropagation()
    self.__stopPropagationFlag = true
end

function Event:_gcancelBubble()
    return self.__stopPropagationFlag
end

function Event:_scancelBubble(bool)
    expect(1, bool, "boolean")
    if bool == true then
        self.__stopPropagationFlag = true
    end
end

function Event:_greturnValue()
    return self.__cancelledFlag
end

function Event:_sreturnValue(bool)
    expect(1, bool, "boolean")
    if bool == false then
        if self.cancellabe and self.__inPassiveListenerFlag == false then
            self.__cancelledFlag = true
        end
    end
end

function Event:composedPath()
    local composedPath = {}
    local path = self.__path
    if #path == 0 then return shallowclone(path) end

    local currentTarget = self._currentTarget
    table.insert(composedPath, currentTarget)

    local currentTargetIndex = 1
    local currentTargetHiddenSubtreeLevel = 1
    local index = #path

    while index > 1 do
        if path[index].rootOfClosedTree then
            currentTargetHiddenSubtreeLevel = currentTargetHiddenSubtreeLevel + 1
        end
        if path[index].invocationTarget == currentTarget then
            currentTargetIndex = index
            break
        end
        if path[index].slotInClosedTree then
            currentTargetHiddenSubtreeLevel = currentTargetHiddenSubtreeLevel - 1
        end
        index = index - 1
    end

    local currentHiddenLevel = currentTargetHiddenSubtreeLevel
    local maxHiddenlevel = currentTargetHiddenSubtreeLevel

    index = currentTargetIndex - 1

    while index > 1 do
        if path[index].rootOfClosedTree then
            currentHiddenLevel = currentHiddenLevel - 1
        end
        if currentHiddenLevel <= maxHiddenlevel then
            table.insert(composedPath, 1, path[index].invocationTarget)
        end
        if path[index].slotInClosedTree then
            currentHiddenLevel = currentHiddenLevel - 1
            if currentHiddenLevel < maxHiddenlevel then
                maxHiddenlevel = currentHiddenLevel
            end
        end
        index = index - 1
    end

    local currentHiddenLevel = currentTargetHiddenSubtreeLevel
    local maxHiddenlevel = currentTargetHiddenSubtreeLevel

    index = currentTargetIndex + 1

    while index <= #path do
        if path[index].slotInClosedTree then
            currentHiddenLevel = currentHiddenLevel + 1
        end
        if currentHiddenLevel <= maxHiddenlevel then
            table.insert(composedPath, #composedPath+1, path[index].invocationTarget)
        end
        if path[index].rootOfClosedTree then
            currentHiddenLevel = currentHiddenLevel - 1
            if currentHiddenLevel < maxHiddenlevel then
                maxHiddenlevel = currentHiddenLevel
            end
        end
        index = index + 1

    end

    return composedPath
end

function Event:stopImmediatePropagation()
    self.__stopPropagationFlag = true
    self.__stopImmediatePropagationFlag = true
end

function Event:preventDefault()
    if self.cancellabe and self.__inPassiveListenerFlag == false then
        self.__cancelledFlag = true
    end
end

function Event:_gdefaultPrevented()
    return self.__cancelledFlag
end

function Event:_gcomposed()
    return self.__composedFlag
end

--print(relativeHighResolutionCoarseTime(os.clock()))
local x = Event:new("test")
--print(x.timeStamp)
--print(x:composedPath())

return Event