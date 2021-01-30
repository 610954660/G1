--Create By GQY
--TIME:2020/8/21 11:45

local NewServerGiftView,Super = class("NewServerGiftView", Window)

function NewServerGiftView:ctor()
    self._packName = "NewServerGift"
    self._compName = "NewServerGiftView"
    self._rootDepth = LayerDepth.Window
    self.data = false
    self.timer = false
end

function NewServerGiftView:_initEvent( )

end

function NewServerGiftView:_initVM( )

end

function NewServerGiftView:_initUI( )
    self.giftList = self.view:getChildAutoType("giftList")
    self.txtTime = self.view:getChildAutoType("txtTime")
    self.giftList:setItemRenderer(function(index,obj)
        self:giftListRenderer(index,obj)
    end)

    self:update_NewServerGiftList()
end

function NewServerGiftView:_exit()
    self.data = false
    if self.timer then
        TimeLib.clearCountDown(self.timer)
        self.timer = false
    end
end

function NewServerGiftView:update_NewServerGiftList()

    local dayStr = DateUtil.getOppostieDays()
	FileCacheManager.setBoolForKey("NewServerGiftView_isShow"..dayStr, true)
    ModelManager.NewServerGiftModel:checkRed()
    
    print(999,"更新")
    self.data = ModelManager.NewServerGiftModel:getAllGift()
    self.giftList:setNumItems(#self.data)

    local info = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.NewServerGift)
    if not info then return end
    local time = (info.realEndMs - ModelManager.ServerTimeModel:getServerTimeMS())/1000
    self.txtTime:setText(TimeLib.GetTimeFormatDay1(self.roundTime))

    if self.timer then
        TimeLib.clearCountDown(self.timer)
    end

    self.txtTime:setText(TimeLib.GetTimeFormatDay1(time))
    self.timer = TimeLib.newCountDown(time,function(time)
        self:onCountDown(time)
    end, nil, false, false,false)
end

function NewServerGiftView:onCountDown(time)
    self.txtTime:setText(TimeLib.GetTimeFormatDay1(time))
end

function NewServerGiftView:giftListRenderer(index,obj)
    local giftID = self.data[index + 1].giftId
    local giftTime = ModelManager.NewServerGiftModel:getBuyTime(giftID)
    local state = ModelManager.NewServerGiftModel:getGiftState(giftID)
    local config = DynamicConfigData.t_SeverGift[giftID]

    local btnGet = obj:getChildAutoType("btnGet")
    local txtTimes = obj:getChildAutoType("txtTimes")
    local txtDesc = obj:getChildAutoType("txtDesc")
    local txtRate = obj:getChildAutoType("txtRate")
    local itemList = obj:getChildAutoType("itemList")
    local img_red = btnGet:getChildAutoType("img_red")
    RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.NewServerGift ..self.data[index + 1].price, img_red)

    txtTimes:setText(string.format(Desc.NewServerGift_buyTimes,config.buyTimes - giftTime,config.buyTimes))
    txtDesc:setText(config.name)
    txtRate:setText(string.format(Desc.NewServerGift_discount,config.discount))
    itemList:setItemRenderer(function(index2,obj2)
        self:itemListRenderer(index + 1,index2,obj2)
    end,1)

    btnGet:addClickListener(function()
        self:onBtnGetClick(index + 1)
    end,1)

    itemList:setNumItems(#config.reward)
    obj:getController("c1"):setSelectedIndex(state)
    obj:getController("showRate"):setSelectedIndex(config.discount ~= 0 and 1 or 0)
    if state == 1 then
        btnGet:setTitle(string.format(Desc.NewServerGift_price,config.price))
    end

end

function NewServerGiftView:itemListRenderer(giftIndex,index,obj)
    local giftID = self.data[giftIndex].giftId
    local itemCell = BindManager.bindItemCell(obj)
    local config = DynamicConfigData.t_SeverGift[giftID].reward[index + 1]

    itemCell:setData(config.code,config.amount,config.type)
	
	local showDouble = DynamicConfigData.t_SeverGift[giftID].doubleShow and config.type == CodeType.MONEY and config.code == GameDef.MoneyType.Diamond
	itemCell:setShowDouble(showDouble)
end

function NewServerGiftView:onBtnGetClick(giftIndex)
    local giftID = self.data[giftIndex].giftId
    local config = DynamicConfigData.t_SeverGift[giftID]
    if config.price == 0 then
        Dispatcher.dispatchEvent(EventType.Activity_NewServerGift_GetReward,giftID)
    else
        ModelManager.RechargeModel:directBuy(config.price, GameDef.StatFuncType.SFT_BuyNewServerGift,giftID, config.name,nil, config.showName1)
    end
end

return NewServerGiftView