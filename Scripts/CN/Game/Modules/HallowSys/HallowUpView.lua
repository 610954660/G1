-- add by zn
-- 圣器升级界面

local HallowUpView = class("HallowUpView", Window)

function HallowUpView:ctor()
    self._packName = "HallowSys"
    self._compName = "HallowUpView"
    -- self._rootDepth = LayerDepth.PopWindow
    self.hallowType = self._args.type or 1;
    self.lvUpEffect1 = false
    self.lvUpEffect2 = false
end

function HallowUpView:_initUI()
    local root = self
    local rootView = self.view
        root.list_type = rootView:getChildAutoType("list_type");
        root.list_attr = rootView:getChildAutoType("list_attr");
        root.list_skill = rootView:getChildAutoType("list_skill");
        root.txt_hallowAdd = rootView:getChildAutoType("txt_hallowAdd"); -- 基座加成
        root.txt_hallowLv = rootView:getChildAutoType("txt_hallowLv"); -- 圣器等级
        root.costBar = BindManager.bindCostBar(rootView:getChildAutoType("costBar"));
        root.progress = rootView:getChildAutoType("progressBar");
        root.btn_up = rootView:getChildAutoType("btn_up");
        root.btn_upBase = rootView:getChildAutoType("btn_upBase");
        root.loader_icon = rootView:getChildAutoType("loader_icon");
        root.txt_curLv = rootView:getChildAutoType("txt_curLv")
        root.txt_nextLv = rootView:getChildAutoType("txt_nextLv")
        root.btn_relicCopy = rootView:getChildAutoType("btn_relicCopy")
    
    local parent = rootView:getChildAutoType("loader_effect")
    local pos = cc.p(parent:getWidth()/2, parent:getHeight()/2)
    SpineUtil.createSpineObj(parent, pos, "ui_shengqizhanshi_loop", "spine/ui/hallow", "efx_shengqizhanshi", "efx_shengqizhanshi", true)
    self.list_type:setSelectedIndex(self.hallowType - 1);
    self:refreshListTypeInfo();
    self:refreshRightPanel();
end

function HallowUpView:_initEvent()
    self.list_type:addClickListener(function ()
        local click = self.list_type:getSelectedIndex() + 1;
        if (click ~= self.hallowType) then
            self.hallowType = click;
            self:refreshRightPanel();
        end
    end)

    self.btn_up:addClickListener(function ()
        if (not HallowSysModel:checkCanUp(self.hallowType, true)) then
            return
        end
        HallowSysModel:upHallow(self.hallowType, function()
            if (tolua.isnull(self.view)) then
                return
            end
            if (not self.lvUpEffect1) then
                local parent = self.view:getChildAutoType("loader_effect")
                local pos = cc.p(parent:getWidth()/2, parent:getHeight()/2)
                self.lvUpEffect1 = SpineUtil.createSpineObj(parent, pos, "ui_shengqitisheng_up", "spine/ui/hallow", "efx_shengqizhanshi", "efx_shengqizhanshi", false)
            else
                self.lvUpEffect1:setAnimation(0, "ui_shengqitisheng_up", false)
            end

            Scheduler.scheduleOnce(0.2, function()
                if (tolua.isnull(self.view)) then
                    return
                end
                if (not self.lvUpEffect2) then
                    local parent = self.view:getChildAutoType("loader_lvUpEffect")
                    local pos = cc.p(parent:getWidth()/2, parent:getHeight()/2)
                    self.lvUpEffect2 = SpineUtil.createSpineObj(parent, pos, "ui_dengjitisheng_up", "spine/ui/hallow", "efx_shengqizhanshi", "efx_shengqizhanshi", false)
                else
                    self.lvUpEffect2:setAnimation(0, "ui_dengjitisheng_up", false)
                end
            end)
        end);
    end)

    self.btn_upBase:addClickListener(function ()
        ViewManager.close("HallowUpView");
    end)
	
	self.btn_relicCopy:addClickListener(function ()
		ModuleUtil.openModule(ModuleId.RelicCopy.id)
    end)
    self:setBg("equipforgeBg.jpg");
end

function HallowUpView:Hallow_sysInfoUpdate()
    self:refreshListTypeInfo();
    self:refreshRightPanel();
end

function HallowUpView:refreshListTypeInfo()
    local map = HallowSysModel.hallowMap;
    local children = self.list_type:getChildren();
    for i = 1, #children do
        local lv = map[i] and map[i].level or 0;
        local child = children[i];
        child:getChildAutoType("txt_lv"):setText("Lv."..lv);
    end
end

