--Date :2020-12-07
--Author : generated by FairyGUI
--Desc : 

local TrainingController = class("Training",Controller)

function TrainingController:init()
	
end

function TrainingController:GamePlay_UpdateData (_,params)
	printTable(5656,params,"GamePlay_UpdateData")
	if params.gamePlayType == GameDef.GamePlayType.TrainingCamp then
		--printTable(5656,params,"训练营任务数据")
		TrainingModel:initData(params.gp)
	end
end

return TrainingController