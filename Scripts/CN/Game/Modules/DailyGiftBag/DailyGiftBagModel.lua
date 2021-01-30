local DailyGiftBagModel = class("DailyGiftBagModel",BaseModel)

function DailyGiftBagModel:ctor()
	self.data = {}
	self.giftCurData = {}  -- 当前显示礼包的数据
end

function DailyGiftBagModel:initData(data)
	-- printTable(8848,"data",data)
	self.data = {}
	self.data = data or {}
	self:redCheck()
	Dispatcher.dispatchEvent(EventType.DailyGiftBagView_refresh)
end

function DailyGiftBagModel:redCheck()
	self:initCurGiftData()
	GlobalUtil.delayCallOnce("DailyGiftBagModel:redCheck",function()
		self:updateRed()
	end, self, 0.1)
end

-- 筛选礼包
function DailyGiftBagModel:initCurGiftData()
	self.giftCurData = {}
	local openDay = ModelManager.ServerTimeModel:getOpenDay() + 1
	local giftData = DynamicConfigData.t_DailyGift
	for i=1,#giftData do
		local data = giftData[i]
		local startDay = data.sellDay[1].type
		local overDay  = data.sellDay[1].value
		if ((openDay >= startDay) and (openDay < overDay)) then
			table.insert(self.giftCurData,data)
		elseif (startDay > overDay) and openDay >= startDay then
			table.insert(self.giftCurData,data)
		end
	end
	--rintTable(8848,"self.giftCurData>>",self.giftCurData)
end

function DailyGiftBagModel:updateRed()
	local dayStr = DateUtil.getOppostieDays()
	local isShow = FileCacheManager.getBoolForKey("DailyGiftBagView_isShow" .. dayStr,false)
	local freeData = false
	if self.data and self.data.recvList and self.data.recvList[1] then
		freeData = self.data.recvList[1]
	end
	local keyArr = {}
	-- local giftData = DynamicConfigData.t_DailyGift
	-- local giftData = self.giftCurData
	for i=1,#self.giftCurData do
		local data = self.giftCurData[i]
		if data.price == 0 then
			table.insert(keyArr,"V_DAILYGIFTBAG" .. data.price)
			break
		end
	end
	RedManager.addMap("V_DAILYGIFTBAG", keyArr)

	for i =1,#self.giftCurData do
		local data = self.giftCurData[i]
		if data.price == 0 then
			RedManager.updateValue("V_DAILYGIFTBAG" .. data.price ,not freeData)
		else
			RedManager.updateValue("V_DAILYGIFTBAG" .. data.price ,false)
		end
	end
	RedManager.updateValue("V_DAILYGIFTBAG", (not isShow) or (not freeData))
end

function DailyGiftBagModel:sortData()
	-- local giftData = {}
	-- giftData = DynamicConfigData.t_DailyGift
	local tempData = {}
	for i=1,#self.giftCurData do
		local data = self.giftCurData[i]
		data.take = 0
		if self.data and self.data.recvList and self.data.recvList[data.giftId] then
			data.take = 1
		end
		table.insert(tempData,data)
	end
	local keys ={
		{key = "take",asc = false},
		{key = "giftId",asc = false},
	}
	TableUtil.sortByMap(tempData, keys)
	-- printTable(8848,"tempData",tempData)
	return tempData
end

function DailyGiftBagModel:loginPlayerDataFinish()
	RPCReq.Welfare_DailyGift_InfoReq({},function(params)
		self.data = {}
		self.data = params.dailyGift
		self:redCheck()
	end)
end

return DailyGiftBagModel