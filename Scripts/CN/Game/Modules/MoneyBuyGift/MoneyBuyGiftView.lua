
-- added by zn
-- 直购礼包

local MoneyBuyGiftView = class("MoneyBuyGiftView", Window);

local GiftType = {
    OnlyNewServer = 4,
    Day = 1,
    Week = 2,
    Month = 3,
}

local GiftTypeToTabLuaIndex = {
    [GiftType.OnlyNewServer] = 1, -- 新服专享礼包
    [GiftType.Day] = 2, -- 日礼包
    [GiftType.Week] = 3, -- 周礼包
    [GiftType.Month] = 4, -- 月礼包
}

local TabLuaIndexToGiftType = {
    [1] = GiftType.OnlyNewServer, --
    [2] = GiftType.Day,
    [3] = GiftType.Week,
    [4] = GiftType.Month,
}

function MoneyBuyGiftView:ctor()
    self._packName = "MoneyBuyGift";
    self._compName = "MoneyBuyGiftView";
    self.dataType = false; -- 当前浏览的礼包类型
    self.timer = false;
end

function MoneyBuyGiftView:_initUI()
    local root = self;
    root.txt_time = self.view:getChild("txt_time")
    root.list_tab = self.view:getChild("list_tab")
    root.list_page = self.view:getChild("list_page")
    root.btn_store = self.view:getChild("btn_store")

    self:refreshGiftTypeTabBar()
end

function MoneyBuyGiftView:refreshGiftTypeTabBar()
    -- 在有“新服专享”时隐藏“周礼包”页签，反之隐藏“新服专享”页签显示“周礼包”
    local haveOnlyNewServerGift =  MoneyBuyGiftModel:haveOnlyNewServerGift()
    local onlyNewServerGiftTab = self.list_tab:getChildAt(GiftTypeToTabLuaIndex[GiftType.OnlyNewServer]-1)
    onlyNewServerGiftTab:setVisible(haveOnlyNewServerGift)
    local weekGiftTab = self.list_tab:getChildAt(GiftTypeToTabLuaIndex[GiftType.Week]-1)
    weekGiftTab:setVisible(not haveOnlyNewServerGift)
end

function MoneyBuyGiftView:Activity_UpdateData(_, param)
    if param.type ~= GameDef.ActivityType.SaleGiftPack then
        return
    end

    self:refreshGiftTypeTabBar()
    local haveOnlyNewServerGift =  MoneyBuyGiftModel:haveOnlyNewServerGift()
    if haveOnlyNewServerGift then
        if self.dataType == GiftType.Week then
            self:switchCurrentGiftType(GiftType.OnlyNewServer)
        end
    else
        if self.dataType == GiftType.OnlyNewServer then
            self:switchCurrentGiftType(GiftType.Day)
        end
    end
end

function MoneyBuyGiftView:switchCurrentGiftType(giftType)
    if not self.dataType or self.dataType ~= giftType then
        self.list_tab:setSelectedIndex(GiftTypeToTabLuaIndex[giftType]-1)
        self.dataType = giftType
        self:MoneyBuy_upGoodsList()
        local ctrl = self.view:getController('c1')
        local storeCtrl = self.view:getController("c3")
        ctrl:setSelectedIndex(giftType == GiftType.Day and 0 or 1)
        storeCtrl:setSelectedIndex(giftType == GiftType.Day and 1 or 0)
        self:upTimeCount()
    end
end

function MoneyBuyGiftView:_initEvent()
    self.list_tab:addEventListener(FUIEventType.TouchBegin, function ()
        local idx = self.list_tab:getSelectedIndex();
        local giftType = TabLuaIndexToGiftType[idx+1]
        self:switchCurrentGiftType(giftType)
    end)

    local pageItems = self.list_tab:getChildren();
    for idx, item in ipairs(pageItems) do
        local red = item:getChild("img_red");
        if (idx == GiftTypeToTabLuaIndex[GiftType.Day]) then
            RedManager.register("V_ACTIVITY_"..MoneyBuyGiftModel.typeId.."_DAY", red);
        elseif (idx == GiftTypeToTabLuaIndex[GiftType.Week]) then
            RedManager.register("V_ACTIVITY_"..MoneyBuyGiftModel.typeId.."_WEEK", red);
        elseif (idx == GiftTypeToTabLuaIndex[GiftType.Month]) then
            RedManager.register("V_ACTIVITY_"..MoneyBuyGiftModel.typeId.."_MONTH", red);
        elseif (idx == GiftTypeToTabLuaIndex[GiftType.OnlyNewServer]) then
            RedManager.register("V_ACTIVITY_"..MoneyBuyGiftModel.typeId.."_ONLYNEWSERVER", red);
        end
    end

    self.btn_store:addClickListener(function ()
        -- ViewManager.open("ShopView", {shopType = 8})
        ModuleUtil.openModule( ModuleId.Shop.id , true,{shopType = 8} )
    end)

    -- 默认选中
    if MoneyBuyGiftModel:haveOnlyNewServerGift() then
        self:switchCurrentGiftType(GiftType.OnlyNewServer)
    else
        self:switchCurrentGiftType(GiftType.Day)
    end

    self:MoneyBuy_upGoodsList();
    self:upTimeCount();
