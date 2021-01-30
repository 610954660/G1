
local LanternSignController = class("LanternSignController",Controller)

function LanternSignController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.LanternEveryDaySign then
		return 	
	end

	if params and params.everyDaySign then 
		LanternSignModel:setData(params.everyDaySign)
		LanternSignModel:checkRedot()
	end
end

return LanternSignController