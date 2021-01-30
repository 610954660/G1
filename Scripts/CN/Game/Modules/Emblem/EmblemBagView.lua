-- add by zn
-- 纹章背包界面
local EmblemCell = require "Game.Modules.Emblem.EmblemCell";
local EmblemBagView = class("EmblemBagView", Window)

function EmblemBagView:ctor()
    self._packName = "Emblem"
    self._compName = "EmblemBagView"
    -- self._rootDepth = LayerDepth.PopWindow
    self.bagType = self._args.type or 0;
    self.bagPanel = false;
    self.isSuitBag = false; -- 为true时仅显示某一套装的纹章
end

function EmblemBagView:_initUI()
    local root = self
    local rootView = self.view
        for i = 1, 4 do
            root["emblem"..i] = rootView:getChildAutoType("emblem"..i);
        end
        root.list_attr = rootView:getChildAutoType("list_attr")
        root.list_suit = rootView:getChildAutoType("list_suit")

        root.list_hero = rootView:getChildAutoType("list_hero");
        root.list_bag = rootView:getChildAutoType("list_bag");
        root.list_bagType = rootView:getChildAutoType("list_bagType");

        root.btn_allDown = rootView:getChildAutoType("btn_allDown");
        root.btn_suit = rootView:getChildAutoType("btn_suit");
        root.btn_jump = rootView:getChildAutoType("btn_jump");
        root.bagPanel = rootView:getChildAutoType("bag");
        root.btn_all = rootView:getChildAutoType("btn_all");
    -- 测试用
    if (not CardLibModel.__CardsCategory or not next(CardLibModel.__CardsCategory)) then
        CardLibModel:setCardsByCategory(0);
    end

    local heroList = EmblemModel:getHeroList();
    Dispatcher.dispatchEvent(EventType.cardView_updateInfo)
    local hero = ModelManager.CardLibModel.curCardStepInfo;
    if (not hero and heroList[1]) then
        hero = heroList[1]
        ModelManager.CardLibModel.curCardStepInfo = hero
    end
    
    self.list_hero:setVirtual();
    self.list_hero:setItemRenderer(function (idx, obj)
        self:upHeroItem(idx, obj, heroList[idx + 1]);
    end)
    self.list_hero:setNumItems(#heroList)
    if (#heroList > 1) then
        local scrollIndex = 0;
        for idx, h in pairs(heroList) do
            if (hero and hero.uuid == h.uuid) then
                scrollIndex = idx - 1
                break
            end
        end
        self.list_hero:scrollToView(scrollIndex, true, true)
    end
    self.list_bagType:setSelectedIndex(self.bagType);
    self:_refresh();

    if (self._args.suitView) then
        ViewManager.open("EmblemSuitSuggestView");
        self.bagPanel:setVisible(false);
    end
end

function EmblemBagView:_initEvent()
    self.list_bagType:addClickListener(function ()
        local index = self.list_bagType:getSelectedIndex()
        if (index ~= self.bagType) then
            self.bagType = index;
            self:_refresh();
        end
    end)

    self.btn_suit:addClickListener(function ()
        self.bagPanel:setVisible(false);
        ViewManager.open("EmblemSuitSuggestView");
    end)

    self.btn_allDown:addClickListener(function ()
        local hero = ModelManager.CardLibModel.curCardStepInfo;
        local equiped = EmblemModel:getHeroEquiped(hero.uuid);
        local list = {};
        for _, uuid in pairs(equiped) do
            local info = {
                heroUuid = hero.uuid,
                heraldryUuid = uuid
            }
            table.insert(list, info)
        end
        if (#list > 0) then
            EmblemModel:unequipWithList(list);
        else
            RollTips.show(Desc.Emblem_noEquiped);
        end
    end)

    self.btn_jump:addClickListener(function ()
        ModuleUtil.openModule(ModuleId.BoundaryMapView);
    end)

    self.list_hero:removeClickListener();

    self.btn_all:addClickListener(function()
        local child = self.list_bagType:getChildAt(0);
        child:setTitle(Desc.common_category0);
        local ctrl = self.view:getController("showSuitBag");
        ctrl:setSelectedIndex(0);
        self.isSuitBag = false;
        self:refreshBag(self.bagType);
    end)
end

function EmblemBagView:_refresh(posList)
    self:refreshBag(self.bagType)
    self:showEmbelmPanel(posList);
end

function EmblemBagView:refreshBag(type)
    local allEmblems = EmblemModel:getEmblemsByPos(type);
    local dataList = {}
    if (self.isSuitBag) then
        for _, d in pairs(allEmblems) do
            if (d.suitId == self.isSuitBag) then
                table.insert(dataList, d);
            end
        end
    else
        dataList = allEmblems;
    end
    local ctrl = self.view:getController("bagCtrl");
    local len = #dataList;
    if (len > 0) then
        ctrl:setSelectedIndex(1)
        self.list_bag:setVirtual();
        self.list_bag:setItemRenderer(function (idx, obj)
            local data = dataList[idx + 1];
            if (not obj.cell) then
                obj.cell = EmblemCell.new(obj);
            end
            obj.cell:setCategoryPos(1);
            obj.cell:setStarType(2);
            obj.cell:setData(data);
            obj:removeClickListener();
            obj:addClickListener(function ()
                ViewManager.open("EmblemCompareView", {data = data, withHero = true})
            end)
        end)
        self.list_bag:setNumItems(len)
    else
        ctrl:setSelectedIndex(0)
    end
end

function EmblemBagView:upHeroItem(idx, obj, data)
    if (not obj.cell) then
        obj.cell = BindManager.bindHeroCell(obj:getChildAutoType("playerCell"));
    end
    obj.cell:setData(data);
    local hero = ModelManager.CardLibModel.curCardStepInfo;
    if (hero and hero.uuid == data.uuid) then
        self.list_hero:setSelectedIndex(idx);
    elseif (not hero and idx == 0) then  -- 应该非正式入口才能进入
        self.list_hero:setSelectedIndex(idx);
    else
        obj.cell:setSelected(false);
    end

    obj:removeClickListener();
    obj:addClickListener(function ()
        if (self.list_hero:getSelectedIndex() == idx) then return end;
        self.list_hero:setSelectedIndex(idx);

        ModelManager.CardLibModel.curCardStepInfo = data;
        ModelManager.CardLibModel:setCarByPosInfo(data.code, data.uuid, idx + 1);
        ModelManager.CardLibModel:setChooseUid(data.uuid)
        Dispatcher.dispatchEvent(EventType.cardView_updateInfo)
        self:showEmbelmPanel();
    end)
    self.btn_help:removeClickListener()
    self.btn_help:addClickListener(function()
        local info = {}
        info['title']=Desc["help_StrTitle151"]
        info['desc']=Desc["help_StrDesc151"]
        ViewManager.open("GetPublicHelpView",info) 
    end)
end

-- 更新装备区域显示
function EmblemBagView:showEmbelmPanel(posList)
    local hero = ModelManager.CardLibModel.curCardStepInfo;
    if (hero) then
        local equiped = EmblemModel:getHeroEquiped(hero.uuid);
        local conf = DynamicConfigData.t_Emblem;
        -- 纹章展示
        for i = 1, 4 do
            local emblemItem = self["emblem"..i];
            local red = emblemItem:getChildAutoType("img_red");
            RedManager.register("V_Emblem"..hero.uuid..i, red)
            local uuid = equiped and equiped[i] or false
            local data = EmblemModel:getEmblemByUuid(uuid);
            emblemItem:removeClickListener();
            local equipedCtrl = emblemItem:getController("equiped");

            if (not emblemItem.cell) then
                emblemItem.cell = EmblemCell.new(emblemItem:getChildAutoType("emblem"));
            end
            emblemItem.cell:setIsMid(true);
            emblemItem.cell:showFrame(false);
            emblemItem.cell:setCategoryPos(2);
            emblemItem.cell:setStarType(0)
            emblemItem.cell:setData(data);

            if (data) then
                emblemItem:addClickListener(function ()
                    ViewManager.open("EmblemCompareView", {data = data, withHero = true, winType = "bagEquiped"})
                    ViewManager.close("EmblemSuitSuggestView")
                    self.bagPanel:setVisible(true);
                    if (self.bagType ~= i) then
                        self.list_bagType:setSelectedIndex(i)
                        self.bagType = i;
                        self:_refresh();
                    end
                end)
                
                if (not emblemItem.star) then
                    emblemItem.star = BindManager.bindCardStar(emblemItem:getChildAutoType("cardStar"));
                end
                emblemItem.star:setData(data.star);
                equipedCtrl:setSelectedIndex(1);

                local name = emblemItem:getChildAutoType("txt_name");
                if (conf[data.code]) then
                    name:setText(conf[data.code].name);
                else
                    name:setText("");
                end
                emblemItem.cell:showCategoryEffect(data.category == hero.heroDataConfiger.category)
            else
                equipedCtrl:setSelectedIndex(0);
                emblemItem:addClickListener(function ()
                    ViewManager.close("EmblemSuitSuggestView")
                    self.bagPanel:setVisible(true);
                    if (self.bagType ~= i) then
                        self.list_bagType:setSelectedIndex(i)
                        self.bagType = i;
                        self:_refresh();
                    end
                end)
            end
            -- 新穿上的
            if (posList and posList[i]) then
                local parent = emblemItem:getChildAutoType("effect")
                local pos = cc.vertex2F(parent:getWidth()/2, parent:getHeight()/2)
                if (not emblemItem.spine) then
                    emblemItem.spine = SpineUtil.createSpineObj(parent, pos, "ui_wenzhangxiangqian", "Spine/ui/Emblem", "efx_wenzhang", "efx_wenzhang", false)
                else
                    emblemItem.spine:setAnimation(0, "ui_wenzhangxiangqian", false)
                end
            end
        end

        -- 属性
        local sx = {};
        local attrs = EmblemModel:getEmblemsAttr(equiped, hero);
        for _, emAttr in pairs(attrs) do
            for id, attr in pairs(emAttr) do
                if (not sx[id]) then
                    sx[id] = 0;
                end
                sx[id] = sx[id] + attr.val + attr.add;
            end
        end
        -- local key = next(sx)
        local attrList = {}
        for id, attr in pairs(sx) do
            local info = {
                id = id,
                val = attr,
            }
            table.insert(attrList, info)
        end
        table.sort(attrList, function(a, b)
            return a.id < b.id
        end)
        local conf = DynamicConfigData.t_combat
        self.list_attr:setItemRenderer(function (idx, obj)
            local d = attrList[idx + 1]
            local id = d.id --idx == 0 and key or next(sx, key);
            -- key = id;
            obj:getChildAutoType("title"):setText(conf[id] and conf[id].name or "");
            local val = id >= 100 and (d.val/100).."%" or d.val;
            obj:getChildAutoType("val"):setText("+"..val);
        end)
        local len = #attrList--TableUtil.GetTableLen(sx)
        self.list_attr:setNumItems(len)
        self.view:getController("attrCtrl"):setSelectedIndex(len == 0 and 0 or 1);

        -- 套装加成
        local suit = EmblemModel:getHeroSuitInfo(equiped);
        local sConf = DynamicConfigData.t_EmblemSuit;
        local skillConf = DynamicConfigData.t_skill;
        local suitTab = {};
        for suitId, info in pairs(suit) do
            local c = sConf[suitId];
            for type, level in pairs(info) do
                local name = string.format(Desc.Emblem_suitDesc1, c.suitName, type);
                local skillId = c["suit"..type][level];
                local str = skillConf[skillId] and skillConf[skillId].showName or "";
                table.insert(suitTab, name..str);
            end
        end
        self.list_suit:setItemRenderer(function (idx, obj)
            local s = suitTab[idx + 1];
            obj:getChildAutoType("desc"):setText(s);
        end)
        len = #suitTab
        self.list_suit:setNumItems(len)
        self.view:getController("suitCtrl"):setSelectedIndex(len == 0 and 0 or 1);
    end
end

-- 背包道具刷新
function EmblemBagView:Emblem_emblemEquipChange(_, param)
    local posList = {};
    if (param) then
        if param.heraldryUuid then
            local d = EmblemModel:getEmblemByUuid(param.heraldryUuid)
            local pos = d and d.pos or 0
            posList[pos] = true
        else
            posList = param
        end
    end
    self:_refresh(posList);
end

function EmblemBagView:EmblemBagView_showBag()
    self.bagPanel:setVisible(true);
end

function EmblemBagView:EmblemBagView_changeBagType(_, type)
    self.bagType = type
    self.list_bagType:setSelectedIndex(type);
    self:refreshBag(type)
    ViewManager.close("EmblemSuitSuggestView")
    self.bagPanel:setVisible(true);
end

function EmblemBagView:Emblem_changeSuitBag(_, suitId)
    local child = self.list_bagType:getChildAt(0);
    local conf = DynamicConfigData.t_EmblemSuit[suitId];
    if (conf) then
        child:setTitle(conf.suitName);
    end
    local ctrl = self.view:getController("showSuitBag");
    ctrl:setSelectedIndex(1);
    self.isSuitBag = suitId
    self.bagType = 0
    self.list_bagType:setSelectedIndex(0);
    self:refreshBag(0)
    ViewManager.close("EmblemSuitSuggestView")
    self.bagPanel:setVisible(true);
end

function EmblemBagView:_exit()
    Dispatcher.dispatchEvent("EmblemBagView_close");
end

return EmblemBagView