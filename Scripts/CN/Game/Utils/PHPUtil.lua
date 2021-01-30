module("PHPUtil", package.seeall)
local  PHPUtil = {}
local FileCacheManager = require "Game.Managers.FileCacheManager"
local LoginModel = require "Game.Modules.Login.LoginModel"
local curReportStep = -1
local reportMap = {}
--记录玩家到达的最大步数
function PHPUtil.reportStep(step)
	--[[if not __IS_RELEASE__ or (CC_TARGET_PLATFORM ~= CC_PLATFORM_IOS and CC_TARGET_PLATFORM ~= CC_PLATFORM_ANDROID) then
		return
	end--]]

	local channelId = SDKUtil.getChannelId()
	if channelId == "" then
		channelId = "-1"
	end

	local deviceId = gy.GYDeviceUtil:getDeviceID()
	if not deviceId or deviceId == "" then
		deviceId = "unknown"
	end	
	--if curReportStep < 0 then
	--	curReportStep = FileCacheManager.getIntForKey(string.format("reportStep_%s_%s", deviceId, channelId), 0, nil, true)
	--end

	--if step <= curReportStep then
	--	return
	--end
	
	if step < 10000 and not reportMap[step] then
		local value = FileCacheManager.getIntForKey(string.format("reportStep_%s_%s_%s", deviceId, channelId,step), 0, nil, true)
		if value == 1 then
			reportMap[step] = 1
			return
		end
	end

	local userName, serverId, roleName = "unknown1", -1, "unknown1"
	local playerId, roleLevel = -1,-1
	if step >= ReportStepType.SDK_LOGIN_SUCCESS then
		userName = LoginModel:getUserName()
	end
	if step >= ReportStepType.GET_RECOMMEND_SERVER then
		serverId = LoginModel:getUnitServerId()
	end
	if step >= ReportStepType.CREATE_ROLE_SUCCESS then
		roleName = ModelManager and ModelManager.PlayerModel and ModelManager.PlayerModel.username
		playerId = ModelManager and ModelManager.PlayerModel and ModelManager.PlayerModel.userid
		roleLevel = ModelManager and ModelManager.PlayerModel and ModelManager.PlayerModel.level
	end

	if not userName or userName == "" then
		userName = "unknown2"
	end
	if not serverId or serverId == "" then
		serverId = -2
	end

	if not roleName or roleName == "" then
		roleName = "unknown2"
	end
	
	if not playerId or playerId == "" then
		playerId = "-1"
	end

	if not roleLevel or roleLevel == "" then
		roleLevel = "-1"
	end

	local function onSuccess(data)
		-- printTable(10,"reportStep onSuccess",data)
		if step < 10000 then
			curReportStep = step
			FileCacheManager.setIntForKey(string.format("reportStep_%s_%s_%s", deviceId, channelId, step), 1, nil, true)
		end
	end

	local function onFailed(data)
		printTable(10,"reportStep onFailed",data)
	end

	HttpUtil.send({
		ip = AgentConfiger.testCenterURL,
		action = HttpActionType.REPORT_STEP,
		key = AgentConfiger.logkey,
		showTips = false,
		immediately = true,
		filterRepeat = false,
		params = {
			appVer=__APP_VERSION__,
			codeVer=__SCRIPT_VERSION__,
			deviceId=deviceId,
			osCode=CC_TARGET_PLATFORM,
			platform = AgentConfiger.getRealAgent(),
			username=userName,
			roleName=roleName,
			playerId=playerId,
			roleLevel=roleLevel,
			deviceId= gy.GYDeviceUtil:getDeviceID(),
			serverId=serverId,
			time=os.time(),
			step=step,
			phoneType = gy.GYDeviceUtil:getDeviceModel()
		},
		onSuccess = onSuccess,
		onFailed = onFailed
	})
end

