--创建用于tileList的角色信息
local function newRoleInfoItem(roleInfo)
	return {
		career = tonumber(roleInfo.career),
		level = tonumber(roleInfo.level),
		name = roleInfo.name,
		serverId = roleInfo.server_id,
		playerId = roleInfo.player_id,
		photo = tonumber(roleInfo.photo),
		sex = tonumber(roleInfo.sex),
		changeJobTimes = tonumber(roleInfo.change_job_times),
	}
end

----------------- 外网下服务器列表没改动php就返回空，因此需要把服务器列表保存在本地...  -----------------
local LoginModel = {}
function LoginModel:init()
	--登录用户信息
	self.__loginAccount = {
		username = __DEFAULT_USERNAME__,
		password = __DEFAULT_PASSWORD__,
		token = ""
	}

	---------- php给下来的原始数据 ----------
	self.__mappingMD5 = "1"

	--服务器列表
	self.__serverList = {}
	self.__serverVersion = false

	--推荐服信息
	self.__recommendServerInfo = false



	--服务器id差值，用于与老渠道混服的新渠道将如100服显示成1服
	self.__serverIdInterval = 0

	-- 一个区间的服务器数量
	self.__groupServerNum = 0

	--选中的服务器
	self.__chosenServerInfo = false

	--维护公告tip
	self.__maintenanceNotice = false
	--其他公告
	self.__noticeData = false

	--是否正在获取推荐服
	self.__isGettingRecommendServer= false

	--当前账号所有服务器上的角色信息
	self.__allRoleInfo = {}


	self.__unitServerToState = {}  --唯一服到状态的映射

	--用于服务器列表界面的数据结构
	self.__dealServerList = {
		roleList = {},
		serverGroups = {}
	}
	self.__newServerList = {}  --新服


	self.__isRelink = false  --是否重连

	self.__tryLoginTimes = 0  --尝试无缝重登次数

	self.__serverInfo = false  --服务器信息
	
	self.__lastLoginServerInfo = false  --服务器信息
	
	self.needRelogin = false --是否登陆失败了
	self.hadEnterGame = false --是否已经进游戏了
	
	
	
	--self.hasLogin = false --是否已经登陆了
	
	self:_initListeners();
	
end



function LoginModel:_initListeners()

end

function LoginModel:isTestAgent()
	if __AGENT_CODE__ == "test" or __AGENT_CODE__ == "jinshanyunshenhe" or __AGENT_CODE__ == "optimiz" or
	 __AGENT_CODE__ == "gy_test" or __AGENT_CODE__ == "g1pingce1" or __AGENT_CODE__ == "g19377sucai" or __AGENT_CODE__ == "g1yinghepingce" then
		return true
	end
	return false
end

function LoginModel:getLastLoginServerInfo()
	return self.__chosenServerInfo
end


--玩家账号
function LoginModel:getUserName()
	return self.__loginAccount.username
end

function LoginModel:setUserName(value)
	if value == nil then value = "" end
	self.__loginAccount.username = value
	--self.__loginAccount.token = token
end

--登陆token
function LoginModel:getToken()
	return self.__loginAccount.token
end

function LoginModel:setToken(token)
if token == nil then token = "" end
self.__loginAccount.token = token
end

function LoginModel:setSessionTime(session_time)
	self.__loginAccount.session_time = session_time or ""
end

--session_time
function LoginModel:getSessionTime()
	return self.__loginAccount.session_time or ""
end



--密码
function LoginModel:getPassword(pwd)
	return self.__loginAccount.password
end

function LoginModel:setPassword(pwd)
	if pwd == nil then pwd = "" end
	self.__loginAccount.password = pwd
end

--获取登录服ip
function LoginModel:getLoginIp()
	if __LOGIN_IP__ ~= "" then
		return __LOGIN_IP__
	end

	local serverInfo = self:getLoginServerInfo()
	if serverInfo then
		return serverInfo.ip
	end
end

--端口
function LoginModel:getLoginPort()
	if __LOGIN_PORT__ ~= "" then
		return __LOGIN_PORT__
	end

	local serverInfo = self:getLoginServerInfo()
	if serverInfo then
		return tostring(2000 + tonumber(serverInfo.port))
	end
