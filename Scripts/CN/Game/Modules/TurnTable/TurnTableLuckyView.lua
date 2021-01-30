-- add by zn
-- 转盘幸运名单

local TurnTableLuckyView = class("TurnTableLuckyView", Window)

function TurnTableLuckyView:ctor()
    self._packName = "TurnTable"
    self._compName = "TurnTableLuckyView"
    self._rootDepth = LayerDepth.PopWindow
end

function TurnTableLuckyView:_initUI()
    local root = self
    local rootView = self.view
        root.list = rootView:getChildAutoType("list");

    TurnTableModel:getLuckyList()
end

function TurnTableLuckyView:turnTable_luckyList(_, params)
    local list = params.records or {};
    local conf = DynamicConfigData.t_item;
    self.list:setItemRenderer(function (idx, obj)
        local d = list[idx + 1];
        local code = d.type == 2 and d.code + 2000 or d.code;
        local c = conf[code];
        local color = ColorUtil.itemColorStr[c.color];
        local name = string.format("[color=%s]%s[/color]", color, c.name);
        local str = string.format(Desc.turnTable_luckyStr, d.playerName, name, d.amount);
        obj:setTitle(str);
    end)
    self.list:setNumItems(#list);
end

return TurnTableLuckyView