---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: ljj
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local CardSkillUpView,Super = class("CardSkillUpView",Window)

function CardSkillUpView:ctor(args)
	self._packName = "CardSystem"
	self._compName = "CardSkillUpView"
	self._rootDepth = LayerDepth.PopWindow
	self._isFullScreen = true
	self.skillCell = false
	self.data = args
	self.txt_skillLv1 = false
	self.txt_skillLv2 = false
end    

function CardSkillUpView:_initUI()
	local viewRoot = self.view
	local skillCell =viewRoot:getChild("skillCell");
	local c1 =viewRoot:getController("c1");
	self.txt_skillLv1 = viewRoot:getChild("txt_skillLv1");
	self.txt_skillLv2 = viewRoot:getChild("txt_skillLv2");
	self.skillCell = BindManager.bindSkillCell(skillCell)
	self.skillCell:setData(self.data.heroInfo.heroDataConfiger["skill"..self.data.upIndex][self.data.from + 1])
	self.txt_skillLv1:setText("Lv."..self.data.from)
	self.txt_skillLv2:setText("Lv."..self.data.to)
	if self.data.from == 0 then
		c1:setSelectedIndex(1)
	else
		c1:setSelectedIndex(0)
	end
end

--绑定事件
function CardSkillUpView:bindEvent()
	
end



function CardSkillUpView:_enter()

end
function CardSkillUpView:_exit()

end

return CardSkillUpView