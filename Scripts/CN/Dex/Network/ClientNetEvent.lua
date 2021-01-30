--[[
	客户端的一些网络事件响应，都由这里反馈。
	这个文件只是定义一些网络事件，同时这是一个标准的demo，日后客户端要扩展的话就在这几个基础上做扩展。
]]
local NetworkConfiger = require "Dex.Network.NetworkConfiger"
local function DefaultFun( ... )
	error("Net Interface method shoul be defined")
end

---clientNetInterface
--默认的客户端响应事件需要有这么一些接口需要实现并返回，除此以外，客户端跟网络状态相关的细节可以不管了
--客户端是需要显式地调用断开连接接口以断开连接，或者被动式的收到OnCloseEntity表示连接真的断开了。
local clientNetEvent = {
	ConnectError 		= DefaultFun,
	OnConnected 		= DefaultFun,
	InitClientEntity 	= DefaultFun,
	TryRelink 			= DefaultFun,
	RelinkSuccess 		= DefaultFun,
	CloseEntity 		= DefaultFun,
	DefaultExp 			= DefaultFun,
	NetworkCheck 		= DefaultFun,
	NetworkError 		= DefaultFun,
	SwitchService 		= DefaultFun,
	RPCError			= DefaultFun,
	RecvProxy			= DefaultFun,
}

local millisecondNow = cc.millisecondNow or function ( ... )
	return 0--dummy for 
end

---链接错误
--
--@param addr 地址，这个地址会分两种情况，首次链接一般用域名（本地测试除外），之后的重连或者其他情况都会转换成IP
--@param port 端口。
--@param errStr 链接错误信息
--@param isRelink 用于判断是否在重连中做的链接
local Dispatcher = Dispatcher
function clientNetEvent.ConnectError( addr, port, errStr,isRelink )
	Dispatcher.dispatchEvent(EventType.login_show_tips,errStr)
end

---成功首次连接到服务端，
-- 关于机器人，这里做了下思考。机器人可以是完全重复的角色，客户端采用多路复用。
-- @return clientEntity。这个可以相当于玩家数据。或cached数据
function clientNetEvent.InitClientEntity()
	--****例子已经被复写了****

	--给登陆模块发送连接成功信号触发登陆流程。
	return Cache.networkCache
end

--目前没在用了，因为对于这里来说，OnConnect是被封装了，只有收到SwitchServic才表明登陆成功了。
-- ---收到这个表示连接成功，这时候需要调用一些登陆接口。
-- --
-- --@param clientEntity。这个可以相当于玩家数据。或cached数据
function clientNetEvent.OnConnected( clientEntity )
	
end

---检测到断开连接就开始尝试重连
--客户端在这里开始做重连检测策略。如果socket不曾链接成功不会忘这里跑
--
--@param clientEntity。这个可以相当于玩家数据。或cached数据
--@return bool false:表示不用重连了，这个链接失效。失效后会触发CloseEntity
--@return number 0-N : 多少秒后进行重连
function clientNetEvent.TryRelink( clientEntity )
	local relinkInfo = clientEntity.relinkInfo
	if not relinkInfo then
		relinkInfo = {
			lastLinkMillsec = millisecondNow(),
			linkTimes = 0
		}
		clientEntity.relinkInfo = relinkInfo
		ViewManager.showReconnectWait()
		Dispatcher.dispatchEvent(EventType.socket_tryreconnect, relinkInfo.linkTimes)
		--Dispatcher.dispatchEvent(EventType.login_show_tips, Desc.socket_reConnect)
	end

	return relinkInfo.linkTimes <= 5
end

---重连成功,后的处理。
--
--@param clientEntity。这个可以相当于玩家数据。或cached数据
function clientNetEvent.RelinkSuccess( clientEntity )
	ViewManager.closeReconnectWait()
	
		
	--清除重连定时器
	local handle = clientEntity.relinkInfo and clientEntity.relinkInfo.relinkHanle
	if handle then
		Scheduler.unschedule(handle)
	end
	--重连信息置空
	clientEntity.__IN_RELINK = nil
	clientEntity.relinkInfo = nil
	if ModelManager.PushMapModel and ModelManager.PushMapModel:haveBeenPassPoint() <= 10  then
		FlowManager.backToLogin(false,false,true)
		return
	end
	ViewManager.hadShowCloseTips = false
	Alert.closeAll()
	--Dispatcher.dispatchEvent(EventType.mainui_reconnectSuccess)
	print(10,"重连成功!!!")
end

---玩家无法进行重连了，确认链接失效
--一般走到这里就应该执行重登逻辑，同时如果不对clientEntity进行维护，这个数据将会丢失
--
--@param clientEntity。这个可以相当于玩家数据。或cached数据
function clientNetEvent.CloseEntity( clientEntity,initiativeClose )
	LuaLogE("---CloseEntity"..debug.traceback())
	local handle = clientEntity.relinkInfo and clientEntity.relinkInfo.relinkHanle
	if handle then
		print("清除定时器")
		Scheduler.unschedule(handle)
	end
	clientEntity.__IN_RELINK = nil
	clientEntity.relinkInfo = nil
	Dispatcher.dispatchEvent(EventType.socket_disconnect,initiativeClose)
	if not initiativeClose then
		Dispatcher.dispatchEvent(EventType.login_show_tips, Desc.socket_connectFail)
	end
end

