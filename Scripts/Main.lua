-- local breakInfoFun,xpcallFun = require("LuaDebug")("localhost", 7003)
-- package.cpath = package.cpath .. ";c:/Users/Administrator/.vscode/extensions/tangzx.emmylua-0.3.49/debugger/emmy/windows/x64/?.dll"
-- local dbg = require("emmy_core")
-- dbg.tcpListen("localhost", 9966)
----这一段必须在开始时处理，否则什么文件都将找不到-------------------------------------------------
--脚本启动文件----------
jit.off()
CC_PLATFORM_UNKNOWN     = 0
CC_PLATFORM_IOS         = 1
CC_PLATFORM_ANDROID     = 2
CC_PLATFORM_WIN32       = 3
CC_PLATFORM_MAC  		= 8

CC_TARGET_PLATFORM 		= gy.GYPlatform:getTargetPlatform()

--脚本类型
ScriptTypeLua = 1
ScriptTypeLuaJit = 2
ScriptTypePackS = 3

local gyScriptManager = gy.GYScriptManager:getInstance()
gyScriptManager:setLanguage(__LANGUAGE__)
gyScriptManager:setLanguageBase(__LANGUAGE_BASE__)

ScriptType = gyScriptManager:getScriptType()




DT = setmetatable({}, {
	__newindex = function ()
		LuaLogE("DUMMY_TABLE can not be assigned!")
	end
})

local fileUtils = cc.FileUtils:getInstance()
--真机不处理脚本的读取
if CC_TARGET_PLATFORM == CC_PLATFORM_IOS or CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
	local writablePath = fileUtils:getWritablePath()
	fileUtils:addSearchPath("GameAssets/", true)
    fileUtils:addSearchPath(string.format("%supdate/GameAssets/", writablePath), true)

elseif CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 or CC_TARGET_PLATFORM == CC_PLATFORM_MAC then
	if ScriptType == ScriptTypePackS then
		local writablePath = fileUtils:getWritablePath()
		fileUtils:addSearchPath("GameAssets/", true)
	    fileUtils:addSearchPath(string.format("%supdate/GameAssets/", writablePath), true)
    	
	else
		--获取当前脚本类型
		local directoryType = gyScriptManager:getScriptFolderName()
		local function addScriptSearchPath(lang)
			fileUtils:addSearchPath(string.format("%s/%s/", directoryType, lang), true)			
		end

		local function addAssetsSearchPath(lang)
			fileUtils:addSearchPath(string.format("Assets/%s/", lang), true)
		end

		addScriptSearchPath(__LANGUAGE_BASE__)
		addAssetsSearchPath(__LANGUAGE_BASE__)	
		if __LANGUAGE__ ~= __LANGUAGE_BASE__ then
			addScriptSearchPath(__LANGUAGE__)
			addAssetsSearchPath(__LANGUAGE__)
		end
	end
end


package.path = package.path .. string.format(";./lualib/?.lua;?.lua")   --路径分隔符win和linux不同
if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
	local writablePath = fileUtils:getWritablePath()
	local fullPath = writablePath .. "../?.dll"
	package.cpath = package.cpath .. string.format(";%s",fullPath)
end

--使用官方lua框架
CC_USE_FRAMEWORK = true
--是否屏蔽全局变量使用
CC_DISABLE_GLOBAL = false
-- 是否显示提示替换信息
CC_SHOW_DEPRECATED_TIP = false


--lua 版本兼容
require "Dex.Libs.compat53.init"
--初始化lua框架
require "cocos.init"
--初始化给c++调用的lua方法
require "Interface2C"
--初始化引擎兼容接口
require "EngineEx"
--内网测试环境中使用的变量
require "Test"

 

if __HACK_SEND__ ~= "" then
	local directoryType = gyScriptManager:getScriptFolderName()
	if directoryType == "Scripts_jit32" then
		fileUtils:addSearchPath(string.format("Scripts_jit32/"), true)
	else
		fileUtils:addSearchPath(string.format("Scripts/"), true)
	end
end

local function main()
	collectgarbage("setpause", 160)
	collectgarbage("setstepmul", 260)
	--重设全新随机种子
	math.newrandomseed()
	
	if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
		cc.TextureCache:getInstance():setUseAsyncType(0)
		cc.TextureCache:getInstance():setSpineUseAsyncType(0)
		fgui.UIPackage:setUseAsyncType(0)
	else
		cc.TextureCache:getInstance():setUseAsyncType(0)
		cc.TextureCache:getInstance():setSpineUseAsyncType(0)
		fgui.UIPackage:setUseAsyncType(0)
	end
	--开启后spine会黑边
	--cc.Image:setPNGPremultipliedAlphaEnabledGY(false)
	--cc.TextureCache:getInstance():setCheckAsyncTypeFunc(function (path)
	--return 1
	--end)
	
	
	local director = cc.Director:getInstance()
	director:setDisplayStats(not __IS_RELEASE__)
	director:setAnimationInterval(1.0 / __FPS__)

	local luaVersion = _VERSION:sub(-3)

    if luaVersion < "5.3" then
        local packed = string.pack(">s2","asdasfasgagg")
        local unpacked = string.unpack(">s2",packed)
	    local tt = {{a = 1,b = 11},{a = 22,b = 1},{a = 23,b=1},{a = 45,b = 24},{a = 45,b = 23},{a = 1,b = 2},{a = 3,b = 4}}
	    local function cmp(a,b)
		   	if a.a == b.a then
				return a.b < b.b
			else
				return a.a > b.a
			end
	    end
		table.sort( tt,cmp )
    end
	print(1,"jit.version",jit.version)
	local Game = require "Game.Game"
	Game.startup()
end
local _create = coroutine.create
coroutine.create = function(f)
	--if argEnd ~= nil then
		--luaLogE("to much return value from coroutine")
	--end
	return _create(function(...)
			xpcall(f,__G__TRACKBACK__,...)
	end)
end
--local _resume = coroutine.resume
--coroutine.resume = function(...)
	--local result,ret1,ret2,ret3,ret4,ret5 = _resume(...)
	--if ret5 ~= nil then
		--luaLogE("to much return value from a yeild")
	--end
	----print(1000000,"cor ret:",ret1,ret2,ret3,ret4,ret5)
	--if not result then
		--luaLogE("co error:",ret1,debug.traceback())
	--end
	--return result,ret1,ret2,ret3,ret4,ret5
--end

LuaLogE("lalalalalalalalalalal")
xpcall(main, __G__TRACKBACK__)

