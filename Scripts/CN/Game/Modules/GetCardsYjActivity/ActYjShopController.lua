
--异界招募限时商店controller
--added by xhd
local ActYjShopController = class("ActYjShopController", Controller)

function ActYjShopController:init()
	self.activityTypes = {
		GameDef.ActivityType.HeroSummonShop,
		GameDef.ActivityType. HeroSummonShopDay
	}
	
end

function ActYjShopController:Activity_UpdateData(_, params)
	if not table.hasValue(self.activityTypes,params.type) then
		return 	
	end
	-- if params.endState then --如果是true 直接结束
	-- 	ModelManager.ActivityModel:speDeleteSeverData(params.type)
	-- 	return
	-- end
	if params and params.heroSummonShop then
		printTable(1,">>>异界招募限时商店>>>",params)
		ModelManager.ActYjShopModel:initData(params.type, params.heroSummonShop)
	end
end

return ActYjShopController