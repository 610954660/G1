-----------------------------
--强烈需要注意，在sdk的各个回调方法里面可能存在一些常用的全局变量/对象还没有初始化，如EventType，使用时需特别注意
-----------------------------
local SDKUtil = {}
local GY_CALLBACK_TYPE_INIT = 1		--初始化回调//
local GY_CALLBACK_TYPE_LOGIN = 2	--登录回调//
local GY_CALLBACK_TYPE_LOGOUT = 3	--登出回调//
local GY_CALLBACK_TYPE_PURCHASE = 4	--充值回调//
local GY_CALLBACK_TYPE_EXT = 5		--扩展回调//



--登录成功返回的数据
local _loginSuccessData = false


--注册sdk回调
local function onSDKCallback(type, args)	
	-- LuaLogE("onSDKCallback type="..type)
	if type == GY_CALLBACK_TYPE_INIT then
		LuaLogE("~~~~~~onSDKInitSuccess")
		PHPUtil.reportStep(ReportStepType.SDK_INIT_SUCCESS)
		if Dispatcher then
			Dispatcher.dispatchEvent(EventType.login_sdkInit_success)
		end

	elseif type == GY_CALLBACK_TYPE_LOGIN then
		-- LuaLogE("~~~~~~====onSDKLoginSuccess", args)
		if not args then
			PHPUtil.reportBug(BugInfoType.LOGIN_SDK_FAILED, "SDK登录失败，返回的信息为空！")
			return
		end

		local sdkResData = json.decode(args)
		if not sdkResData then
			LuaLogE("解json失败")
			PHPUtil.reportBug(BugInfoType.LOGIN_SDK_FAILED, "SDK登录失败，解析返回数据失败！")
			return
		end
		if not sdkResData.uid then
			--LoginModel.needRelogin = true
			LuaLogE("~~~~~~onSDKLoginError", args)
			--SDKUtil.login()
			LoginModel.needRelogin = true
			ViewManager.closeGlobalWait()
			Dispatcher.dispatchEvent("login_sdklogin_failed")
			return
		end
		_loginSuccessData = sdkResData
		LoginModel:setUserName(sdkResData.uid)
		LoginModel:setToken(sdkResData.vsign)
		LoginModel:setSessionTime(sdkResData.timestamp)
		LuaLogE("----onSDKLoginSuccess")
		PHPUtil.reportStep(ReportStepType.SDK_LOGIN_SUCCESS)
		--Dispatcher.dispatchEvent("login_sdkLogin_success1")  --这里用EventType.login_sdkLogin_success的话，loginView里面的触发不了，原因暂不明
		Dispatcher.dispatchEvent("login_sdklogin_success", sdkResData)

	elseif type == GY_CALLBACK_TYPE_LOGOUT then
		LuaLogE("~~~~onSDKLogoutSuccess ")
		local LoginModel = require "Game.Modules.Login.LoginModel"
		LoginModel:updateSelectedServer() --清空之前选的服务器（服务器列表记录的角色信息是之前帐号的）
		_loginSuccessData = false
		FlowManager.backToLogin(nil, true)
		LoginModel:setUserName("")
		LoginModel:setToken("")
		Dispatcher.dispatchEvent(EventType.login_sdkLogout_success)	
		if args == "changeAccount" then
			SDKUtil.logout()
		end

	elseif type == GY_CALLBACK_TYPE_PURCHASE then


	elseif type == GY_CALLBACK_TYPE_EXT then
		
		if args then
			local dict = json.decode(args)
			if dict then
				local notch = dict.notch				
				if notch and notch ~= "" then  --刘海屏
					local cutoutWidth, cutoutHeight, screenWidth, screenHight, corner = string.match(notch,"(%d+),(%d+),(%d+),(%d+),(%d+)")
					local cutoutWidth = tonumber(cutoutWidth)
					local cutoutHeight = tonumber(cutoutHeight)
					local screenWidth = tonumber(screenWidth)
					local screenHight = tonumber(screenHight)
					local corner = tonumber(corner)

					if cutoutWidth > 0 and screenHight > 0 then
						cutoutWidth = cutoutWidth/screenHight*720
					end
					if cutoutHeight > 0 and screenWidth > 0 then
						cutoutHeight = cutoutHeight/screenWidth*1280
					end
					DeviceUtil.setCutoutSize(cutoutWidth, cutoutHeight, 0, 0, corner)
				elseif dict.type == "cancelLogin" then--取消登录
					Dispatcher.dispatchEvent(EventType.login_sdkLogin_cancel)
				elseif dict.type == "registerSuccess" then--注册成功
					Dispatcher.dispatchEvent(EventType.login_sdkRegister_success)
				elseif dict.type == "verifySuccess" then  --登录验证成功
					Dispatcher.dispatchEvent(EventType.login_sdkVerify_success)
				elseif dict.type == "getRealName" then --实名认证
					ShopModel.realNameInfo = dict
					LuaLogE("realNameInfo = ",json.encode(dict))
				elseif dict.type == "screenShot" then --开始截图
					DisplayUtil.captureScreen(function (isSucceed,name )
						-- body
						--print(911, "isSucceed,name",isSucceed,name)
						gy.GYChannelSDK:getInstance():extraAPI(AgentConfiger.SCREEN_SHOT_SUCCESS, name)
					end, cc.rect(0,0,display.width, display.height), "screenShot.jpg")
				elseif dict.type == "switchAccount" then --切换帐号
					LuaLogE("~~~~onSDKSwitchAccount")
					local LoginModel = require "Game.Modules.Login.LoginModel"
					LoginModel:updateSelectedServer() --清空之前选的服务器（服务器列表记录的角色信息是之前帐号的）
					LoginModel:setUserName("")
					_loginSuccessData = false
					FlowManager.backToLogin(nil, true)
					Dispatcher.dispatchEvent(EventType.login_sdkLogout_success)
					
					_loginSuccessData = dict
					LoginModel:setUserName(dict.uid)
					LoginModel:setToken(dict.vsign)
					
					--Dispatcher.dispatchEvent("login_sdkLogin_success1")  --这里用EventType.login_sdkLogin_success的话，loginView里面的触发不了，原因暂不明
					Dispatcher.dispatchEvent("login_sdklogin_success", dict)					
				end
			end
		end
	end
