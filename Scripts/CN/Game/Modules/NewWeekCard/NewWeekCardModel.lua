local BaseModel = require "Game.FMVC.Core.BaseModel"
local NewWeekCardModel = class("NewWeekCardModel", BaseModel)


function NewWeekCardModel:ctor()
	self.allData = {} 	-- 下推的所有礼包的数据
	self.pageData = {}
end


function NewWeekCardModel:initData(data)
	self.allData = data or {}
	printTable(8848,">>>data>>>",data)
	self:setPageData()
	self:upDateRed()
	Dispatcher.dispatchEvent(EventType.NewWeekCardView_refreshPanal)
end

function NewWeekCardModel:setPageData()
	self.pageData = {}
	local moduleId = self:getModuleId()
	-- print(8848,">>>moduleId>>",moduleId)
	-- local serverOpenDay  = ServerTimeModel:getOpenDay() + 1  -- 开服时间
	for k,v in pairs(self.allData) do
		local data 	   = DynamicConfigData.t_WeekCardNew[v.moduleId]
		-- local openDay 	= v.days[1].openDay
		-- local endDay 	= v.days[1].endDay
		-- if serverOpenDay>=openDay and serverOpenDay <= endDay then
		-- 	table.insert(pageData,v)
		-- end
		if data then
			table.insert(self.pageData,data[v.level])
		end
	end

	local keys = {
		{key = "price",asc = false},
	}
	TableUtil.sortByMap(self.pageData, keys)
end

function NewWeekCardModel:getPageData()
	return self.pageData or {}
end


-- 根据档位获取礼包数据
function NewWeekCardModel:getRewardData(gear)
	local moduleId = self:getModuleId()

	local rewardData = DynamicConfigData.t_WeekCardRewardNew[moduleId][gear]
	local pushData = self.allData[gear] 	-- 下推的礼包数据
	local rewardStatus = {}
	local isBuy = false
	local isShow = false
	if pushData.level then
		rewardStatus = pushData.rewardStatus  -- 0 未领取 1 可领取 2 已领取
		isBuy 	= pushData.isBuy
		isShow 	= pushData.isShow
	end
	-- 还需要判断礼包购买状态以及奖励领取状态
	for k,v in pairs(rewardData) do
		v.state = rewardStatus[k] or 0
	end
	return rewardData
end

-- 根据档位获取礼包购买状态
function NewWeekCardModel:getGiftBuyState(gear)
	local pushData = self.allData[gear] 	-- 下推的礼包数据
	local isBuy = pushData and pushData.isBuy or false
	return isBuy
end

-- 根据档位获取每个礼包的结束时间
function NewWeekCardModel:getGiftEndTime(gear)
	local pushData 	= self.allData[gear] 	-- 下推的礼包数据
	local endTime 	= pushData.endTime or 0
	return endTime
end

-- 根据档位获取每个礼包的开始时间
function NewWeekCardModel:getGiftStartTime(gear)
	local endTime 	= self:getGiftEndTime(gear)
	local startTime = math.floor(endTime/1000) - 86400 * 7
	return startTime
end

function NewWeekCardModel:getModuleId()
	local moduleId = 1
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.NewWeekCard)
	moduleId = actData and actData.showContent.moduleId or 1
	-- printTable(8848,">>actData>>",actData)
	return moduleId
end

function NewWeekCardModel:upDateRed()
	local keyArr1 = {}
	if self.allData then
		for k,v in pairs(self.allData) do
			local keyArr2 = {}
			local gear = v.level
			for i=1,7 do
				table.insert(keyArr2, "V_ACTIVITY_"..GameDef.ActivityType.NewWeekCard..gear .. i)
			end
			table.insert(keyArr1, "V_ACTIVITY_"..GameDef.ActivityType.NewWeekCard..gear)
			RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.NewWeekCard .. gear, keyArr2)
		end
		printTable(8848,">>keyArr1>>>",keyArr1)
		RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.NewWeekCard, keyArr1)
		
		for k,v in pairs(self.allData) do
			local rewardStatus = v.rewardStatus
			local gear = v.level
			printTable(8848,">>.rewardStatus>>",rewardStatus)
			for o,p in pairs(rewardStatus) do
				local state = (p == 1) and true or false
				RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.NewWeekCard.. gear .. o, state)	
			end
		end
	end
end

-- 关闭活动
function NewWeekCardModel:closeActivity()
	print(8848,">>>>>>>>>>>>>>>>>closeActivity>>>>>>>")
	 ActivityModel:speDeleteSeverData(GameDef.ActivityType.AccWeekCard)  
end

return NewWeekCardModel