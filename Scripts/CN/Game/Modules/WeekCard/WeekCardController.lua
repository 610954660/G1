
local WeekCardController = class("WeekCardController", Controller)


function WeekCardController:Activity_UpdateData(_, params)
 	if params.type == GameDef.ActivityType.AccWeekCard then
		--  printTable(8848,"param.accWeekCard",params)
		 if params.endState then --如果是true 直接结束
			ModelManager.ActivityModel:speDeleteSeverData(params.type)
			return
		end
 		WeekCardModel:initEndTime(params.accWeekCard)
	end
end

function WeekCardController:GamePlay_UpdateData (_,params)
	-- printTable(8848,"WeekCardController",param)
	if params.gamePlayType == GameDef.GamePlayType.WeekCard then
		-- printTable(8848,">>>param.gp.weekCard>>>",param.gp.weekCard)
		WeekCardModel:initData(params.gp.weekCard)
	end
end



return WeekCardController