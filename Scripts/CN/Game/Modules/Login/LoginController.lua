

local LoginController = class("LoginController",Controller)

local LoginModel = require "Game.Modules.Login.LoginModel"
local network = require "Dex.Network.Network"
local clientNetEvent = require "Dex.Network.ClientNetEvent"
local bag = {} --服务器协议优化后的临时数据块


function LoginController:ctor()
	LuaLogE(33,"LoginController ctor")
	self.alertViewName = false
	self.alertTimer = false
end

function LoginController:init()
	LuaLogE("LoginController init")

end

-- 手动注册方法
function LoginController:_initListeners()
	Dispatcher.addEventListener(RecvType.Challenge, self)
end

function LoginController:gotoLoginView(autoLoginData)
	ViewManager.open("LoginView", autoLoginData)
end

function LoginController:user_login_success()
	print(333,"user_login_success")
	if LoginModel:isQuietRelink() then
		LoginModel:setQuietRelink(false)
		self:login_doLogin()
		return
	end

	ViewManager.closeGlobalWait()
	FlowManager.enterGameScene()
end

function LoginController:login_sdklogin_success(e, sdkRes)
	LuaLogE(DescAuto[176], sdkRes.uid, sdkRes.vsign) -- [176]="sdk登录成功"
	--ViewManager.closeGlobalWait()
	Dispatcher.dispatchEvent(EventType.login_showLoginView);
	local params = {
		onSuccess = function(data)
			ViewManager.closeGlobalWait()
			Dispatcher.dispatchEvent("login_chooseServer", data)
		end,
		
		onFailed = function(data)
			RollTips.show(Desc.login_getRecommendFail)
		end
	} 
		
	--获取推荐服
	PHPUtil.getRecommendServer(params)
	
	if VersionChange:getChangeServerId() > 0 then
		--获取服务器列表
		PHPUtil.getServerList()
	end
end

--检测客户端key
function LoginController:checkHmac(rspData)
	local dexLogin = Cache.networkCache.dexLogin

	local serverKey = crypt.base64decode(rspData.eServerKey)
	local secret = crypt.dhsecret(serverKey, dexLogin.clientKey)
	local hmac = crypt.hmac64(dexLogin.challenge,secret)

	dexLogin.serverKey = serverKey
	dexLogin.secret = secret
	dexLogin.hmac = hmac

	local function success(rspData)
		LuaLogE("CheckHmac success")
		PHPUtil.reportStep(ReportStepType.SERVER_CHECK_SUCCESS)
		self:startAuth(rspData)
	end
	
	--验证失败，回到登陆登陆界面
	local function onFailed(errorTable)
		LuaLogE("CheckHmac Failed")
		ViewManager.closeGlobalWait()
		RollTips.showError(errorTable)
		local hintStr = Desc.login_authFail
		if errorTable.repErrorStr then
			LuaLogE("Auth Failed  Str="..errorTable.repErrorStr)
			local errInfo =GameDef.ErrorCodeDict[tonumber(errorTable.repError)];
			hintStr = string.gsub(errInfo.desc, "%%s",errorTable.repErrorStr )
		end
		Dispatcher.dispatchEvent(EventType.login_show_tips,hintStr)
	end

	RPCReq.CheckHmac({
			eClientHmac = crypt.base64encode(hmac)
		},
		success, onFailed)
end


