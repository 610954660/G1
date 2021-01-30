--[[
	name: VoidlandSkillView3
	author: zn
]]

local base = require "Game.Modules.Voidland.VoidSkillBaseView";
local VoidlandSkillView3 = class("VoidlandSkillView3", base)

function VoidlandSkillView3:ctor()
	self._packName = "Voidland";
	self._compName = "VoidlandSkillView3";
	self.selectedItem = false;
end

function VoidlandSkillView3:afterInit()
	self.selectedItem = self.view:getChildAutoType("selected");
	local ctrl = self.view:getController("c1");
	local ctrl2 = self.view:getController("c2");
	self.list_skill:removeClickListener();
	self.list_skill:addEventListener(FUIEventType.TouchBegin, function()
		self.select = self.list_skill:getSelectedIndex() + 1;
		self:upSkillItems(self.select - 1, self.selectedItem);
		ctrl:setSelectedIndex(self.select - 1);
		if (ctrl2:getSelectedIndex() == 0) then
			ctrl2:setSelectedIndex(1);
		end
	end)
	self:upSkillItems(self.select - 1, self.selectedItem);
	ctrl:setSelectedIndex(self.select - 1);
	ctrl2:setSelectedIndex(1);
end

function VoidlandSkillView3:upSkillItems(idx, obj)
	local skillId = self.skillList[idx + 1];
	local icon = obj:getChildAutoType("icon");
	local skillInfo = DynamicConfigData.t_skill[skillId]
	if skillInfo then
		-- local ultSkillurl = ModelManager.CardLibModel:getItemIconByskillId(skillInfo.icon)
		-- icon:setURL(ultSkillurl) --放了一张技能图片
		-- obj:getChildAutoType("txt_skillName"):setText(skillInfo.skillName);
		obj:getChildAutoType("txt_desc"):setText(skillInfo.showName);
	end

	local VoidSkillConf = DynamicConfigData.t_VoidlandSkill[skillId];
	if (VoidSkillConf) then
		local ultSkillurl = ModelManager.CardLibModel:getItemIconByskillId(VoidSkillConf.skillIcon)
		icon:setURL(ultSkillurl) --放了一张技能图片
		obj:getChildAutoType("txt_skillName"):setText(VoidSkillConf.name);
		local ctrl = obj:getController("c1");
		ctrl:setSelectedIndex(VoidSkillConf.color or 3);
	end
end

return VoidlandSkillView3