end

--登录的服务器id
function LoginModel:getServerId()
	local serverId = 0
	if __QUICK_LOGIN_CONFIG__ then
		serverId = __QUICK_LOGIN_CONFIG__.serverId
		if serverId ~= nil then
			return serverId
		end
	end

	local serverInfo = self:getLoginServerInfo()
	if serverInfo then
		return serverInfo.server_id
	end
	return 0
end

--登录的唯一服id
function LoginModel:getUnitServerId()
	local serverInfo = self:getLoginServerInfo()
	if serverInfo then
		return serverInfo.unit_server
	end
	return 0
end

function LoginModel:getServerName()
	local serverInfo = self:getLoginServerInfo()
	if serverInfo then
		return serverInfo.name
	end
	return ""
end

function LoginModel:getServerList()
	return self.__serverList
end

--获取服务器版本
function LoginModel:getServerVersion()
	return self.__serverVersion
end

--获取服务器MD5
function LoginModel:getMappingMD5()
	return self.__mappingMD5
end


--玩家id在当前服的所有账号
function LoginModel:getCurServerRoleInfo()
	local tb = {}
	local serverInfo = self:getLoginServerInfo()
	for k,v in pairs(self.__allRoleInfo) do
		if tonumber(v.serverId) == tonumber(serverInfo.unit_server) then
			table.insert(tb,v)
		end
	end
	return tb
end

--普通公告
function LoginModel:getNotice(status)
	if self.__noticeData and self.__noticeData[status] then
		return self.__noticeData[status]
	end
	return {}
end

function LoginModel:setNotice(args)
	local data = type(args) == "table" and args or {}
	local noticeViewData = {}
	if #data >= 1 then

		for i,v in ipairs(data) do
			if v.status ==10 or v.status == 11 then
				if not noticeViewData[v.status] then
					noticeViewData[v.status] = {}
				end
				table.insert(noticeViewData[v.status],v)
	        else
	        	if not noticeViewData[6] then
					noticeViewData[6] = {}
				end
				table.insert(noticeViewData[6],v)
	        end
			
		end
	end
	
	self.__noticeData = noticeViewData
end



--是否正在获取推荐服
function LoginModel:isGettingRecommendServer()
	return self.__isGettingRecommendServer
end

function LoginModel:setGettingRecommendServer(value)
	self.__isGettingRecommendServer = value
end


--获取每组的服务器数量
function LoginModel:getGroupServerNum()
	return self.__groupServerNum
end

--获取所有角色
function LoginModel:getRoleList()
	return self.__dealServerList.roleList
end

function LoginModel:clearRoleList()
	self.__dealServerList.roleList = {}
end

--获取服务器组
function LoginModel:getServerGroups()

	--测试使用，可以看到两个大区
	--local temp = self.__dealServerList.serverGroups
	--local testN = #temp+1
	--if testN < 3 then
		--temp[testN] = {
			--[1] = {displayCode = 10086,name = "测试服1"},
			--[2] = {displayCode = 10088,name = "测试服2"},
		--}
	--end

	return self.__dealServerList.serverGroups
end

--获取服务器组名称
function LoginModel:getServerGroupsName()
	return self.__dealServerList.serverGroupsName
end

function LoginModel:getNewServerList()
	return self.__newServerList
end

--获取服务器组数量
function LoginModel:getGroupNum()
	return #self.__dealServerList.serverGroups
end

function LoginModel:getServerState(unitServer)
	return self.__unitServerToState[unitServer]
end

