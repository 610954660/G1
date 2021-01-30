--卡牌获取model层
--added by xhd
local BaseModel = require "Game.FMVC.Core.BaseModel"
local lotteryType = GameDef.HeroLotteryType
local GetCardsModel = class("GetCardsModel", BaseModel)
local gamePlayType = GameDef.GamePlayType.HeroLotteryRare
function GetCardsModel:ctor()
	self.heroLottery = false
	self.curSelectPage = false
	self.useTime = 0
	self.maxTimes = DynamicConfigData.t_limit[gamePlayType].maxTimes
	-- self.pageMapTypeVal = {lotteryType.Normal,lotteryType.Rare,lotteryType.Special,lotteryType.FriendShip,lotteryType.NewPlayer,lotteryType.Up} 
	self.pageMapTypeVal = {lotteryType.Normal,lotteryType.Rare,lotteryType.Special,lotteryType.FriendShip,lotteryType.SeniorVIP} -- 新手暂时屏蔽
	-- self.redType = {"V_GETCARD_NORMAL","V_GETCARD_SENIOR","V_GETCARD_SPECIAL","V_GETCARD_FRIEND","V_GETCARD_NEWPLAYER","V_GETCARD_UP"}
	self.redType = {"V_GETCARD_NORMAL","V_GETCARD_SENIOR","V_GETCARD_SPECIAL","V_GETCARD_FRIEND","V_GETCARD_ALIENLAND"}
	self.tyChangeCatogery = 0
	self.tyChangeUuid = 0

	self.useTimeNew = 0
	self.useTimeUp = 0
	self.useTimeAlien = 0
end

function GetCardsModel:initData( data,limit)
	printTable(1,"data",data,"limit",limit)
	self.heroLottery = data

	if limit and limit.daily and limit.daily[gamePlayType] then
		self.useTime = limit.daily[gamePlayType].times or 0
	end

	if limit and limit.daily and limit.daily[GameDef.GamePlayType.HeroLotteryVIPSenior] then
		self.useTimeAlien = limit.daily[GameDef.GamePlayType.HeroLotteryVIPSenior].times or 0
		print(1,"仙魔次数",self.useTimeAlien)
	end

	if limit and limit.static and limit.static[GameDef.GamePlayType.HeroLotteryNewPlayer] then
		self.useTimeNew = limit.static[GameDef.GamePlayType.HeroLotteryNewPlayer].times or 0
	end

    if limit and limit.static and limit.static[GameDef.GamePlayType.HeroLotteryUp] then
		self.useTimeUp = limit.static[GameDef.GamePlayType.HeroLotteryUp].times or 0
	end

	self:checkRedot()
end

