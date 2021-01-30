--Date :2020-12-16
--Author : generated by FairyGUI
--Desc : 

local ActGodsPrayController = class("ActGodsPray",Controller)

function ActGodsPrayController:init()
	
end


function ActGodsPrayController:Activity_UpdateData(_, param)
	if param.type == GameDef.ActivityType.GodsPray then
		printTable(5656,"神灵祈愿",param)
		ActGodsPrayModel:initData(param)
		if param.endState then
			ActivityModel:speDeleteSeverData(param.type)
		end
	end
end

function ActGodsPrayController:money_change(_, param)
	ActGodsPrayModel:updateRed()
	--printTable(5656,"货币变化",param)
end


return ActGodsPrayController