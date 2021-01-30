-- 装备升星活动
-- add by zn

local EquipUpStarView = class("EquipUpStarView", Window);

function EquipUpStarView:ctor()
    self._packName = "EquipUpStar";
    self._compName = "EquipUpStarView";
    self.isEnd = false;
    self.txt_countTimer = false;
    self.timer = false;
    EquipUpStarModel.selected1 = false;
    EquipUpStarModel.selected2 = false;

    self.showMoneyType = {
        {type = GameDef.GameResType.Item, code = 10000071},
		{type = GameDef.GameResType.Money, code = GameDef.MoneyType.Gold},
		{type = GameDef.GameResType.Money, code = GameDef.MoneyType.Diamond},
	} 
end

function EquipUpStarView:_refresh()
    self:EquipUpStarView_upPanel(nil, 1)
    self:EquipUpStarView_upPanel(nil, 2)
end

function EquipUpStarView:_initUI()
    local root = self;
    local rootView = self.view;
        for i = 1, 2 do
            local panel = rootView:getChildAutoType("panel"..i);
            root["panel"..i] = panel;
            panel.itemCell1 = BindManager.bindItemCell(panel:getChildAutoType("itemCell1"));
            panel.itemCell2 = BindManager.bindItemCell(panel:getChildAutoType("itemCell2"));
            panel.itemCell1:setIsMid(true);
            panel.itemCell2:setIsMid(true);
            panel.list_item = panel:getChildAutoType("list_item");
            panel.btn_up = panel:getChildAutoType("btn_up");
            panel.btn_add = panel:getChildAutoType("btn_add");
            panel.list_attr = panel:getChildAutoType("list_attr");
        end
        root.txt_countTimer = rootView:getChildAutoType("txt_time");
    
    self.view:setIcon("UI/EquipUpStar/beidi_lihui.png")
end

function EquipUpStarView:_initEvent()
    for i = 1, 2 do
        local panel = self["panel"..i];
        -- panel.btn_up:addClickListener(function ()
        --     print(2233, "装备升级-----");
        -- end)
        panel.btn_add:addClickListener(function ()
            ViewManager.open("EquipChooseView", {type = i});
        end)
    end
    self:updateCountTimer()
    self:EquipUpStarView_upPanel(nil, 1)
    self:EquipUpStarView_upPanel(nil, 2)

    self.btn_help:removeClickListener();
    self.btn_help:addClickListener(function()
        local info={}
        info['title']=Desc["help_StrTitle"..ModuleId.EquipUpStar.id]
        info['desc']=Desc["help_StrDesc"..ModuleId.EquipUpStar.id]
        ViewManager.open("GetPublicHelpView",info) 
    end)
end

function EquipUpStarView:EquipUpStarView_upPanel(_, panelIdx)
    local panel = self["panel"..panelIdx];
    local eqInfo = EquipUpStarModel["selected"..panelIdx];
    local ctrl = panel:getController("c1");
    local upConf = DynamicConfigData.t_EquipExchangeActivity;
    local conf = false;
    panel.btn_up:removeClickListener();

    if (not eqInfo) then
        ctrl:setSelectedIndex(0);
        local key = next(upConf);
        conf = upConf[key] or false;
    else
        ctrl:setSelectedIndex(1);
        panel.itemCell1:setData(eqInfo.code, 0, CodeType.ITEM);
        conf = upConf[eqInfo.code] or false;
        if (conf) then
            panel.itemCell2:setData(conf.gainId, 0, CodeType.ITEM);
            panel.btn_up:addClickListener(function ()
                EquipUpStarModel:upStar(panelIdx, eqInfo);
            end)
            local oldAttr = self:rebuildEquipAttr(eqInfo.code)
            local newAttr = self:rebuildEquipAttr(conf.gainId)
            local k = next(oldAttr);
            panel.list_attr:setItemRenderer(function(idx, obj)
                local oldA = oldAttr[k]
                local newA = newAttr[k]
                obj:getChildAutoType("txt_name"):setText(Desc["card_attrName_"..k])
                obj:getChildAutoType("txt_val"):setText(oldA)
                obj:getChildAutoType("txt_valadd"):setText(newA)
                k = next(oldAttr, k)
            end)
            panel.list_attr:setNumItems(TableUtil.GetTableLen(oldAttr))
        end
    end
    -- 消耗
    if (conf) then
        panel.list_item:setVisible(true);
        local cost = conf.costItem;
        panel.list_item:setItemRenderer(function (idx, obj)
            local d = cost[idx + 1];
            if (not obj.itemCell) then
                obj.itemCell = BindManager.bindItemCell(obj);
                -- obj.itemCell:setIsMid(true);
            end
            local amount = eqInfo and d.amount or 0
            obj.itemCell:setData(d.code, amount, d.type);
            if (amount > 0 and not PlayerModel:checkCostEnough(d, false)) then
                obj.itemCell.txtNum:setColor(cc.c3b(0xff, 0x3b, 0x3b));
            else
                obj.itemCell.txtNum:setColor(ColorUtil.textColor.white);
            end
        end)
        panel.list_item:setNumItems(#cost);
    else
        panel.list_item:setNumItems(0);
    end
end

-- 倒计时
function EquipUpStarView:updateCountTimer()
    if self.isEnd then return end
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.EquipUpStar)
    if not actData then return end
    local actId   = actData.id
    local status, addtime = ModelManager.ActivityModel:getActStatusAndLastTime(actId)
    if not addtime then return end

    if status == 2 and addtime == -1 then
        self.isEnd = false
        self.txt_countTimer:setText(Desc.activity_txt5)
    else
        local lastTime = addtime / 1000
        if lastTime == -1 then
            self.txt_countTimer:setText(Desc.activity_txt5)
        else
            if not tolua.isnull(self.txt_countTimer) then
                self.txt_countTimer:setText(TimeLib.GetTimeFormatDay(lastTime, 2))
            end
            local function onCountDown(time)
                if not tolua.isnull(self.txt_countTimer) then
                    self.isEnd = false
                    self.txt_countTimer:setText(TimeLib.GetTimeFormatDay(time, 2))
                end
            end
            local function onEnd(...)
                self.isEnd = true
                if not tolua.isnull(self.txt_countTimer) then
                --  self.activityEnable = true
                self.txt_countTimer:setText(Desc.activity_txt18)
                end
            end
            if self.timer then
                TimeLib.clearCountDown(self.timer)
            end
            self.timer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
        end
    end
end

function EquipUpStarView:rebuildEquipAttr(equipId)
    local conf = DynamicConfigData.t_equipEquipment[equipId]
    if (not conf) then
        return {}
    end
    local map = {
        ["hp"] = 1,
        ["attack"] = 2,
        ["defense"] = 3,
        ["magic"] = 4,
        ["magicDefense"] = 5,
        ["speed"] = 6,
    }
    local attrList = {}
    for key, v in pairs(map) do
        -- table.insert(attrList, {
        --     id = v,
        --     value = conf[key]
        -- })
        if (conf[key] ~= 0) then
            attrList[v] = conf[key]
        end
    end
    return attrList
end

return EquipUpStarView