--检测红点
function GetCardsModel:checkRedot( ... )
	-- local cost1 = DynamicConfigData.t_heroLottery[1].cost
	-- local cost2 = DynamicConfigData.t_heroLottery[3].cost
	-- local cost3 = DynamicConfigData.t_heroLottery[21].cost
	for i=1,#self.pageMapTypeVal do
		
		local showRed = false
		 if self:getFreeData(self.pageMapTypeVal[i])>=1 then --如果是免费
			print(1,"checkRedot self.pageMapTypeVal[i]",self.pageMapTypeVal[i])
		 	showRed = true
		-- else
		--     if i == 1 then
		--      if PackModel:getItemsFromAllPackByCode(cost1[1].code) >=cost1[1].amount then
		--      	showRed = true
		--      end
		--    	elseif i==2 then
		--    		if PackModel:getItemsFromAllPackByCode(cost2[1].code) >=cost2[1].amount then
		-- 	     	showRed = true
		-- 	    end
		-- 	elseif i==3 then
		-- 		if PackModel:getItemsFromAllPackByCode(cost2[1].code) >=cost2[1].amount then
		-- 	     	showRed = true
		-- 	    end
		--    	end
		end
		if lotteryType.Special ~=self.pageMapTypeVal[i] then
			if self.pageMapTypeVal[i] == lotteryType.SeniorVIP then
				local isOpen = ModuleUtil.moduleOpen( ModuleId.GetCard_alienLand.id , false )
				if isOpen then
					RedManager.updateValue(self.redType[i], showRed)
				else
					RedManager.updateValue(self.redType[i], false)
				end
			elseif self.pageMapTypeVal[i] == lotteryType.Normal then
				local isOpen = ModuleUtil.moduleOpen( ModuleId.GetCard_Normal.id , false )
				if isOpen then
					RedManager.updateValue(self.redType[i], showRed)
				else
					RedManager.updateValue(self.redType[i], false)
				end
			elseif self.pageMapTypeVal[i] == lotteryType.Rare then
				local isOpen = ModuleUtil.moduleOpen( ModuleId.GetCard_Senior.id , false )
				if isOpen then
					RedManager.updateValue(self.redType[i], showRed)
				else
					RedManager.updateValue(self.redType[i], false)
				end
			else
				RedManager.updateValue(self.redType[i], showRed)
			end
		end
	end
	
	local cost = DynamicConfigData.t_heroLottery[31].cost
	if  ModelManager.PlayerModel:isCostEnough(cost, false) then
		RedManager.updateValue(self.redType[4], true)
	end

	--特异功能红点
	local costty = {{type=3,code= 10000050,amount= 2000,},}
	RedManager.updateValue("V_GETCARD_SPECIAL_1", false)
	if ModuleUtil.hasModuleOpen(ModuleId.GetSpeCards.id) then
		if  ModelManager.PlayerModel:isCostEnough(costty, false) then
			RedManager.updateValue("V_GETCARD_SPECIAL_1", true)
		else
			RedManager.updateValue("V_GETCARD_SPECIAL_1", false)
		end
	end
	Dispatcher.dispatchEvent("update_getCardsView")
end

function GetCardsModel:getColorByCode( code )
	local heroStar = DynamicConfigData.t_hero[code].heroStar
	local resInfo= DynamicConfigData.t_heroResource[heroStar]
	return resInfo.qualityRes
end

--检测是否存在SSR
function GetCardsModel:checkHadSSR( data )
	for i,v in ipairs(data) do
		if v.type == GameDef.GameResType.Hero then
			local code = v.code
			local heroStar = DynamicConfigData.t_hero[code].heroStar
			local resInfo= DynamicConfigData.t_heroResource[heroStar]
			local color = resInfo.qualityRes
			if heroStar==5 and color == 5  then --只有5星才需要弹出详情英雄页面了
				return true
			end
		end
	end
	return false
end


function GetCardsModel:updateLastTime( data )
	-- printTable(1,data)
	if data.type == gamePlayType then
		self.useTime = self.useTime +  data.times
	end

	if data.type == GameDef.GamePlayType.HeroLotteryNewPlayer then
		self.useTimeNew = self.useTimeNew + data.times
	end
	
	if data.type == GameDef.GamePlayType.HeroLotteryUp then
		self.useTimeUp = self.useTimeUp + data.times
	end

	if data.type == GameDef.GamePlayType.HeroLotteryVIPSenior then
		self.useTimeAlien = self.useTimeAlien + data.times
    end

	
	self:checkRedot()
end

function GetCardsModel:getGjLastTime( ... )
	-- return self.maxTimes.."/"..self.useTime
	return self.maxTimes - self.useTime
end

--限时次数
function GetCardsModel:getNewPlayerLastCount( ... )
	local maxTimes = DynamicConfigData.t_limit[GameDef.GamePlayType.HeroLotteryNewPlayer].maxTimes
	return maxTimes - self.useTimeNew 
end

--获取仙魔的剩余次数
function GetCardsModel:getAlienLandLastCount( ... )
	local maxTimes = DynamicConfigData.t_limit[GameDef.GamePlayType.HeroLotteryVIPSenior].maxTimes
	return maxTimes - self.useTimeAlien 
end


--限时时间
function GetCardsModel:getNewPlayerTime( ... )
	local serverTime = self.heroLottery.newPlayerTime/1000
	local time = ServerTimeModel:getServerTime()
	local lasttime = serverTime - time
	if lasttime<=0 then lasttime = 0 end
	return lasttime
end

function GetCardsModel:getUpLastCount( ... )
	local maxTimes = DynamicConfigData.t_limit[GameDef.GamePlayType.HeroLotteryUp].maxTimes
	return maxTimes - self.useTimeUp
