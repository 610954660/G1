--Date :2020-11-20
--Author : generated by FairyGUI
--Desc : 

local CrossPVPController = class("CrossPVP",Controller)

function CrossPVPController:init()
	
end
function CrossPVPController:HorizonPvp_Info(_,data)
	CrossPVPModel:setSeverData(data)
end
function CrossPVPController:Limit_ConsumeTimes( _,data)
	if data.type == GameDef.GamePlayType.HorizonPvp then
		CrossPVPModel:addLimitNum(1)
	end
end
function CrossPVPController:Limit_ResetInfos(_,data)
	CrossPVPModel:setLimitNum(0)
end

return CrossPVPController