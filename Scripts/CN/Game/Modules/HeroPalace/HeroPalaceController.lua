--Name : HeroPalaceController.lua
--Author : generated by FairyGUI
--Date : 2020-4-15
--Desc : 

local HeroPalaceController = class("HeroPalaceController",Controller)

function HeroPalaceController:init()
	
end


function HeroPalaceController:HeroPalace_UpdateGroupA(_, info)
	ModelManager.HeroPalaceModel:updateGroupA(info)
end

function HeroPalaceController:HeroPalace_ActivateCrystal(_, info)
	ModelManager.HeroPalaceModel:activateCrystal(info)
end

--卡牌添加或者减少了，检查红点
function HeroPalaceController:cardView_CardAddAndDeleInfo(_, info)
	ModelManager.HeroPalaceModel:redCheckAdd()
end




function HeroPalaceController:money_change(_,data)
	--if data[1].type == 8 then
		ModelManager.HeroPalaceModel:redCheckActive()
		ModelManager.HeroPalaceModel:redCheckUpgrade()
	--end
end

function HeroPalaceController:pack_item_change(_,data)
	--if data[1].type == 8 then
		ModelManager.HeroPalaceModel:redCheckActive()
	--end
end


return HeroPalaceController