function HallowUpView:refreshRightPanel()
    local hallowLv = HallowSysModel.hallowMap[self.hallowType].level;
    local conf = DynamicConfigData.t_HallowLevel[self.hallowType];
    local baseConf, nextConf = HallowSysModel:getBaseSeatConf();

    self.loader_icon:setIcon(string.format("UI/Hallow/hallow%s.png", self.hallowType));
    -- 等级
    local limitLv = baseConf.lvLimit;
    self.txt_hallowLv:setText(string.format(Desc.Hallow_hallowLvAndMax, hallowLv, limitLv));
    local ctrl = self.view:getController("c2");
    self.txt_curLv:setText("Lv."..hallowLv)
    self.txt_nextLv:setText("Lv."..(hallowLv + 1))
    if hallowLv >= limitLv then
        if (not nextConf or hallowLv >= #conf) then
            ctrl:setSelectedIndex(2); -- 达到最大值
        else
            ctrl:setSelectedIndex(1); -- 达到基座上限
        end
    else
        ctrl:setSelectedIndex(0); -- 可以提升
        if (conf[hallowLv + 1]) then
            -- self.costBar:setHasNumOnRight(true);
            self.costBar:setGreenColor("#3CFE45");
            self.costBar:setRedColor("#ff3b3b")
            self.costBar:setNormalColor(ColorUtil.textColor.white);
            self.costBar:setAllInfoChangeColor(true)
            self.costBar:setData(conf[hallowLv].lvUpCost, false);
        end
    end
    self.progress:setMax(limitLv);
    self.progress:setValue(hallowLv);

    -- 属性加成
    self.txt_hallowAdd:setText(string.format(Desc.Hallow_baseExtraAttr, baseConf.attrRate / 100))
    local curAttrs = conf[hallowLv].hallowAttr;
    local attrs = {};
    for _, val in ipairs(curAttrs) do
        attrs[val.attrId] = val;
        attrs[val.attrId].curExtra = math.ceil(val.value * baseConf.attrRate / 10000);
    end
    if (conf[hallowLv + 1]) then
        for _, val in ipairs(conf[hallowLv + 1].hallowAttr) do
            local d = attrs[val.attrId]
            if (not d) then
                attrs[val.attrId] = {
                    attrId = val.attrId,
                    value = 0,
                }
                d = attrs[val.attrId];
            end
            d.nextValue = val.value;
            d.nextExtra = math.ceil(val.value * baseConf.attrRate / 10000);
            attrs[val.attrId] = d;
        end
    end

    self.list_attr:setItemRenderer(function (idx, obj)
        local id = next(attrs, idx);
        local d = attrs[id];
        local ctrl = obj:getController("c1");
        ctrl:setSelectedIndex(d.nextValue and 1 or 0);
        obj:getChildAutoType("txt_attrName"):setText(Desc["card_attrName_"..id]);
        obj:getChildAutoType("icon"):setIcon(PathConfiger.getFightAttrIcon(id));

        local curVal = d.value
        if (d.curExtra) then
            curVal = curVal + d.curExtra --tring.format("%s [%s]", d.value, d.curExtra);
        end
        obj:getChildAutoType("txt_curVal"):setText(curVal);

        if (d.nextValue) then
            local val = d.nextValue
            if (d.nextExtra) then
                val = val + d.nextExtra --string.format("%s [%s]", d.nextValue, d.nextExtra);
            end
            obj:getChildAutoType("txt_nextVal"):setText(val);
        end
    end)
    self.list_attr:setNumItems(TableUtil.GetTableLen(attrs));


    -- 技能显示
    local allSkill = conf[#conf].skill;
    local curSkill = conf[hallowLv].skill;
    local skillConf = DynamicConfigData.t_skill;
    self.list_skill:setItemRenderer(function (idx, obj)
        if (not obj.skillCell) then
            obj.skillCell = BindManager.bindSkillCell(obj);
        end
        local skillId = allSkill[idx + 1];
        obj.skillCell:setData(skillId);
        local lockCtrl = obj:getController("lockCtrl");
        local nameCtrl = obj:getController("c1");
        nameCtrl:setSelectedIndex(1);
        local txt_name = obj:getChildAutoType("itemName");
        local id = 0;
        local lv = false
        if (curSkill[idx + 1] == 0) then -- 技能未解锁
            lockCtrl:setSelectedIndex(1);
            id = math.floor(skillId / 10) * 10 + 1;
            local c = skillConf[id]
            if (c) then
                obj.skillCell:showSkillName(0, c.unlock)
                -- txt_name:setText(c.unlock);
                txt_name:setColor(cc.c3b(0xCC, 0xCC, 0xCC))
            end
        else
            lockCtrl:setSelectedIndex(0);
            id = curSkill[idx + 1];
            lv = id - math.floor(id / 10) * 10;
            -- txt_name:setText("Lv."..lv);
            obj.skillCell:showSkillName(0, "Lv."..lv)
            txt_name:setColor(ColorUtil.textColor.white)
        end
        obj.skillCell.view:removeClickListener();
        obj.skillCell.view:addClickListener(function ()
            local info = {codeType = CodeType.HALLOW_SKILL, id = id, hallowType = self.hallowType, hallowLv = hallowLv}
            ViewManager.open("ItemTips", info)
        end)
    end)
    self.list_skill:setNumItems(#allSkill);
end

return HallowUpView