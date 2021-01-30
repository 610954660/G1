-- add by zn
-- 饰品兑换界面
local JewelryExchangeTipView = class("JewelryExchangeTipView", Window);

function JewelryExchangeTipView: ctor()
    self._packName = "Jewelry";
    self._compName = "JewelryExchangeTipView";
    self._rootDepth = LayerDepth.PopWindow;
end

function JewelryExchangeTipView: _initUI()
    self.itemCell = BindManager.bindItemCell(self.view:getChildAutoType("itemCell"));
    self.btn_get = self.view:getChildAutoType("btn_get");
    self.itemCell:setIsBig(true);
    self.itemCell:setAmountVisible(false);
    self.itemCell:setData(60000004, 0, GameDef.GameResType.Item);
    self.view:getChildAutoType("title"):setText(Desc.Jewelry_Exchage)
    local canExchange = JewelryModel.proficiency >= 1000;
    self.btn_get:setGrayed(not canExchange);
    self.btn_get:setTouchable(canExchange);
    self.btn_get:addClickListener(function ()
        JewelryModel:exchangeByProficiency();
        self:closeView();
    end)
end

return JewelryExchangeTipView;