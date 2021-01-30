-- added by wyz
-- 精灵技能说明界面

local ElvesSkillTipsInfoView = class("ElvesSkillTipsInfoView",Window)

function ElvesSkillTipsInfoView:ctor()
    self._packName  = "ElvesSystem"
    self._compName  = "ElvesSkillTipsInfoView"
    self._rootDepth = LayerDepth.AlertWindow

    self.skillCell = false
    self.txt_Lv     = false
    self.txt_skillName = false
    self.txt_skillCD = false
    self.txt_enerval = false
    self.txt_SkillInfo = false
    self.txt_upTips = false
end

function ElvesSkillTipsInfoView:_initUI()
    self.skillCell = self.view:getChildAutoType("skillCell")
    self.txt_Lv     = self.view:getChildAutoType("txt_Lv")
    self.txt_skillName = self.view:getChildAutoType("txt_skillName")
    self.txt_skillCD = self.view:getChildAutoType("txt_skillCD")
    self.txt_enerval = self.view:getChildAutoType("txt_enerval")
    self.txt_SkillInfo = self.view:getChildAutoType("txt_SkillInfo")
    self.txt_upTips = self.view:getChildAutoType("txt_upTips")
end

function ElvesSkillTipsInfoView:_initEvent()
    self:refreshPanal()
end

function ElvesSkillTipsInfoView:refreshPanal()
    local data      = self._args.data
    local ElfStar   = DynamicConfigData.t_ElfStar[data.elfId][data.star]
    local skillCell = BindManager.bindSkillCell(self.skillCell)
    skillCell:setData(data.skillId)
    
    self.txt_Lv:setText("Lv." .. data.showLevel)
    local skillInfo     = DynamicConfigData.t_skill[data.skillId]
    self.txt_skillName:setText(skillInfo.skillName)
    self.txt_enerval:setText(string.format(Desc.ElvesSystem_elvescostEnergy2,data.costEnergy))
    self.txt_skillCD:setText(string.format(Desc.ElvesSystem_skillCD2,data.coolDown))
    self.txt_SkillInfo:getChildAutoType("title"):setText(ElfStar.skillTipDesc)

    self.txt_upTips:setText(Desc.ElvesSystem_str2)
end

return ElvesSkillTipsInfoView