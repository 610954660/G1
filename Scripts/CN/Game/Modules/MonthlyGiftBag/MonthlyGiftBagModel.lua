local MonthlyGiftBagModel = class("MonthlyGiftBagModel",BaseModel)

function MonthlyGiftBagModel:ctor()
	self.data = {}
end

function MonthlyGiftBagModel:initData(data)
	self.data = {}
	self.data = data
	self:redCheck()
	Dispatcher.dispatchEvent(EventType.MonthlyGiftBagView_refresh)
end

function MonthlyGiftBagModel:redCheck()
	GlobalUtil.delayCallOnce("MonthlyGiftBagModel:redCheck",function()
		self:updateRed()
	end, self, 0.1)
end

function MonthlyGiftBagModel:updateRed()
	local dayStr = DateUtil.getOppostieDays()
	local isShow = FileCacheManager.getBoolForKey("MonthlyGiftBagView_isShow" .. dayStr,false)
	local freeData = false
	local keyArr = {}
	local giftData = DynamicConfigData.t_MoonGift
	for i=1,#giftData do
		local data = giftData[i]
		if data.price == 0 then
			table.insert(keyArr,"V_ACTIVITY_" ..GameDef.ActivityType.MoonGift .. data.price)
			break
		end
	end
	RedManager.addMap("V_ACTIVITY_" .. GameDef.ActivityType.MoonGift , keyArr)

	for i =1,#giftData do
		local data = giftData[i]
		if data.price == 0 then
			if self.data and self.data[data.giftId] and self.data[data.giftId].buyTimes then
				freeData = self.data[data.giftId].buyTimes >= data.buyTimes
			end
			RedManager.updateValue("V_ACTIVITY_" .. GameDef.ActivityType.MoonGift .. data.price ,not freeData)
		else
			-- freeData = false
			RedManager.updateValue("V_ACTIVITY_" .. GameDef.ActivityType.MoonGift .. data.price ,false)
		end
	end
	RedManager.updateValue("V_ACTIVITY_" .. GameDef.ActivityType.MoonGift, (not isShow) or (not freeData))
end
	
function MonthlyGiftBagModel:sortData()
	local giftData = {}
	giftData = DynamicConfigData.t_MoonGift
	local tempData = {}
	for i=1,#giftData do
		local data = giftData[i]
		data.take = 0
		local isOpen = true
		if data.sellDay then
			local minDay = data.sellDay[1]
			local maxDay = data.sellDay[2]
			local diffDay = ServerTimeModel:getOpenDay() + 1
			if (maxDay == 0 and diffDay < minDay) or (maxDay > 0 and (diffDay < minDay or diffDay > maxDay )) then
				isOpen = false
			end
		end
		
		if self.data and self.data[data.giftId] and self.data[data.giftId].buyTimes and self.data[data.giftId].buyTimes >= data.buyTimes then
			data.take = 1
		end
		if isOpen then
			table.insert(tempData,data)
		end
	end
	local keys ={
		{key = "take",asc = false},
		{key = "price",asc = false},
	}
	TableUtil.sortByMap(tempData, keys)
	-- printTable(8848,"tempData",tempData)
	return tempData
end

-- function MonthlyGiftBagModel:loginPlayerDataFinish()
-- 	RPCReq.Welfare_DailyGift_InfoReq({},function(params)
-- 		self.data = {}
-- 		self.data = params.dailyGift
-- 		self:updateRed()
-- 	end)
-- end

return MonthlyGiftBagModel