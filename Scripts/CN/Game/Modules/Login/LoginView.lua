
local LoginView,Super = class("LoginView", View)
local LoginModel = require "Game.Modules.Login.LoginModel"
local FlowManager = require "Game.Managers.FlowManager"

function LoginView:ctor(args)
	LuaLogE("LoginView ctor")
	self._packName = "Login"
	self._compName = "LoginView"
	self._isFullScreen = true
	self.loginBtn = false
	self.serverBtn= false
	self.serverText= false
	self.serverID= false
	self.serverHealth = false;
	self.testlabel = false
	self.noticeBtn = false
	self.agreeBtn = false
	-- self.settingBtn = false
	self.inputNameText = false
	self.yonghuBtn = false
	self.btn_openDebug = false
	self.txt_testInfo = false
	self.txt_zfInfo = false
	self.bg_loader = false    --用来加载更新背景的
	self.logo_loader = false    --用来加载更新背景的
	self.effectLoader_down = false    --底层特效
	self.modelLoader = false    --模型
	self.effectLoader_up = false    --顶层特效
	
	self._updateTimeId = false --测试按钮检测定时器
	self._testBtnClickNum = 0 --测试按钮点击次数，连击5下打开debug模式
	
	self.enterGame = false -- 进入游戏、服务器列表组
	self.bg = false
	self.logo = false
	self.autoLogin = args.autoLogin
	self.autoLoginServerInfo = args.serverInfo
end

