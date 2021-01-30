--[[
	name: VoidlandSkillView1
	author: zn
]]

local base = require "Game.Modules.Voidland.VoidSkillBaseView";
local VoidlandSkillView1, Super = class("VoidlandSkillView1", base)

function VoidlandSkillView1:ctor()
	self._packName = "Voidland";
	self._compName = "VoidlandSkillView1";

	self.skillCell = false;
	self.txt_skillDesc = false;
	self.bgUrl = "UI/Voidland/bg1.png";
	self.roleUrl = "UI/Voidland/role.png";
end

function VoidlandSkillView1:afterInit()
	local rootView = self.view;
	-- printTable(2233, "1111111111111", rootView:getChildAutoType("skillCell"));
	self.skillCell = BindManager.bindSkillCell(rootView:getChildAutoType("skillCell"));
	self.txt_skillDesc = rootView:getChildAutoType("txt_skillDesc");

	local skillId = self.skillList[1];
	print(2233, "----------------", skillId);
	local skillConf = DynamicConfigData.t_skill[skillId];
	-- self.skillCell:setData(skillId);
	self.txt_skillDesc:setText(skillConf.showName);
	
	local VoidSkillConf = DynamicConfigData.t_VoidlandSkill[skillId];
	if (VoidSkillConf) then
		local url = ModelManager.CardLibModel:getItemIconByskillId(VoidSkillConf.skillIcon)
		self.skillCell.iconLoader:setURL(url)
	end
end

return VoidlandSkillView1