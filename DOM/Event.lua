local classutils = require("classutils")
local tableutils = require("tableutils")
local pretty = require("cc.pretty")

local type = classutils.type
local instanceof = classutils.instanceof
local class = classutils.class
local extend = classutils.extend
local expect = classutils.expect
local assertImplementsParent = classutils.assertImplementsParent

--- **** Event ****
--- [x] type - readonly string 
--- [x] target - readonly EventTarget?
--- [ ] srcElement - readonly EventTarget? //legacy
--- [ ] currentTarget - readonly EventTarget? 
--- [ ] eventPhase - readonly number
--- [x] cancelBubble - boolean //legacy alias of .stopPropagation() - uses getters and setters for the dlag
--- [x] bubbles - readonly boolean
--- [x] cancelable - readonly boolean
--- [x] returnValue - public boolean //legacy - uses getters and setters for the flag
--- [x] defaultPrevented - readonly boolean- uses getter
--- [x] composed - readonly boolean - getter for the flag
--- [x] isTrusted - readonly unforegable boolean 
--- [x] timeStamp - readonly number (DOMHighResTimeStamp)
--- [ ]
--- [ ]

--- [x] Event(string, table)
--- [ ] composedPath() - table<EventTarget> (sequence)
--- [x] stopPropagation() - nil
--- [ ] stopImmediatePropagation() - nil
--- [ ] preventDefault()
--- [x] initEvent(String, boolean?, boolean?)

Event = {

    --Static variables
    NONE = 0,
    CAPTURING_PHASE = 1,
    AT_TARGET = 2,
    BUBBLING_PHASE = 3,

    isTrusted = "boolean",
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
    __dispatchFlag = false
}

Event = class("Event", Event)


function Event:new(_type, eventInitDict)
    expect(1, _type, "string")
    if eventInitDict then
        expect(2, eventInitDict, "table")
    end
    
    o = setmetatable({}, Event)
    o.__initializedFlag = true

    o._timeStamp = 

    setmetatable(o, Event)

    o:initEvent(_type, bubbles, cancelable)
    
    return o
end

function Event:initEvent(_type, bubbles, cancelable)
    expect(1, _type, "string")
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




