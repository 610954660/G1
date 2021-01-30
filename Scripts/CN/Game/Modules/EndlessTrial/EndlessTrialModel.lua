-- added by wyz
-- 无尽试炼 数据层

local HeroConfiger 	=	require "Game.ConfigReaders.HeroConfiger"
local EndlessTrialModel = class("EndlessTrialModel",BaseModel)



function EndlessTrialModel:ctor()
	self.trialAllData	= {} 		-- 试炼的所有数据
	self.trialTypeData	= {}		-- 试炼类型数据
	self.raceType 		= false 	-- 当前可挑战的种族试炼类型（其它试炼）
	self.challengeType 	= false 	-- 今天已选择的挑战的类型
	self.helpHeroId 	= false 	-- 当前提供给好友协助的英雄uuid
	self.helperList 	= {} 		-- 当前已选择的好友助战卡牌
	self.rewardData 	= {} 		-- 奖励列表
	self.firstIndex 	= false 	-- 首通奖励索引
	self.myHelpCardList = {} 		-- 我可以提供帮助的所有英雄

	self.level 			= 1 		-- 记录关卡
	self.flagMaxRecord  = false 	-- 记录已经领取日常奖励的最大层数

	self.myAllHeroList 	= {} 		-- 我的所有英雄列表
	self.trialType 		= 1		-- 试炼类型
	self.buff 			= false 	-- buff效果
	self.dailyRewardData  = {} 		-- 日常奖励列表
	self.firstRewardNum = false 	-- 首通奖励个数
	self.modulefirstPass = false 	-- 是不是第一次通关

	self.isFistSkip 	= true 		-- 用于判断是否跳过当前关卡，第一次相等时，可以跳过
	self.fiveOrZero   	= false 
	self.isFighting 	= false 	-- 判断是否在战斗中

	self.helpHeroState 	 = false 	-- 当天是否给过好友协助英雄
	self.result 		= false  	-- 战斗是否胜利
end


--  challengeMap		1:*TopChallengeTypeData(type)	#试炼类型数据
-- 	raceType			2:integer		#当前可挑战的种族试炼类型
-- 	challengeType 		3:integer		#今天已选择的挑战的类型
-- 	helpHeroId			4:string		#当前提供给好友协助的英雄uuid
-- 	helperList			5:*TopChallengeHelperData		#当前已选择的好友助战卡牌
function EndlessTrialModel:initData(data,isCrossDay)
	local dayStr = DateUtil.getOppostieDays()
	if isCrossDay and self.isFighting then
		Dispatcher.dispatchEvent(EventType.EndlessTrial_endRewardTipsView)
		Dispatcher.dispatchEvent(EventType.EndlessTrial_endBuffView)
		ViewManager.close("BattlePrepareView")
		self:endGame()
		RPCReq.TopChallenge_ResetChallenge({})
	end
	self.flagMaxRecord 	= FileCacheManager.getIntForKey("EndlessTrialFirstFight" .. dayStr, -1)

	self.trialAllData 	= data
	self.trialTypeData 	= data.challengeMap
	self.raceType 		= data.raceType
	self.challengeType 	= data.challengeType
	self.helperList 	= data.helperList or {}
	self.helpHeroId 	= data.helpHeroId or ""
	-- print(8848,"data.helpHeroState >>>>>>>>>>>>>>",data.helpHeroState)
	self.helpHeroState 	= data.helpHeroState or false

	self:setFriendHelpHero(data.helperList)
	self:setHelpHeroUid(self.helpHeroId)
	-- printTable(8848,"EndlessTrialModel:initData(data)",data)
	self:upDateRedByType(self.trialTypeData[1].type)
	self:upDateRedByType(self.raceType)
	self:isPass()
	self:isFiveOrZero()
	Dispatcher.dispatchEvent(EventType.EndlessTrial_refreshMainViewPanel)

end

function EndlessTrialModel:getCategoryByType(trialType)
	local categoryData = {}
	if trialType == 1 then
		categoryData = nil
	elseif trialType == 2 then
		categoryData = {4}
	elseif trialType == 3 then
		categoryData = {3}
	elseif trialType == 4 then
		categoryData = {5}
	elseif trialType == 5 then
		categoryData ={1,2}
	end
	return categoryData
end

