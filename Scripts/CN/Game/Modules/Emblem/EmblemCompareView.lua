-- add by zn
-- 装备比较界面
local EmblemCell = require "Game.Modules.Emblem.EmblemCell";
local EmblemCompareView = class("EmblemCompareView", Window)

function EmblemCompareView:ctor()
    self._packName = "Emblem"
    self._compName = "EmblemCompareView"
    self.data = self._args.data;
    self.hero = false;
    self.winType = self._args.winType
    self.equiped = self._args.equiped
    self.category = self._args.category
    self._rootDepth = self.winType == "tips" and LayerDepth.Tips or LayerDepth.PopWindow
end

function EmblemCompareView:_initUI()
    local root = self
    local rootView = self.view
        for i = 1, 2 do
            local equipInfo = rootView:getChildAutoType("equipInfo"..i);
            root["equipInfo"..i] = equipInfo;
            if (not equipInfo.cell) then
                local em = equipInfo:getChildAutoType("emblemCell");
                em:getController("c2"):setSelectedIndex(1);
                equipInfo.cell = EmblemCell.new(em);
            end
            equipInfo.txt_name = equipInfo:getChildAutoType("txt_name");
            equipInfo.txt_color = equipInfo:getChildAutoType("txt_color"); -- 品质
            equipInfo.txt_category = equipInfo:getChildAutoType("txt_category"); -- 同种族激活
            equipInfo.list_attr = equipInfo:getChildAutoType("list_attr"); -- 属性
            equipInfo.list_suit = equipInfo:getChildAutoType("list_suit"); -- 套装
            equipInfo.headIcon = equipInfo:getChildAutoType("headIcon");
            equipInfo.btn_showMax = equipInfo:getChildAutoType("btn_showMax");
            equipInfo.list_max = equipInfo:getChildAutoType("list_max");
            equipInfo.txt_maxTitle = equipInfo:getChildAutoType("txt_maxTitle");
        end
        root.btn_rebuild = rootView:getChildAutoType("btn_rebuild");
        root.btn_upStar = rootView:getChildAutoType("btn_upStar");
        root.btn_unequip = rootView:getChildAutoType("btn_unequip");
        root.btn_equip = rootView:getChildAutoType("btn_equip");
        root.btn_close = rootView:getChildAutoType("blackbg11");

    -- 当前选中的英雄
    if (self._args.withHero) then
        -- local heroList = CardLibModel:getHeroInfoToIndex();
        self.hero = ModelManager.CardLibModel.curCardStepInfo;-- heroList[self._args.heroIndex];
    end

    self:refreashInfo();
end

function EmblemCompareView:_initEvent()
	self.btn_rebuild:setVisible(self.data.category ~= 0 and self.data.color >= 6)
    -- 重铸
    self.btn_rebuild:addClickListener(function ()
        ViewManager.open("EmblemRecastView", {data = self.data})
    end)
    self.btn_upStar:setVisible(self.data.color ~= 1)
    -- 升星
    self.btn_upStar:addClickListener(function ()
        ViewManager.open("EmblemStarUpView", {data = self.data})
    end)
    -- 卸下
    self.btn_unequip:addClickListener(function ()
        if (self.hero) then
            EmblemModel:unequip(self.data, self.hero)
            self:closeView();
        end
    end)
    -- 镶嵌
    self.btn_equip:addClickListener(function ()
        local title = self.btn_equip:getTitle();
        if (title == Desc.Emblem_equipOther) then
            if ViewManager.isShow("EmblemBagView") then
                Dispatcher.dispatchEvent("EmblemBagView_changeBagType", self.data.pos)
                self:closeView();
            else
                ViewManager.open("EmblemBagView", {type = self.data.pos});
                self:closeView();
            end
        elseif (self.hero) then
            EmblemModel:equip(self.data, self.hero)
            self:closeView();
        end
    end)

    self.btn_close:removeClickListener();
    self.btn_close:addClickListener(function()
        self:closeView();
    end)

    if (self.winType and self.winType == "tips") then
        self.btn_rebuild:setVisible(false)
        self.btn_upStar:setVisible(false)
        self.btn_unequip:setVisible(false)
        self.btn_equip:setVisible(false)
        self.view:getChildAutoType("btnbg"):setVisible(false);
    end
end

