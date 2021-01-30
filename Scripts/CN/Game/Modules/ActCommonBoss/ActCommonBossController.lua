--Date :2021-01-20
--Author : added by xhd
--Desc : 通用boss控制器

local ActCommonBossController = class("ActCommonBossController",Controller)

function ActCommonBossController:init()
	
end

function ActCommonBossController:Activity_UpdateData(_, params)
	--通用boss兑换
	if params and params.type == GameDef.ActivityType.HolidayExchange then --节日活动兑换商城
		if params.endState then
			ActivityModel:speDeleteSeverData(params.type)
		end
		if params.newHeroShop then
			ModelManager.ActCommonBossModel:setCommonBossShopData(params.newHeroShop)
		end
		ActCommonBossModel:setActCommonBossShopRedFirst()
		Dispatcher.dispatchEvent(EventType.activity_CommonBossShop)
	end
	
	--通用boss商店
	if params.type == GameDef.ActivityType.HolidayShop then
		if params and params.trialShop then
			ModelManager.ActCommonShopModel:initData(params.trialShop)
		end 	
	end

	if params.type == GameDef.ActivityType.HolidayBoss then
		printTable(1,"通用boss数据",params)
		if params and params.holidayBoss then
			ModelManager.ActCommonBossModel:initBossData(params.holidayBoss)
		end 	
	end
end

return ActCommonBossController