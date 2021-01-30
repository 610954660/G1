

local TwistEggShopController = class("TwistEggShopController", Controller)

function TwistEggShopController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.GashaponShop then
		return 	
	end
	-- if params.endState then --如果是true 直接结束
	-- 	ModelManager.ActivityModel:speDeleteSeverData(params.type)
	-- 	return
	-- end
	if params and params.gashaponShop then
		ModelManager.TwistEggShopModel:initData(params.gashaponShop)
	end
end

return TwistEggShopController