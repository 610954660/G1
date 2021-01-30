--added by xhd
--特殊背包
local PackBaseModel = require "Game.Modules.Pack.PackBaseModel"
local SpecialPackModel = class("SpecialPackModel", PackBaseModel)

function SpecialPackModel:getEquipByPos(pos)
	local item = self.__packItems[pos]
	if ItemsUtil.isTrueItem(item) then
		return item
	end
	return nil
end


function SpecialPackModel:redCheck(itemData, curAmount)
	--红点检测
	local itemInfo = itemData:getItemInfo()
	local type = itemInfo.type
	local code = itemInfo.code
	local ItemType = GameDef.ItemType
	
	--灵气（卡牌升级）
	if(code == 10000006) then
		ModelManager.CardLibModel:redCheck()
	elseif(code == 10000007) then
		ModelManager.CardLibModel:redCheck()
	end

	for k,v in pairs(self.__packItems) do
		if v:getType() == GameDef.ItemType.HeroCard then
			RedManager.updateValue("V_BAG_SPECIAL",true)
			return
		end
	end
	RedManager.updateValue("V_BAG_SPECIAL",false)

end

return SpecialPackModel
