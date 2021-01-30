
--loading界面不使用FGUI，纯代码实现
local LoadingView = class("LoadingView",View)
local LoadingController = require "Game.Modules.Loading.LoadingController"
local FlowManager = require "Game.Managers.FlowManager"
local UpdateDescription = require "Configs.Handwork.UpdateDescription"
local Dispatcher = require "Game.FMVC.Core.Dispatcher"
local FileCacheManager = require "Game.Managers.FileCacheManager"
--logo只显示一次
local showLogo = true
local first = true
local beginData = false

function LoadingView:ctor()
	LuaLogE("LoadingView ctor LuaLogE cccccccccccc")
	self.schedulerID = false
	self.labelText = false
	self.label = false
	self.index = 1
	self.progress = false
	self.percent = 0
	self.percentText = 0
	self.guangSpr = false
end


--初始化
function LoadingView:init()
	LuaLogE("LoadingView _initUI")
	--SoundManager.playMusic(15, nil, false, "LoadingView")
	
	self:readSoundSetting() -- 先读取上次保存的音量设置
	self:playBgm()
	
	local resourceManager = cc.ResourceManager:getInstance()
	resourceManager:updatePack1List("ResourceE")
	resourceManager:updateGameFileList("ResourceC1")
	if gy.GYScriptManager:getInstance():getScriptType() ~= 3 and (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 or CC_TARGET_PLATFORM == CC_PLATFORM_MAC)  then
		resourceManager:updateGameFileList("")
		cc.FileUtils:getInstance():setFilenameLookupDictionary({})
	end
	
	local function sceneEventHandler(event)
		if event == "enter" then

		elseif event =="exit" then
			print("--执行event=='exit'的代码！")
			display.removeUnusedSpriteFrames()
		end
	end

	local scene = cc.Scene:create()
	scene:registerScriptHandler(sceneEventHandler)
	display.runScene(scene)

	if showLogo then
		--先把图显示出来
		self:showLogo(scene);

		--延迟一帧进行其他初始化逻辑
		local function fucCall()
			LuaLogE(0,"LoadingView initLoadingEnv")
			self:showOtherUI()
			self:initLoadingEnv();
		end

		Scheduler.scheduleOnce(0.01, fucCall)

		--showLogo = false;
	else
		self:showOtherUI()
		self:initLoadingEnv();
	end
end

--读取声音设置
function LoadingView:readSoundSetting()
	local data = FileCacheManager.getStringForKey("game_setting", "", nil, true)
	if data ~= "" then
		local Info = json.decode(data)
		if type(Info) == "table" then
			SoundManager.setMusicVolume(Info.sound[1])
			SoundManager.setSoundVolume(Info.sound[2])
			--fgui.GRoot:getInstance():setSoundVolumeScale(Info[2]/100.0)
		end
	end
end

--[[
	更新结束回调
	@code 			更新结果
	@info 		    额外信息
	@exParam 		额外参数
--]]
local function onUpdateEnd(code, info, exParam)
	--掉线切换帐号下更新了强制更新的脚本，必须重启游戏	
	if (code == 1 or code == 2) and exParam and isNowRestart and isForcedUpdate then
		code = 110
	end
	local desc = UpdateDescription[code] or ""
	if info then
		desc = string.format("%s(%s)",desc,info)
	end
	LuaLogE(DescAuto[171]) -- [171]="检测更新......."
	if code == 1 or code == 5 then
		LuaLogE(DescAuto[172] .. code) -- [172]="更新完成... "
		Dispatcher.dispatchEvent(EventType.loading_tipsFont,Desc.loading_finish)
		Dispatcher.dispatchEvent(EventType.loading_updateProgress,200)
		if code == 1 then
			PHPUtil.reportStep(ReportStepType.UPDATE_FINISH)
		end
		VersionChange:clear()
	else
		LuaLogE(string.format(DescAuto[173], code, info, exParam)) -- [173]="更新失败%s  info:%s  exParam:%s"
		Dispatcher.dispatchEvent(EventType.loading_tipsFont,Desc.loading_error1:format(code))
	end
	
	
end

local function onCheckingHandler(data)
	printTable(33,"onCheckingHandler data = ",data)
