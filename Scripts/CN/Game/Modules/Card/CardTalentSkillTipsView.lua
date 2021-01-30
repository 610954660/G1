---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by:
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local CardTalentSkillTipsView, Super = class("CardTalentSkillTipsView", Window)
function CardTalentSkillTipsView:ctor()
    self._packName = "CardSystem"
    self._compName = "CardTalentSkillTipsView"
	self._rootDepth = LayerDepth.PopWindow
end

function CardTalentSkillTipsView:_initUI()
    self:bindEvent()
end

--绑定事件
function CardTalentSkillTipsView:bindEvent()
    local skillInfo = self._args[1]
    local viewRoot = self.view
    local skillName = viewRoot:getChild("skillName")
    local skillDetails = viewRoot:getChild("skillDetails")
    local skillCell = viewRoot:getChild("skillCell")
    local skillContro = viewRoot:getController("c1")
    local btnActive = viewRoot:getChild("btn_active")
    local btnLearn = viewRoot:getChild("btn_learn")
	
	
    --放了一张技能图片
    --[[local closeBtn = viewRoot:getChild("closeButton1")
    closeBtn:addClickListener(
        function(context)
            ViewManager.close("CardTalentSkillTipsView")
        end
    )--]]
    local skillId = self._args[1].id
	
	local skillCellItem = BindManager.bindSkillCell(skillCell)
	skillCellItem:setData(skillId)
	
    local heroInfo = ModelManager.CardLibModel.curCardStepInfo

    if self._args[2] == 1 then --主动技能
        skillContro:setSelectedIndex(0)
        skillName:setText(skillInfo.skillName)
        skillDetails:setText(skillInfo.showName)
    elseif self._args[2] == 2 then --被动技能

        if heroInfo.passiveSkill[skillId] then
        	skillContro:setSelectedIndex(0) --不用去学习了
        else
        skillContro:setSelectedIndex(1)
        end
        skillName:setText(skillInfo.name)
        skillDetails:setText(skillInfo.desc)
    end
    btnActive:addClickListener(
        function(context)
            self:closeView()
            ViewManager.open("CardDetailsSkillActiveView", {skillId})
        end
    )

    --[[btnLearn:addClickListener(
        function(context)
            self:closeView()
            ViewManager.open("CardLearnSkillView", {skillId})
        end
    )--]]
end

function CardTalentSkillTipsView:_enter()
end

return CardTalentSkillTipsView