function LoginView:_initUI()
	LuaLogE("LoginView _initUI")
	--SoundManager.playMusic(15, nil, false, "LoadingView")
	self:playBgm()
	
	LuaLogE("__SDK_LOGIN__" .. tostring(__SDK_LOGIN__))--]]
	self.btn_openDebug = self.view:getChildAutoType("btn_openDebug")
	self.txt_testInfo = self.view:getChildAutoType("txt_testInfo")
	self.loginBtn = self.view:getChildAutoType("_GButton$begin")
	self.enterGame = self.view:getChildAutoType("enterGame")
	self.bg = self.view:getChildAutoType("bg")
	self.logo = self.view:getChildAutoType("logo")
	self.bg_loader = self.view:getChildAutoType("bg_loader")
	self.logo_loader = self.view:getChildAutoType("logo_loader")
	self.testlabel = self.view:getChildAutoType("testlabel")
	self.txt_zfInfo = self.view:getChildAutoType("txt_zfInfo")
	self.effectLoader_down = self.view:getChildAutoType("effectLoader_down")
	self.modelLoader = self.view:getChildAutoType("modelLoader")
	self.effectLoader_up = self.view:getChildAutoType("effectLoader_up")
	self.versionText = self.view:getChildAutoType("versionText")
	self.versionText:setText(string.format("%s_%s_%s",gy.GYPlatform:getAppVersionCode(),__APP_VERSION__,__SCRIPT_VERSION__))
	self.versionText:setPosition(self.versionText:getPosition().x,self.versionText:getPosition().y - self.view:getPosition().y)
	self.txt_zfInfobg = self.view:getChildAutoType("n35")
	self.txt_zfInfo2 = self.view:getChildAutoType("n26")
	local h = self.txt_zfInfobg:getHeight()
	self.txt_zfInfo2:setPosition(self.txt_zfInfo2:getPosition().x,self.txt_zfInfo2:getPosition().y + self.view:getPosition().y)
	self.txt_zfInfobg:setHeight(h)

	local txt_testApi = self.view:getChildAutoType("txt_testApi")
	txt_testApi:setVisible(__USE_TEST_URL__)
	
	if __SDK_LOGIN__ and LoginModel:getUserName() == "" then
		self.enterGame:setVisible(false)
	end

	self.loginBtn:addClickListener(function()
		self:loginHandler()
	end)

	self.serverBtn = self.view:getChildAutoType("_GButton$server")

	self.serverBtn:addClickListener(function()
			Dispatcher.dispatchEvent(EventType.login_openServerList)
	end)
	
	self.noticeBtn = self.view:getChildAutoType("_GButton$gonggao")
	--local tips=ModuleUtil.moduleOpen(ModuleId.GameNoticeView.id,false)
	--if tips==true then--前端开启了该功能
	self.noticeBtn:setVisible(true)
	--else
	--	self.noticeBtn:setVisible(false)
	--end
	if AgentConfiger.isAudit() then
		self.noticeBtn :setVisible(false)
	end
	
	self.noticeBtn:addClickListener(function()
			Dispatcher.dispatchEvent(EventType.login_openNotice)
		end)
	self.bg:addClickListener(function()
		if LoginModel.needRelogin then
			LoginModel.needRelogin = false
			SDKUtil.login()
		end
	end)
	
	self.yonghuBtn = self.view:getChildAutoType("_GButton$yonghu")
	self.yonghuBtn:addClickListener(function()
			--local ttttsssssMs = os.clock()
			--rawset(_G,"ttttsssssMs",ttttsssssMs)
			--ViewManager.open("PushMapView")
			--Alert.show("")
		end)
	

	self.serverText = self.view:getChildAutoType("_GButton$server/_GTextField$name")
	self.serverID = self.serverBtn:getChildAutoType("_GTextField$id")
	self.serverHealth = self.serverBtn:getChildAutoType("loader_status");
	self.agreeBtn = self.view:getChildAutoType("agreebt")
	self.serverText:setText("")
	self:updateSelectServer()
	--self.agreeBtn:setVisible(false)
	self.agreeBtn:addClickListener(function()
			--Dispatcher.dispatchEvent(EventType.login_doLogin)
			--print(33,"5556666")

			self.loginBtn:setTouchable(not self.agreeBtn:isSelected())

			self.loginBtn:setGrayed(self.agreeBtn:isSelected())
		end)

	self.inputNameText = self.view:getChildAutoType("username")
	
	--这里是加载背景和logo
	local bgUrl = AgentConfiger.getAuditLoginBg()
	if not bgUrl then
		bgUrl = "ResStay/loginBg.jpg"
		local saveBgUrl = FileCacheManager.getStringForKey("loginBg", "", nil, true)
		if saveBgUrl and saveBgUrl ~= "" and cc.FileUtils:getInstance():isFileExist(saveBgUrl) then 
			bgUrl = saveBgUrl
		elseif not cc.FileUtils:getInstance():isFileExist(bgUrl) then
			bgUrl = "UI/Loading/loginBg.jpg"
		end
	end
	LuaLogE("set bgUrl = "..bgUrl)
	if string.find(bgUrl, "http") then
		self.bg:setNetWorkUrl(bgUrl)
	else
		self.bg:setURL(bgUrl)
	end
	
	local logoUrl = "ResStay/gameLogo.png"
	local saveLogoUrl = FileCacheManager.getStringForKey("logoUrl", "", nil, true)
	if saveLogoUrl and saveLogoUrl ~= "" and cc.FileUtils:getInstance():isFileExist(saveLogoUrl) then 
		logoUrl = saveLogoUrl
	elseif not cc.FileUtils:getInstance():isFileExist(logoUrl) then
		logoUrl = "UI/Loading/gameLogo.png"
	end
	if string.find(logoUrl, "http") then
		self.logo:setNetWorkUrl(logoUrl)
	else
		self.logo:setURL(logoUrl)
	end

	self:showZfInfo()
	xpcall(function()
			--这里是检查是否有新的背景和logo，有的话先下载回来，下次打开游戏再用
			local strs = string.split(__RES_URL__, "/")
				for i=1,3,1 do
					strs[#strs] = nil
				end
			local updateRoot = TableUtil.join(strs, "/").."/"
			
			local newBgUrl = FileCacheManager.getStringForKey("platform_loginBg", "", nil, true)
			if newBgUrl then
				if newBgUrl == "" then 
					FileCacheManager.setStringForKey("loginBg", "", nil, true)
				else
					newBgUrl = updateRoot.."publicRes/"..newBgUrl
					HttpUtil.downLoadImage(newBgUrl,function(url, filePath)
						--下载完才写到本地，防止打开游戏时背景是黑色的
						LuaLogE("new loginBg loaded newBgUrl= "..filePath)
						FileCacheManager.setStringForKey("loginBg", filePath, nil, true)
					end)
				end
			end
			
			local newlogoUrl = FileCacheManager.getStringForKey("platform_logo", "", nil, true)
			if newlogoUrl then
				if newlogoUrl == "" then 
					FileCacheManager.setStringForKey("logoUrl", "", nil, true)
				else
					newlogoUrl = updateRoot.."publicRes/"..newlogoUrl
					HttpUtil.downLoadImage(newlogoUrl,function(url, filePath)
						--下载完才写到本地，防止打开游戏时背景是黑色的
						LuaLogE("new loginLogo loaded newlogoUrl= "..filePath)
						FileCacheManager.setStringForKey("logoUrl", filePath, nil, true)
					end)
				end
			end		
			
			
			local newLoadingUrl = FileCacheManager.getStringForKey("platform_loadingBg", "", nil, true)
			if newLoadingUrl then
				if newLoadingUrl == "" then 
					FileCacheManager.setStringForKey("loadingBgUrl", "", nil, true)
				else
					newLoadingUrl = updateRoot.."publicRes/"..newLoadingUrl
					HttpUtil.downLoadImage(newLoadingUrl,function(url, filePath)
						--下载完才写到本地，防止打开游戏时背景是黑色的
						LuaLogE("new loadingBg loaded loadingBgUrl= "..filePath)
						FileCacheManager.setStringForKey("loadingBgUrl", filePath, nil, true)
					end)
				end
			end
		end, __G__TRACKBACK__)
	
	-- self.view:getChildAutoType("n25"):setWidth(display.width)
	-- self.view:getChildAutoType("n25"):setPosition(-(display.width - self.view:getWidth())/2,643)
	
	if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID or CC_TARGET_PLATFORM == CC_PLATFORM_IOS) and not LoginModel:isTestAgent()  then
		self.view:getChildAutoType("n22"):setVisible(false)
		self.view:getChildAutoType("n20"):setVisible(false)
		self.inputNameText:setVisible(false)
	else
		self.inputNameText:setText(LoginModel:getUserName())
		print(33,"inputNameText = ",self.inputNameText:getText())
		self.inputNameText:onChanged(function (str)
			print(33,"inputNameText =",str)	
			LoginModel:setUserName(str)
		end)
	end

	---显示更新-------------------------
	--多次点击显示包信息
	local tapTimes, invalidDelay = 0, 500
	local lastMs = 0
	self.btn_openDebug:addClickListener(function()
			local ms = cc.millisecondNow()
			if ms - lastMs <= invalidDelay then
				tapTimes = tapTimes + 1
				if tapTimes >= 6 then
					tapTimes = 1
					self:showDebugInfo()
				end
			else
				tapTimes = 1
				local packageInfo = self.view:getChildAutoType("updateInfoText")
				packageInfo:setVisible(false)
			end
			lastMs = ms
		end)

	
	GMModel:regOpenWay()
	
	--如果sdk已经登陆过的了，直接去拿服务器列表
	--if SDKUtil._loginSuccessData then
		--Dispatcher.dispatchEvent(EventType.login_sdklogin_success)
	--end
	
	if self.autoLogin then
		LoginModel:updateSelectedServer(self.autoLoginServerInfo)
		self:loginHandler()
	end
	
	
	if __IS_RELEASE__ then
		Scheduler.schedule(function()
				local c1 = collectgarbage("count")
				LuaLogE("lua Memory size:"..math.ceil(c1/1024))
			end,10)
	end
	
	local heroIds = {
						{heroId = 55002, pos = {x = 70, y = 610}, scaleX = 0.25,scaleY = 0.25},
						{heroId = 45003, pos = {x = -440, y = 225}, scaleX = -0.4, scaleY = 0.4},
						{path = "Spine/ui/yase",animation = "animation3", skelName="yase_lihui",atlasName="yase_lihui", pos = {x = 430, y = 520}, scaleX = 0.5, scaleY = 0.5},
						

					}
	for _,v in pairs(heroIds) do
		local skeletonNode
		if v.heroId then
			skeletonNode = SpineUtil.createHeroDraw(self.modelLoader,v.pos,v.heroId,false,0)
		else
			skeletonNode = SpineUtil.createHeroDrawByName(self.modelLoader,v.pos, v.path, v.skelName, v.atlasName,v.animation)
		end
		
		skeletonNode:setScaleX(v.scaleX)
		skeletonNode:setScaleY(v.scaleY)
	end
	
	SpineUtil.createSpineObj(self.effectLoader_up, vertex2(0,0), "animation", "Spine/ui/denglu", "denglu_texiao_up", "denglu_texiao",true)
	SpineUtil.createSpineObj(self.effectLoader_down, vertex2(0,0), "animation", "Spine/ui/denglu", "denglu_texiao_down", "denglu_texiao",true)
