-- add by zn
-- 饰品穿戴选择界面

local JewelryChoseListView = class("JewelryChoseListView", View);
function JewelryChoseListView:ctor()
	--LuaLog("JewelryChoseListView ctor")
	self._packName = "Jewelry"
	self._compName = "JewelryChoseListView"
	self._rootDepth = LayerDepth.PopWindow
    self._curPos = self._args.pos; -- 英雄的饰品槽位  1 左槽 2 右槽
    self.data = {};
	-- self.equipWearScore = 0 --身上穿的饰品评分
end

function JewelryChoseListView:_initEvent( )
	
end

function JewelryChoseListView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Equipment.JewelryChoseListView
        vmRoot.list = viewNode:getChildAutoType("$list")--list
        vmRoot.btn_getMore = viewNode:getChildAutoType("btn_getMore");
	--{vmFieldsEnd}:Equipment.JewelryChoseListView
    --Do not modify above code-------------
    
end

function JewelryChoseListView:_initUI( )
    self:_initVM()

    self.view:getChildAutoType("blackBg"):addClickListener(function()
		self:closeView()
    end,33)
    
    self.list:setVirtual()
	self.list:setItemRenderer(function(index,obj)
		self:itemShow(index, obj);
    end)

    self.btn_getMore:addClickListener(function ()
        ViewManager.open("ItemNotEnoughView", {type = CodeType.ITEM, code = 60000001, amount=1})    
    end)

	self:Jewelry_updateWear()
	
end


function JewelryChoseListView:Jewelry_updateWear( )
    self.data = {};

    local packbag = JewelryModel:getBag();
    for _, je in pairs (packbag) do
        local info = {};
        info.data = je;
        
        info.combot = JewelryModel:calcCombat(je);
        table.insert(self.data, info);
    end
    table.sort(self.data, function (a, b)
        return a.combot > b.combot;
    end)
    
    -- 计算当前穿戴装备的战力
    local jewelry = JewelryModel:getJewelryInHeroPos(self._curPos);
    if (jewelry) then
        local info = {};
        info.data = jewelry;
        info.combot = JewelryModel:calcCombat(jewelry);
        info.wear = true;
        -- if (jewelry.code == 60000002) then
        --     printTable(2233, jewelry.attr);
        -- end
        table.insert(self.data, 1, info);
    end
    local ctrl = self.view:getController("c1");
    if (self.data and #self.data > 0) then
        self.list:setNumItems(#self.data);
        ctrl:setSelectedIndex(0);
    else
        ctrl:setSelectedIndex(1);
    end
    
    -- -- printTable(2233, "饰品列表", self.data);
end

function JewelryChoseListView:itemShow(idx, obj)

    local eqdata = self.data[idx+1];
    local data = eqdata.data;
	if eqdata.wear then
		obj:getController("state"):setSelectedIndex(1)
	else
		obj:getController("state"):setSelectedIndex(0)
	end
	
	local shuxing = obj:getChildAutoType("shuxing")
	local jineng = obj:getChildAutoType("jineng")
	
	if not obj.itemcell then
		obj.itemcell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
		obj.itemcell.view:removeClickListener()
	end
    obj.itemcell:setData(data.code, 0, CodeType.ITEM)
	-- obj:getChildAutoType("starList"):setNumItems(eqInfo.staramount)
	obj:getChildAutoType("txt_name"):setText(data.name)
	obj:getChildAutoType("txt_power"):setText(eqdata.combot)
    -- obj:getChildAutoType("btn_c"):getChildAutoType("img_red"):setVisible(eqdata.totalPower > self.equipWearScore)

    -- 脱装
    local btn_t = obj:getChildAutoType("btn_t");
    btn_t:removeClickListener(33);
	btn_t:addClickListener(function()
        JewelryModel:takeOffJewelry(self._curPos);
	end,33)
    
    -- 穿装
    local btn_c = obj:getChildAutoType("btn_c");
    btn_c:removeClickListener(33);
	obj:getChildAutoType("btn_c"):addClickListener(function()
		JewelryModel:equipJewelry(data.uuid, self._curPos);
	end,33)
    
    local AttrConf = DynamicConfigData.t_combat;
    local attr = {};
    for _, v in ipairs(data.attr) do
        table.insert(attr, v)
    end
	shuxing:setItemRenderer(function(index, item)
        local sxInfo = attr[index+1]
        local name = item:getChildAutoType("name")
        -- printTable(2233, sxInfo.id, AttrConf[sxInfo.id]);
        name:setText(AttrConf[sxInfo.id].name)
        local value = item:getChildAutoType("value")
        if (sxInfo.id > 100) then
            value:setText(string.format("+%s%%", sxInfo.value / 100))
        else
            value:setText(string.format("+%s", sxInfo.value))
        end
	end)
	shuxing:setNumItems(#attr);
    
    local ctrl = obj:getController("c1")
    if (data.percentageValue and data.percentageValue > 0) then
        local percent = data.percentageValue
        ctrl:setSelectedIndex(1);
        local prog = obj:getChildAutoType("progressBar");
        prog:setMax(10000);
        prog:setValue(percent);
        prog:getChildAutoType("title"):setText((percent/100).."%")
    else
        ctrl:setSelectedIndex(0);
        local conf = DynamicConfigData.t_passiveSkill
        jineng:setItemRenderer(function(index,item)
            local skillId = data.skill[index + 1];
            local skillCell = BindManager.bindSkillCell(item)
            local ultSkillurl = CardLibModel:getItemIconByskillId(skillId);
            local info = conf[skillId];
            skillCell:showSkillName(2, info.name);
            local nameLab = skillCell.view:getChildAutoType("itemName")
            nameLab:setFontSize(40)
            nameLab:setColor(cc.c3b(0x45, 0x45, 0x45))
            skillCell.iconLoader:setURL(ultSkillurl) --放了一张技能图片
            skillCell.iconLoader:setScale(1,1)
            skillCell.iconLoader:removeClickListener(100)
            skillCell.iconLoader:addClickListener(
                function(context)
                    --点击查看技能详情
                    ViewManager.open("ItemTips", {codeType = CodeType.PASSIVE_SKILL, id = skillId, data = {id = skillId}});
                end,
                100
            )
            -- skillCell:setEquipmentData(skillInfo.id);
            item:getChildAutoType("n29"):setVisible(false)
        end)
        jineng:setNumItems(#data.skill)
    end
end


return JewelryChoseListView