--上报异常
function PHPUtil.reportBug(errType, errStr)
	if type(errType) ~= "number" or type(errStr) ~= "string" then
		return
	end

	if errType == 1 and __AGENT_CODE__ == "test" then
		return
	end

	local username, rolename = "unknown1", "unknown1"
	local serverId = -1
	if Cache then
		local loginCache = LoginModel
		if loginCache then
			username = loginCache:getUserName()		
			serverId = loginCache:getUnitServerId()
		end
		-- local roleCache = Cache.roleCache
		-- if roleCache then
			-- rolename = roleCache:getName()
		-- end

		if not username or username=="" then username = "unknown2" end
		if not rolename or rolename=="" then rolename = "unknown2" end
		if not serverId or serverId==0 then serverId = -2 end
	end

	local function onSuccess(data)
		printTable(15,"reportBug onSuccess",data)
	end

	local function onFailed(data)
		printTable(15,"reportBug onFailed",data)
	end

	HttpUtil.send({
		ip = AgentConfiger.testCenterURL,
		action = HttpActionType.REPORT_BUG,
		key = AgentConfiger.logkey,
		showTips = false,
		filterRepeat = false,
		params = {
			bugType = errType,
			appVersion = __APP_VERSION__,
			codeVer = __SCRIPT_VERSION__,
			osCode = CC_TARGET_PLATFORM,
			platform = AgentConfiger.getRealAgent(),
			username = username,
			rolename = rolename,
			reportBug = errStr,
			serverId = serverId,
			level = ModelManager and ModelManager.PlayerModel and ModelManager.PlayerModel.level or -1,
			time = os.time(),
		},
		onSuccess = onSuccess,
		onFailed = onFailed
	})
	
	--new 
	--[[HttpUtil.send({
		ip = AgentConfiger.testCenterURL,
		action = "error_log",
		key = AgentConfiger.logkey,
		showTips = false,
		filterRepeat = false,
		params = {
			func_id = 100,--错误码ID  100  加载资源异常  200  系统不兼容
			error_log = ,--错误信息
			data_ver= ,--协议版本
			game_id = ,--游戏ID
			game_ver = ,--游戏版本
			game_channel_id = ,--渠道包ID
			time_zone = ,--时区
			package_name = ,--游戏包名
			device_name = ,--设备名称
			os_type = ,--系统类型
			net_type = ,--网络类型
			os_ver = ,--系统版本
			device_uuid = ,--客户端生成的设备唯一标识
			imei_or_idfa = ,--Android 的Android_imei  或者IOS的IDFA
			screen_width = ,--屏幕宽
			screen_height = ,--屏幕高
			cpu_amount = ,--CPU核数
			cpu_model = ,--CPU型号
			ram_size = ,--RAM大小
			rom_size = ,--ROM大小



















			bugType = errType,
			appVersion = __APP_VERSION__,
			codeVer = __SCRIPT_VERSION__,
			osCode = CC_TARGET_PLATFORM,
			platform = AgentConfiger.getRealAgent(),
			username = username,
			rolename = rolename,
			reportBug = errStr,
			serverId = serverId,
			level = ModelManager and ModelManager.PlayerModel.level or -1,
			time = os.time(),
		},
		onSuccess = onSuccess,
		onFailed = onFailed
	})--]]
end

--获取推荐服
function PHPUtil.getRecommendServer(params, notUpdate)
	LuaLogE("getRecommendServer")
	params = params or {}
	
	local function onSuccess(data)
		LuaLogE("getRecommendServer success..   "..json.encode(data))
		print(1,"getRecommendServer success",json.encode(data))
		--dump(92, data, " 更新推荐服 data")
		LoginModel:updateRecommendServer(data, notUpdate)
		PHPUtil.reportStep(ReportStepType.GET_RECOMMEND_SERVER)
		if type(params.onSuccess) == "function" then
			params.onSuccess(data)
		end
	end

	local function onFailed(data)
		print(33,"getRecommendServer fail")
		if type(params.onFailed) == "function" then
			params.onFailed(data)
		end
	end
	print(0,"getRecommendServer start")
	local mappingMD5 = LoginModel:getMappingMD5()
	local username = LoginModel:getUserName()
	if params.forceGetMappingList then
		mappingMD5 = ""
	end
	if params.username then
		username = params.username
	end

	local httpParams = {
		appVersion=__APP_VERSION__,
		time=os.time(),

		platform=AgentConfiger.getRealAgent(),
		username=username,
		mappingMD5=mappingMD5,
	}

	HttpUtil.send{
		action=HttpActionType.GET_RECOMMEND_SERVER,
		ip=AgentConfiger.centerURL,
		key=AgentConfiger.logkey,
		immediately = true,
		params=httpParams,
		onSuccess=onSuccess,
		onFailed=onFailed,
	}
end

