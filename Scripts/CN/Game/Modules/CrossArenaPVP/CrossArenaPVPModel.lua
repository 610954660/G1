local CrossArenaPVPModel = class("CrossArenaPVP", BaseModel)

local _defTemp = {
	GameDef.BattleArrayType.CrossArenaDefOne,
    GameDef.BattleArrayType.CrossArenaDefTwo,
    GameDef.BattleArrayType.CrossArenaDefThree,
}
local _ackTemp = {
	GameDef.BattleArrayType.CrossArenaAckOne,
    GameDef.BattleArrayType.CrossArenaAckTwo,
    GameDef.BattleArrayType.CrossArenaAckThree,
}
function CrossArenaPVPModel:ctor()
	self.baseMark = 0
	self.myRank = 0
	self.recordIndex = 0
	self._CrossPVPType = {
		_ack = 0,
		_def = 1,
	}
	self.curPVPModule = GameDef.BattleArrayType.CrossArenaAckOne
	self.curPVPType = self._CrossPVPType._ack
	self.battleRecord = false
	self.tempBattleData = {}
	self.heroTempItems = {}
	self.serverList = {}
	self:initListeners()
	self.needPlay = true
	self.severData = false
	self.matchingPlayer = false
	self.rankData = {}
	self.battleNum = 0
	self.usedFreeTimes = 0
	self.dailyReward = false
	self.fightId = DynamicConfigData.t_CrossArenaConfig[1].fightId
	self.likeList = {}
	self.hisRank = 0
	self.likeTimes = 0
	self.lastRankTime = 0
	self.lastMyRankTime = 0
	self.changeTeamHide = {}
	self.haveBattle = false
	self.recordFightMs = false
end
function CrossArenaPVPModel:setBattleNum(data)
	self.battleNum = data or 0
end
function CrossArenaPVPModel:addBattleNum(num)
	self.battleNum = self.battleNum + num
	Dispatcher.dispatchEvent("refresh_CrossArenaView")
end
function CrossArenaPVPModel:getBattleNum()
	return self.battleNum
end
function CrossArenaPVPModel:setRankData(data)
	self.rankData = data or {}
end
function CrossArenaPVPModel:getRankData(data)
	return self.rankData
end
function CrossArenaPVPModel:setNowRank(val)
	self.myRank = val or 0
	--Dispatcher.dispatchEvent("refresh_CrossArenaView")
end
function CrossArenaPVPModel:getNowRank()
	return self.myRank
end
function CrossArenaPVPModel:setHisRank(val)
	self.hisRank = val or 0
	--Dispatcher.dispatchEvent("refresh_CrossArenaView")
end

function CrossArenaPVPModel:getHisRank()
	return self.hisRank
end
-- 判断自己在不在排行榜内
function CrossArenaPVPModel:getMyRankInfo() 
    local myRankInfo = {}
    local inRank = false
    local playerId = tonumber(PlayerModel.userid) 
    for k,v in pairs(self.rankData) do
        if playerId == v.playerId then
            return v,true,k
        end
    end
    return myRankInfo,inRank
end


function CrossArenaPVPModel:getCanHideNum() 
	if self.myRank > 0 and self.myRank <= 20 then
		return 2
	end

	return 1
end

function CrossArenaPVPModel:reqGetRanks(func)
	-- body
	if  ServerTimeModel:getServerTime() - self.lastRankTime > 5 then
		self.lastRankTime = ServerTimeModel:getServerTime()
		RPCReq.Rank_GetRankData({rankType = GameDef.RankType.CrossArenaScore},function(data)
			if next(data) then
				if data.myRankData and next(data.myRankData) then
					--self:setNowRank(data.myRankData.rank)
					self:setBaseMark(data.myRankData.value)
				end
				if data.rankData and next(data.rankData) then
					self:setRankData(data.rankData)
				end
				if func then func(data.rankData) end
			end
		end)
	else
		if func then func(self.rankData) end
	end
end

function CrossArenaPVPModel:reqGetMyRanks(func)
	if  ServerTimeModel:getServerTime() - self.lastMyRankTime > 10 then
		self.lastMyRankTime = ServerTimeModel:getServerTime()
		RPCReq.Rank_GetMyRankData({rankType = GameDef.RankType.CrossArenaScore},function(data)
			printTable(33,"Rank_GetMyRankData call",data)
			self.myRank = data.rankData.rank or 0
			if func then func(self.myRank) end
		end)
	else
		if func then func(self.myRank) end
	end
