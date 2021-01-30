
local FirstChargeController = class("FirstChargeController", Controller)

function FirstChargeController:Activity_UpdateData(_, param)
	-- printTable(999,"FirstChargeController:Activity_UpdateData",param)

	if param.type == GameDef.ActivityType.FirstCharge then
	FirstChargeModel:getCurrentGiftData(param.firstCharge,param.endState)
	end
end

return FirstChargeController