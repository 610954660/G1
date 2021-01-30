

local ShopController = class("ShopController",Controller)

function ShopController:Shop_PushMailList(_,args)
	
	-- printTable(8848,"args",args)
	ShopModel:updateShopData(args)
end



function ShopController:Money_Recharge(_,args)
	ModelManager.RechargeModel:updateRechargeStat(args.recharge)
	--Dispatcher.dispatchEvent(EventType.charge_status_change) -- 在playerModel里面已经有
end


function ShopController:Money_ChargeSucceed (_,args)
	RollTips.show(string.format(Desc.recharge_success, args.amount))
end

return ShopController