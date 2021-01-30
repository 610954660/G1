

local LanternRiddleController = class("LanternRiddleController", Controller)

function LanternRiddleController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.LanternGuess then
		return 	
	end
	-- if params.endState then --如果是true 直接结束
	-- 	ModelManager.ActivityModel:speDeleteSeverData(params.type)
	-- 	return
	-- end
	if params and params.lanternGuess then
		ModelManager.LanternRiddleModel:initData(params.lanternGuess)
	end
end

return LanternRiddleController