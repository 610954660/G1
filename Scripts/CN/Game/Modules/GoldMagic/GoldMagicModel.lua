

local GoldMagicModel = class("GoldMagicModel",BaseModel)

function GoldMagicModel:ctor()
    self.data = {}
end

function GoldMagicModel:initData(data)
    self.data = data or {}
    self:redCheck()
    Dispatcher.dispatchEvent(EventType.GoldMagicView_refreshPanal)
end

function GoldMagicModel:getCount( ... )
   if self.data and self.data.count then
       return  self.data.count
   end
   return 0
end


function GoldMagicModel:getShowConfig( ... )
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.GoldMagic)
    if not actData then return {} end
	local rewardData = {}
    local config = DynamicConfigData.t_GoldActivity[actData.showContent.moduleId]
	for _,v in ipairs(config) do
		table.insert(rewardData, {config = v, id = v.id, hasGet = self:checkHadGet(v.id) and 1 or 0 })
	end
	TableUtil.sortByMap(rewardData, {{key = "hasGet", asc = false}, {key = "id", asc = false}})
    return rewardData 
end

function GoldMagicModel:checkHadGet(id)
    if self.data and self.data.recordMap and self.data.recordMap[id] then
        return true
    end
    return false
end

function GoldMagicModel:redCheck()
	GlobalUtil.delayCallOnce("GoldMagicModel:redCheck",function()
		self:updateRed()
	end, self, 0.1)
end

function GoldMagicModel:updateRed()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.GoldMagic)
    if not actData then return end
    local rewardData = self:getShowConfig( )
    RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.GoldMagic, false)
    for i=1,#rewardData do
        local curConfig =rewardData[i].config
        if self:getCount()>=curConfig.task then
            if not self:checkHadGet(curConfig.id) then
                RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.GoldMagic, true)
                break
            end
        end
    end
end

return GoldMagicModel