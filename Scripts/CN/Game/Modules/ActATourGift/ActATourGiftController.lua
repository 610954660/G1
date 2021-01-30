
local ActATourGiftController = class("ActATourGiftController",Controller)
--一番巡礼
function ActATourGiftController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.ElfHis then
		return 	
	end
	if params.endState then --如果是true 直接结束
		-- Dispatcher.dispatchEvent("close_ActivityView",3) 
		return
	end
	
	if params and params.elfHis then 
		ActATourGiftModel:setData(params.elfHis)
		ActATourGiftModel:checkRedot()
	end
end

function ActATourGiftController:pack_item_change(_,data)
	local config2  = ActATourGiftModel:getOneDrawConfig(10)
	local cost2 = config2.costItem[1]
	if data[1].itemCode == cost2.code then
		ActATourGiftModel:checkRedot()
	end
end

return ActATourGiftController