end

--local function onDownloadingHandler(data)
	--printTable(33,"onDownloadingHandler data = ",data)
	
	--local curD = data.currentDLSize/(1024*1024)
	--local allD = data.totalDLSize/(1024*1024)
	
	--if not beginData then
		--beginData = curD
	--end
	
	--local strText ="正在玩命更新%.2fM数据 (更新中...%.2f/%.2f)" 
	--Dispatcher.dispatchEvent(EventType.loading_tipsFont,strText:format(allD-beginData,curD-beginData , allD-beginData))
		
	--local percent = math.floor(100.0*  curD / allD)
	--Dispatcher.dispatchEvent(EventType.loading_updateProgress,percent)
--end

local function onDownloadingHandler(data)
	--printTable(33,"onDownloadingHandler data = ",data)
	if first then
		Dispatcher.dispatchEvent(EventType.loading_tipsFont,Desc.loading_doing)
		first = false
	end
	
	local curD = data.successByte/(1024*1024)
	local allD = data.totalByte/(1024*1024)

	
	
	local realCurD = curD
	local realAllD = allD
	local percent = 0
	if realAllD > 0 then
		percent = math.floor(100.0* realCurD / realAllD)
	end
	
	if percent < 5 then percent = 5 end
	
	local strText =Desc.loading_data
	if realAllD > 5 then
		Dispatcher.dispatchEvent(EventType.loading_tipsFont,strText:format(realAllD,realCurD , realAllD))
	else
		Dispatcher.dispatchEvent(EventType.loading_tipsFont,Desc.loading_upzip)
	end
	LuaLogE("onDownloadingHandler realCurD ="..realCurD..",realAllD = "..realAllD.." percent="..percent)
	Dispatcher.dispatchEvent(EventType.loading_updateProgress,percent)
end

