-- added by wyz
-- 扭蛋活动 扭蛋商店

local LanternShopView = class("LanternShopView",Window)

function LanternShopView:ctor()
    self._packName  = "TwistEggShop"
    self._compName  = "TwistEggShopView"

    self.txt_countTitle = false     -- 倒计时标题
    self.txt_countTimer = false     -- 活动倒计时
    self.banner         = false     -- 宣传图
    self.txt_integral   = false     -- 积分
    self.list_goods     = false     -- 商品列表
    self.costItem       = false     -- 拥有的积分数量


    self.timer          = false
    self.isEnd          = false
end

function LanternShopView:_initUI()
    self.txt_countTitle = self.view:getChildAutoType("txt_countTitle")
    self.txt_countTimer = self.view:getChildAutoType("txt_countTimer")
    self.banner         = self.view:getChildAutoType("banner")
    self.list_goods     = self.view:getChildAutoType("list_goods")
    self.txt_integral   = self.view:getChildAutoType("txt_integral")
    self.costItem       = self.view:getChildAutoType("costItem")
    
    self.banner:setURL("UI/TwistEgg/img_shop_banner.png")
end

function LanternShopView:_initEvent()
    self:LanternShopView_refreshPanal()
end

function LanternShopView:LanternShopView_refreshPanal()
    self:refreshPanal()
end

function LanternShopView:refreshPanal()
    -- self.txt_integral:setText("")
    self:setIntegral()
    self:setShopList()
    self:updateCountTimer()
end

-- 设置积分
function LanternShopView:setIntegral()
    local shopData = LanternShopModel:getShopData()
    local price = shopData[1].price[1]
    local costItem = BindManager.bindCostItem(self.costItem)
    costItem:setGreenColor("#ffffff")
    costItem:setRedColor("#ffffff")
    costItem:setData(price.type,price.code,price.amount,false,true)
end

-- 设置商品列表
function LanternShopView:setShopList()
    local shopData = LanternShopModel:getShopData()
    local flagInfo = LanternShopModel.flagInfo
    self.list_goods:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local data = shopData[index]
        local itemCell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))     -- 商品展示
        local btn_buy  = obj:getChildAutoType("btn_buy")    -- 购买按钮
        local costItem = BindManager.bindCostItem(obj:getChildAutoType("costItem"))     -- 积分
        local txt_limitTimes = obj:getChildAutoType("txt_limitTimes")   -- 限购次数
        local txt_soldout   = obj:getChildAutoType("txt_soldout")   -- 已售完
        local soldCtrl  = obj:getController("soldCtrl")     -- 0 没卖完 1 已售完 2 不显示限购
        local fdata = flagInfo[data.id]


        if fdata.buyTime == -1 then
            soldCtrl:setSelectedIndex(2)
        else
            soldCtrl:setSelectedIndex(fdata.buyTime == 0 and 1 or 0)
        end
        txt_soldout:setText(Desc.TwistEggShop_soldOut)

        local price = data.price[1]
        costItem:setData(price.type,price.code,price.amount,true)

        local reward = data.reward[1]
        itemCell:setData(reward.code,reward.amount,reward.type)

        local name = obj:getChildAutoType("txt_name")
        local item = DynamicConfigData.t_item[reward.code]
        name:setText(ItemConfiger.getItemNameByCode(reward.code))
        if item.color == 1 then
            name:setColor(cc.c3b(69,69,69))
        else
            name:setColor(ColorUtil.getItemColor(item.color))
        end

        txt_limitTimes:setText(string.format(Desc.shop_shengyu1,fdata.buyTime))

        obj:removeClickListener(11)
        obj:addClickListener(function()
            if self.isEnd then
                RollTips.show(Desc.CollectThing_end)
                return
            end
            if fdata.buyTime == 0 then
                RollTips.show(Desc.TwistEggShop_soldOut)
                return
            end
            ViewManager.open("LanternShopTipsView", {showData = data,buyTime=fdata.buyTime})
        end,11)

    end)
    self.list_goods:setData(shopData)
end

-- 倒计时
function LanternShopView:updateCountTimer()
    if self.isEnd then return end
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.LanternShop)
    if not actData then return end
    local actId   = actData.id
    local status, addtime = ModelManager.ActivityModel:getActStatusAndLastTime(actId)
    if not addtime then return end
    if status == 2 and addtime == -1 then
        self.isEnd = false
        self.txt_countTimer:setText(Desc.activity_txt5)
    else
        local lastTime = math.floor(addtime / 1000)
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

function LanternShopView:_exit()
    -- Scheduler.scheduleNextFrame(function() 
    --     ModelManager.EquipTargetModel.jump = false
    -- end)
    TimeLib.clearCountDown(self.timer)
end

return LanternShopView