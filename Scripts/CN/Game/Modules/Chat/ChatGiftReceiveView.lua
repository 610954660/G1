local ChatGiftReceiveView, Super = class("ChatGiftReceiveView", Window)
function ChatGiftReceiveView:ctor()
    self._packName = "Chat"
    self._compName = "ChatGiftReceiveView"
    self._rootDepth = LayerDepth.PopWindow
end

function ChatGiftReceiveView:_initEvent()
    self.btn_zengli:addClickListener(
        function(context)
            ModuleUtil.openModule(ModuleId.ChatGift.id, true)
            self:closeView()
        end,
        100
    )
end

function ChatGiftReceiveView:_initUI()
    self.txt_libaotime = self.view:getChildAutoType("txt_libaotime")
    self.txt_daojutime = self.view:getChildAutoType("txt_daojutime")
    self.list_reward = self.view:getChildAutoType("list_reward")
    self.btn_zengli = self.view:getChildAutoType("btn_zengli")
    local configInfo1 = DynamicConfigData.t_DonateGiftSetting[1]
    local configInfo2 = DynamicConfigData.t_DonateGiftSetting[2]
    local servserTime1 = ChatModel:getRecvGiftTimes(1)
    local servserTime2 = ChatModel:getRecvGiftTimes(2)
    self.txt_libaotime:setText(string.format("%s/%s", servserTime1, configInfo1.recieveLimit))
    self.txt_daojutime:setText(string.format("%s/%s", servserTime2, configInfo2.recieveLimit))
    self:showList()
end

function ChatGiftReceiveView:showList()
    local temp = {}
    local map = ChatModel.reciveGiftList or {}
    for key, value in pairs(map) do
        temp[#temp + 1] = value
    end
    TableUtil.sortByMap(temp, {{key = "status", asc = false}, {key = "addMs", asc = true}})
    local rewardConfig = DynamicConfigData.t_DonateGift
    self.list_reward:setItemRenderer(
        function(index, obj)
            local itemInfo = temp[index + 1]
            local rewardMode = rewardConfig[itemInfo.giftType][itemInfo.giftId]
            local itemCell = obj:getChildAutoType("itemCell")
            local bindItemCell = BindManager.bindItemCell(itemCell)
            bindItemCell:setData(
                rewardMode.clientshow[1].code,
                rewardMode.clientshow[1].amount,
                rewardMode.clientshow[1].type,
                true
            )
            local txt_desc = obj:getChildAutoType("txt_desc")
            local goodsitem = ItemConfiger.getInfoByCode(rewardMode.clientshow[1].code, rewardMode.clientshow[1].type)
            local playerStr = ColorUtil.formatColorString1("[" .. itemInfo.fromPlayerName .. "]", "#ffc35b")
            local goodsStr = ColorUtil.formatColorString1("[" .. goodsitem.name .. "]", "#ffc35b")
            local str = string.format("%s%s%s", playerStr, "送给你", goodsStr)
            txt_desc:setText(str)
            local txt_times = obj:getChildAutoType("txt_times")
            local servserTime = ServerTimeModel:getServerTime()
            local endTime = itemInfo.endMs / 1000
            local overdueStr = GMethodUtil:getHowLongOverdueStr(servserTime, endTime, "(%s后过期)")
            --%s后过期
            local timeStr = string.format("%s%s", TimeLib.msToString((itemInfo.addMs / 1000), "%H:%M:%S"), overdueStr)
            txt_times:setText(timeStr)
            local txt_words = obj:getChildAutoType("txt_words")
            txt_words:setText(itemInfo.words)
            local c1 = obj:getController("c1")
            if itemInfo.status == 1 then --可领取
                c1:setSelectedIndex(0)
            else
                c1:setSelectedIndex(1)
            end
            local btn_lingqu = obj:getChildAutoType("btn_lingqu")
            btn_lingqu:removeClickListener(100) --池子里面原来的事件注销掉
            btn_lingqu:addClickListener(
                function(context)
                    ChatModel:RelationshipGetGiftReward(itemInfo.giftType, itemInfo.uuid)
                end,
                100
            )
            local btn_huizeng = obj:getChildAutoType("btn_huizeng")
            btn_huizeng:removeClickListener(100) --池子里面原来的事件注销掉
            btn_huizeng:addClickListener(
                function(context)
                    ChatModel:openGiftView(1,itemInfo.fromPlayer,itemInfo.fromPlayer.playerId)
                    self:closeView()
                end,
                100
            )
        end
    )
    self.list_reward:setNumItems(#temp)
end

--页面退出时执行
function ChatGiftReceiveView:update_upChatGiftGiftRecord(...)
    self:showList()
end

--页面退出时执行
function ChatGiftReceiveView:_exit(...)
    print(1, "ChatView _exit")
end

return ChatGiftReceiveView