--开始平台验证
function LoginController:startAuth(args)
	local dexLogin = Cache.networkCache.dexLogin

	local function encode(data)
		return crypt.base64encode(crypt.desencode(dexLogin.secret,data))
	end

	local account = LoginModel:getUserName()
	if __QUICK_LOGIN_CONFIG__ then
		account = __QUICK_LOGIN_CONFIG__.account
	end
	account = encode(account)
	local password = encode(LoginModel:getPassword())
	local token = encode("")


	local function success(rspData)
		print(1,"rev Auth success ")
		printTable(1,rspData)
		
		local info = {
			playerId = rspData.userDataSeq[1].playerId,
			os_code = RPUtil.getOsCode(),

			cpu = RPUtil.getCpuModel(),
			phoneId = RPUtil.getDeviceId(),
			phoneType = RPUtil.getDeviceModel(),
			resolution = RPUtil.getResolution(),
			memsize = RPUtil.getRamSize(),
			osVersion = RPUtil.getOsVer(),
			networkType = RPUtil.getNetType(),
			ignoreLock	= false,
			recoverId	= 0,
			}
		LoginModel:saveLastLoginUserInfo()
		RPCReq.DoLogin(info)
	end
	
	--验证失败，回到登陆登陆界面
	local function onFailed(errorTable)
		LuaLogE("Auth Failed")
		ViewManager.closeGlobalWait()
		--RollTips.showError(errorTable)
		local hintStr = Desc.login_authFail
		if errorTable.repErrorStr then
			LuaLogE("Auth Failed  Str="..errorTable.repErrorStr)
			local errInfo =GameDef.ErrorCodeDict[tonumber(errorTable.repError)];
			hintStr = string.gsub(errInfo.desc, "%%s",errorTable.repErrorStr )
		end
		Dispatcher.dispatchEvent(EventType.login_show_tips,hintStr)
	end
	
	
	
	local extraData = {
		mac = "",
		os_code = RPUtil.getOsCode(),
		cpu = RPUtil.getCpuModel(),
		phoneId = RPUtil.getDeviceId(),
		phoneType = RPUtil.getDeviceModel(),
		resolution = RPUtil.getResolution(),
		memsize = RPUtil.getRamSize(),
		osVersion = RPUtil.getOsVer(),
		networkType = RPUtil.getNetType(),
	}

	local deviceData = {
		name = RPUtil.getDeviceModel(), 			--				1:string 		#设备名称
		os_type = RPUtil.getOsCode(), 					--				2:string 		#系统类型
		net_type = RPUtil.getNetType(), 				--				3:string		#网络类型
		id = RPUtil.getDeviceId(), 			--				4:string		#设备唯一标识
		imei_or_idfa = RPUtil.getImeiOrIdfa(), 			-- 				5:string		#Android_imei  或者IOS的IDFA
		screen_width = RPUtil.getSreenWidth(), 			--				6:string 		#屏幕宽
		screen_height = RPUtil.getSscreenHeight(), 		--				7:string		#屏幕高
		cpu_amount = RPUtil.getCpuNum(), 				--				8:string		#CPU核数
		cpu_model = RPUtil.getCpuModel(), 				--				9:string		#CPU型号
		ram_size = RPUtil.getRamSize(),  				--				10:string		#RAM大小
		rom_size = RPUtil.getRomSize(), 				--				15:string		#ROM大小
	}
	
	local channelInfo = {
		platform = RPUtil.getPlatform(), -- 				0:string		#平台
		game_channel_id = RPUtil.getChannelId(),  -- 		1:integer		#渠道包ID
		package_name = RPUtil.getPackageName(), --			2:string		#游戏包名
		parent_platform = __AGENT_CODE__,    --#父渠道
		username = account				--#平台的uid	

	}
	
	local gameInfo = {
			code = RPUtil.getGameId(), -- 				1:string 		#研发后台分配的游戏ID
			version = RPUtil.getGameVer() --				2:string 		#研发分配的游戏版本号	
		}
		
	local DataCenterData = {
		game = gameInfo, --					#
		channel = channelInfo, --				#
		device  = deviceData, --					#	
	}
	
	local info = {
		eAccount = account,
		platform = RPUtil.getPlatform(),
		eToken = token,
		ePassword = password,
		version = RPUtil.getGameVer(),
		serverId = math.tointeger(LoginModel:getLoginServerInfo().unit_server),
		parentPlatform = AgentConfiger.getLoginAgent(),
		extraData = extraData,
		dataCenterData=DataCenterData
	}
	

	print(33,"req StartAuth data = ")
	printTable(33,info)
	RPCReq.StartAuth(info,success, onFailed)
end

--监听自定义事件部分

--login 入口事件
function LoginController:login_showLoginView(evt, data)
	LuaLogE("login_showLoginView")
	--读取本地信息
	LoginModel:readSavedServerInfo()
	LoginModel:readLastLoginServer()
	self:addNotice()
	if not __SDK_LOGIN__ then
		local params = {
			onSuccess = function(data)
				--LoginModel:updateSelectedServer(data.serverInfo)  --本地的使用上次的服务品，所以不需要用推荐服
				Dispatcher.dispatchEvent(EventType.login_chooseServer)
			end,
			
			onFailed = function(data)
				RollTips.show(Desc.login_getRecommendFail)
			end
			} 
		
		--获取推荐服
		PHPUtil.getRecommendServer(params)
		
		if VersionChange:getChangeServerId() > 0 then
			--获取服务器列表
			PHPUtil.getServerList()
		end
	end
	
	--打开登录界面
	--local autoLogin = data and data.autoLogin
	self:gotoLoginView(data);
