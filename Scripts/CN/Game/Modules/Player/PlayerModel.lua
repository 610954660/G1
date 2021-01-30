
local BaseModel = require "Game.FMVC.Core.BaseModel"
local PlayerModel = class("PlayerModel", BaseModel)
local HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger"

local MoneyType = GameDef.MoneyType
function PlayerModel:ctor()
	print(33,"PlayerModel ctor")
	self.username = ""
	self.sex = ""
	self.sexStr = ""
	self.level = 1
	self.address = ""
	self.exp = 1
	self.head = 1
	self.headBorder = 1
	self.userid = ""
	self.moneyArr = {}
	self.headInfo = false
	self.firstBattleArray = false
	self.awardData = {}
	self.nameFlag = false
	self.createMS = -1
	self.totalOnlineTime = 0
	self.loginTime = 0 --登陆时间点
	self.TipsNotifyId = false --正在提示的信息
	self.banChatTime=false--禁言时间
	self.lihuiDebugMode = false  --显示所有立绘的对位框
	
	self.menCache = {} --纹理列表(查内存泄漏用)
	
	self.mainShowHeroId = false   --主界面展示的英雄id
	self.boundary = 1--临界之旅轮回数
	self.oppostieDays = false
	self.checkTimer = false
	self.stat = {}  -- 玩家个人统计（类型可以看StatType)-- 充值元宝-- 充值RMB	-- 消费元宝-- 充值物品-- 首次充值金额
	self.dailyStat = {}  -- 玩家每日个人统计（类型可以看StatType)-- 充值元宝-- 充值RMB	-- 消费元宝-- 充值物品-- 首次充值金额
	self.emblemList = {}
	self.tempExp = 0
end

function PlayerModel:init()
	
	
end

function PlayerModel:_initListeners()
	
end


function PlayerModel:setStat(stat)
	if not stat then return end
	for key,v in pairs(stat) do
		self.stat[v.type] = v.value
	end
	Dispatcher.dispatchEvent(EventType.module_check, 13)
end

function PlayerModel:setDailyStat(stat)
	if not stat then return end
	for key,v in pairs(stat) do
		self.dailyStat[v.type] = v.value
	end
	--Dispatcher.dispatchEvent(EventType.module_check, 13)
end

function PlayerModel:updateStat(type, value)
	self.stat[type] = value
	if type == GameDef.StatType.ChargeRmb then  --累充金额可能影响模块开放
		self:sendChargeStatus()
	end
end

function PlayerModel:updateDailyStat(type, value)
	self.dailyStat[type] = value
	if type == GameDef.StatType.ChargeRmb then  --累充金额可能影响模块开放
		self:sendChargeStatus()
	end
end

function PlayerModel:sendChargeStatus()
	GlobalUtil.delayCallOnce("PlayerModel:sendChargeStatus", function()
		Dispatcher.dispatchEvent(EventType.module_check, 13)
		Dispatcher.dispatchEvent(EventType.charge_status_change)
		
	end)
end


function PlayerModel:getDailyStatByType(type)
	return self.dailyStat[type]
end


function PlayerModel:getStatByType(type)
	return self.stat[type]
end

function PlayerModel:startDateCheck()
	if not self.oppostieDays then self.oppostieDays = DateUtil.getOppostieDays() end
	if self.checkTimer then Scheduler.unschedule(self.checkTimer) end
	self.checkTimer = Scheduler.schedule(function()
		local newOppostieDays = DateUtil.getOppostieDays()
		if self.oppostieDays and self.oppostieDays ~= newOppostieDays then
			Dispatcher.dispatchEvent(EventType.module_check)
			Scheduler.scheduleNextFrame(function()
				Dispatcher.dispatchEvent(EventType.module_open_hint)
			end)
		else
			self.oppostieDays = newOppostieDays
		end
	end,5)
	Dispatcher.dispatchEvent(EventType.module_check)
	Scheduler.scheduleNextFrame(function()
		Dispatcher.dispatchEvent(EventType.module_open_hint)
	end)
end

function PlayerModel:getHeadInfo()
	if not self.headInfo then
		local t_hero = DynamicConfigData.t_hero
		self.headInfo = {}
		for k,v in pairs(t_hero) do
			if v.isGet== 1 then
				self.headInfo[k] = {}
				self.headInfo[k].id = k
				self.headInfo[k].image =PathConfiger.getPlayerHead(k)
			end
		end
	end
	return self.headInfo
end


function PlayerModel:getUserHeadURL(id)
	return PathConfiger.getPlayerHead(id)
end


function PlayerModel:updateMoney( keystr,amount )
	local mtype =0 
	if type(keystr) =="string"  then
		local typeStr = StringUtil.capitalize(keystr)
		mtype = MoneyType[typeStr]
		self.moneyArr[mtype] = amount
	else 
		self.moneyArr[keystr] = amount
	end
end

function PlayerModel:getMoneyByType(type)
    return self.moneyArr[type] or 0
end

function PlayerModel:isMoneyEnough(type, total)
    return self:getMoneyByType(type) >= total
end

