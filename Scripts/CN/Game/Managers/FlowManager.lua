----------------------------------------------------
-- 本文件用于管理更新完成后的游戏流程
----------------------------------------------------
local FlowManager = {}

--重连失败后尝试无缝重登游戏
local reloginHandle = false
local reconnetTimes = 1
local reconnectFrame = false
local reconnectAlert = false

local loadingEndCall = nil;

local canLogin = false  --是否已经更新完毕，可以调用登陆

local function clearNode()
	if not tolua.isnull(reconnectFrame) then
		reconnectFrame:removeFromParent()
		reconnectFrame = false
	end
	if not tolua.isnull(reconnectAlert) then
		reconnectAlert:removeFromParent()
		reconnectAlert = false
	end
end

--清理重登信息
local function clearSilentLogin()
	if reloginHandle then
		Scheduler.unschedule(reloginHandle)
		reloginHandle = false
	end
	clearNode()
	--Cache.loginCache:clearLoginTimes()
end

function FlowManager.clearReconnetNode()
	clearNode()
end

--开始运行
function FlowManager.backToLoading()
	--退出登录时提交玩家数据到api中心
	PHPUtil.updatePlayer()

	LoginModel:switchAccountForPC()

	--重连需要保存之前的账号信息，防止唤出sdk登陆界面
	FlowManager.clear()
	
	UIPackageManager.removeAllPackages()
	--Dispatcher.dispatchEvent(EventType.loading_begin);
end

--开始运行
function FlowManager.run(func,noUpdate)

	LuaLogE("FlowManager.run")
	
	
	UIPackageManager.init()
	TextureManager.init()
	SpeechUtil.init()
	local scene = display.getRunningScene()
	
	--如果登录过后的更新重启 需要判断
	if fgui.GRoot:getInstance() then
		fgui.GRoot:getInstance():release()
	end
	
	local groot = fgui.GRoot:create(scene)
	groot:retain()

	ViewManager.init(groot)
	PoolManager.init()
	FightManager.init()
	FlowManager.initLogin()
	--红点管理器启动
	RedManager.start();
	--local ResDownloadModel = require "Game.Modules.Loading.ResDownloadModel"
	
end


function FlowManager.initLogin()
	--需要初始化的东西

	local network = require "Dex.Network.Network"
	network.Init({"ConnectHost","DoLogin"})



	if not (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID or CC_TARGET_PLATFORM == CC_PLATFORM_IOS) then
		restoreLoaded()
	end

	PHPUtil.reportStep(ReportStepType.UPDATE_FINISH)
	
	FlowManager.init()


	if rawget(_G, "__IGONRE_LOGIN__") then
		FlowManager.enterGameScene()
	else
		FlowManager.enterLoginScene()
	end
end

--关闭游戏
function FlowManager.quitGame()
	cc.Director:getInstance():endToLua()
end

function FlowManager.init()
	ControllerManager.init()
	ModelManager.init()
end

function FlowManager.clear(changeRole)
	-- 清理
	local Network = require "Dex.Network.Network"
	Network.clear()
	Dispatcher.dispatchEvent(EventType.buoyWindow_Remove) --移除浮标按钮
	ModuleUtil.clear()
	Scheduler.unscheduleAll()
	Dispatcher.clear()
	ModelManager.clear()
	ControllerManager.clear()
	ViewManager.clear()
	FightManager.clear()
	
	ResUpdateManager.stopDownload()

	cc.Director:getInstance():getActionManager():removeAllActions()
	gy.GYPathFinder:getInstance():clearCachedMapData()
	--LoginModel.hasLogin = false
	_G.__ENTER_GAME__ = false
	
end

-- 返回登录
function FlowManager.backToLogin(changeRole, changeAccount, autoLogin)
	
	--退出登录时提交玩家数据到api中心
	--PHPUtil.updatePlayer()
	local lastLoginServerInfo = TableUtil.DeepCopy(LoginModel:getLastLoginServerInfo())
	
	LoginModel:switchAccountForPC()

	--重连需要保存之前的账号信息，防止唤出sdk登陆界面
	FlowManager.clear(changeRole)
	--重新初始化
	FlowManager.init()
	FlowManager.enterLoginScene(changeRole, changeAccount,autoLogin,lastLoginServerInfo)