end


function LoginView:getPicExtend()
	local extend = ""
	if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
		extend = "_rgd"
	elseif CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
		extend = "_ptx"
	end
	return extend
end

function LoginView:login_loginFail()
	self.loginBtn:setVisible(true)
	ViewManager.closeGlobalWait()
end


function LoginView:_initEvent( ... )
	self:addEventListener(EventType.login_sdkInit_success,self)
end

--登陆按钮处理
function LoginView:loginHandler()
	ViewManager.showGolbalWait()
	self.loginBtn:setVisible(false)
	local Game = require "Game.Game"
	--检测没有文件更新后开始登陆
	Game.checkUpdate(function()
		if LoginModel:isTestAgent() then
			if __IS_SHOW_LOGININFO__ and  (CC_TARGET_PLATFORM == CC_PLATFORM_MAC or CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) then
				local str = self.testlabel:getText()
				if string.find(str, "-") then
					local serverId = tonumber(string.split(str, "-")[1])
					local url = string.split(str, "-")[2]
					local ip = string.split(url, ":")[1]
					local port = tonumber(string.split(url, ":")[2])
					local serverInfo = LoginModel:getLoginServerInfo()
					local newServerInfo = TableUtil.DeepCopy(serverInfo)
					serverInfo.unit_server = serverId
					serverInfo.ip = ip
					serverInfo.port = port - 2000
					LoginModel:updateSelectedServer(serverInfo)
				end
			end
			Dispatcher.dispatchEvent(EventType.login_doLogin)
		else
			Dispatcher.dispatchEvent(EventType.login_loginCheck)  --不是test渠道
		end
	end)
