--added by xhd
--系统model层
local BaseModel = require "Game.FMVC.Core.BaseModel"
local FriendModel = class("FriendModel", BaseModel)

local FRIEND_MONEY_TIME_MAX = 20; -- 每天最大领取次数
local FRIEND_MONEY_PER = 10;

function FriendModel:ctor()
	self.dataArr = {}
	self._lastRefreshTime = -1
	self.maxFriendLimit = 50; -- 最大好友数量限制
	self.maxFriendMoneyLimit = 200; -- 每日好友币上限
	self.firendMoneyList = {} -- 已赠送好友币的列表
	self.firendMoneyReceiveList = {} -- 已领取好友币的列表
	self.firendMoneyAcceptList = {} -- 待领取好友币的列表
	self.firendMoneyReceiveTimes = 0 -- 今日领取数量
end

function FriendModel:init( ... )
end


 
function FriendModel:setLastRefreshTime(time)
	self._lastRefreshTime = time
end

function FriendModel:getLastRefreshTime()
	return self._lastRefreshTime
end


--初始化数据
function FriendModel:initData(type,data)
    if not self.dataArr[type] then
    	self.dataArr[type] =  {}
	end
    self.dataArr[type] =  data
	self:updateApplyRed();
end

--玩家信息更新了
function FriendModel:updatePlayerData(data)
	for i,v in ipairs(self.dataArr) do
		local datas = v
		for k,playerData in ipairs(datas) do
			if playerData.playerId == data.playerId then
				datas[k] = playerData
				break
			end
		end
	end
end

function FriendModel:getData( type )
	return self.dataArr[type]
end

function FriendModel:unLockBlack(data )
	for i,v in ipairs(self.dataArr[GameDef.FriendListType.Blacklist]) do
		if v.playerId == data.playerId then
			table.remove(self.dataArr[GameDef.FriendListType.Blacklist],i)
			break
		end
	end
	Dispatcher.dispatchEvent("black_update_list")
end

function FriendModel:addBlack(data)
	if not self.dataArr[GameDef.FriendListType.Blacklist] then
    	self.dataArr[GameDef.FriendListType.Blacklist] =  {}
	end
	table.insert(self.dataArr[GameDef.FriendListType.Blacklist], data)
	Dispatcher.dispatchEvent("black_update_list")
end

function FriendModel: getFriendList()
	local params = {}
	params.type = GameDef.FriendListType.FriendList
	params.onSuccess = function (res )
		if res.type == GameDef.FriendListType.FriendList then
			self:initData(GameDef.FriendListType.FriendList,res.list)
		end 
	end
	RPCReq.Friend_List(params, params.onSuccess)
end

function FriendModel:ApplyToFriend( data )
    if not self.dataArr[GameDef.FriendListType.ApplyList] then
    	self.dataArr[GameDef.FriendListType.ApplyList] =  {}
    end
	local applyList = self.dataArr[GameDef.FriendListType.ApplyList]
	local isExist = false
	for i,v in ipairs(applyList) do
		if v.playerId == data.playerId then
			isExist = true
			break
		end
	end
	
	if(not isExist) then
		table.insert(applyList,data)
		Dispatcher.dispatchEvent("apply_update_list")
		self:updateApplyRed()
	end
end

function FriendModel:updateApplyRed()
	local applyList = self.dataArr[GameDef.FriendListType.ApplyList]
	local hasApply = applyList ~= nil and #applyList > 0
	if self.dataArr[GameDef.FriendListType.FriendList] and #self.dataArr[GameDef.FriendListType.FriendList] >= self.maxFriendLimit then
		hasApply = false;
	elseif (not self.dataArr[GameDef.FriendListType.FriendList]) then
		self:getFriendList();
		hasApply = false;
	end
	RedManager.updateValue("V_FRIEND_APPLY", hasApply)
end

function FriendModel:DeleteApplyToFriend(data)
	if not data then return end
	local applyList = self.dataArr[GameDef.FriendListType.ApplyList]
	if not applyList then return end
    for i,v in ipairs(applyList) do
		if v.playerId == data.playerId then
			table.remove(applyList,i)
			break
		end
	end
	self:updateApplyRed();
	Dispatcher.dispatchEvent("apply_update_list")
