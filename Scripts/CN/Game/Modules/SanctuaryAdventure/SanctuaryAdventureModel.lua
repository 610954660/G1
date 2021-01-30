

local SanctuaryAdventureModel = class("SanctuaryAdventureModel",BaseModel)

function SanctuaryAdventureModel:ctor()
    self.data = {}
    self.layer = 0  --层数
    self.state = 0  --领取状态
end

function SanctuaryAdventureModel:initData(data)
    self.data = data or {}
    self.layer = data.layer or 0
    self.state = data.state or 0
    self:redCheck()
    Dispatcher.dispatchEvent(EventType.SanctuaryAdventureView_refreshPanal)
end

function SanctuaryAdventureModel:sortData()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.StarTempleExpedition)
    if not actData then return end
    local myData = DynamicConfigData.t_TempleActivityReward[actData.showContent.moduleId]
    if not myData then return end

    for k,v in pairs(myData) do
        if self.layer >= v.times then
			local flag = bit.band(self.state, bit.lshift(1, v.id - 1)) > 0
            if not flag then
                v.take = 1 -- 可领取
            else
                v.take = 3 -- 已领取
            end
        else
            v.take = 2 -- 不可领取
        end
    end
    local keys ={
        {key = "take",asc = false},
        {key = "id",asc = false},
    }
    TableUtil.sortByMap(myData, keys)
    return myData
end

function SanctuaryAdventureModel:redCheck()
	GlobalUtil.delayCallOnce("SanctuaryAdventureModel:redCheck",function()
		self:updateRed()
	end, self, 0.1)
end

function SanctuaryAdventureModel:updateRed()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.StarTempleExpedition)
    if not actData then return end
    local myData = {}
    myData = self:sortData()
    if not myData then return end

    local dayStr = DateUtil.getOppostieDays()
    local isShow = FileCacheManager.getBoolForKey("SanctuaryAdventureView_isShow" .. dayStr,false)
    local keyArr={}
    for i=1,#myData do
        local data = myData[i]
        table.insert(keyArr, "V_ACTIVITY_"..GameDef.ActivityType.StarTempleExpedition..data.id)
    end
    RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.StarTempleExpedition, keyArr)

    local isTake = true

    for i=1,#myData do
        local data =myData[i]
        if self.layer >= data.times then
            local flag = bit.band(self.state, bit.lshift(1, data.id - 1)) > 0
            if not flag then
                isTake = false
                RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.StarTempleExpedition..data.id, true)
            else
                RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.StarTempleExpedition..data.id, false)
            end
        else
            RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.StarTempleExpedition..data.id, false)
        end
    end
    RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.StarTempleExpedition, (not isShow) or (not isTake))
	
end

return SanctuaryAdventureModel