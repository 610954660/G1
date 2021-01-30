
-- add by zn
-- 特性激活成功弹窗

local TalentActiveSucView = class("TalentActiveSucView", Window)

function TalentActiveSucView:ctor()
    self._packName = "Talent";
    self._compName = "TalentActiveView";
    self._rootDepth = LayerDepth.PopWindow;
    self.skillId = self._args.skillId;
end

function TalentActiveSucView:_initUI()
    local root = self;
    local rootView = self.view;
        root.txt_name = rootView:getChildAutoType("txt_name");
        root.txt_desc = rootView:getChildAutoType("txt_desc");
        root.itemCell = rootView:getChildAutoType("itemCell");

    self.view:getTransition("t0"):play(function()
        self.view:getController("showCtrl"):setSelectedIndex(1);
    end)

    if (self.skillId) then
        local skillItem = BindManager.bindItemCell(self.itemCell)
        skillItem:setData(self.skillId, 1, CodeType.PASSIVE_SKILL)
        local data = DynamicConfigData.t_passiveSkill[self.skillId];
        self.txt_name:setText(string.format("[color=#ca5600]%s[/color]", data.name));
        skillItem.view:getChildAutoType("frame"):setIcon(PathConfiger.getPassiveSkillFrame(data.quality));
        -- self.txt_skillName:setText(self._skillData.name)
        self.txt_desc:setText(data.desc)
    end
end

return TalentActiveSucView;