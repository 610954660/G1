-- add by zn
-- 点亮星阶
local HeroConfiger = require "Game.ConfigReaders.HeroConfiger"

local CardSegmentPreView = class("CardSegmentPreView", Window)

function CardSegmentPreView:ctor()
    self._packName = "CardSystem"
    self._compName = "CardSegmentPreView"
    self._rootDepth = LayerDepth.PopWindow
    self.hero = self._args.hero;
    self.index = self._args.index;
    self.selected = {};
    self.isActived = false;
end

function CardSegmentPreView:_initUI()
    local root = self
    local rootView = self.view
        root.txt_title = rootView:getChildAutoType("txt_title");
        local starItem = rootView:getChildAutoType("starItem");
            root.star = starItem:getChildAutoType("starcell");
            for i = 1, 4 do
                root["attr"..i] = starItem:getChildAutoType("attr"..i);
                root["val_"..i] = starItem:getChildAutoType("val_"..i);
                root["val1_"..i] = starItem:getChildAutoType("val1_"..i);
            end
            root.list_cost = rootView:getChildAutoType("list_cost");
            root.btn_sure = rootView:getChildAutoType("btn_sure");
            root.costItem = BindManager.bindCostItem(rootView:getChildAutoType("costItem"));

    local starSegment = self.hero.starSegment and self.hero.starSegment[self.hero.star] or {};
    local segment = starSegment and starSegment.starSegment or {};
    if (segment and segment[self.index] and segment[self.index].isActivate) then
        self.isActived = true;
    end
    self:initAttr();
    self:upMaterials();
end

function CardSegmentPreView:_initEvent()
    self.btn_sure:addClickListener(function()
        if (self:checkMaterialEnough()) then
            local costList, starItem = self:getSelected2SData();
            CardLibModel:heroStarSegmentLevelUp(self.hero.uuid, self.index, costList, starItem)
        else
            RollTips.show(Desc.Emblem_Desc6);
        end
    end)
end

function CardSegmentPreView:initAttr()
    local heroConf = DynamicConfigData.t_hero[self.hero.code];
    local heroName = heroConf.heroName;
    self.txt_title:setText(string.format(Desc.card_segmentStr1, heroName, Desc["common_"..self.index]));
    self.star:setTitle(self.index);
    self.star:getController("c1"):setSelectedIndex(1);
	local category = (heroConf.category == 1 or heroConf.category == 2) and 2 or 1;
    local conf = DynamicConfigData.t_HeroSegmentAttr[category][self.hero.star];
    -- local baseAdd = {};
    -- local segment = self.hero.starSegment and self.hero.starSegment.starSegment or {}
    -- for _
    local c = conf and conf[self.index] or {};
    for i = 1, 4 do
        local title = Desc["card_segmentAttr1"..i];
        local base = 0;
        local add = 0;
        if (i == 1) then
            local otherAdd = CardLibModel:getSegmentAddLvMax(self.hero)
            if (self.isActived) then
                add = HeroConfiger.getNextLevelLimit(self.hero.stage, self.hero.level) + otherAdd;
                base = add - c.addlevel;
            else
                base = HeroConfiger.getNextLevelLimit(self.hero.stage, self.hero.level) + otherAdd;
                add = base + c.addlevel;
            end
            
        elseif (i == 2) then
            base = c.addnumericalShow;
        elseif (i == 3) then
            base = string.format(Desc.card_segmentAttr13_str, c.addattrPoint);
        elseif i == 4 then
            local data = c.addSpecialAttr[1]
            local attrConf = DynamicConfigData.t_combat[data.attrId];
            local val = data.attrId > 100 and string.format("+%s%%", data.val/100) or "+"..data.val;
            base = attrConf.name..val
        end
        self["attr"..i]:setText(title);
        self["val_"..i]:setText(base);
        self["val1_"..i]:setText(add);
    end
end

