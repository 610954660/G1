-- add by zn
-- 技能解锁

local HallowSkillUnlockView = class("HallowSkillUnlockView", Window)

function HallowSkillUnlockView:ctor()
    self._packName = "HallowSys"
    self._compName = "HallowSkillUnlockView"
    self._rootDepth = LayerDepth.PopWindow
end

function HallowSkillUnlockView:_initUI()
    local root = self
    local rootView = self.view
        root.txt_skillName = rootView:getChildAutoType("txt_skillName");
        root.txt_desc = rootView:getChildAutoType("txt_skillDesc");
        root.skillCell = BindManager.bindSkillCell(rootView:getChildAutoType("skillCell"));
    local skillId = self._args.skillId;
    local conf = DynamicConfigData.t_skill[skillId];
    if (conf) then
        self.txt_skillName:setText(conf.skillName);
        self.txt_desc:setText(conf.showName);
        self.skillCell:setData(skillId);
    end
    self.view:getTransition("t0"):play(function()
        -- self.view:getController("showCtrl"):setSelectedIndex(1);
    end)
end

function HallowSkillUnlockView:_initEvent()

end

return HallowSkillUnlockView