--获取点击登录按钮时使用的服务器信息
function LoginModel:getLoginServerInfo()
	
	--LuaLogE("getLoginServerInfo1")
	if __QUICK_LOGIN_CONFIG__ then
		return {
			health=2,
			ip=__QUICK_LOGIN_CONFIG__.ip,
			create_time=1520306730,
			server_id=__QUICK_LOGIN_CONFIG__.serverId,
			unit_server=__QUICK_LOGIN_CONFIG__.serverId,
			name=__QUICK_LOGIN_CONFIG__.name,
			port=__QUICK_LOGIN_CONFIG__.port,
		}
	end


	--LuaLogE("getLoginServerInfo2")
	if self.__chosenServerInfo and not __AUTO_TEST__ then
		-- printTable(92,self.__chosenServerInfo)
		return self.__chosenServerInfo
	end
	
	--LuaLogE("getLoginServerInfo3")
	if __TEST_LOGIN_SERVER__ then
		return __TEST_LOGIN_SERVER__
	end
	--LuaLogE("getLoginServerInfo4")
	
	local serverID = VersionChange:getChangeServerId()
	if serverID > 0 then
	if self.__recommendServerInfo and serverID == self.__recommendServerInfo.server_id then return self.__recommendServerInfo end 
		for k,v in pairs(self.__serverList) do
			for m,n in pairs(v) do
				if n.server_id == serverID then
					local serverInfo = n
					for k,v in pairs(self.__dealServerList.roleList) do
						if v.server_id == serverID then
							serverInfo = clone(n)
							serverInfo.roleInfo = v.roleInfo
							break
						end
					end
					LoginModel:updateSelectedServer(serverInfo)
					return n
				end
			end
		end
	end
	if self.__lastLoginServerInfo and not __AUTO_TEST__ and self:isTestAgent() then
		-- printTable(92,self.__chosenServerInfo)
		return self.__lastLoginServerInfo
	end
	
	--LuaLogE("getLoginServerInfo5")
	-- printTable(92,self.__recommendServerInfo)
	return self.__recommendServerInfo
end

--格式化本地保存的key
function LoginModel:formatUserDefaultKeyWithAgent(key)
	return string.format("%s_%s", key, AgentConfiger.getRealAgent())
end

--进入登录界面时执行，读取本地保存的服名映射表、映射表md5，服务器列表、列表版本，最后登录的玩家名等信息
function LoginModel:readSavedServerInfo()
	
	--非sdk登录且没有指定默认用户名的，读取本地保存的帐号
	if not __SDK_LOGIN__ and __DEFAULT_USERNAME__ == "" then
		local strLoginUserInfo = FileCacheManager.getStringForKey(self:formatUserDefaultKeyWithAgent(FileDataType.LOGIN_LAST_LOGIN_ACCOUNT), "", nil, true)
		if strLoginUserInfo ~= "" then
			local userInfo = json.decode(strLoginUserInfo)
			if type(userInfo) == "table" then
				self.__loginAccount.username = userInfo.username
				self.__loginAccount.password = userInfo.password
			end
		end
	end
	-------------------------

	
	-------------------------
	local data = FileCacheManager.getStringForKey(self:formatUserDefaultKeyWithAgent(FileDataType.LOGIN_SERVER_LIST), "", nil, true)
	if data ~= "" then
		data = json.decode(data)
		self:updateServerList(data)
	end
	------------------------
end

--本地保存最后获取到的服务器列表信息
function LoginModel:saveServerList(data)
	if not data then return end

	if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 or CC_TARGET_PLATFORM == CC_PLATFORM_MAC then
		self.__serverInfo = data
	end

	local serverVersion = tonumber(data.serverVersion)
	if serverVersion and self.__serverVersion ~= serverVersion then  --版本不同需要保存新的服务器信息
		self.__serverVersion = serverVersion

		if type(data.serverList) == "table" then
			self.__serverList = data.serverList
		end
		FileCacheManager.setStringForKey(self:formatUserDefaultKeyWithAgent(FileDataType.LOGIN_SERVER_LIST), json.encode(data), nil, true)
	end
end

--非sdk登录需要保存上次登录的玩家信息
function LoginModel:saveLastLoginUserInfo()
	if not __SDK_LOGIN__ and self:isUsernameValid() and self:isPasswordValid() then
		FileCacheManager.setStringForKey(self:formatUserDefaultKeyWithAgent(FileDataType.LOGIN_LAST_LOGIN_ACCOUNT), json.encode(self.__loginAccount), nil, true)
	end
end

