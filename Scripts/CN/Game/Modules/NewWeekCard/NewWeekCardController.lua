
local NewWeekCardController = class("NewWeekCardController", Controller)


function NewWeekCardController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.NewWeekCard then
		return 	
	end
	--printTable(8848,"param.newWeekCard",params)
	if params.endState then --如果是true 直接结束
		ModelManager.ActivityModel:speDeleteSeverData(params.type)
		return
	end
	ModelManager.NewWeekCardModel:initData(params.newWeekCard)
end

return NewWeekCardController