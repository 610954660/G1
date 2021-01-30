

local LanternShopController = class("LanternShopController", Controller)

function LanternShopController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.LanternShop then
		return 	
	end
	-- if params.endState then --如果是true 直接结束
	-- 	ModelManager.ActivityModel:speDeleteSeverData(params.type)
	-- 	return
	-- end
	if params and params.gashaponShop then
		ModelManager.LanternShopModel:initData(params.gashaponShop)
	end
end

return LanternShopController