local getServerListTime = 0 --太快调用多次会飘失败
--获取所有服务器列表
function PHPUtil.getServerList(params)
	LuaLogE("get serverList start")
	if os.time() - getServerListTime <= 1 then
		return
	end
	getServerListTime = os.time()
	params = params or {}
	-- dump(92,params,"返回服务器列表")
	local function onSuccess(data)
		-- dump(10,data,"返回服务器列表")
		print(69,"get serverList success",json.encode(data))
		--printTable(33,data)
		PHPUtil.reportStep(ReportStepType.GET_SERVER_LIST)
		LoginModel:updateServerList(data)
		if type(params.onSuccess) == "function" then
			params.onSuccess(data)
		end
	end

	local function onFailed(data)
		print(69,"getServerList fail")
		-- dump(data, "getServerList failed:")
		if type(params.onFailed) == "function" then
			params.onFailed(data)
		end
	end

	local serverListVer = LoginModel:getServerVersion() or 1
	local mappingMD5 = LoginModel:getMappingMD5()

	local username = LoginModel:getUserName()
	if params.forceGetServerList then
		serverListVer = 1
	end
	if params.forceGetMappingList then
		mappingMD5 = ""
	end
	if params.username then
		username = params.username
	end


	if __AUTO_TEST__ then
		if not params.username or params.username == "" then
			username = "1"
		end	
	end
	
	if username == "" then
		username = "aa"
	end
	
	local httpParams = {
		appVersion=__APP_VERSION__,
		time=getServerListTime,
		getType=2,
		platform=AgentConfiger.getRealAgent(),
		serverVersion=serverListVer,
		mappingMD5=mappingMD5,
		username=username,
		--isDebug = "1",
	}
	local ip = AgentConfiger.centerURL
	if GlobalUtil.isPCDownload() then
		ip = "http://api-g1-test.guangyv.com/v1/client/"
	end
	HttpUtil.send{
		action=HttpActionType.GET_SERVER,
		ip=ip,
		key=AgentConfiger.logkey,
		immediately = true,
		params=httpParams,
		retryTimes=3,
		onSuccess=onSuccess,
		onFailed=onFailed,
	}
	print(0,"get serverList start")

end


function PHPUtil.getNotice(params,status)
	params  = params or {}
	local sendParams = {
		appVersion = params.isAppVersion and __APP_VERSION__ or __SCRIPT_VERSION__,
		platform = AgentConfiger.getRealAgent(),
		unit_server = LoginModel:getUnitServerId(),
		time = os.time(),
	}

	local function onSuccess(data)
		if type(params.onSuccess) == "function" then
			params.onSuccess(data)
		end
	end

	local function onFailed(data)
		if type(params.onFailed) == "function" then
			params.onFailed(data)
		end
	end

	HttpUtil.send({
		ip = AgentConfiger.centerURL,
		action = HttpActionType.GAME_NOTICE,
		key = AgentConfiger.logkey,
		immediately = true,
		params = sendParams,
		onSuccess = onSuccess,
		onFailed = onFailed,
	})
end

function PHPUtil.gyOrder(params)
	local deviceId = gy.GYDeviceUtil:getDeviceID()
	if not deviceId or deviceId == "" then
		deviceId = "unknown"
	end
	
	local phoneType = gy.GYDeviceUtil:getDeviceModel()
	if phoneType == "" then
		phoneType = "pc_not_implement"
	end
	
	local resolution = gy.GYDeviceUtil:getScreenResolution()
	local screenWidth="-1"
	local screenHeight="-1"
	if resolution~= "" then
		local resolutionParam = string.split(resolution, "*")
		screenWidth = resolutionParam[1] or "-1"
		screenHeight = resolutionParam[2] or "-1"
	end
	
	local osVersion = gy.GYDeviceUtil:getDeviceVersion()
	if osVersion == "" then
		osVersion = "Unknown"
	end
	
	local networkType = gy.GYDeviceStatusListener:getInstance():getNetStatus()
	if networkType == gy.NETWORK_STATUS_WIFI then
		networkType = "wifi"

	elseif networkType == gy.NETWORK_STATUS_MOBILE then
		networkType = "Mobile"

	else
		networkType = "Unknown"
	end
	
	
	local packageName = gy.GYPlatform:getBundleID()
	if packageName == "" then
		packageName = "Unknown"
	end
	
	
	params  = params or {}
	local sendParams = {
		appVersion = params.isAppVersion and __APP_VERSION__ or __SCRIPT_VERSION__,
		platform = AgentConfiger.getRealAgent(),-- 平台
		money_num = params.money_num, --: 金额
		product_num = params.product_num or 1, --: 产品数量
		product_name = params.product_name,--: 产品名称
		player_id = ModelManager.PlayerModel and ModelManager.PlayerModel.userid, --: 玩家ID
		money_type = 1,   --   : 金额类型(1：人民币;2：港币;3：美元;4：越南盾;5：台币]
		unit_server_id =  LoginModel:getUnitServerId(),--: 统一服ID
		username = LoginModel:getUserName(),--: 用户名
		identity= deviceId, --:设备ID
		phone_type = phoneType,--:手机型号
		phone_system = CC_TARGET_PLATFORM,--:手机系统
		gold_tag_ver = 1,--：充值档位版本
		app_ver = __APP_VERSION__,--：包版本
		career = 1, --职业
		game_ver = __ENGINE_VERSION__, --：游戏版本
		net_type = networkType, --：网络类型
		package_name = packageName,--：包名
		player_level = ModelManager.PlayerModel and ModelManager.PlayerModel.level, --：玩家等级
		screen_height = screenHeight, --：屏幕高
		screen_width = screenWidth,--：屏幕高
		vip_level = ModelManager.PlayerModel and (ModelManager.VipModel.level + 1),--：vip等级
		os_ver =  osVersion,--: 系统版本
		order_expand = params.order_expand, --：客户端透传参数（没有不传）
		product_id =  params.product_id,--：商品id（php将存放到js_str字段里面去读取）
		
		time = os.time(),
	}

	local function onSuccess(data)
		if type(params.onSuccess) == "function" then
			params.onSuccess(data)
		end
	end

	local function onFailed(data)
		if type(params.onFailed) == "function" then
			params.onFailed(data)
		end
	end

	HttpUtil.send({
		ip = AgentConfiger.orderURL,
		action = HttpActionType.GET_ORDER_ID,
		key = AgentConfiger.logkey,
		immediately = true,
		params = sendParams,
		onSuccess = onSuccess,
		onFailed = onFailed,
	})
