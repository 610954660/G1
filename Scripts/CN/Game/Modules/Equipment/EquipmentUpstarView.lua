-- add by zn
-- 装备升星界面

local EquipmentUpstarView = class("EquipmentUpstarView", Window)

function EquipmentUpstarView:ctor()
    self._packName = "Equipment"
    self._compName = "EquipmentUpstarView"
    self._rootDepth = LayerDepth.PopWindow
    self.curUuid = self._args.uuid;
    self.bag = {};
    self.selected = {};
    self.data, self.heroUuid= EquipmentModel:getEqDataByUuid(self.curUuid);
    self.isAnimation = false;
    self.addExpToLv = 0; -- 选中的经验能升的级数
    self.selectStatus = 0; -- 0 可以选择升级  1  需要进阶了  2 该装备已经顶级
    self.onKeyLimitColor = FileCacheManager.getIntForKey("EquipmentUpstarView_onKey", 4);
end

function EquipmentUpstarView:_initUI()
    local root = self
    local rootView = self.view
        root.btn_cancel = rootView:getChildAutoType("btn_cancel");
        root.list_item = rootView:getChildAutoType("list_item");
        root.txt_name = rootView:getChildAutoType("name");
        for i = 1, 3 do
            root["itemCell"..i] = BindManager.bindItemCell(rootView:getChildAutoType("itemCell"..i));
        end
        root.list_attr = rootView:getChildAutoType("list_attr");
        -- 升星部分
        root.txt_exp = rootView:getChildAutoType("txt_exp");
        root.expIcon = rootView:getChildAutoType("expIcon");
        root.progressBar = rootView:getChildAutoType("progressBar");
        root.btn_addAll = rootView:getChildAutoType("btn_addAll");
        root.btn_sure = rootView:getChildAutoType("btn_sure");
        root.btn_left = rootView:getChildAutoType("btn_left");
        root.closeTips = rootView:getChildAutoType("closeTips");
        root.closeTips1 = rootView:getChildAutoType("closeTips1");
        root.btn_right = rootView:getChildAutoType("btn_right");
        root.txt_color = rootView:getChildAutoType("txt_color/txt_color");
        root.list_color = rootView:getChildAutoType("list_color");
        root.list_equip = rootView:getChildAutoType("list_equip");
        -- 进阶部分
        root.costItem = BindManager.bindCostItem(rootView:getChildAutoType("costItem"));
        root.btn_uplv = rootView:getChildAutoType("btn_uplv");
        root.txt_tips = rootView:getChildAutoType("txt_tips");
        
        self.list_item:setVirtual();
        self.list_equip:setVirtual()
        self.txt_tips:setText(Desc.equipment_upstar_tips);
        self.spinenode = rootView:getChildAutoType("spinenode")
	self.spinenode.skeletonNode = SpineUtil.createSpineObj(self.spinenode,vertex2(0,0), "ui_zhuangbeishengxing", "Spine/ui/Emblem", "efx_wenzhang", "efx_wenzhang",false,true)
	self.spinenode:setVisible(false)

    self:_refresh();
    self:upOneKeyLimit();
    self:initListColor();
end

