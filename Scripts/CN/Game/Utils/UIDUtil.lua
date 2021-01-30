local UIDUtil = {}
local _dispatcherId = 0

local _eventId = 100000000000

local _moduleId = 0

local _uid = 0

--获取全局唯一的id
function UIDUtil.getUID()
	_uid = _uid + 1
	return _uid
end

--获取事件发布器的唯一id
function UIDUtil.getDispatcherUID()
	_dispatcherId = _dispatcherId + 1
	return _dispatcherId
end

--事件名的唯一id
function UIDUtil.getEventUID()
	_eventId = _eventId + 1
	return _eventId
end

--模块的唯一id
function UIDUtil.getModuleUID()
	_moduleId = _moduleId + 1
	return _moduleId
end

return UIDUtil