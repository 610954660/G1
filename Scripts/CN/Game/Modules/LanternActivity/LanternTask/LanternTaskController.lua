

local LanternTaskController = class("LanternTaskController", Controller)

function LanternTaskController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.LanternTask then
		return 	
	end
	-- if params.endState then --如果是true 直接结束
	-- 	ModelManager.ActivityModel:speDeleteSeverData(params.type)
	-- 	return
	-- end
	if params and params.gashaponTask then
		ModelManager.LanternTaskModel:initData(params.gashaponTask)
	end
end

function LanternTaskController:Record_SyncProgress(_,params)
	if params.gamePlayType ~= GameDef.GamePlayType.ActivityLanternTask then
		return 	
	end
	LanternTaskModel:updateStateFinishAndAcc(params)
end

function LanternTaskController:Record_SyncRewardStatus(_,params)
	if params.gamePlayType ~= GameDef.GamePlayType.ActivityLanternTask then
		return 	
	end
	LanternTaskModel:updateStateGot(params)
end

return LanternTaskController