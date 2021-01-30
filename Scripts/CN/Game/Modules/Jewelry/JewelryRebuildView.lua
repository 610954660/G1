-- add by zn
-- 饰品合成界面

local JewelryRebuildView = class("JewelryRebuildView", View);

function JewelryRebuildView: ctor()
    self._packName = "Jewelry";
    self._compName = "JewelryRebuildView";
    self.selected = false; -- 当前选中的饰品
    self.type = false;
    self.spineNode = false;
end

function JewelryRebuildView: _initVM()
    local root = self;
    local rootView = self.view;
        root.list_bag = rootView:getChildAutoType("com_bag/list_bag");
        root.list_type = rootView:getChildAutoType("com_bag/list_type");
        root.itemCell = BindManager.bindItemCell(rootView:getChildAutoType("itemCell"));
        root.itemCell:setIsBig(true);
        root.itemCell:setAmountVisible(false);
        -- root.txt_itemName = rootView:getChildAutoType("txt_itemName");
        for i = 1, 2 do
            local rebuild = rootView:getChildAutoType("rebuild"..i)
            root["rebuild"..i] = rebuild;
            rebuild.list_attr = rebuild:getChildAutoType("list_attr");
            rebuild.list_skill = rebuild:getChildAutoType("list_skill");
            rebuild.ctrl = rebuild:getController("c2");
        end
        -- root.txt_mustRebuild = rootView:getChildAutoType("txt_mustRebuild");
        root.costBar = BindManager.bindCostBar(rootView:getChildAutoType("costBar"));
        root.btn_rebuild = rootView:getChildAutoType("btn_rebuild");
        root.btn_save = rootView:getChildAutoType("btn_save");
        -- root.btn_help = rootView:getChildAutoType("btn_help");
        root.btn_preview = rootView:getChildAutoType("btn_preview");
end

function JewelryRebuildView: _initUI()
    self:_initVM();
    self.costBar:setDarkBg(true)
    self.list_bag:setItemRenderer(function (idx, obj)
        self:upBagItem(idx, obj)
    end)
    self.list_bag:setVirtual();
    self.list_type:setSelectedIndex(0);
    self:changeBagShow(0);
end

function JewelryRebuildView: _initEvent()
    self.list_type:addClickListener(function ()
        local index = self.list_type:getSelectedIndex();
        if (index ~= 0) then
            index = index + 2;
        end
        self:changeBagShow(index);
    end)

    self.btn_rebuild:addClickListener(function ()
        JewelryModel:rebuild(self.selected);
        self:showSpine();
    end)

    self.btn_save:addClickListener(function ()
        JewelryModel:saveRebuild(self.selected);
    end)

    -- self.btn_help:addClickListener(function ()
    --     ViewManager.open("JewelrySkillView");
    -- end)

    self.btn_preview:addClickListener(function()
        ViewManager.open("JewelrySkillView");
    end)
end

function JewelryRebuildView:_refresh()
    self.selected = false;
    self.list_type:setSelectedIndex(0);
    self:changeBagShow(0);
end

function JewelryRebuildView:JewelryRebuildView_refreshView()
    self:changeBagShow(self.type);
    self:JewelryRebuild_upRightPanel();
end

function JewelryRebuildView:jewelry_rebuildChoose(_, uuid)
    self.selected = uuid;
    local idx = 0;
    for i, v in ipairs(self.data) do
        if (v.uuid == uuid) then
            idx = i;
            break;
        end
    end
    if (idx ~= 0) then
        self.list_bag:scrollToView(idx - 1, true, true)
    end
    self.list_bag:setSelectedIndex(idx - 1);
    self:JewelryRebuild_upRightPanel();
end

