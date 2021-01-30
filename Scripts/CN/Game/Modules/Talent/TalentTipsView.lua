-- add by zn
-- 特性提示界面

local TalentTipsView = class("TalentTipsView", Window)

function TalentTipsView:ctor()
    self._packName = "Talent"
    self._compName = "TalentTipsView"
    self._rootDepth = LayerDepth.PopWindow
    self.data = self._args.data
    self.pos = self._args.pos
end

function TalentTipsView:_initUI()
    local root = self
    local rootView = self.view
        root.talentCell = rootView:getChildAutoType("talentCell")
        root.txt_name = rootView:getChildAutoType("txt_name")
        root.txt_desc = rootView:getChildAutoType("txt_desc")
        root.btn_forget = rootView:getChildAutoType("btn_forget")
        root.btn_close = rootView:getChildAutoType("btnclose")

    local conf = DynamicConfigData.t_passiveSkill[self.data.skillId]
    local path = ModelManager.CardLibModel:getItemIconByskillId(conf.icon)
    self.talentCell:getController("c1"):setSelectedIndex(2)
    self.talentCell:setIcon(path)
    self.txt_name:setText(conf.name)
    self.txt_desc:setText(conf.desc)
    self.btn_forget:addClickListener(function()
        self:sureForget()
    end)
    self.btn_close:addClickListener(function()
        self:closeView()
    end)
end

function TalentTipsView:sureForget()
    local onYes = function()
        local hero = ModelManager.CardLibModel.curCardStepInfo
        TalentModel:forgetTalent(hero.uuid, self._args.index)
        self:closeView()
    end
    local conf = DynamicConfigData.t_PassiveConst[1]
    local cost = conf.passiveResetCost[1]
    ViewManager.open("TalentForgetSureView", {onYes= onYes, cost = cost})
end

return TalentTipsView