function CardSegmentPreView:upMaterials()
    local materials = CardLibModel:getMaterialsList20Segment(self.hero, self.index);
    local conf = DynamicConfigData.t_HeroSegment[self.hero.star];
    local c = conf and conf[self.index] or {};
    local cost = c.material[1];
    self.costItem:setData(cost.type, cost.code, cost.amount)
    self.list_cost:setItemRenderer(function(idx, obj)
        local d = materials[idx + 1];
        local ctrl = obj:getController("c1");
        obj:removeClickListener(111);
        if (d.star) then
            ctrl:setSelectedIndex(0);
            self:showCardItem(obj, d, self.hero, idx + 1);
        else
            ctrl:setSelectedIndex(1);
            self:showItemCell(obj, d);
        end
    end)
    self.list_cost:setNumItems(#materials);
    if (self.isActived) then
        self.btn_sure:setTitle(Desc.card_segmentStr3);
        self.btn_sure:setGrayed(true);
        self.btn_sure:setTouchable(false);
    else
        self.btn_sure:setTitle(Desc.card_segmentStr2);
        self.btn_sure:setGrayed(false);
        self.btn_sure:setTouchable(true);
    end
end

function CardSegmentPreView:showCardItem(obj, materials, heroItem, pos)
    if (not obj.cardCell) then
        obj.cardCell = BindManager.bindCardCell(obj:getChildAutoType("cardItem"));
    end
	local cardItem = obj.cardCell;
	local type = materials.type or 1;
	--type 1同样角色  2 同阵营同星级  3、
	local category = 0
	if type == 1 then
		local cardData = {heroStar = materials.star, heroId = materials.hero}
		category = heroItem.category
		cardItem:setData(cardData, true)
		cardItem:setShowCategory(true)
	elseif type == 2 then
		local cardData = {heroStar = materials.star, heroId = heroItem.heroId}
		category = heroItem.category
		cardItem:setData(cardData, true)
		cardItem:setIcon(PathConfiger.getItemIcon(40000013))
		cardItem:setShowCategory(true)
	elseif type == 3 then
		local cardData = {heroStar = materials.star, heroId = heroItem.heroId}
		category = 0
		cardItem:setData(cardData, true)
		cardItem:setIcon(PathConfiger.getItemIcon(40000013))
		cardItem:setShowCategory(false)
	end
	-- --材料不足的要变灰
	-- local material = ModelManager.CardLibModel:getStarCanChooseInfo(materials, heroItem, pos)-- ModelManager.CardLibModel:getCardByCategory(category, {ModelManager.CardLibModel.curCardStepInfo.uuid}, materials.star, materials.level)
	-- if #material < materials.num then
	-- 	cardItem:setGrayed(false, true)
	-- 	cardItem:setGrayed(true, true)
	-- else
	-- 	cardItem:setGrayed(false, true)
    -- end
    obj:addClickListener(function ()
        local choseFunc = function(arr)
            self:upSelectedInfo(arr, pos)
        end 
        local exclude = {};
        for i, info in pairs(self.selected) do
            if (i ~= pos) then
                for _, d in pairs(info) do
                    if (d.uuid) then
                        exclude[d.uuid] = true
                    else
                        if (not exclude[d.code]) then
                            exclude[d.code] = 0;
                        end
                        exclude[d.code] = exclude[d.code] + 1;
                    end
                end
            end
        end
        ModelManager.CardLibModel.bOpenCardChooseView = true
        local param = {
            callback = choseFunc,
            materials = materials,
            heroInfo = heroItem,
            selected = self.selected[pos],
            exclude = exclude
        }
        ViewManager.open("CardSegmentChoseView", param)
    end, 111);

    --放了卡牌图片
    local txtnum = obj:getChildAutoType("count");
    local num = #(self.selected[pos] and self.selected[pos] or {});
    txtnum:setText(string.format("%s/%s", num, materials.num))
    if (num < materials.num) then
        txtnum:setColor(cc.c3b(0xff, 0x3b, 0x3b));
    else
        txtnum:setColor(cc.c3b(0xff, 0xff, 0xff));
    end
end

function CardSegmentPreView:showItemCell(obj, materials)
    if (not obj.itemCell) then
        obj.itemCell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"));
    end
    local itemCell = obj.itemCell;
    itemCell:setData(materials.code, 0, materials.type);
    local hasNum = 0;
    if materials.type == CodeType.ITEM then
		hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(materials.code)
	elseif materials.type == CodeType.MONEY then
		hasNum = ModelManager.PlayerModel:getMoneyByType(materials.code)
    end
    local txtnum = obj:getChildAutoType("count");
    txtnum:setText(string.format("%s/%s", MathUtil.toSectionStr(hasNum), MathUtil.toSectionStr(materials.amount)))
    if (hasNum < materials.amount) then
        txtnum:setColor(cc.c3b(0xff, 0x3b, 0x3b));
    else
        txtnum:setColor(cc.c3b(0xff, 0xff, 0xff));
    end
end

-- function CardSegmentPreView:getMaterialsList(haveMaterial)
--     haveMaterial = haveMaterial or false;
--     local heroCode = self.hero.code;
--     local conf = DynamicConfigData.t_HeroSegment[self.hero.star];
--     local c = conf and conf[self.index] or {};
--     local temp = {}
--     if (#c.self > 0) then  -- 本卡牌id
--         for k, d in ipairs(c.self) do
--             d.type = 1
--             d.hero = heroCode
--             table.insert(temp, d)
--         end
--     end
--     if (#c.faction > 0) then  -- 本种族
--         for k, d in ipairs(c.faction) do
--             d.type = 2
--             table.insert(temp, d)
--         end
--     end
--     if (#c.free > 0) then  -- 无规则限制
--         for k, d in ipairs(c.free) do
--             d.type = 3
--             table.insert(temp, d)
--         end
--     end
--     if (#c.special > 0) then  -- 特殊要求
--         for k, d in ipairs(c.special) do
--             d.type = 1
--             table.insert(temp, d)
--         end
--     end
--     if (#c.exclusive) then
--         for k, d in ipairs(c.exclusive) do
--             table.insert(temp, d)
--         end
--     end
--     if (haveMaterial and #c.material) then
--         for k, d in ipairs(c.material) do
--             table.insert(temp, d)
--         end
--     end
--     return temp;
-- end

function CardSegmentPreView:upSelectedInfo(arr, idx)
    if (not self.selected[idx]) then
        self.selected[idx] = {};
    end
    self.selected[idx] = arr;
    self:upMaterials();
end

function CardSegmentPreView:getSelected2SData()
    local cards = {}; -- 消耗卡牌
    local items = {}; -- 升星替换材料
    for _, arr in pairs(self.selected) do
        for _, d in ipairs(arr) do
            if (d.uuid) then
                table.insert(cards, d.uuid);
            elseif (d.code) then
                local code = d.code
                if (not items[code]) then
                    items[code] = {
                        code = code,
                        num = 0
                    }
                end
                items[code].num = items[code].num + 1;
            end
        end
    end
    return cards, items;
end

function CardSegmentPreView:checkMaterialEnough()
    local needs = CardLibModel:getMaterialsList20Segment(self.hero, self.index, true);
    for idx, d in ipairs(needs) do
        if (d.star) then -- 卡牌消耗需求
            local select = self.selected[idx] or {};
            if (d.num > #select) then
                return false;
            end
        else
            if (not PlayerModel:checkCostEnough(d, false)) then
                return false;
            end
        end
    end
    return true;
end

function CardSegmentPreView:cardStarSegmentLevelUp_suc()
    self:closeView();
end

return CardSegmentPreView