end

--不经过登录界面的重连
function FlowManager.relinkQuietly()
	function delay()
		clear(true)
		--加载界面图标
		local bgConfig = AgentResConfiger.getLoadingBackground()
		reconnectFrame = UI.newSprite({src = bgConfig.src})
		local bgSize = reconnectFrame:getContentSize()
		local ratioW = display.width / bgSize.width
		local ratioH = display.height / bgSize.height
		if ratioW >= ratioH then
			reconnectFrame:setScale(ratioW)
		else
			reconnectFrame:setScale(ratioH)
		end
		reconnectFrame:setPosition(display.cx + bgConfig.offsetX, display.cy + bgConfig.offsetY)
		LayerManager.eventLayer:addChild(reconnectFrame)		

		reconnectAlert = Alert.show({
			title = Desc.common_tips,
			no = true,
			noText =  Desc.login_backLogin,
			mask = true,
			father = LayerManager.eventLayer,
			onClose = function (event)
				if event.detail == "no" or event.detail == "close" then
					--返回等录
					Scheduler.scheduleNextFrame(function ()
						backToLogin()
					end)
				end
			end
		})

		local tryConnectTimes = UI.newRichText({
			text = Desc.login_waitConnect,
			x = 277,
			y = 197,
			anchorPoint = UI.POINT_CENTER,
			style = Alert.ALERT_DEDAULT.style.contentText
		})
		reconnectAlert:addChild(tryConnectTimes)
		reconnetTimes = reconnetTimes + 1

		Dispatcher.dispatchEvent(EventType.login_relinkQuietly)
		--是否可以再次尝试重登
		if Cache.loginCache:canTryLoginAgain() then
			reloginHandle = Scheduler.scheduleOnce(2, delay)

		--返回登录界面
		else
			backToLogin()
		end
	end
	reconnetTimes = 1
	Scheduler.scheduleNextFrame(delay)
end

function FlowManager.backToSelectRole(func)
	local function delay()
		backToLogin(true)
		Dispatcher.dispatchEvent(EventType.LOGIN_COMMON, "login")
		if func then
			func()
		end
	end
	Scheduler.scheduleNextFrame(delay)
end

function FlowManager.enterLoginScene(changeRole, changeAccount, autoLogin,lastLoginServerInfo)
	LuaLogE("FlowManager.enterLoginScene")
	if LoginModel:isTestAgent() then
		--FlowManager.enterLoginScene()
	else
		LuaLogE("__SDK_LOGIN__" .. tostring(__SDK_LOGIN__))
		if __SDK_LOGIN__  then
			if gy.GYChannelSDK:getInstance():isInited() then
				ViewManager.showGolbalWait()
				Scheduler.scheduleNextFrame(function()
						SDKUtil.login()
					end)
			else
				LuaLogE("还没初始化成功")
				FlowManager.canLogin = true
			end
		end
	end
	Dispatcher.dispatchEvent(EventType.loading_closeLoading);
	Dispatcher.dispatchEvent(EventType.login_showLoginView, {autoLogin = autoLogin, serverInfo = lastLoginServerInfo});
	Dispatcher.dispatchEvent(EventType.resDownLoad_start);
end

function FlowManager.enterGameScene()
	print(33,"FlowManager.enterGameScene")
	clearSilentLogin()
	_G.__ENTER_GAME__ = true
	ViewManager.clear()
	
	--初始化推送数据
	--Cache.dailyCache:loadNotificationData()

	local moduleParams = setmetatable({isResident = true, closeOthers = false, playSound = false}, {__newIndex = function (t,k,v)
		error(string.format("Error! module params no member variable:'%s'", tostring(k)))
	end})

	--初始化推送
	PushNotificationManager.init()

	--到时候需要新建一个场景进入主界面
	
	
	--打开界面
	ViewManager.open("MainUIView",{},function()
		print(1,"执行回调")
	end)
	--创建公告面板
	ViewManager.open("BroadcastView")
	--Dispatcher.dispatchEvent(EventType.ENTER_GAME_SCENE)
	PHPUtil.reportStep(ReportStepType.ENTER_GAME_SCENE)
	ViewManager.showIpadBg(true)
end

return FlowManager