function EndlessTrialModel:judgType(configType)
    return configType==GameDef.BattleArrayType.TopChallengeCommon
	or configType==GameDef.BattleArrayType.TopChallengeHuman
	or configType==GameDef.BattleArrayType.TopChallengeOrc
	or configType==GameDef.BattleArrayType.TopChallengeMachine
	or configType==GameDef.BattleArrayType.TopChallengeFairy
end


-- 获取当天最大通关数
function EndlessTrialModel:getMaxLevel(trialType)
 	local maxLevel = false
 	maxLevel = self.trialTypeData[trialType].dailyTopLevel
 	return maxLevel
end

-- 获取试炼类型
function EndlessTrialModel:getTrialType()
 	return self.trialType or 1
end

-- 是不是已经通关
function EndlessTrialModel:isPass()
	local maxLevel =  self.trialTypeData[self.trialType].maxLevel
	local curLevel = self.trialTypeData[self.trialType].curLevel

	-- print(8848,"maxLevel>>>>>>>>>>>",maxLevel)
	-- print(8848,"curLevel>>>>>>>>>>>",curLevel)
	self.modulefirstPass = curLevel < maxLevel and true or false

	if maxLevel == curLevel and self.isFistSkip then
		self.modulefirstPass = true
		self.isFistSkip = false
	end
end

-- 判断当前关卡是不是以0或5结尾
function EndlessTrialModel:isFiveOrZero()
	local curLevel = self.trialTypeData[self.trialType].curLevel
	if curLevel ~= 0 then
		self.fiveOrZero = not ((curLevel % 5) == 0)
	end
end



-- 设置试炼类型
function EndlessTrialModel:setTrialType(trialType)
	self.trialType = trialType or 1
end


-- 通过试炼类型获取奖励列表
function EndlessTrialModel:getRewardDataByType(trialType)
	local data = {}
	data = DynamicConfigData.t_TopChallenge
	self.rewardData = {}
	self.rewardData = data[trialType]
	return self.rewardData
end

-- 获取首通奖励列表
function EndlessTrialModel:getFirstRewardDataByType(trialType)
	local data = {}
	data = DynamicConfigData.t_TopChallengefirstReward[trialType]
	return data
end

-- 获取当前显示的首通奖励索引id
function EndlessTrialModel:getCurFirstIndex(level)
	if level > 0 and level <= 5 then
		self.firstIndex = 5
	elseif level > 5 and level <= 10 then
		self.firstIndex = 10
	else
		local bits = level % 10
		local temp = math.floor(level / 10)
		if bits >= 1 and bits <= 5 then
			self.firstIndex = temp * 10 + 5
		elseif bits >= 6 and bits <= 9 then
			self.firstIndex = temp * 10 + 10
		else
			self.firstIndex = temp * 10
		end
	end
	return self.firstIndex
end


-- 获取我英雄列表里 当前种族战力最高的英雄
function EndlessTrialModel:getHeroPowerByCategory(category)
	local heroList = {}
	-- heroList = self:getAllCards()
	heroList = self.myAllHeroList
	for k,v in pairs(heroList) do 
		if v.category == category then
			return v.combat
		end
	end
	return 0
end

function EndlessTrialModel:transText(text)
	text = tostring(text)
	local str = ""
	local len = string.len(text)
	if len > 0 then
		for k = 1, len do
			str = str .. StringUtil.utf8sub(text,k,1)
			if k ~= len then
				str = str .. "\n"
			end
		end

	end

	return str
end


-- 获取阵容id
function EndlessTrialModel:getMonsterIdByLevel(trialType, level)
	local data = {}
	data = self:getRewardDataByType(trialType)
	return data[level].monsterId
end

-- 获取下一关关卡
function EndlessTrialModel:getNextLevelByType(trialType)
	return self.trialTypeData[trialType].curLevel
end


-- 获取试炼的数据
function EndlessTrialModel:getTrialDataByType(type)
	local trialData = {}
	trialData = self.trialTypeData[type]
	return trialData
end


