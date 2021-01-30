
local LanternDrawController = class("LanternDrawController",Controller)

function LanternDrawController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.LanternDraw then
		return 	
	end
	if params and params.gashapon then 
		ModelManager.LanternDrawModel:initRedMap()
		ModelManager.LanternDrawModel.recvRecords = params.gashapon.recvRecords
		ModelManager.LanternDrawModel.drawCount = params.gashapon.count
		LanternDrawModel:redCheck()
		Dispatcher.dispatchEvent(EventType.LanternDrawView_refreshPanel)
	end
end


function LanternDrawController:money_change(_,data)
	if data[GameDef.MoneyType.LanternCoin] then
		LanternDrawModel:redCheck()
	end
end

return LanternDrawController