end


function LoginController:login_chooseServer(evt, data)
	if data then
		self:addNotice(data)
	end
end

--获取公告
function LoginController:addNotice( serverData )
	local args = {
		onSuccess = function(data)
		    -- printTable(1,"公告数据",data)
			LoginModel:setNotice(data)
			if serverData then
				self:checkNoticeShow(serverData)
			end
		end,
		
		onFailed = function(data)
			--RollTips.show(Desc.login_getNoticeFail)
		end
	}
	PHPUtil.getNotice(args);
end

function LoginController:checkNoticeShow( data )
	if data and data.serverInfo  then
		local health = FileCacheManager.getStringForKey("health","", nil, true)
		if health and tonumber(health) ~=data.serverInfo.health and tonumber(health) == 4 and  data.serverInfo.health~=4 then --维护后
			print(1,"checkNoticeShow维护后")
			Dispatcher.dispatchEvent(EventType.login_openNotice)
			FileCacheManager.setStringForKey("health",tostring(data.serverInfo.health), nil, true)
		else--非维护后
			local time = DateUtil.getThedaySecond(ServerTimeModel:getServerTime())
			if  data.serverInfo.health ~=4 then
				print(1,"checkNoticeShow非维护状态")
				--每日首次登录    维护后首次
				local noticeKeyVal = FileCacheManager.getStringForKey("notice","", nil, true)
				print(1,noticeKeyVal)
				if noticeKeyVal~="" then
					print(1,"checkNoticeShow有记录数据")
	               if noticeKeyVal ~= tostring(time) then --不是今天的数据
	               	  print(1,"checkNoticeShow今天首次")
	               	  Dispatcher.dispatchEvent(EventType.login_openNotice)
	               	  FileCacheManager.setStringForKey("notice", tostring(time),"", true)
	               end
				else
					print(1,"checkNoticeShow未保存过公告数据")
					Dispatcher.dispatchEvent(EventType.login_openNotice)
	                FileCacheManager.setStringForKey("notice", tostring(time),"", true)
				end
			else
				print(1,"checkNoticeShow维护中")
				Dispatcher.dispatchEvent(EventType.login_openNotice)
			end
			FileCacheManager.setStringForKey("notice", tostring(time),"", true)
			FileCacheManager.setStringForKey("health",tostring(data.serverInfo.health), nil, true)
		end
	end
end

--登陆验证（后台）
function LoginController:login_loginCheck()
	if LoginModel:getUserName() == "" then
		RollTips.show(Desc.login_userNameEmpty)
		Dispatcher.dispatchEvent(EventType.login_loginFail)
		return;
	end

	local agentCode = __AGENT_CODE__
	local data = {}
	if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
		data.uid = LoginModel:getUserName()
		data.session_id = LoginModel:getToken()
		data.session_time = LoginModel:getSessionTime()
	else
		data.uid = LoginModel:getUserName()
		data.session_id = LoginModel:getUserName()
	end

	PHPUtil.gyLogin(data, function(result)
		printTable(1,"PHPUtil.gyLogin", "success",result)
		if result and result.user_id then
			PHPUtil.reportStep(ReportStepType.PHP_VARIFY_SUCCESS)
			self:login_doLogin()
		else
			LuaLogE(DescAuto[177]) -- [177]="登陆验证失败"
			Dispatcher.dispatchEvent(EventType.login_show_tips,Desc.login_authFail)
		end
	end, 
	function(info)
		LuaLogE(DescAuto[178]) -- [178]="php登陆验证连接失败"
		printTable(1,"login_loginCheck", info)
		Dispatcher.dispatchEvent(EventType.login_show_tips,Desc.login_authFail)
	end)
end

