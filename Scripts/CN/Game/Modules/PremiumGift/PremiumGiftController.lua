local PremiumGiftController = class("PremiumGiftController", Controller)

function PremiumGiftController:Activity_UpdateData(_, param)

	local params = ActivityModel.actData
	-- printTable(999,params)
    for _, data in pairs(params) do
        if data.type == GameDef.ActivityType.BargainGift then
            PremiumGiftModel:initData(data)
            -- printTable(999,data)
            break
        end
    end
end

return PremiumGiftController