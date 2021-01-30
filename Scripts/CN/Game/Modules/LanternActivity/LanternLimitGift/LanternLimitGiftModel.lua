
local LanternLimitGiftModel = class("LanternLimitGiftModel",BaseModel)

function LanternLimitGiftModel:ctor()
    self.giftInfo = {}     -- 礼包信息
    self.flagInfo = {}      -- 记录购买的次数
end

-- # 扭蛋礼包rmb
-- .PActivity_LanternGift {
-- 	buyRecords		1:*PGashaponBuyRecord(id)		#购买记录
-- }

-- # 扭蛋礼包购买次数
-- .PGashaponBuyRecord {
-- 	id 					1:integer	#奖励id
-- 	buyTimes 			2:integer 	#购买次数 
-- }
function LanternLimitGiftModel:initData(data)
    self.giftInfo = data.buyRecords or {}
    self:updateRed()
    Dispatcher.dispatchEvent(EventType.LanternLimitGiftView_refreshPanal)
end

-- 获取礼包数据
function LanternLimitGiftModel:getShopData()
    local moduleId = self:getModuleId()
    local giftData = DynamicConfigData.t_LanternShop[moduleId]
    for k,v in pairs(giftData) do
        local data = self.giftInfo[v.id]
        if not  self.flagInfo[v.id] then
            self.flagInfo[v.id] = {}
        end

        self.flagInfo[v.id].buyTime = v.daylimit

        if data then
            data.buyTimes = data.buyTimes or 0
            self.flagInfo[v.id].buyTime = self.flagInfo[v.id].buyTime - data.buyTimes
            if self.flagInfo[v.id].buyTime < 0 then
                self.flagInfo[v.id].buyTime = 0
            end
        end
        v.state = 0 -- 没卖完
        if self.flagInfo[v.id].buyTime == 0 then
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
function LanternLimitGiftModel:getModuleId()
	local moduleId = 1
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.LanternGift)
	moduleId = actData and actData.showContent.moduleId or 1
	-- printTable(8848,">>actData>>",actData)
	return moduleId
end

-- 红点更新
function LanternLimitGiftModel:updateRed()
    local giftData = self:getShopData()
    local keyArr = {}
    for k,v in pairs(giftData) do
        if v.price == 0 then
            table.insert(keyArr, "V_ACTIVITY_"..GameDef.ActivityType.LanternGift..v.id)
            break
        end
    end
    RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.LanternGift, keyArr)

    for k,v in pairs(giftData) do
        if v.price == 0 then
            local fdata = self.flagInfo[v.id]
            RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.LanternGift..v.id , fdata.buyTime > 0)
            break
        end
    end
end

return LanternLimitGiftModel
