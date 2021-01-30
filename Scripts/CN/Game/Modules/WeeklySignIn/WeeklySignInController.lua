local WeeklySignInController = class("WeeklySignInController",Controller)

function WeeklySignInController:Activity_UpdateData(_,params)
	if params.type == GameDef.ActivityType.WeekLogin then
		-- printTable(8848,"params.weekLogin",params.weekLogin)
		ModelManager.WeeklySignInModel:initData(params.weekLogin)
	end
end

return WeeklySignInController