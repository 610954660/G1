--Date :2021-01-28
--Author : added by xhd
--Desc : 新英雄皮肤售卖

local ActNewHeroPrayController = class("ActNewHeroPrayController",Controller)

function ActNewHeroPrayController:init()
	
end

function ActNewHeroPrayController:Activity_UpdateData(_, params)
	if params and params.type == GameDef.ActivityType.NewHeroSummonExchange then --新英雄召唤兑换商城
		if params.newHeroShop then
			ModelManager.ActNewHeroPrayModel:setNewHeroExchangeShopData(params.newHeroShop)
        end
        ActNewHeroPrayModel:setActConvertShopRedFirst()
        Dispatcher.dispatchEvent(EventType.NewHeroPray_updateConvertView)
	end
	
	--新英雄召唤购买商城
	if params.type == GameDef.ActivityType.NewHeroSummonShop then
		if params and params.heroSummonShop then
			ModelManager.ActNewHeroPrayModel:setNewHeroSummonShopData(params.heroSummonShop)
		end 	
	end

	if params.type == GameDef.ActivityType.NewHeroSummon then
		printTable(1,"数据=",params)
		if params and params.newHeroSummon then
			ModelManager.ActNewHeroPrayModel:setNewHeroSummon(params.newHeroSummon)
		end 	
	end
end

return ActNewHeroPrayController