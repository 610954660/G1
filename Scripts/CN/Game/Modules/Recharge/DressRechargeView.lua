-- add by zn
-- 时装纽扣充值

local DressRechargeView = class("DressRechargeView", Window)

function DressRechargeView:ctor()
    self._packName = "Recharge"
    self._compName = "DressRechargeView"
    -- self._rootDepth = LayerDepth.PopWindow
end

function DressRechargeView:_initUI()
    local root = self
    local rootView = self.view

    local moduleId = 1;
    local conf = DynamicConfigData.t_FashionChargeShop[moduleId];
    local list = rootView:getChildAutoType("list_item");
    list:setItemRenderer(function(idx, obj)
        local c = conf[idx + 1];
        local limitCtrl = obj:getController("limit");
        local worthCtrl = obj:getController("worth");
        local txt_limit = obj:getChildAutoType("txt_limit");
        local txt_value = obj:getChildAutoType("txt_value");
        obj:setIcon(string.format("Icon/recharge/Fashion%s.png", c.showIcon));
        obj:setTitle(c.name);
        txt_value:setText("￥"..c.price);
        -- if (c.times and c.times > 0) then
        --     limitCtrl:setSelectedIndex(1);
        --     txt_limit:setText(string.format(Desc.Recharge_str1, c.times))
        -- else
        --     limitCtrl:setSelectedIndex(0);
        -- end
        worthCtrl:setSelectedIndex((c.desc and c.desc ~= "") and 1 or 0);
        local item = c.item[1];

        local btn = obj:getChildAutoType("btn_recharge");
        btn:removeClickListener();
        btn:addClickListener(function()
            local info = {}
			info.text = string.format(Desc.Recharge_str2,DescAuto[181], c.price, item.amount) -- [181]="￥"
			info.type = "yes_no"
			info.align = "center"
			info.mask = true
			info.onYes = function()
                ModelManager.RechargeModel:directBuy(c.price,  GameDef.StatFuncType.SFT_FashionCharge, c.id, c.name, nil, c.name)
                -- RollTips.show("功能开发中~");
			end
			Alert.show(info)
        end);
    end)
    list:setNumItems(#conf);
end

function DressRechargeView:_initEvent()

end

return DressRechargeView