function EmblemCompareView:refreashInfo()

    if (self.hero) then -- 重铸红点
        local emblemConst = DynamicConfigData.t_EmblemConst[1].resetCost[1] -- 重铸消耗材料
        local hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(emblemConst.id)
        if (self.data.category ~= self.hero.heroDataConfiger.category and  hasNum >= emblemConst.cout) then
            self.btn_rebuild:getChildAutoType("img_red"):setVisible(true)
        else
            self.btn_rebuild:getChildAutoType("img_red"):setVisible(false)
        end

        local exchangeRed = self.btn_equip:getChildAutoType("img_red");
        local redStr = "V_Emblem"..self.hero.uuid..self.data.pos
        local val = RedManager.getTips(redStr);
        exchangeRed:setVisible(val);
    end

    local upStarRed = self.btn_upStar:getChildAutoType("img_red")
    upStarRed:setVisible(EmblemModel:checkUpStarExp(self.data))

    self:showEmblemInfo(self.equipInfo1, self.data);
    local equiped = self.hero and EmblemModel:getHeroEquiped(self.hero.uuid) or false;
    -- 有已穿戴的
    local uuid = self.data.uuid;
    local pos = self.data.pos;
    local ctrl = self.view:getController("c1");
    if (equiped and equiped[pos]) then
        if (equiped[pos] ~= uuid) then
            ctrl:setSelectedIndex(1);
            local emblem = EmblemModel:getEmblemByUuid(equiped[pos]);
            self:showEmblemInfo(self.equipInfo2, emblem);

            -- 穿戴装备不同  显示替换
            self.btn_unequip:setVisible(false);
            self.btn_equip:setVisible(true);
            self.btn_equip:setTitle(Desc.Emblem_exchange);
        else
            self.btn_unequip:setVisible(true);
            if (self.winType and self.winType == "bagEquiped") then
                self.btn_equip:setVisible(false);
            else
                self.btn_equip:setVisible(true);
            end
            self.btn_equip:setTitle(Desc.Emblem_equipOther);
        end
    else
        self.btn_unequip:setVisible(false);
        self.btn_equip:setVisible(true);
        self.btn_equip:setTitle(Desc.Emblem_equip);
        ctrl:setSelectedIndex(0);
    end
    Scheduler.scheduleNextFrame(function ()
        local c2 = self.view:getController("c2");
        local index = {}
        if (self.btn_equip:isVisible()) then
            table.insert(index, 1);
        end
        if (self.btn_unequip:isVisible()) then
            table.insert(index, 2);
        end
        if (self.btn_upStar:isVisible()) then
            table.insert(index, 3);
        end
        if (self.btn_rebuild:isVisible()) then
            table.insert(index, 4);
        end
        local str = table.concat(index);
        c2:setSelectedPage(str);
        local x = self.btn_equip:getX();
        self.btn_unequip:setX(x);
        self.btn_upStar:setX(x);
        self.btn_rebuild:setX(x);
    end)
end