end


function CrossArenaPVPModel:getPVPEnum()
    if (self.curPVPType == 0) then
        return _ackTemp
    elseif (self.curPVPType == 1) then
        return _defTemp
    end
end
function CrossArenaPVPModel:init()
	self.controller = {}
end
function CrossArenaPVPModel:getConfigByMark()
	for key,value in pairs(DynamicConfigData.t_CrossArenaRankReward) do
		if self.baseMark >= value.minRank  and self.baseMark <= value.maxRank then
			return value
		end
	end
end
function CrossArenaPVPModel:addBaseMark(val)
	self.baseMark = self.baseMark + val
	Dispatcher.dispatchEvent("refresh_CrossArenaView")
end
function CrossArenaPVPModel:setBaseMark(mark)
	self.baseMark = mark or 0
	Dispatcher.dispatchEvent("refresh_CrossArenaView")
end
function CrossArenaPVPModel:getBaseMark()
	return self.baseMark
end
function CrossArenaPVPModel:setSeverHeroTemp(data,type)
	if (data.array) then
		local tb = {}
		tb.arrayType = type
		tb.array = {}
        for uuid,seat in pairs(data.array) do
            local heroInfo = CardLibModel:getHeroByUid(seat.uuid)
			local hero = {}
			hero.uuid = seat.uuid
			hero.code = heroInfo.code
			hero.id = seat.id
            if (heroInfo) then
				tb.array[hero.uuid] = hero
            end
        end
		self.heroTempItems[self.curPVPType][type] = tb
    end
end
function CrossArenaPVPModel:getCurTempForSever()
	if self.curPVPType == self._CrossPVPType._ack then
		self:getAckTemp()
	else
		self:getDefTemp()
	end
end
function CrossArenaPVPModel:loginPlayerDataFinish()
	local severInfo = LoginModel:getServerGroups()
	for key,severList in pairs(severInfo) do
		for k,sever in pairs(severList) do
			self.serverList[sever.server_id] = sever
		end	
	end
	self:getDefTemp()
	self:getAckTemp()
	self:hisRedCheck()
	self:getBaseInfo()
	self:checkRecord()
	local data = FileCacheManager.getStringForKey("CrossArenaPVP_recordTime", "", nil, false)
	self.recordFightMs = 0
	if data ~= "" then
		self.recordFightMs = tonumber(data)
	end
end

function CrossArenaPVPModel:getBaseInfo()
	RPCReq.CrossArena_GetInfo({},function(data)
		if next(data) and next(data.info) then
			self.likeTimes = data.info.likeTimes or 999
			self:setNowRank(data.info.rank)
			self:setBaseMark(data.info.score)
			self:setHisRank(data.info.highRank or 0)
			self:setSeverData(data.info)
			self:setBattleNum(data.info.battleNum)
			self:setUsedFreeTimes(data.info.usedFreeTimes)
			self:setDailyReward(data.info.dailyReward)
			self:setLikeList(data.info.likeList)
			Dispatcher.dispatchEvent("crossArena_timeUpdate")
		end
	end)
end


function CrossArenaPVPModel:setLikeList(tb)
	self.likeList = tb or {}
end
function CrossArenaPVPModel:getLikeList()
	return self.likeList
end
function CrossArenaPVPModel:checkLikeState(id)
	for key,value in pairs(self.likeList) do
		if value == id then
			return true
		end
	end
	return false
end
function CrossArenaPVPModel:setDailyReward(tb)
	self.dailyReward = tb or {}
	self:redCheck()
end
function CrossArenaPVPModel:getDailyReward()
	return self.dailyReward
end
function CrossArenaPVPModel:setUsedFreeTimes(num)
	self.usedFreeTimes = num or 0
	Dispatcher.dispatchEvent("refresh_CrossArenaView")
end
function CrossArenaPVPModel:addUsedFreeTimes(num)
	self.usedFreeTimes = self.usedFreeTimes + num
	Dispatcher.dispatchEvent("refresh_CrossArenaView")
	Dispatcher.dispatchEvent("refresh_crossArenaPVPSlectedView")