-- 处理从后台获取的更新信息
local function manageUpdateInfoDictionary(jsContent)
	if not jsContent then 
		LuaLogE(DescAuto[174]) -- [174]="没有信息"
		Dispatcher.dispatchEvent(EventType.loading_tipsFont,Desc.loading_getversionError)
		return 
	end
	Dispatcher.dispatchEvent(EventType.loading_tipsFont,Desc.loading_checking)
	Dispatcher.dispatchEvent(EventType.loading_updateProgress,5)
	
	local oldAppVersion = __APP_VERSION__
	local app = jsContent.app -- app最新版本
	local force = tonumber(jsContent.force) -- 是否强制更新app
	if force and force == 1 and app and app ~= oldAppVersion then
		local ipaPlist = jsContent.ipaPlist -- app更新地址
		if ipaPlist and ipaPlist ~= "" then -- 强制更新
			local function checkCallback2()
				gy.GYChannelSDK:getInstance():update(ipaPlist)
			end
			checkNetWorkStatus(true, checkCallback2)
		else
			onUpdateEnd(103)
		end
		return
	end
	
	---------------------
	--注意！！！以下写全局变量数据时都保存到了本地是因为更新完脚本后整个LuaEngine会重新构建
	local FileCacheManager = require "Game.Managers.FileCacheManager"
	if jsContent.platform then
		rawset(_G, "__AGENT_SUFFIX__", jsContent.platform)
		FileCacheManager.setStringForKey("__AGENT_SUFFIX__", jsContent.platform, nil, true)
	else
		rawset(_G, "__AGENT_SUFFIX__", "")
		FileCacheManager.setStringForKey("__AGENT_SUFFIX__", "", nil, true)
	end

	if jsContent.verifyApp == 1 then
		rawset(_G, "__IN_AUDITING__", true)
		FileCacheManager.setBoolForKey("__IN_AUDITING__", true, nil, true)
	else
		rawset(_G, "__IN_AUDITING__", false)
		FileCacheManager.setBoolForKey("__IN_AUDITING__", false, nil, true)
	end

	if jsContent.extend then
		FileCacheManager.setStringForKey("CustomerServiceUrl", jsContent.extend.vplus or "", nil, true)
		if jsContent.extend.closePay == 1 then
			rawset(_G, "__CLOSE_PAY__", true)
			FileCacheManager.setBoolForKey("__CLOSE_PAY__", true, nil, true)
		else
			rawset(_G, "__CLOSE_PAY__", false)
			FileCacheManager.setBoolForKey("__CLOSE_PAY__", true, nil, false)
		end
		if jsContent.extend.loadingBg and jsContent.extend.loadingBg ~= "" then
			FileCacheManager.setStringForKey("platform_loadingBg", jsContent.extend.loadingBg or "", nil, true)
		else
			FileCacheManager.setStringForKey("platform_loadingBg", "", nil, true)
		end
		
		if jsContent.extend.loginBg and jsContent.extend.loginBg ~= "" then
			FileCacheManager.setStringForKey("platform_loginBg", jsContent.extend.loginBg or "", nil, true)
		else
			FileCacheManager.setStringForKey("platform_loginBg", "", nil, true)
		end
		
		if jsContent.extend.logo and jsContent.extend.logo ~= "" then
			FileCacheManager.setStringForKey("platform_logo", jsContent.extend.logo or "", nil, true)
		else
			FileCacheManager.setStringForKey("platform_logo", "", nil, true)
		end
	else
		FileCacheManager.setStringForKey("CustomerServiceUrl", jsContent.extend.vplus or "", nil, true)
		rawset(_G, "__CLOSE_PAY__", false)
		FileCacheManager.setBoolForKey("__CLOSE_PAY__", false, nil, true)
	end

	rawset(_G, "__SERVER_LIST_MD5__", jsContent.md5)
	FileCacheManager.setStringForKey("__SERVER_LIST_MD5__", jsContent.md5, nil, true)

	if jsContent.customerInfo then
		FileCacheManager.setStringForKey("CustomerServiceQQ", jsContent.customerInfo.qq or "", nil, true)
		FileCacheManager.setStringForKey("CustomerServicePhone", jsContent.customerInfo.tel or "", nil, true)
		--FileCacheManager.setStringForKey("CustomerServiceUrl", jsContent.customerInfo.tel or "", nil, true)
	else
		FileCacheManager.setStringForKey("CustomerServiceQQ", "", nil, true)
		FileCacheManager.setStringForKey("CustomerServicePhone", "", nil, true)
		--FileCacheManager.setStringForKey("CustomerServiceUrl", "", nil, true)
	end
	

	if jsContent.htPlatform and jsContent.htPlatform ~= "" then
		rawset(_G, "__AGENT_LOGIN__", jsContent.htPlatform)
		FileCacheManager.setStringForKey("__AGENT_LOGIN__", jsContent.htPlatform, nil, true)
	else
		rawset(_G, "__AGENT_LOGIN__", "")
		FileCacheManager.setStringForKey("__AGENT_LOGIN__", "", nil, true)
	end

	LuaLogE(string.format(
		DescAuto[175], -- [175]="getVersion：  __AGENT_SUFFIX__=%s  __AGENT_LOGIN__=%s  __IN_AUDITING__=%s  __CLOSE_PAY__=%s __SERVER_LIST_MD5__=%s"
		__AGENT_SUFFIX__,
		__AGENT_LOGIN__,
		tostring(__IN_AUDITING__),
		tostring(__CLOSE_PAY__),
		tostring(__SERVER_LIST_MD5__)
	))


	--dump(92, jsContent)

	if jsContent.zfinfo then
		local zfinfo = jsContent.zfinfo
		FileCacheManager.setStringForKey("ApprovalNumber", zfinfo.spw, nil, true)  --审批文号
		FileCacheManager.setStringForKey("GameSpareNumber", zfinfo.wwy, nil, true) --文网游备字
		FileCacheManager.setStringForKey("PublicationNumber", zfinfo.cbw, nil, true) --网络游戏出版号 ISBN
		FileCacheManager.setStringForKey("OperatingUnit", zfinfo.yydw, nil, true) --运营单位
		FileCacheManager.setStringForKey("PublishingUnit", zfinfo.cbdw, nil, true) -- 出版单位
		FileCacheManager.setStringForKey("Author", zfinfo.author, nil, true) -- 著作人
		FileCacheManager.setStringForKey("LicenseNumber", zfinfo.xkz, nil, true) -- 网络经营许可证编号 粤网文
	else
		FileCacheManager.setStringForKey("ApprovalNumber", "", nil, true)
		FileCacheManager.setStringForKey("GameSpareNumber", "", nil, true)
		FileCacheManager.setStringForKey("PublicationNumber", "", nil, true)
		FileCacheManager.setStringForKey("OperatingUnit", "", nil, true)
		FileCacheManager.setStringForKey("PublishingUnit", "", nil, true)
		FileCacheManager.setStringForKey("Author", "", nil, true)
		FileCacheManager.setStringForKey("LicenseNumber", "", nil, true)
	end
	-----------------------

	--最新功能版本
	local latestCodeVer = jsContent.resListVer
	--强制更新资源版本
	local forceResVer = jsContent.resForVer
	if not forceResVer or forceResVer == "" then
		forceResVer = 0
	end
	forceResVer = tonumber(forceResVer)
	--最新资源版本
	local latestResVer = jsContent.latResVer
	if not latestResVer or latestResVer == "" then
		latestResVer = 0
	end	
	latestResVer = tonumber(latestResVer)

	--资源路径
	local resURL = jsContent.resUrl
	if __USE_HTTPS__ then
		resURL = string.gsub(resURL, "http://", "https://")
	end
	resURL = string.urldecode(resURL)
	if resURL ~= "" then
		rawset(_G, "__RES_URL__", resURL)
		FileCacheManager.setStringForKey("__RES_URL__", resURL, nil ,true)
	end

	--切换参数
	ResUpdateManager.init({
		latCodeVersion = latestCodeVer,
		resURL = resURL,
		cdnDomain = jsContent.cdnDomain,
		clientDomain = jsContent.clientDomain,
		md5 = jsContent.md5,--列表MD5
		backupDomains = jsContent.domain, --可用备机域名
		forceUpVersion = forceResVer, 
		latResVersion = latestResVer,
		isTest = jsContent.isTest
	})

	PHPUtil.reportStep(ReportStepType.GET_UPDATE_INFO)

	if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID or CC_TARGET_PLATFORM == CC_PLATFORM_IOS) or ScriptType == ScriptTypePackS then			
		if __AGENT_CODE__ == "g1yinghepingce" then
			onUpdateEnd(1)
		elseif CC_TARGET_PLATFORM == CC_PLATFORM_IOS and __IN_AUDITING__ then 
			onUpdateEnd(1)
		else
			ResUpdateManager.downloadResLoading(onUpdateEnd, onCheckingHandler, onDownloadingHandler)
		end
	else--未开启更新检查
		onUpdateEnd(1)
	end
