--[[
	name: VoidlandSkillView
	author: zn
]]

local VoidlandSkillView = class("VoidlandSkillView", MutiWindow)

function VoidlandSkillView:ctor()
	self._packName = "Voidland";
	self._compName = "VoidlandSkillView";
	self._rootDepth = LayerDepth.PopWindow
	-- self.viewCtrlName = "ViewType";

	self.data = DynamicConfigData.t_VoidlandEvent[VoidlandModel.eventId];
	self._args.page = self.data.eventType - 1
end

return VoidlandSkillView