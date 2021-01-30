--Date :2021-01-14
--Author : generated by FairyGUI
--Desc : 

local GodMarketModel = class("GodMarket", BaseModel)

function GodMarketModel:ctor()
    self.curConfig = false
    self.mapPos = false     --以x,y为key记录房间格子信息
    self.mapId = {}         --以id为key记录房间格子信息
    self.eventId = {}       --以时间ID为key记录房间格子信息  主要用来做合批
    self.curPeriod = 1      --神虚的期数
    self.moduleId = 1       --活动的期数
    self.serverData = {}    --服务器下发的数据  原数据.PGodMarket_Room
    self.serverGrid = {}    --服务器的格子数据 
    self.PlayerInfo = {}    --房间玩家信息 格子为key
    self.PlayerIdMap = {}   --房间玩家信息 playerId为key
    self.bossInfo = {}      --boss信息
	self.gridBox = {}       --宝箱信息
    self.activityId = 1     --活动ID
    self.contri = 0         --贡献值
    self.actionReward = false --行动奖励
    self.costAction = 1     --每次消耗行动力

    self.eventAllNum = {0,0,0,0,0,0,0,0,0}  --所有格子计数
    self.eventCurNum = {0,0,0,0,0,0,0,0,0}  --所有通关格子计数
    self.curHourGet = 0                     --每小时产量

    self.fightIndex = 0
    self.battleRecord = false
	self.leader = 0             --团长
	self.leaderServerId = 0     --团长服务器ID
	
	self.rankData = false       --排行榜数据
	self.roomId = 0             --当前房间ID
    self.roomMsg = {}           --房间聊天消息
    
    self.flags = false
	self.leader = 0
	self.hasBuyMine = false --是否已经购买宝藏
	self.mineRewardState = false --宝藏奖励列表领取状态
end

function GodMarketModel:init()
    
end


function GodMarketModel:initData()
    
end

--初始化地图数据
function GodMarketModel:initMapData()
    if not self.curConfig then 
        self.curConfig = DynamicConfigData.t_GodMarket[self.moduleId][self.curPeriod]
    end
    self.mapPos = DynamicConfigData.GodMarketMap
    self.mapId =  DynamicConfigData.t_GodMarketEvent[self.moduleId][self.curPeriod]
    self.curHourGet = 0
    self.eventAllNum = {0,0,0,0,0,0,0,0}
    self.eventCurNum = {0,0,0,0,0,0,0,0}
    self.eventId = {}
    for k,v in pairs(self.mapId) do
        for i = 1,#v.position do
           local pos = v.position[i]

            --初始化的可行走区域(eventId == 7)默认为已占领
           local data = {x = pos.x,y = pos.y, eid = v.eventId,id = v.id, d = v}
           self.mapPos[pos.y][pos.x] = data
           if not self.eventId[v.eventId] then
                self.eventId[v.eventId] = {}
           end
           
           table.insert(self.eventId[v.eventId],data)
        end
        
        self.eventAllNum[v.eventId] = self.eventAllNum[v.eventId] + 1
        local gridData = self.serverGrid[v.id]
        if gridData  then
            if v.eventId == 1 or v.eventId == 2 then
                self.curHourGet = self.curHourGet + v.reward1[1].amount
            end
            gridData.eventId = v.eventId
			if gridData.flag == 1 then
				self.eventCurNum[v.eventId] = self.eventCurNum[v.eventId] + 1
			end
        end
    end
    TableUtil.sortByMap(self.eventId[7],{{key = "y", asc = false}})
    TableUtil.sortByMap(self.eventId[1],{{key = "y", asc = false}})
    print(33,"read success ")
end

--判断格子状态  -2为空白区域 -1为障碍物 0为未挑战 1为已挑战（可行走区域）
function GodMarketModel:checkStatus(x,y)
    local yData = self.mapPos[y]
    if not yData then return -2 end
    local data = self.mapPos[y][x]
    if not data or data == 0 then return -2 end
    if not data.id then return -2 end
    if data.eid == 7 then return 1 end
    if data.eid == 6 then return -1 end
    local gridData = self.serverGrid[data.id]
    return   gridData and gridData.flag or 0
end

--判断格子是否可以挑战
function GodMarketModel:isCanChallenge(x,y)
    local data = self.mapPos[y][x]
    --可行走区域和障碍物不可挑战
    if data.eid == 7 or data.eid == 6 then return false end
    --判断上下左右至少有一个是可行走区域才能挑战
    for k,v in pairs(data.d.position) do
        if self:checkStatus(v.x+1,v.y) == 1 then return true end
        if self:checkStatus(v.x-1,v.y) == 1 then return true end
        if self:checkStatus(v.x,v.y+1) == 1 then return true end
        if self:checkStatus(v.x,v.y-1) == 1 then return true end
    end
    return false
    
end

