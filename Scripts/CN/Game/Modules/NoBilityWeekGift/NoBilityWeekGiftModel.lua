local NoBilityWeekGiftModel = class("NoBilityWeekGiftModel",BaseModel)

function NoBilityWeekGiftModel:ctor()
	self.data = {}
	
end

function NoBilityWeekGiftModel:initData(data)
	self.data = {}
	self.data = data
	self:redCheck()
	Dispatcher.dispatchEvent(EventType.NoBilityWeekGiftView_refresh)
end

function NoBilityWeekGiftModel:redCheck()
	GlobalUtil.delayCallOnce("NoBilityWeekGiftModel:redCheck",function()
		self:updateRed()
	end, self, 0.1)
end

function NoBilityWeekGiftModel:getGiftData()
	local nowWeekNum = ServerTimeModel:getOpenWeek() or 0
	local giftData = {}
	local moduleId = ActivityModel:getModuleIdByActivityType(GameDef.ActivityType.NoBilityWeekGift)
	local shopConfig = DynamicConfigData.t_VipShop[moduleId]
	if shopConfig then
		if moduleId then
			for _,v in pairs(shopConfig) do
				if nowWeekNum >= v.sellday[1] and (v.sellday[2] == 0 or nowWeekNum < v.sellday[2]) then
					table.insert(giftData, v)
				end
			end
		end
	end
	return giftData
end

function NoBilityWeekGiftModel:updateRed()
	local dayStr = DateUtil.getOppostieDays()
	local isShow = FileCacheManager.getBoolForKey("NoBilityWeekGiftView_isShow" .. dayStr,false)
	local freeData = false
	local haveZero = false
	local keyArr = {}
	local giftData = ModelManager.NoBilityWeekGiftModel:getGiftData()
	for i=1,#giftData do
		local data = giftData[i]
		if data.price == 0 then
			haveZero = true
			table.insert(keyArr,"V_ACTIVITY_" ..GameDef.ActivityType.NoBilityWeekGift .. data.price)
			break
		end
	end
	RedManager.addMap("V_ACTIVITY_" .. GameDef.ActivityType.NoBilityWeekGift, keyArr)

	for i =1,#giftData do
		local data = giftData[i]
		if data.price == 0 then
			if self.data and self.data[data.giftId] and self.data[data.giftId].buyTimes then
				freeData = self.data[data.giftId].buyTimes >= data.buyTimes
			end
			RedManager.updateValue("V_ACTIVITY_" .. GameDef.ActivityType.NoBilityWeekGift .. data.price ,not freeData)
		else
			RedManager.updateValue("V_ACTIVITY_" .. GameDef.ActivityType.NoBilityWeekGift .. data.price ,false)
		end
	end
	RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.NoBilityWeekGift, (not isShow) or (not freeData and haveZero))
end

function NoBilityWeekGiftModel:sortData()
	local giftData = {}
	giftData = ModelManager.NoBilityWeekGiftModel:getGiftData()
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

-- function NoBilityWeekGiftModel:loginPlayerDataFinish()
-- 	RPCReq.Welfare_DailyGift_InfoReq({},function(params)
-- 		self.data = {}
-- 		self.data = params.dailyGift
-- 		self:updateRed()
-- 	end)
-- end

return NoBilityWeekGiftModel