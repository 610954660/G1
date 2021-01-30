-- add by zn
-- 圣器基座界面

local HallowEllipse = require "Game.Modules.HallowSys.HallowEllipse";
local HallowBaseSeatView = class("HallowBaseSeatView", Window)

function HallowBaseSeatView:ctor()
    self._packName = "HallowSys"
    self._compName = "HallowBaseSeatView"
    -- self._rootDepth = LayerDepth.PopWindow
    HallowSysModel:getSysInfo(true);
end

function HallowBaseSeatView:_initUI()
    local root = self
    local rootView = self.view
        local ellipse = rootView:getChildAutoType("ellipse")
        for i = 1, 5 do
            root["hallow"..i] = ellipse:getChildAutoType("hallow"..i);
        end
        root.txt_baseLv = rootView:getChildAutoType("txt_baseLv");
        root.txt_curAttr = rootView:getChildAutoType("txt_curAttr");
        root.txt_curMaxLv = rootView:getChildAutoType("txt_curMaxLv");
        root.txt_nextAttr = rootView:getChildAutoType("txt_nextAttr");
        root.txt_nextMaxLv = rootView:getChildAutoType("txt_nextMaxLv");
        root.costItem = BindManager.bindCostItem(rootView:getChildAutoType("costItem"));
        root.btn_upBase = rootView:getChildAutoType("btn_upBase");
        root.loader_base = ellipse:getChildAutoType("loader_base");
        root.txt_point = rootView:getChildAutoType("txt_point");
        root.txt_cost = rootView:getChildAutoType("txt_cost");
        HallowEllipse.new(ellipse);
end

function HallowBaseSeatView:_initEvent()
    for i = 1, 5 do
        local hallow = self["hallow"..i]
        hallow:addClickListener(function ()
            if (HallowSysModel.baseSeatLv == 0) then
                RollTips.show(Desc.Hallow_baseNotAcitve);
            else
                ViewManager.open("HallowUpView", {type = i});
            end
        end)
        hallow:setIcon(string.format("UI/Hallow/hallow%s.png", i));
        RedManager.register("V_HALLOW_"..i, hallow:getChildAutoType("img_red"));
    end

    self.btn_upBase:addClickListener(function ()
        HallowSysModel:upBaseSeat();
    end)
    self:setBg("HallowBg.jpg");
    self.loader_base:setIcon("UI/Hallow/base.png");
end

function HallowBaseSeatView:Hallow_sysInfoUpdate(_, data, showUpStar)
    -- printTable(2233, data);
    local sysInfo = HallowSysModel.sysInfo
    self.txt_baseLv:setText("Lv."..HallowSysModel.baseSeatLv);
    local curConf, nextConf = HallowSysModel:getBaseSeatConf();
    if (not curConf) then
        self.txt_curAttr:setText(string.format(Desc.Hallow_baseAttrAdd, 0));
        self.txt_curMaxLv:setText(string.format(Desc.Hallow_baseLvLimit, 0));
        self.btn_upBase:setTitle(Desc.Hallow_baseActive);
    else
        self.txt_curAttr:setText(string.format(Desc.Hallow_baseAttrAdd, curConf.attrRate / 100));
        self.txt_curMaxLv:setText(string.format(Desc.Hallow_baseLvLimit, curConf.lvLimit));
        self.btn_upBase:setTitle(Desc.Hallow_baseUpLv);
    end
    local ctrl = self.view:getController("c1");
    local has = sysInfo.newPoint or 0;
    local maxHistory = sysInfo.point or 0
    if (not nextConf) then
        ctrl:setSelectedIndex(1);
    else
        ctrl:setSelectedIndex(0);
        self.txt_nextAttr:setText(string.format(Desc.Hallow_baseAttrAdd, nextConf.attrRate / 100));
        self.txt_nextMaxLv:setText(string.format(Desc.Hallow_baseLvLimit, nextConf.lvLimit));
        self.costItem:setData(GameDef.GameResType.Item, 10006002, nextConf.lvUpCost)  

        -- 这里独立处理数量不走通用，10006002只是做前端显示，后端并不根据这个道具做消耗，用的另外的数据
        local str = ""
        if (maxHistory < nextConf.lvUpCost) then
            str = string.format(Desc.Hallow_pointStr.."[color=%s]%d/%d[/color]", ColorUtil.textColorStr.red, maxHistory, nextConf.lvUpCost);
        else
            str = string.format(Desc.Hallow_pointStr.."[color=#6aff60]%d/%d[/color]", maxHistory, nextConf.lvUpCost);
        end
        self.costItem.txt_num:setText(str); 
        self.txt_cost:setText(str);
    end

    self.txt_point:setText(string.format(Desc.Hallow_copydesc14, maxHistory, has))
    self:upHallowsInfo();
end

function HallowBaseSeatView:upHallowsInfo()
    local map = HallowSysModel.hallowMap;
    local spineMap = {
        "shengqi_jin",
        "shengqi_zi",
        "shengqi_lv",
        "shengqi_hong",
        "shengqi_lan",
    }
    for i = 1, 5 do
        local hallow = self["hallow"..i];
        local txt_lv = hallow:getChildAutoType("txt_level");
        local lv = map[i] and map[i].level or 0;
        txt_lv:setText("Lv."..lv);
        if (not hallow.spine) then
            local parent = hallow:getChildAutoType("bg")
            local pos = cc.p(parent:getWidth()/2, parent:getHeight()/2)
            hallow.spine = SpineUtil.createSpineObj(parent, pos, spineMap[i], "Spine/ui/Hallow", "shengqi_texiao", "shengqi_texiao", true)
        end
    end
end

return HallowBaseSeatView