end

---------------------------

--初始化
function SDKUtil.init()
	local gyChannelSDK = gy.GYChannelSDK:getInstance()
	gyChannelSDK:registerEventCallback(onSDKCallback)
	gy.GYChannelSDK:getInstance():extraAPI(AgentConfiger.DEVICE_GET_SAFE_AREA, "1")
end

--登录
function SDKUtil.login()
	LuaLogE("~~~~login~~~~", tostring(_loginSuccessData))
	if not _loginSuccessData then
		gy.GYChannelSDK:getInstance():login()
	else
		Dispatcher.dispatchEvent(EventType.login_sdklogin_success, _loginSuccessData)
	end
end

--登出
function SDKUtil.logout()
	local function nextFrame()   --必须下一帧，否则在回调里面清掉根节点会崩溃
		LuaLogE("Call logout!")
		gy.GYChannelSDK:getInstance():logout()
	end
	Scheduler.scheduleNextFrame(nextFrame)	
end

--登录验证失败
function SDKUtil.onVerifyFailed()
	_loginSuccessData = false
end

--打开连接
function SDKUtil.openURL(url)
	--审核状态不允许跳出app
	if AgentConfiger.isAudit() then
		return
	end
	cc.Application:getInstance():openURL(url);
	--gy.GYChannelSDK:getInstance():openURL(url)
end

