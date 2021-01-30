-- add by zn
-- 装备升阶

local EquipmentUpStageView = class("EquipmentUpStageView", Window)

function EquipmentUpStageView:ctor()
    self._packName = "Equipment"
    self._compName = "EquipmentUpStageView"
    self._rootDepth = LayerDepth.PopWindow
    self.spinenode = false
    self.curUuid = false;
end

function EquipmentUpStageView:_initUI()
    local root = self
    local rootView = self.view
        root.list_type = rootView:getChildAutoType("list_type");
        root.list_item = rootView:getChildAutoType("list_item");
        root.txt_name = rootView:getChildAutoType("name");
        for i = 1, 3 do
            root["itemCell"..i] = BindManager.bindItemCell(rootView:getChildAutoType("itemCell"..i));
            root["itemCell"..i]:setIsMid(true)
        end
        root.list_attr = rootView:getChildAutoType("list_attr");
        -- 进阶部分
        root.costItem = BindManager.bindItemCell(rootView:getChildAutoType("CostItem"));
        root.costItem:setIsMid(true)
        root.btn_upStage = rootView:getChildAutoType("btn_upStage");
        root.txt_tips = rootView:getChildAutoType("txt_tips");
        root.txt_attrAdd = rootView:getChildAutoType("txt_attrAdd");
        root.txt_cost = rootView:getChildAutoType("txt_cost");
        
        self.list_item:setVirtual();
        self.txt_tips:setText(Desc.equipment_upstar_tips);
        self.spinenode = rootView:getChildAutoType("spinenode")
    self.spinenode.skeletonNode = SpineUtil.createSpineObj(self.spinenode,vertex2(0,0), "ui_zhuangbeishengxing", "Spine/ui/Emblem", "efx_wenzhang", "efx_wenzhang",false,true)
    self.spinenode:setVisible(false)

    self.list_type:setSelectedIndex(0)
    self.bag = self:getBag();
    self:upBagList();
end

function EquipmentUpStageView:_initEvent()
    self.list_type:addClickListener(function()
        local type = self.list_type:getSelectedIndex()
        self.bag = self:getBag(type);
        self:upBagList();
    end)

    self.btn_upStage:addClickListener(function()
        RollTips.show("功能开发中~");
    end)
end

