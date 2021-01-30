local WeeklyGiftBagController = class("WeeklyGiftBagController",Controller)

function WeeklyGiftBagController:Activity_UpdateData(_,params)
	if params.type == GameDef.ActivityType.WeekGift then
		-- printTable(8848,"params.weekGift",params.weekGift)
		WeeklyGiftBagModel:initData(params.weekGift.giftStatus)
	end
end

return WeeklyGiftBagController