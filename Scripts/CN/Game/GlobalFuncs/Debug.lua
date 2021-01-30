local logFunc = (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID or CC_TARGET_PLATFORM == CC_PLATFORM_IOS) and LuaLogE or LuaLog

--测试状态用来隐藏测试按钮
__HIDE_TEST__ = true

--普通打印
print = function (printId,...)
	local pid = ""
	for i=1,1 do
		if __IS_RELEASE__ then
			if __SCRIPT_VERSION__ == "99999999" then
				if type(printId) == "number" then
					pid = string.format("[pid:%d]",printId)
				else
					pid = "[pid:nil]"
				end
				break--正式包情况下，我们默认把log打印出来。
			else
				return
			end
		end
		if __PRINT_TYPE__ ~= printId then
			return
		end
	end

	local argsLen = gyGetArgsNum(...)
	local msg = ""
	if __PRINT_WITH_FILE_LINE__ then
		local traceback = string.split(debug.traceback("", 2), "\n")
		msg = string.format("print from: %s\n", string.trim(traceback[3]))
	end

	local args = {...}
	for i = 1, argsLen do
		msg = string.format("%s %s", msg, tostring(args[i]))
	end
	if pid ~= "" then
		msg = string.format("%s%s", pid, msg)
	end
	logFunc(msg)
end

--打印枚举
printType = function (printId, TypeTable, pType, ex)
	if __IS_RELEASE__ then return end
	local str = ""
	ex = ex or ""
	for k, v in pairs(TypeTable) do
		if v == pType then
			str = k
			break
		end
	end
	if str ~= "" then
		print(printId, ex .. " " .. "type = " .. str)
	end
end

local function formatKey(key)

	local t = type(key)
	if t == "number" then
		return "["..key.."]"
	elseif t == "string" then
		local n = tonumber(key)
		if n then
			return "["..key.."]"
		end
	end

	return key
end

--打印table
function printTable(...)
	if __IS_RELEASE__ then return end

	local args = {...}

	if __PRINT_TYPE__ > 0 then
		if args[1] ~= __PRINT_TYPE__ and args[1] ~= 0 then return end
		table.remove(args, 1, 1)
	end

	if __PRINT_WITH_FILE_LINE__ then
		local traceback = string.split(debug.traceback("", 2), "\n")
		logFunc(string.format("print from: %s\n", string.trim(traceback[3])))
	end

	for k, v in pairs(args) do
		local root = v
		if type(root) == "table" then
			local temp = {
				"----------------printTable start----------------------------\n",
				tostring(root).."={\n",
			}
			local function table2String(t, depth)
				if type(depth) == "number" then
					depth = depth + 1
				else
					depth = 1
				end
				if depth > 13 then return end
				local indent = ""
				for i=1, depth do
					indent = indent .. "\t"
				end

				for k, v in pairs(t) do
					local key = tostring(k)
					local typeV = type(v)
					if typeV == "table" then
						if key ~= "__valuePrototype" then
							table.insert(temp, indent..formatKey(key).."={\n")
							table2String(v, depth)
							table.insert(temp, indent.."},\n")
						end
					elseif typeV == "string" then
						table.insert(temp, string.format("%s%s=\"%s\",\n", indent, formatKey(key), tostring(v)))
					else
						table.insert(temp, string.format("%s%s=%s,\n", indent, formatKey(key), tostring(v)))
					end
				end
			end
			table2String(root)
			table.insert(temp, "}\n------------------------printTable end------------------------------")
			logFunc(table.concat(temp))
		else
			logFunc(tostring(root))
		end
	end
end

function getTraceback(fromLevel)
	local ret = ""
	local level = 2
	if type(fromLevel) == "number" and fromLevel >= 0 then
		level = fromLevel + 2
	end

	while true do
		--get stack info
		local info = debug.getinfo(level, "Sln")
		if not info then
			break
		else
			if ret ~= "" then
				ret = ret .. "\r\n"
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

--打印当前函数的调用堆栈
function printTraceback(fromLevel)
	logFunc(__PRINT_TYPE__, getTraceback(fromLevel))
end


function printStack(func)
	if true then
		func = func or 2
		print ( __PRINT_TYPE__, "##COLOR##5##",
			debug.getinfo(func).source,
			debug.getinfo(func).linedefined,
			debug.getinfo(func).lastlinedefined)
	end
end

-- lua脚本监听清除loaded
function restoreLoaded()
	if cc.exports.__packageLoaded == nil then
		cc.exports.__packageLoaded = {}
		for k, _ in pairs(package.loaded) do
			cc.exports.__packageLoaded[k] = true
		end
	else
		for k, _ in pairs(package.loaded) do
			if not cc.exports.__packageLoaded[k] then
				package.loaded[k] = nil
			end
		end
	end
end

--[[
	lua文件热更，主要用于调整界面，改完直接保存立即看效果
	监听的是整个Srcipts目录
	只刷新FlowManager.enterGameScene()之后加载的以及includeFiles中的文件
	此函数名不能改
--]]