--开始登录
function LoginController:login_doLogin()
	local serverInfo = LoginModel:getLoginServerInfo()
	if serverInfo and serverInfo.health == 4  then  --1火爆 2-畅通 3-新服 4-维护
		RollTips.show(Desc.login_nettips4)
		Dispatcher.dispatchEvent(EventType.login_openNotice)
		Dispatcher.dispatchEvent(EventType.login_loginFail)
		return
	elseif serverInfo and (serverInfo.health == 1 or serverInfo.health == 6) and not serverInfo.roleInfo then
		LuaLogE("login_doLogin no roleInfo")
		RollTips.show(Desc.login_nettips5)
		Dispatcher.dispatchEvent(EventType.login_loginFail)
		return
	end
			
			
	LuaLogE("login_doLogin ok")
	printTable(69, "login_doLogin", serverInfo )
	
	if LoginModel:getUserName() == "" then
		--RollTips.show("账号为空")
		Dispatcher.dispatchEvent(EventType.login_show_tips, Desc.login_userNameEmpty)
		--FlowManager.backToLogin()
		return;
	end
	
	if not serverInfo or (not LoginModel:getLoginIp()) or (not LoginModel:getLoginPort()) then
		LuaLogE("login_doLogin1113333")
		--RollTips.show(Desc.login_chooseServerFirst)
		--FlowManager.backToLogin()
		Dispatcher.dispatchEvent(EventType.login_show_tips, Desc.login_chooseServerFirst)
		return;
	end
	
	if VersionChange:doChangeVersion(serverInfo) then
		return
	end
	
	self:startConnect()
end

--开始连接服务器
function LoginController:startConnect()
	local loginIp = LoginModel:getLoginIp()
	local port = LoginModel:getLoginPort()

	if loginIp == nil or port == nil then
		return
	end
	
	--开始连接
	network.ClientConnect(loginIp,port,clientNetEvent)

	----链接成功后开始做登陆验证。
	function clientNetEvent.SwitchService( clientEntity, newServiceType )

	end

	function clientNetEvent.ConnectError( addr, port, errStr,isRelink )
		LuaLogE("clientNetEvent.ConnectError",errStr)
		ViewManager.closeGlobalWait()
		ViewManager.closeReconnectWait()
		Dispatcher.dispatchEvent(EventType.login_show_tips,Desc.login_nettips1)
		Dispatcher.dispatchEvent(EventType.login_loginFail)
	end
end

--打开选服界面
function LoginController:login_openServerList()
	--[[local serverGroups =  LoginModel:getServerGroups();
	if #serverGroups == 0 then
		--没有获取到服务器列表
		RollTips.show(Desc.login_gettingServer)
		return
	end
	--]]
	local param = {}
	param.onSuccess = function ()
		ViewManager.open("ServerListView")
	end
	PHPUtil.getServerList(param)
	
end

--打开登录公告
function LoginController:login_openNotice()

	local Notice =  LoginModel:getNotice(6);
	--printTable(1,Notice)
	if Notice == nil or (not Notice[1]) then
		--没有获取到公告
		-- Alert.show(Desc.login_gettingNotice)
		return
	end

	ViewManager.open("LoginNoticeView")
end



---监听网路事件部分


--连接成功后登陆前几步验证
function LoginController:Challenge( cmd,args,Cache )

	print(33,"rev Challenge")
	if not Cache.dexLogin then
		Cache.dexLogin = {}
	end
	local data = Cache.dexLogin
	data.challenge = crypt.base64decode(args.challenge)
	data.clientKey = crypt.randomkey()

	local function success(rspData)
		self:checkHmac(rspData)
	end

	--连接服务器成功
	PHPUtil.reportStep(ReportStepType.CONNNECT_SERVER_SUCCESS)

	RPCReq.Handshake({
			eClientKey = crypt.base64encode(crypt.dhexchange(data.clientKey))
		},
		success)
end

--网络连接状态提示
function LoginController:socket_tryreconnect(_,times)

	--RollTips.show(Desc.socket_reTryConnect:format(times))
	
end

--网络连接状态提示
function LoginController:login_show_tips(_,desc)
	--if self.alertViewName and ViewManager.isShow(self.alertViewName) then return end --防止重复弹窗
	if ViewManager.hadShowCloseTips then return end
	if self.alertTimer then Scheduler.unschedule(self.alertTimer) end
	self.alertTimer = Scheduler.scheduleNextFrame(function()
			Alert.closeAll()
			ViewManager.closeGlobalWait()
			ViewManager.closeReconnectWait()
			local info = {}
			info.text = desc
			info.type = "ok"
			info.align = "center"
			info.mask = true
			info.noClose = "yes"
			info.onOk = function()
				ViewManager.hadShowCloseTips  = false
				FlowManager.backToLogin()
			end
			local view,viewName = Alert.show(info)
			ViewManager.hadShowCloseTips  = true
			self.alertViewName = viewName
		end)
	