function SDKUtil.pay(product_id, product_num, product_name, money_num, expandData)
	if not __SDK_LOGIN__ then return end
	print(1, "SDKUtil.pay",product_id, product_num, product_name,money_num,expandData)
	if __CLOSE_PAY__ then
		RollTips.show(Desc.recharge_closePay)
		return
	end
	local params = {}
	params.product_id = product_id
	params.product_num = product_num
	params.product_name = product_name
	params.money_num = money_num
	if expandData then
		params.order_expand = expandData
	end
	
	params.onSuccess = function(result)
		if result then
			local channel = SDKUtil.getChannelId()
			if channel == "" then channel = "1" end
			local infoT = {}
			infoT.productid = tostring(product_id)  --// 商品ID 需要与发行核对档位  需要与发行核对档位  需要与发行核对档位
			infoT.productName = tostring(product_name) --商品名称
			infoT.productDesc = tostring(0)  --商品描述
			infoT.price = tostring(money_num)		--下单金额 单位元
			infoT.gold = tostring(money_num * 10)		--下单金额 单位元
			infoT.goldName = tostring(Desc.recharge_name)   --充值游戏币数量 （新增）
			infoT.goldRate = tostring(10)		--游戏币名称，如：元宝, 钻石 （新增）
			infoT.serverid = tostring(LoginModel:getUnitServerId())		--区服ID
			infoT.serverName = tostring(LoginModel:getServerName())  --区服名称
			infoT.roleid = tostring(ModelManager.PlayerModel.userid)			--角色ID
			infoT.rolename =  tostring(ModelManager.PlayerModel.username)  --角色名称
			infoT.rolelevel = tostring(ModelManager.PlayerModel.level)		--角色等级
			infoT.vipLevel = tostring(ModelManager.VipModel.level)		--VIP等级
			infoT.gamecno = tostring(result.order_id)			--游戏订单号
			infoT.notifyurl = tostring(AgentConfiger.payURL)..AgentConfiger.getRealAgent()		--充值回调地址
			infoT.channel = tostring(channel)			--支付渠道，传 1 即可
			infoT.extradata = tostring(result.order_id)		--透传参数，原样返回

			local jsonStr = json.encode(infoT)
			printTable(1, "SDKUtil.pay", infoT)
			gy.GYChannelSDK:getInstance():purchase(jsonStr, function() end)
		end
	end
	PHPUtil.gyOrder(params)
	
end

--上传付费信息给统计sdk
function SDKUtil.recordPayInfo(payInfo)
	if not payInfo then return end

	if payInfo.rmb > 0 then
		local exData = json.decode(payInfo.ex)
		local orderId, itemName = "", ""
		if type(exData) == "table" then
			if exData.OrderId then
				orderId = exData.OrderId
			end

			if exData.itemCode and exData.itemCode > 0 then
				local itemInfo = ItemConfiger.getInfoByCode(exData.itemCode)
				itemName = itemInfo.name
			end
		end

		local MoneyType = GameDef.MoneyType
		local playerModel = ModelManager.PlayerModel
		local loginModel = LoginModel

		local remainGold = playerModel:getMoneyByType(MoneyType.Emoney)
		local remainGoldBind = playerModel:getMoneyByType(MoneyType.BindEmoney)

		local t = {
			orderId = orderId,
			money = payInfo.rmb,
			rechargeNum = payInfo.rechargeNum,
			itemName = itemName,

			uServerId = tostring(loginModel:getUnitServerId()),
			serverName = tostring(loginModel:getServerName()),
			roleId = playerModel:getPlayerId(),
			userId = loginModel:getUserName(),
			roleLevel = playerModel:getLevel(),
			remainGold = remainGold,
			remainGoldBind = remainGoldBind,
		}
		gy.GYChannelSDK:getInstance():extraAPI(AgentConfiger.SDK_RECORD_PAYMENT, json.encode(t))
	end
end