end

function PHPUtil.updatePlayerWidthRoleData(params)
	params = params or {}
	local roleData = params.roleData	
	local function onSuccess(data)
		if type(params.onSuccess) == "function" then
			params.onSuccess(data)
		end
	end

	local function onFailed(data)
		if type(params.onFailed) == "function" then
			params.onFailed(data)
		end
	end


	
	local sendParams = {
		platform = AgentConfiger.getRealAgent(),
		username = LoginModel:getUserName(),
		name = roleData.name,
		osCode = CC_TARGET_PLATFORM,
		playerId = roleData.userid,
		level = roleData.level,
		unitServerId = LoginModel:getUnitServerId(),
		isDel = params.isDel,			
		identity = gy.GYDeviceUtil:getIDFA(),
		mac = gy.GYDeviceUtil:getDeviceID(),
		time = os.time(),
		serverId = LoginModel:getServerId(),
		sex = 1,
		career = 1,
		photo = PlayerModel.head,
		changeJobTimes = 1,
		isMain = 1,
		--以下为无效字段，需要保留
		camp = 1,
	}

	HttpUtil.send({
		action=HttpActionType.UPDATE_PLAYER,
		ip=AgentConfiger.centerURL,
		key=AgentConfiger.logkey,
		params = sendParams,
		onSuccess = onSuccess,
		onFailed = onFailed,
	})	

end

--[[更新玩家数据]]
function PHPUtil.updatePlayer(params)

	params = params or {}
	
	local function onSuccess(data)
		if type(params.onSuccess) == "function" then
			params.onSuccess(data)
		end
		--Alert.show("success")
	end

	local function onFailed(data)
		if type(params.onFailed) == "function" then
			params.onFailed(data)
		end
	end


	local sendParams = {
		oldCareer = 0,
		osCode = CC_TARGET_PLATFORM,
		platform = AgentConfiger.getRealAgent(),
		identity = gy.GYDeviceUtil:getIDFA(),
		mac = gy.GYDeviceUtil:getDeviceID(),
		time = os.time(),

		username = LoginModel:getUserName(),
		serverId = LoginModel:getServerId(),
		unitServerId = LoginModel:getUnitServerId(),
		changeJobTimes = 0,
		playerId = PlayerModel.userid,
		name = PlayerModel.username,
		sex = PlayerModel.sex,

		career = 0,
		level = PlayerModel.level,
		photo = PlayerModel.head,

		isMain = 1,
		--以下为无效字段，需要保留
		camp = 1,
	}

	-- dump(1, sendParams, "~~~~~~httpUpdatePlayer~~~~~")
	HttpUtil.send({
		action=HttpActionType.UPDATE_PLAYER,
		ip=AgentConfiger.centerURL,
		key=AgentConfiger.logkey,
		params = sendParams,
		onSuccess = onSuccess,
		onFailed = onFailed,
	})
end

--获取充值档位
function PHPUtil.getRechargeInfo(params)
	local finalParam = {
		appVersion=__APP_VERSION__,
		osCode = CC_TARGET_PLATFORM,
		platform=AgentConfiger.getRealAgent(),
		time=os.time(),
		username=LoginModel:getUserName()
	}

	HttpUtil.send({
	    ip = AgentConfiger.centerURL,
	    action = HttpActionType.GET_GOLD_TAG,
	    key = AgentConfiger.logkey,
	    params = finalParam,
	    onSuccess = params.onSuccess,
	    onFailed = params.onFailed
	})	
end

