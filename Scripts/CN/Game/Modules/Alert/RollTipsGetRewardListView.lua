--可以支持多行的飘字
local RollTipsGetRewardListView, Super = class("RollTipsGetRewardListView", View)

function RollTipsGetRewardListView:ctor(args)
    --LuaLogE("RollTips ctor")
    self._packName = "UIPublic_Window"
    self._compName = "RollTipsListView"
    self._rootDepth = LayerDepth.Message
    self.args = args
    self.title = false
    self._isFullScreen = true
    self.list_msg = false
    self._rollMsgList = {}
    self._rollTipsTimer = false
    self._hideMsgTimer = false
    self._allShowMsg = {}
    self._showTime = 2000 --显示时间，超过这个时间就移除
    self._objPool = {}
    self._allItem = {}
    self._beginPosX = 0 --消息出来的点
    self._beginPosY = 0 --消息出来的点
    self.loader_msg = false
end

function RollTipsGetRewardListView:_initUI()
    self.loader_msg = self.view:getChildAutoType("loader_msg")
    self:addMsgList(self.args)
end

function RollTipsGetRewardListView:addMsgList(msgList)
    for _, v in ipairs(msgList) do
        self:addMsg(v)
    end
end

--获取一个消息对象
function RollTipsGetRewardListView:getMsgObj(parent)
    if #self._objPool > 0 then
        local obj = self._objPool[1]
        parent:addChild(obj)
        obj:release() --放到对象池的时候已经retain过的了，这里要release一次
        table.remove(self._objPool, 1)
        return obj
    else
        local obj = FGUIUtil.createObjectFromURL("UIPublic_Window", "com_rollTipsToastItem")
        parent:addChild(obj)
        return obj
    end
end

function RollTipsGetRewardListView:addMsgItem(args)
    local obj = self:getMsgObj(self.loader_msg)
    local c1= obj:getController("c1")
    if args.reward and args.reward.type == 2 then --货币
        c1:setSelectedIndex(1)
        local URL = ItemConfiger.getItemIconByCodeAndType(args.reward.type, args.reward.code)
        obj:getChildAutoType("img_onhook1"):setURL(URL)
        obj:getChildAutoType("txt_onhook1"):setText(args.reward.amount)
    else
        c1:setSelectedIndex(0)
        local color = "#EEEEEE"
        local itemConfig = ItemConfiger.getInfoByCode(args.reward.code, args.reward.type)
        color = ColorUtil.itemColorStr[itemConfig.color]
        local itemName = ColorUtil.formatColorString1(itemConfig.name, color)
        local str = string.format("获得%sx%s", itemName, args.reward.amount)
        obj:getChildAutoType("title"):setText(str)
    end
    obj:setPosition(self._beginPosX, self._beginPosY)
    TableUtil.insertTo(self._allItem, 1, obj)
    args.showTime = cc.millisecondNow()
    args.item = obj
    TableUtil.insertTo(self._allShowMsg, 1, args)
    for i, v in ipairs(self._allItem) do
        local targetY = -35 * i + self._beginPosY
        v:setPosition(self._beginPosX, targetY)
        if #self._allItem > 15 then
            self:recycleItem()
        end
    end
end

function RollTipsGetRewardListView:addMsg(msg)
    local arg = {reward = msg}
    table.insert(self._rollMsgList, arg)
    if (#self._rollMsgList > 10) then
        table.remove(self._rollMsgList, 1)
    end
    self:_showNextTips()
end

function RollTipsGetRewardListView:_showNextTips()
    if not self._hideMsgTimer then
        self._hideMsgTimer =
            Scheduler.schedule(
            function()
                self:_hidetips()
            end,
            0.1
        )
    end
    if #self._rollMsgList == 0 then
        if self._rollTipsTimer then
            Scheduler.unschedule(self._rollTipsTimer)
            self._rollTipsTimer = false
        end
    end

    if #self._rollMsgList > 0 then
        local args = self._rollMsgList[1]
        table.remove(self._rollMsgList, 1)
        self:addMsgItem(args)
    end
end

function RollTipsGetRewardListView:recycleItem()
    local item = self._allItem[#self._allItem]
    table.insert(self._objPool, item)
    item:retain()
    self.view:removeChild(item)
    self._allShowMsg[#self._allShowMsg] = nil
    self._allItem[#self._allItem] = nil
end

function RollTipsGetRewardListView:_hidetips()
    if #self._allShowMsg > 0 then
        local msg = self._allShowMsg[#self._allShowMsg]
        while (cc.millisecondNow() - msg.showTime) >= self._showTime do
            self:recycleItem()
            if #self._allShowMsg > 0 then
                msg = self._allShowMsg[#self._allShowMsg]
            else
                break
            end
        end
    else
        for _, v in pairs(self._objPool) do
            v:release()
        end
        self:closeView()
        Scheduler.unschedule(self._hideMsgTimer)
    end
end

return RollTipsGetRewardListView
