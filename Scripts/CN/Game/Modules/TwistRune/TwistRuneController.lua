-- This is an automatically generated class by FairyGUI.

local TwistRuneController = class("TwistRune",Controller)

function TwistRuneController:init()
	
end

function TwistRuneController:Activity_UpdateData(_, params)


	if params.type ~= GameDef.ActivityType.RuneMission then  --RuneShop
		return
	end
	if params.endState then --如果是true 直接结束
		ModelManager.ActivityModel:speDeleteSeverData(params.type)
		return
	end
	print(5656,params.type)
	if params and params.equipMission then
	    TwistRuneModel:initData(params.equipMission)
	end
end



return TwistRuneController