end

--初始化环境
function LoadingView:initLoadingEnv()
	--if true then LuaLog("stop !! initLoadingEnv") return end
	--获取版本更新
	local function onSuccess(data)
		if data and json then
			LuaLogE("getVersion:"..json.encode(data))
		end
		manageUpdateInfoDictionary(data)		
	end

	local function onFailed(data)
		--if data.code == -1 then -- 网络连接失败
			--onUpdateEnd(101, data.status)
		--else -- 后台认证失败
			--onUpdateEnd(102, data.code)
		--end
		Dispatcher.dispatchEvent(EventType.loading_tipsFont,Desc.loading_getversionError)
	end
	self.percent = 0
	Dispatcher.dispatchEvent(EventType.loading_tipsFont,Desc.loading_gettingversion)
	Dispatcher.dispatchEvent(EventType.loading_updateProgress,1)
	--[[if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 or CC_TARGET_PLATFORM == CC_PLATFORM_MAC) or ScriptType == ScriptTypeLua then
		onUpdateEnd(1)
	else--]]
		PHPUtil.getVersion(onSuccess, onFailed)
--	end
	
end

--显示logo闪图
function LoadingView:showLogo(scene)
	LuaLogE("LoadingView showLogo")

	local layer = cc.Layer:create()
	scene:addChild(layer)
	layer:setTag(5330)
	self.layer = layer

	local function endCall()
		--播放完成后移除logo页面
		--if not tolua.isnull(layer) then
			--layer:removeFromParentAndCleanup(true)
		--end
		LoadingController:loading_end(2)
	end

	local logoUrl = AgentConfiger.getAuditLoadingBg()
	if not logoUrl then
		local random = math.floor(math.random()*3) + 1
		logoUrl = "ResStay/loadingBg"..random..".jpg" 
		local saveLogoUrl = FileCacheManager.getStringForKey("loadingBgUrl", "", nil, true)
		if saveLogoUrl and saveLogoUrl ~= "" and cc.FileUtils:getInstance():isFileExist(saveLogoUrl) then
			logoUrl = saveLogoUrl
		elseif not cc.FileUtils:getInstance():isFileExist(logoUrl) then
			logoUrl = "UI/Loading/loadingBg"..random..".jpg"
		end
	end
	local logo = cc.Sprite:create(logoUrl)
	if logo then
		layer:addChild(logo)
		logo:setPosition(display.width/2, display.height/2)
		logo:setAnchorPoint(0.5,0.5)
	end
	--if CC_TARGET_PLATFORM ~= CC_PLATFORM_WIN32 then
		--logo:runAction(cc.Sequence:create({
					--cc.DelayTime:create(1),
					----cc.FadeOut:create(0.5),
					--cc.CallFunc:create(endCall)
				--}))
	--else
		LoadingController:loading_end(2)
	--end
	
	
	
