local ChatGiftView, Super = class("ChatGiftView", Window)
function ChatGiftView:ctor()
    self._packName = "Chat"
    self._compName = "ChatGiftView"
    self._rootDepth = LayerDepth.PopWindow
    self.curInfo={}
end

function ChatGiftView:_initEvent()
    self.btn_huozeng:addClickListener(
        function(context)
            ViewManager.open("ChatGiftReceiveView")
            self:closeView()
        end,
        100
    )
    self.btn_send:addClickListener(
        function(context)
            local words= self.msgInput:getText()
            local tarPlayerId,serverId,giftType,giftId=ChatModel.sendGiftPlayer["playerId"],ChatModel.sendGiftPlayer["serverId"],self.curInfo["giftType"],self.curInfo["giftId"]
            ChatModel:RelationshipDonate(tarPlayerId,serverId,giftType,giftId,words)--赠礼
        end,
        100
    )
   
end

function ChatGiftView:_initUI()
    self.list_type = self.view:getChildAutoType("list_type")
    self.list_libao = self.view:getChildAutoType("list_libao")
    self.list_daoju = self.view:getChildAutoType("list_daoju")
    self.btn_huozeng = self.view:getChildAutoType("btn_huozeng")
    self.btn_send = self.view:getChildAutoType("btn_send")
    self.c1= self.view:getController("c1")
    local msgInput = self.view:getChildAutoType("msgInput")
    self.msgInput = BindManager.bindTextInput(msgInput)
    self.msgInput:setMaxLength(40)
    self.list_type:setItemRenderer(
        function(index, obj)
            local title = obj:getChildAutoType("title")
            if index == 0 then
                self.curInfo["giftType"]=1
                self:showGiftBagList()
                obj:setSelected(true)
                self.c1:setSelectedIndex(0)
                title:setText("礼    包")
            else
                title:setText("道    具")
            end
            obj:removeClickListener(100)
            --池子里面原来的事件注销掉
            obj:addClickListener(
                function(context)
                    if index == 0 then
                        self.curInfo["giftType"]=1
                        self:showGiftBagList()
                        self.c1:setSelectedIndex(0)
                    else
                        self.curInfo["giftType"]=2
                        self:showGiftDaojuList()
                        self.c1:setSelectedIndex(1)
                    end
                end,
                100
            )
        end
    )
    self.list_type:setNumItems(2)
end

function ChatGiftView:showBtnText()
    local gifttype=self.curInfo["giftType"]
    local configInfo1=DynamicConfigData.t_DonateGiftSetting[gifttype]
    local servserTime1= ChatModel:getSendGiftTimes(gifttype)
    local str=string.format( "(%s/%s)",servserTime1,configInfo1.sendlimit)
    self.btn_send:setTitle(str)
end

function ChatGiftView:showGiftBagList() --礼包
    local temp={}
    local rewardList=DynamicConfigData.t_DonateGift[1]
    for key, value in pairs(rewardList) do
        temp[#temp+1]=value
    end
    TableUtil.sortByMap(temp,{ {key="id",asc=false}})
    self.list_libao:setItemRenderer(
        function(index, obj)
            local itemInfo=temp[index+1]
            local itemCell = obj:getChildAutoType("itemCell")
            local bindItemCell = BindManager.bindItemCell(itemCell)
            bindItemCell:setData(itemInfo.clientshow[1].code, itemInfo.clientshow[1].amount, itemInfo.clientshow[1].type, true)
            bindItemCell:setAmountStr("")
            local item= ItemConfiger.getInfoByCode(itemInfo.clientshow[1].code, itemInfo.clientshow[1].type)
            local txt_name = obj:getChildAutoType("txt_name")
            txt_name:setText(item.name) 
            local costItem = obj:getChildAutoType("costItem")
            local costItmeObj = BindManager.bindCostItem(costItem)
            costItmeObj:setData(itemInfo.price[1].type, itemInfo.price[1].code, itemInfo.price[1].amount,true)
            if index==0 then
                self.curInfo["giftId"]=itemInfo.id
                obj:setSelected(true)
                else
                obj:setSelected(false)
            end
            obj:removeClickListener(100) --池子里面原来的事件注销掉
            obj:addClickListener(
                function(context)
                    self.curInfo["giftId"]=itemInfo.id
                end,
                100
            )
        end
    )
    self.list_libao:setNumItems(#temp)
end

function ChatGiftView:showGiftDaojuList() --道具
    local temp={}
    local rewardList=DynamicConfigData.t_DonateGift[2]
    for key, value in pairs(rewardList) do
        temp[#temp+1]=value
    end
    TableUtil.sortByMap(temp,{ {key="id",asc=false}})
    self.list_daoju:setItemRenderer(
        function(index, obj)
            local itemInfo=temp[index+1]
            local itemCell = obj:getChildAutoType("itemCell")
            local bindItemCell = BindManager.bindItemCell(itemCell)
            bindItemCell:setData(itemInfo.clientshow[1].code, itemInfo.clientshow[1].amount, itemInfo.clientshow[1].type, true)
            bindItemCell:setAmountStr("")
            local item= ItemConfiger.getInfoByCode(itemInfo.clientshow[1].code, itemInfo.clientshow[1].type)
            local txt_name = obj:getChildAutoType("txt_name")
            txt_name:setText(item.name) 
            if index==0 then
                self.curInfo["giftId"]=itemInfo.id
                obj:setSelected(true)
                else
                obj:setSelected(false)
            end
            obj:removeClickListener(100)      --池子里面原来的事件注销掉
            obj:addClickListener(
                function(context)
                    self.curInfo["giftId"]=itemInfo.id
                end,
                100
            )
        end
    )
    self.list_daoju:setNumItems(#temp)
end

function ChatGiftView:update_upChatGiftTimes(...)
        self:showBtnText()
end

--页面退出时执行
function ChatGiftView:_exit(...)
    print(1, "ChatView _exit")
    self.curInfo={}
end

return ChatGiftView
