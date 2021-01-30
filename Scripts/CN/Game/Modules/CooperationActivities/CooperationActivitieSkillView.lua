--Date :2021-01-18
--Author : generated by FairyGUI
--Desc :

local CooperationActivitieSkillView, Super = class("CooperationActivitieSkillView", Window)

function CooperationActivitieSkillView:ctor()
    --LuaLog("CooperationActivitieSkillView ctor")
    self._packName = "CooperationActivities"
    self._compName = "CooperationActivitieSkillView"
    self._rootDepth = LayerDepth.PopWindow
end

function CooperationActivitieSkillView:_initEvent()
    self.closeButton0:addClickListener(
        function()
            self:closeView()
        end
    )
end

function CooperationActivitieSkillView:_initVM()
    local viewNode = self.view
    ---Do not modify following code--------
    --{autoFields}:CooperationActivities.CooperationActivitieSkillView
	self.closeButton0 = viewNode:getChildAutoType('closeButton0')--GButton
	self.list_skill = viewNode:getChildAutoType('list_skill')--GList
 --{autoFieldsEnd}:CooperationActivities.CooperationActivitieSkillView
    --Do not modify above code-------------
end

function CooperationActivitieSkillView:_initUI()
    self:_initVM()
    local bossId = self._args.monsterId
    local configInfo = DynamicConfigData.t_monster[bossId]
    if configInfo then
        self.list_skill:setItemRenderer(
            function(index, obj)
                local skillItem = configInfo.skill[index + 1]
                local skillCellObj = obj:getChild("skillCell")
                local skillCell = BindManager.bindSkillCell(skillCellObj)
                skillCell:setData(skillItem)
                skillCellObj:removeClickListener(100)
                skillCellObj:addClickListener(
                    function()
                        ViewManager.open("ItemTips", {codeType = CodeType.SKILL, id = skillItem})
                    end,
                    100
				)
				local conf = DynamicConfigData.t_skill[skillItem]
				local txt_skillName = obj:getChild("txt_skillName")
				txt_skillName:setText(conf.skillName)
				local txt_seklldesc = obj:getChild("txt_seklldesc")
				txt_seklldesc:setText(conf.showName)
            end
        )
        self.list_skill:setNumItems(#configInfo.skill)
    end
end

return CooperationActivitieSkillView