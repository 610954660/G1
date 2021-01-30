
local TwistSignController = class("TwistSignController",Controller)

function TwistSignController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.EveryDaySign then
		return 	
	end

	if params and params.everyDaySign then 
		TwistSignModel:setData(params.everyDaySign)
		TwistSignModel:checkRedot()
	end
end

return TwistSignController