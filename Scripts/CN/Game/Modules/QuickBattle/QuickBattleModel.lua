

local QuickBattleModel = class("QuickBattleModel",BaseModel)

function QuickBattleModel:ctor()
    self.data = {}
end

function QuickBattleModel:initData(data)
    self.data = data or {}
    self:redCheck()
    Dispatcher.dispatchEvent(EventType.QuickBattleView_refreshPanal)
end

function QuickBattleModel:getCount( ... )
   if self.data and self.data.count then
       return  self.data.count
   end
   return 0
end


function QuickBattleModel:getShowConfig( ... )
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.QuickBattle)
    if not actData then return {} end
	local rewardData = {}
    local config = DynamicConfigData.t_WipeActivity[actData.showContent.moduleId]
	for _,v in ipairs(config) do
		table.insert(rewardData, {config = v, id = v.id, hasGet = self:checkHadGet(v.id) and 1 or 0 })
	end
	TableUtil.sortByMap(rewardData, {{key = "hasGet", asc = false}, {key = "id", asc = false}})
    return rewardData 
end

function QuickBattleModel:checkHadGet(id)
    if self.data and self.data.recordMap and self.data.recordMap[id] then
        return true
    end
    return false
end

function QuickBattleModel:redCheck()
	GlobalUtil.delayCallOnce("QuickBattleModel:redCheck",function()
		self:updateRed()
	end, self, 0.1)
end

function QuickBattleModel:updateRed()
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.QuickBattle)
    if not actData then return end
    local rewardData = self:getShowConfig( )
    RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.QuickBattle, false)
    for i=1,#rewardData do
        local curConfig =rewardData[i].config
        if self:getCount()>=curConfig.task then
            if not self:checkHadGet(curConfig.id) then
                RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.QuickBattle, true)
                break
            end
        end
    end
end

return QuickBattleModel