end

function MoneyBuyGiftView:MoneyBuy_upGoodsList()
    local idArr = MoneyBuyGiftModel.idList[self.dataType];
	self.list_page:setVirtual();
    self.list_page:setItemRenderer(function (idx, obj)
        local data = MoneyBuyGiftModel.dataList[idArr[idx + 1]];
        -- 调整控制器
        local buyTypeCtrl = obj:getController("buyType"); -- 0 免费
        local btn_buy = obj:getChild('btn_buy'); -- 购买
        local c1 = obj:getController('c1') -- 1 售罄
        local status = MoneyBuyGiftModel:getStatusByGiftId(data.giftId)
        c1:setSelectedIndex(status);
        btn_buy:setTouchable(status == 0);
        local txt_fuli = obj:getChild('txt_fuli');

        if (data.price == 0) then
            buyTypeCtrl:setSelectedIndex(0);
            btn_buy:setTitle(Desc.moneyBuyGift_free);
            txt_fuli:setText(Desc["moneyBuyGift_fuli"..data.giftType]);
        else
            btn_buy:setTitle(string.format(Desc.moneyBuyGift_rmb, data.price));
            buyTypeCtrl:setSelectedIndex(1);
        end
        if (status == 1) then
            btn_buy:setTitle(Desc.moneyBuyGift_bought);
        end
        
        local txt_zhe = obj:getChild('txt_zhe');  -- 折扣数
        local txt_limit = obj:getChild('txt_limit'); -- 限购
        local itemCell = BindManager.bindItemCell(obj:getChild('itemCell')); -- 大图标
        local list_prop = obj:getChild('list_prop'); -- 剩余礼包道具图标

        txt_zhe:setText(data.discount);
        txt_limit:setText(string.format(Desc.moneyBuyGift_limit, MoneyBuyGiftModel:getRemainingBuyCountByGiftId(data.giftId)));
        itemCell:setIsBig(true);
        itemCell:setNoFrame(true);
        itemCell:setData(data.reward[1].code, data.reward[1].amount, data.reward[1].type);
        list_prop:setItemRenderer(function (idx, obj1)
            local d = data.reward[idx + 2];
            local item = BindManager.bindItemCell(obj1);
            item:setData(d.code, d.amount, d.type);
        end)
        list_prop:setNumItems(#data.reward - 1);  -- 第一个奖励图标单独显示
        list_prop:resizeToFit(#data.reward > 4 and 3 or (#data.reward - 1));

        btn_buy:removeClickListener(22);
        btn_buy:addClickListener(function ()
            local info = {
                id = data.giftId
            }
			if data.price > 0 then
				ModelManager.RechargeModel:directBuy(data.price,  GameDef.StatFuncType.SFT_SaleGiftPack, data.giftId, data.name,nil,data.showName1)
			else
				RPCReq.Activity_SaleGiftPack_Buy(info);
			end
        end, 22)
    end)
    self.list_page:setNumItems(#idArr);
end

-- 更新倒计时
function MoneyBuyGiftView:upTimeCount()
    if (self.timer) then
        TimeLib.clearCountDown(self.timer);
    end
    local endTime = 0;
    if (self.dataType == 2) then
        endTime = TimeLib.nextWeekBeginTime();
    elseif (self.dataType == 3) then
        endTime = TimeLib.nextMonthBeginTime();
    elseif self.dataType == 4 then -- 新服专享礼包
        -- 取活动开启时间的凌晨 + 7天
        local info = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.SaleGiftPack)
        endTime = TimeLib.GetDateStamp(info.realStartMs) + 7*24*60*60*1000
        endTime = math.floor(endTime/1000)
    end

    local now = ServerTimeModel:getServerTime()
    local times = endTime - now;
    -- LuaLogE("结束时间，", endTime , ServerTimeModel:getServerTime(), times);
    if (times > 0) then
        local function formatTime(_time)
            if (_time > 3600 * 24) then
                self.txt_time:setText(StringUtil.formatTime(_time, "d", Desc.common_TimeDesc))
            else
                self.txt_time:setText(StringUtil.formatTime(_time, "h", Desc.common_TimeDesc2))
            end
        end
        formatTime(times);
        -- 开倒计时
        self.timer = TimeLib.newCountDown(times, function (time)
            formatTime(time);
        end, function ()
            self.txt_time:setText(string.format(Desc.common_TimeDesc2, "00", "00", "00"))
        end, false, false, false);
    else
        self.txt_time:setText(string.format(Desc.common_TimeDesc2, "00", "00", "00"))
    end
end

function MoneyBuyGiftView:_exit()
    if (self.timer) then
        TimeLib.clearCountDown(self.timer);
    end
end

return MoneyBuyGiftView;