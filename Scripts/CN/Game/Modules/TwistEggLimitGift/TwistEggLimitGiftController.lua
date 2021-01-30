

local TwistEggLimitGiftController = class("TwistEggLimitGiftController", Controller)

function TwistEggLimitGiftController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.GashaponGift then
		return 	
	end
	-- if params.endState then --如果是true 直接结束
	-- 	ModelManager.ActivityModel:speDeleteSeverData(params.type)
	-- 	return
	-- end
	if params and params.gashaponGift then
		ModelManager.TwistEggLimitGiftModel:initData(params.gashaponGift)
	end
end

return TwistEggLimitGiftController