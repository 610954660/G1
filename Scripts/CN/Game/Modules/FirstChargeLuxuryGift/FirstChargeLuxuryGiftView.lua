-- 首充豪礼礼包
local FirstChargeLuxuryGiftView = class("FirstChargeLuxuryGiftView", Window)

function FirstChargeLuxuryGiftView:ctor()
    self._packName = "FirstChargeLuxuryGift" -- 资源包
    self._compName = "FirstChargeLuxuryGiftView" -- 资源包中的组件
    self._rootDepth = LayerDepth.PopWindow
    self.btn_topUp = false
    self.list_page = false
    self.list_reward = false
    self.giftData = {}
    self.txt_topUpMoney = false
    self.clickIndex = 1
    self.lihuiDisplay = false
    self.lihuiDisplayObj = false
    self.activityEnable = false
    self.calltimer=false
end

function FirstChargeLuxuryGiftView:_initUI()
    self.list_page = self.view:getChildAutoType("list_page")
    self.txt_topUpMoney = self.view:getChildAutoType("txt_topUpMoney")
    self.btn_topUp = self.view:getChildAutoType("btn_topUp")
    self.list_reward = self.view:getChildAutoType("list_reward")
    self.lihuiDisplayObj = self.view:getChildAutoType("lihuiDisplay")

    self.txt_desc2 = self.view:getChildAutoType("txt_desc2")
    self.img_titleIcon = self.view:getChildAutoType("img_titleIcon")
    self.txt_heroName = self.view:getChildAutoType("txt_heroName")
    self.txt_countdown = self.view:getChildAutoType("txt_countdown")
    self:showGiftView()
end

function FirstChargeLuxuryGiftView:showGiftView()
    self.giftData = FirstChargeLuxuryGiftModel.currentGift
    if not self.giftData then
        return
    end
    self.lihuiDisplay = BindManager.bindLihuiDisplay(self.lihuiDisplayObj)
    self:setListCell()
end

function FirstChargeLuxuryGiftView:_initEvent()
    -- 右侧累计充值按钮
    self.btn_topUp:addClickListener(
        function()
            if self.activityEnable then
                RollTips.show(Desc.activity_txt13)
                return
            end
            ModuleUtil.openModule(ModuleId.DailyGiftBag, true)
        end
    )
end

function FirstChargeLuxuryGiftView:isShowCountDowm(rmb)
    local isOpen = false
    -- local dataCfg = self:getBtnRMB()
    if self.giftData.count and self.giftData.count >= rmb then
        isOpen = true
    end
    return isOpen
end

function FirstChargeLuxuryGiftView:showTextRMB(rmb)
    self.giftData.count = self.giftData.count and self.giftData.count or 0
    if self:isShowCountDowm(rmb) == true then
        self.txt_countdown:setVisible(false)
    else
        self.txt_countdown:setVisible(true)
        self:showCountTime()
    end
    self.txt_topUpMoney:setText(string.format(Desc.firstCharge_topUpCurrent, self.giftData.count))
end

function FirstChargeLuxuryGiftView:showCountTime()
    local curSerevrTime = ServerTimeModel:getServerTime()
    local endTime = self.giftData.endTimeMs and self.giftData.endTimeMs or 0
    local addtime = (endTime / 1000) - curSerevrTime
    local lastTime = addtime
    if lastTime <= 0 then
        self.activityEnable = true
        self.txt_countdown:setText(Desc.activity_txt21)
    else
        if not tolua.isnull(self.txt_countdown) then
            self.txt_countdown:setText(TimeLib.GetTimeFormatDay(lastTime, 2))
        end
        local function onCountDown(time)
            if not tolua.isnull(self.txt_countdown) then
                self.txt_countdown:setText(TimeLib.GetTimeFormatDay(time, 2))
            end
        end
        local function onEnd(...)
            Dispatcher.dispatchEvent(EventType.FirstChargeGift_upGiftclose)
            self.activityEnable = true
            if not tolua.isnull(self.txt_countdown) then
                self.txt_countdown:setText(Desc.activity_txt21)
            end
        end
        if self.calltimer then
            TimeLib.clearCountDown(self.calltimer)
        end
        self.calltimer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
    end
end

