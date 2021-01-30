-- add by zn
-- add by zn
-- 饰品合成界面

local JewelryMergeView = class("JewelryMergeView", View);

function JewelryMergeView: ctor()
    self._packName = "Jewelry";
    self._compName = "JewelryMergeView";
    self.type = false;
    self.addNum = 5;
    self.data = {};
    JewelryModel:clearSelected();
    self.spine = false;
    self.fiveSpineNode1 = false;
    self.fiveSpineNode2 = false;
    self.spineNode = false;
    self.spineCell = false;
    self.spineFly = false;
    self.effectTimer = {};
    self.isMerging = false;
end

function JewelryMergeView: _initVM()
    local root = self;
    local rootView = self.view;
        root.list_bag = rootView:getChildAutoType("com_bag/list_bag");
        root.list_type = rootView:getChildAutoType("com_bag/list_type");
        
        for i = 1, 5 do
            root["btn_item"..i] = rootView:getChildAutoType("btn_item"..i);
        end
        root.itemCell = BindManager.bindItemCell(rootView:getChildAutoType("itemCell"));
        root.txt_success = rootView:getChildAutoType("txt_success");
        root.txt_num = rootView:getChildAutoType("txt_num");
        root.btn_numAdd = rootView:getChildAutoType("btn_numAdd");
        root.btn_numSub = rootView:getChildAutoType("btn_numSub");
        root.btn_addItem = rootView:getChildAutoType("btn_addItem"); -- 一键添加
        root.btn_merge = rootView:getChildAutoType("btn_merge"); -- 合成
        root.costBar = BindManager.bindCostBar(rootView:getChildAutoType("costBar"));
        root.costGroup = rootView:getChildAutoType("costGroup");
        root.btn_flock = rootView:getChildAutoType("btn_flock"); -- 熔炼
        root.progress = root.btn_flock:getChildAutoType("porgress");
        root.exchangeItem = BindManager.bindItemCell(root.btn_flock:getChildAutoType("itemCell"));
        root.sucPanel = rootView:getChildAutoType("successRate");
        root.btn_preview = rootView:getChildAutoType("btn_preview");
        root.loader = root.btn_flock:getChildAutoType("loader");
        root.spineParent = rootView:getChildAutoType("spineParent");
        root.btn_output = rootView:getChildAutoType("btn_output");
end

function JewelryMergeView: _initUI()
    self:_initVM();
	self.costBar:setDarkBg(true)
    self.list_bag:setItemRenderer(function (idx, obj)
        self:upBagItem(idx, obj)
    end)
    self.itemCell:setVisible(false);
    self.itemCell:setAmountVisible(false);
    self.view:getChildAutoType("successRate"):setVisible(false);
    self.costGroup:setVisible(false);
    self.list_bag:setVirtual();
    self:changeBagShow(0);
    self.list_type:setSelectedIndex(0);
    self.progress:setMax(1000);
    self.progress:setValue(JewelryModel.proficiency);
    self.txt_num:setText(self.addNum);
    self:upMergeAear();
    self.exchangeItem:setAmountVisible(false);
    self.exchangeItem:setData(60000004, 1, GameDef.GameResType.Item);
    self:createSpine();
end

