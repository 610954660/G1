--本地保存的用户设置数据
local  FileCacheManager = {}
local deviceId
local userData = cc.UserDefault:getInstance()

--检测值类型
local function checkValueType(value, valueType)
	if value==nil or type(value)~=valueType then
		print("FileCacheManager: the value type is not "..valueType.."!")
		return false
	end
	return true
end

--格式化key，加上玩家id
local function formatKey(key, useDeviceId)
	if not deviceId then
		deviceId = gy.GYDeviceUtil:getDeviceID()
	end
	local id = 0
	if not useDeviceId then
		if rawget(_G, "Cache") then
			id = ModelManager.PlayerModel and ModelManager.PlayerModel.userid or deviceId
		end
	else
		id = deviceId
	end
	return string.format("jz2_%s_%s", tostring(id), key)
end

--[[
获取本地保存的int数据
@param	key 			#string		字段key
@param	defaultValue	#int		找不到时的默认值
@param	useDeviceId		#boolean	是否使用设置id作为前缀，默认为false表示使用玩家的entityId作为前缀
@param	useRawKey		#boolean	使用原始key
]]
function FileCacheManager.getIntForKey(key, defaultValue, useDeviceId, useRawKey)
	if checkValueType(key, "string") and checkValueType(defaultValue, "number") then
		print(168, "useData path", cc.UserDefault:getXMLFilePath())
		return userData:getIntegerForKey(useRawKey and key or formatKey(key, useDeviceId), defaultValue)
	end
end
--[[
设置本地保存的int数据
@param	key 			#string		字段key
@param	value			#int		值
@param	useDeviceId		#boolean	是否使用设置id作为前缀，默认为false表示使用玩家的entityId作为前缀
@param	useRawKey		#boolean	使用原始key
]]
function FileCacheManager.setIntForKey(key, value, useDeviceId, useRawKey)
	if __AUTO_TEST__ or __QUICK_LOGIN_CONFIG__ then
		return
	end
	if checkValueType(key, "string") and checkValueType(value, "number") then
		userData:setIntegerForKey(useRawKey and key or formatKey(key, useDeviceId), value)
		userData:flush()
	end
end


--[[
获取本地保存的float数据
@param	key 			#string		字段key
@param	defaultValue	#float		找不到时的默认值
@param	useDeviceId		#boolean	是否使用设置id作为前缀，默认为false表示使用玩家的entityId作为前缀
@param	useRawKey		#boolean	使用原始key
]]
function FileCacheManager.getFloatForKey(key, defaultValue, useDeviceId, useRawKey)
	if checkValueType(key, "string") and checkValueType(defaultValue, "number") then
		return userData:getFloatForKey(useRawKey and key or formatKey(key, useDeviceId), defaultValue)
	end
end
--[[
设置本地保存的float数据
@param	key 			#string		字段key
@param	value			#float		值
@param	useDeviceId		#boolean	是否使用设置id作为前缀，默认为false表示使用玩家的entityId作为前缀
@param	useRawKey		#boolean	使用原始key
]]
function FileCacheManager.setFloatForKey(key, value, useDeviceId, useRawKey)
	if __AUTO_TEST__ then
		return
	end
	if checkValueType(key, "string") and checkValueType(value, "number") then
		userData:setFloatForKey(useRawKey and key or formatKey(key, useDeviceId), value)
		userData:flush()
	end
end

--[[
获取本地保存的boolean数据
@param	key 			#string		字段key
@param	defaultValue	#boolean	找不到时的默认值
@param	useDeviceId		#boolean	是否使用设置id作为前缀，默认为false表示使用玩家的entityId作为前缀
@param	useRawKey		#boolean	使用原始key
]]
function FileCacheManager.getBoolForKey(key, defaultValue, useDeviceId, useRawKey)

	if checkValueType(key, "string") and checkValueType(defaultValue, "boolean") then
		return userData:getBoolForKey(useRawKey and key or formatKey(key, useDeviceId), defaultValue)
	end
end
--[[
设置本地保存的boolean数据
@param	key 			#string		字段key
@param	value			#boolean	值
@param	useDeviceId		#boolean	是否使用设置id作为前缀，默认为false表示使用玩家的entityId作为前缀
@param	useRawKey		#boolean	使用原始key
]]
function FileCacheManager.setBoolForKey(key, value, useDeviceId, useRawKey)
	if __AUTO_TEST__ or __QUICK_LOGIN_CONFIG__ then
		return
	end
	if checkValueType(key, "string") and checkValueType(value, "boolean") then
		userData:setBoolForKey(useRawKey and key or formatKey(key, useDeviceId), value)
		userData:flush()
	end
end

--[[
设置本地保存的boolean数据
@param	key 			#string		字段key
@param	value			#string	值
@param	useDeviceId		#boolean	是否使用设置id作为前缀，默认为false表示使用玩家的entityId作为前缀
@param	useRawKey		#boolean	使用原始key
]]
function FileCacheManager.setStringForKey(key, value, useDeviceId, useRawKey)
	if __AUTO_TEST__ or __QUICK_LOGIN_CONFIG__ then
		return
	end
	if checkValueType(key, "string") and checkValueType(value, "string") then
		userData:setStringForKey(useRawKey and key or formatKey(key, useDeviceId), value)
		userData:flush()
	end
end

--[[
获取本地保存的boolean数据
@param	key 			#string		字段key
@param	defaultValue	#string	找不到时的默认值
@param	useDeviceId		#boolean	是否使用设置id作为前缀，默认为false表示使用玩家的entityId作为前缀
@param	useRawKey		#boolean	使用原始key
]]
function FileCacheManager.getStringForKey(key, defaultValue, useDeviceId, useRawKey)
	if checkValueType(key, "string") and checkValueType(defaultValue, "string") then
		return userData:getStringForKey(useRawKey and key or formatKey(key, useDeviceId), defaultValue)
	end
end

function FileCacheManager.deleteValueForKey(key)
	if __AUTO_TEST__  or __QUICK_LOGIN_CONFIG__ then
		return defaultValue
	end
	if checkValueType(key, "string") then
		userData:deleteValueForKey(key)
		userData:flush()
	end
end

return FileCacheManager