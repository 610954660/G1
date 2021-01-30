-- add by zn
-- 克制组合

local HelpRestraintPanel = class("HelpRestraintPanel", BindView)

function HelpRestraintPanel:ctor()
    self._packName = "HelpSystem"
    self._compName = "HelpRestraintPanel"
    self._data = false;
    -- self._rootDepth = LayerDepth.PopWindow
end

function HelpRestraintPanel:_initUI()
    local root = self
    local rootView = self.view
        root.desc = rootView:getChildAutoType("desc");
        root.list_restraint = rootView:getChildAutoType("list_restraint");
        root.list_skill = rootView:getChildAutoType("list_skill");
        root.txt_skill = rootView:getChildAutoType("desc_passkill");
        self.list_restraint:setItemRenderer(function (idx, obj)
            self:upOneLine(idx, obj);
        end)
end

function HelpRestraintPanel:setData(data)
    self._data = data;
    self.list_restraint:setNumItems(1);
    self.desc:setText(data.desr)
    self.txt_skill:setText(data.skilldesr);
    local skills = data.skill;
    self.list_skill:setItemRenderer(function (idx, obj)
        local skillId = skills[idx + 1];
        local skillInfo = DynamicConfigData.t_passiveSkill[skillId];
        if (skillInfo) then
            local icon = obj:getChildAutoType("iconLoader");
            icon:setIcon(ModelManager.CardLibModel:getItemIconByskillId(skillInfo.icon))
            obj:getChildAutoType("txt_name"):setText(skillInfo.name)
            obj:removeClickListener()
            obj:addClickListener(function ()
                ViewManager.open("ItemTips", {codeType = CodeType.PASSIVE_SKILL, id = skillId, data = skillInfo})
            end)
        end
    end)
    self.list_skill:setNumItems(#skills)
end

function HelpRestraintPanel:upOneLine(idx, obj)
    local d = self._data;
    local cardInfo = obj:getChildAutoType("cardInfo");
    self:setCardInfo(cardInfo, d.hero1[1]);
    local list = obj:getChildAutoType("list_cardInfo");
    list:setItemRenderer(function (i, item)
        self:setCardInfo(item, d.hero2[i + 1]);
    end)
    list:setNumItems(#d.hero2)
end

function HelpRestraintPanel:setCardInfo(obj, info)
    local cardItem = obj:getChildAutoType("cardItem")
    if (not obj.cardCell) then
        obj.cardCell = BindManager.bindCardCell(cardItem)
    end
    obj.cardCell:setData(info.heroCode);
    cardItem:setGrayed(false)
    cardItem:setGrayed(not HandbookModel:isCardGot(info.heroCode));

    local skills = {};
    for i = 1, 4 do
        if (info["skill"..i]) then
            table.insert(skills, info["skill"..i]);
        end
    end
    local list = obj:getChildAutoType("list_skill");
    local heroConf = DynamicConfigData.t_hero[info.heroCode];
    local conf = DynamicConfigData.t_skill;
    list:setItemRenderer(function (idx, item)
        if (not item.skill) then
            item.skill = BindManager.bindSkillCell(item);
        end
        local skillId = heroConf["skill"..skills[idx + 1]][1]
        item.skill:setData(skillId, true);
        item.skill:showSkillName(0, conf[skillId].skillName)
        local itemName = item.skill.view:getChildAutoType("itemName");
        itemName:setColor(cc.c3b(0x45, 0x45, 0x45));
        itemName:setFontSize(24);
        item:removeClickListener()
        item:addClickListener(function()
            ViewManager.open("ItemTips", {codeType = CodeType.SKILL, id = skillId, heroId = info.heroCode})
        end)
    end)
    list:setNumItems(#skills);

    cardItem:removeClickListener()
    cardItem:addClickListener(function()
        local conf = DynamicConfigData.t_HeroTotems
        local arr = conf[heroConf.category]
        local h = false
        for _, d in pairs(arr) do
            if (d.hero == info.heroCode) then
                h = d
                break
            end
        end
        local info = {index = 1,heroId = info.heroCode, heroList = {h}};
        ViewManager.open("HeroInfoView", info);
    end)
end

return HelpRestraintPanel