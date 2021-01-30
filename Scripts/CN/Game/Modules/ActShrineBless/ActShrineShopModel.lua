--added by xhd
--神社祈福商店model层
local ActShrineShopModel = class("ActShrineShopModel",BaseModel)

function ActShrineShopModel:ctor()
    self.giftInfo = {}     -- 礼包信息
    self.redFlag = false
    self.checkFlag = false
end

function ActShrineShopModel:setCheckFlag(flag)
    self.checkFlag = flag
end

function ActShrineShopModel:getCheckFlag()
    return self.checkFlag
end

function ActShrineShopModel:initData(data)
    self.giftInfo = data.gift or {}
    self:updateRed()
    Dispatcher.dispatchEvent(EventType.ActShrineShop_refreshPanal)
end

-- 获取礼包数据
function ActShrineShopModel:getShopData()
    local moduleId = self:getModuleId()
    local giftData = DynamicConfigData.t_PrayShop[moduleId]
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
function ActShrineShopModel:getModuleId()
	local moduleId = 1
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.ShrinePrayShop)
	moduleId = actData and actData.showContent.moduleId or 1
	-- printTable(8848,">>actData>>",actData)
	return moduleId
end

-- 红点更新
function ActShrineShopModel:updateRed()
    local giftData = self:getShopData()
    if not self.redFlag then
        self.redFlag = true
        local keyArr = {}
        for k,v in pairs(giftData) do
            if v.price == 0 then
                table.insert(keyArr, "V_ACTIVITY_"..GameDef.ActivityType.ShrinePrayShop..v.id)
                break
            end
        end
        RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.ShrinePrayShop, keyArr)
    end

    for k,v in pairs(giftData) do
        if v.price == 0 then
            RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.ShrinePrayShop..v.id , v.buyTime > 0)
            break
        end
    end
end

return ActShrineShopModel