local function reload()
	restoreLoaded()

	local includeFiles = {
		-- "Configs.Handwork.Description",
		"Configs.Handwork.Resources",
		"Game.Managers.ResManager",
		"Game.Managers.ToolTipManager",
		"Game.Modules.MainUI.Components.TestContainer",
		
	}
	for _,v in pairs(myReloadFiles) do
		table.insert(includeFiles,v)
	end

	for i,v in ipairs(includeFiles) do
		package.loaded[v] = nil
		require(v)
	end

	local testModules = {
		--  ModuleType.MAIN_UI,
	}

	for _, v in ipairs(testModules) do
		ModuleManager.close(v)
		local ctrl = GameController.getCtrl(v)
		if ctrl then
			ctrl:dispose()
		end
		ModuleManager.open(v)
	end
end

-- lua监听开关
if gy.GYLuaWatcher then
	-- if __HACK_SEND__ ~= "" then
		-- gy.GYLuaWatcher.regedit(reload)
	-- else
		-- gy.GYLuaWatcher.regedit(reload)
	-- end
end


--通过键盘快捷键刷新指定文件
function reloadLua(files)

	if __IS_RELEASE__ then
        return
    end
    LuaLog("手动刷新")
    --重刷的包体 
	local refreshPack = {
        "MainUI",
    }

   for i,v in ipairs(refreshPack) do
   	 UIPackageManager.removePackage(v)
   	 UIPackageManager.addPackage(v)
   end

    --需要刷新的lua脚本
    local includePattern = {
        "Game.Modules.MainUI.MainUIController",
        "Game.Modules.MainUI.MainUIView",
        "Game.Modules.Bag.BagWindow",
        "Game.Modules.Bag.BagSplitView",
        "Game.Modules.Bag.BatchUseView",
        "Game.Modules.Bag.BagQuickView",
    }
	
	if files then
		includePattern = files
	end

    for i,v in ipairs(includePattern) do
    	package.loaded[v] = nil
    	local cls = require(v)
    	if string.find(v,"Controller") then
    		ControllerManager.reloadController(v, cls)
    	end

    	if string.find(v,"View") or string.find(v,"Window") then
    		local arr = string.split(v,".")
    		ViewManager.close(arr[#arr])
    		ViewManager.open(arr[#arr])
    	end
    end


end



-- 调试函数调用的细节
function debugFunction(func, log)
    debugModuleBegin()
    ------------------------------
    func()
    ------------------------------
    debugModuleEnd()
end

local s_hookData = false
function debugModuleBegin()
    if rawget(_G,"profiler_start") then
        --C++ 统计时间异步处理打印
        rawget(_G,"profiler_start")()
    else
        if s_hookData then
            return
        end

        s_hookData = {
            hookTime = 0,
            func = {},
            call = {},
            self = {},
            selfLast = {},
        }
        local function hookf(type)
            if type == "count" then
                s_hookData.hookTime = s_hookData.hookTime + 1
                local info = debug.getinfo(2, "Sln")
                local name = string.format("%s[%d", info.source, info.linedefined)
                s_hookData.self[name] = (s_hookData.self[name] or 0) + 1
            elseif type == "return" then
                local level = 2
                local line = 0
                local checkRepeat = {}
                while true do
                    local info = debug.getinfo(level, "Sln")
                    if not info then
                        break
                    else
                        if info then
                            if level == 2 then
                                local key = string.format("%s[%d", info.source, info.linedefined)
                                s_hookData.call[key] = (s_hookData.call[key] or 0) + 1
                                line = s_hookData.self[key] - (s_hookData.selfLast[key] or 0)
                                s_hookData.selfLast[key] = s_hookData.self[key]
                            end

                            local name = string.format("%s[%d~%d]%s[%d]", info.source, info.linedefined, info.lastlinedefined, info.name, info.currentline)
                            if not checkRepeat[name] then
                                s_hookData.func[name] = (s_hookData.func[name] or 0) + line
                                checkRepeat[name] = true
                            end
                        end
                    end
                    level = level + 1
                end
            end
        end
        LuaLog("======== debugModuleBegin ========")
        debug.sethook(hookf, "r", 1)
    end
end

function debugModuleEnd(printLevel, topFuncNum)
	if not printLevel then
		printLevel = 15
	end

	if not topFuncNum then
		topFuncNum = 80
	end

    if rawget(_G,"profiler_stop") then
        rawget(_G,"profiler_stop")(printLevel, topFuncNum)
    else
        debug.sethook()
        if not s_hookData then
            return
        end
        LuaLog("======== debugModuleEnd ========")
        LuaLog("== total hooks:", s_hookData.hookTime, "==")

        local t = {}
        for k, v in pairs(s_hookData.func) do
            local call = 1
            local pos = string.find(k, "~")
            if pos then
                local ck = string.sub(k, 1, pos - 1)
                call = s_hookData.call[ck] or 1
            end
            table.insert(t, {
                name = k,
                hooks = v,
                calls = call,
                hooksPreCall = math.floor(v / call),
            })
        end
        table.sort(t, function(a, b)
            return a.hooks > b.hooks
        end)
        LuaLog("| hooks | hooks pre call | call | location |")
        for i = 1, 90 do
            local v = t[i]
            if not v then
                break
            end
            LuaLog("::", v.hooks, v.hooksPreCall, v.calls, v.name)
        end
        s_hookData = false
    end
end

--打印函数在哪一行返回的
function printReturnLine(printType, func)
	-- local index = 0
	if __IS_RELEASE__ then
		func()
		return
	end
	local preLine
	local curLine
	local thisFileName
	local secondFileName
	local targetFileName
	local executeFuncLine
	local  function hook(des, line)
		-- Game/Modules/Map/Config/MapConfig.lua
		if not thisFileName then
			thisFileName = debug.getinfo(2).short_src
		else
			if not secondFileName then
				secondFileName = debug.getinfo(2).short_src
			else
				targetFileName = debug.getinfo(2).short_src
			end

			-- if not targetFileName then
			-- 	targetFileName = "FightUtil" --debug.getinfo(2).short_src
			-- end
		end
		
		if debug.getinfo(2).short_src == thisFileName then
			if not executeFuncLine then
				executeFuncLine = line
			end
			if line == executeFuncLine + 1 then
				print(printType, "返回行数", preLine)
				debug.sethook()
			end
		end
		if targetFileName and string.find(debug.getinfo(2).short_src, targetFileName) then -- debug.getinfo(2).short_src == targetFileName then
			preLine = curLine
			curLine = line
		end
		
	end

	debug.sethook(hook, "l")	

	func()
end


--自动化测试
__AUTO_TEST__ = false
__AUTO_TEST_SERVER__ = 90079
__AUTO_TEST_DISABLE_RENDER__ = false
__AUTO_TEST_DATA__ = false

__QUICK_LOGIN_CONFIG__ = false


if not __IS_RELEASE__ then
	local runPath = cc.FileUtils:getInstance():getWritablePath()
	local p = string.gsub(runPath, "whale/", "../Tools/stress_test/")
	p = p .. "IDEConfig.json"

	if cc.FileUtils:getInstance():isFileExist(p) then
		local str = cc.FileUtils:getInstance():getStringFromFile(p)
		print(92, "str", str)
		str = json.decode(str)
		if display.sizeInPixels.height == 481 then
			__AUTO_TEST__ = str.AutoTest or false
			if __AUTO_TEST__ then
				__AUTO_TEST_SERVER__ = str.ServerId
				__AUTO_TEST_DISABLE_RENDER__ = str.DisableRender or false
				str.DeviceName = str.DeviceName or "TESTPC"
				__AUTO_TEST_DATA__ = str
				__FPS__ = 15
				cc.Director:getInstance():setAnimationInterval(1.0 / __FPS__)
			end
		end
	end

	local launcherPath = string.gsub(runPath, "whale/", "../Tools/launcher/")
	p = launcherPath .. "launch.json"
	serverId2AddrJsonPath = launcherPath.."ServerId2Addr.json"
	if cc.FileUtils:getInstance():isFileExist(p) 
		and cc.FileUtils:getInstance():isFileExist(serverId2AddrJsonPath) then
		local str = cc.FileUtils:getInstance():getStringFromFile(p)
		launchConfigs = json.decode(str)
		local serverId2Addr = json.decode(cc.FileUtils:getInstance():getStringFromFile(serverId2AddrJsonPath))

		index = display.sizeInPixels.height%10
		launchConfig = launchConfigs[index]
		print(15, "cc.FileUtils:getInstance():getStringFromFile(p)",index,launchConfig)
		if launchConfig 
			and index == display.sizeInPixels.width%10 
			and ( not launchConfig.normal or launchConfig.normal == 0 )
			then
			__QUICK_LOGIN_CONFIG__ = launchConfig
			local realServerId = launchConfig.serverId
			realServerId = string.gsub(tostring(realServerId),"([0-9])[0-9]([0-9][0-9][0-9])",function (s1,s2)
				 	return string.format("%s9%s",s1,s2)
				 end)
			realServerId = math.tointeger(realServerId)
			for i,v in ipairs(serverId2Addr) do
				if v[1] == realServerId then
					launchConfig.ip = v[2]
					launchConfig.port = v[3]
				end
			end
			printTable(15,launchConfig)
			if not __QUICK_LOGIN_CONFIG__.ip then
				__QUICK_LOGIN_CONFIG__.ip = "192.168.9.69"
			end
			if __QUICK_LOGIN_CONFIG__.name == "" or not __QUICK_LOGIN_CONFIG__.name then
				if index > 1 then
					__QUICK_LOGIN_CONFIG__.name = __QUICK_LOGIN_CONFIG__.account..tostring(index-1)
				else
					__QUICK_LOGIN_CONFIG__.name = __QUICK_LOGIN_CONFIG__.account
				end
			end
		end
	end
end