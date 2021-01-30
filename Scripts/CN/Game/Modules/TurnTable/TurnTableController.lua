
local TurnTableController = class("TurnTableController", Controller)


function TurnTableController: Activity_UpdateData(_, param)
	-- printTable(1, param)
	if param.type == GameDef.ActivityType.PowerTurnTable then
		-- LuaLogE(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 转盘数据更新");
		-- printTable(1, param.powerTurnTable);
		TurnTableModel:setData(param.powerTurnTable)
		Dispatcher.dispatchEvent(EventType.activity_TurnTableActiveUpdate);
		
	end
end

return TurnTableController