--提交问题
function PHPUtil.commitProblem(params)
	local finalParam = {
		qq = params.qq,
		phone = params.phone,
		title = params.title,
		content = params.content,

		platform=AgentConfiger.getRealAgent(),
		playerId = PlayerModel.userid or "",
		playerName = PlayerModel.username or "",
		unitServer = LoginModel:getUnitServerId(),
		username = LoginModel:getUserName(),
		time = os.time(),
	}
	printTable(19,"打印的UI参数",params.path,finalParam.phone,finalParam.title,finalParam.content,finalParam.username)
	local function onFinish(dict)
		-- printTable(10,"提交图片回调",dict)
		if dict.status == 200 then
			local jsContent = json.decode(dict.data)
			if jsContent and tonumber(jsContent.code)==1000 then
				RollTips.show(Desc.php_commitFinish)	
			end 	
		end
	end

	-- print(10,"图片路径",tostring(params.path))
	if type(params.path) == "string" and cc.FileUtils:getInstance():isFileExist(params.path) then
	print(19,"提交图片",params.path)
		local url = HttpUtil.getFormatedURLData(finalParam,AgentConfiger.logkey)
		url = string.format("%s%s?%s", AgentConfiger.centerURL, HttpActionType.FEED_BACK, url)
		HttpUtil.sendPostFile({
			url = url,
		    onFinish = onFinish,
		    fileFullPath = params.path
		})	
	else
		HttpUtil.send({
			ip = AgentConfiger.centerURL,
		    action = HttpActionType.FEED_BACK,
		    key = AgentConfiger.logkey,
		    params = finalParam,
		    isGet = true,
		    onSuccess = params.onSuccess,
		    onFailed = params.onFailed
		})
	end
end

--获取问题
function PHPUtil.getProblems(params)
	local finalParam = {
		playerId = PlayerModel.userid or "",
		username = LoginModel:getUserName(),
		time = os.time(),
	}

	HttpUtil.send({
		ip = AgentConfiger.centerURL,
	    action = HttpActionType.FEED_BACK_MY,
	    key = AgentConfiger.logkey,
	    params = finalParam,
	    isGet = true,
	    onSuccess = params.onSuccess,
	    onFailed = params.onFailed
	})
end

--更新客服系统阅读标记
function PHPUtil.upReadProblemsTag(params)
	local finalParam = {
		id=params.id,
		playerId = PlayerModel.userid or "",
		unitServer = LoginModel:getUnitServerId(),
		identity = gy.GYDeviceUtil:getIDFA(),
		time = os.time(),
	}

	HttpUtil.send({
		ip = AgentConfiger.centerURL,
	    action = HttpActionType.FEED_BACK_UPDATE,
	    key = AgentConfiger.logkey,
	    params = finalParam,
	    isGet = true,
	    onSuccess = params.onSuccess,
	    onFailed = params.onFailed
	})
end


--实名认证
function PHPUtil.getCertificationState(params)
	local loginCache = LoginModel
	local args = {
		identity = params.identity,
		name = params.name,
		area_code= "CN",
		osCode= CC_TARGET_PLATFORM,
		platform = AgentConfiger.getRealAgent(),
		player_id = Cache.roleCache:getPlayerId(),
		project = "jz2",
		time=os.time(),
		type = 3,
		unit_server = loginCache:getUnitServerId(),
		username = loginCache:getUserName() .. "_" .. AgentConfiger.getRealAgent(),
		game_channel_id = SDKUtil.getChannelId(),
		user_id = loginCache:getUserName(),
	}


	-- dump(92, args)
	HttpUtil.send({
		action = HttpActionType.IDENTITY_CARD,
		ip = AgentConfiger.centerURL,
		key = AgentConfiger.logkey,
		params = args,
		showTips = params.showTips,
		onSuccess = params.onSuccess,
		onFailed = params.onFailed,
	})
end


--[[ 
激活码查看&领取

params
	platform:平台代号
    osCode：载体
    username： 用户名
    project:项目代号
    type:（show：查看,get:领取）
    playerId:玩家ID
    code:激活码
    unitServer：唯一区服ID,（注意：领取一定要多传一个codeId,这个codeId会在查询的时候返回）
]]
function PHPUtil.handleActivationCode(type,code,onSuccess,onFailed)
	HttpUtil.send({
		action = HttpActionType.ACTIVATION,
		ip = AgentConfiger.centerURL,
		key = AgentConfiger.logkey,
		params = {
			osCode= CC_TARGET_PLATFORM,
			platform = AgentConfiger.getRealAgent(),
			project = "g1",
			time=os.time(),

			username = LoginModel:getUserName(),
			unitServer = LoginModel:getUnitServerId(),
			playerId = PlayerModel.userid,
			type = type,
			code = code
		},
		onSuccess = onSuccess,
		onFailed = onFailed, 
	})
end


