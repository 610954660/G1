local MonthlyGiftBagController = class("MonthlyGiftBagController",Controller)

function MonthlyGiftBagController:Activity_UpdateData(_,params)
	if params.type == GameDef.ActivityType.MoonGift then
		-- printTable(8848,"Activity_UpdateData",params.moonGift)
		MonthlyGiftBagModel:initData(params.moonGift)
	end
end

return MonthlyGiftBagController