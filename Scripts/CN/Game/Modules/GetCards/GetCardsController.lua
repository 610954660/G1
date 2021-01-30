--added by xhd 
--卡牌召唤控制器
local GetCardsController = class("GetCardsController",Controller)
--卡牌召唤数据更新 监听服务器数据更新
function GetCardsController:HeroLottery_ModuleInfo( _,params )
    print(1,"PlayerController HeroLottery_ModuleInfo",params)
    GetCardsModel:initData(params.moduleData)
    Dispatcher.dispatchEvent("update_getCardsView")
end

function GetCardsController:Limit_ConsumeTimes( _,params )
    printTable(1,"PlayerController Limit_ConsumeTimes",params)
    GetCardsModel:updateLastTime(params)
    Dispatcher.dispatchEvent("update_cardListTime")
end

function GetCardsController:Vip_UpLevel()
	ModelManager.GetCardsModel:checkRedot()
end

function GetCardsController:pushMap_point_change()
	ModelManager.GetCardsModel:checkRedot()
end

return GetCardsController