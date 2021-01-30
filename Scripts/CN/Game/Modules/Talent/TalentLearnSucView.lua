

local TalentLearnSucView = class("TalentLearnSucView", Window)

function TalentLearnSucView:ctor()
    self._packName = "Talent";
    self._compName = "TalentLearnSucView";
    self._rootDepth = LayerDepth.PopWindow;
    self.skillId = self._args.skillId;
    self.newInfo = self._args.newInfo.passiveSkill;
    self.oldInfo = self._args.oldInfo.passiveSkill;
end

function TalentLearnSucView:_initUI()
    local root = self;
    local rootView = self.view;
        root.oldTalent = rootView:getChildAutoType("oldTalent");
        root.newTalent = rootView:getChildAutoType("newTalent");
        root.title = rootView:getChildAutoType("title");

    self.view:getTransition("t0"):play(function()
        self.view:getController("showCtrl"):setSelectedIndex(1);
    end)
    local oldSkillId = false;
    for k in pairs(self.oldInfo) do
        if (not self.newInfo[k]) then
            oldSkillId = k;
            break;
        end
    end
    local conf = DynamicConfigData.t_passiveSkill;
    local newName = conf[self.skillId] and conf[self.skillId].name or "";
    local oldName = conf[oldSkillId] and conf[oldSkillId].name or "";
    self.title:setText(string.format(Desc.card_talentLearTip, newName, oldName));
    self:upTalentInfo(self.oldTalent, oldSkillId);
    self:upTalentInfo(self.newTalent, self.skillId);
end

function TalentLearnSucView:upTalentInfo(obj, skillId)
    local skillItem = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
    skillItem:setData(skillId, 1, CodeType.PASSIVE_SKILL)
    local data = DynamicConfigData.t_passiveSkill[skillId];
    obj:getChildAutoType("txt_name"):setText(string.format("[color=#ca5600]%s[/color]", data.name));
    skillItem.view:getChildAutoType("frame"):setIcon(PathConfiger.getPassiveSkillFrame(data.quality));
    -- self.txt_skillName:setText(self._skillData.name)
    obj:getChildAutoType("txt_desc"):setText(data.desc)
end

return TalentLearnSucView;