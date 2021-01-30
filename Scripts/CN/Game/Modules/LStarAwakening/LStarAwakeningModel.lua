

local LStarAwakeningModel = class("LStarAwakeningModel",BaseModel)

function LStarAwakeningModel:ctor()
    self.data = {}
    -- self.starLevel = 0  -- 当前星级
end

function LStarAwakeningModel:initData(data)
    self.data = data or {}
    -- self.starLevel = data.starLevel or 0
    self:redCheck()
    Dispatcher.dispatchEvent(EventType.LStarAwakeningView_refreshPanal)
end


function LStarAwakeningModel:isHaveHero() 
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroStarLevel)
    if not actData then return end
    local heroList = DynamicConfigData.t_UpStarActivity[actData.showContent.moduleId]
    if not heroList then return end
    for k,v in pairs(heroList.hero) do
        local ss = ModelManager.CardLibModel:isHeroGot(v)
        if ModelManager.CardLibModel:isHeroGot(v) then
            return true
        end
    end
    return false
end

function LStarAwakeningModel:sortData()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroStarLevel)
    if not actData then return end
    local myData = DynamicConfigData.t_UpStarActivityReward[actData.showContent.moduleId]
    if not myData then return end
    -- for k,v in pairs(myData) do
    --     if self.starLevel >= v.task then
    --         if not self.data.recordMap[v.id] then
    --             v.take = 1 -- 可领取
    --         else
    --             v.take = 3 -- 已领取
    --         end
    --     else
    --         v.take = 2 -- 不可领取
    --     end
    -- end
    for k,v in pairs(myData) do
        if self.data.recordMap[v.id] then
            if self.data.recordMap[v.id].recvState==true then
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

function LStarAwakeningModel:redCheck()
	GlobalUtil.delayCallOnce("LStarAwakeningModel:redCheck",function()
		self:updateRed()
	end, self, 0.1)
end

function LStarAwakeningModel:updateRed()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroStarLevel)
    if not actData then return end
    local myData = {}
    myData = self:sortData()
    if not myData then return end

    local dayStr = DateUtil.getOppostieDays()
    local isShow = FileCacheManager.getBoolForKey("LStarAwakeningView_isShow" .. dayStr,false)
    local keyArr={}
    for i=1,#myData do
        local data = myData[i]
        table.insert(keyArr, "V_ACTIVITY_"..GameDef.ActivityType.HeroStarLevel..data.id)
    end
    RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.HeroStarLevel, keyArr)

    local isTake = true

    for i=1,#myData do
        local data =myData[i]
        if self.data.recordMap[data.id] then
            if self.data.recordMap[data.id].recvState == true then
                isTake = false
                RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.HeroStarLevel..data.id, true)
            else
                RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.HeroStarLevel..data.id, false)
            end
        else
            RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.HeroStarLevel..data.id, false)
        end
    end

    RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.HeroStarLevel, (not isShow) or (not isTake))
	
end

return LStarAwakeningModel