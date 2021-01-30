--added by xhd
--碎品背包
local PackBaseModel = require "Game.Modules.Pack.PackBaseModel"
local HeroCompPackModel = class("HeroCompPackModel", PackBaseModel)

function HeroCompPackModel:getEquipByPos(pos)
	local item = self.__packItems[pos]
	if ItemsUtil.isTrueItem(item) then
		return item
	end
	return nil
end

function HeroCompPackModel:redCheck( ... )
	for k,v in pairs(self.__packItems) do
		local code = v:getItemCode()
		if DynamicConfigData.t_heroCombine[code] and v:getItemAmount()>= DynamicConfigData.t_heroCombine[code].amount then
			RedManager.updateValue("V_BAG_HEROCOMP",true)
			return
		end
	end
	RedManager.updateValue("V_BAG_HEROCOMP",false)
end

return HeroCompPackModel
