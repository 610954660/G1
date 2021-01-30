-- added by wyz
-- 扭蛋活动 限时商城

local PopularVoteShopView = class("PopularVoteShopView",Window)

function PopularVoteShopView:ctor()
    self._packName = "TwistEggLimitGift"
    self._compName = "TwistEggLimitGiftView"

    self.txt_countTitle = false     -- 倒计时标题
    self.txt_countTimer = false     -- 活动倒计时
    self.banner         = false     -- 宣传图
    self.list_gift      = false     -- 礼包列表
    self.timer          = false     -- 活动定时器
    self.isEnd          = false 
end

function PopularVoteShopView:_initUI()
    self.txt_countTitle = self.view:getChildAutoType("txt_countTitle")
    self.txt_countTimer = self.view:getChildAutoType("txt_countTimer")
    self.banner         = self.view:getChildAutoType("banner")
    self.list_gift      = self.view:getChildAutoType("list_gift")
    
    self.banner:setURL("UI/activity/limitShopTitleBanner2.png")
    self:refreshPanal()
end

function PopularVoteShopView:PopularVoteShop_refreshView()
    self:refreshPanal()
end

function PopularVoteShopView:refreshPanal()
    self:setGiftList()
    self:updateCountTimer()
end

-- 设置礼包列表
function PopularVoteShopView:setGiftList()
    local giftData = ModelManager.PopularVoteModel:getShopData()
    self.list_gift:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local data = giftData[index]
        local txt_name      = obj:getChildAutoType("txt_name")  -- 礼包名
        local list_reward   = obj:getChildAutoType("list_reward") -- 奖励列表
        local btn_free      = obj:getChildAutoType("btn_free")  -- 免费按钮
        local btn_buy       = obj:getChildAutoType("btn_buy")   -- 购买按钮
        local btn_soldout   = obj:getChildAutoType("btn_soldout")   -- 已售完按钮
        local txt_discount  = obj:getChildAutoType("txt_discount")  -- 折扣文本
        local txt_limitTimes= obj:getChildAutoType("txt_limitTimes")    -- 限购次数
        local buyCtrl       = obj:getController("buyCtrl")  -- 0 免费 1 花钱购买 2 已售完
        local discountCtrl  = obj:getController("discountCtrl")     -- 0不打折 1打折
        
        discountCtrl:setSelectedIndex((data.discount==0) and 0 or 1)

        if data.price == 0 and data.buyType==1 then
            local img_red = btn_free:getChildAutoType("img_red")
            RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.HeroVoteShop .. data.id, img_red)
            buyCtrl:setSelectedIndex((data.buyTime == 0) and 2 or 0)
        elseif data.price==0 and data.buyType==2 then
            buyCtrl:setSelectedIndex((data.buyTime == 0) and 2 or 1)
        else
            buyCtrl:setSelectedIndex((data.buyTime == 0) and 2 or 1)
        end

        txt_name:setText(data.name)
        local rewardData = data.reward
        list_reward:setItemRenderer(function(idx2,obj2)
            local reward = rewardData[idx2+1]
            local itemCell = BindManager.bindItemCell(obj2)
            itemCell:setData(reward.code,reward.amount,reward.type)
        end)
        list_reward:setData(rewardData)

        txt_discount:setText(string.format(Desc.TwistEggLimitGift_discount,data.discount))
        if data.reType == 1 then 
            txt_limitTimes:setText(string.format(Desc.TwistEggLimitGift_limitTimes3,data.buyTime))
        else
            txt_limitTimes:setText(string.format(Desc.TwistEggLimitGift_limitTimes2,data.buyTime))
        end

        if data.price == 0 and data.buyType == 2 then --取cost显示
            btn_buy:getController("costType"):setSelectedIndex(1)
            local costItemObj = btn_buy:getChildAutoType("costItem")
            local  costItem = BindManager.bindCostItem(costItemObj)
            printTable(1,data.cost[1])
            -- costItem:setUseMoneyItem(true)
            costItem:setGreenColor("#654800")
            costItem:setRedColor("#f43636")
            costItem:setData(data.cost[1].type, data.cost[1].code, data.cost[1].amount, true, false, false)
        else
            btn_buy:getController("costType"):setSelectedIndex(0)
            btn_buy:getChildAutoType("title"):setText(string.format(Desc.TwistEggLimitGift_price,data.price))
        end

        btn_free:removeClickListener(11)
        btn_free:addClickListener(function()
            if self.isEnd then
                RollTips.show(Desc.CollectThing_end)
                return
            end
            local params = {}
            params.activityType = GameDef.ActivityType.HeroVoteShop
            params.id = data.id
            printTable(6,"params",params)
            RPCReq.Activity_HeroSummonShop_Buy(params)
        end,11)

        btn_buy:removeClickListener(11)
        btn_buy:addClickListener(function()
            if self.isEnd then
                RollTips.show(Desc.CollectThing_end)
                return
            end
            if data.price == 0 and data.buyType == 2 then --取cost显示
                if not PlayerModel:isCostEnough(data.cost, true) then
                    return
                end
                local params = {}
                params.activityType = GameDef.ActivityType.HeroVoteShop
                params.id = data.id
                printTable(6,"params",params)
                RPCReq.Activity_HeroSummonShop_Buy(params)
            else
                ModelManager.RechargeModel:directBuy(data.price, GameDef.StatFuncType.SFT_HeroVoteShop, data.id, data.name, nil, data.showName1)
            end
        end,11)
    end)
    self.list_gift:setData(giftData)
end

-- 倒计时
function PopularVoteShopView:updateCountTimer()
    if self.isEnd then return end
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.HeroVoteShop)
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


function PopularVoteShopView:_exit()
    -- Scheduler.scheduleNextFrame(function() 
    --     ModelManager.EquipTargetModel.jump = false
    -- end)
    TimeLib.clearCountDown(self.timer)
end


return PopularVoteShopView