end

--网络连接失败处理
function LoginController:socket_disconnect()
	--if ViewManager.isShow("LoginView") then
		--RollTips.show(Desc.login_nettips1)
	--else
		--ViewManager.closeGlobalWait()
		--ViewManager.closeReconnectWait()
		--[[local info = {}
		info.text = Desc.login_nettips2
		info.onClose = function()
			FlowManager.backToLogin()
		end
		info.mask = true
		Alert.show(info)--]]
	--end
end

--帐号在其他设备登陆
function LoginController:login_elseLogin()
	if self.alertTimer then Scheduler.unschedule(self.alertTimer) end
	self.alertTimer = Scheduler.scheduleNextFrame(function()
		Alert.closeAll()
		ViewManager.closeGlobalWait()
		ViewManager.closeReconnectWait()
		local info = {}
		info.type = "yes_no"
		info.mask = true
		info.yesText = Desc.login_nettips6
		info.noText = Desc.login_nettips7
		info.text = Desc.login_relogin
		info.onYes = function()
			--self:fairyLand_moveComplete()
			FlowManager.backToLogin(false,false, true)
			--重连需要保存之前的账号信息，防止唤出sdk登陆界面
			--FlowManager.clear(false)
			--重新初始化
			--FlowManager.init()
			--self:login_doLogin()
		end
		info.onNo = function()
			--self:fairyLand_moveComplete()
			FlowManager.backToLogin()
		end
		Alert.show(info)
	end)
end

-- bag					31:*PBag_Bag(type)					#背包模块数据
-- .PBag_Bag {
-- 	type 			0:integer				#背包类型
-- 	items     		2:*PItem_Item(id)			#物品的map
-- 	capacity		3:integer				#背包当前容量
-- }

-- Bag_PostBagInfos 13332 {
-- 	request {
-- 		bags		1:*PItem_Item #每次二百个道具
-- 		type 		2:integer #背包类型
-- 		bagEnd 		3:integer #判断有没有背包发完
-- 	}
-- }

function LoginController:Bag_PostBagInfos( _,args )
	-- printTable(1,"Bag_PostBagInfos",args)
	if not bag[args.type] then
		bag[args.type] = {}
		bag[args.type].type = args.type
		bag[args.type].items = {}
	end
	if args.bags then
		for i,v in ipairs(args.bags) do
			table.insert(bag[args.type].items,v)
		end
	end
	
    -- printTable(1,"bag[args.type]",bag[args.type])
	if args.bagEnd ==1 then

		ModelManager.PackModel:setPack(bag[args.type])
	end
end

