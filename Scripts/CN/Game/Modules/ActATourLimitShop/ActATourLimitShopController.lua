

local ActATourLimitShopController = class("ActATourLimitShopController", Controller)

function ActATourLimitShopController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.ElfTourShop then
		return 	
	end
	-- if params.endState then --如果是true 直接结束
	-- 	ModelManager.ActivityModel:speDeleteSeverData(params.type)
	-- 	return
	-- end
	if params and params.limitGift then
		printTable(8848,">>>巡礼商城>>>",params)
		ModelManager.ActATourLimitShopModel:initData(params.limitGift)
	end
end

return ActATourLimitShopController