end

function LoginView:updateSelectServer()
	local serverInfo = LoginModel:getLoginServerInfo()
	if not serverInfo then
		self.serverID:setText("")
		self.serverText:setText("")
		return 
	end
	-- printTable(1, serverInfo);
	printTable(33, "LoginView:updateSelectServer", serverInfo)
	local serverId = serverInfo and (serverInfo.displayCode or serverInfo.server_id) or "10001"
	local serverName = serverInfo and serverInfo.name or "default"
	local serverHealth = serverInfo and (serverInfo.health or 2) or 2;
	if serverHealth > 5 then
		serverHealth = serverHealth - 5
	end
	serverHealth = serverHealth > 2 and (serverHealth - 1) or serverHealth;

	self.serverID:setText(serverId)
	self.serverText:setText(serverName)
	self.serverHealth:setIcon("UI/Login/dl_zt_0"..serverHealth..".png");
	self.serverBtn:getController("newCtrl"):setSelectedIndex((serverInfo.health == 3) and 1 or 0)


	if __IS_SHOW_LOGININFO__ and  (CC_TARGET_PLATFORM == CC_PLATFORM_MAC or CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) then
		
		local serverId = LoginModel:getUnitServerId() or 0
		local loginIp = LoginModel:getLoginIp() or ""
		local port = LoginModel:getLoginPort() or ""
		self.testlabel:setText(serverId.."-"..loginIp..":"..port)
		self.testlabel:setVisible(true)
	end
