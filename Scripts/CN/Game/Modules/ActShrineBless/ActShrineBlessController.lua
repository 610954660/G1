

--神社祈福controller
--added by xhd 
local ActShrineBlessController = class("ActShrineBlessController", Controller)

function ActShrineBlessController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.ShrinePray then
		return 	
	end
	-- if params.endState then --如果是true 直接结束
	-- 	ModelManager.ActivityModel:speDeleteSeverData(params.type)
	-- 	return
	-- end
	if params and params.shrinePray then
		printTable(1,">>>神社祈福数据>>>",params)
		ModelManager.ActShrineBlessModel:initData(params.shrinePray)
	end
end

return ActShrineBlessController