end
function CrossArenaPVPModel:getUsedFreeTimes()
	local num = DynamicConfigData.t_CrossArenaConfig[1].freeTimes - self.usedFreeTimes
	if num <= 0 then num = 0 end
	return num
end
function CrossArenaPVPModel:hisRedCheck()
--	RPCReq.CrossArena_GetBattleRecordInfo({},function(data)
--		if next(data) and next(data.record) then
--			local lastTime = FileCacheManager.getStringForKey("CrossArena_GetBattleRecordInfo"..PlayerModel.userid,"")
--			if tonumber(lastTime) then 
--				if tonumber(lastTime) < data.record[#data.record].time then
--					RedManager.updateValue("V_CrossArena_record",true)
--					FileCacheManager.setStringForKey("CrossArena_GetBattleRecordInfo"..PlayerModel.userid,tostring(data.record[#data.record].time))
--				end
--			else
--				FileCacheManager.setStringForKey("CrossArena_GetBattleRecordInfo"..PlayerModel.userid,"0")
--			end
--		end
--	end)
end
function CrossArenaPVPModel:getSeverName(serverId)
	return self.serverList[serverId] and self.serverList[serverId].name or serverId
end
function CrossArenaPVPModel:getAckTemp()
	self.heroTempItems[self._CrossPVPType._ack] = {}
	for key,id in pairs(_ackTemp) do
		self.heroTempItems[self._CrossPVPType._ack][id] = {}
		self.heroTempItems[self._CrossPVPType._ack][id].arrayType = id
		self.heroTempItems[self._CrossPVPType._ack][id].array = {}
		self.heroTempItems[self._CrossPVPType._ack][id].isHide = false
		self.controller[id] = key
	end
	for _, v in ipairs(_ackTemp) do
		self:doHandle(self._CrossPVPType._ack,v)
	end
end
function CrossArenaPVPModel:getDefTemp()
	self.heroTempItems[self._CrossPVPType._def] = {}
	for key,id in pairs(_defTemp) do
		self.heroTempItems[self._CrossPVPType._def][id] = {}
		self.heroTempItems[self._CrossPVPType._def][id].arrayType = id
		self.heroTempItems[self._CrossPVPType._def][id].array = {}
		self.heroTempItems[self._CrossPVPType._def][id].isHide = false
		self.controller[id] = key
	end
	for k, v in ipairs(_defTemp) do
		self:doHandle(self._CrossPVPType._def,v,function()
			local state = false
			for key,value in pairs(self.heroTempItems[self._CrossPVPType._def]) do
				if next(value.array) then
					state = false
				else
					state = true
				end
			end
			RedManager.updateValue("V_CrossArenapvp_defand",state)
		end)
	end
end
function CrossArenaPVPModel:doHandle(type,v,cal)
    local requseInfo = {
        fightId	= self.fightId,
        playerId = 0,
        gamePlay = v,
    }
    local function success(data)
        if (data.array) then
			local tb = {}
			tb.arrayType = v
			tb.array = {}
			local isHide = false
            for uuid,seat in pairs(data.array) do
				local hero = {}
				hero.uuid = seat.uuid
				hero.code = tonumber(seat.uuid)
				hero.id = seat.id
				tb.array[hero.uuid] = hero
				if seat.isHide then
					isHide = true
				end
            end
			tb.isHide = isHide
			self.heroTempItems[type][v] = tb
        end
		if cal then cal() end
    end
    RPCReq.Battle_GetOpponentBattleArray(requseInfo,success)
end
function CrossArenaPVPModel:getPlayerArray(playerId,serverId,gamePlayType,cal)
    local info = {
        playerId = playerId,
        serverId = serverId,
        gamePlayType = gamePlayType
    }
    RPCReq.Battle_QueryPlayerGamePlayInfo(info,function (data)
		Dispatcher.dispatchEvent("CrossPVP_teamInfo",data)
		if cal then
			cal(data)
		end
    end)
end
function CrossArenaPVPModel:checkHeroTypeInTeam(code)
	local index = 0
	
	for key,value in pairs(self:getTypeHeroTempInfo()) do
		for k,v in pairs(value.array) do
			local heroInfo = CardLibModel:getHeroByUid(v.uuid)
			if heroInfo.code == code  then
				for l,s in pairs(self:getPVPEnum()) do
					if s == key then
						return l
					end
				end
			end
		end
	end
	return false
end
function CrossArenaPVPModel:checkHeroInTeam(uuid)

	for key,value in pairs(self.heroTempItems[self.curPVPType]) do
		for k,heroInfo in pairs(value.array) do 
			if heroInfo.uuid == uuid  then
				return self.controller[key]
			end
		end
	end
	return false
end
function CrossArenaPVPModel:setHeroToTeam(seatId,heroInfo,uuid)
	local curHeroTemp = self:getCurHeroTempInfo()
	if not heroInfo then
		for key,heroInfo in pairs(curHeroTemp.array) do
			if heroInfo.uuid == uuid then
				curHeroTemp.array[key] = nil
				break
			end
		end
	else	
		local hero = {}
		hero.uuid = heroInfo.uuid
		hero.code = heroInfo.code
		hero.id = seatId
		curHeroTemp.array[hero.uuid] = hero
	end
	self:checkTeamHasEmpty()
end


function CrossArenaPVPModel:getCurEnumGroup()
	if self.curPVPType == self._CrossPVPType._ack then
		return _ackTemp
	end
	return _defTemp
end
function CrossArenaPVPModel:getCurHeroTempInfo()
	return self.heroTempItems[self.curPVPType][self.curPVPModule]
end

function CrossArenaPVPModel:refrushTypeHeroTempInfo(data)
	self.heroTempItems[self.curPVPType] = data
	self:saveTeamToSever(function()
		Dispatcher.dispatchEvent("battle_CrossChangeTeamType",BattleModel:getBattleConfig().configType)
	end)
end
function CrossArenaPVPModel:getTypeHeroTempInfo(typ,isCopy)
	local typ = typ or self.curPVPType
	return self.heroTempItems[typ]
end
function CrossArenaPVPModel:setCurPVPModule(moduleId)
	self.curPVPModule = moduleId
end
function CrossArenaPVPModel:getCurPVPModule()
	return self.curPVPModule
end
function CrossArenaPVPModel:setCurPVPType(typ)
	self.curPVPType = typ or 0
end
function CrossArenaPVPModel:getCurPVPType()
	return self.curPVPType
end
function CrossArenaPVPModel:setSeverData(data)
	self.severData = next(data) and data or {}
end
function CrossArenaPVPModel:getSeverData()
	return self.severData
end
function CrossArenaPVPModel:isCrossPVPDefType(configType)
	for key,id in pairs(_defTemp) do
		if id == configType then
			return true
		end
	end
	return false
end
function CrossArenaPVPModel:isCrossPVPType(configType)
	for key,id in pairs(_ackTemp) do
		if id == configType then
			return true
		end
	end
	for key,id in pairs(_defTemp) do
		if id == configType then
			return true
		end
	end
	return false
end
function CrossArenaPVPModel:getArrayByType(type)
	return self.heroTempItems[self.curPVPType][type]
end
function CrossArenaPVPModel:clearTypeAllHeroTemp()
	for key,value in pairs(self.heroTempItems[self.curPVPType]) do
		value.array = {}
	end
	for key,v in pairs(self.heroTempItems[self.curPVPType]) do
        BattleModel.__arrayInfos[key] = self:getArrayByType(key)
    end
	Dispatcher.dispatchEvent("battle_CrossPVPrefrush",BattleModel:getBattleConfig().configType)
end
function CrossArenaPVPModel:saveTeamToSever(callBack)
	local tb = {}
	tb.arrays = {}
	for key,value in pairs(self.heroTempItems[self.curPVPType]) do
		if table.nums(value.array) == 0 then
			return RollTips.show(Desc.CrossPVPDesc2)
		end 
		if self.curPVPType == 1 and self.changeTeamHide then
			value.isHide = self.changeTeamHide[key] or false
		end
		table.insert(tb.arrays,value)
	end
	RPCReq.Battle_UpdateArrayMap(tb, function (param)
        if (param) then
            for key,v in pairs(self.heroTempItems[self.curPVPType]) do
                BattleModel.__arrayInfos[key] = self:getArrayByType(key)
            end
            if callBack then callBack() end
        end
	end)
	self.changeTeamHide = {}
	RedManager.updateValue("V_CrossArenapvp_defand",false)
end
function CrossArenaPVPModel:SeatItem_seatInfoUpdate()
	local mapConfig = BattleModel:getBattleConfig()
	if not self:isCrossPVPType(mapConfig.configType) then return end
    local seats = BattleModel:getSeatInfos()
    local array = self:getCurHeroTempInfo().array
    for uuid, d in pairs(array) do
        for _, seat in ipairs(seats) do
            if (seat.uuid == uuid) then
                d.id = seat.seatId
                -- return
            end
        end
    end
end 
function CrossArenaPVPModel:changeHeroTemp(p1,p2)
	if not p1 or not p2 then return false end
	local temp1 = self.heroTempItems[self.curPVPType][p1].array
	local temp2 = self.heroTempItems[self.curPVPType][p2].array
	self.heroTempItems[self.curPVPType][p1].array = temp2
	self.heroTempItems[self.curPVPType][p2].array = temp1
	for key,v in pairs(self.heroTempItems[self.curPVPType]) do
        BattleModel.__arrayInfos[key] = self:getArrayByType(key)
    end

	self:saveTeamToSever(function()
		Dispatcher.dispatchEvent("battle_CrossChangeTeamType",BattleModel:getBattleConfig().configType)
	end)
end
function CrossArenaPVPModel:Battle_BattleRecordData(_, args)
	local arrayType = args.battleData.gamePlayInfo.arrayType
	if not self:isCrossPVPType(arrayType) then return end
	args.battleData.gamePlayInfo.arrayType = GameDef.BattleArrayType.CrossArenaAckOne
	if self.needPlay then
		Dispatcher.dispatchEvent(EventType.Battle_replayRecord,{isRecord = false,battleData = args.battleData})
	end
end
function CrossArenaPVPModel:setNeedPlay(state)
	self.needPlay = state
end
function CrossArenaPVPModel:setBattleData(battleRecord)
	self.needPlay = true
	self.battleRecord = battleRecord
	self.recordIndex = 0
	self:checkNextFight()
end

function CrossArenaPVPModel:checkNextFight(args)
	local fightId =  table.remove(self.battleRecord,1)
	if fightId then 
		self.recordIndex = self.recordIndex + 1
		BattleModel:requestBattleRecord(fightId,nil,GameDef.GamePlayType.CrossArena)
	else
		self.recordIndex = 0
		Dispatcher.dispatchEvent(EventType.battle_end,args)
	end
end
function CrossArenaPVPModel:getRecordIndex()
	return self.recordIndex
end
function CrossArenaPVPModel:fightBegin(baseData)
	self:setCurPVPType(self._CrossPVPType._ack)
	local fightData = {}
	local bttleResult = false
	local reward = {}
	local reslutData = {}
	local battleCall = function (param,args)
		if (param == "cancel") then

		elseif (param == "begin") then
			RPCReq.CrossArena_Challenge({playerId = baseData.playerId,revengeIndex = baseData.logId},function(data)
				reslutData = data.data
				bttleResult = data.data.isWin
				reward = data.data.rewards
				self:setNowRank(data.data.myInfo.rank)
				if data.data.myInfo.rank and data.data.myInfo.rank > 0 and (data.data.myInfo.rank < self.hisRank  or self.hisRank == 0 )then
					self.hisRank = data.data.myInfo.rank
				end
				self:addBaseMark(data.data.addScore)
				local battleRecord = {}
				for key,value in pairs(data.data.recordIds) do
					table.insert(battleRecord,value.recordId)
				end
				self:setBattleData(battleRecord)
				self:addUsedFreeTimes(1)
				self:addBattleNum(1)
				self:redCheck()
			end)	
		elseif (param == "next") then
			if  (args and args.onClickSkip) then
				Dispatcher.dispatchEvent(EventType.battle_end,args)
			else
				self:checkNextFight(args)
			end
		elseif (param == "end") then
			ViewManager.close("CrossArenaPVPSlectedView")
			ViewManager.close("CrossArenaPVPHistoryView")
			if bttleResult then
				ViewManager.open("AwardShowView",{reward = reward})
			end
			local function closefuc()
				
			end
			HigherPvPModel.fightData = {}
			HigherPvPModel.recordIds = reslutData.recordIds
			local info = {
                isWin = bttleResult, 
                ackName = PlayerModel.username,
                defName = baseData.name, 
                ackAddScore = reslutData.addScore, 
                defAddScore = reslutData.adddefScore,
				otherId = baseData.playerId,
				gamePlayType = GameDef.GamePlayType.CrossArena
            }
			ViewManager.open("HigherPvPResultView", info);
			Dispatcher.dispatchEvent("refresh_CrossArenaView")
			self.haveBattle = true
		end
	end
	local args = {
		fightID = self.fightId,
		configType = GameDef.BattleArrayType.CrossArenaAckOne,
		customPrepare = true,
		serverId = baseData.serverId,
		playerId = baseData.playerId
	}
	Dispatcher.dispatchEvent(EventType.battle_requestFunc, battleCall, args)
end

function CrossArenaPVPModel:getMainSubInfo(fun)

	--self:reqGetMyRanks(function(rank) 
		local data = {}
		data.dayTimes = self:getUsedFreeTimes()
		if self.severData then
			data.seasonTime = (self.severData.nextSeasonDt) / 1000 - ServerTimeModel:getServerTime() - 10
		else
			data.seasonTime = 0
		end
		if not self.myRank or self.myRank  == 0 then
			data.rank = Desc.Rank_notInRank
		elseif self.myRank and self.myRank  >999 then
			data.rank = "999+"
		else
			data.rank = self.myRank or 0
		end
		data.red = "V_CrossArenaPVP"
		data.moduleId = ModuleId.CrossArena.id
		fun(data)
	--end)
	
end

function CrossArenaPVPModel:getRobotInfo(playerId,config)
    local conf = config[playerId] 
    local data = false
    if (conf) then
        -- 基本信息
        local baseInfo = {
            head = conf.head,
            level = conf.level,
            name = conf.name,
            playerId = playerId,
            score = conf.score,
            sex = conf.sex,
        }
        -- 队伍信息
        local arrayInfo = {};
        local fightConf = DynamicConfigData.t_fight
        for _, fightId in pairs(conf.fightId) do
            local c = fightConf[fightId];
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
                    if posIndex < 4 then
                        d.id = 10 + posIndex
                    elseif posIndex < 7 then
                        d.id = 20 + posIndex - 3
                    else
                        d.id = 30 + posIndex - 6
                    end
                    table.insert(heroInfos, d);
                end
                local info = {
                    combat = combat,
                    heroInfos = heroInfos,
                    arrayType = fightId
                }
                table.insert(arrayInfo, info)
            end
        end
        data = {
            playerInfo = baseInfo,
            arrayInfo = arrayInfo
        }
    end
    return data
end
function CrossArenaPVPModel:getAIEnemyInfos(playerId,index)
	local data = self:getRobotInfo(playerId,DynamicConfigData.t_CrossArenaRobot)
	return data.arrayInfo[index]
end
function CrossArenaPVPModel:getMatchingPlayer()
	return self.matchingPlayer
end
function CrossArenaPVPModel:setMatchingPlayer(data)
	self.matchingPlayer = data
end

function CrossArenaPVPModel:isAckArrayType(arrayType)
	return arrayType == GameDef.BattleArrayType.CrossArenaAckOne
    or arrayType == GameDef.BattleArrayType.CrossArenaAckTwo
    or arrayType == GameDef.BattleArrayType.CrossArenaAckThree
end

function CrossArenaPVPModel:isDefArrayType(arrayType)
	return arrayType == GameDef.BattleArrayType.CrossArenaDefOne
	or arrayType == GameDef.BattleArrayType.CrossArenaDefTwo
	or arrayType == GameDef.BattleArrayType.CrossArenaDefThree
end

function CrossArenaPVPModel:checkTeamHasEmpty(num)
	--self.curPVPType
	--self.curPVPModule
	local team = self:getPVPEnum()
    for type, data in pairs(team) do
		local curHeroTemp = self.heroTempItems[self.curPVPType][data]
		local key = "CrossArena_teamEmpty"..self.curPVPType..data
        RedManager.updateValue(key, TableUtil.GetTableLen(curHeroTemp.array) < 1);
    end
end

-- 进入玩法保存一遍精灵阵容
function CrossArenaPVPModel:saveElvesBattle(planIndex)
    if TableUtil.GetTableLen(ElvesSystemModel:getElvesEnterData(1)) == 0 and 
    TableUtil.GetTableLen(ElvesSystemModel:getElvesEnterData(2)) == 0 and 
    TableUtil.GetTableLen(ElvesSystemModel:getElvesEnterData(3)) == 0 then
        Dispatcher.dispatchEvent(EventType.ElvesAddTopView_refresh)
        return
    end
    local arrayType = GameDef.BattleArrayType.CrossArenaAckOne
    local saveElvesPlan = function(params)
        if not ModelManager.ElvesSystemModel.arrays[params.data.arrayType] then
            ModelManager.ElvesSystemModel.arrays[params.data.arrayType] = {}
        end
        table.insert(ModelManager.ElvesSystemModel.arrays[params.data.arrayType],params.data)
        -- 刷新界面
        local data = {
            arrayType = arrayType,
            planId    = planIndex,
        }
        ModelManager.ElvesSystemModel.planId[arrayType] = planIndex
        ModelManager.ElvesSystemModel:setMyElvesBattleReqInfo(arrayType,planIndex)
        Dispatcher.dispatchEvent(EventType.ElvesAddTopView_refresh)
    end
    local reqInfo = {
            arrayType = arrayType, -- 阵容类型
            planId    = planIndex, -- 方案id
        }
    RPCReq.Elf_SetArraysPalnId(reqInfo,function(params)
        saveElvesPlan(params)
    end)
    RPCReq.Elf_SetArraysPalnId({arrayType = GameDef.BattleArrayType.CrossArenaAckOne,planId = planIndex,},function(params)
    end)
    RPCReq.Elf_SetArraysPalnId({arrayType = GameDef.BattleArrayType.CrossArenaAckTwo,planId = planIndex,},function(params)
    end)
    RPCReq.Elf_SetArraysPalnId({arrayType = GameDef.BattleArrayType.CrossArenaAckThree,planId = planIndex,},function(params)
    end)
    printTable(8848,">>>>>精灵>>>保存跨服竞技场PVP攻击阵容>>>>>")
end

function CrossArenaPVPModel:canZan()
	return self.likeTimes <  DynamicConfigData.t_CrossArenaConfig[1].likeTimes
end

function CrossArenaPVPModel:setRecordFightMs()
	if RedManager.getTips("V_CrossArenapvp_record") then
		xpcall(function()
			FileCacheManager.setStringForKey("CrossArenaPVP_recordTime", tostring(self.recordFightMs), nil, false)
		end, __G__TRACKBACK__)
	end
end

function CrossArenaPVPModel:checkRecord(fun)
	RPCReq.CrossArena_GetBattleRecordInfo({},function(data)
		local list = {}
		if data.data then
			for key,value in pairs(data.data) do
				table.insert(list,1,value)
				if value.addScore < 0 and value.fightMs > self.recordFightMs then
					self.recordFightMs = value.fightMs
					RedManager.updateValue("V_CrossArenapvp_record",true)
				end
			end
		end
		if fun then
			fun(list)
		end
	end)
end

function CrossArenaPVPModel:redCheck()
	local reward = DynamicConfigData.t_CrossArenaDailyReward
	
	local find = false
	for i=1,#reward do 
		if self:getBattleNum() >= reward[i].time and not self.dailyReward[reward[i].id] then
			find = true
		end
	end

	local time = -1
	if self.severData and self.severData.isTodayOpen then
		time = self.severData.endTime/1000 - ServerTimeModel:getServerTime()
	end

	local haveRank = self.rankData and (self.rankData[1] or self.rankData[2] or self.rankData[3])
	RedManager.updateValue("V_CrossArenapvp_reward",find)
	RedManager.updateValue("V_CrossArenapvp_zan",haveRank and self.likeTimes and self.likeTimes <  DynamicConfigData.t_CrossArenaConfig[1].likeTimes)
	RedManager.updateValue("V_CrossArenapvp_begin",self:getUsedFreeTimes() > 0 and  time > 0 );
end

return CrossArenaPVPModel
