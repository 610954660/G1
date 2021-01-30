

local DetectiveTrialGiftController = class("DetectiveTrialGiftController", Controller)

function DetectiveTrialGiftController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.HeroTrialGift then
		return 	
	end
	-- if params.endState then --如果是true 直接结束
	-- 	ModelManager.ActivityModel:speDeleteSeverData(params.type)
	-- 	return
	-- end
	if params and params.gashaponGift then
		ModelManager.DetectiveTrialGiftModel:initData(params.gashaponGift)
	end
end

return DetectiveTrialGiftController