--added by xhd
--通用boss活动商城
local ActCommonShopModel = class("ActCommonShopModel",BaseModel)

function ActCommonShopModel:ctor()
    self.giftInfo = {}     -- 礼包信息
end

function ActCommonShopModel:initData(data)
    self.giftInfo = data.gift or {}
    self:updateRed()
    Dispatcher.dispatchEvent(EventType.CommonBossShop_refreshPanal)
end

-- 获取礼包数据
function ActCommonShopModel:getShopData()
    local moduleId = self:getModuleId()
    local giftData = DynamicConfigData.t_HolidayShop[moduleId]
    for k,v in pairs(giftData) do
        local data = self.giftInfo[v.id]
        v.buyTime = v.limit
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
function ActCommonShopModel:getModuleId()
	local moduleId = 1
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HolidayShop)
	moduleId = actData and actData.showContent.moduleId or 1
	-- printTable(8848,">>actData>>",actData)
	return moduleId
end

-- 红点更新
function ActCommonShopModel:updateRed()
    local giftData = self:getShopData()
    local keyArr = {}
    for k,v in pairs(giftData) do
        if v.price == 0 then
            table.insert(keyArr, "V_ACTIVITY_"..GameDef.ActivityType.HolidayShop..v.id)
            break
        end
    end
    RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.HolidayShop, keyArr)

    for k,v in pairs(giftData) do
        if v.price == 0 then
			if #v.cost > 0  then-- and not ModelManager.PlayerModel:isCostEnough(v.cost, false) then
				RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.HolidayShop..v.id, false)
			else
				RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.HolidayShop..v.id, v.buyTime > 0)
			end
        end
    end
end

return ActCommonShopModel
