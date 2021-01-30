local DailyGiftBagController = class("DailyGiftBagController",Controller)

function DailyGiftBagController:Welfare_DayilyGiftNotify(_,params)
	-- printTable(8848,"params.dailyGift",params)
	DailyGiftBagModel:initData(params.dailyGift)
end

return DailyGiftBagController