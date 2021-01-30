-- add by zn
-- 纹章装备界面
local EmblemCell = require "Game.Modules.Emblem.EmblemCell";
local EmblemEquipView = class("EmblemEquipView", Window)

function EmblemEquipView:ctor()
    self._packName = "Emblem"
    self._compName = "EmblemEquipView"
    -- self._rootDepth = LayerDepth.PopWindow
    EmblemModel:getBag();
end

function EmblemEquipView:_initUI()
    local root = self
    local rootView = self.view
        for i = 1, 4 do
            root["pos"..i] = rootView:getChildAutoType("pos"..i)
        end
        root.list_attr = rootView:getChildAutoType("list_attr")
        root.list_suit = rootView:getChildAutoType("list_suit")
        
        root.btn_info = rootView:getChildAutoType("btn_info")
        root.btn_allDown = rootView:getChildAutoType("btn_allDown")
        root.btn_suit = rootView:getChildAutoType("btn_suit")

    self:_refresh();
end

function EmblemEquipView:_initEvent()
    self.btn_info:addClickListener(function ()
        ViewManager.open("EmblemBagView");
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
    
    self.btn_suit:addClickListener(function ()
        ViewManager.open("EmblemBagView", {suitView = true});
    end)
end

function EmblemEquipView:_refresh()
    self:showEmbelmPanel()
end

function EmblemEquipView:showEmbelmPanel()
    local hero = ModelManager.CardLibModel.curCardStepInfo;
    if (hero) then
        local equiped = EmblemModel:getHeroEquiped(hero.uuid);
        local conf = DynamicConfigData.t_Emblem;
        -- 纹章展示
        for i = 1, 4 do
            local item = self["pos"..i];
            local red = item:getChildAutoType("img_red");
            RedManager.register("V_Emblem"..hero.uuid..i, red)
            local uuid = equiped and equiped[i] or false
            local data = EmblemModel:getEmblemByUuid(uuid);
            local ctrl = item:getController("equiped");
            item:removeClickListener();
            if (not item.cell) then
                item.cell = EmblemCell.new(item:getChildAutoType("emblem"))
            end
            if (not data) then
                ctrl:setSelectedIndex(0);
                item:addClickListener(function ()
                    ViewManager.open("EmblemBagView", {type = i});
                end)
            else
                ctrl:setSelectedIndex(1);
                item:addClickListener(function ()
                    ViewManager.open("EmblemCompareView", {data = data, withHero = true})
                end)
                local name = item:getChildAutoType("txt_name");
                if (conf[data.code]) then
                    name:setText(conf[data.code].name);
                else
                    name:setText("");
                end
                -- item.cell:setIsMid(true);
                item.cell:showFrame(false);
                item.cell:setCategoryPos(2);
                item.cell:setStarType(0)
                item.cell:setData(data);
                if (not item.star) then
                    item.star = BindManager.bindCardStar(item:getChildAutoType("cardStar"));
                end
                item.star:setData(data.star);
                item.cell:showCategoryEffect(data.category == hero.heroDataConfiger.category)
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
        local len = #attrList;--TableUtil.GetTableLen(sx)
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

function EmblemEquipView:Emblem_emblemEquipChange()
    self:_refresh();
end

function EmblemEquipView:cardView_updateInfo()
    self:_refresh();
end

return EmblemEquipView