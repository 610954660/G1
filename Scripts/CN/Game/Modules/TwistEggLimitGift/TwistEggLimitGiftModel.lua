
local TwistEggLimitGiftModel = class("TwistEggLimitGiftModel",BaseModel)

function TwistEggLimitGiftModel:ctor()
    self.giftInfo = {}     -- 礼包信息
end

-- # 扭蛋礼包rmb
-- .PActivity_GashaponGift {
-- 	buyRecords		1:*PGashaponBuyRecord(id)		#购买记录
-- }

-- # 扭蛋礼包购买次数
-- .PGashaponBuyRecord {
-- 	id 					1:integer	#奖励id
-- 	buyTimes 			2:integer 	#购买次数 
-- }
function TwistEggLimitGiftModel:initData(data)
    self.giftInfo = data.buyRecords or {}
    self:updateRed()
    Dispatcher.dispatchEvent(EventType.TwistEggLimitGift_refreshPanal)
end

-- 获取礼包数据
function TwistEggLimitGiftModel:getShopData()
    local moduleId = self:getModuleId()
    local giftData = DynamicConfigData.t_CapsuleToysShop[moduleId]
    for k,v in pairs(giftData) do
        local data = self.giftInfo[v.id]
        v.buyTime = v.daylimit
        if data then
            data.buyTimes = data.buyTimes or 0
            v.buyTime = v.buyTime - data.buyTimes
            v.buyTime = v.buyTime < 0 and 0 or v.buyTime
        end
        v.state = 0 -- 没卖完
        if v.buyTime == 0 then
            v.state = 1 -- 卖完了
        end
    end
    local keys = {
        {key = "state",asc=false},
        {key = "id",asc=false},
    }
    TableUtil.sortByMap(giftData,keys)
    return giftData or {}
end

-- 获取模板id
function TwistEggLimitGiftModel:getModuleId()
	local moduleId = 1
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.GashaponGift)
	moduleId = actData and actData.showContent.moduleId or 1
	-- printTable(8848,">>actData>>",actData)
	return moduleId
end

-- 红点更新
function TwistEggLimitGiftModel:updateRed()
    local giftData = self:getShopData()
    local keyArr = {}
    for k,v in pairs(giftData) do
        if v.price == 0 then
            table.insert(keyArr, "V_ACTIVITY_"..GameDef.ActivityType.GashaponGift..v.id)
            break
        end
    end
    RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.GashaponGift, keyArr)

    for k,v in pairs(giftData) do
        if v.price == 0 then
            RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.GashaponGift..v.id , v.buyTime > 0)
            break
        end
    end
end

return TwistEggLimitGiftModel