--[[ 
首次设备激活

params
	platform：平台代号，客户端打包时的平台代号【必要】
    channelId：渠道ID
    appVer：包版本
    gameVer：游戏版本
    packageName：包名称
    osCode：载体
    osVer：系统版本
    netType：网络类型（2G,3G,4G,5G,6G,wifi）
    deviceName：设备名称
    deviceId：设备ID
    screenWidth：屏幕宽
    screenHeight：屏幕高
]]
function PHPUtil.deviceActivition(onSuccess,onFailed)
	printTable(1, "first_active")
	local channelId = SDKUtil.getChannelId()
	if channelId == "" then
		channelId = "-1"
	end

	local deviceId = gy.GYDeviceUtil:getDeviceID()
	if not deviceId or deviceId == "" then
		deviceId = "unknown"
	end	
	
	local value = FileCacheManager.getIntForKey(string.format("deviceActivition_%s_%s", deviceId, channelId), 0, nil, true)
	if value == 1 then
		return
	end
		
	local deviceId = gy.GYDeviceUtil:getDeviceID()
	if not deviceId or deviceId == "" then
		deviceId = "unknown"
	end	

	local deviceVer = gy.GYDeviceUtil:getDeviceVersion()
	if not deviceVer or deviceVer == "" then
		deviceVer = "unknown"
	end	
	
	local networkType = gy.GYDeviceStatusListener:getInstance():getNetStatus()
	if networkType == gy.NETWORK_STATUS_WIFI then
		networkType = "wifi"

	elseif networkType == gy.NETWORK_STATUS_MOBILE then
		networkType = "Mobile"

	else
		networkType = "Unknown"
	end
	
	local resolution = gy.GYDeviceUtil:getScreenResolution()
	local screenWidth="-1"
	local screenHeight="-1"
	if resolution~= "" then
		local resolutionParam = string.split(resolution, "*")
		screenWidth = resolutionParam[1] or "-1"
		screenHeight = resolutionParam[2] or "-1"
	end
	
	local phoneType = gy.GYDeviceUtil:getDeviceModel()
	if phoneType == "" then
		phoneType = "pc_not_implement"
	end

	local packageName = gy.GYPlatform:getBundleID()
	if packageName == "" then
		packageName = "Unknown"
	end
	
	HttpUtil.send({
		action = HttpActionType.DEVICE_ACTIVATION,
		ip = AgentConfiger.centerURL,
		key = AgentConfiger.logkey,
		params = {
			osCode= CC_TARGET_PLATFORM,
			platform = AgentConfiger.getRealAgent(),
			channelId = SDKUtil.getChannelId(),
			appVer=__APP_VERSION__,
			codeVer=__SCRIPT_VERSION__,
			osCode= CC_TARGET_PLATFORM,
			gameVer = __ENGINE_VERSION__,
			packageName = packageName,
		
			osVer = deviceVer,
			netType=networkType,
			deviceName=phoneType,
			deviceId=deviceId,
			screenWidth = screenWidth,
			screenHeight = screenHeight,
			
			
			--project = "g1",
			time=os.time(),

			--username = LoginModel:getUserName(),
			--unitServer = LoginModel:getUnitServerId(),
			--playerId = PlayerModel.userid,
			--type = type,
			--code = code
		},
		onSuccess = function()
			print(1, "deviceActivition_success")
			FileCacheManager.setIntForKey(string.format("deviceActivition_%s_%s", deviceId, channelId), 1, nil, true)
		end,
		--onFailed = onFailed, 
		onFailed = function(arg)
			printTable(69, "deviceActivition failed", arg)
		end,
	})
	
	
	--new-----
	local params = {
			game_code = RPUtil.getGameId(),--游戏ID
			game_version = RPUtil.getGameVer(),--游戏服务端版本
			platfrom= RPUtil.getPlatform(),--渠道代号
			channel_id = RPUtil.getChannelId(),--渠道ID
			package_name= RPUtil.getPackageName(),--游戏包名
			client_time_zone= RPUtil.getTimeZone(),--游戏包名
			device_name =RPUtil.getDeviceModel(),--设备名称
			os_code = RPUtil.getOsCode(),--系统类型
			net_type = RPUtil.getNetType(),--网络类型
			os_version = RPUtil.getOsVer(),--系统版本
			device_id = RPUtil.getDeviceId(),--客户端生成的设备唯一标识
			imei_or_idfa = RPUtil.getImeiOrIdfa(),--Android 的Android_imei  或者IOS的IDFA
			screen_width = RPUtil.getSreenWidth(),--屏幕宽
			screen_height = RPUtil.getSscreenHeight(),--屏幕高
			cpu_amount = RPUtil.getCpuNum(),--CPU核数
			cpu_model = RPUtil.getCpuModel(),--CPU型号
			ram_size = RPUtil.getRamSize(),--RAM大小单位KB
			rom_size = RPUtil.getRomSize(),--ROM大小单位KB
			time=os.time(),
		}
	printTable(1, "first_active", params)
		
	HttpUtil.send({
		action = "first_active",
		ip = "http://cp-log-api-itn.guangyv.com:8888/",
		key = AgentConfiger.logkey,
		params = {
			isNew = true,  --是否新接口
			game_code = RPUtil.getGameId(),--游戏ID
			game_version = RPUtil.getGameVer(),--游戏服务端版本
			platfrom= RPUtil.getPlatform(),--渠道代号
			channel_id = RPUtil.getChannelId(),--渠道ID
			package_name= RPUtil.getPackageName(),--游戏包名
			client_time_zone= RPUtil.getTimeZone(),--游戏包名
			device_name =RPUtil.getDeviceModel(),--设备名称
			os_code = RPUtil.getOsCode(),--系统类型
			net_type = RPUtil.getNetType(),--网络类型
			os_version = RPUtil.getOsVer(),--系统版本
			device_id = RPUtil.getDeviceId(),--客户端生成的设备唯一标识
			imei_or_idfa = RPUtil.getImeiOrIdfa(),--Android 的Android_imei  或者IOS的IDFA
			screen_width = RPUtil.getSreenWidth(),--屏幕宽
			screen_height = RPUtil.getSscreenHeight(),--屏幕高
			cpu_amount = RPUtil.getCpuNum(),--CPU核数
			cpu_model = RPUtil.getCpuModel(),--CPU型号
			ram_size = RPUtil.getRamSize(),--RAM大小单位KB
			rom_size = RPUtil.getRomSize(),--ROM大小单位KB
			time=os.time(),
		},
		onSuccess = function()
			print(1, "deviceActivition_success")
			--FileCacheManager.setIntForKey(string.format("deviceActivition_%s_%s", deviceId, channelId), 1, nil, true)
		end,
		--onFailed = onFailed
		onFailed = function(arg)
			printTable(69, "deviceActivition failed", arg)
		end
	})