--判断消耗是否足够
function PlayerModel:checkCostEnough(cost, needTips)
	--print(1, "checkCostEnough")
	--printTable(1,cost)
	if needTips == nil then needTips = true end
	--金钱数量判断
	if cost.type == GameDef.GameResType.Exp then
		if ModelManager.PlayerModel.exp > cost.amount then return true end
		if(needTips) then
			local itemInfo = ItemConfiger.getInfoByCode(cost.code, GameDef.GameResType.Money)
			if #itemInfo.source == 0 then
				RollTips.show(Desc.player_expStr4) 
			else
				ViewManager.open("ItemNotEnoughView", cost)
			end
		end
	elseif cost.type == GameDef.GameResType.Money then
		if self:getMoneyByType(cost.code) >= cost.amount then return true end
		if(needTips) then
			local itemInfo = ItemConfiger.getInfoByCode(cost.code, GameDef.GameResType.Item)
			if #itemInfo.source == 0 then
				local moneyName = Desc["common_moneyType"..cost.code]
				local tips = string.format(Desc.common_notEnough, moneyName)
				RollTips.show(tips) 
			else
				ViewManager.open("ItemNotEnoughView", cost)
			end
		end
	else
		--物品数量判断
		local hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(cost.code)
		if(hasNum >= cost.amount) then return true end
		if(needTips) then
			local itemInfo = ItemConfiger.getInfoByCode(cost.code, GameDef.GameResType.Item)
			if #itemInfo.source == 0 then
				local itemName = itemInfo and itemInfo.name  or Desc.player_expStr5
				local tips = string.format(Desc.common_notEnough, itemName)
				RollTips.show(tips)
			else
				ViewManager.open("ItemNotEnoughView", cost)
			end
		end
	end
end

--判断多个消耗是否够
--costList 消耗列表，格式是{{type = GameDef.GameResType.Item, code = 10000023, amount=1}}
--是否自动出提示 默认为true, 材料不足时，会自动出现材料来源窗口
function PlayerModel:isCostEnough(costList, needTips)
	if needTips == nil then needTips = true end
	for _,v in ipairs(costList) do
		if not self:checkCostEnough(v, needTips) then return false end
	end
	return true
end


--获取总的在线时长
function PlayerModel:getTotalOnlineTime()
	return self.totalOnlineTime + (ServerTimeModel:getServerTime() - self.loginTime)
end

--缓存下老经验
function PlayerModel:setTempExp(  )
	self.tempExp = self.exp
end

function PlayerModel:getTempExp(  )
	return self.tempExp
end


function PlayerModel:haddleLoginData(info)
	printTable(33,info)
	self.userid = info.baseData.playerId
	self.username = info.baseData.name
	self.level = info.baseData.attr.level
	self.loginTime = ServerTimeModel:getServerTime()
	if info.baseData.createMS then
		self.createMS = info.baseData.createMS
	end

	if info.baseData.totalOnlineTime then
		self.totalOnlineTime = info.baseData.totalOnlineTime
	end
	if info.baseData.boundary and info.baseData.boundary.round then
		self.boundary= info.baseData.boundary.round 
	end
	self.banChatTime= info.baseData.banChatTime or 0
	self.head = info.baseData.head
	self.address = info.baseData.city
	self.sex = info.baseData.sex
	self.sexStr = self.sex == 1 and Desc.common_man or Desc.common_women
	self.exp = info.baseData.attr.exp
	self:setTempExp() --缓存数据
	self.nameFlag = info.baseData.nameFlag or false
	self.headBorder = info.baseData.headBorder or 90000001  --如果没有的话，设为默认头像
	if self.headBorder == 0 then self.headBorder = 90000001 end
    --初始化货币
	for k, v in pairs(MoneyType) do
		self.moneyArr[v] = 0
	end

	for k,v in pairs(info.baseData.money or {}) do 
		self:updateMoney(k,v)
	end
	CardLibModel.maxCombat = info.baseData.hero.maxCombat or 0;
	OperatingActivitiesModel:setWarmakesActiveLvAndExp()
end
function PlayerModel:set_awardByType(type,data)
	self.awardData[type] = data
end

function PlayerModel:set_awardData(data)
	if data==false then
		self.awardData[1000000] = false
		return 
	end
	if  data.type==nil then
		data.type=1000000
	end
	self.awardData[data.type] = data
end

function PlayerModel:get_awardData(gamePlayType)
	if gamePlayType==nil then
		gamePlayType=1000000
	end
	local rewardData =  self.awardData[gamePlayType]
	--self.awardData[arrayType] = nil
	return rewardData
end

function PlayerModel:clear( data )
	if self.checkTimer then Scheduler.unschedule(self.checkTimer) end
	self.username = ""
	self.sex = ""
	self.sexStr = ""
	self.level = 1
	self.address = ""
	self.exp = 1
	self.head = 1
	self.userid = ""
	self.moneyArr = {}
	self.headInfo = false
	self.firstBattleArray = false
	self.awardData = false
	self.nameFlag = false
	self.createMS = -1
	self.totalOnlineTime = 0
	self.loginTime = 0 --登陆时间点
	-- self.boundary= 1
	-- self.banChatTime=false
	self.lihuiDebugMode = false  --显示所有立绘的对位框
	
	self.menCache = {} --纹理列表(查内存泄漏用)
	
	self.mainShowHeroId = false   --主界面展示的英雄id
end

function  PlayerModel:getProfessional(heroId)
	local HeroInfo=HeroConfiger.getHeroInfoByID(heroId)
	if HeroInfo then
		local categoryImg = PathConfiger.getCardCategory(HeroInfo.category)
		local professionalImg = PathConfiger.getCardProfessional(HeroInfo.professional)
		local categoryStr = Desc["common_category"..HeroInfo.category]
		local professionalStr = Desc["common_creer"..HeroInfo.professional]
		return categoryStr,professionalStr,categoryImg,professionalImg
	end
	return nil,nil,nil,nil
end

function PlayerModel:setBanChatTime(time)
	self.banChatTime=time
end

function PlayerModel:setBoundaryTime(num)
	self.boundary=num
end

return PlayerModel
