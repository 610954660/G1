local PopularVoteTaskController = class("PopularVoteTaskController", Controller)

function PopularVoteTaskController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.HeroVoteTask then
		return 	
	end
	PopularVoteModel:initTaskData(params)
end

function PopularVoteTaskController:Record_SyncProgress(_,params)
	if params.gamePlayType ~= GameDef.GamePlayType.ActivityHeroVoteTask then
		return 	
	end
	PopularVoteModel:updateStateFinishAndAcc(params)
end

function PopularVoteTaskController:Record_SyncRewardStatus(_,params)
	if params.gamePlayType ~= GameDef.GamePlayType.ActivityHeroVoteTask then
		return 	
	end
	PopularVoteModel:updateStateGot(params)
end

return PopularVoteTaskController