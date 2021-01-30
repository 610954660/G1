-- added by wyz 
-- 超值礼包
local PremiumGiftModel = class("PremiumGiftModel",BaseModel)


function PremiumGiftModel:ctor()
	self.lastData = false 		--更新前数据
	self.data = false 		-- 初始数据
	self.giftData = false 	-- 礼包数据
	self.tempData = false 	-- 临时数据
	self.refreshRed = false -- 红点刷新
	self.first 		= true
	self.isFirst 	= true
	self.activityEndTime = false -- 整个活动的结束时间

	self.bigGiftEndTime = -1  -- 活动时间最长的礼包的结束时间
end

-- 获取当前档次礼包的数据 
function PremiumGiftModel:initData(data)
	self.lastData = self.data
	self.data = {}
	self.tempData = {}
	self.giftData = {}
	self.data = data
	self.tempData = data.showContent.data
	self:removeEndGift()
	self:getRareNum()
	self:upDateRed()
	-- printTable(999,"超值礼包数据",self.giftData)
	Dispatcher.dispatchEvent(EventType.PremiumGift_UpGiftData)
end


-- 去除已结束的礼包
function PremiumGiftModel:removeEndGift()
	-- self.activityEndTime = math.ceil(self.data.realEndMs /1000)
	for i = 1,#self.tempData do
		local serverTime = ServerTimeModel:getServerTime()  	-- 当前服务器的时间戳(s)
		local data = self.tempData[i]
		local startTime = data.sellStartTime
		local endTime 	= data.sellEndTime
		if self.bigGiftEndTime < data.sellEndTime then
			self.bigGiftEndTime = data.sellEndTime
		end
		if serverTime >= startTime and serverTime < endTime then
			table.insert(self.giftData,self.tempData[i])
		end
	end
	self.activityEndTime = self.bigGiftEndTime
	if (not self.giftData or #self.giftData == 0) then
		ActivityModel:speDeleteSeverData(GameDef.ActivityType.BargainGift) 
	end
end

-- 获取稀有次数
function PremiumGiftModel:getRareNum()
	for i = 1, #self.giftData do
		local data = self.giftData[i]
		for j = 1, #data.giftId do
			local data2 = data.giftId[j]
			if data2.giftMake == 2 then
				data.rareNum = j
				break
			end
		end
	end
end

function PremiumGiftModel:upDateRed()

	for i = 1,#self.giftData do
		local keyArr = {}
		for j = 1,#self.giftData[i].giftId do
			table.insert(keyArr,"V_ACTIVITY_" ..GameDef.ActivityType.BargainGift .. i .. j)
		end
		RedManager.addMap("V_ACTIVITY_" .. GameDef.ActivityType.BargainGift..i, keyArr)
	end

	local keyArr = {}
	for i = 1,#self.giftData do
		table.insert(keyArr,"V_ACTIVITY_" ..GameDef.ActivityType.BargainGift .. i)
	end
	RedManager.addMap("V_ACTIVITY_" .. GameDef.ActivityType.BargainGift, keyArr)

	for i = 1,#self.giftData do
		for j = 1,#self.giftData[i].giftId do
			RedManager.updateValue("V_ACTIVITY_" .. GameDef.ActivityType.BargainGift .. i .. j, false)
		end
	end
	for i = 1,#self.giftData do 
		local number = #self.giftData[i].giftId
		local reqType = self.giftData[i].giftType
		RPCReq.Activity_BargainGift_Info({type = reqType},function(params)
			if params.id == 1 then
				RedManager.updateValue("V_ACTIVITY_" .. GameDef.ActivityType.BargainGift .. i .. params.id, true)
			end
		end)
	end
end


return PremiumGiftModel