end


function LoadingView:showOtherUI(scene)
	
	local layer = self.layer
	local textbg1 = cc.Sprite:create("UI/Loading/bg1.png")
	if textbg1 then
		textbg1:setPosition( display.width/2, 42)
		layer:addChild(textbg1)
	end

	local labelText = cc.Label:createWithTTF("","fonts/YINGWEN.TTF",22)
	--labelText:setSystemFontSize(24)
	labelText:setAnchorPoint(0,0.5)
	labelText:setPosition(display.width/2 - labelText:getContentSize().width/2, 20)
	--labelText:setDimensions(500,20)
	--labelText:setHorizontalAlignment(0)
	--labelText:enableOutline({r=0,g=0,b=0,a=255},2)
	layer:addChild(labelText)



	--local scaleX = display.width/logo:getContentSize().width
	--logo:setScale(scaleX)
	local progressBg = cc.Sprite:create("UI/Loading/jindubg.png")
	if progressBg then
		progressBg:setPosition(display.width/2-40, 75)
		--progressBg:setContentSize(cc.size(1149,9))
		layer:addChild(progressBg)
	end

	local progressSpr = ccui.Scale9Sprite:create("UI/Loading/jindu.png");
	--progressSpr:setAnchorPoint(0,0.5)
	--progressSpr:setContentSize(cc.size(1000,9))
	local progress = cc.ProgressTimer:create(progressSpr);
	--progress:setContentSize(cc.size(1000,9))
	progress:setPosition(display.width/2-40, 75)
	--local scaleX = display.width/progress:getContentSize().width
	--progress:setScaleX(scaleX)
	--progress:setAnchorPoint(0.5,0.5)
	--条形，定义进度条方式：从右到左显示
	progress:setType(cc.PROGRESS_TIMER_TYPE_BAR);
	progress:setBarChangeRate( cc.p(1, 0) );
	progress:setMidpoint( cc.p(0, 1) );
	progress:setPercentage(0)

	layer:addChild(progress);

	--self.guangSpr = ccui.Scale9Sprite:create("UI/Loading/guang.png")
	--self.guangSpr:setPosition( display.width/2-575, 82)
	--self.guangSpr:setAnchorPoint(0.6,0.5)
	--layer:addChild(self.guangSpr)



	local textbg = ccui.Scale9Sprite:create("UI/Loading/textbg.png")
	local xxx = display.width/2+575+textbg:getContentSize().width/2 + 5
	if xxx > display.width- 50 then
		xxx =  display.width- 50
	end
	textbg:setPosition( xxx, 75)
	layer:addChild(textbg)
	local sText = cc.Label:createWithTTF("85","fonts/YINGWEN.TTF",40)
	--sText:setString()
	sText:setAnchorPoint(0.5,0.5)
	sText:setColor({r=244,g=191,b=59})
	sText:setPosition(textbg:getContentSize().width/2, textbg:getContentSize().height/2+5)
	--sText:enableOutline({r=0,g=0,b=0,a=255},1)
	--labelText:setHorizontalAlignment(0)
	textbg:addChild(sText)
	self.percentText = sText

	local sText2 = cc.Label:createWithTTF("%","fonts/YINGWEN.TTF",22)
	--sText:setString()
	sText2:setAnchorPoint(0.5,0.5)
	sText2:setColor({r=244,g=191,b=59})
	sText2:setPosition(textbg:getContentSize().width/2, textbg:getContentSize().height/2-24)
	--sText2:enableOutline({r=0,g=0,b=0,a=255},1)
	--labelText:setHorizontalAlignment(0)
	textbg:addChild(sText2)


	local ac1 = cc.ProgressTo:create(2.0, 100);
	local ac2 = cc.ProgressFromTo:create(2.0, 30, 100);

	--progress:runAction( cc.RepeatForever:create(ac1) ); --2秒内，从0到100


	Dispatcher.addEventListener(EventType.loading_updateProgress,self)
	Dispatcher.addEventListener(EventType.loading_tipsFont,self)
	self.label = labelText
	self.labelText = ""
	self.progress = progress

	local text = {".","..","..."}
	self.schedulerID = Scheduler.schedule(function()
			--printTable(33,"curWinNode = ",self.curPointNode:localToGlobal(Vector2.zero))
			self.label:setString(self.labelText..text[self.index])
			--self.percentText:setString(math.ceil(progress:getPercentage()))
			self.index = self.index + 1
			if self.index > 3 then
				self.index = 1
			end
		end,0.4)

	if AgentConfiger.getAuditLoadingBg() then
		progress:setVisible(false)
		textbg:setVisible(false)
		sText2:setVisible(false)
		progressBg:setVisible(false)
	end
