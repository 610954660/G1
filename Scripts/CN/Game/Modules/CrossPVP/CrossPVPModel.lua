local CrossPVPModel = class("CrossPVP", BaseModel)
local HorizonPvpType = require"Configs.GameDef.HorizonPvpType"
local _defTemp = {
	GameDef.BattleArrayType.HorizonPvpDefOne,
    GameDef.BattleArrayType.HorizonPvpDefThree,
    GameDef.BattleArrayType.HorizonPvpDefSix,
}
local _ackTemp = {
	GameDef.BattleArrayType.HorizonPvpAckOne,
    GameDef.BattleArrayType.HorizonPvpAckThree,
    GameDef.BattleArrayType.HorizonPvpAckSix,
}
function CrossPVPModel:ctor()
	self.baseMark = 0
	self.myRank = 0
	self.recordIndex = 0
	self._CrossPVPType = {
		_ack = 0,
		_def = 1,
	}
	self.curPVPModule = GameDef.BattleArrayType.HorizonPvpAckOne
	self.curPVPType = self._CrossPVPType._ack
	self.battleRecord = false
	self.tempBattleData = {}
	self.heroTempItems = {}
	self.serverList = {}
	self:initListeners()
	self.needPlay = true
	self.severData = false
	self.maxNum = DynamicConfigData.t_limit[GameDef.GamePlayType.HorizonPvp].maxTimes
	self.limitNum = 0
	self.matchingPlayer = false
	self.rankData = {}
end
function CrossPVPModel:setRankData(data)
	self.rankData = data
end
function CrossPVPModel:getRankData(data)
	return self.rankData
end
function CrossPVPModel:initLimit(limit)
	if limit and limit.daily then
		local data = limit.daily[GameDef.GamePlayType.HorizonPvp]
		if data then
			self.limitNum = data.times
		end
	end
end
function CrossPVPModel:getBuyNum()
	local config = DynamicConfigData.t_VipPriviligeType[20][VipModel.level]
	local residue = 0
	if config then
		residue = config.effect
		if self.maxNum - self.limitNum < 0 then
			residue = residue + self.maxNum - self.limitNum
		end
		if residue < 0 then
			residue = 0
		end
	end
	return residue
end
function CrossPVPModel:addLimitNum(val)
	self.limitNum = self.limitNum + val
	Dispatcher.dispatchEvent("refresh_CrossView")
end
function CrossPVPModel:setLimitNum(num)
	self.limitNum = num
	Dispatcher.dispatchEvent("refresh_CrossView")
end

function CrossPVPModel:getMainSubInfo(fun)
	local data = {}
	if self:getResidueNum() <= 0 then
		data.dayTimes = self:getBuyNum()
	else
		data.dayTimes = self:getResidueNum()
	end
	data.red = "V_CROSSPVP"
	data.moduleId = ModuleId.CrossPVP.id
	if self.severData then
		data.seasonTime = self.severData.endTtime + 1800  - ServerTimeModel:getServerTime() - 10
	else
		data.seasonTime = 0
	end
	data.rank = self:getNowRank() == 0 and Desc.CrossPVPDesc9 or self:getNowRank()
	fun(data)
end

function CrossPVPModel:getResidueNum()
	local residue = self.maxNum - self.limitNum
	if residue < 0 then
		residue = 0
	end
	return residue
end
function CrossPVPModel:setNowRank(val)
	self.myRank = val
	Dispatcher.dispatchEvent("refresh_CrossView")
end
function CrossPVPModel:getNowRank()
	return self.myRank
end
function CrossPVPModel:getPVPEnum()
    if (self.curPVPType == 0) then
        return _ackTemp
    elseif (self.curPVPType == 1) then
        return _defTemp
    end
end
function CrossPVPModel:init()
	self.controller = {}
end
function CrossPVPModel:getConfigByMark()
	for key,value in pairs(DynamicConfigData.t_HorizonpvpLevel) do
		if self.baseMark >= value.min  and self.baseMark <= value.max then
			return value,key == 1 and nil or DynamicConfigData.t_HorizonpvpLevel[key - 1]
		end
	end
end
function CrossPVPModel:addBaseMark(val)
	self.baseMark = self.baseMark + val
end
function CrossPVPModel:setBaseMark(mark)
	self.baseMark = mark
	Dispatcher.dispatchEvent("refresh_CrossView")
end
function CrossPVPModel:getBaseMark()
	return self.baseMark