function GodMarketModel:getFightPersent(oldData,nowData,gridData)
    

    local oldHpNum = 1
    local curHpNum = 1
    local maxHpNum = 1
    local oldfightData = oldData and oldData.event and oldData.event and oldData.event.fightData
    local curfightData = nowData.event and nowData.event and nowData.event.fightData
    if oldfightData then
        for k,v in pairs(oldfightData.monster) do
            if v.hp and v.hp > 0 then
                oldHpNum =  v.hp
                maxHpNum =  v.hpMax
                break
            end
        end
    else
        
    end

    if curfightData then
        for k,v in pairs(curfightData.monster) do
            if v.hp and v.hp > 0 then
                curHpNum =  v.hp
                maxHpNum = v.hpMax
                break
            end
        end
    end
    local persent = 0
    if nowData.flag == 1 then
        persent = 100.0*(maxHpNum - oldHpNum)/maxHpNum 
    else
        persent = 100.0*(oldHpNum -curHpNum)/maxHpNum 
    end

    return persent
   --if flag
end

function GodMarketModel:getFightStr()
    if self.fightIndex == 1 and self.battleRecord and #self.battleRecord == 0 then
        return ""
    end
    return string.format(Desc.godmarket_desc12,self.fightIndex)
end

-- 获取模板id
function GodMarketModel:getModuleId()
    if self.moduleId == 1 then
	    local actData = ActivityModel:getActityByType(GameDef.ActivityType.GodMarket)
        self.moduleId = actData and actData.showContent.moduleId or 1
    end
	return self.moduleId
end

-- 获取活动id
function GodMarketModel:getActivityId()

	if self.activityId == 1 then
        local actData = ActivityModel:getActityByType(GameDef.ActivityType.GodMarket)
        self.activityId = actData and actData.id or 1
    end
	return self.activityId
end


--获取排行数据
function GodMarketModel:getRankData(type)
	
	local function success(data)
        printTable(159, "获取排行榜返回", data)
        if data and data.rank then
            Dispatcher.dispatchEvent(EventType.godmarket_rankData, {type = type, data = data.rank})
        end
    end
    local info = {
		roomId = self.roomId, --#string #房间ID
        type = type --1:integer #排行榜类型 1 贡献 2 BOSS伤害
    }
    printTable(159, "获取排行榜", info)
	
	RPCReq.Activity_GodMarket_GetRankData(info, success)
end

--模型移动
function GodMarketModel:moveToXY(obj,x,y,isCoco)
    if not tolua.isnull(obj) then
        local xx = self.mapPos[y][x].posX
        local yy = self.mapPos[y][x].posY
        if isCoco then
            obj:setPosition(xx+40,-yy)
        else
            obj:setPosition(xx+60,yy)
        end
    end
end

--根据key获取坐标 key格式x*10000+y
function GodMarketModel:getXY(pos)
	return math.floor(pos/10000),pos%10000
end

--获取房间消息
function GodMarketModel:getRoomChatMsg(fun)

	RPCReq.Activity_GodMarket_GetRoomChatMsg({roomId = self.roomId},function()
			self.roomMsg = data.msg or {}
			if fun then fun() end
		end)
end

--发送房间消息
function GodMarketModel:sendRoomChatMsg(msg)
	RPCReq.Activity_GodMarket_GetRankData({roomId = self.roomId,msg = msg})
end

--获取收益奖励
function GodMarketModel:getAreaReward(func)
    if self.serverData.newAmount and self.serverData.newAmount > 0 then
        RPCReq.Activity_GodMarket_GetAreaReward({roomId = self.roomId},function(data)
            self.serverData.newAmount = 0
            Dispatcher.dispatchEvent(EventType.godmarket_updatemap)
        end)
    end
end

--一键行动
function GodMarketModel:onekeyAction(num)
    RPCReq.Activity_GodMarket_AllkeyAction({roomId = self.roomId,num = num},function(data)
        self.serverData.action = data.num or 0
        Dispatcher.dispatchEvent("godmarket_updateOneAction")
    end)
end


--集合进攻
function GodMarketModel:setRoomFlagsPos(pos)
    print(33,"setRoomFlagsPos",pos)
	RPCReq.Activity_GodMarket_SetRoomFlagsPos({roomId = self.roomId,pos = pos})
end

--转让团长
function GodMarketModel:transferPosition(userid,serverid)
	RPCReq.Activity_GodMarket_TransferPosition({roomId = self.roomId,toPlayerId = userid,toServerId = serverid})
end


--获取神墟宝藏
function GodMarketModel:getBoxTreasure()
	RPCReq.Activity_GodMarket_GetBoxTreasure({roomId = self.roomId})
end

--领取神墟宝藏
function GodMarketModel:receiveGridBoxTreasure(gridBox)
    printTable(33,"playerMoveGrid",{roomId = self.roomId,pos = gridBox.pos})
    RPCReq.Activity_GodMarket_ReceiveGridBoxReward({roomId = self.roomId,pos = gridBox.pos},function(data)
        if data.ret == 0 then
            self.gridBox[gridBox.pos] = nil
            Dispatcher.dispatchEvent(EventType.godMarket_updateGridBoxData,gridBox,true)
            local x,y = self:getXY(gridBox.pos)
            if  self:checkStatus(x,y) == 1 then
                self:playerMoveGrid(gridBox.pos)
            end
            
        end
    end)
