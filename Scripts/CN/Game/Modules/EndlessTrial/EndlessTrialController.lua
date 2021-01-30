
local EndlessTrialController = class("EndlessTrialController", Controller)


function EndlessTrialController:TopChallenge_SyncData(_, param)
	EndlessTrialModel:initData(param.data,param.isCrossDay)
	-- EndlessTrialModel:endGame(param.isCrossDay)
end

return EndlessTrialController