end

function FriendModel:JoinFriend( data)
	if not data then return end
    if not self.dataArr[GameDef.FriendListType.FriendList] then
    	self.dataArr[GameDef.FriendListType.FriendList] =  {}
    end
	table.insert(self.dataArr[GameDef.FriendListType.FriendList],data)
	Dispatcher.dispatchEvent("friend_update_list")
	Dispatcher.dispatchEvent("apply_update_list")
	Dispatcher.dispatchEvent("check_update_panel",data)
end

function FriendModel:DeleteFriend( data )
	if not data then return end
	local friendList = self.dataArr[GameDef.FriendListType.FriendList]
	if not friendList then return end
	for i,v in ipairs(friendList) do
		if v.playerId == data.playerId then
			table.remove(friendList,i)
			break
		end
	end
	Dispatcher.dispatchEvent("friend_update_list")
	Dispatcher.dispatchEvent("apply_update_list")
end

--是否我的好友
function FriendModel:IsMyFriend(playerId)
	local friendList = self.dataArr[GameDef.FriendListType.FriendList]
	if not friendList then return end
	for i,v in ipairs(friendList) do
		if v.playerId == playerId then
			return true
		end
	end
end

-- 初始化友情币数据
function FriendModel: initFriendMoneyData(param)
	self.firendMoneyAcceptList = param.firendMoneyAcceptList;
	for k,v in pairs(self.firendMoneyAcceptList) do
		LuaLogE("初始化服务器数据id="..k)
	end
	self.firendMoneyReceiveList = param.firendMoneyReceiveList;
	self.firendMoneyList = param.firendMoneyList;
	self.firendMoneyReceiveTimes = param.firendMoneyReceiveTimes;
	self:checkFriendMoneyRedDot();
end

-- 友情点的状态 0 送 1 领 2 置灰
function FriendModel:getFriendMoneyStatus(playerId)
	-- end
	if (self.firendMoneyAcceptList[playerId] and not self.firendMoneyReceiveList[playerId]) then -- 有接收 没有领  可以领
		return 1
	end
	if (not self.firendMoneyList[playerId]) then -- 没有送  可以送
		return 0
	end
	return 2;
end

-- 赠送给别人 添加到已赠送
function FriendModel:sendFriendMoney(idList)
	if (not idList) then return end
	for _, id in ipairs(idList) do
		self.firendMoneyList[id] = id;
	end
	Dispatcher.dispatchEvent("friend_update_list")
end

-- 添加到已领取
function FriendModel:acceptFriendMoney(idList) 
    for k,v in pairs(self.firendMoneyAcceptList) do
		LuaLogE("原有数组id="..k)
	end
	for _, id in ipairs(idList) do
		self.firendMoneyAcceptList[id] = nil;
		self.firendMoneyReceiveList[id] = id;
		self.firendMoneyReceiveTimes = math.min(self.firendMoneyReceiveTimes + 1, FRIEND_MONEY_TIME_MAX);
	end
	self:checkFriendMoneyRedDot();
	Dispatcher.dispatchEvent("friend_update_list")
end

-- 添加到可领取
function FriendModel:addToAccept(id)
    LuaLogE("单个添加到数组="..id)
	self.firendMoneyAcceptList[id] = id;
	self:checkFriendMoneyRedDot();
	Dispatcher.dispatchEvent("friend_update_list")
end

-- 友情点相关红点
function FriendModel:checkFriendMoneyRedDot()
	RedManager.addMap("V_FRIEND", {"V_FRIEND_MONEY"});
	if ( TableUtil.GetTableLen(self.firendMoneyAcceptList) > 0--self.firendMoneyReceiveTimes < TableUtil.GetTableLen(self.firendMoneyReceiveList)
		and self.firendMoneyReceiveTimes < FRIEND_MONEY_TIME_MAX) then -- 有接收 没有领  可以领
		RedManager.updateValue("V_FRIEND_MONEY", true)
	else
		RedManager.updateValue("V_FRIEND_MONEY", false)
	end
end

--model清除
function FriendModel:clear()

end

return FriendModel