function EquipmentUpstarView:_initEvent()
    -- 全部取消
    self.btn_cancel:addClickListener(function()
        if (self.isAnimation) then return end
        self.selected = {};
        self:_refresh();
    end)

    -- 一键添加
    self.btn_addAll:addClickListener(function()
        if (self.isAnimation) then return end
        local flag, idx = self:selectOneKey()
        if (flag) then
            idx = idx and idx - 1 or false;
            self:upBagList(idx);
            self:upRightPanel();
        end
    end)

    self.btn_left:addClickListener(function()
        self.onKeyLimitColor = math.max(self.onKeyLimitColor - 1, 2);
        self:upOneKeyLimit();
        FileCacheManager.setIntForKey("EquipmentUpstarView_onKey", self.onKeyLimitColor);
    end)

    self.btn_right:addClickListener(function()
        self.onKeyLimitColor = math.min(self.onKeyLimitColor + 1, 6);
        self:upOneKeyLimit();
        FileCacheManager.setIntForKey("EquipmentUpstarView_onKey", self.onKeyLimitColor);
    end)

    self.closeTips:addClickListener(function()
        local ctrl = self.view:getController("c3");
        ctrl:setSelectedIndex(0)
    end)

    self.closeTips1:addClickListener(function()
        local ctrl = self.view:getController("c4");
        ctrl:setSelectedIndex(0)
    end)

    -- 确认升星
    self.btn_sure:addClickListener(function()
        if (self.isAnimation) then return end
        local endCode = self:checkAddedExp();
        local code = self.data.code;
        local uuid = self.data.uuid;
        if (endCode == code and TableUtil.GetTableLen(self.selected) == 0) then
            RollTips.show(Desc.equipment_upstar_notenough);
            return
        end
        local arr = {};
        local haveHigherEq = false; -- 是否有高级装备
        for k, d in pairs(self.selected) do
            if(d.color and d.color > 4) then
                haveHigherEq = true;
            end
            table.insert(arr, k);
        end
        if (haveHigherEq) then
            local info = {
                text = Desc.equipment_upstar_selecthigherEq,
                type = "yes_no",
                onYes = function()
                    EquipmentModel:upStar(uuid, arr, self.heroUuid)
                end
            }
            Alert.show(info);
        else
            EquipmentModel:upStar(uuid, arr, self.heroUuid)
        end
        -- else
        --     RollTips.show(Desc.equipment_upstar_notenough);
        -- end
    end)

    -- 进阶
    self.btn_uplv:addClickListener(function()
        if (self.isAnimation) then return end
        local uuid = self.data.uuid;
        EquipmentModel:upgrade(uuid, self.heroUuid)
    end)
end

function EquipmentUpstarView:initListColor()
    self.list_color:setItemRenderer(function(idx, obj)
        obj:getChildAutoType("txt_color"):setText(Desc["onKeyLimitColor_"..(6 - idx)]);
        obj:removeClickListener()
        obj:addClickListener(function()
            self.onKeyLimitColor = 6 - idx;
            self:upOneKeyLimit();
            FileCacheManager.setIntForKey("EquipmentUpstarView_onKey", self.onKeyLimitColor);
            local ctrl = self.view:getController("c3");
            ctrl:setSelectedIndex(0)
        end)
    end)
    self.list_color:setNumItems(6)
end

function EquipmentUpstarView:upOneKeyLimit()
    -- self.btn_left:setVisible(self.onKeyLimitColor ~= 2);
    -- self.btn_right:setVisible(self.onKeyLimitColor ~= 6);
    self.txt_color:setText(Desc["onKeyLimitColor_"..self.onKeyLimitColor]);
end

