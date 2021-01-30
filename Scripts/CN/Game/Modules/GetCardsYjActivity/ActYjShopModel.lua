--added by xhd
--异界招募限时商店model层
local ActYjShopModel = class("ActYjShopModel",BaseModel)

function ActYjShopModel:ctor()
    self.giftInfo = {}     -- 礼包信息
    self.redFlag = {}
    --self.checkFlag = false
end

--[[function ActYjShopModel:setCheckFlag(flag)
    self.checkFlag = flag
end

function ActYjShopModel:getCheckFlag()
    return self.checkFlag
end--]]

function ActYjShopModel:initData(activityType, data)
    self.giftInfo[activityType] = data.gift or {}
    self:updateRed(activityType)
    Dispatcher.dispatchEvent(EventType.ActYjShopView_refreshPanal)
end

-- 获取礼包数据
function ActYjShopModel:getShopData(activityType)
    local moduleId = self:getModuleId(activityType)
	local giftData
	if activityType == GameDef.ActivityType.HeroSummonShop then
		giftData = DynamicConfigData.t_HeroSummonShop[moduleId]
	elseif activityType == GameDef.ActivityType.HeroSummonShopDay then
		giftData = DynamicConfigData.t_HeroSummonDayShop[moduleId]
	end
    for k,v in pairs(giftData) do
        local data = self.giftInfo[activityType][v.id]
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
function ActYjShopModel:getModuleId(activityType)
	local moduleId = 1
	local actData = ModelManager.ActivityModel:getActityByType(activityType)
	moduleId = actData and actData.showContent.moduleId or 1
	-- printTable(8848,">>actData>>",actData)
	return moduleId
end

-- 红点更新
function ActYjShopModel:updateRed(activityType)
    local giftData = self:getShopData(activityType)
    if not self.redFlag[activityType] then
        self.redFlag[activityType] = true
        local keyArr = {}
        for k,v in pairs(giftData) do
            if v.price == 0 and v.buyType == 1 then
                table.insert(keyArr, "V_ACTIVITY_"..activityType..v.id)
                break
            end
        end
        RedManager.addMap("V_ACTIVITY_"..activityType, keyArr)
    end

    for k,v in pairs(giftData) do
        if v.price == 0 and v.buyType == 1 then
            RedManager.updateValue("V_ACTIVITY_"..activityType..v.id , v.buyTime > 0)
            break
        end
    end
end

return ActYjShopModel
