--用于定义所有让C++调用的lua函数
module(..., package.seeall)

local symbol = (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID or CC_TARGET_PLATFORM == CC_PLATFORM_IOS) and "<br>" or "\r\n"

local function tostringex(v, len)
	if len == nil then len = 0 end

	local pre = string.rep('\t', len)
	local ret = ""
	if type(v) == "table" then
		if len > 5 then return "\t{ ... }" end
		local t = ""
		local j = 0
		for k, v1 in pairs(v) do
			t = t .. "\n\t" .. pre .. tostring(k) .. ":"
			t = t .. tostringex(v1, len + 1)
			
			j = j+ 1
			if j > 3 then break end
		end

		if t == "" then
			ret = ret .. pre .. "{ }\t(" .. tostring(v) .. ")"
		else
			if len > 0 then
				ret = ret .. "\t(" .. tostring(v) .. ")\n"
			end

			ret = ret .. pre .. "{" .. t .. "\n" .. pre .. "}"
		end
	else
		ret = ret .. pre .. tostring(v) .. "\t(" .. type(v) .. ")"
	end

	return ret
end

local function tracebackex(fromLevel)
	local ret = ""
	local level = fromLevel or 1
	
	while true do
		--get stack info
		local info = debug.getinfo(level, "Sln")
		if not info then
			break 
		else
			if ret ~= "" then
				ret = ret .. "<br>"
			end
			ret = string.format("%s[%s]:%d in %s \"%s\"", ret, info.source, info.currentline, info.namewhat ~= "" and info.namewhat or "''", info.name or "")
		end
		
		--打印变量
		-- local i = 1
		-- while true do
		-- 	local name, value = debug.getlocal(level, i)

		-- 	if not name then break end
		
		-- 	ret = ret .. "\t" .. name .. " =\t" .. tostringex(value, 3) .. "\n"
		-- 	i = i + 1
		-- end
		
		level = level + 1
	end
	
	return ret
end

local preErrTime = 0
local prevErrMsg = nil

local function errorTraceback(msg)
	if Dispatcher then
		Dispatcher.dispatchEvent(EventType.loading_tipsFont,"初始化环境异常")
	end
	local traceback = tracebackex(3)
	local errStr = string.format(
[[
-----------------LUA ERROR-----------------------
%s
-------------->>>>>>>>> stack >>>>>>>>>--------------
%s
-----------------------------------------------------
]]
		,tostring(msg) 
		,traceback
	)

	LuaLogE(string.gsub(errStr, "<br>","\r\n"))
	errStr = string.gsub(errStr, "\n", "<br>")
	errStr = string.gsub(errStr, "\r\n", "<br>")	
	
	local curTime = os.time()
	local diff = curTime-preErrTime

	if prevErrMsg ~= msg or diff > 5 then
		prevErrMsg = msg
		preErrTime = curTime
		PHPUtil.reportBug(BugInfoType.LUA_ERROR, errStr)
		SDKUtil.reportBuglyLuaError(string.format("[%s]%s",__SCRIPT_VERSION__,msg),string.gsub(traceback, "<br>","\r\n"))
	end
	if _G["GMView"] then
		GMView.staticCall("showLuaError",msg)
	end
	return msg
end

------------------------------------------------
--注册给c++调用
------------------------------------------------
rawset(_G, "__G__TRACKBACK__", errorTraceback)

