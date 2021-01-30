local WeeklyGiftBagModel = class("WeeklyGiftBagModel",BaseModel)

function WeeklyGiftBagModel:ctor()
	self.data = {}
end

function WeeklyGiftBagModel:initData(data)
	self.data = {}
	self.data = data
	self:redCheck()
	Dispatcher.dispatchEvent(EventType.WeeklyGiftBagView_refresh)
end

function WeeklyGiftBagModel:redCheck()
	GlobalUtil.delayCallOnce("WeeklyGiftBagModel:redCheck",function()
		self:updateRed()
	end, self, 0.1)
end

function WeeklyGiftBagModel:getGiftData()
	local nowWeekNum = ServerTimeModel:getOpenWeek()
	local giftData = {}
	local moduleId = ActivityModel:getModuleIdByActivityType(GameDef.ActivityType.WeekGift)
	local config = DynamicConfigData.t_WeekDayGift[moduleId]
	if config then
		for _,v in pairs(config) do
			if nowWeekNum >= v.sellday[1] and (v.sellday[2] == 0 or nowWeekNum < v.sellday[2]) then
				table.insert(giftData, v)
			end
		end
	end
	return giftData
end

function WeeklyGiftBagModel:updateRed()
	local dayStr = DateUtil.getOppostieDays()
	local isShow = FileCacheManager.getBoolForKey("WeeklyGiftBagView_isShow" .. dayStr,false)
	local freeData = false
	local haveZero = false
	local keyArr = {}
	local giftData = ModelManager.WeeklyGiftBagModel:getGiftData()
	for i=1,#giftData do
		local data = giftData[i]
		if data.price == 0 then
			haveZero = true
			table.insert(keyArr,"V_ACTIVITY_" ..GameDef.ActivityType.WeekGift .. data.price)
			break
		end
	end
	RedManager.addMap("V_ACTIVITY_" .. GameDef.ActivityType.WeekGift, keyArr)

	for i =1,#giftData do
		local data = giftData[i]
		if data.price == 0 then
			if self.data and self.data[data.giftId] and self.data[data.giftId].buyTimes then
				freeData = self.data[data.giftId].buyTimes >= data.buyTimes
			end
			RedManager.updateValue("V_ACTIVITY_" .. GameDef.ActivityType.WeekGift .. data.price ,not freeData)
		else
			RedManager.updateValue("V_ACTIVITY_" .. GameDef.ActivityType.WeekGift .. data.price ,false)
		end
	end
	RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.WeekGift, (not isShow) or (not freeData and haveZero))
end

function WeeklyGiftBagModel:sortData()
	local giftData = {}
	giftData = ModelManager.WeeklyGiftBagModel:getGiftData()
	local tempData = {}
	for i=1,#giftData do
		local data = giftData[i]
		data.take = 0
		if self.data[data.giftId] and self.data[data.giftId] and self.data[data.giftId].buyTimes >= data.buyTimes then
			data.take = 1
		end
		table.insert(tempData,data)
	end
	local keys ={
		{key = "take",asc = false},
		{key = "price",asc = false},
	}
	TableUtil.sortByMap(tempData, keys)
	-- printTable(8848,"tempData",tempData)
	return tempData
end

-- function WeeklyGiftBagModel:loginPlayerDataFinish()
-- 	RPCReq.Welfare_DailyGift_InfoReq({},function(params)
-- 		self.data = {}
-- 		self.data = params.dailyGift
-- 		self:updateRed()
-- 	end)
-- end

return WeeklyGiftBagModel