function EquipmentUpstarView:upListEquip()
    local conf = DynamicConfigData.t_equipEquipment
    local bag = EquipmentModel:getEquipBag().__packItems
    local equipedList = EquipmentModel:getWearEqList()
    local material = {};
    for _, eq in pairs(bag) do
        local d = eq.__data;
        local uuid = d.uuid;
        local color = eq:getColorId();
        if (uuid ~= self.curUuid) then
            local info = {
                code = d.code,
                uuid = uuid,
                color = color
            }
            local c = conf[d.code];
            info.pos = c.position
            table.insert(material, info);
        end
    end
    for heroUuid, eqlist in pairs(equipedList) do
        if (next(eqlist)) then
            for _, eq in pairs(eqlist) do
                if (eq and eq.uuid ~= self.curUuid) then
                    local c = conf[eq.code];
                    local info = {
                        code = eq.code,
                        uuid = eq.uuid,
                        color = c.color,
                        pos = c.position,
                        heroUuid = heroUuid,
                    }
                    table.insert(material, info);
                end
            end
        end
    end
    table.sort(material, function(a, b)
        if (a.color == b.color) then
            if (a.pos == b.pos) then
                return a.code > b.code
            end
            return a.pos < b.pos
        else
            return a.color > b.color;
        end
    end)

    self.list_equip:setItemRenderer(function(idx, obj)
        local d = material[idx + 1]
        if (not obj.cell) then
            obj.cell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"));
        end
        local headBg = obj:getChildAutoType("head_frame");
        local head = obj:getChildAutoType("hero_icon");
        if (d.heroUuid) then
            headBg:setVisible(true);
            head:setVisible(true);
            local hero = CardLibModel:getHeroByUid(d.heroUuid);
            head:setIcon(PathConfiger.getHeroHead(hero.code));
        else
            headBg:setVisible(false);
            head:setVisible(false);
        end
        obj.cell:setIsBig(true)
        obj.cell:setData(d.code, 0, GameDef.GameResType.item);
        obj.cell:setClickable(false);
        obj:removeClickListener()
        obj:addClickListener(function()
            if (self.isAnimation) then return end
            self:_refresh(d.uuid);
            local ctrl = self.view:getController("c4");
            ctrl:setSelectedIndex(0)
        end)
    end)
    self.list_equip:setNumItems(#material)
end

-- 只是播特效
function EquipmentUpstarView:equipUpstar_refresh(_, newEqUuid)
    local newData = EquipmentModel:getEqDataByUuid(newEqUuid);
    if (newData.code ~= self.data.code) then
        self.isAnimation = true;
        self.spinenode:setVisible(true)
        self.spinenode.skeletonNode:stopAllActions()
        self.spinenode.skeletonNode:setCompleteListener(function(name)
            if name == "ui_zhuangbeishengxing" then
                self.spinenode:setVisible(false)
            end
        end)
        self.spinenode.skeletonNode:setAnimation(0,"ui_zhuangbeishengxing",false)
        Scheduler.scheduleOnce(1.3, function()
            if (tolua.isnull(self.view)) then
                return;
            end
            self.isAnimation = false;
            self:_refresh(newEqUuid)
        end)
    else
        self:_refresh(newEqUuid)
    end
end

function EquipmentUpstarView:_refresh(newEqUuid)
    if (newEqUuid) then
        self.curUuid = newEqUuid;
        self.data, self.heroUuid = EquipmentModel:getEqDataByUuid(self.curUuid);
    end
    self.selected = {};
    self.bag = self:getAllMaterial();
    self:upBagList();
    self:upRightPanel();
    self:upListEquip()
end

function EquipmentUpstarView:upRightPanel()
    local curCode = self.data.code or 0;
    local conf = DynamicConfigData.t_equipEquipment[curCode];
    local c1 = self.view:getController("c1");
    local c2 = self.view:getController("c2");
    self.txt_name:setText(conf.name);
    if (conf and conf.next == 0) then -- 当前装备已经满级
        c1:setSelectedIndex(0);
        c2:setSelectedIndex(2);
        self.itemCell1:setData(curCode, 0, GameDef.GameResType.item);
        self:upProgress(curCode, "max");
        self:upAttrList(curCode);
    elseif (conf and conf.next ~= 0 and conf.levelUpExp == 0) then-- 显示升阶形式
        c1:setSelectedIndex(1);
        c2:setSelectedIndex(1);
        for i = 2, 3 do
            local itemCell = self["itemCell"..i];
            local code = i == 2 and curCode or conf.next;
            itemCell:setData(code, 0, GameDef.GameResType.item);
        end
        local cost = conf.upCost[1]
        self.costItem:setData(cost.type, cost.code, cost.amount);
        self:upAttrList(curCode);
    else
        local endCode, preCode, exp = self:checkAddedExp();
        c1:setSelectedIndex(endCode == curCode and 0 or 1);
        c2:setSelectedIndex(0);
        for i = 1, 3 do
            local itemCell = self["itemCell"..i];
            local code = i == 3 and endCode or curCode
            itemCell:setData(code, 0, GameDef.GameResType.item);
        end
        local code = self.selectStatus == 0 and endCode or preCode;
        self:upProgress(code, exp);
        self:upAttrList(endCode);
    end
    
end

function EquipmentUpstarView:upProgress(showCode, exp)
    local conf = DynamicConfigData.t_equipEquipment[showCode];
    local max = conf.levelUpExp
    exp = exp == "max" and max or exp;
    self.progressBar:setMax(max);
    self.progressBar:setValue(exp);
    if (exp == "max") then
        self.txt_exp:setText("MAX");
    else
        -- self.txt_exp:setText(string.format("%s/%s", StringUtil.transValue(exp), StringUtil.transValue(max)));
        self.txt_exp:setText((math.ceil((exp/max)*10000) / 100).."%");
    end
end

function EquipmentUpstarView:upAttrList(code)
    local curCode = self.data.code;
    local allConf = DynamicConfigData.t_equipEquipment;
    local curConf = allConf[curCode];
    local showConf = allConf[code]
    local attrMap = {
        ["hp"] = 1,
        ["attack"] = 2,
        ["defense"] = 3,
        ["magic"] = 4,
        ["magicDefense"] = 5,
        ["speed"] = 6,
    }
    local skillList = {}
    for k, v in pairs(attrMap) do
        local info = {
            id = v
        }
        if (code ~= curCode) then
            info.up = showConf[k];
        end
        if (curConf[k] ~= 0) then
            info.pre = curConf[k]
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

-- 更新背包
function EquipmentUpstarView:upBagList(scrollTo)
    self.list_item:setItemRenderer(function(idx, obj)
        self:upBagItem(self.bag[idx + 1], obj);
    end)
    self.list_item:setNumItems(#self.bag);
    if (scrollTo) then
        self.list_item:scrollToView(scrollTo, true);
    end
end


function EquipmentUpstarView:upBagItem(data, obj)
    local d = data
    if (not obj.cell) then
        obj.cell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"));
    end
    obj.cell:setData(d.code, 0, GameDef.GameResType.item);
    local icon = obj:getChildAutoType("exp_icon");
    local txt_exp = obj:getChildAutoType("txt_exp");
    local txt_name = obj:getChildAutoType("txt_name");
    local txt_num = obj:getChildAutoType("txt_num");
    local btn_sub = obj:getChildAutoType("btn_sub");
    local c1 = obj:getController("c1"); -- 0 没选中  1 选中
    local c2 = obj:getController("c2"); -- 0 不显示 1 显示
    local selectedCount = self.selected[d.uuid] and self.selected[d.uuid].count or 0;
    c1:setSelectedIndex(selectedCount > 0 and 1 or 0);
    c2:setSelectedIndex(d.color and 1 or 0);
    local iconPath = PathConfiger.getItemIcon(10000017);
    icon:setIcon(iconPath);
    txt_exp:setText(StringUtil.transValue(d.exp));
    txt_name:setText(d.name);
    txt_num:setVisible(d.code == 10000017);
    -- txt_num:setText(string.format("%s/%s", StringUtil.transValue(selectedCount), StringUtil.transValue(d.amount)));
    txt_num:setText(string.format("%s", StringUtil.transValue(d.amount)));

    local uuid = d.uuid
    local code = d.code
    local max = d.amount
    obj:removeClickListener()
    obj:addClickListener(function()
        if (self.isAnimation) then return end
        if (self.selectStatus == 0) then
            if (not self.selected[uuid]) then
                self.selected[uuid] = {
                    count = 0,
                    exp = 0,
                    color = 0,
                }
            end
            local selected = self.selected[uuid] and self.selected[uuid].count or 0;
            -- if code == 10000017 and self.selected[uuid] then
            --     self.selected[uuid].count = selected + max;
            --     self.selected[uuid].exp = self.selected[uuid].exp + d.exp * max;
            --     c1:setSelectedIndex(1);
            --     txt_num:setText(string.format("%s/%s", StringUtil.transValue(max), StringUtil.transValue(max)));
            --     self:upRightPanel()
            if (selected < max) then
                selected = code == 10000017 and selected + max or selected + 1;
                self.selected[uuid].count = selected;
                self.selected[uuid].exp = d.exp * selected;
                self.selected[uuid].color = d.color;
                c1:setSelectedIndex(1);
                -- txt_num:setText(string.format("%s/%s", StringUtil.transValue(selected), StringUtil.transValue(max)));
                txt_num:setText(string.format("%s", StringUtil.transValue(max)));
                self:upRightPanel()
            end
        else
            RollTips.show(Desc.equipment_upstar_status1);
        end
    end)

    btn_sub:removeClickListener()
    btn_sub:addClickListener(function(context)
        context:stopPropagation()
        if (self.isAnimation) then return end
        local selected = self.selected[uuid] and self.selected[uuid].count or 0;
        if (selected > 0) then
            selected = code == 10000017 and selected - max or selected - 1;
            self.selected[uuid].count = selected;
            self.selected[uuid].exp = d.exp * selected;
            -- txt_num:setText(string.format("%s/%s", StringUtil.transValue(selected), StringUtil.transValue(max)));
            txt_num:setText(string.format("%s", StringUtil.transValue(max)));
            self:upRightPanel()
        end
        if (selected == 0) then
            c1:setSelectedIndex(0);
            self.selected[uuid] = nil;
        end
        if (code == 10000017) then
            c1:setSelectedIndex(0);
            txt_num:setText(StringUtil.transValue(max));
        end
    end)
end

-- 获得所有升星材料
function EquipmentUpstarView:getAllMaterial()
    local conf = DynamicConfigData.t_equipEquipment
    local bag = EquipmentModel:getEquipBag().__packItems
    local curConf = conf[self.data.code]
    local material = {};
    for _, eq in pairs(bag) do
        local d = eq.__data;
        local c = conf[d.code];
        local code = d.code;
        local color = eq:getColorId();
        local uuid = d.uuid;
        local extraData = d.specialData and d.specialData.equipment or {};
        local extraExp = extraData.starExp or 0;
        if (uuid ~= self.curUuid and (color < curConf.color or (color == curConf.color and c.staramount <= curConf.staramount))) then
            local info = {
                code = code,
                uuid = uuid,
                color = color,
                amount = 1,
                name = eq:getName()
            }
            info.exp = c and c.decompose or 0;
            info.exp = info.exp + extraExp;
            info.pos = c.position
            table.insert(material, info);
        end
    end
    table.sort(material, function(a, b)
        if (a.color == b.color) then
            if (a.pos == b.pos) then
                return a.code < b.code
            end
            return a.pos < b.pos
        else
            return a.color < b.color;
        end
    end)
    local pack = PackModel:getNormalBag();
    local items = pack:getItemsByCode(10000017);
    local uuid = "";
    local amount = 0;
    local name = "";
    -- for _, item in pairs(items) do
    --     local d = item.__data;
    --     amount = amount + d.amount;
    --     if (d.uuid) then
    --         uuid = d.uuid;
    --         name = item:getName()
    --         -- break;
    --     end
    -- end
    for _, item in pairs(items) do
        local d = item.__data;
        if (d.uuid) then
            local info = {
                code = 10000017,
                amount = d.amount,
                uuid = d.uuid,
                exp = 1,
                name = d.name,
                color = item:getColorId()
            }
            table.insert(material, 1, info);
        end
    end
    
    
    return material;
end

-- 获取已选择的经验的升级情况
function EquipmentUpstarView:checkAddedExp()
    -- 计算已选择的经验
    self.selectStatus = 0;
    local exp = 0;
    for _, d in pairs(self.selected) do
        if (d and d.exp) then
            exp = exp + d.exp;
        end
    end
    local baseExp = self.data and self.data.extraExp or 0;
    exp = baseExp + exp;
    local eqCode = self.data.code;
    local preCode = eqCode; -- 显示需要
    local preExp = exp; -- 显示需要
    local conf = DynamicConfigData.t_equipEquipment;
    while (exp >= 0) do
        local c = conf[eqCode];
        if (c.next == 0) then
            -- 满级了
            exp = preExp;
            self.selectStatus = 2;
            break;
        else
            local needExp = c.levelUpExp
            if (needExp == 0) then
                -- 该进阶了
                exp = preExp;
                self.selectStatus = 1;
                break;
            else
                local leaveExp = exp - needExp;
                if (leaveExp < 0) then
                    -- 经验不够升级了
                    preCode = eqCode;
                    break;
                else
                    preExp = exp
                    exp = leaveExp;
                    preCode = eqCode;
                    eqCode = c.next;
                end
            end
        end
    end
    return eqCode, preCode, exp
end

function EquipmentUpstarView:selectOneKey()
    self.selected = {};
    local allItems = self:getAllMaterial();
    local startCode = self:checkAddedExp();
    local idx = false
    if (#allItems == TableUtil.GetTableLen(self.selected)) then
        RollTips.show(Desc.equipment_upstar_selectOneKey);
    elseif (self.selectStatus == 0) then
        for i, item in ipairs(allItems) do
            if not self.selected[item.uuid] then
                local count = item.amount;
                if (item.code == 10000017 and self.selected[item.uuid]) then
                    local c = self.selected[item.uuid].count;
                    local exp = self.selected[item.uuid].exp;
                    self.selected[item.uuid].count = c + count;
                    self.selected[item.uuid].exp = exp + item.exp * count;
                else
                    if (item.color <= self.onKeyLimitColor) then
                        self.selected[item.uuid] = {
                            count = count,
                            exp = item.exp * count,  
                            color = item.color
                        }
                        idx = i
                    end
                end
                
                local endCode = self:checkAddedExp();
                if (self.selectStatus ~= 0 or endCode ~= startCode) then
                    break;
                end
            end
        end
        if (idx == false) then
            RollTips.show(Desc.equipment_upstar_selectOneKey);
        end
        return true, idx;
    else
        RollTips.show(Desc.equipment_upstar_status1);
    end
    return false;
end

return EquipmentUpstarView