end


--领取boss奖励
function GodMarketModel:receiveGridBossReward(id,func)
    RPCReq.Activity_GodMarket_ReceiveGridBossReward({roomId = self.roomId,id = id},function(data)
        if data.ret == 0 and func then
            func()
        end
    end)
end

--玩家移动格子
function GodMarketModel:playerMoveGrid(pos)
    printTable(33,"playerMoveGrid",{roomId = self.roomId,pos = pos})
	RPCReq.Activity_GodMarket_PlayerMoveGrid({roomId = self.roomId,pos = pos})
end

function GodMarketModel:getActionReward(  )
    if not self.actionReward then
        self.actionReward =  self.curConfig.actionReward
    end

    return self.actionReward
end


function GodMarketModel:getFightArray(fightId,gridData,status)

    -- 队伍信息
    local arrayInfo = {};
    local fightConf = DynamicConfigData.t_fight
    local c = fightConf[fightId];
    local cf = gridData and gridData.event and gridData.event.fightData and gridData.event.fightData.monster or {}
    if (c) then
        local combat = c.monstercombat
        local heroInfos = {}
        for _, posIndex in pairs(c.monsterStand) do
            local d = {
                code = c["monsterId"..posIndex],
                level = c["level"..posIndex],
                star = c["star"..posIndex],
                type = 2
            }
            d.monsterId = d.code
            if posIndex < 4 then
                d.id = 10 + posIndex
            elseif posIndex < 7 then
                d.id = 20 + posIndex - 3
            else
                d.id = 30 + posIndex - 6
            end
            
            if status == nil or status == 2 then
                d.hp = cf[d.id] and cf[d.id].hp or 1
                d.maxHp = cf[d.id] and cf[d.id].hpMax or 1
                d.rage = cf[d.id] and cf[d.id].rage or 0
            elseif status == 1 then
                d.hp =  1
                d.maxHp =  1
                d.rage =  0
            elseif status == 3 then
                d.hp =  0
                d.maxHp =  1
                d.rage =  0
            end
            

            table.insert(heroInfos, d);
        end
        local info = {
            combat = combat,
            heroInfos = heroInfos,
            --arrayType = arrayType
        }
        return info
    end
    
    return false

end

--获取神墟宝藏数据
function GodMarketModel:getMineInfos()
	local params = {}
	params.roomId = self.roomId
	params.onSuccess = function (res )
		--if tolua.isnull(self.view) then return end
		self.hasBuyMine = res.isBuy or false 			--0:boolean #true已经购买
		self.mineRewardState = res.reward 			--1:*PGodMarket_BoxTreasure(id) #神墟宝藏
		Dispatcher.dispatchEvent(EventType.godmarket_mineRewardStateChange)
	end
	RPCReq.Activity_GodMarket_GetBoxTreasure(params, params.onSuccess)	
end

--领取神墟宝藏
function GodMarketModel:getMineListReward(id)
	local params = {}
	params.roomId = self.roomId
	params.id = id
	params.onSuccess = function (res )
		self.mineRewardState = res.reward 			--1:*PGodMarket_BoxTreasure(id) #神墟宝藏
		Dispatcher.dispatchEvent(EventType.godmarket_mineRewardStateChange)
	end
	RPCReq.Activity_GodMarket_ReceiveBoxTreasure(params, params.onSuccess)	
end

--王者之证活动界面数据
function GodMarketModel:getMineListConfigInfo(isSort)
    local temp = {}
    local configInfo = DynamicConfigData.t_GodMarketcard[self:getModuleId()]
    local lingquMap = self.mineRewardState or {}
    for key, value in pairs(configInfo) do
        local info = lingquMap[key] or {}
        local index = true
        if info.state == nil then
            index = true
        else
            index = info.state
        end
        local speciaIndex = true
        if info.buyState == nil then
            speciaIndex = true
        else
            speciaIndex = info.buyState
        end
        if index == false and speciaIndex == false then
            value["getRewardIdex"] = 1
        else
            value["getRewardIdex"] = 0
        end
        temp[#temp + 1] = value
    end
    if isSort == true then
        TableUtil.sortByMap(temp, {{key = "getRewardIdex", asc = false}, {key = "id", asc = false}})
    end
    return temp
end

--##协力兑换商城 兑换
function GodMarketModel:buyItem(type, id, amount)
    local function success(data)
        if data then
            --printTable(5, "#协力兑换商城 兑换成功", data)
            --local itemList = self.CooperationShop[type]["itemList"] or {}
            --itemList[data.id] = {id = data.id, num = data.num}
            --self.CooperationShop[type]["itemList"] = itemList
            Dispatcher.dispatchEvent(EventType.GodMarket_ShopRefresh)
        end
    end
   local reqInfo = {
			activityId = GameDef.ActivityType.GodMarket,
			id = id,
			buyCount = amount,
		}  
    --printTable(5, "#协力兑换商城 兑换", info)
    RPCReq.Activity_NewHeroShop_Buy(reqInfo, success)
end


return GodMarketModel