end


function LoginView:login_chooseServer()
	self:updateSelectServer();
	local serverInfo = LoginModel:getLoginServerInfo()
	if not tolua.isnull(self.enterGame) then
		self.enterGame:setVisible(serverInfo ~= nil)
	end
end


function LoginView:showZfInfo()
	local lineMax = 40
	local spw = FileCacheManager.getStringForKey("ApprovalNumber", "",nil, true)  --审批文号
	local wwy = FileCacheManager.getStringForKey("GameSpareNumber", "",nil, true) --文网游备字
	local cbw = FileCacheManager.getStringForKey("PublicationNumber", "",nil, true) --网络游戏出版号 ISBN
	local yydw = FileCacheManager.getStringForKey("OperatingUnit", "", nil, true) --运营单位
	local cbdw = FileCacheManager.getStringForKey("PublishingUnit", "", nil, true) -- 出版单位
	local author = FileCacheManager.getStringForKey("Author", "", nil, true) -- 著作人
	local xkz = FileCacheManager.getStringForKey("LicenseNumber", "", nil, true) -- 网络经营许可证编号 粤网文
	local showStr = ""
	local hasAdd = false
	
	local needAdd = function()
		if #showStr < lineMax then return "" end
		if hasAdd then return "" end
		hasAdd = true
		return "\n"
	end
	if spw ~= "" then showStr = showStr..Desc.login_text1..spw.." "..needAdd() end
	if cbw ~= "" then showStr = showStr.."ISBN: "..cbw.." "..needAdd() end
	if cbdw ~= "" then showStr = showStr..Desc.login_text2..cbdw.." "..needAdd() end
	if yydw ~= "" then showStr = showStr..Desc.login_text3..yydw.." "..needAdd() end
	if author ~= "" then showStr = showStr..Desc.login_text4..author.." "..needAdd() end
	if xkz ~= "" then showStr = showStr..Desc.login_text5..xkz.." "..needAdd() end
	--if #showStr > 2 then showStr = string.gsub(showStr, )
	--审批文号：    出版单位：
--网络游戏出版物号：  运营单位：   著作人：
	self.txt_zfInfo:setText(showStr)
end


--显示debug信息
function LoginView:showDebugInfo()
	if LoginModel:isTestAgent() then
		_G.__IS_RELEASE__ = false
	end
	local updatePath = gy.GYScriptManager:getInstance():getUpdateDirectory()
	local info = string.format([[
		后台地址：%s 
		下载地址：%s 
		下载路径：%s 
		账号：%s 
		主渠道：%s 
		子渠道：%s 
		互通渠道：%s 
		列表md5：%s 
		是否审核：%s 
		包版本：%s 
		游戏版本：%s 
		端口：%s ]],
	tostring(AgentConfiger.centerURL or ""), tostring(__RES_URL__ or ""), tostring(updatePath or ""),
	tostring(LoginModel:getUserName() or ""), tostring(__AGENT_CODE__ or ""), tostring(__AGENT_SUFFIX__ or ""), 
	tostring(AgentConfiger.getLoginAgent() or ""), tostring(__SERVER_LIST_MD5__ or ""), tostring(__IN_AUDITING__ or ""), tostring(__APP_VERSION__ or ""), 
	tostring(__SCRIPT_VERSION__ or ""), tostring(LoginModel:getLoginPort() or ""))
	local packageInfo = self.view:getChildAutoType("updateInfoText")
	packageInfo:setText(info)
	packageInfo:setVisible(true)
end



return LoginView