-- 获取首通奖励列表
function EndlessTrialModel:getTrialFirstRewardDataByType(trialType,isFlashBack)
	local rewardData 	= {} 	-- 首通奖励数据
	local trialData 	= {} 	-- 当前试炼类型数据
	local firstRewardFlag = {} 	-- 首通奖励领取记录

	rewardData = self:getFirstRewardDataByType(trialType)
	trialData 	= self.trialTypeData[trialType]
	if not trialData then return end
	firstRewardFlag = trialData.firstReward 
	if not firstRewardFlag then return end					

	local firstRewardList = {}
	local firstIndex = false 	-- 首通奖励索引
	local firstRewardNum  = math.floor(#rewardData/5) 	-- 首通奖励个数
	self.firstRewardNum = 0
	for i = 1,TableUtil.GetTableLen(rewardData) do
		local data = rewardData[i*5]
		table.insert(firstRewardList,data)
	end

	-- 判断是否已领取 or 可领取
	for i = 1,#firstRewardList do
		local data = firstRewardList[i]
		data.states = 2 	-- 进行中
		data.take = 0 	 
		data.finish = 0 		
		if firstRewardFlag[data.level] then
			data.take = 1  -- 已领取
			data.states = 1
		end
		if trialData.maxLevel >= data.level and (not firstRewardFlag[data.level]) then
			data.finish = 1
			data.states = 3
			self.firstRewardNum = self.firstRewardNum + 1
		end
	end

	if isFlashBack and self.firstRewardNum > 0 then
		table.sort( firstRewardList, function(a,b) 
			if a.states > b.states then
				return true
			elseif a.states == b.states then
				if a.states == 3 then
					return a.level > b.level
				else
					return false
				end
			end
			return false
		end)
	else
		local keys ={
			-- {key = "take",asc = false},
			-- {key = "finish",asc = true},
			-- {key = "level",asc = false},
			{key = "states",asc = true},
			{key = "level",asc = false},
		}
		TableUtil.sortByMap(firstRewardList, keys)
	end

	return firstRewardList,self.firstRewardNum
end

-- 获取首通奖励可领取的个数 个数大于10 显示所有可以领取的 否则只显示10个
function EndlessTrialModel:getFirstRewardNum()
	print(999,"self.firstRewardNum",self.firstRewardNum)
 	return self.firstRewardNum > 10 and self.firstRewardNum or 10
end


-- 获取我可以提供帮助的所有英雄
function EndlessTrialModel:getAllCards()
	local myHelpCardList = {}
	local heroList = {}
	heroList = ModelManager.CardLibModel:getAllCards()
	local myHelpHeroId 	= self:getHelpHeroUid()
	local hinfo = DynamicConfigData.t_hero
	for k,v in pairs(heroList) do
		v.category = hinfo[v.code].category
	end
	table.sort( heroList, function(a,b) 
		return a.combat > b.combat
	end) 

	-- printTable(999,"heroList",heroList)
	for k,v in pairs(heroList) do
		if not HeroPalaceModel:isInHeroPalace(v.uuid) then
			table.insert(myHelpCardList,v)
		end
	end
	self.myAllHeroList = {}
	self.myAllHeroList = myHelpCardList

	myHelpCardList = {}
	for k,v in pairs(heroList) do
		if not HeroPalaceModel:isInHeroPalace(v.uuid) then
			if (v.uuid) ~= myHelpHeroId then
				table.insert(myHelpCardList,v)
			end
		end
	end
	-- printTable(999,"myHelpCardList",myHelpCardList)
	return myHelpCardList or {}
end


function EndlessTrialModel:setHelpHeroUid(uuid)
	self.helpHeroId = uuid or self.trialAllData.helpHeroId
end

-- 我提供的支援英雄
function EndlessTrialModel:getHelpHeroUid()
	return self.helpHeroId
end


-- 好友提供给我的英雄
function EndlessTrialModel:getFriendHelpHero()
	-- printTable(999,"self.helperList",self.helperList)
	return self.helperList
end

function EndlessTrialModel:setFriendHelpHero(data)
	-- printTable(999,"data",data)
	self.helperList = data
end

-- 初始化好友英雄列表信息
-- 判断好友提供协助英雄战力是否超过我方同种族英雄战力的120%
function EndlessTrialModel:initFriendHelpHero(hero,isList)
	local heroList = {}
	-- printTable(999,"self.helperList",self.helperList)
	-- printTable(999,"好友提供的英雄",hero)
	for k,v in pairs(hero) do 
		local data 	= v.hero
		local localHeroData = HeroConfiger.getHeroInfoByID(data.code)
		data.protext 		= localHeroData.protext
		data.heroName 		= localHeroData.heroName
		data.professional 	= localHeroData.professional
		data.category 		= localHeroData.category
		local combat 		= self:getHeroPowerByCategory(data.category)
		data.outPower   	= false
		-- LuaLogE("data.combat = " .. data.combat .. "  combat*1.2 = " ..combat*1.2  )
		if data.combat > combat*1.2 then
			data.outPower   = true
		end

		if  self.helperList and #self.helperList > 0 and isList then
			if (self.helperList[1].hero.uuid) ~= (data.uuid ) then
				table.insert(heroList,v)
			end
		else
			table.insert(heroList,v)
		end
	end
	if not isList then
		heroList = {}
		heroList = hero
	end
	table.sort( heroList, function(a,b)
		return a.hero.combat > b.hero.combat
	end)
	return heroList
end


-- 设置上阵英雄
function EndlessTrialModel:setAllInBattle(heroData)
	if not heroData then return end
	local heroList = {}
	for k,v in pairs(heroData) do
		local data = HeroConfiger.getHeroInfoByID(v.code)
		v.category = data.category
	end
	heroList = heroData
	return heroList
end

-- 设置当前关卡
function EndlessTrialModel:setCurrentLevel(isReset)
	if isReset then
		self.level = self.trialTypeData[self.trialType].beginLevel + 1
	else
		self.level = self.level + 1
	end
	print(999,"self.level",self.level)
end

function EndlessTrialModel:getCurrentLevel()
	return self.level
end

-- 设置buff效果
function EndlessTrialModel:setBuffName(buff)
	self.buff = buff
end

function EndlessTrialModel:getBuffName()
	return self.buff
end

-- 根据当前关卡从配置内获取奖励配置
function EndlessTrialModel:setDailyDataReward(currentLevel,result)
	if not result and #self.dailyRewardData ~= 0 then
		return 
	end
	local startLevel = self.trialTypeData[self.trialType].dailyTopLevel
	local dayStr = DateUtil.getOppostieDays()
	-- LuaLogE(">>>>>>>>>>> currentLevel 1 >>"..currentLevel)
	-- LuaLogE(">>>>>>>>>>> startLevel  1>>".. startLevel)
	-- LuaLogE(">>>>>>>>>>> flagMaxRecord  1>>".. self.flagMaxRecord)
	if currentLevel == startLevel  then
		-- LuaLogE(">>>>>>>>>>> currentLevel 2 >>"..currentLevel)
		-- LuaLogE(">>>>>>>>>>> startLevel 2 >>".. startLevel)
		if self.flagMaxRecord >= currentLevel then
			-- LuaLogE(">>>>>>>>>>> self.flagMaxRecord >= currentLevel >>".. self.flagMaxRecord)
			self.dailyRewardData = {}
			return 
		end

		local dailyReward = {}
		local rewardData = {}
		rewardData = self:getRewardDataByType(self.trialType)
		dailyReward = rewardData[currentLevel].dailyReward

		for idx = 1,#dailyReward do
			local data = dailyReward[idx]
			self.dailyRewardData[idx] = self.dailyRewardData[idx] and (self.dailyRewardData[idx]+data.amount) or data.amount
		end
	else
		self.dailyRewardData = {}
	end
end

-- 获取累计奖励列表
function EndlessTrialModel:getCumulativeReward()
	return self.dailyRewardData
end

-- 更新红点
function EndlessTrialModel:upDateRedByType(trialType)
	local rewardAllData = self:getTrialFirstRewardDataByType(trialType)
	if not rewardAllData then return end
	local isFresh = false
	for k,v in pairs(rewardAllData) do
		if v.states == 3 then
			isFresh = true
			break
		end
	end
	if trialType == 1 then
		RedManager.updateValue("V_ENDLESSTRIAL_SYN", isFresh)
	else
		RedManager.updateValue("V_ENDLESSTRIAL_OTH", isFresh)
	end
end

-- 跨天强制结束战斗直接结算
function EndlessTrialModel:endGame()
	-- print(8848,">>>>>>>>>>>>>>>>>>>>>>>> EndlessTrialModel:endGame >>>>>>>>>>>>>")
	Dispatcher.dispatchEvent(EventType.battle_end)
end




return EndlessTrialModel