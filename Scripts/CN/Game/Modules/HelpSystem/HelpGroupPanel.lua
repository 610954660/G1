-- add by zn
-- 组合

local HelpGroupPanel = class("HelpGroupPanel", BindView)

function HelpGroupPanel:ctor(view)
    self.data = false;
end

function HelpGroupPanel:_initUI()
    local root = self
    local rootView = self.view
        root.txt_group = rootView:getChildAutoType("desc_gourp");
        root.txt_passkill = rootView:getChildAutoType("desc_passkill");
        root.txt_progress = rootView:getChildAutoType("txt_progress");
        root.cardInfo1 = rootView:getChildAutoType("cardInfo1");
        root.cardInfo2 = rootView:getChildAutoType("cardInfo2");
        root.cardInfo3 = rootView:getChildAutoType("cardInfo3");
        root.list_skill = rootView:getChildAutoType("list_skill");
        root.txt_skill = rootView:getChildAutoType("desc_passkill");
        root.itemCell = BindManager.bindItemCell(rootView:getChildAutoType("itemCell"));
end

function HelpGroupPanel:setData(conf)
    self.data = conf;
    self.txt_group:setText(conf.desr or "");
    self.txt_passkill:setText("");
    self.txt_skill:setText(conf.skilldesr);
    local heroes = conf.hero1;
    local len = #heroes;
    local ctrl = self.view:getController("c1");
    ctrl:setSelectedIndex(len - 2);
    for i = 1, len do
        self:setCardInfo(self["cardInfo"..i], heroes[i]);
    end
    
    local skills = conf.skill;
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

    local reward = conf.reward[1]
    self.itemCell:setData(reward.code, reward.amount, reward.type);
    self.itemCell:setClickable(false);

    self.itemCell.view:removeClickListener(888);
    local isGot = false;
    for _, id in pairs(HandbookModel.heroGroup) do
        if (id == conf.id) then
            isGot = true;
            break;
        end
    end
    if (isGot) then
        self.txt_progress:setText("");
        self.itemCell:setIsHook(true);
    else
        self.itemCell:setIsHook(false);
        local count = 0;
        for i = 1, len do
            if (HandbookModel:isCardGot(heroes[i].heroCode)) then
                count = count + 1;
            end
        end
        self.txt_progress:setText(string.format(Desc.handbook_groupConnect, count, len));
        self.itemCell:setReceiveFrame(count == len);
        if (count == len) then
            self.itemCell.view:addClickListener(function (context)
                HandbookModel:getGroupConnectReward(conf.id)
            end, 888)
        end
    end
end

function HelpGroupPanel:setCardInfo(obj, info)
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
    local conf = DynamicConfigData.t_skill
    list:setItemRenderer(function (idx, item)
        if (not item.skill) then
            item.skill = BindManager.bindSkillCell(item);
        end
        local skillId = heroConf["skill"..skills[idx + 1]][1]
        item.skill:setData(skillId);
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

function HelpGroupPanel:handbook_groupaward()
    self:setData(self.data);
end

return HelpGroupPanel