function EquipmentUpStageView:upBagList(scrollTo)
    self.list_item:setSelectedIndex(-1);
    self.list_item:setItemRenderer(function(idx, obj)
        local data = self.bag[idx + 1];
        if (self.curUuid == data.uuid) then
            self.list_item:setSelectedIndex(idx);
        end
        self:upBagItem(data, obj);
    end)
    self.list_item:setNumItems(#self.bag);
    if (scrollTo) then
        self.list_item:scrollToView(scrollTo, true);
    end
    if (not self.curUuid and #self.bag > 0) then
        self.curUuid = self.bag[1].uuid
        self.list_item:setSelectedIndex(0);
        self:upRightPanel();
    end
end

function EquipmentUpStageView:upBagItem(data, obj)
    if (not obj.cell) then
        obj.cell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"));
        obj.cell:setIsMid(true)
    end
    obj.cell:setData(data.code, 0, CodeType.ITEM)
    local txt_name = obj:getChildAutoType("txt_name");
    txt_name:setText(data.name);
    local ctrl = obj:getController("head");
    ctrl:setSelectedIndex(1);
    local headIcon = obj:getChildAutoType("heroIcon");
    headIcon:setIcon(PathConfiger.getHeroCard(data.heroCode))
    obj:removeClickListener(222);
    obj:addClickListener(function()
        self.curUuid = data.uuid;
        self:upRightPanel();
    end, 222)
end

function EquipmentUpStageView:upRightPanel()
    local index = self.list_item:getSelectedIndex() + 1
    local data = self.bag[index];
    local ctrl = self.view:getController("c1");
    local c2 = self.view:getController("c2");
    local conf = DynamicConfigData.t_equipEquipment[data.code];
    if (data.stage == 2) then
        c2:setSelectedIndex(2);
        ctrl:setSelectedIndex(0);
    else
        c2:setSelectedIndex(1);
        ctrl:setSelectedIndex(1);
    end
    self.txt_name:setText(data.name);
    for i = 1, 3 do
        local itemCell = self["itemCell"..i];
        itemCell:setData(data.code, 0, CodeType.ITEM)
        local stage = data.stage
        if (i == 3) then
            stage = math.min(stage + 1, 2)
        end
        itemCell.txtNum:setText(stage > 0 and "T"..stage or "")
    end
    -- 装备属性
    self:upAttrList(data.code, math.min(data.stage + 1, 2));
    -- 属性加成显示
    local attrOffset = 0;
    local cost = false;
    if (data.stage == 0) then
        attrOffset = conf.reward1;
        cost = conf.cost1[1];
    elseif data.stage == 1 then
        attrOffset = conf.reward2 - conf.reward1;
        cost = conf.cost2[1];
    end
    self.txt_attrAdd:setText(attrOffset == 0 and "" or string.format(Desc.equipment_upstage_attrAdd, attrOffset))
    -- 消耗
    if (cost) then
        self.costItem:setData(cost.code, 0);
        local have = ModelManager.PackModel:getItemsFromAllPackByCode(cost.code)
        if (have >= cost.amount) then
            self.txt_cost:setText(string.format("[color=#119717]%s/%s[/color]", have, cost.amount))
        else
            self.txt_cost:setText(string.format("[color=#D12121]%s/%s[/color]", have, cost.amount))
        end
        
    end
end

function EquipmentUpStageView:upAttrList(code, stage)
    local curCode = code;
    local allConf = DynamicConfigData.t_equipEquipment;
    local curConf = allConf[curCode];
    -- local showConf = allConf[code]
    local attrMap = {
        ["hp"] = 1,
        ["attack"] = 2,
        ["defense"] = 3,
        ["magic"] = 4,
        ["magicDefense"] = 5,
        ["speed"] = 6,
    }
    local skillList = {}
    local stageAdd = 0;
    if (stage == 1) then
        stageAdd = curConf.reward1
    elseif stage == 2 then
        stageAdd = curConf.reward2
    end
    for k, v in pairs(attrMap) do
        local info = {
            id = v
        }
        if (curConf[k] ~= 0) then
            info.pre = curConf[k]
            info.up = info.pre * (stageAdd / 100 + 1)
            table.insert(skillList, info)
        end
    end
    table.sort(skillList, function (a, b)
        return a.id < b.id;
    end)
    self.list_attr:setItemRenderer(function (idx, obj)
        local info = skillList[idx + 1];
        local str1 = obj:getChildAutoType("str1");
        local str2 = obj:getChildAutoType("str2");
        local spine = obj:getChildAutoType("spine");
        local c1 = obj:getController("state");
        c1:setSelectedIndex(info.up and 1 or 0);
        str1:setText(string.format("%s %s",Desc["equipment_sx"..info.id], info.pre))
        str2:setText(info.up or "")
    end)
    self.list_attr:setNumItems(#skillList)
end

function EquipmentUpStageView:getBag(type)
    local index = self.list_type:getSelectedIndex()
    type = type or (index == -1 and 0 or index)
    local conf = DynamicConfigData.t_equipEquipment
    local equipedList = EquipmentModel:getWearEqList()
    local material = {};
    for heroUuid, eqlist in pairs(equipedList) do
        local hero = CardLibModel:getHeroByUid(heroUuid)
        if (next(eqlist)) then
            for _, eq in pairs(eqlist) do
                if (eq) then
                    local c = conf[eq.code];
                    if (c and c.color >= 6 and (type == 0 or type == c.position)) then
                        local info = {
                            code = eq.code,
                            uuid = eq.uuid,
                            color = c.color,
                            pos = c.position,
                            heroUuid = heroUuid,
                            heroCode = hero.code,
                            star = c.staramount,
                            stage = 0,
                            name = c.name
                        }
                        table.insert(material, info);
                    end
                end
            end
        end
    end
    TableUtil.sortByMap(material, {{key="stage", asc=true}, {key="pos", asc=false}, {key="star",asc=true}})
    return material
end

return EquipmentUpStageView