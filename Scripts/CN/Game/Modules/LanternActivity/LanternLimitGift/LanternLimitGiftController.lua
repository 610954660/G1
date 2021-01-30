

local LanternLimitGiftController = class("LanternLimitGiftController", Controller)

function LanternLimitGiftController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.LanternGift then
		return 	
	end
	-- if params.endState then --如果是true 直接结束
	-- 	ModelManager.ActivityModel:speDeleteSeverData(params.type)
	-- 	return
	-- end
	if params and params.gashaponGift then
		ModelManager.LanternLimitGiftModel:initData(params.gashaponGift)
	end
end

return LanternLimitGiftController