function JewelryRebuildView: changeBagShow(type)
    self.type = type;
    self.data = JewelryModel: getItemsByType(type, true);
    local ctrl = self.view:getController("c1");
    if (next(self.data)) then
        for _, v in pairs(self.data) do
            v.sortState = v.heroUuid and 1 or 0;
            v.combat = JewelryModel:calcCombat(v);
        end
        TableUtil.sortByMap(self.data, {{key = "sortState", asc = true}, {key = "color", asc = true}, {key = "combat", asc = true}})
        if (not self.selected) then
            local key = next(self.data);
            self.selected = self.data[key].uuid;
            self:JewelryRebuild_upRightPanel();
        end
        ctrl:setSelectedIndex(1);
        self.list_bag:setSelectedIndex(-1);
        self.list_bag:setNumItems(TableUtil.GetTableLen(self.data));
    else
        self.list_bag:setNumItems(0);
        if (not self.selected) then
            ctrl:setSelectedIndex(0);
        end
    end
end

function JewelryRebuildView: upBagItem(idx, obj)
    local data = self.data[idx + 1];
    local itemCell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"));
    itemCell:setData(data.code, 1, GameDef.GameResType.Item);
    local nameLab = obj:getChildAutoType("txt_name");
    nameLab:setText(data.name);
    nameLab:setColor(ColorUtil.getItemColor(data.color));
    if (data.uuid == self.selected) then
        self.list_bag:setSelectedIndex(idx);
    end

    -- 属性
    local attr1 = {};
    for _, v in pairs(data.attr) do
        table.insert(attr1, v);
    end
    
    local attrConf = DynamicConfigData.t_combat;
    local list_attr = obj:getChildAutoType("list_attr");
    list_attr:setItemRenderer(function (idx, obj)
        local id = attr1[idx + 1].id;
        obj:setTitle(attrConf[id].name);
        if (id > 100) then
            obj:getChildAutoType("value"):setText(string.format("%s%%", attr1[idx+ 1].value / 100))
        else
            obj:getChildAutoType("value"):setText(string.format("%s", attr1[idx+ 1].value))
        end
        
    end)
    list_attr:setNumItems(#attr1);
    local ctrl = obj:getController("c1");
    if (data.percentageValue and data.percentageValue > 0) then
        ctrl:setSelectedIndex(2);
        local percent = data.percentageValue;
        local prog = obj:getChildAutoType("progressBar");
        prog:setMax(10000);
        prog:setValue(percent);
        prog:getChildAutoType("title"):setText((percent / 100).."%");
    elseif (#data.skill > 0) then
        ctrl:setSelectedIndex(1);
        -- 技能
        local list_skill = obj:getChildAutoType("list_skill");
        list_skill:setItemRenderer(function (idx, obj)
            local skill = data.skill[idx + 1];
            obj.skillItem = obj.skillItem or BindManager.bindSkillCell(obj);
            obj.skillItem.view:getChildAutoType('n29'):setVisible(false);
            local ultSkillurl = CardLibModel:getItemIconByskillId(skill);
            obj.skillItem.iconLoader:setURL(ultSkillurl) --放了一张技能图片
        end)
        list_skill:setNumItems(#data.skill);
    else
        ctrl:setSelectedIndex(0);
    end
    local txt_combat = obj:getChildAutoType("combat");
    local combat = JewelryModel:calcCombat(data);
    txt_combat:setText(StringUtil.transValue(combat));

    obj:removeClickListener();
    obj:addClickListener(function ()
        self.list_bag:setSelectedIndex(idx);
        self.selected = data.uuid;
        self:JewelryRebuild_upRightPanel();
    end)

    -- 佩戴英雄头像
    local ctrl = obj:getController("equiped");
    if (data.heroUuid) then
        local hero = CardLibModel:getHeroByUid(data.heroUuid);
        if (hero) then
            ctrl:setSelectedIndex(1);
            local url = PathConfiger.getHeroCard(hero.code);
            obj:getChildAutoType("heroIcon"):setIcon(url);
        end
    else
        ctrl:setSelectedIndex(0);
    end

end

-- 更新右侧
function JewelryRebuildView:JewelryRebuild_upRightPanel()
    local data = JewelryModel:getJewelryByUuid(self.selected);
    local itemData = PackModel:getJewelryBag():getItemByUuid(data.code, data.uuid);
    if (itemData) then
        self.itemCell:setItemData(itemData, GameDef.GameResType.Item);
    else
        self.itemCell:setData(data.code, 1, GameDef.GameResType.Item)
    end
    
    local btnCtrl = self.view:getController("btnCtrl");
    if (#data.showAttr == 0 and #data.showSkill == 0 
        and (data.percentageValueShow == 0 or not data.percentageValueShow)) then
        btnCtrl:setSelectedIndex(0);
    else
        btnCtrl:setSelectedIndex(1);
    end
    local attrConf = DynamicConfigData.t_combat;
    -- 重铸前
    local attr1 = {};
    for _, v in pairs(data.attr) do
        table.insert(attr1, v);
    end
    self.rebuild1.list_attr:setItemRenderer(function (idx, obj)
        local id = attr1[idx + 1].id;
        obj:setTitle(attrConf[id].name);
        if (id > 100) then
            obj:getChildAutoType("value"):setText(string.format("%s%%", attr1[idx+ 1].value / 100))
        else
            obj:getChildAutoType("value"):setText(string.format("%s", attr1[idx+ 1].value))
        end
    end)
    self.rebuild1.list_attr:setNumItems(#attr1);
    local ctrl1 = self.rebuild1:getController("c2")
    if (data.percentageValue and data.percentageValue > 0) then
        ctrl1:setSelectedIndex(2);
        local percent = data.percentageValue;
        local prog = self.rebuild1:getChildAutoType("progressBar");
        prog:setMax(10000);
        prog:setValue(percent);
        prog:getChildAutoType("title"):setText((percent / 100).."%")
    elseif (#data.skill > 0) then
        ctrl1:setSelectedIndex(1);
        local passConf = DynamicConfigData.t_passiveSkill;
        self.rebuild1.list_skill:setItemRenderer(function (idx, obj)
            local skill = data.skill[idx + 1];
            obj.skillItem = obj.skillItem or BindManager.bindSkillCell(obj:getChildAutoType("skillCell"));
            obj.skillItem.view:getChildAutoType('n29'):setVisible(false);
            local ultSkillurl = CardLibModel:getItemIconByskillId(skill);
            obj.skillItem.iconLoader:setURL(ultSkillurl) --放了一张技能图片
            obj.skillItem.iconLoader:removeClickListener(100)
            obj.skillItem.iconLoader:addClickListener(function(context)
                --点击查看技能详情
                ViewManager.open("ItemTips", {codeType = CodeType.PASSIVE_SKILL, id = skill, data = {id = skill}});
            end, 100)
        end)
        self.rebuild1.list_skill:setNumItems(#data.skill);
    else
        ctrl1:setSelectedIndex(0);
    end
    
    -- if (#data.skill > 0) then
    --     self.rebuild1.ctrl:setSelectedIndex(1);
    -- else
    --     self.rebuild1.ctrl:setSelectedIndex(0);
    -- end
    

    -- 重铸后
    local attr2 = {};
    if (TableUtil.GetTableLen(data.showAttr)) then
        for _, v in pairs(data.showAttr) do
            table.insert(attr2, v);
        end
    end
    self.rebuild2.list_attr:setItemRenderer(function (idx, obj)
        if (#attr2 == 0) then
            obj:setTitle(Desc.Jewelry_randAttr);
            obj:getChildAutoType("value"):setText("");
        else
            local id = attr2[idx + 1].id;
            obj:setTitle(attrConf[id].name);
            if (id > 100) then
                obj:getChildAutoType("value"):setText(string.format("%s%%", attr2[idx+ 1].value / 100))
            else
                obj:getChildAutoType("value"):setText(string.format("%s", attr2[idx+ 1].value))
            end
        end
    end)
    local num = #attr2 > 0 and #attr2 or 2;
    self.rebuild2.list_attr:setNumItems(num);

    local ctrl2 = self.rebuild2:getController("c2");
    if (data.percentageValueShow and data.percentageValueShow > 0) then
        ctrl2:setSelectedIndex(2);
        local percent = data.percentageValueShow;
        local prog = self.rebuild2:getChildAutoType("progressBar");
        prog:setMax(10000);
        prog:setValue(percent);
        prog:getChildAutoType("title"):setText((percent / 100).."%")
    elseif (#data.showSkill > 0) then
        ctrl2:setSelectedIndex(1);
        self.rebuild2.list_skill:setItemRenderer(function (idx, obj)
            local ctrl = obj:getController("c1");
            obj.skillItem = obj.skillItem or BindManager.bindSkillCell(obj:getChildAutoType("skillCell"));
            obj.skillItem.view:getChildAutoType('n29'):setVisible(false);
            obj.skillItem.iconLoader:removeClickListener(100)
            if (#data.showSkill > 0) then
                local skill = data.showSkill[idx + 1];
                ctrl:setSelectedIndex(0);
                local ultSkillurl = CardLibModel:getItemIconByskillId(skill);
                obj.skillItem.iconLoader:setURL(ultSkillurl) --放了一张技能图片
                obj.skillItem.iconLoader:addClickListener(function(context)
                    --点击查看技能详情
                    ViewManager.open("ItemTips", {codeType = CodeType.PASSIVE_SKILL, id = skill, data = {id = skill}});
                end, 100)
            else
                ctrl:setSelectedIndex(1);
                obj.skillItem.iconLoader:setURL("") --放了一张技能图片
            end
        end)
        self.rebuild2.list_skill:setNumItems(#data.showSkill);
    else
        ctrl2:setSelectedIndex(0);
    end


    -- 剩余幸运重铸
    local jConf = DynamicConfigData.t_Jewelry[data.code];
    -- if (jConf.times > 0 ) then
    --     self.btn_help:setVisible(true);
    --     self.btn_preview:setVisible(false);
    --     self.txt_mustRebuild:setVisible(true);
    --     local count = jConf.times - data.luckyProb
    --     if (count > 0) then
    --         self.txt_mustRebuild:setText(string.format(Desc.Jewelry_luckyRebuild, count))
    --     else
    --         self.txt_mustRebuild:setText(Desc.Jewelry_luckyTime);
    --     end
    -- else
    --     self.btn_help:setVisible(false);
    --     self.btn_preview:setVisible(true);
    --     self.txt_mustRebuild:setVisible(false);
    -- end

    self.costBar:setData(jConf.cost, true, false);
    local children = self.costBar.list_cost:getChildren();
    for _, child in ipairs(children) do
        if (child and child.costItem) then
            child.costItem:setUseMoneyItem(true);
        end
    end
end


function JewelryRebuildView:showSpine(  )
    if not self.spineNode then
        local cell = self.itemCell.view
		self.spineNode = SpineUtil.createSpineObj(cell, vertex2(cell:getWidth()/2,cell:getHeight()/2), "fw_chongzhi_fazhen", "Spine/ui/rune", "fuwenxitong_texiao", "fuwenxitong_texiao",false)
	else
		self.spineNode:setAnimation(0, "fw_chongzhi_fazhen", false)
	end
end

-- -- 提前预览合成道具
-- function JewelryRebuildView:showMergePreshow()
--     local color, code = JewelryModel:checkSelectedColor();
--     if (color and JewelryModel.selectedNum > 1) then
--         self.itemCell:setVisible(true);
--         self.txt_success:setVisible(true);
--         local conf = DynamicConfigData.t_JewelryComposite[JewelryModel.selectedNum][code];
--         local rate = conf.rate * 100;
--         self.txt_success:setText(string.format(Desc.Jewelry_mergeSucRate, rate));
--         local successCode = conf.sucProduct;
--         if (successCode) then
--             self.itemCell:setData(successCode, 1, GameDef.GameResType.Item);
--         end
--         self.costBar:setData(conf.cost, true, false);
--         self.costGroup:setVisible(true);
--     else
--         self.itemCell:setVisible(false);
--         self.txt_success:setVisible(false);
--         self.costGroup:setVisible(false);
--     end
-- end

return JewelryRebuildView