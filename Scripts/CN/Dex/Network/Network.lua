--[[
	客户端的网络模块，注意可能引起阻塞的地方是域名解析。这里需要做优化
	Dean***:注意因为协议已经捆绑一起了，所以要重新思考服务器关于接口攻击的设计
]]

local STR_PACK_FMT = ">s2"
local TYPE_MSG_NORMAL = 0		--普通消息，参与计数
local TYPE_MSG_DONT_COUNT = 1	--不是关键消息，不参与计数
local BIG_SPILTED_PACKAGE_HAS_COMPLISH = 0
local MD5_KEY = "g1_&**bd&CKEY"

--Dex 的客户端对服务端只有一种协议，尽管服务端有多种独立服务，他们也是合并成一个，并通过sproto工具保证协议接口唯一性。
local sprotoHost --lua封装
local sprotoReq

local requestSp	--bin
local hostSp

local Network = {}
local lsocket = require "lsocket"
--local interval = 0.01
local statusInterval = 0.5 --连接状态检测
local connectInterval = 3 --连接间隔
local cc = cc
local scheduler = cc.Director:getInstance():getScheduler()
local REQ_POLL_INTERVAL = 3
local TIME_OUT_CHECK_INTERVAL_MILSEC = 15 * 1000--超时检测。 
local PING_INTERVAL = 1 * 1000--隔很长时间没收到返回要发一次heartbeat维持链接
local lastTimeoutMilSec = 0
local PING_RPC_NAME = "Heartbeat"
local networkEntity = false
local MAX_TRY_CONNECT_TIMES = 3  --5秒一次，重连两分钟


local __DEBUG__ = not __IS_RELEASE__
local recv = {}
local RECV = setmetatable({},{
		__newindex = function (t,k,v)
			--外网开发模式下不负责检测接口有没有被注册。
			if recv[k] then
				if __DEBUG__ then
					if not sprotoHost:exist_proto(k) then
						error("this rpc function "..k.." is not exit in real proto files")
					end
				end
				error("this rpc function "..k.." has been duplicated defined")
			else
				recv[k] = v
			end
		end,
		__index = recv
	})

local cb = {}
local CB = setmetatable({},{
		__newindex = function (t,k,v)
			--外网开发模式下不负责检测接口有没有被注册。
			if cb[k] then
				if __DEBUG__ then
					if not sprotoReq:exist_proto(k) then
						error("this rpc callback function "..k.." is not exit in real proto files")
					end
				end
				error("this rpc callback function "..k.." has been duplicated defined")
			else
				cb[k] = v
			end
		end,
		__index = cb
	})

local exp = {}
local EXP = setmetatable({},{
		__newindex = function (t,k,v)
			--外网开发模式下不负责检测接口有没有被注册。
			if exp[k] then
				if __DEBUG__ then
					if not sprotoReq:exist_proto(k) then
						error("this rpc exception function "..k.." is not exit in real proto files")
					end
				end
				error("this rpc exception function "..k.." has been duplicated defined")
			else
				exp[k] = v
			end
		end,
		__index = exp
	})

---获取对应S2C 协议里面的 tag 主要用来结合Controller做消息分发。
local cacheForRecv = { 
	--key name
	--value tag
}
local sprotocore = require "sproto.core"
local function GetRecvId( recvName )
	-- body
	local tag = cacheForRecv[recvName]
	if tag then
		return tag
	end
	local tag = sprotocore.protocol(hostSp.__cobj,recvName)
	cacheForRecv[recvName] = tag
	--print("tag:",tag)
	return tag
end

function Network.CheckRecvEvent( recvName )
	return sprotocore.protocol(hostSp.__cobj,recvName)
end

local pollId
local function ScheduleFunc(func, intervalSec )
	return scheduler:scheduleScriptFunc(func,intervalSec,false)
end

local function StartPoll(  )
	if pollId then
		scheduler:unscheduleScriptEntry(pollId)
	end
	pollId = ScheduleFunc(Network.Poll,0.01)
end

--[[---socketHub = array:socket
	socket = {
		__clientEntity__ => 对应实体信息。
			{
				__socket__ = socket--环形引用，每次socket断开连接时候需要断开
				__
			}
	}
				__ip__ = 必须换回IP，因为重连时候不会因网络问题卡顿
				__port__ = 默认重连的端口
]]
local socketArray = {}

--[[
	---这个是
	clientSocketHub = {
		key => addr:port
		value = clientEntity --当断开连接时候
	}
]]
local clientSocketHub = {}

--本来想改下lsockt让他生成出来的socket支持index和newindex方法，但是想想还是算了，比较麻烦。这类就一个socket不如就改这里算了，而且用的地方不多。
local socketHub = {
	--key socket
	--value clientEntity
}


local g_waitSwitchConfrim = {}
---网络通信初始化
--Dex的网络初始化主要内容：
--	初始化sproto协议
--	启动网络的事件循环器。
--@param waitSwitchConfrim array<string>:字符串数组用来标记哪些接口是用来做服务切换的。这个是必须要有的
function Network.Init( waitSwicthConfirm_ )
	print(15,"Network.Init( waitSwicthConfirm_ )")
	for _,v in ipairs(waitSwicthConfirm_) do
		g_waitSwitchConfrim[v] = true
	end
	local sproto = require "Dex.Libs.sproto.sproto"
	local sprotoloader = require "Dex.Libs.sproto.sprotoloader"
	local sprotoparser = require "Dex.Libs.sproto.sprotoparser"
	local fileUtil = cc.FileUtils:getInstance()

	--优先度文本的，其次读二进制的。外网默认读二进制的
	local function InitProto( host, req )		
		local protoPath
		local isPhone = CC_TARGET_PLATFORM == CC_PLATFORM_IOS or CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID or ScriptType == ScriptTypePackS
		if isPhone then
			protoPath = string.format("%s2%s.proto",host,req)
		else
			protoPath = string.format("Sproto/%s2%s.proto",host,req)
		end
		
		local useBinary
		if not fileUtil:isFileExist(protoPath) then			
			if isPhone then
				protoPath = string.format("%s2%s.bproto",host,req)
			else
				protoPath = string.format("Sproto/%s2%s.bproto",host,req)
			end
			useBinary = true
		end

		local data
		if fileUtil:isFileExist(protoPath) then
			if isPhone then
				data = xxteaDecryptFile(protoPath, "123")
			else
				data = fileUtil:getDataFromFile(protoPath)
			end

			if not data then
				return false
			end

			if not useBinary then
				data = sprotoparser.parse(data)
			end
		end

		if data ~= nil then
			return true, sproto.new(data)--没必要用sharenew
		end	
		return false
	end

	local host, request = "C", "S"
	local ret

	ret,requestSp = InitProto(host,request)
	if not ret then
		error(string.format("Init proto error  %s%s", host,request))
	end
	
	ret,hostSp = InitProto(request,host)
	if not ret then
		error(string.format("Init proto error  %s%s", request,host))
	end
	
	if hostSp and requestSp then
		sprotoHost = hostSp:host("Package")
		sprotoReq = sprotoHost:attach(requestSp)
		--启动网络时间定时器。
		--StartPoll()
		return true
	end
	return false
