----------------------------------------------------
-- 本文件用于游戏启动时读后台一段lua代码并执行，主要用于处理临时性的紧急安装包存在的bug（一般与更新相关）
----------------------------------------------------
local EmergencyMeasures = {}
--最大等级时间
local MAX_WAIT_COUNT = 9
--当前等待次数
local waitCount = 0
--定时器id
local schedulerId = false
--结束回调
local endCallback = false

local appVersion = __APP_VERSION__

local centerUrl =  AgentConfiger.centerURL .. "?action=start_check&"

local str1 = string.format("appVer=%s&time=%s", appVersion, os.time())

local str2 = str1..Fanren:getLogKey()

local str3 = FRMD5( str2, string.len(str2) )

local finalUrl = string.format("%s%s&sign=%s",centerUrl,str1,string.lower(str3))

--执行回调
local function runEndCallback()
	if type(endCallback) == "function" then
		endCallback()
	end
end

local function onCallback(dict)
	waitCount = 10
	
	local tmpStr = "-----Begin do string-----\ncheck url:%s\nstatus:%s, data:%s"
	tmpStr = string.format(tmpStr, finalUrl, tostring(dict.status), tostring(dict.data))
	LuaLog(tmpStr)
	
	local data = tostring(dict.data)
	if dict.status == 200 and data and data ~= "-1" and data ~= "-2" and data ~= "-3" and data ~= "" then
		dostring(data)
	end

	LuaLog("-----End do string-----")
end

local function onTick()
	waitCount = waitCount + 1
	if waitCount >= MAX_WAIT_COUNT then
		if schedulerId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerId)
			schedulerId = false
		end
		runEndCallback()
	end
end

--执行
function EmergencyMeasures.run(callback)
	if not schedulerId then
		FRHttpClient:toGet( onCallback, nil, finalUrl, false, true )

		waitCount = 0
		endCallback = callback
		schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onTick,0.1,false,10)
	end
end