end
function CrossPVPModel:setSeverHeroTemp(data,type)
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
function CrossPVPModel:getCurTempForSever()
	if self.curPVPType == self._CrossPVPType._ack then
		self:getAckTemp()
	else
		self:getDefTemp()
	end
end
function CrossPVPModel:loginPlayerDataFinish()
	local severInfo = LoginModel:getServerGroups()
	for key,severList in pairs(severInfo) do
		for k,sever in pairs(severList) do
			self.serverList[sever.server_id] = sever
		end	
	end
	
	self:getDefTemp()
	self:getAckTemp()

	self:hisRedCheck()
end

function CrossPVPModel:get_RankData()
	RPCReq.HorizonPvp_Rank({},function(data)
		if next(data) then
			self:setNowRank(data.myRank)
			self:setBaseMark(data.myScore)
			self:setRankData(data)
		end
	end)
end


function CrossPVPModel:hisRedCheck()
	RPCReq.HorizonPvp_Record({},function(data)
		if next(data) and next(data.record) then
			local lastTime = FileCacheManager.getStringForKey("HorizonPvp_Record"..PlayerModel.userid,"")
			if tonumber(lastTime) then 
				if tonumber(lastTime) < data.record[#data.record].time then
					RedManager.updateValue("V_Crosspvp_record",true)
					FileCacheManager.setStringForKey("HorizonPvp_Record"..PlayerModel.userid,tostring(data.record[#data.record].time))
				end
			else
				FileCacheManager.setStringForKey("HorizonPvp_Record"..PlayerModel.userid,"0")
			end
		end
	end)
end
function CrossPVPModel:getSeverName(serverId)
	return self.serverList[serverId] and self.serverList[serverId].name or serverId
end
function CrossPVPModel:getAckTemp()
	self.heroTempItems[self._CrossPVPType._ack] = {}
	for key,id in pairs(_ackTemp) do
		self.heroTempItems[self._CrossPVPType._ack][id] = {}
		self.heroTempItems[self._CrossPVPType._ack][id].arrayType = id
		self.heroTempItems[self._CrossPVPType._ack][id].array = {}
		self.controller[id] = key
	end
	for _, v in ipairs(_ackTemp) do
		self:doHandle(self._CrossPVPType._ack,v)
	end
end
function CrossPVPModel:getDefTemp()
	self.heroTempItems[self._CrossPVPType._def] = {}
	for key,id in pairs(_defTemp) do
		self.heroTempItems[self._CrossPVPType._def][id] = {}
		self.heroTempItems[self._CrossPVPType._def][id].arrayType = id
		self.heroTempItems[self._CrossPVPType._def][id].array = {}
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
			RedManager.updateValue("V_Crosspvp_defand",state)
		end)
	end
end
function CrossPVPModel:doHandle(type,v,cal)
	local const = self:getConfigByMark()
    local requseInfo = {
        fightId	= const.fightId,
        playerId = 0,
        gamePlay = v,
    }
    local function success(data)
        if (data.array) then
			local tb = {}
			tb.arrayType = v
			tb.array = {}
            for uuid,seat in pairs(data.array) do
				local hero = {}
				hero.uuid = seat.uuid
				hero.code = tonumber(seat.uuid)
				hero.id = seat.id
				tb.array[hero.uuid] = hero
            end
			self.heroTempItems[type][v] = tb
        end
		if cal then cal() end
    end
    RPCReq.Battle_GetOpponentBattleArray(requseInfo,success)
end
function CrossPVPModel:getPlayerArray(playerId,serverId,gamePlayType,cal)
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
function CrossPVPModel:checkHeroTypeInTeam(code)
	local index = 0
	for key,value in pairs(self:getTypeHeroTempInfo()) do
		for k,v in pairs(value.array) do
			if v.code == code  then
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
function CrossPVPModel:checkHeroInTeam(uuid)
	for key,value in pairs(self.heroTempItems[self.curPVPType]) do
		for k,heroInfo in pairs(value.array) do 
			if heroInfo.uuid == uuid  then
				return self.controller[key]
			end
		end
	end
	return false
end
function CrossPVPModel:setHeroToTeam(seatId,heroInfo,uuid)
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
end
function CrossPVPModel:getCurEnumGroup()
	if self.curPVPType == self._CrossPVPType._ack then
		return _ackTemp
	end
	return _defTemp
end
function CrossPVPModel:getCurHeroTempInfo()
	return self.heroTempItems[self.curPVPType][self.curPVPModule]
end

function CrossPVPModel:refrushTypeHeroTempInfo(data)
	self.heroTempItems[self.curPVPType] = data
	self:saveTeamToSever(function()
		Dispatcher.dispatchEvent("battle_CrossChangeTeamType",BattleModel:getBattleConfig().configType)
	end)
end
function CrossPVPModel:getTypeHeroTempInfo(typ)
	local typ = typ or self.curPVPType
	return self.heroTempItems[typ]
end
function CrossPVPModel:setCurPVPModule(moduleId)
	self.curPVPModule = moduleId
end
function CrossPVPModel:getCurPVPModule()
	return self.curPVPModule
end
function CrossPVPModel:setCurPVPType(typ)
	self.curPVPType = typ
end
function CrossPVPModel:getCurPVPType()
	return self.curPVPType
end
function CrossPVPModel:setSeverData(data)
	self.severData = next(data) and data or {state = HorizonPvpType.OPEN}
end
function CrossPVPModel:getSeverData()
	return self.severData
end
function CrossPVPModel:isCrossPVPDefType(configType)
	for key,id in pairs(_defTemp) do
		if id == configType then
			return true
		end
	end
	return false
end
function CrossPVPModel:isCrossPVPType(configType)
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
function CrossPVPModel:getArrayByType(type)
	return self.heroTempItems[self.curPVPType][type]
end
function CrossPVPModel:clearTypeAllHeroTemp()
	for key,value in pairs(self.heroTempItems[self.curPVPType]) do
		value.array = {}
	end
	for key,v in pairs(self.heroTempItems[self.curPVPType]) do
        BattleModel.__arrayInfos[key] = self:getArrayByType(key)
    end
	Dispatcher.dispatchEvent("battle_CrossPVPrefrush",BattleModel:getBattleConfig().configType)
end
function CrossPVPModel:saveTeamToSever(callBack)
	local tb = {}
	tb.arrays = {}
	for key,value in pairs(self.heroTempItems[self.curPVPType]) do
		if table.nums(value.array) == 0 then
			return RollTips.show(Desc.CrossPVPDesc2)
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
	RedManager.updateValue("V_Crosspvp_defand",false)
end
function CrossPVPModel:SeatItem_seatInfoUpdate()
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
function CrossPVPModel:changeHeroTemp(p1,p2)
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
function CrossPVPModel:Battle_BattleRecordData(_, args)
	local arrayType = args.battleData.gamePlayInfo.arrayType
	if not self:isCrossPVPType(arrayType) then return end
	if self.needPlay then
		Dispatcher.dispatchEvent(EventType.Battle_replayRecord,{isRecord = false,battleData = args.battleData})
	end
end
function CrossPVPModel:setNeedPlay(state)
	self.needPlay = state
end
function CrossPVPModel:setBattleData(battleRecord)
	self.needPlay = true
	self.battleRecord = battleRecord
	self.recordIndex = 0
	self:checkNextFight()
end

function CrossPVPModel:checkNextFight(args)
	local fightId =  table.remove(self.battleRecord,1)
	if fightId then 
		self.recordIndex = self.recordIndex + 1
		BattleModel:requestBattleRecord(fightId,nil,GameDef.GamePlayType.HorizonPvp)
	else
		self.recordIndex = 0
		Dispatcher.dispatchEvent(EventType.battle_end,args)
	end
end
function CrossPVPModel:getRecordIndex()
	return self.recordIndex
end
function CrossPVPModel:fightBegin(baseData)
	self:setCurPVPType(self._CrossPVPType._ack)
	local fightData = {}
	local bttleResult = false
	local battleCall = function (param,args)
		if (param == "cancel") then

		elseif (param == "begin") then
			RPCReq.HorizonPvp_Battle({},function(data)
				if data.retCode and data.retCode ~= HorizonPvpType.OPEN then return RollTips.show(Desc.CrossPVPDesc23) end
				if not data.score then return  end
				fightData = data
				bttleResult = data.score > 0
				self:addBaseMark(data.score)
				self:setNowRank(data.newRank)
				self:setBattleData(clone(data.battleRecord))
			end)	
		elseif (param == "next") then
			self:checkNextFight(args)
		elseif (param == "end") then
			local reward = clone(ModelManager.PlayerModel:get_awardData(GameDef.GamePlayType.HorizonPvp))
			PlayerModel:set_awardByType(GameDef.GamePlayType.HorizonPvp,{})
			ViewManager.open("AwardShowView",{reward = reward.reward})
			local function closefuc()
				
			end
			ViewManager.open("ReWardView",{
				data = reward or {},
				isWin = bttleResult,
				page = 9,
				closefuc = closefuc,
				fightData = fightData,
				playType = GameDef.GamePlayType.HorizonPvp,
				arrayType = GameDef.BattleArrayType.HorizonPvpAckOne
			})
		end
	end
	local const = self:getConfigByMark()
	local args = {
		fightID = const and const.fightId or 1070000,
		configType = GameDef.BattleArrayType.HorizonPvpAckOne,
		customPrepare = true,
		serverId = baseData.pkInfo.serverId,
		playerId = baseData.playerId
	}
	Dispatcher.dispatchEvent(EventType.battle_requestFunc, battleCall, args)
end
function CrossPVPModel:getRobotInfo(playerId,config)
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
function CrossPVPModel:getAIEnemyInfos(playerId,index)
	local data = self:getRobotInfo(playerId,DynamicConfigData.t_HorizonPvpRobot)
	return data.arrayInfo[index]
end
function CrossPVPModel:getMatchingPlayer()
	return self.matchingPlayer
end
function CrossPVPModel:setMatchingPlayer(data)
	self.matchingPlayer = data
end

-- 进入玩法保存一遍精灵阵容
function CrossPVPModel:saveElvesBattle(planIndex)
    if TableUtil.GetTableLen(ElvesSystemModel:getElvesEnterData(1)) == 0 and 
    TableUtil.GetTableLen(ElvesSystemModel:getElvesEnterData(2)) == 0 and 
    TableUtil.GetTableLen(ElvesSystemModel:getElvesEnterData(3)) == 0 then
        Dispatcher.dispatchEvent(EventType.ElvesAddTopView_refresh)
        return
    end
    local arrayType = GameDef.BattleArrayType.HorizonPvpAckOne
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
    RPCReq.Elf_SetArraysPalnId({arrayType = GameDef.BattleArrayType.HorizonPvpAckOne,planId = planIndex,},function(params)
    end)
    RPCReq.Elf_SetArraysPalnId({arrayType = GameDef.BattleArrayType.HorizonPvpAckThree,planId = planIndex,},function(params)
    end)
    RPCReq.Elf_SetArraysPalnId({arrayType = GameDef.BattleArrayType.HorizonPvpAckSix,planId = planIndex,},function(params)
    end)
    printTable(8848,">>>>>精灵>>>保存天域赛PVP攻击阵容>>>>>")
end
function CrossPVPModel:getTempHeroInfo(heroData)
	local hero = {}
	local config = DynamicConfigData.t_HorizonPvpTotems[heroData.code]
	hero.data = heroData.uuid
	hero.code = heroData.code
	hero.level = heroData.level
	hero.star = heroData.star
	hero.combat = config.combat or 0
	hero.newPassiveSkill = {}
	hero.stage = 10
	for k,v in pairs(config.passiveSkill) do
		local t = {}
		t.index = k
		t.skillId = v
		table.insert(hero.newPassiveSkill,t)
	end
							
	hero.attrs = config.baseAttr or {}
	hero.rune = {} -- 符文
	hero.equipmentMap = {} -- 装备
	for k,v in pairs(config.equipment) do
		local config = DynamicConfigData.t_equipEquipment[v]
		local t = {}
		t.prob = 0
		t.hopeSkill = {}
		t.skill = {}
		t.uuid = ""
		t.power = 0
		t.showSkill = {}
		t.id = k
		t.starExp = 0
		t.code = v
		table.insert(hero.equipmentMap,t)
	end
	return hero
end

function CrossPVPModel:isAckArrayType(arrayType)
	return arrayType == GameDef.BattleArrayType.HorizonPvpAckOne
    or arrayType == GameDef.BattleArrayType.HorizonPvpAckThree
    or arrayType == GameDef.BattleArrayType.HorizonPvpAckSix
end

function CrossPVPModel:isDefArrayType(arrayType)
	return arrayType == GameDef.BattleArrayType.HorizonPvpDefOne
	or arrayType == GameDef.BattleArrayType.HorizonPvpDefThree
	or arrayType == GameDef.BattleArrayType.HorizonPvpDefSix
end
return CrossPVPModel