end

function InitSocek( socket, addr, port, clientEntity)
	clientEntity.tryConnectTimes = 0
	clientEntity.__sendFailedTimes__ = 0
	clientEntity.__sendCache__ = ""
	clientEntity.__cache__ = ""
	clientEntity.__msgUncomplish__ = {
			[TYPE_MSG_NORMAL] = {},
			[TYPE_MSG_DONT_COUNT] = {},
		}

	clientEntity.__socket__ = socket
	clientEntity.__addr__ = addr
	clientEntity.__port__ = port
end

---尝试添加新的socket
--目前策略：
--		连接同一个地址端口的服务端只能有一个端。
function TryAddSocket( socket, addr, port, clientEntity )
	if socketHub[socket] then
		print(15,"Socket exist! can't not add again!")
		return false
	end

	local key = addr .. ":" .. port
	clientSocketHub[key] = clientEntity
	InitSocek(socket,addr,port,clientEntity)
	print(15,"TryAddSocket: ",key,clientEntity.__IN_RELINK)
	if not clientEntity.__IN_RELINK then
		clientEntity.__net__ = {--用来清理数据包的
				waiteToSend = {},	--当socket不可用的时候此时可以将请求存起来。
				reciveId = 0,
				lastPackageSZ = 0,
				rpcCB = {},
				rpcCBResend = false,--重连以后降未发送的接口重发。
				canSendHeartbeat = true, --当心跳扫过时候查看有没有发过消息，有就不发送心跳，没有就发送心跳，最后将其标记成true
				lastHearBeadtime = 0,
				doReqCountDown = REQ_POLL_INTERVAL,
				waitSwitchConfrim = false,	
			}
	end
	table.insert(socketArray,socket)
	socketHub[socket] = clientEntity
	return true
end

local __isRelink = false
local function TryRelink( socket,lastAddr,lastPort)
	local clientKey = lastAddr ..":"..lastPort
	print(15,"TryRelink:",clientKey)
	local clientEntity = clientSocketHub[clientKey]
	if clientEntity then
		local oldSocket = clientEntity.__socket__
		print(15,"TryRelink, oldSocket:",oldSocket,"newSocek",socket)
		if oldSocket then
			local removeIndex
			for k,v in ipairs(socketArray) do
				if oldSocket == v then
					removeIndex = k
					break
				end
			end

			if removeIndex then
				table.remove(socketArray,removeIndex)
			end
			socketHub[oldSocket] = nil
			clientEntity.__socket__ = nil
			oldSocket:close()
		end

		TryAddSocket(socket,lastAddr,lastPort,clientEntity)
		return clientEntity
	end
	return nil
end

local CLOSE_ENTITY = true
local tryTimes

local __cancelRelink = false
function Network.cancelRelink( reason )
	print(15,"recive canRelink reason",reason)
	__cancelRelink = true
end

function Network.isCancelRelink()
	return __cancelRelink
end

