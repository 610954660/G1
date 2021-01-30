

local TwistEggTaskController = class("TwistEggTaskController", Controller)

function TwistEggTaskController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.GashaponTask then
		return 	
	end
	-- if params.endState then --如果是true 直接结束
	-- 	ModelManager.ActivityModel:speDeleteSeverData(params.type)
	-- 	return
	-- end
	if params and params.gashaponTask then
		ModelManager.TwistEggTaskModel:initData(params.gashaponTask)
	end
end

function TwistEggTaskController:Record_SyncProgress(_,params)
	if params.gamePlayType ~= GameDef.GamePlayType.ActivityGashaponTask then
		return 	
	end
	TwistEggTaskModel:updateStateFinishAndAcc(params)
end

function TwistEggTaskController:Record_SyncRewardStatus(_,params)
	if params.gamePlayType ~= GameDef.GamePlayType.ActivityGashaponTask then
		return 	
	end
	TwistEggTaskModel:updateStateGot(params)
end

return TwistEggTaskController