function JewelryMergeView: _initEvent()
    self.list_type:addClickListener(function ()
        local index = self.list_type:getSelectedIndex();
        if (index ~= 0) then
            index = index + 2;
        end
        self:changeBagShow(index);
    end)

    self.btn_numAdd:addClickListener(function ()
        self.addNum = math.min(self.addNum + 1, 5);
        self.txt_num:setText(self.addNum);
    end)

    self.btn_numSub:addClickListener(function ()
        self.addNum = math.max(self.addNum - 1, 1);
        self.txt_num:setText(self.addNum);
    end)

    self.btn_merge:addClickListener(function ()
        if (self.isMerging) then return end;

        local list = {};
        local color = false;
        local code = false;
        for _, uuid in ipairs (JewelryModel.selectedArr) do
            if (uuid) then
                local d = JewelryModel:getJewelryByUuid(uuid)
                local c = d.color;
                if (color == false) then
                    color = c;
                    code = d.code;
                elseif (color ~= c) then
                    RollTips.show(Desc.Jewelry_colorDiff);
                    return;
                end
                table.insert(list, uuid);
            end
        end
        -- 个数判断
        if (#list == 0) then
            RollTips.show(Desc.Jewelry_mergeNoItem);
            return;
        elseif (#list == 1) then
            RollTips.show(Desc.Jewelry_minMergeNum);
            return;
        end
        -- 消耗判断
        local conf = DynamicConfigData.t_JewelryComposite[#list][code];
        if (conf and PlayerModel:isCostEnough(conf.cost)) then
            self.isMerging = true;
            self:showSpine(function ()
                JewelryModel:merge(list);
                self.isMerging = false;
            end)
        end
    end)
    -- 一键添加
    self.btn_addItem:addClickListener(function ()
        if (self.isMerging) then return end;
        local arr = JewelryModel:addAllJewelry(self.addNum);
        if (arr) then
            JewelryModel.selectedArr = {};
            JewelryModel.selectedArr = arr;
            self:addItemRefreshView()
        end
    end)

    self.btn_flock:addClickListener(function ()
        ViewManager.open("JewelryExchangeTipView");
    end)

    self.btn_preview:addClickListener(function ()
        ViewManager.open("JewelrySkillView");
    end)

    self.btn_output:addClickListener(function ()
        local cost = {code = 60000001, type = GameDef.GameResType.Item, amount = 1};
        ViewManager.open("ItemNotEnoughView", cost)
    end)
end

function JewelryMergeView:addItemRefreshView()
    self.list_bag:setNumItems(TableUtil.GetTableLen(self.data));
    self:upMergeAear();
end

function JewelryMergeView: _refresh()
    JewelryModel:clearSelected();
    self.list_type:setSelectedIndex(0);
    self:changeBagShow(0);
    self:upMergeAear();
end

function JewelryMergeView: createSpine()
    if (self.spine) then
        self.spine:removeFromParent();
        self.spine = false;
    end
    if (JewelryModel.proficiency >= 1000) then
        self.spine = SpineMnange.createSpineByName("Effect/UI/efx_tongyongyuankuang")
        self.loader:displayObject():addChild(self.spine)
        self.spine:setPosition(50, 50);
        self.spine:setAnimation(0, "tongyongyuankuang_chong", true);
    end
end

-- 更新数据
function JewelryMergeView:Jewelry_upView()
    self:changeBagShow(self.type)
    self:upMergeAear();
end

function JewelryMergeView:Jewelry_mergeSuccess(_, param)
    if (param and param.isSuccess) then
        local item = param.item[1];
        local data = {
			show = 1,
			reward = {{code = item.code, amount= 1, type=GameDef.GameResType.Item}};
		}
        ViewManager.open("AwardShowView",data);
    end
    JewelryModel:getItemsByType(0);
    self:Jewelry_upView();
end

function JewelryMergeView: changeBagShow(type)
    self.type = type;
    local bagArr = JewelryModel: getItemsByType(type);
    self.data = {};
    if (#bagArr > 0) then
        -- 剔除红色品质
        for i = 1, #bagArr do
            if (bagArr[i].code ~= 60000005) then
                table.insert(self.data, bagArr[i]);
            end
        end
        TableUtil.sortByMap(self.data, {{key = "color", asc = false}})
        self.list_bag:setNumItems(#self.data);
    else
        self.list_bag:setNumItems(0);
    end
end

function JewelryMergeView: upBagItem(idx, obj)
    local data = self.data[idx + 1];
    local itemCell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"));
    itemCell:setData(data.code, 1, GameDef.GameResType.Item);
    local nameLab = obj:getChildAutoType("txt_name")
    nameLab:setText(data.name);
    nameLab:setColor(ColorUtil.getItemColor(data.color));
    local ctrl = obj:getController("button");
    if (JewelryModel:isSelected(data.uuid)) then
        ctrl:setSelectedIndex(1);
    else
        ctrl:setSelectedIndex(0);
    end

    local list_attr = obj:getChildAutoType("list_attr");
    local conf = DynamicConfigData.t_combat;
    list_attr:setItemRenderer(function (idx, obj)
        local d = data.attr[idx + 1];
        obj:setTitle(conf[d.id].name);
        if (d.id > 100) then
            obj:getChildAutoType("value"):setText(string.format("+%s%%", d.value / 100));
        else
            obj:getChildAutoType("value"):setText("+"..d.value);
        end
    end)
    list_attr:setNumItems(#data.attr);

    obj:removeClickListener();
    obj:addClickListener(function ()
        if (self.isMerging) then return end;
        if (JewelryModel:isSelected(data.uuid)) then
            JewelryModel:unselect(data.uuid);
            ctrl:setSelectedIndex(0);
            self:upMergeAear();
        elseif (JewelryModel:select(data.uuid)) then
            ctrl:setSelectedIndex(1);
            self:upMergeAear();
        end
    end)
end

function JewelryMergeView: upMergeAear()
    for idx = 1, 5 do
        local uuid = JewelryModel.selectedArr[idx];
        local item = self["btn_item"..idx];
        local ctrl = item:getController("c1");
        ctrl:setSelectedIndex(uuid and 0 or 1);
        if (not item.cell) then
            item.cell = BindManager.bindItemCell(item:getChildAutoType("itemCell"));
            -- item.cell:setIsBig(true);
        end
        if (uuid) then
            local data = JewelryModel:getJewelryByUuid(uuid);
            item.cell:setData(data.code, 1, GameDef.GameResType.Item);
        end
        item:removeClickListener();
        item:addClickListener(function ()
            if (self.isMerging) then return end;
            if (uuid and JewelryModel:isSelected(uuid)) then
                JewelryModel:unselect(uuid);
                self.list_bag:setNumItems(TableUtil.GetTableLen(self.data));
                ctrl:setSelectedIndex(1);
                self:showMergePreshow();
            end
        end)
    end
    self:showMergePreshow();
    self.progress:setValue(JewelryModel.proficiency);
    self:createSpine();
end

-- 提前预览合成道具
function JewelryMergeView:showMergePreshow()
    local color, code = JewelryModel:checkSelectedColor();
    if (color and JewelryModel.selectedNum > 1) then
        self.itemCell:setVisible(true);
        self.sucPanel:setVisible(true);
        local conf = DynamicConfigData.t_JewelryComposite[JewelryModel.selectedNum][code];
        local rate = conf.rate * 100;
        self.txt_success:setText(string.format(Desc.Jewelry_mergeSucRate, rate));
        local successCode = conf.sucProduct;
        if (successCode) then
            self.itemCell:setData(successCode, 1, GameDef.GameResType.Item);
        end
        self.costBar:setData(conf.cost, true, false);
        self.costGroup:setVisible(true);
    else
        self.itemCell:setVisible(false);
        self.sucPanel:setVisible(false);
        self.costGroup:setVisible(false);
    end
    self:showFiveRuneComp();
end


--满五个  可合成特效
function JewelryMergeView:showFiveRuneComp(  )
	if JewelryModel.selectedNum >= 2 then --满5个
		if not self.fiveSpineNode1 then
		    self.fiveSpineNode1 = SpineUtil.createSpineObj(self.spineParent, vertex2(self.spineParent:getWidth()/2,self.spineParent:getHeight()/2), "fw_liuguang", "Spine/ui/rune", "fuwenxitong_texiao", "fuwenxitong_texiao",true)
	    else
			self.fiveSpineNode1:setVisible(true)
		end

		if not self.fiveSpineNode2 then
		    self.fiveSpineNode2 = SpineUtil.createSpineObj(self.spineParent, vertex2(self.spineParent:getWidth()/2,self.spineParent:getHeight()/2), "fw_shan", "Spine/ui/rune", "fuwenxitong_texiao", "fuwenxitong_texiao",true)
	    else
			self.fiveSpineNode2:setVisible(true)
		end

	else
		if self.fiveSpineNode1 then
			self.fiveSpineNode1:setVisible(false)
		end
		if self.fiveSpineNode2 then
			self.fiveSpineNode2:setVisible(false)
		end
	end
end

--显示特效 合成飞行特效
function JewelryMergeView:showSpine( cb )
    if JewelryModel.selectedNum >= 2 then
        self.spineCell = self.spineCell or {};
        self.spineFly = self.spineFly or {};
        -- 闪光特效
        for i in pairs(JewelryModel.selectedArr) do
            if (JewelryModel.selectedArr[i]) then
                if (not self.spineCell[i]) then
                    local item = self["btn_item"..i]
                    self.spineCell[i] = SpineUtil.createSpineObj(item, vertex2(item:getWidth()/2,item:getHeight()/2), "fw_hecheng1", "Spine/ui/rune", "fuwenxitong_texiao", "fuwenxitong_texiao",false)
                else
                    self.spineCell[i]:setAnimation(0, "fw_hecheng1", false);
                end
            end
        end
        -- 飞行特效
        local effectFunc2 = function ()
            for i in pairs(JewelryModel.selectedArr) do
                if (JewelryModel.selectedArr[i]) then
                    if (not self.spineFly[i]) then
                        local item = self.spineParent;
                        self.spineFly[i] = SpineUtil.createSpineObj(item, vertex2(item:getWidth()/2,item:getHeight()/2), "fw_hecheng2", "Spine/ui/rune", "fuwenxitong_texiao", "fuwenxitong_texiao",false)
                        self.spineFly[i]:setRotation(-72*(i-1)+90);
                    else
                        self.spineFly[i]:setAnimation(0, "fw_hecheng2", false);
                    end
                end
            end
            self.effectTimer[2] = nil;
        end
        self.effectTimer[2] = Scheduler.scheduleOnce(0.2, effectFunc2);
        -- 合成特效
        local effectFunc3 = function ()
            if not self.spineNode then
                self.spineNode = SpineUtil.createSpineObj(self.spineParent, vertex2(self.spineParent:getWidth()/2,self.spineParent:getHeight()/2), "fw_hecheng3", "Spine/ui/rune", "fuwenxitong_texiao", "fuwenxitong_texiao",false)
            else
                self.spineNode:setAnimation(0, "fw_hecheng3", false);
            end
            self.effectTimer[3] = nil;
        end
        self.effectTimer[3] = Scheduler.scheduleOnce(0.3, effectFunc3);
        if (cb) then
            self.effectTimer[4] = Scheduler.scheduleOnce(1.3, cb);
        end
    else
        if cb then cb() end
    end
    
end

function JewelryMergeView:_exit()
    for key, timerId in pairs(self.effectTimer) do
        Scheduler.unschedule(timerId);
        self.effectTimer[key] = nil;
    end
end

return JewelryMergeView