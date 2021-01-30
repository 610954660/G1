

local ActHeroGatherModel = class("ActHeroGatherModel",BaseModel)

function ActHeroGatherModel:ctor()
    self.data = {}
end

function ActHeroGatherModel:initData(data)
    self.data = data or {}
    self:redCheck()
    Dispatcher.dispatchEvent(EventType.ActHeroGatherView_refreshPanal)
end

function ActHeroGatherModel:getCount( ... )
   if self.data and self.data.count then
       return  self.data.count
   end
   return 0
end

-- function ActHeroGatherModel:isHaveHero() 
--     local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroCollection)
--     if not actData then return end
--     local heroList = DynamicConfigData.t_UpStarActivity[actData.showContent.moduleId]
--     if not heroList then return end
--     for k,v in pairs(heroList.hero) do
--         local ss = ModelManager.CardLibModel:isHeroGot(v)
--         if ModelManager.CardLibModel:isHeroGot(v) then
--             return true
--         end
--     end
--     return false
-- end

function ActHeroGatherModel:getShowConfig( ... )
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroCollection)
    if not actData then return {} end
	local rewardData = {}
    local config = DynamicConfigData.t_HeroActivity[actData.showContent.moduleId]
	for _,v in ipairs(config) do
		table.insert(rewardData, {config = v, id = v.id, hasGet = self:checkHadGet(v.id) and 1 or 0 })
	end
	TableUtil.sortByMap(rewardData, {{key = "hasGet", asc = false}, {key = "id", asc = false}})
    return rewardData 
end

function ActHeroGatherModel:checkHadGet(id)
    if self.data and self.data.recordMap then
        for k,v in pairs(self.data.recordMap) do
            if v.id == id then
                return true
            end
        end
    end
    return false
end

function ActHeroGatherModel:redCheck()
	GlobalUtil.delayCallOnce("ActHeroGatherModel:redCheck",function()
		self:updateRed()
	end, self, 0.1)
end

function ActHeroGatherModel:updateRed()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroCollection)
    if not actData then return end
    local rewardData = self:getShowConfig( )
    RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.HeroCollection, false)
    for i=1,#rewardData do
        local curConfig =rewardData[i].config
        if self:getCount()>=curConfig.task then
            if not self:checkHadGet(curConfig.id) then
                RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.HeroCollection, true)
                break
            end
        end
    end
end

return ActHeroGatherModel