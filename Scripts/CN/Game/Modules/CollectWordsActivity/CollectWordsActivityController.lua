--Date :2020-12-24
--Author : generated by FairyGUI
--Desc : 

local CollectWordsActivityController = class("CollectWordsActivity",Controller)

function CollectWordsActivityController:init()
	
end

function CollectWordsActivityController:Activity_UpdateData( _,params )
    if params.type ~= GameDef.ActivityType.CollectWordsShop and params.type ~= GameDef.ActivityType.CollectWords then
        return
    end
    
    if params and params.heroSummonShop then
        CollectWordsActivityModel:initShopData(params.heroSummonShop)
    end

    if params and params.collectWords then
        CollectWordsActivityModel:initData(params.collectWords) 
    end

end


return CollectWordsActivityController