function Network.CloseSocket( socket, closeEntity, initiativeClose)
	if not socket then return end
	local removeIndex
	for k,v in ipairs(socketArray) do
		if socket == v then
			removeIndex = k
			break
		end
	end

	if removeIndex then
		table.remove(socketArray,removeIndex)
	end

	print(15,"Network.CloseSocket",socket, ", inputCloseEntity:",tostring(closeEntity), ", initiativeClose:",tostring(initiativeClose),"#socketArray:",#socketArray,debug.traceback())
	local entity = socketHub[socket]
	socketHub[socket] = nil

	if entity then
		entity.__socket__ = nil
		if closeEntity then
			entity.tryConnectTimes = nil
			entity.__event__.CloseEntity(entity,initiativeClose)
			LuaLogE("closeEntity 最终关闭玩家了:",debug.traceback())
			--Network.ClientConnect(entity.__addr__,entity.__port__, nil, nil, false, false)  --重走登陆流程
		else
			local canRelink = entity.__event__.TryRelink(entity)
			if canRelink then  --重连中...
				local now = cc.millisecondNow()
				print(15,"aaaaaaaaa",now,entity.__lastMarkRelinkMs or 0,now - (entity.__lastMarkRelinkMs or 0))
				if now - (entity.__lastMarkRelinkMs or 0) > 3000 then
					print(15,"bbbbbb")
					entity.__IN_RELINK = true
					entity.__lastMarkRelinkMs = now
					local relinkInfo = entity.relinkInfo
					print(15,"relinkInfo.relinkHanle:",relinkInfo.relinkHanle)
					if not relinkInfo.relinkHanle then
						local function callback()
							if __cancelRelink then
								Scheduler.unschedule(relinkInfo.relinkHanle)
								relinkInfo.relinkHanle = nil
							end

							relinkInfo.linkTimes = relinkInfo.linkTimes + 1		
							if relinkInfo.linkTimes > MAX_TRY_CONNECT_TIMES then
								__cancelRelink = true
								LuaLog("达到最大重连数",MAX_TRY_CONNECT_TIMES)
								if not initiativeClose then
									Dispatcher.dispatchEvent(EventType.login_show_tips,Desc.socket_error)
								end
							else
								Dispatcher.dispatchEvent(EventType.socket_tryreconnect, relinkInfo.linkTimes)
								tryTimes = false
								ViewManager.showReconnectWait()
								print(15,"重新连接中.....",relinkInfo.linkTimes,entity.__addr__,entity.__port__, relinkInfo.linkTimes,debug.traceback())
								Network.ClientConnect(entity.__addr__,entity.__port__, nil, nil, true)
							end
						end
						relinkInfo.relinkHanle = Scheduler.schedule(callback,2,5)
						--callback()
					end
				end
				--重连失败!
			else
				entity.__event__.CloseEntity(entity, initiativeClose)
			end
			entity.__event__.NetworkCheck(-1)--网络出问题。
		end
	else
		LuaLog("玩家已经不在了",next(socketHub))
	end
	socket:close()
end

---will create client or relink client
--
local tryTimeCache = {}--多个client的时候的优化
local breakConnnectingHandle = false
local lastIp,lastPort



local MAX_OFFLINE_MILLS = 10000--跟服务器的最大离线事件一致！！！
local POLL_FOR_CHECK_INIT = -100
local POLL_FOR_CHECK_NOT_INIT = POLL_FOR_CHECK_INIT - 1
local pollForCheckSlowNetworkCount = POLL_FOR_CHECK_NOT_INIT
local MAX_CHECK_NETWORK_POLL_COUNT = 2--每两帧检测有没有超过SLOW_NET_WORK_MILLS
local SLOW_NET_WORK_MILLS = 1000--超过
if __IS_RELEASE__ then
	SLOW_NET_WORK_MILLS = 1000
end


--local milsecStart = cc.millisecondNow()

--首次链接时候会传入clientEvent
--连接一定不能在上一次连接还没断开就又连一次，不然会两个连接都连不上
function Network.ClientConnect( addr, port, clientNetEvent, clientEntity, isReconnect)
	__isRelink = isReconnect
	local timerId
	--local fullAddr = string.format("%s:%d",addr,port)
	if clientNetEvent then--首次登陆
		__cancelRelink = false	
	end
	if not tryTimes then
		tryTimes = 1
	else
		print(15,"in tryConnect")
		return
	end

	--换了服务器，清空之前的状态
	if lastIp ~= addr or lastPort ~= port then
		Network.clear()
	end
	
	
	local socket, errmsg
	--local tryConnect
	lastIp = addr
	lastPort = port

	local function TryGetIfConnect ()
		local ok, errmsg
		if socket then
			ok, errmsg = socket:status()
		end
		print(15,"TryGetIfConnect",ok,errmsg)
		if timerId then
			Scheduler.unschedule(timerId)
		end
		if ok then
			--连接成功
			local clientEntity
			if clientNetEvent then
				clientEntity = clientNetEvent.InitClientEntity()
				if clientEntity then
					clientEntity.__event__ = clientNetEvent
					if not TryAddSocket(socket,addr,port,clientEntity) then
						--链接失败
						print(15,"connection fail")
						clientNetEvent.ConnectError(addr,port,"connection has connected")
						Network.CloseSocket(socket,CLOSE_ENTITY)
					else
						--这里对host做操作
						print(15,"首次登录调用ConnectHost!!")
						
						RPCReq.ConnectHost({})
					end
				end
				pollForCheckSlowNetworkCount = POLL_FOR_CHECK_NOT_INIT
			else
				LuaLogE(15,"尝试重连")	
				clientEntity = TryRelink(socket,addr,port)
				if not clientEntity then 	
					--print("connection was not built!!!!,addr:",addr,", prot:",port)
					--clientNetEvent.ConnectError(addr,port,"connection was not built")
					print(15, "===== CloseSocket",socket)
					Network.CloseSocket(socket,CLOSE_ENTITY)
				else
					--这里做host操作。					
					print(15,"尝试连接",clientEntity.srvHandle,
						tostring(clientEntity.uid),
						tostring(clientEntity.__net__.reciveId),
						tostring(clientEntity.__net__.lastPackageSZ)
					)

					LuaLogE(15,"重发发送连接",clientEntity.__net__.reciveId,clientEntity.__net__.lastPackageSZ)
					local valueType = type(clientEntity.uid)
					print(15,"++++ ConnectHost")
					RPCReq.ConnectHost({
							srvHandle	= clientEntity.srvHandle,
							secret 		= valueType == "string" and clientEntity.uid or nil,
							intUid 		= valueType == "number" and clientEntity.uid or nil,
							recvId 		= clientEntity.__net__.reciveId,
							sz 			= clientEntity.__net__.lastPackageSZ
						})
				end
			end

			--主动断开
			if not __IS_RELEASE__ then
				Network.initiative_break = function ()
					Network.CloseSocket(socket)
				end
				Dispatcher.addEventListener(EventType.initiative_break,Network)
			end
			tryTimes = nil
			return
		end
		--local tryTimes = tryTimeCache[fullAddr]
		
			
		if not tryTimes then 
			tryTimes = 0
		end
		tryTimes = tryTimes + 1
		if tryTimes >= 2 then--20秒尝试两次就可以了
			print(15,"tryTimes",tryTimes)
			tryTimes = nil
			if not isReconnect and clientNetEvent then
				clientNetEvent.ConnectError(addr,port,"connect timeout")
			end
			Network.CloseSocket(socket,CLOSE_ENTITY)
	
		else
			print(15,"tryTimes",tryTimes)
			timerId = Scheduler.scheduleOnce(statusInterval, TryGetIfConnect)

		end
	end
	
	--tryConnect = function()
		--milsecStart = cc.millisecondNow()
	--LuaLogE("tryConnect")
	if timerId then
		Scheduler.unschedule(timerId)
	end
	if socket then Network.CloseSocket(socket) end
	socket, errmsg = lsocket.connect(addr,port)
	print(15,"=== ClientConnect",addr,port, socket, errmsg,debug.traceback())
	if errmsg then
		if socket and (not isReconnect or (isReconnect and reachMaxTimes ))  then
			if clientNetEvent then
				clientNetEvent.ConnectError(addr,port,errmsg)
			end
			Network.CloseSocket(socket,CLOSE_ENTITY)
		end
		print(33, "connect error!", errmsg)
		return false
	end
	TryGetIfConnect()
	--end
	
	--tryConnect()
	--TryGetIfConnect()
	--可能poll在切换场景等时候失效了，这里需要重新开启。
	StartPoll()
	return true
end


--数据处理这里比较复杂一点就是考虑了大数据包。
--项目可以根据自己需要做优化，其中字符字符根式处理协议这部分应该用c来写效率更高。
local function HandleRecvData( socket, p, entity ,milsecNow)
	local msgUncomplish = entity.__msgUncomplish__
	local entityNetData = entity.__net__
	local clientNetEvent = entity.__event__
	if entityNetData.doReqCountDown <= 0 then
		entityNetData.doReqCountDown = REQ_POLL_INTERVAL
	end
	local tryPType = tonumber(string.sub(p,1,1))
	if tryPType == nil then
		return
	end
	local pType,unfinish = math.modf(tryPType/2)
	local typeCache = msgUncomplish[pType]
	if not typeCache then
		print(15, "type not init drop this package")
	else
		entity.__lastReciveData__ = milsecNow 
		table.insert(typeCache,string.sub(p,2))
		local handleType = math.floor(pType/2)
		if handleType == TYPE_MSG_NORMAL then
			entityNetData.reciveId = entityNetData.reciveId + 1
			print(15, "reciveId:",entityNetData.reciveId)
			entityNetData.lastPackageSZ = #p
		end
		if unfinish == BIG_SPILTED_PACKAGE_HAS_COMPLISH then
			local msgsFlow = table.concat(typeCache)
			local msgsFlowSize = #msgsFlow
			local pos,data  = 1
			repeat
				data,pos = string.unpack(STR_PACK_FMT,msgsFlow,pos)
				local pcallRet, rpcType, name, rpcData, response, ud = pcall(sprotoHost.dispatch,sprotoHost,data)
				if pcallRet then
					if rpcType == "REQUEST" then
						entityNetData.canSendHeartbeat = true
						local f = RECV[name]
						--if name ~= "Scene_MoveInfo" and name ~= "Scene_AttrUpdate" and name ~= "Scene_SkillEffects"
							--and name ~= "Cross5v5_PlayerUpdateInfo" and name ~= "Scene_EntitysChange"
						-- then
							-- print(92, "----------------------------- name", name)
						--end
						--如果是服务端主动断开的，不需要重连了
						if name == "CloseClient" then
							--reasons可以在ReasonType里面找到
							print(15, "CloseClient", "reason = "..rpcData.reason)
							if __isRelink then return end
							Network.CloseSocket(socket, true, true)
							local info = {}
							if rpcData.reason == GameDef.ReasonType.ReLogin or rpcData.reason == GameDef.ReasonType.ElseLogin then
								Dispatcher.dispatchEvent("login_elseLogin") --帐号在其他设备登陆（提示的操作不一样（有顶回去），发到外面处理）
								return
							elseif rpcData.reason == GameDef.ReasonType.LoginError then
								info.text = Desc.login_nettips3
							else
								info.text = Desc.login_nettips2
							end
							info.type = "ok"
							info.mask = true
							info.onOk = function()
								FlowManager.backToLogin()
							end
							Alert.show(info)
							return
						elseif name == "Login_PlayerData" then
							pollForCheckSlowNetworkCount = POLL_FOR_CHECK_INIT
						end
						if f then
							local ret,msg = xpcall(f,__G__TRACKBACK__,rpcData,entity)
							if ret == false then
								if response then
									socket:send(response( nil, {repError = msg} ))
									--Network.SendData(fd, response( nil, {repError = msg} ))
								end
							else
								if response then
									if type(msg) == "table" then
										socket:send(response(msg))
										--Network.SendData(fd, response(msg))
									else
										socket:send(response( nil, {repError = 0 }))
										--Network.SendData(fd, response( nil, {repError = 0 }))
									end
								end
							end
						end
						if not f and response then
							socket:send(response( nil, {repError = 0 }))
							--Network.SendData(fd, response( nil, {repError = 0 }))
						end
						--print(15,"rev RecvType  = "..name)
						--printTable(22,"data  = ",rpcData)
						Dispatcher.dispatchEvent(name,rpcData,entity)
						--xpcall(clientNetEvent.RecvProxy,__G__TRACKBACK__,GetRecvId(name),entity,rpcData,response,name)
					elseif rpcType == "RESPONSE" then
						local session = name
						ud = response
						local response = rpcData
						print(15,"session response:",session)
						if session then
							local sessionRep = entityNetData.rpcCB[session]
							if not sessionRep then
								if entityNetData.rpcCBResend then
									sessionRep = entityNetData.rpcCBResend[session]
									entityNetData.rpcCBResend[session] = nil
								end
							else
								entityNetData.rpcCB[session] = nil
							end
							if sessionRep then
								if sessionRep.name == "Heartbeat" then
									xpcall(function ()
										local heartUseTime = milsecNow - sessionRep.callTime
										Dispatcher.dispatchEvent(EventType.network_ping, heartUseTime)
									end,__G__TRACKBACK__)
								end
								xpcall(clientNetEvent.NetworkCheck,__G__TRACKBACK__, milsecNow - sessionRep.callTime)--网络ping值
								name = sessionRep.name
								print(15,"response:",name,session)
								if name ~= PING_RPC_NAME then
									--print("recive any msg:",name)
									--print("\tresponse name:",name)
									entityNetData.canSendHeartbeat = true
								end
								--print("ud:",ud,"repError:",ud and ud.repError)
								if ud and ud.repError then--异常处理
									local f = EXP[name]
									if f then
										local ret, msg = xpcall(f, __G__TRACKBACK__, ud, entity, sessionRep.bindData )
										if not ret then
											print("running exception:"..name..",error:"..msg)
										end
									end

									f = sessionRep.exception
									local ret,showRollTips = false,false
									if f then
										ret, showRollTips = xpcall(f, __G__TRACKBACK__, ud, entity, sessionRep.bindData )
										if not ret then
											print("running exception:"..name..",error:"..showRollTips)
										end
									end

									if not f or showRollTips then
										--统一异常处理函数，这个由NetInterface定
										--Dean***:网络异常默认处理
										clientNetEvent.DefaultExp(ud,name,entity,sessionRep.bindData)
									end
								else
									local f = CB[name]
									local doResponse = false
									if f then
										doResponse = true
										local ret,msg = xpcall(f, __G__TRACKBACK__, response, entity, sessionRep.bindData)
										if not ret then
											print("running CB:"..name..",error:"..msg)
										end
									end
									if f ~= sessionRep.callback then
										f = sessionRep.callback
										if f then
											doResponse = true

											printTable(22,"RPCReq callback = "..sessionRep.name,response)
											local ret,msg = xpcall(f, __G__TRACKBACK__, response, entity, sessionRep.bindData)
											if not ret then
												print("running CB:"..name..",error:"..msg)
											end
										end
									end
									
									if not doResponse then
										print("no any callback function match to:"..name)
									end
								end
								if name ~= "Heartbeat" then
									-- print("RECV-RESPONSE:",name)
									-- printTable(ud)
									-- printTable(response)
								end
							else
								print("RESPONSE find no callback data")
							end
						end
					end
				else
					LuaLogE(string.format("ERROR: sproto dispatch error: %s",rpcType))
				end
			until msgsFlowSize <= pos
			msgUncomplish[pType] = {}
		end
	end
end

local function sendBuffer(clientEntity, socket)
	local bytes, errStr = socket:send(clientEntity.__sendCache__)
	if bytes == false then
		local ok, errmsg = socket:status()
		if not ok then
			print(15,"write error1:", errmsg)
			xpcall(Network.CloseSocket,__G__TRACKBACK__,socket)
		end
		clientEntity.__sendFailedTimes__ = clientEntity.__sendFailedTimes__ + 1
	elseif bytes == nil then
		local tryConnectTimes = clientEntity.tryConnectTimes
		if tryConnectTimes then
			if tryConnectTimes < 60 then
				clientEntity.tryConnectTimes = tryConnectTimes + 1
			else
				xpcall(Network.CloseSocket,__G__TRACKBACK__,socket)
			end
		else
			clientEntity.tryConnectTimes = 1
		end
		print(15,"write error2: ", errStr, tryConnectTimes)
	elseif bytes > 0 then
		clientEntity.tryConnectTimes = nil
		clientEntity.__sendCache__ = clientEntity.__sendCache__:sub(bytes+1)
	end

	if clientEntity.__sendFailedTimes__ > 10 then
		local sock = socket:info("socket")
		print(15,"writeSockets __sendFailedTimes__ > 10")
		xpcall(clientEntity.__event__.NetworkError,__G__TRACKBACK__,sock.addr,sock.port,"peer not response for sending data",clientEntity)
		xpcall(Network.CloseSocket,__G__TRACKBACK__,socket)
	end
end


local printCount = 1
function PrintCount( ... )
	if printCount > 100 then
		return
	end
	print(...)
	printCount = printCount+1
end

local selectErrorTimes = 0
--电脑端socket表现非常诡异, 因此跟手机端区分开
local selectErrorMaxTimes = (CC_TARGET_PLATFORM == CC_PLATFORM_IOS or CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) and 500 or 35

local lastFrameMs = cc.millisecondNow()
function Network.Poll( )
	local readSockets,writeSockets = lsocket.select(socketArray, socketArray, 0)
	if readSockets == false then
		--print(15,"=== no avaliable socket!!",writeSockets,selectErrorTimes,"socketArray sie:",#socketArray)
		selectErrorTimes = selectErrorTimes + 1
		if selectErrorTimes >= selectErrorMaxTimes then
			selectErrorTimes = 0   --网络错误
			for socket,clientEntity in pairs(socketHub) do
				Network.CloseSocket(socket)
				xpcall(clientEntity.__event__.NetworkError,__G__TRACKBACK__,nil, nil, "Connection refused")
			end
		end
		return
	elseif readSockets == nil then
		--print(15,"=== error occur!!!",writeSockets)
		return
	end
	selectErrorTimes = 0

	local recvData, msg, errStr, ex
	local milsecNow = cc.millisecondNow()
	local diffMs = milsecNow - lastFrameMs
	lastFrameMs = milsecNow
	--if readSockets and math.random(1,99) < 5 then--模拟丢包和网络不好
	if readSockets then
		for _,socket in ipairs(readSockets) do
			local clientEntity = socketHub[socket]
			if clientEntity then
				recvData, errStr,ex = socket:recv()
				-- print(15,"接收数据:",tostring(recvData),tostring(errStr),tostring(ex))
				if recvData  then
					--print("get read some data:", recvData, #recvData, errStr,ex)
					local cacheMsg = clientEntity.__cache__ .. recvData
					local ok,msg,n
					while true do
						ok,msg,n = pcall(string.unpack, STR_PACK_FMT,cacheMsg)
						if ok and msg and msg ~= "" then
							if clientEntity.tryConnectTimes then
								clientEntity.tryConnectTimes = nil
							end
							cacheMsg = cacheMsg:sub(n)
							--print("in here !!!!",#msg)
							local ret,msg = xpcall(HandleRecvData,__G__TRACKBACK__,socket,msg,clientEntity,milsecNow)
							if not ret then
								xpcall(clientEntity.__event__.RPCError,__G__TRACKBACK__,clientEntity,msg)
							end
						else
							break
						end
					end
					if cacheMsg then
						clientEntity.__cache__ = cacheMsg
					else
						clientEntity.__cache__ = ""
					end

				elseif errStr then
					print(15, "readSockets errStr:",errStr)
					local sock = socket:info("socket")
					
					--重连失败了
					local doCloseEntity = false
					if clientEntity and clientEntity.__IN_RELINK then
						clientEntity.__IN_RELINK = false 
						doCloseEntity = true
						xpcall(clientEntity.__event__.NetworkError,__G__TRACKBACK__,sock.addr,sock.port,errStr,clientEntity)
					end
					xpcall(Network.CloseSocket,__G__TRACKBACK__,socket,doCloseEntity)
				else
					--local ok,errmsg = socket:status()
					--PrintCount("server die,",ok,errmsg)
					-- print(15,"socket 状态: ", socket:status())
				end
			else
				PrintCount("clientEntity not found")
			end
		end
	end

	local doCheckTimeout = false
	if milsecNow - lastTimeoutMilSec > 1000 then--每秒检测超时
		doCheckTimeout = true
		lastTimeoutMilSec = milsecNow
	end

	if pollForCheckSlowNetworkCount >= POLL_FOR_CHECK_INIT then
		pollForCheckSlowNetworkCount = pollForCheckSlowNetworkCount + 1
		if pollForCheckSlowNetworkCount > MAX_CHECK_NETWORK_POLL_COUNT then
			pollForCheckSlowNetworkCount = 0
		end
	end

	local toClose
	for _, socket in ipairs(socketArray) do
		--这里做req/rep的算法处理
		local clientEntity = socketHub[socket]
		if clientEntity and not clientEntity.tryConnectTimes then
			local net = clientEntity.__net__
			if net.doReqCountDown > 0 then
				net.doReqCountDown = net.doReqCountDown - 1

			elseif net.canSendHeartbeat then
				net.canSendHeartbeat = false
				net.lastHearBeadtime = milsecNow
				-- print(15,"发送心跳包1")
				if not clientEntity.__IN_RELINK then
					xpcall(RPCReq.Heartbeat,__G__TRACKBACK__,clientEntity)
				end
			end

			if pollForCheckSlowNetworkCount == 0 then
				local getSlowCall = false
				--local heartbeatOnce = true--在服务端或者客户端处理消息卡帧的情况下回导致心跳异常，举例再一个接口里面，再下推了很多消息被处理，这时候心跳就超时了。
				--heartbeatOnce不开启，所有问题应该要能被解决，而不是容忍。
				for sessionId,sessionRep in pairs(net.rpcCB) do
					if sessionRep.name ~= "Heartbeat" then
						local to = milsecNow - sessionRep.callTime
						if to > (SLOW_NET_WORK_MILLS + diffMs) then
							getSlowCall = true
						end
					end
				end
				if getSlowCall then
					--print(15,"ViewManager.showReconnectWait()")
					--LuaLog("getSlowCall")
					ViewManager.showReconnectWait(true)
				else
					--print(15,"closeReconnectWait")
					--LuaLog("closeSlowCall")
					ViewManager.closeReconnectWait()
				end
			end
			if doCheckTimeout then
				local isToClose = false
				--做超时检测，原则上来说一旦有ping方法超时了，那么说明网络是有问题的。我们就主动断开网络，尝试重连。
				--不做主动断开了，同时记住我们是不需要timeout的。因为有重连机制和重发机制。所以timeout拿不定标准！！！
				for sessionId,sessionRep in pairs(net.rpcCB) do
					local to = milsecNow - sessionRep.callTime
					--[[if to > TIME_OUT_CHECK_INTERVAL_MILSEC then
						net.rpcCB[sessionId] = nil--消息应该已经超时了，不在做继续检测。
					end--]]
					
					if to > MAX_OFFLINE_MILLS then
						if sessionRep.name ~= PING_RPC_NAME then 
							LuaLogE("heart timeout",sessionRep.name, to)
							toClose = toClose or {}
							toClose[socket] = true
							isToClose = true							
						end
						--net.rpcCB[sessionId] = nil
					end
				end
				
				if not isToClose then
					local heartUseTime = milsecNow - net.lastHearBeadtime
					if heartUseTime >= PING_INTERVAL then
						net.lastHearBeadtime = milsecNow
						-- print(15,"发送心跳包2")
						xpcall(RPCReq.Heartbeat,__G__TRACKBACK__,clientEntity)
					end
				end
			end
		end
	end

	if toClose then
		for socket,_ in pairs(toClose) do
			LuaLogE("close socket")
			xpcall(Network.CloseSocket,__G__TRACKBACK__,socket)
		end
	end

	--这里处理发送
	--print(15,"socekts:try write:")
	for _,socket in ipairs(writeSockets) do
		--print(15,"socekts:",socket)
		if not toClose or not toClose[socket] then
			local clientEntity = socketHub[socket]
			if clientEntity then
				sendBuffer(clientEntity,socket)
			end
		end
	end
end

local handleCount
local reqRepMode = true
---这个是提供给外部调用用来标识客户端是否非常繁忙已经处理不过来了。
--当busy为true当启用了req/rep模式的时候，开始busy相当于只发送接包数量，不要求请求数据。
--handleCount有指定数量时候，客户端会只向服务器拿N条。
function Network.BusyClient( busy,handleCount_ )
	handleCount = handleCount_
	if handleCount then
		reqRepMode = true
	elseif busy then
		reqRepMode = true
	else
		reqRepMode = false
	end
end

---统一的发送消息接口
--
--@param clientEntity 	玩家网络实体，也是玩家数据载体。携带socket信息
--@param name 			接口名字
--@param args			{} 发送数据的table
--@param bindData		当有回调的时候用来传回去给回调用的。
--@param callback		通信框架允许定义全局默认处理的CB[name]，也允许自定义callback函数闭包
--@param exception		通信框架允许定义全局默认处理的EXP[name],也允许自定义exception函数闭包
--@param syncResponse	同步回调，Dean***:todo 当回调那里都不定义CB EXP callback exception这里面的任意一个方法，但是接口默认是有回调的。这时候说明协程框架可用，异步代码会同步执行。
local sessionId = 1
local millisecondNow = cc.millisecondNow or function ( ... )
	return 0--dummy for 
end
local SET_VALUE,POP_BACK=true,nil
local function IterHack( msgName, value,i,hackPath, srcData )
	local pathKey = hackPath[i]
	if not pathKey then
		--最终赋值了
		-- pathKey = hackPath[i-1]
		-- srcData[pathKey] = value
		--返回true表示终结了，要执行赋值操作了
		return SET_VALUE
	end
	local ret
	if pathKey == "*" then
		if type(srcData) == "table" then
			local nextPos = i + 1
			for k,v in pairs(srcData) do
				ret = IterHack(msgName, value,nextPos,hackPath,v)
				if ret == SET_VALUE then
					srcData[k] = value
				end
			end
		else
			LuaLogE("try container named:%s type error src data type is:%",tostring(hackPath[i-1]),srvValueType)
		end
		return POP_BACK --这个操作只会返回false
	end
	if type(srcData) ~= "table" then
		LuaLogE("try hack field name:%s but src is not table",tostring(hackPath[i-1]))
		return POP_BACK
	end 
	local numStr = string.match(pathKey,"$([-+%.%d]+)")
	if numStr then
		pathKey = tonumber(numStr)
	end
	local srvValue = srcData[pathKey]
	local srvValueType = type(srvValue)
	ret = IterHack(msgName, value,i+1,hackPath,srvValue)
	if ret == SET_VALUE then
		srcData[pathKey] = value
	end
	return POP_BACK
end

local function quickPrint( t,depth )
	depth = depth or 0
	depth = depth + 1
	if depth > 5 then
		return "嵌套太深"
	end
	local ret = "{"
	for k,v in pairs(t) do
		if type(k) == "string" then
			k = string.format("\"%s\"",k)
		end
		local vt = type(v) 
		if vt == "function" or vt == "userdata" then
		elseif vt == "table" then
			ret = string.format("%s%s:%s,",ret,tostring(k),quickPrint(v,depth))
		else
			ret = string.format("%s%s:%s,",ret,tostring(k),tostring(v))
		end
	end
	return string.format("%s}",ret)
end

--检查消失最大超时时间
local function checkMsgTime(clientEntity)
	local maxTime = 0
	for _,v in pairs(clientEntity.__net__.rpcCB) do
		local time = cc.millisecondNow() - v.callTime
		if time > maxTime then
			maxTime = time
		end
	end
	LuaLogE("maxCallTime = "..maxTime )
end

local function packSecondParams( args )
	local md5ParamsT = {}
	for key, value in pairs(args) do
		local numType = type(value)
		if type(value) == "number" or numType == "string" then
			table.insert(md5ParamsT, key.."="..value)
		end
	end
	table.sort(md5ParamsT)
	return table.concat(md5ParamsT, "&")
end

local function packMd5Params( md5ParamsT, args )
	if not args then
		return
	end
	for key, value in pairs(args) do
		local numType = type(value)
		if type(value) == "number" or numType == "string" then
			table.insert(md5ParamsT, key.."="..value)
		end
	end
	if #md5ParamsT >= 3 then
		return
	end
	for key, value in pairs(args) do
		local numType = type(value)
		if type(value) == "table" then
			table.insert(md5ParamsT, key.."="..packSecondParams(value))
		end
	end
end

local function makeMd5Sign( args )
	local md5ParamsT = {}
	packMd5Params(md5ParamsT, args)
	table.sort(md5ParamsT)
	local md5ParamsStr = table.concat(md5ParamsT, "&") .. MD5_KEY
	return gy.GYStringUtil:getStringMD5(md5ParamsStr)
end

local __SendMsgMap = {}
local _hackSendPath
--minInterval 同一接口最小调用间隔
local function SendMsg(clientEntity,name,args,bindData,callback,exception,minInterval,syncResponse,doWaitSwitchConfirm)
	if minInterval == nil then
		minInterval = 0
	elseif type(minInterval) ~= "number" then
		minInterval = 0
	end
	--50ms内调用同一接口的话，把请求抛弃(仅在特殊需求接口用)
	if __SendMsgMap[name]  and (cc.millisecondNow() - __SendMsgMap[name]) < minInterval then
		return
	end
	__SendMsgMap[name] = cc.millisecondNow()
	
	if __IGONRE_LOGIN__ then
		return
	end
	if name~= "Heartbeat" then
		printTable(15,"RPCReq send "..name,args)
	end
	if __DEBUG__ then
		--只有debug的情况下才会启用Hack
		if __HACK_SEND__ ~= "" then
			if not _hackSendPath then
				_hackSendPath = string.format("HackSend.%s",__HACK_SEND__)
			end
			local HackSend = require(_hackSendPath)
			local hackInfo = HackSend[name]
			if hackInfo then
				for hackPath, hackValue in pairs(hackInfo) do
					local notFind
					local tmp = nil
					local paths = {}
					for k in string.gmatch(hackPath,"([%*$%w]+)") do
						table.insert(paths,k)
					end
					IterHack(name,hackValue,1,paths,args)
				end
				print(__PRINT_TYPE__,"HackSend name:",name)
				printTable(__PRINT_TYPE__,args)
			end
		end
	end
	-- if name ~= PING_RPC_NAME then
	-- 	--print("SendMsg:",name)
	-- end
	local session
	local socket = clientEntity.__socket__
	local net = clientEntity.__net__
	if not socket or not net then
		--链接断开了，将发送请求存起来。后面优化重连时候做把
		--clientEntity.__net__.table.pack(name,args,bindData,callback,exception,syncResponse )
		--ViewManager.closeReconnectWait()
		--clientEntity.__event__.NetworkError("","","Socket has not built please check",clientEntity)
		return
	end

	local netWaitSwitchConfrim = net.waitSwitchConfrim
	if netWaitSwitchConfrim then		
		LuaLogE("waitSwitchConfrim and name:",name,debug.traceback())
		--1.5秒内没收到服务器确认则先缓存消息，超过1.5秒则清空重新请求登录，防止遇到服务器未启动之类的问题导致永远无法登录
		if cc.millisecondNow() - netWaitSwitchConfrim < 10000 then
			if name ~= PING_RPC_NAME and not g_waitSwitchConfrim[name] then		
				table.insert(net.waiteToSend,table.pack(clientEntity,name,args,bindData,callback,exception,syncResponse,doWaitSwitchConfirm))
			end
			if name == PING_RPC_NAME  then
				return
			end
		end
		--超过1.5秒清空缓存消息，重新请求登录
		--net.waiteToSend = {}
	end

	local data
	local cb,exp
	if callback ~= nil then
		cb = callback
	else
		cb = CB[name]
	end

	if exception ~= nil then
		exp = exception
	else
		exp = EXP[name]
		if exp == nil and ( cb or bindData ) then
			exp = clientEntity.__event__.DefaultExp
		end
	end

	if exp then
		--print("add session id ????",type(bindData),type(cb),type(exp))
		session = sessionId
		sessionId = sessionId + 1
		clientEntity.__net__.rpcCB[session] = {
			args = args,
			bindData = bindData,
			callback = cb,
			exception = exp,
			callTime = millisecondNow(),
			name = name
		}
	end

	local ud = {}
	if reqRepMode then
		ud.recvIdAndRep = net.reciveId
	else
		ud.recvId = net.reciveId
	end
	if handleCount then
		ud.handleCount = handleCount
	end
	ud.sign = makeMd5Sign( args )
	local pack = ""
	if sprotoReq then
		pack = string.pack(STR_PACK_FMT, 
			sprotoReq(
					name,
					args,
					session,
					ud
				)
			)
	end

	if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 or CC_TARGET_PLATFORM == CC_PLATFORM_MAC then --没有回调，直接显示接口,有回调的收到回调后再显示
		if name ~= "Heartbeat" then
			if not __IS_RELEASE__ then
				Dispatcher.dispatchEvent(EventType.test_callTime,name,args and quickPrint(args) or "nil")
			end
		end
	end

	-- repeat
	-- 	local bytes = socket:send(pack)
	-- 	if not bytes then
	-- 		local ok, errmsg = socket:status()
	-- 		if not ok then
	-- 			print("write error:"..errmsg)
	-- 			Network.CloseSocket(socket)
	-- 		end
	-- 		--print(15,"not send bytes",bytes)
	-- 		--break
	-- 	else
	-- 		pack = pack:sub(bytes+1)	
	-- 	end
	-- until pack == ""

	clientEntity.__sendCache__ = clientEntity.__sendCache__ .. pack
	net.doReqCountDown = REQ_POLL_INTERVAL
	if syncResponse then
		--yeild here 先保留吧
	end

	if doWaitSwitchConfirm then
		net.waitSwitchConfrim = cc.millisecondNow()
	end
	sendBuffer(clientEntity,socket)
end

---一般消息回调消息处理
--当项目确定有限的连接类型的时候，做多一次封装每次不需要吧entity拿进来。这个事情，可以写在OnConnected上面。
_G.RPCReq = setmetatable( {},{
	__index = function( t,k )
		local sendWarp
		if not g_waitSwitchConfrim[k] then
			sendWarp = function (args, callback, exception, bindData,minInterval )
				if not networkEntity then
					networkEntity = Cache.networkCache
				end

				SendMsg(networkEntity,k,args,bindData,callback,exception,minInterval, nil,nil)
			end
			t[k] = sendWarp--存起来减少频繁创建函数
		else
			sendWarp = function (args, callback, exception, bindData,minInterval )
				if not networkEntity then
					networkEntity = Cache.networkCache
				end
				SendMsg(networkEntity,k,args,bindData,callback,exception,minInterval, nil,true)
			end
			t[k] = sendWarp--存起来减少频繁创建函数
		end
		return sendWarp
	end
	})

---协程发消息处理。
_G.CorReq = setmetatable( {},{
	__index = function( t,k )
		--Dean***:这里是还没有做好的，到时候需要对callback 和exception做下返回处理。
		local function SendWarp( entity, args )
			SendMsg(entity,k,args,nil,nil,nil,true)
		end
		t[k] = SendWarp
		return SendWarp
	end
	})

function RECV:SwitchConfirm( entity )
	
	print(15,"**********SwitchConfirm********")
	
	entity.__net__.waitSwitchConfrim = false
	--主动下发的切换成功
	entity.uid = self.secret or self.intUid --注意对于客户端来说这个UID都是服务器分配的。

	if entity.__IN_RELINK  then
		--断开连接是重连中的一个表现，当且紧当不是标识为断开连接状态才会进入服务切换逻辑
		__isRelink = false
		__cancelRelink = true
		entity.relinkInfo.linkTimes = 0
		Scheduler.unschedule(entity.relinkInfo.relinkHanle)
		entity.relinkInfo.relinkHanle = nil
		entity.__event__.RelinkSuccess(entity)
		local nowMs = millisecondNow()
		if next(entity.__net__.rpcCB) then
		end
		LuaLogE("重连成功，准备处理未收发数据：")
		local rpcCBResend = {}
		entity.__net__.rpcCBResend = rpcCBResend
		for sessionId,sessionRep in pairs(entity.__net__.rpcCB) do
			--将这里的数据重连成功后等心跳完成以后重新发送一次。
			rpcCBResend[sessionId] = sessionRep
		end
		entity.__net__.rpcCB = {}
	end
	if entity.srvType ~= self.srvType or entity.srvHandle ~= self.srvHandle then
		--跑到这里说明服务端有服务切换了，那么告知一下客户端，可能你需要做写什么处理，比如离开老服务，跑到新服务里面去。
		entity.srvType = self.srvType
		entity.srvHandle = self.srvHandle
		entity.__event__.SwitchService(entity,self.srvType)
		for k,v in ipairs(entity.__net__.waiteToSend) do 
			SendMsg(table.unpack(v))
		end
		entity.__net__.waiteToSend = {}
	end

	--因为是req/rep的模式，所以一旦SwitchConfirm成功就应该开始发送ping
end

function CB:Heartbeat( entity )
	local rpcCBResend = entity.__net__.rpcCBResend
	if rpcCBResend then
		--当发生了切换等待第一次的心跳来了，就做一次发送
		for k,v in pairs(rpcCBResend) do
			SendMsg(entity,v.name,v.args,v.bindData,v.callback,v.exception)
		end
		entity.__net__.rpcCBResend = false
	end
	print(15,"Heartbeat.sendId:",self.sendId)
	entity.__net__.reciveId = self.sendId
end

--切换账号时需要清理的东西
function Network.clear()
	if pollId then
		scheduler:unscheduleScriptEntry(pollId)
		pollId = false
	end
	ViewManager.closeReconnectWait()

	if next(socketHub) then
		--告诉服务器客户端已经下线
		RPCReq.CloseClient({
			reason = 0
		})
		Network.Poll()
	end

	for k,v in pairs(socketHub) do 
		Network.CloseSocket(k,true,true)
	end
	
	socketHub = {}
	socketArray = {}
	clientSocketHub = {}
	selectErrorTimes = 0
end

function Network.CloseNetCheck(  )
	print(15,"Network.CloseNetCheck(  )")
	pollForCheckSlowNetworkCount = POLL_FOR_CHECK_NOT_INIT
end

_G.RECV = RECV
_G.CB = CB
_G.EXP = EXP
_G.GetRecvId = GetRecvId
_G.RecvType = setmetatable({},{__index=function (t,k) rawset(t,k,k);return k end})

return Network