--上传角色信息到渠道
function SDKUtil.recordRoleInfo(type)
	if not __SDK_LOGIN__ then return end
	local loginModel = LoginModel

	local uServerId = loginModel:getUnitServerId()
	if uServerId == 0 then
		LuaLogE("没有服务器信息")
		return
	end
	local serverName = loginModel:getServerName()
	
	--local roleModel = ModelManager.PlayerModel
	local ip = "0"
	local roleId = ModelManager.PlayerModel.userid
	local roleName = ModelManager.PlayerModel.username
	local roleLevel = ModelManager.PlayerModel.level
	local roleCreateTime = ModelManager.PlayerModel.createMS
	local roleUpdateTime = 0
	local roleOnlineTime = ModelManager.PlayerModel:getTotalOnlineTime()
	local gender = 1
	local profession = 0
	local moneynum = ModelManager.PlayerModel:getMoneyByType(GameDef.MoneyType.Gold)
	local fight = ModelManager.CardLibModel:getFightVal() or 0
	local vipLevel = ModelManager.VipModel.level
	if type == AgentConfiger.SDK_RECORD_CREATE_ROLE then
		roleUpdateTime = roleCreateTime
	end

	local changeJobTimes = 0
	local careerName = "0"-- GameDefConfiger.getCareerName(roleModel:getCareer(), changeJobTimes)
	local MoneyType = GameDef.MoneyType

	local infoT = {}
	infoT.ip = tostring(ip)
	infoT.createServerId = tostring(uServerId)
	infoT.serverId = tostring(uServerId)
	infoT.serverName = tostring(serverName)
	--infoT.userId = tostring(loginModel:getUserName())
	infoT.roleid = tostring(roleId)
	infoT.roleName = tostring(roleName)
	infoT.roleLevel = tostring(roleLevel)
	infoT.roleArea = tostring(0)--角色所在区域
	infoT.roleCareerLevel = tostring(0)--转生等级
	infoT.roleCreateTime = tostring(roleCreateTime)
	local cityId,chapterId,pointId = ModelManager.PushMapModel:getPushMapCurInfo()
	local str = string.format("%d-%d-%d", cityId, chapterId, pointId);
	infoT.rolePass = tostring(str)--角色通过关卡数 默认0（新增）
	infoT.roleOnlineTime =  tostring(roleOnlineTime)--角色历史在线时长，单位秒（新增）
	infoT.vipLevel =  tostring(vipLevel)--VIP等级
	infoT.partyId =  tostring(GuildModel.guildList.id or "0")--所在工会或帮派id
	infoT.partyName =  tostring(GuildModel.guildList.name or "0")--所在工会或帮派名称
	infoT.partyRoleId =  tostring(0)--所在工会或帮派的角色 ID
	infoT.partyRoleName =  tostring(0)--所在工会或帮派的角色名称
	infoT.fightvalue =  tostring(fight)--角色战力
	infoT.moneynum =  tostring(moneynum)--拥有的游戏币
	infoT.gender =  tostring(gender)--性别，男 或 女
	infoT.profession =  tostring(profession)--职业名称
	infoT.professionid =  tostring(profession)--职业名称 ID
	infoT.firstRechargeAmount =  tostring(ModelManager.PlayerModel:getStatByType(GameDef.StatType.FirstRmb) or 0)--角色首次充值金额
	infoT.totalRechargeAmount =  tostring(ModelManager.PlayerModel:getStatByType(GameDef.StatType.ChargeRmb) or 0)--角色累计充值金额
	infoT.remainGold = tostring(ModelManager.PlayerModel:getMoneyByType(GameDef.MoneyType.Diamond))
	infoT.remainGoldBind = tostring(0)
	--infoT.changeJobTimes = tostring(changeJobTimes or 0)
	
	local jsonStr = json.encode(infoT)
	print(1, "resportData", jsonStr)
	gy.GYChannelSDK:getInstance():extraAPI(type, jsonStr)
end

