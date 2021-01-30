-- add by zn
-- 特性装备界面

local TalentEquipView = class("TalentEquipView", Window)

function TalentEquipView:ctor()
    self._packName = "Talent"
    self._compName = "TalentEquipView"
    -- self._rootDepth = LayerDepth.PopWindow
    self.selected = false
end

function TalentEquipView:_initUI()
    local root = self
    local rootView = self.view
        for i = 1, 5 do
            local gird = rootView:getChildAutoType("Gird"..i)
            root["gird"..i] = gird
        end
        root.btn_help = rootView:getChildAutoType("btn_help")
        root.btn_shop = rootView:getChildAutoType("btn_shop")
        root.txt_success = rootView:getChildAutoType("txt_success")

    self.selected = 1
    self.gird1:setSelected(true)
    self:_refresh()
end

function TalentEquipView:_initEvent()


	self.btn_shop:addClickListener(function()
        ModuleUtil.openModule(ModuleId.Shop_Talent.id)
    end)
    self.btn_help:removeClickListener()
    self.btn_help:addClickListener(function()
        RollTips.showHelp(Desc["help_StrTitle"..ModuleId.CardTalent.id], Desc["help_StrDesc"..ModuleId.CardTalent.id])
    end)
end

function TalentEquipView:cardView_updateInfo()
    self:_refresh()
end

function TalentEquipView:cardView_activeSkillFail()
    self:_refresh()
end

function TalentEquipView:_refresh()
    local hero = ModelManager.CardLibModel.curCardStepInfo
    local girdInfo = TalentModel:getHeroTalentInfo(hero)
    local equipCount = 0
    for i = 1, #girdInfo do
        local obj = self["gird"..i]
        RedManager.register("V_passiveSkill"..hero.uuid.."_"..i, obj:getChildAutoType("img_red"))
        self:upGirdShow(i, obj, girdInfo[i])
        if (girdInfo[i].state == 2) then
            equipCount = equipCount + 1
        end
    end
    if (equipCount == 0) then
        self.txt_success:setText(Desc.Talent_successRate1)
    else
        local sucConf = DynamicConfigData.t_PassiveSkillLearn[equipCount]
        local failCount = hero.newPassiveSkillCount
        if (sucConf and failCount) then
            local count = sucConf.pCount - failCount
            if (count > 0) then
                self.txt_success:setText(string.format(Desc.Talent_successRate2, count))
            else
                self.txt_success:setText(Desc.Talent_successRate1)
            end
        else
            self.txt_success:setText("")
        end
    end

    -- local grayed = girdInfo[1].state == 0 or girdInfo[1].state == 2
    -- self.btn_learn:setGrayed(grayed)
    -- self.btn_learn:setTouchable(not grayed)
end

function TalentEquipView:upGirdShow(index, obj, data)
    local ctrl = obj:getController("c1");
    ctrl:setSelectedIndex(data.state)
    local girdConf = DynamicConfigData.t_PassiveSkillOpen[index]
    if (data.state == 2 or data.skillId) then
        local conf = DynamicConfigData.t_passiveSkill[data.skillId]
        local path = ModelManager.CardLibModel:getItemIconByskillId(conf.icon)
        obj:setIcon(path)
    elseif data.state == 0 then
        local txt_unlock = obj:getChildAutoType("txt_unlock")
        txt_unlock:setText(string.format(Desc.Talent_unlockDesc, data.star))
    end
    obj:removeClickListener()
    obj:addClickListener(function()
        if (data.state == 2 or data.skillId) then
            ViewManager.open("TalentTipsView", {pos = obj:getPosition(), data = data, index = index})
            return;
        elseif data.state == 1 then

            ViewManager.open("TalentLearnView", {index = index, listType = girdConf.typeList})
        else
            RollTips.show(string.format(Desc.Talent_unlockDesc, data.star))
        end
        if (self.selected) then
            local gird = self["gird"..self.selected]
            gird:setSelected(false)
            self.selected = false
        end
        obj:setSelected(true)
        self.selected = index
    end)
end

return TalentEquipView