--服务器下推玩家信息
function LoginController:Login_PlayerData(_,args )
	--各模块可以自行定义 login_player_data 去接收登录数据
	ModelManager.loginPlayerDataInit(args)
	VersionChange:clearChangeServerId()
	-- body
	--LoginModel:updateRoleData(info)
	--角色数据初始化
	PlayerModel:haddleLoginData(args);
	
	SDKUtil.setBuglyUserInfo()
	
	ShopModel:haddleShopData(args.baseData.shop)

	local baseData = args.baseData
	--背包数据初始化
	--服务器压力 修改为协议下发
	-- -- printTable(1,baseData.bag)
	-- for k, v in pairs(baseData.bag) do
	-- 	ModelManager.PackModel:setPack(v)
 --    end
	-- printTable(1,baseData.limit,"拿到的卡牌1")
	ModelManager.CardLibModel:setInitInfos(baseData)
	ElvesSystemModel:initLimit(baseData.limit)
	HandbookModel:initLimit(baseData.limit)
	CrossPVPModel:initLimit(baseData.limit)
	CrossTeamPVPModel:initLimit(baseData.limit)
	GetCardsModel:initData(baseData.heroLottery,baseData.limit)
	ModelManager.MaterialCopyModel:setCopyLimit(baseData.limit)
	ModelManager.MaterialCopyModel:setCopyInfos(baseData.copy)
	ModelManager.ChatModel:setChatSetting(baseData.chat)
	ModelManager.PataModel:setPataInfos(baseData.copy)
	--printTable(1,baseData.task,baseData.activeScore,"任务数据")
	ModelManager.TaskModel:initData(baseData.task,baseData.activeScore)
	ModelManager.FairyLandModel:initData(baseData.fairyLand)
	ModelManager.MazeModel:setInitData(baseData.maze)
	ModelManager.TacticalModel:setInitData(baseData.tactical)
	ModelManager.HeroPalaceModel:setInitData(baseData.heroPalace)
	ModelManager.RechargeModel:updateRechargeStat(baseData.rechargeStat)
	ModelManager.PlayerModel:setDailyStat(baseData.dailyStat)
	ModelManager.PlayerModel:setStat(baseData.stat)
	GamePlayModel:initData(baseData.gp);
	TrainingModel:initData(baseData.gp)
	VipModel:initData(baseData.vip);
	SealDevilModel:initData(baseData.devilRoad)
	CrossLaddersChampModel:initData(baseData.skyLadChampion)
	
	
	ModelManager.DownLoadGiftModel:initData(baseData.gp.downloadReward)
	ModelManager.GuildMLSModel:playerData(baseData.evilMountain)
	
	--好友数据没有下推 其他模块需要 提前请求
	local params = {}
	params.type = GameDef.FriendListType.FriendList
	params.onSuccess = function (res )
	   if res.type == GameDef.FriendListType.FriendList then
		  ModelManager.FriendModel:initData(GameDef.FriendListType.FriendList,res.list)
	   end 
	end
	RPCReq.Friend_List(params, params.onSuccess)

	--提前请求巅峰竞技
	StrideServerModel:reqInfoData()

	--if LoginModel.hasLogin then return end 
	--LoginModel.hasLogin = true
	--同步服务器时间
	ServerTimeModel:setOpenDateTime(args.openDateMs)
    ServerTimeModel:setCurTimeZone(args.timeZone)
    ServerTimeModel:startClock(args.serverMs)

	--接受消息完成 通知登录成功并进入主界d面
	self:user_login_success();
	printTable(4,baseData.battle," Battle_AllBattleArrays")
	Dispatcher.dispatchEvent(EventType.battle_config,baseData.battle)
	
	Dispatcher.dispatchEvent(EventType.guide_first)
	
	VipMemberModel:updateMemberData() --获取客服信息
	--提交玩家数据到api中心
	PHPUtil.updatePlayer()

	--进入模块检测逻辑
	ModuleUtil.checkModuleOpen(0 , 0 , true)

	--各模块都接受完数据后 处理各种相互依赖的逻辑数据
	ModelManager.loginPlayerDataFinish(args)
	TimingPushModel:setSeverData(args.baseData.gp)
	HeroFettersModel:setSeverData(args.baseData.heroFetter)
	Dispatcher.dispatchEvent("ModuleOpen_CheckFinish")
end
-------------

--服务器下推更新卡牌信息
function LoginController:Hero_UpdateInfo(_,args )
	print(4,"rev HeroUpdateData")
end
-------------

--服务器下推战斗阵容信息
function LoginController:Battle_AllBattleArrays(_,args )
	printTable(4,args,"Battle_AllBattleArrays")
	Dispatcher.dispatchEvent(EventType.battle_config,args.arrayInfos)
end


--登陆后所有推消息完成了
function LoginController:Login_PlayerDataFinished(_,info)
	local dayStr = DateUtil.getOppostieDays()..""
	if FileCacheManager.getStringForKey("firstEnterGameToday", "0") ~= dayStr then
		FileCacheManager.setStringForKey("firstEnterGameToday", dayStr)
		--延迟一点等服务端的消息到了再发事件
		Scheduler.scheduleOnce(0.1, function ()
			Dispatcher.dispatchEvent(EventType.public_firstEnterGameToday) --今天第一次进入游戏
		end)
	end
	LoginModel.hadEnterGame = true
	Dispatcher.dispatchEvent(EventType.public_enterGame)  --进入游戏
	SDKUtil.recordRoleInfo(AgentConfiger.SDK_RECORD_ENTER_SERVER)
end

function LoginController:clear( ... )
	bag = {}
end

return LoginController