--上传消费信息到君海服务器
function SDKUtil.uploadConsumeInfo(params)
	--[[local loginMode = LoginModel
	local roleModel = ModelManager.PlayerModel

	if not loginMode:getLoginServerInfo() then
		LuaLogE("Server info expected in recordRoleInfo!!")
		return
	end

	local uServerId = loginMode:getUnitServerId()
	local serverName = loginMode:getServerName()
	local roleId = roleModel:getPlayerId()
	local roleName = roleModel:getName()
	local roleLevel = roleModel:getLevel()

	local consumeGold = params.consumeGold or 0
	local consumeGoldBind = params.consumeGoldBind or 0
	local itemName = params.itemName
	local itemCount = params.itemCount or 1
	local itemDesc = params.itemDesc

	local MoneyType = GameDef.MoneyType
	local remainGold = roleModel:getMoneyByType(MoneyType.Emoney)
	local remainGoldBind = roleModel:getMoneyByType(MoneyType.BindEmoney)

	local infoT = {}
	infoT.uServerId = tostring(uServerId)
	infoT.userId = tostring(loginMode:getUserName())
	infoT.roleId = tostring(roleId)
	infoT.roleName = tostring(roleName)
	infoT.remainGold = remainGold
	infoT.remainGoldBind = remainGoldBind
	infoT.consumeGold = consumeGold
	infoT.consumeGoldBind = consumeGoldBind
	infoT.itemName = tostring(itemName)
	infoT.itemCount = itemCount
	infoT.itemDesc = tostring(itemDesc)

	-- dump(1, infoT, "~~~~1111~~~~~~~~")
	gy.GYChannelSDK:getInstance():extraAPI(AgentConfiger.SDK_RECORD_CONSUME, json.encode(infoT))--]]
end


--获取实名信息
function SDKUtil.getRealNameInfo()
	gy.GYChannelSDK:getInstance():extraAPI(AgentConfiger.USER_GET_REALNAMEINFO,"")
end

--获取Ssid
function SDKUtil.getWifiSsid()
	gy.GYChannelSDK:getInstance():extraAPI(AgentConfiger.DEVICE_GET_WIFI_SSID,"")
end

--获取实名信息
function SDKUtil.getChannelId()
	local channelId = gy.GYChannelSDK:getInstance():getGameChannelId()
	if string.find(channelId, "_") == 1 then
		channelId = string.sub(channelId,2,string.len(channelId))
	end
	return channelId
end



--设置当前用户信息
function SDKUtil.setBuglyUserInfo()
	
	local info = {}
	info.loginname = LoginModel:getUserName() .. "_" .. AgentConfiger.getRealAgent()
	info.serverid = LoginModel:getLoginServerInfo().unit_server

	info.userid = PlayerModel.userid
	info.username = PlayerModel.username
	info.level = PlayerModel.level
	info.time = os.date("%Y-%m-%d %H:%M:%S", os.time())
	info.resMd5 = ResUpdateManager.getLocalServerListMD5()
	--LuaLog("setBuglyUserInfo "..json.encode(info))
	gy.GYChannelSDK:getInstance():extraAPI(AgentConfiger.BUGLY_SET_USERINFO,json.encode(info))
end

--设置当前用户界面操作
function SDKUtil.setBuglyUserStep(logstr)
	local info = {}
	info.step = logstr
	--LuaLog("setBuglyUserStep "..logstr)
	gy.GYChannelSDK:getInstance():extraAPI(AgentConfiger.BUGLY_SET_USERSTEP,json.encode(info))
end

--提交报错
function SDKUtil.reportBuglyLuaError(msg,traceback)
	if CC_TARGET_PLATFORM ~= CC_PLATFORM_WIN32 and CC_TARGET_PLATFORM ~= CC_PLATFORM_MAC then
		local info = {}
		info.msg = msg
		info.traceback = traceback
		info.rtype = 6
		--LuaLog("reportBuglyLuaError ")
		gy.GYChannelSDK:getInstance():extraAPI(AgentConfiger.BUGLY_REPORT_ERROR,json.encode(info))
	end
end

--提交报错
function SDKUtil.reportDownLoadError(msg,traceback)
	if CC_TARGET_PLATFORM ~= CC_PLATFORM_WIN32 and CC_TARGET_PLATFORM ~= CC_PLATFORM_MAC then
		local info = {}
		info.msg = msg
		info.traceback = traceback
		info.rtype = 5
		--LuaLog("reportBuglyLuaError ")
		gy.GYChannelSDK:getInstance():extraAPI(AgentConfiger.BUGLY_REPORT_ERROR,json.encode(info))
	end
end

return SDKUtil