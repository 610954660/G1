
local TwistEggController = class("TwistEggController",Controller)

function TwistEggController:Activity_UpdateData(_, params)
	if params.type ~= GameDef.ActivityType.Gashapon then
		return 	
	end
	if params and params.gashapon then 
		ModelManager.TwistEggModel:initRedMap()
		ModelManager.TwistEggModel.recvRecords = params.gashapon.recvRecords
		ModelManager.TwistEggModel.drawCount = params.gashapon.count
		TwistEggModel:redCheck()
		Dispatcher.dispatchEvent(EventType.TwistEggView_refreshPanel)
	end
end


function TwistEggController:money_change(_,data)
	if data[GameDef.MoneyType.GashaponCoin] then
		TwistEggModel:redCheck()
	end
end

return TwistEggController