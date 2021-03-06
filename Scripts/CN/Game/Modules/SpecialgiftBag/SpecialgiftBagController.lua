--Name : SpecialgiftBagController.lua
--Author : generated by FairyGUI
--Date : 2020-5-29
--Desc :

local SpecialgiftBagController = class("SpecialgiftBagController", Controller)

function SpecialgiftBagController:init()
	self.activityTypes = {
		GameDef.ActivityType.PreferentialkGift,
		GameDef.ActivityType. HeroTrialPreferGift,
		GameDef.ActivityType.TourPreferGift,
		GameDef.ActivityType. GashaponPreferGift,
		GameDef.ActivityType.ShrinePrayPreferGift,
	}
	
end

function SpecialgiftBagController:Activity_UpdateData(_, params)
    if params and table.hasValue(self.activityTypes,params.type) then --特惠礼包
        printTable(155, "Activity_UpdateData特惠礼包", params)
        if params.endState then
            ActivityModel:speDeleteSeverData(params.type)
        end
        if params.preferentialkGift then
            ModelManager.SpecialgiftBagModel:setSpecialgiftBagActiveInfo(params.type, params.preferentialkGift)
        end
        Dispatcher.dispatchEvent(EventType.activity_SpecialgiftActiveUpdate)
    end
end



return SpecialgiftBagController
