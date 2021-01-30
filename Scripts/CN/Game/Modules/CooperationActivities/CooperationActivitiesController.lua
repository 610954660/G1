--Date :2021-01-16
--Author : generated by FairyGUI
--Desc : 协力活动

local CooperationActivitiesController = class("CooperationActivities",Controller)

function CooperationActivitiesController:init()
	
end

function CooperationActivitiesController:Activity_WorkTogether_CommonUpdate(_,info)
    ModelManager.CooperationActivitiesModel:setCommonUpdate(GameDef.ActivityType.WorkTogetherAct,info)
    Dispatcher.dispatchEvent(EventType.CooperationActivitie_timerefresh)
    printTable(159, "Activity_WorkTogether_CommonUpdate零点刷新", info)
end

function CooperationActivitiesController:Activity_UpdateData(_, params)
    if  params and params.type == GameDef.ActivityType.WorkTogetherAct then
        printTable(159, "Activity_UpdateData协力活动", params)
        if params.workTogether then
            ModelManager.CooperationActivitiesModel:setCooperationInfo(params.type,params.workTogether)
        end
        CooperationActivitiesModel:setCooperationRed(params.type)
        Dispatcher.dispatchEvent(EventType.CooperationActivitie_timerefresh)
        if params.endState then
            ActivityModel:speDeleteSeverData(params.type)
        end
    elseif params and params.type == GameDef.ActivityType.WorkTogetherExchange then--协力活动兑换商城
        printTable(159, "Activity_UpdateData协力活动兑换商城", params)
        if params.workTogetherExchange then
            ModelManager.CooperationActivitiesModel:setCooperationShop(params.type,params.workTogetherExchange)
        end
        Dispatcher.dispatchEvent(EventType.CooperationActivitie_ShopRefresh)
        if params.endState then
            ActivityModel:speDeleteSeverData(params.type)
        end
    elseif params and params.type == GameDef.ActivityType.WorkTogetherShop then--协力活动限时商城
        printTable(159, "Activity_UpdateData协力活动限时商城", params)
        if params.workTogetherShop then
            ModelManager.CooperationActivitiesModel:setCooperationStore(params.type,params.workTogetherShop)
        end
        Dispatcher.dispatchEvent(EventType.CooperationActivitie_Holpprefresh)
        CooperationActivitiesModel:setCooperationLimitedShopRed(params.type)
        if params.endState then
            ActivityModel:speDeleteSeverData(params.type)
        end
    end

end

return CooperationActivitiesController