--事件分发管理器
local Dispatcher = {}

--[[
    map<
        eventName,
        priorArray<{
            prior = integer
            callers = map_kv<maplistener,function>> 
        }>
]]
local eventMap = {}
--[[
    map<eventName:String,waitAddArray:Array>
]]
local _inDispatching_={}
local _mt_ = {__mode = "kv"}


function Dispatcher.clear()
    eventMap = {}
end

function Dispatcher.addEventListener(name, listenerCaller, priority)
    priority = priority or 1
	local opQueue = _inDispatching_[name]
    if opQueue then
        if opQueue == true then
            opQueue = {}
            _inDispatching_[name] = opQueue
        end
        table.insert(opQueue,function (  )
            --不让报错导致无法接受
            Dispatcher.addEventListener(name, listenerCaller, priority)
        end)
        return
    end
    
    local priorityArray = eventMap[name]
    if not priorityArray then
       priorityArray = {}
       eventMap[name] = priorityArray 
    end

    local callers, nowPriority
    for i,priorityItem in ipairs(priorityArray) do
        nowPriority = priorityItem.priority
        if nowPriority == priority then
            callers = priorityItem.callers
            break
        elseif nowPriority < priority then
            callers = setmetatable({},_mt_)
            local newPriorityItem = {priority = priority, callers = callers}
            table.insert(priorityArray,i,newPriorityItem)
            break
        end
    end
    if not callers then
        callers = setmetatable({},_mt_)
        local newPriorityItem = {priority = priority, callers = callers}
        table.insert(priorityArray,newPriorityItem)
    end
    --print(15,"callers[listenerCaller] = listenerCaller[name]", listenerCaller, listenerCaller[name])
    callers[listenerCaller] = listenerCaller[name]
    return true
end


function Dispatcher.removeEventListener(name, listenerCaller)
    local opQueue = _inDispatching_[name]
    if opQueue then
        if opQueue == true then
            opQueue = {}
            _inDispatching_[name] = opQueue
        end
        table.insert(opQueue,function (  )
            --不让报错导致无法接受
            Dispatcher.removeEventListener(name, listenerCaller)
        end)
        return
    end
    local priorityArray = eventMap[name]
    if priorityArray then
        local i = 1
        local len = #priorityArray
        while len >= i do
            local priorityItem = priorityArray[i]
            priorityItem.callers[listenerCaller] = nil
            if not next(priorityItem.callers) then
                table.remove(priorityArray,i)
                len = len - 1
            else
                i = i + 1
            end
        end
        if not next(priorityArray) then
            eventMap[name] = nil
        end
    end
end

--[[
发布事件
@name		[string]事件名
@...		其它参数
--]]
function Dispatcher.dispatchEvent(name, ...)
	local priorityArray = eventMap[name]
    --LuaLogE("Dispatcher.dispatchEvent(name, ...)",name)
    if not priorityArray then
        -- LuaLogE("Dispatcher.dispatchEvent(name, ...)111111",name)
        return
    end
    local opQueue = _inDispatching_[name]
    if opQueue then
        LuaLogE(DescAuto[38],name,debug.traceback()) -- [38]="在分发中再有相同事件分发出来，这是不正常的"
        return
    else
        _inDispatching_[name] = true
    end

    for i,priorityItem in ipairs(priorityArray) do
        for caller, func in pairs(priorityItem.callers) do
            --print(15,"call func !!!!aaa",caller,func)
            xpcall(func,__G__TRACKBACK__,caller,name,...)
        end
    end
    opQueue = _inDispatching_[name]
    _inDispatching_[name] = nil
    if opQueue and opQueue ~= true then
        for i,func in ipairs(opQueue) do
            xpcall(func,__G__TRACKBACK__)
        end
    end
end

--[[
是否存在该事件侦听
@name	事件名
--]]
function Dispatcher.hasEventListener(name)
    assert(type(name) == "string" or type(name) == "number", "Invalid event name of argument 1, need a string or number!")
    return __eventMap__[name] ~= nil
end

return Dispatcher
