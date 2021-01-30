

local DetectiveTrialShopController = class("DetectiveTrialShopController", Controller)

function DetectiveTrialShopController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.HeroTrialShop then
		return 	
	end
	-- if params.endState then --如果是true 直接结束
	-- 	ModelManager.ActivityModel:speDeleteSeverData(params.type)
	-- 	return
	-- end
	if params and params.gashaponShop then
		ModelManager.DetectiveTrialShopModel:initData(params.gashaponShop)
	end
end

return DetectiveTrialShopController