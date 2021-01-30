
local ActFinalRewardController = class("ActFinalRewardController",Controller)
--最终赏
function ActFinalRewardController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.ElfFinal then
		return 	
	end

	if params.endState then --如果是true 直接结束
		-- Dispatcher.dispatchEvent("close_ActivityView",3) 
		return
	end
	
	if params and params.elfFinal then 
		ActFinalRewardModel:setData(params.elfFinal)
		ActFinalRewardModel:checkRedot()
	end
end

return ActFinalRewardController