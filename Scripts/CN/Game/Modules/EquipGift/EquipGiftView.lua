-- add by zn
-- 装备礼包活动

local EquipGiftView = class("EquipGiftView", Window)

function EquipGiftView:ctor()
    self._packName = "EquipGift"
    self._compName = "EquipGiftView"
    -- self._rootDepth = LayerDepth.PopWindow
    self.isEnd = false;
    self.txt_countTimer = false;
    self.timer = false;
end

function EquipGiftView:_initUI()
    local root = self
    local rootView = self.view
        root.txt_countTimer = rootView:getChildAutoType("txt_countTimer");
        root.list_reward = rootView:getChildAutoType("list_reward");
    rootView:getChildAutoType("banner"):setURL("UI/EquipGift/img_meizhou_banner.png")
    self:EquipGift_refreashData();
    self:updateCountTimer()
end

function EquipGiftView:_initEvent()

end

function EquipGiftView:EquipGift_refreashData()
    local data = EquipGiftModel:sortDataList();
    self.list_reward:setItemRenderer(function (idx, obj)
        local d = data[idx + 1];
        -- 礼包名
        obj:setTitle(d.name);
        -- 购买次数
        local count = EquipGiftModel.statusList[d.giftId] and d.buyTimes - EquipGiftModel.statusList[d.giftId].buyTimes or d.buyTimes;
        obj:getChildAutoType("txt_times"):setText(string.format(Desc.WeeklyGiftBag_times, count, d.buyTimes));
        obj:getController("takeCtrl"):setSelectedIndex(d.status);
        -- 价格
        local btn_buy = obj:getChildAutoType("btn_take")
        btn_buy:setTitle(string.format(Desc.DailyGiftBag_money, d.price));
        btn_buy:removeClickListener();
        btn_buy:addClickListener(function ()
            if (self.isEnd) then 
                RollTips.show(Desc.activity_txt13);
                return 
            end
            if d.price == 0 then
                RPCReq.Activity_WeekGift_Reward{id = d.giftId, activityType = GameDef.ActivityType.EquipGift};
            else
                ModelManager.RechargeModel:directBuy(d.price,  GameDef.StatFuncType.SFT_EquipGift, d.giftId, d.name,nil,d.showName1);
            end
        end)
        -- 打折
        local zheCtrl = obj:getController("discountCtrl");
        if (d.discount > 0) then
            zheCtrl:setSelectedIndex(0);
            obj:getChildAutoType("txt_zhe"):setText(string.format(Desc.DailyGiftBag_disCount, d.discount))
        else
            zheCtrl:setSelectedIndex(1);
        end
        -- 礼包内容
        local list = obj:getChildAutoType("list_reward");
        list:setItemRenderer(function (idx, item)
            local info = d.reward[idx + 1];
            if (not item.itemCell) then
                item.itemCell = BindManager.bindItemCell(item)
            end
            item.itemCell:setData(info.code, info.amount, info.type)
        end)
        list:setNumItems(#d.reward);
    end)
    self.list_reward:setNumItems(#data);
end

-- 倒计时
function EquipGiftView:updateCountTimer()
    if self.isEnd then return end
    local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.EquipGift)
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

return EquipGiftView