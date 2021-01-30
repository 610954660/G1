
local LanternRiddleModel = class("LanternRiddleModel",BaseModel)

function LanternRiddleModel:ctor()
    self.giftInfo = {}     -- 礼包信息
    self.flagInfo = {}      -- 记录购买的次数
end

-- #元宵活动
-- .PActivity_LanternGuessQuestion {
-- 	id 			1:integer		#题目id
-- 	result 		2:boolean		#回答状态 值 == nil 为没有回答状态 true 为回答正确 false 为回答错误
-- }
function LanternRiddleModel:initData(data)
    self.giftInfo = data or {}
    self:updateRed()
    Dispatcher.dispatchEvent(EventType.LanternRiddleView_refreshPanel)
end


-- 获取模板id
function LanternRiddleModel:getModuleId()
	local moduleId = 1
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.LanternGuess)
	moduleId = actData and actData.showContent.moduleId or 1
	-- printTable(8848,">>actData>>",actData)
	return moduleId
end

-- 红点更新
function LanternRiddleModel:updateRed()
    -- local giftData = self:getShopData()
    -- local keyArr = {}
    -- for k,v in pairs(giftData) do
    --     if v.price == 0 then
    --         table.insert(keyArr, "V_ACTIVITY_"..GameDef.ActivityType.LanternGuess..v.id)
    --         break
    --     end
    -- end
    -- RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.LanternGuess, keyArr)

    -- for k,v in pairs(giftData) do
    --     if v.price == 0 then
    --         local fdata = self.flagInfo[v.id]
    --         RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.LanternGuess..v.id , fdata.buyTime > 0)
    --         break
    --     end
    -- end
end

return LanternRiddleModel
