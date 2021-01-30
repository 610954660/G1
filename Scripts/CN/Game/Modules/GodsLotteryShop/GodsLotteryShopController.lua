

local GodsLotteryShopController = class("GodsLotteryShopController", Controller)

function GodsLotteryShopController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.GodsPrayShop then
		return 	
	end
	-- if params.endState then --如果是true 直接结束
	-- 	ModelManager.ActivityModel:speDeleteSeverData(params.type)
	-- 	return
	-- end
	if params and params.heroSummonShop then
		ModelManager.GodsLotteryShopModel:initData(params.heroSummonShop)
	end
end

return GodsLotteryShopController