--更新推荐服
function LoginModel:updateRecommendServer(data, notUpdate)
	if not data then return end
	local serverInfo = data.serverInfo
	
	if type(serverInfo) == "table" and next(serverInfo) then
		local name,nodeName = string.match(serverInfo.name,"(.+)_(.+)")
		if name then
			serverInfo.name = name
		end
		--serverInfo.nodeName = nodeName
		LuaLogE("updateRecommendServer.."..json.encode(serverInfo))
		self.__recommendServerInfo = serverInfo
		--[[if not notUpdate then
			Dispatcher.dispatchEvent(EventType.login_recommendServerUpdated, self.__recommendServerInfo)
		end--]]
		Dispatcher.dispatchEvent("login_chooseServer")
	else
		self.__recommendServerInfo = false
		Dispatcher.dispatchEvent("login_chooseServer")
	end
end

--更新服务器列表
function LoginModel:updateServerList(data)
	if not data then return end
	-- self.__serverList = {}
	self:saveServerList(data)

	if __IS_RELEASE__ then
		self.__groupServerNum = tonumber(data.regionNum) or 0
	else
		self.__groupServerNum = 8
	end
	self.__serverIdInterval = tonumber(data.intervalNum) or 0

	local bigRegion = data.bigRegion or {}
	local lastLoginServer = data.lastLoginServer
	local roleInfoList = data.roleInfoList or {}
	-- dump(92, data, "data")
	local tmpList = {}
	local roleList = {}
	local lastLoginServerInfo = nil

	--把各服务器列表插到大区里去
	for k, v in pairs(bigRegion) do
		local key = tostring(k)
		local srcServerList = self.__serverList[key] or {}
		-- dump(92, srcServerList, "srcServerList")
		if #srcServerList > 0 then
			--展开合服数据
			for k1, v1 in pairs(srcServerList) do

				local serverItem = clone(v1)
				serverItem.health = tonumber(serverItem.health) or 4

				local displayCode = tonumber(serverItem.server_id) or 0
				if displayCode - self.__serverIdInterval > 0 then
					displayCode = displayCode - self.__serverIdInterval
				end
				serverItem.displayCode = displayCode

				local name,nodeName = string.match(serverItem.name,"(.+)_(.+)")
				if name then
					serverItem.name = name
				end
				--serverItem.nodeName = nodeName

				local stringKey = tostring(serverItem.server_id)
				if roleInfoList[stringKey] then
					serverItem.roleInfo = newRoleInfoItem(roleInfoList[stringKey])
					table.insert(roleList,serverItem)
				else
					serverItem.roleInfo = nil
				end
				table.insert(tmpList,serverItem)

				self.__unitServerToState[serverItem.unit_server] = v
			end
		end
	end

	local function sort(a,b)
		return a.server_id < b.server_id  --临时调整一下排序
	end
	table.sort(tmpList,sort)

	--服务器界面显示用的数据结构
	self.__dealServerList = {
		roleList = roleList,
		serverGroups = {},
		serverGroupsName = {}
	}

	local serverGroups = self.__dealServerList.serverGroups
	local serverGroupsName = self.__dealServerList.serverGroupsName
	local tmp = {}
	self.__newServerList = {}
	local testTmp = {}
	local count = 0
	
	local curTime  = os.time()
	local day7 = 7*24*60*60  --7天的秒数
	
	for _,v in pairs(tmpList) do

		count = count + 1
		if curTime - v.create_time < day7 then
			table.insert(self.__newServerList,v)
		end

		table.insert(tmp,v)
		if count % self.__groupServerNum == 0 then
			
			local txt = string.format(Desc.login_group, (#serverGroups)*self.__groupServerNum+1,(#serverGroups)*self.__groupServerNum+self.__groupServerNum)
			table.insert(serverGroupsName,txt)
			table.insert(serverGroups,tmp)
			TableUtil.sortByMap(tmp, {{key="server_id", asc=true}})
			tmp = {}
		end
		-- end
	end
	
	if #tmp > 0 then
		local txt = string.format(Desc.login_group,(#serverGroups)*self.__groupServerNum+1,(#serverGroups)*self.__groupServerNum+10)
		table.insert(serverGroupsName,txt)
		table.insert(serverGroups,tmp)
	end
	
	--如果没有7天内的服务器 则取最近两个服务器作为新服
	if #self.__newServerList < 2 then
		
		table.sort( tmpList, function(a, b)
		 	return a.create_time > b.create_time
		 end)
		
		if #self.__newServerList == 1 then
			table.insert(self.__newServerList,tmpList[2])
		else
			table.insert(self.__newServerList,tmpList[1])
			table.insert(self.__newServerList,tmpList[2])
		end
		
	end
	
	table.insert(serverGroups,self.__newServerList)
	table.insert(serverGroupsName,Desc.login_newServer)
	
	if #roleList > 0 then
		table.insert(serverGroups,roleList)
		table.insert(serverGroupsName,Desc.login_userServer)
	end
	
	
	if #testTmp > 0 then
		table.insert(serverGroups,1,testTmp)
		table.insert(serverGroupsName,Desc.login_testServer)
	end


	Dispatcher.dispatchEvent(EventType.login_serverListUpdated)
end


--用户名是否有效
function LoginModel:isUsernameValid()
	return self.__loginAccount.username and self.__loginAccount.username ~= ""
end
--密码是否有效
function LoginModel:isPasswordValid()
	return self.__loginAccount.password and self.__loginAccount.password ~= ""
end

--设置登录服信息(临时用)
function LoginModel:updateSelectedServer(server)
	if not server then 
		LuaLogE("updateSelectedServer clear")
		self.__chosenServerInfo = false
		return
	end
	if type(server) == "table" then
		LuaLogE("updateSelectedServer set")
		self:setGettingRecommendServer(false)
		self.__chosenServerInfo = server
		self:saveLastLoginServer(server)
	end
end



function LoginModel:setQuietRelink(relink)
	self.__isRelink = relink
end

function LoginModel:isQuietRelink()
	return self.__isRelink
end


function LoginModel:getDeviceID()
	local deviceId = gy.GYDeviceUtil:getDeviceID()
	if deviceId == "" and device.platform == "windows" then
		deviceId = "unknow_windows_device"
	end

	return deviceId
end



function LoginModel:canTryLoginAgain()
	self.__tryLoginTimes = self.__tryLoginTimes + 1
	return self.__tryLoginTimes <= 3
end

function LoginModel:clearLoginTimes()
	self.__tryLoginTimes = 0
end


function LoginModel:switchAccountForPC()
	if CC_TARGET_PLATFORM == CC_PLATFORM_MAC or CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
		self:saveServerList(self.__serverInfo)
		self:saveLastLoginUserInfo()
	end
end

function LoginModel:readLastLoginServer()
	if CC_TARGET_PLATFORM == CC_PLATFORM_MAC or CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
		
		local lastLoginServerInfo = FileCacheManager.getStringForKey(self:formatUserDefaultKeyWithAgent(FileDataType.LOGIN_LAST_SEL_SERVER), "", nil, true)
		if lastLoginServerInfo ~= "" then
			local Info = json.decode(lastLoginServerInfo)
			if type(Info) == "table" then
				self.__lastLoginServerInfo = Info
			end
		end
	end
end

function LoginModel:saveLastLoginServer(data)
	if CC_TARGET_PLATFORM == CC_PLATFORM_MAC or CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
		self.__lastLoginServerInfo = data
		FileCacheManager.setStringForKey(self:formatUserDefaultKeyWithAgent(FileDataType.LOGIN_LAST_SEL_SERVER), json.encode(self.__lastLoginServerInfo), nil, true)
	end
end
-----------------------------

--切帐号，断线等返回登录界面的清理
function LoginModel:clear(changeRole)
	if not changeRole then
		self:init()
	end
end

function LoginModel:getServerInfoByServerId(serverId)
	for k,v in pairs(self.__serverList) do
		for m,n in pairs(v) do
			if n.server_id == serverId then
				return n
			end
		end
	end
	return false
end





LoginModel:init()
rawset(_G,"LoginModel",LoginModel)
return LoginModel