---游戏进行中的ping值
--这个值一般通过心跳包或者接口返回的时间来体现，默认是毫秒。
--需要注意一点，这个ping值不能完全反应服务器的情况，因为目前框架下网络处理线程与游戏主线程一致，所以要综合考虑判断服务器的情况。
--
--@param ping 毫秒表示网络延迟，当进行网络重连期间或者网络出现可补救的异常情况时候返回-1
function clientNetEvent.NetworkCheck( ping )
	if ping > 50 then
		print("bad network ping value:",ping)
	end
end

---有网络错误会往这里加
function clientNetEvent.NetworkError( addr, port, errStr, clientEntity )
	print(10,string.format("网络错误 ip:%s, port:%s, msg:%s",addr, port, errStr))
	local Network = require "Dex.Network.Network"
	Network.CloseNetCheck()
	if type(errStr) == "string" and string.find(errStr,"Connection refused") then
		Dispatcher.dispatchEvent(EventType.login_show_tips, Desc.socket_connectFail)
		print(15,"NetworkError,服务器未启动",debug.traceback())
		Network.clear()
	else
		ViewManager.closeGlobalWait()
		print(15,"NetworkError,网络错误",debug.traceback())
		Dispatcher.dispatchEvent(EventType.login_show_tips, Desc.socket_error)	
	end
end

---服务发生切换，这个服务主要是针对服务端，比如登陆切换到login，login 切换到 agent
--可以写成统一的，也可以动态替换。建议写成统一的
function clientNetEvent.SwitchService( clientEntity, newServiceType )
	
end

---RPC请求处理异常。
--
--@param clientEntity。这个可以相当于玩家数据。或cached数据
function clientNetEvent.RPCError( clientEntity, tracebackInfo )
	print("RPCError",tracebackInfo)
end

---接收信息的代理
--对于MVC框架的客户端而言接收网络消息多半在Controller中监听并处理。
--
--@param clientEntity。这个可以相当于玩家数据。或cached数据
--@param rpcData 接收到的网络数据。
--@param response 这个是sproto的response，如果收到了，应该要要在proxy 中自行封装返回内容。
--
--@notice 针对response 这部分，目前的mvc 的时间分发器是不支持response的，因为逻辑上会存在多个模块监听，不可能多个模块返回。
--		  所以这里的例子是需要判断有没有返回事件，如果有应该要抛异常返回给服务端。
--		  但是如果是需要返回的，这时候你可以选着用proxy来接管这个事情。也就是用RECV:***来做，注意者是兼容的。
local RecvType_Login_PlayerData = RecvType.Login_PlayerData
local RecvType_Scene_EnterScene = RecvType.Scene_EnterScene
local ignore = {
	[RecvType.SwitchConfirm] = true,
	[RecvType.Error] = true,
	[RecvType.CloseClient] = true,
	[RecvType.Login_PlayerData] = true,
	[RecvType.Hero_UpdateInfo] = true,
}

--暂时不使用接收代理  已废弃
function clientNetEvent.RecvProxy( tag, clientEntity, rpcData, response,name)
	--[[if tag == RecvType_Scene_EnterScene then
		LuaLogE("收到进入场景" .. tostring(Cache.guideCache.needWaiting))
	end
	if tag == RecvType_Login_PlayerData then
		LuaLogE("收到进入游戏" .. tostring(Cache.guideCache.needWaiting))
	end
	 
	if Cache.guideCache.needWaiting and not ignore[tag] then --收到Login_PlayerData之前所有协议缓存起来
		local msg = {tag = tag, rpcData = rpcData, clientEntity = clientEntity}
		local watingMsg = Cache.guideCache.watingMsg
		watingMsg[#watingMsg + 1] = msg
	else
		local preTime
		if not __IS_RELEASE__ then
			preTime = millisecondNow()
		end
		Dispatcher.dispatchEvent(tag,rpcData,clientEntity)

		if not __IS_RELEASE__ then
			Cache.testCache:addPushdownInfo(name,millisecondNow() - preTime)
			Dispatcher.dispatchEvent("test_protoPushdown")
		end

		if tag == RecvType_Login_PlayerData then
			Cache.guideCache.needWaiting = false
			local watingMsg = Cache.guideCache.watingMsg
			if #watingMsg > 0 then
				for k, v in ipairs(watingMsg) do
				    local preTime
					if not __IS_RELEASE__ then
						preTime = millisecondNow()
					end
					Dispatcher.dispatchEvent(v.tag,v.rpcData,v.clientEntity)

					if not __IS_RELEASE__ then
						Cache.testCache:addPushdownInfo(name,millisecondNow() - preTime)
						Dispatcher.dispatchEvent("test_protoPushdown")
					end
	            end
	            Cache.guideCache.watingMsg = {}
			end
		elseif tag == RecvType.CloseClient then
			 local info = {}
			info.text = "帐号在其他设备登陆"
			info.type = "yes_no"
			info.mask = true
			info.onYes = function()
				--Dispatcher.dispatchEvent(EventType.update_chatClientGuildDivination, nil)
			end
			Alert.show(info)
		end
	end--]]
end

function clientNetEvent.DefaultExp( errorTable)
	--MsgManager.systemException({code = errorTable.repError,what = errorTable.repErrorStr})
	--printTable(33,{code = errorTable.repError,what = errorTable.repErrorStr})
	RollTips.showError(errorTable)
end

return clientNetEvent