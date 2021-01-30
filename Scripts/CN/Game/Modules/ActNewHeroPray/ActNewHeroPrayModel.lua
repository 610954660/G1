--Date :2021-01-28
--Author : added by xhd
--Desc : 新英雄皮肤售卖

local ActNewHeroPrayModel = class("ActNewHeroPrayModel", BaseModel)

function ActNewHeroPrayModel:ctor()
   self.exchangeData = {}
   self.giftInfo = {}
   self.summonData = {}
   self.aniFlag = false
end

function ActNewHeroPrayModel:init()

end

function ActNewHeroPrayModel:getAniFlag()
	self.aniFlag = FileCacheManager.getBoolForKey("actNewHero",false)
	return self.aniFlag
end

function ActNewHeroPrayModel:setAniFlag(flag )
	self.aniFlag = flag
	FileCacheManager.setBoolForKey("actNewHero",self.aniFlag)
end



function ActNewHeroPrayModel:setNewHeroExchangeShopData(data)
    self.exchangeData = data
end

function ActNewHeroPrayModel:getExchangeShopData()
    return self.exchangeData
end

function ActNewHeroPrayModel:setNewHeroSummonShopData(data)
    self.giftInfo = data.gift or {}
    self:updateRed()
    Dispatcher.dispatchEvent(EventType.NewHeroPray_shoprefreshPanal)
end




function ActNewHeroPrayModel:getActData()
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.NewHeroSummonExchange)
	return actData
end

function ActNewHeroPrayModel:setActConvertShopRedFirst() --活动出现红点
    local t_NewHeroStoreConfig = DynamicConfigData.t_NewHeroStoreConfig
    local moduleId = self:getConVertModuleId()
    local showData = t_NewHeroStoreConfig[moduleId]
    local showState = false
    for key,value in pairs(showData) do
        local count = 0
        if self.exchangeData.buyRecords and self.exchangeData.buyRecords[key] then
            count = self.exchangeData.buyRecords[key].count
        end
        local num = ModelManager.PlayerModel:getMoneyByType(value.price[1].code)
        if num > value.price[1].amount and value.reward[1].amount - count > 0 then
            showState = true
            break
        end
    end
    GlobalUtil.delayCallOnce(
    "ActNewHeroPrayModel:setActConvertShopRedFirst",
    function()
        local dayStr = DateUtil.getOppostieDays()
        local isShow = FileCacheManager.getBoolForKey("setActConvertShopRedFirst_isShow" .. dayStr, false)
        RedManager.updateValue("V_ACTIVITY_" .. GameDef.ActivityType.NewHeroSummonExchange, not isShow and showState)
    end,self,0.1)
end


-- 获取礼包数据
function ActNewHeroPrayModel:getShopData()
    local moduleId = self:getShopModuleId()
    local giftData = DynamicConfigData.t_NewHeroSellShopConfig[moduleId]
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
function ActNewHeroPrayModel:getModuleId()
	local moduleId = 1
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.NewHeroSummon)
	moduleId = actData and actData.showContent.moduleId or 1
	-- printTable(8848,">>actData>>",actData)
	return moduleId
end

function ActNewHeroPrayModel:getShopModuleId()
	local moduleId = 1
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.NewHeroSummonShop)
	moduleId = actData and actData.showContent.moduleId or 1
	-- printTable(8848,">>actData>>",actData)
	return moduleId
end

function ActNewHeroPrayModel:getConVertModuleId()
	local moduleId = 1
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.NewHeroSummonExchange)
	moduleId = actData and actData.showContent.moduleId or 1
	-- printTable(8848,">>actData>>",actData)
	return moduleId
end



-- 红点更新
function ActNewHeroPrayModel:updateRed()
    local giftData = self:getShopData()
    local keyArr = {}
    for k,v in pairs(giftData) do
        if v.price == 0 then
            table.insert(keyArr, "V_ACTIVITY_"..GameDef.ActivityType.NewHeroSummonShop..v.id)
            break
        end
    end
    RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.NewHeroSummonShop, keyArr)

    for k,v in pairs(giftData) do
        if v.price == 0 then
			if #v.cost > 0  then-- and not ModelManager.PlayerModel:isCostEnough(v.cost, false) then
				RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.NewHeroSummonShop..v.id, false)
			else
				RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.NewHeroSummonShop..v.id, v.buyTime > 0)
			end
        end
    end
end


function ActNewHeroPrayModel:setNewHeroShopData(data)
   self.exchangeData = data
end


function ActNewHeroPrayModel:setNewHeroSummon(data)
    self.summonData = data
end

function ActNewHeroPrayModel:getData()
    return self.summonData
end

function ActNewHeroPrayModel:getAllYJZMAllConfig(moduleId)
	return DynamicConfigData.t_NewHeroPr[moduleId]
end


-- 获取商品数据
function ActNewHeroPrayModel:getConVertShopData()
    local moduleId = self:getModuleId()
    local shopData = DynamicConfigData.t_NewHeroStoreConfig[moduleId]
    for k,v in pairs(shopData) do
        local data = self.exchangeData[v.id]
        if v.limit == 0 then
            v.buyTime   =  -1
        else
            v.buyTime   = v.limit
        end
        if data and v.limit~=0 then
            data.count = data.count or 0
            v.buyTime = v.buyTime - data.count
            if v.buyTime < 0 then
                v.buyTime = 0
            end
        end
    end
    return shopData or {}
end




return ActNewHeroPrayModel