function EmblemCompareView:showEmblemInfo(item, data)
    local conf = DynamicConfigData.t_Emblem[data.code];
    local const = DynamicConfigData.t_EmblemConst[1];
    item.cell:setCategoryPos(1);
    item.cell:setStarType(2)
    item.cell:setData(data);
    item.txt_name:setText(conf.name);
    item.txt_color:setText(Desc["common_quality"..data.color])
    local color = ColorUtil.itemTipsHeadColor[data.color];
    -- local color2 = ColorUtil.itemTipsHeadColor[data.color];
    item.txt_name:setColor(color);
    item.txt_color:setColor(color);
    item.headIcon:setIcon(PathConfiger.getItemTipsHeadBg(data.color))
    item:getController("equiped"):setSelectedIndex(data.heroUuid and 1 or 0);
    -- 属性
    local attrList = conf.attribute;
    local category = -1
    if (self.category) then
        category = self.category
    elseif self.hero then
        category = self.hero.heroDataConfiger.category
    end
    local attrConf = DynamicConfigData.t_combat
    item.list_attr:setItemRenderer(function (idx, obj)
        local d = attrList[idx + 1];
        obj:getChildAutoType("title"):setText(attrConf[d.attrId] and attrConf[d.attrId].name or "");
        local id = d.attrId;
        local val = id >= 100 and (d.val/100).."%" or d.val;
        obj:getChildAutoType("val"):setText(val);
        local star = data.star * const.StarAdd;
        local categoryAdd = data.category == category and const.CategoryAdd or 0;
        local add = math.ceil(d.val * (star + categoryAdd) / 10000);
        if (type(add) == "number" and add > 0) then
            add = id >= 100 and (add/100).."%" or add;
            obj:getChildAutoType("add"):setText("+"..add);
        else
            obj:getChildAutoType("add"):setText("");
        end
        
    end)
    item.list_attr:setNumItems(#attrList);
    -- 套装
    print(2233, "DynamicConfigData.t_EmblemSuit[conf.suitId]", conf.suitId)
    local suitConf = DynamicConfigData.t_EmblemSuit[conf.suitId];
    local skillConf = DynamicConfigData.t_skill
    -- 这里是穿戴或者如果穿戴上激活的套装属性
    local equiped = {};
    if (self.equiped) then
        equiped = self.equiped;
    elseif self.hero then
        equiped = EmblemModel:getHeroEquiped(self.hero.uuid)
    end
    equiped = clone(equiped);
    equiped[data.pos] = type(equiped[data.pos]) == "string" and data.uuid or data;
    local _, uuidMap = EmblemModel:getHeroSuitInfo(equiped)
    local activeSuit = uuidMap[data.uuid] or {}

    local suitCtrl = item:getController("suitCtrl");
    if (data.color == 1) then
        suitCtrl:setSelectedIndex(0)
    else
        suitCtrl:setSelectedIndex(1)
        item.list_suit:setItemRenderer(function (idx, obj)
            local txt_desc = obj:getChildAutoType("desc");
            local txt_title = obj:getChildAutoType("title");
            local ctrl = obj:getController("c1");
            local suit = 2 * idx + 2
            txt_title:setText(string.format(Desc.Emblem_suit, suit));
            -- local i = activeSuit[suit] or 0
            -- local str = EmblemModel:suitStrToRich(suitConf["suitDes"..suit], i, ColorUtil.textColorStr.green);
            local skillId = suitConf["suit"..suit][5]

            txt_desc:setText(skillConf[skillId].showName);
            -- if (activeSuit[suit]) then
            local color = activeSuit[suit] and cc.c3b(0x97, 0xe6, 0xad) or cc.c3b(0x99, 0x99, 0x99)
            txt_title:setColor(color);
            txt_desc:setColor(color);
            -- end
            -- ctrl:setSelectedIndex(i);
        end)
        item.list_suit:setNumItems(2);
    end
    
    -- 种族
    if (data.category ~= 0) then
        item.txt_category:setText(string.format(Desc.Emblem_category, Desc["card_category"..data.category], 30));
    else
        item.txt_category:setText(Desc.Emblem_noCategory);
    end
    local color = data.category == category and cc.c3b(0x97, 0xe6, 0xad) or cc.c3b(0x99, 0x99, 0x99)
    item.txt_category:setColor(color);

    -- 最高属性预览
    local maxCode = tonumber(conf.suitId..data.pos.."6");
    local maxConf = DynamicConfigData.t_Emblem[maxCode];
    -- 属性
    local maxAttrList = maxConf.attribute;
    item.list_max:setItemRenderer(function (idx, obj)
        local d = maxAttrList[idx + 1];
        obj:getChildAutoType("title"):setText(attrConf[d.attrId] and attrConf[d.attrId].name or "");
        local id = d.attrId;
        local star = 5 * const.StarAdd;
        local add = math.ceil(d.val * star / 10000) or 0;
        local val = d.val + add
        local valStr = id >= 100 and (val/100).."%" or val ;
        obj:getChildAutoType("val"):setText(valStr);

        -- if (type(add) == "number" and add > 0) then
        --     add = id >= 100 and (add/100).."%" or add;
        --     obj:getChildAutoType("add"):setText("+"..add);
        -- else
        --     obj:getChildAutoType("add"):setText("");
        -- end
    end)
    item.list_max:setNumItems(#maxAttrList);
    item.list_max:resizeToFit(#maxAttrList)
    item.txt_maxTitle:setText(Desc.Emblem_str2);
    item.btn_showMax:removeClickListener();
    item.btn_showMax:addClickListener(function()
        local ctrl = item:getController("showMax");
        local index = ctrl:getSelectedIndex();
        ctrl:setSelectedIndex(1 - index);
    end)
end

function EmblemCompareView:Emblem_emblemEquipChange(_, params)
    local newUuid = params.heraldryUuid
    if (newUuid) then
        self.data = EmblemModel:getEmblemByUuid(newUuid)
    end
    self:refreashInfo();
end

return EmblemCompareView