end

--更新loading进度条
function LoadingView:loading_updateProgress(_,percent)
	--LuaLogE("loading_updateProgress percent = ",percent)
	self.progress:stopAllActions()
	
	
	if percent == 200 then
		self.percentText:setString(100)
		Scheduler.unschedule(self.schedulerID)
		local ac1 = cc.ProgressTo:create(0.2, 100);
		local delayTime = 0.5
		if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
			delayTime = 0
		end
		local ac2 = cc.DelayTime:create(delayTime)
		self.progress:runAction( cc.Sequence:create(ac1,ac2,cc.CallFunc:create(function()
				LoadingController:loading_end(1)
		end) ));
		--self.progress:setPercentage(percent)
		--self.guangSpr:setPositionX(display.width/2+575)
	else
		--self.guangSpr:stopAllActions()
		self.progress:setPercentage(self.percent)
		--local xxx = display.width/2-575+(percent/100.0*1149)
		--print(33,"xxxxxss",xxx)
		--self.guangSpr:runAction(cc.MoveTo:create(0.5,cc.p(xxx,81)))
		self.percentText:setString(percent)
		local ac1 = cc.ProgressTo:create(0.4, percent);
		self.progress:runAction( ac1 );
	end
	self.percent = percent
end

--更新loading字体显示
function LoadingView:loading_tipsFont(_,text)

	if AgentConfiger.getAuditLoadingBg() then
		self.labelText = Desc.loading_finish1
	else
		self.labelText = text
	end

	self.label:setString(self.labelText)
	self.label:setPosition(display.width/2 - self.label:getContentSize().width/2, 45)
	self.index = 1
end

--进入loading界面
function LoadingView:enterLoadingView()

	--是否开始检查资源更新
	if false then
		--开始资源更新
	else
		--进入登录界面
		--Dispatcher.dispatchEvent(EventType.loading_end);
		LoadingController:loading_end()
	end

end

--进入loading界面
function LoadingView:clear()
	Scheduler.unschedule(self.schedulerID)
	Dispatcher.removeEventListener(EventType.loading_updateProgress,self)
	Dispatcher.removeEventListener(EventType.loading_tipsFont,self)
	self.layer:removeFromParent()
end


return LoadingView