end

function GetCardsModel:getUpTime( ... )
	local serverTime = self.heroLottery.UpTime/1000
	local time = ServerTimeModel:getServerTime()
	local lasttime = serverTime - time
	if lasttime<=0 then lasttime = 0 end
	return lasttime
end

--获取幸运值
function GetCardsModel:getLuckyValue( ... )
	-- if self.heroLottery.luckyValue>1000 then
	-- 	self.heroLottery.luckyValue = 1000
	-- end
	return self.heroLottery.luckyValue
end

-- --获取特异卡牌召唤指定卡牌数据
-- function GetCardsModel:getTYAssignHero( )
-- 	return self.heroLottery.assignHero[GameDef.HeroLotteryType.Farplane]        
-- end

function GetCardsModel:getTYprotectCount(type)
	if self.heroLottery.protectCount[type] and self.heroLottery.protectCount[type].value then
		return self.heroLottery.protectCount[type].value
	end
	return 0
end

--或者某个类型的免费次数
function GetCardsModel:getFreeData( type )
	if not self.heroLottery or not self.heroLottery.freeCountMap then return 0 end
	for k,v in pairs(self.heroLottery.freeCountMap) do
	   if(self.heroLottery.freeCountMap[k].type==type) then
	   	  return self.heroLottery.freeCountMap[k].value and self.heroLottery.freeCountMap[k].value or 0
	   end
	end
	return 0
end

function GetCardsModel:setSelectPage( page )
	self.curSelectPage = page
end

function GetCardsModel:getSelectPage( ... )
	return self.curSelectPage
end

function GetCardsModel:getChangeConfigByType(category,star)
   local config = DynamicConfigData.t_HeroTransformConfig[category]
   for k,v in pairs(config) do
   	  if v.heroStar == star then
         return v
   	  end
   end
end

function GetCardsModel:setTyChangeCatogery( category )
	 self.tyChangeCatogery = category
end

function GetCardsModel:getTyChangeCatogery(  )
	 return self.tyChangeCatogery
end

function GetCardsModel:setTyChangeUuid( uuid )
	self.tyChangeUuid = uuid
end

function GetCardsModel:getTyChangeUuid( )
	return self.tyChangeUuid
end

function GetCardsModel:getOffsetById( id )
	local config = DynamicConfigData.t_HeroOffsetConfig[id]
	if  config then
       return {x=config.horizontal,y=config.vertical}
	end
	return nil
end

--获取异界招募的显示配置
function GetCardsModel:getYJZMRewardConfig( moduleId )
	local config = DynamicConfigData.t_WorldSummonShow[moduleId]
	local configArr = {}
	for i,v in ipairs(config) do
		if v.isShow== 1 then
			table.insert(configArr,v.reward[1])
		end
	end
	return  configArr
end

function GetCardsModel:getAllYJZMAllConfig(moduleId)
	return DynamicConfigData.t_WorldSummonShow[moduleId]
end

function GetCardsModel:getYJHeroConfig( moduleId )
	local config = DynamicConfigData.t_WorldSummon[moduleId]
	local configArr = {}
	for k,v in pairs(config) do
		table.insert(configArr,v)
	end
	return  configArr
end

function GetCardsModel:getLotteryChangeConfig( index )
	local arr = {}
	local config =  DynamicConfigData.t_LotteryChance[index]
	if config.fiveStar and config.fiveStar~="" then
		table.insert(arr,{5,config.fiveStar})
	end
	if config.fourStar and config.fourStar~="" then
		table.insert(arr,{4,config.fourStar})
	end
	if config.threeStar and config.threeStar~="" then
		table.insert(arr,{3,config.threeStar})
	end
	return arr,config.lotteryId
end

function GetCardsModel:getLotChangeOne( lotteryId,star)
	local  arr = {}
	local config =  DynamicConfigData.t_LotteryChanceOne
	for i=1,#DynamicConfigData.t_LotteryChanceOne do
		local oneconfig = DynamicConfigData.t_LotteryChanceOne[i]
		if oneconfig.lotteryId == lotteryId and  oneconfig.star == star then
			table.insert(arr,oneconfig)
		end
	end
	return arr
end

return GetCardsModel