end

--获取版本
function PHPUtil.getVersion(onSuccess, onFailed)
	local channelId = SDKUtil.getChannelId()
	local httpParams = {
		appVer=__APP_VERSION__,
		codeVer=__SCRIPT_VERSION__,
		experience = __IS_EXPERIENCE__ and 1 or 0,
		osCode= CC_TARGET_PLATFORM,
		platform=__AGENT_CODE__,
		channelId=channelId,
		endMicro = 1,
		serverVer=1,
		time=os.time(),
	}

	--为了版署测试搞的，后面要删掉
	if __AGENT_CODE__ == "g1banshu" then
	--	httpParams.isDebug = true
	end

	--电脑上测试资源下载
	if GlobalUtil.isPCDownload() then
		httpParams.osCode = CC_PLATFORM_ANDROID
		httpParams.platform = "junhai"
	end

	LuaLogE(string.format("start get_version! channelId: %s", channelId))
	HttpUtil.send({
		action=HttpActionType.GET_VERSION,
		service = "v1.Client.GetVersion",
		ip=AgentConfiger.centerURL,
		key=AgentConfiger.logkey,
		params=httpParams,
		retryTimes=3,
		retryDelay=1,
		immediately = true,
		onSuccess=onSuccess,
		onFailed=onFailed,		
	})
end

--获取版本
function PHPUtil.gyLogin(data, onSuccess, onFailed)
	local channelId = SDKUtil.getChannelId()
	local httpParams = {
		--appVer=__APP_VERSION__,
		--codeVer=__SCRIPT_VERSION__,
		--osCode= CC_TARGET_PLATFORM,
		platform=AgentConfiger.getRealAgent(),
		channel_id=channelId,
		game_id=gy.GYChannelSDK:getInstance():getGameId(),
		time=os.time(),
	}
	for k,v in pairs(data) do
		httpParams[k] = v
	end

	--为了版署测试搞的，后面要删掉
	--if __AGENT_CODE__ == "g1banshu" then
	--	httpParams.isDebug = true
	--end

	--LuaLogE(string.format("start gyLogin! uid: %s", uid))
	HttpUtil.send({
		action=HttpActionType.GYLOGIN,
		service = "v1.Login.gyLogin",
		ip=AgentConfiger.loginURL,
		key=AgentConfiger.logkey,
		params=httpParams,
		retryTimes=3,
		retryDelay=1,
		immediately = true,
		onSuccess=onSuccess,
		onFailed=onFailed,		
	})
end


