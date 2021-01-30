
local ActATourLimitShopModel = class("ActATourLimitShopModel",BaseModel)

function ActATourLimitShopModel:ctor()
    self.giftInfo = {}     -- 礼包信息
    self.redFlag = false
end

-- #限时商城礼包
-- .PActivity_LimitGift {
-- 	gift 			1:*BuyTimesRecord(id)
-- }

-- #购买次数
-- .BuyTimesRecord {
-- 	id 				1:integer #类型ID
-- 	times 			2:integer #次数
-- }
function ActATourLimitShopModel:initData(data)
    self.giftInfo = data.gift or {}
    self:updateRed()
    Dispatcher.dispatchEvent(EventType.ActATourLimitShop_refreshPanal)
end

-- 获取礼包数据
function ActATourLimitShopModel:getShopData()
    local moduleId = self:getModuleId()
    local giftData = DynamicConfigData.t_ElfOneShop[moduleId]
    for k,v in pairs(giftData) do
        local data = self.giftInfo[v.id]
        v.buyTime = v.times
        if data then
            data.buyTimes = data.times or 0
            v.buyTime = v.buyTime - data.times
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
function ActATourLimitShopModel:getModuleId()
	local moduleId = 1
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.ElfTourShop)
	moduleId = actData and actData.showContent.moduleId or 1
	-- printTable(8848,">>actData>>",actData)
	return moduleId
end

-- 红点更新
function ActATourLimitShopModel:updateRed()
    local giftData = self:getShopData()
    if not self.redFlag then
        self.redFlag = true
        local keyArr = {}
        for k,v in pairs(giftData) do
            if v.price == 0 then
                table.insert(keyArr, "V_ACTIVITY_"..GameDef.ActivityType.ElfTourShop..v.id)
                break
            end
        end
        RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.ElfTourShop, keyArr)
    end

    for k,v in pairs(giftData) do
        if v.price == 0 then
            RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.ElfTourShop..v.id , v.buyTime > 0)
            break
        end
    end
end

return ActATourLimitShopModel
