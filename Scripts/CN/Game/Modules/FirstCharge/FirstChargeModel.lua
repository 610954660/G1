-- added by wyz 
-- 首充礼包
local FirstChargeModel = class("FirstChargeModel",BaseModel)

function FirstChargeModel:ctor()
	-- 当前档次礼包的数据
	self.currentGift = {}
	-- self:updataRed()
end


-- 获取当前档次礼包的数据 包含当前礼包累计充值数量和充值档次类型的表
function FirstChargeModel:getCurrentGiftData(data,endState)
	self.currentGift = data
	self:updataRed(endState)
	Dispatcher.dispatchEvent(EventType.FirstCharge_upGiftData)
end

function FirstChargeModel:updataRed(endState)
	local itemData = DynamicConfigData.t_FirstCharge
	local dataCfg = {6,98}
	local keyArr2 = {}
	for i=1,2 do
		local keyArr =  {}
		for j=1,#itemData[dataCfg[i]] do
			table.insert(keyArr, "V_ACTIVITY_"..GameDef.ActivityType.FirstCharge..i .. j)
		end
		table.insert(keyArr2, "V_ACTIVITY_"..GameDef.ActivityType.FirstCharge..i)
		RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.FirstCharge .. i, keyArr)
	end
	RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.FirstCharge, keyArr2)

	for i = 1,2 do 
		local isRed = false
		for j=1,#itemData[dataCfg[i]] do
			local data 		 = itemData[dataCfg[i]]
			if self.currentGift.accTypeMap[dataCfg[i]] ~= nil then
				local recvMark = self.currentGift.accTypeMap[dataCfg[i]].recvMark
				local flag = bit.band(recvMark, bit.lshift(1, j-1)) > 0
				if (not flag) and data[j].dayIndex <= self.currentGift.accTypeMap[dataCfg[i]].dayIndex and (not endState)  then
					if not isRed then isRed = true end
					RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.FirstCharge.. i .. j, true)
				else
					RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.FirstCharge.. i .. j, false)
				end
			end
		end
	end
end

return FirstChargeModel