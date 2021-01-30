local NoBilityWeekGiftController = class("NoBilityWeekGiftController",Controller)

function NoBilityWeekGiftController:Activity_UpdateData(_,params)
	if params.type == GameDef.ActivityType.NoBilityWeekGift then
		-- printTable(8848,"params.weekGift",params.weekGift)
		NoBilityWeekGiftModel:initData(params.weekGift.giftStatus)
	end
end

return NoBilityWeekGiftController