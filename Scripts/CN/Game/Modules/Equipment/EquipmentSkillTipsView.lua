--Name : EquipmentSkillTipsView.lua
--Author : generated by FairyGUI
--Date : 2020-4-7
--Desc : 

local EquipmentSkillTipsView,Super = class("EquipmentSkillTipsView", View)

function EquipmentSkillTipsView:ctor()
	--LuaLog("EquipmentSkillTipsView ctor")
	self._packName = "Equipment"
	self._compName = "EquipmentSkillTipsView"
	--self._rootDepth = LayerDepth.Window
	
end

function EquipmentSkillTipsView:_initEvent( )
	
end

function EquipmentSkillTipsView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Equipment.EquipmentSkillTipsView
		--{vmFieldsEnd}:Equipment.EquipmentSkillTipsView
	--Do not modify above code-------------
end

function EquipmentSkillTipsView:_initUI( )
	self:_initVM()

end




return EquipmentSkillTipsView