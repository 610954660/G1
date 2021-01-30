
-- added by wyz
-- 商城刷新物品提示
local ShopRefreshTipsView = class("ShopRefreshTipsView",Window)

function ShopRefreshTipsView:ctor()
    self._packName = "Shop"
    self._compName = "shopRefreshTipsView"
    self._rootDepth = LayerDepth.PopWindow

    self.btn_ok     = false
    self.btn_close  = false
    self.txt_title  = false
    self.btn_tips   = false

end

function ShopRefreshTipsView:_initUI()
    self.btn_ok = self.view:getChildAutoType("btn_ok")
    self.btn_close = self.view:getChildAutoType("btn_close")
    self.txt_title = self.view:getChildAutoType("txt_title")
    self.btn_tips = self.view:getChildAutoType("btn_tips")
end

function ShopRefreshTipsView:_initEvent()
    -- printTable(8848,">>>info>>>",self._args)
    local data = self._args.data
    self.btn_ok:addClickListener(function()
        data.onYes()
        ViewManager.close("ShopRefreshTipsView")  
    end)

    self.btn_close:addClickListener(function()
        ModelManager.ShopModel.refreshFlag = false
        ViewManager.close("ShopRefreshTipsView")  
    end)

    local dayStr = DateUtil.getOppostieDays()
    local index = FileCacheManager.getIntForKey("ShopView_isCheckTips" .. dayStr,0)
    local ctrl = self.btn_tips:getController("button")
    ctrl:setSelectedIndex(index)
    self.btn_tips:addClickListener(function()
        local selectIndex = ctrl:getSelectedIndex()
        print(8848,">>>selectIndex>>>",selectIndex)
        ModelManager.ShopModel:setCheckTips(selectIndex)
    end)

    self.txt_title:setText(data.text)
    local txt_tips = self.btn_tips:getChildAutoType("txt_tips")
    txt_tips:setText(Desc.shop_noTips)

end

function ShopRefreshTipsView:_exit()
    ModelManager.ShopModel.refreshFlag = false
end

return ShopRefreshTipsView