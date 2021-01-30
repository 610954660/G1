--added by xhd
--装备背包
local PackBaseModel = require "Game.Modules.Pack.PackBaseModel"
local EquipmentPackModel, Super = class("EquipmentPackModel", PackBaseModel)

function EquipmentPackModel:getEquipByPos(pos)
	local item = self.__packItems[pos]
	if ItemsUtil.isTrueItem(item) then
		return item
	end
	return nil
end

function EquipmentPackModel:redCheck(itemData, curAmount)
	--红点检测
	EquipmentModel:redCheck()
end

function EquipmentPackModel:setPack(data)
	Super.setPack(self, data);
	local eqs = data.items;
	for _, eq in pairs(eqs) do
		local eqData = eq.specialData and eq.specialData.equipment or {};
		local info = {
			code = eq.code,
			id = eq.id,
			uuid = eq.uuid,
		}
		for k, v in pairs(eqData) do
			info[k] = v;
		end
		EquipmentModel:setSkillData(info.uuid, info);
	end
	-- EquipmentModel:setSkillData(eq.uuid, eq);
end

return EquipmentPackModel
