--[[
	name: VoidlandSkillView2
	author: zn
]]

local base = require "Game.Modules.Voidland.VoidSkillBaseView";
local VoidlandSkillView2 = class("VoidlandSkillView2", base)

function VoidlandSkillView2:ctor()
	self._packName = "Voidland";
	self._compName = "VoidlandSkillView2";

	self.bgUrl = "UI/Voidland/bg2.png";
	self.roleUrl = "UI/Voidland/role.png";
end

function VoidlandSkillView2:upSkillItems(idx, obj)
	-- print(2233, "======== VoidlandSkillView2:upSkillItems");
	local skillId = self.skillList[idx + 1];
	local skillCell = BindManager.bindSkillCell(obj:getChildAutoType("skillCell"))
	local skillConf = DynamicConfigData.t_skill[skillId];
	local VoidSkillConf = DynamicConfigData.t_VoidlandSkill[skillId];
	if (VoidSkillConf) then
		local url = ModelManager.CardLibModel:getItemIconByskillId(VoidSkillConf.skillIcon)
		skillCell.iconLoader:setURL(url)
	end
	-- obj:getChildAutoType("txt_skillName"):setText(skillConf.skillName);
	obj:getChildAutoType("txt_desc/txt_desc"):setText(skillConf.showName);
end


return VoidlandSkillView2