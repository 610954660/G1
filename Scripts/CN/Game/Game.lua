local Game = {}

local LoadingController = require "Game.Modules.Loading.LoadingController"

local checkUpdateTime = 0
--初始化音量设置
function Game.initNativeSetting()
	-- local SettingConfig = Cache.settingCache.SettingConfig
	-- local native = Cache.settingCache.native
	-- native.musicVolume = FileCacheManager.getIntForKey("musicVolume", SettingConfig.getDefaultValueByCKey("musicVolume"), true)
	-- native.soundVolume = FileCacheManager.getIntForKey("soundVolume", SettingConfig.getDefaultValueByCKey("soundVolume"), true)
	-- SoundManager.setMusicVolume(native.musicVolume)
	-- SoundManager.setSoundVolume(native.soundVolume)
end

--从本地保存的数据中取出一些重要的设置信息
function Game.initGlobalVars()
	
end

--更新完后
local function onUpdateEnd()
	print(1,"Game.onUpdateEnd")
	LuaLogE("onUpdateEnd")
	--主游戏部分基础环境准备
	require "Game.EnvGame"
	Game.initGlobalVars()
	Game.initNativeSetting()						
	checkUpdateTime = os.time()
	FlowManager.run()
	PHPUtil.deviceActivition()   --发送激活信息给后台，每台设备只发送一次
end

--返回Loading界面环境
function Game.backToLoading()
	FlowManager.backToLoading()
	Game.initLoadingEnv()
end

--检查是否需要更新
function Game.checkUpdate(func)
	--设置60秒检查间隔
	if CC_TARGET_PLATFORM == CC_PLATFORM_MAC or CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then func(false) return end
	if os.time() - checkUpdateTime < 60 then func(false) return end
	checkUpdateTime = os.time()
	
	LoadingController:checkIsNeedUpdate(function(value)
			func(value)
			
			if value then
				LuaLogE("checkIsNeedUpdate true")
				Game.backToLoading()
			else
				LuaLogE("checkIsNeedUpdate false")
			end
	end)
end

--初始化Loading界面环境
function Game.initLoadingEnv()
	print(15,"initLoadingEnv()")
	if __QUICK_LOGIN_CONFIG__ then
		onUpdateEnd()
		return
	end
	if __IGNORE_UPDATE__ then
		local resourceManager = cc.ResourceManager:getInstance()
		resourceManager:updatePack1List("ResourceE")
		resourceManager:updateGameFileList("ResourceC1")
		onUpdateEnd(false)
	else
		
		LoadingController:init()
		LoadingController:loading_begin("loading_begin",onUpdateEnd)
		--Dispatcher.dispatchEvent(EventType.loading_begin,onUpdateEnd);
	end
end


function Game.startup()
	--启动基础环境准备
	require "Game.EnvBase"
	print(__PRINT_TYPE__, "##MYCOLOR##"..__PRINT_COLOR__.."  setcolor") --调用一次打印，设置console里log的颜色
	PHPUtil.reportStep(ReportStepType.ENTER_LUA)
	--设备初始化	
	DeviceUtil.init()
	--初始化sdk
	SDKUtil.init()
	Game.initLoadingEnv();
end

return Game