function FirstChargeLuxuryGiftView:setListCell()
    local itemData = DynamicConfigData.t_ChargeGift -- 礼包数据
    local dataCfg = self:getBtnRMB()
    self.list_page:setSelectedIndex(self.clickIndex - 1)
    self.list_page:setItemRenderer(
        function(idx, obj)
            local img_red = obj:getChildAutoType("img_red")
            local title = obj:getChildAutoType("title")
            title:setText(string.format(Desc.firstChargeGift_str, dataCfg[idx + 1]))
            RedManager.register("V_ACTIVITY_" .. GameDef.ActivityType.SecordCharge .. (idx + 1), img_red)
            obj:removeClickListener(222)
            obj:addClickListener(
                function()
                    self:showBgIcon(itemData, dataCfg, idx)
                    self.clickIndex = idx + 1
                    self.list_reward:setNumItems(#itemData[dataCfg[self.clickIndex]])
                    self:showTextRMB(dataCfg[idx + 1])
                end,
                222
            )
            if idx == self.clickIndex - 1 then
                self:showBgIcon(itemData, dataCfg, idx)
                self:showRewardList()
                self:showTextRMB(dataCfg[idx + 1])
            end
        end
    )
    self.list_page:setNumItems(#dataCfg)
end

function FirstChargeLuxuryGiftView:showRewardList()
    local itemData = DynamicConfigData.t_ChargeGift -- 礼包数据
    local dataCfg = self:getBtnRMB()
    self.list_reward:setItemRenderer(
        function(idx, obj)
            local index = self.clickIndex - 1
            local Rmb = dataCfg[index + 1]
            local data = itemData[Rmb][idx + 1]
            local txt_day = obj:getChildAutoType("txt_day")
            local list_reward = obj:getChildAutoType("list_reward")
            local btn_rewardRed = obj:getChildAutoType("img_red")
            local txt_take = obj:getChildAutoType("txt_take")
            RedManager.register(
                "V_ACTIVITY_" .. GameDef.ActivityType.SecordCharge .. (index + 1) .. (idx + 1),
                btn_rewardRed
            )
            txt_day:setText(string.format(Desc.firstChargeGift_str1, data.dayIndex))
            local takeCtrl = obj:getController("takeCtrl")
            local state = 1
            takeCtrl:setSelectedIndex(2)
            if self.giftData.accTypeMap and self.giftData.accTypeMap[Rmb] ~= nil then
                local recvMark = self.giftData.accTypeMap[Rmb].recvMark
                local flag = bit.band(recvMark, bit.lshift(1, idx)) > 0
                state = flag and 3 or 1
                if flag then
                    takeCtrl:setSelectedIndex(1)
                    txt_take:setText(Desc.CohesionReward_str25)
                elseif data.dayIndex <= self.giftData.accTypeMap[Rmb].dayIndex then
                    takeCtrl:setSelectedIndex(0)
                end
            end
            local btn_clickArea = obj:getChildAutoType("btn_clickArea")
            btn_clickArea:removeClickListener(222)
            btn_clickArea:addClickListener(
                function()
                    local req = {
                        accType = data.accType,
                        dayIndex = data.dayIndex
                    }
                    RPCReq.Activity_SecordCharge_RecvReward(req)
                end,
                222
            )
            local reward = data.reward
            list_reward:setItemRenderer(
                function(idx2, obj2)
                    local dd = reward[idx2 + 1]
                    local itemCell = BindManager.bindItemCell(obj2)
                    itemCell:setData(dd.code, dd.amount, dd.type)
                    itemCell:setIsHook(state == 3)
                end
            )
            list_reward:setNumItems(#reward)
        end
    )
    self.list_reward:setNumItems(#itemData[dataCfg[self.clickIndex]])
end

function FirstChargeLuxuryGiftView:getBtnRMB()
    local itemData = DynamicConfigData.t_ChargeGift -- 礼包数据
    local dataCfg = {}
    for key, value in pairs(itemData) do
        table.insert(dataCfg, key)
    end
    table.sort(
        dataCfg,
        function(a, b)
            return a < b
        end
    )
    return dataCfg
end

function FirstChargeLuxuryGiftView:showBgIcon(itemData, dataCfg, idx)
    local itemMode = itemData[dataCfg[idx + 1]][1]
    local heroId = itemMode.modelShow
    self.lihuiDisplay:setData(heroId, nil, true)
    self.txt_desc2:setText(itemMode.dec2)
    self.img_titleIcon:setURL(string.format("UI/FirstChargeGift/%s", itemMode.dec1))
    local heroConfig = DynamicConfigData.t_hero[heroId]
    self.txt_heroName:setText(heroConfig.heroName)
end

function FirstChargeLuxuryGiftView:FirstChargeGift_upGiftData()
    self:showGiftView()
end

return FirstChargeLuxuryGiftView
