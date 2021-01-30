-- add by zn
-- 购买高阶竞技场门票

local HigherPvPTicketView = class("HigherPvPTicketView", Window)

function HigherPvPTicketView: ctor()
    self._packName = "HigherPvP";
    self._compName = "HigherPvPTicketView";
    self._rootDepth = LayerDepth.PopWindow;

end

function HigherPvPTicketView: _initUI()
    local root = self;
    local rootView = self.view;
        root.blackbg = rootView:getChildAutoType("$closeButton");
        root.itemCell = BindManager.bindItemCell(rootView:getChildAutoType("itemCell"));
        root.btn_cancel = rootView:getChildAutoType("cancel");
        root.btn_buy = BindManager.bindCostButton(rootView:getChildAutoType("buy"));

        local ticket = DynamicConfigData.t_HPvPConst[1].buyTicket[1];
        if (ticket) then
            self.itemCell:setData(ticket.code, ticket.amount, ticket.type);
        end

        local cost = HigherPvPModel:getBuyCost();
        if (cost) then
            self.btn_buy:setData(cost);
        end
end

function HigherPvPTicketView: _initEvent()
    self.blackbg:addClickListener(function ()
        self:closeView();
    end)
    self.btn_cancel:addClickListener(function ()
        self:closeView();
    end)
    self.btn_buy:addClickListener(function ()
        HigherPvPModel: buyTicket();
        self:closeView();
    end)
end

return HigherPvPTicketView