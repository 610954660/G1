--Date :2020-12-24
--Author : generated by FairyGUI
--Desc : 

local FullsrGiftController = class("FullsrGift",Controller)

function FullsrGiftController:init()
	
end

function FullsrGiftController:Activity_UpdateData(_, param)
	if param.type == GameDef.ActivityType.ServerGroupBuy then
		printTable(5656,"全服礼包",param)
		if param.endState then
			FullsrGiftModel:setActvieOpen(false)
			ActivityModel:speDeleteSeverData(param.type)
		end
		FullsrGiftModel:initData(param)
	end
end




return FullsrGiftController