--聊天上报
--toPlayerId 不是私聊可以发0
--toRoleName 不是私聊可以发“”
--chatTime  
--msgStr
--chatType 1系统 2世界 4公会 8私聊 16同城 32组队 64跨服
--chatTypeName 系统 世界 公会 私聊 同城 组队 跨服
function PHPUtil.reportChat(toPlayerId, toRoleName, chatTime,msgStr,chatType,chatTypeName)
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
	
	local chatObject = {mUid = toPlayerId, roleid = toPlayerId, roleName = toRoleName}
	local channelId = SDKUtil.getChannelId()
	local httpParams = {
		gameCode = "g1",
		channelId = SDKUtil.getChannelId() ~= "" and SDKUtil.getChannelId() or "297",
		mUid = LoginModel:getUserName(),
		serverId = LoginModel:getUnitServerId(),
		serverName =LoginModel:getServerName(),-- 	是	区服名称
		roleid = tostring(roleId), --	是	玩家角色id
		roleName = roleName,	--是	角色名称
		roleLevel = tostring(roleLevel),--	string	是	角色等级
		roleArea = LoginModel:getServerId(), --	string	否	角色所在区域
		roleCareerLevel = 0,--	string	是	角色转生等级
		roleCreateTime = tostring(roleCreateTime), --	string	是	角色创建时间戳
		vipLevel = tostring(vipLevel),	--string	是	VIP等级
		partyName = tostring(GuildModel.guildList.name or "0"), --	string	否	所在工会或帮派名称
		partyId	 = tostring(GuildModel.guildList.id or "0"), --string	否	所在工会或帮派名称 ID
		partyRoleId	 = tostring(0), --string	否	所在工会或帮派的角色 ID
		partyRoleName =	tostring(0), --string	否	所在工会或帮派的角色名称
		fightvalue = tostring(ModelManager.CardLibModel:getFightVal() or 0),--角色战力
		moneynum = tostring(ModelManager.PlayerModel:getMoneyByType(GameDef.MoneyType.Gold)),--拥有的游戏币
		gender = tostring(gender),--性别，男 或 女
		profession =  tostring(profession),--职业名称
		professionid =  tostring(profession),--职业名称 ID
		friendlist= "1",
		ipAddress = "127.0.0.1",
		chatTime = chatTime,--	string	是	聊天记录时间戳
		chatObject  = chatObject,--	string	是	聊天对象信息，详情看chatObject
		chatInfo = msgStr,--	string	是	聊天记录
		chatType = chatType, --string	是	聊天记录类型（1系统 2世界 4公会 8私聊 16同城 32组队 64跨服）
		chatTypeName  = chatTypeName, --	string	是	聊天频道名称
		sign = ""--	string	是	签名
	}

	--为了版署测试搞的，后面要删掉
	--if __AGENT_CODE__ == "g1banshu" then
	--	httpParams.isDebug = true
	--end
	local url = "https://api3.ysjgames.com/pay/serverApi/chatUpload"
	--local url = "https://www.baidu.com/"
	local onResult = function(para)
		printTable(69,para)
	end
	
	local onFailed= function(para)
		printTable(69,para)
	end
	HttpUtil.sendToPlatform(url, httpParams, onResult, onFailed)
end

--在游戏里显示一个网页
function PHPUtil.showWebPage(parent, url, width, height, posX, posY)
	if not (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID or CC_TARGET_PLATFORM == CC_PLATFORM_IOS) then
		--仅安卓或者ios支持
		return
	end
	local web = ccexp.WebView:create()
	web:loadURL(url)
	web:setPosition(cc.p(posX + width/2, posY + height/2));
	web:setContentSize(cc.size(width,height));
	web:setScalesPageToFit(true)
	parent:displayObject():addChild(web)
--[[
	web:setOnShouldStartLoading(function(obj,url)

	end)
	web:setOnDidFinishLoading(function(obj,url)

	end)
	web:setOnDidFailLoading(function(obj,url)

    end)--]]
	return web
end


--获取公用资源（登陆背景，logo等）
function PHPUtil.getPublicRes(params)
	params = params or {}
	
	local function onSuccess(data)
		--LuaLogE("getPublicRes success"..json.encode(data))
		if type(params.onSuccess) == "function" then
			params.onSuccess(data)
		end
	end

	local function onFailed(data)
		--LuaLogE("getPublicRes failed")
		if type(params.onFailed) == "function" then
			params.onFailed(data)
		end
	end
	
	local scriptHandler = function(dict)
		printTable(69, "返回结果", dict)
		if dict.code ~= 200 then
			onFailed({code = dict.code, reason = dict.dlMsg, status=dict.dlStatus})
			return
		end
		print(69, dict.data)
		onSuccess(dict.data)
	end
	if __RES_URL__ and __RES_URL__ ~= "" then
		--LuaLogE("getPublicRes "..__RES_URL__.."publicRes/../../../publicRes/resList.json?"..math.random()  )
		gy.GYHttpClient:send(__RES_URL__.."../../publicRes/resList.json?"..math.random(), "", scriptHandler, true, false, true, 15, 15)
	end
end

--获取客服信息
function PHPUtil.gsMember(onSuccess, onFailed)
	local httpParams = {
		platform=AgentConfiger.getRealAgent(),
		unitServer=LoginModel:getUnitServerId(),
		playerId=ModelManager and ModelManager.PlayerModel and ModelManager.PlayerModel.userid,
		time=os.time(),
	}

	HttpUtil.send({
		action=HttpActionType.GS_MEMBER,
		service = "v1.Client.gsMember",
		ip=AgentConfiger.centerURL,
		key=AgentConfiger.logkey,
		params=httpParams,
		retryTimes=3,
		retryDelay=1,
		immediately = true,
		onSuccess=onSuccess,
		onFailed=onFailed,		
	})
end

return PHPUtil

