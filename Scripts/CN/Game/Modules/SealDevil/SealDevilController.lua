--Date :2020-12-29
--Author : generated by FairyGUI
--Desc : 

local SealDevilController = class("SealDevil",Controller)

function SealDevilController:init()
	
end


function SealDevilController:DevilRoadUpdateData(_,params)
	printTable(5656,params,"params封魔之路数据")

end


function SealDevilController:DevilRoad_UpdateGridInfo(_,params)
	printTable(5656,params,"params封魔之路某个格子更新")
	Dispatcher.dispatchEvent(EventType.DevilRoad_updateGrid,{gridInfo=params})
end


return SealDevilController