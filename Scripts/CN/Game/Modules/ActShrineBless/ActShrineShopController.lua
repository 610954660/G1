
--神社祈福controller
--added by xhd
local ActShrineShopController = class("ActShrineShopController", Controller)

function ActShrineShopController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.ShrinePrayShop then
		return 	
	end
	-- if params.endState then --如果是true 直接结束
	-- 	ModelManager.ActivityModel:speDeleteSeverData(params.type)
	-- 	return
	-- end
	if params and params.limitGift then
		printTable(1,">>>神社祈福商城>>>",params)
		ModelManager.ActShrineShopModel:initData(params.limitGift)
	end
end

return ActShrineShopController