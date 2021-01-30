
local SuperFundController = class("SuperFundController", Controller)


function SuperFundController:Activity_UpdateData(_, param)
	-- local params = ActivityModel.actData
	-- -- printTable(999,params)
 --    for _, data in pairs(params) do
 --        if data.type == GameDef.ActivityType.BargainGift then
 --            PremiumGiftModel:initData(data)
 --            -- printTable(999,data)
 --            break
 --        end
--    end
 	-- printTable(999,"param",param)
	 if param.type ~= GameDef.ActivityType.AccSuperFund then
		return
		-- FirstChargeModel:getCurrentGiftData(param.SuperFund)
	end
	printTable(8848,"param.accSuperFund",param.accSuperFund)
	SuperFundModel:initData(param.accSuperFund)
end

-- function SuperFundController:SuperFund_SendInfo (_,param)
-- 	-- printTable(8848,"SuperFund_SendInfo_param",param)
-- 	-- SuperFundModel:initData(param.superFund)
-- end



return SuperFundController