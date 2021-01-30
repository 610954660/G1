

local TimeSummonModel = class("TimeSummonModel",BaseModel)

function TimeSummonModel:ctor()
    self.data = {}
    self.count = 0  --召唤次数
end

function TimeSummonModel:initData(data)
    self.data = data or {}
    self.count = data.count or 0
    self:redCheck()
    Dispatcher.dispatchEvent(EventType.TimeSummonView_refreshPanal)
end

function TimeSummonModel:sortData()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroSummon)
    if not actData then return end
    local myData = DynamicConfigData.t_LimitSummonActivityTask[actData.showContent.moduleId]

    for k,v in pairs(myData) do
        if self.count >= v.num then
            if not self.data.recordMap[v.id] then
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

function TimeSummonModel:redCheck()
	GlobalUtil.delayCallOnce("TimeSummonModel:redCheck",function()
		self:updateRed()
	end, self, 0.1)
end

function TimeSummonModel:updateRed()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroSummon)
    if not actData then return end
    local myData = {}
    myData = self:sortData()

    local dayStr = DateUtil.getOppostieDays()
    local isShow = FileCacheManager.getBoolForKey("TimeSummonView_isShow" .. dayStr,false)
    local keyArr={}
    for i=1,#myData do
        local data = myData[i]
        table.insert(keyArr, "V_ACTIVITY_"..GameDef.ActivityType.HeroSummon..data.id)
    end
    RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.HeroSummon, keyArr)

    local isTake = true

    for i=1,#myData do
        local data =myData[i]
        if self.count >= data.num then
            if not self.data.recordMap[data.id] then
                isTake = false
                RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.HeroSummon..data.id, true)
            else
                RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.HeroSummon..data.id, false)
            end
        else
            RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.HeroSummon..data.id, false)
        end
    end

    RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.HeroSummon, (not isShow) or (not isTake))
	
end

return TimeSummonModel