local ChatTextView, Super = class("ChatTextView", Window)
local ChatTextCell = require "Game.UI.Global.ChatTextCell"
local msToString = TimeLib.msToString
local timeStr = "[%s]"
local format_normal = "%m-%d %H:%M"

function ChatTextView:ctor()
    LuaLogE("Chat ctor")
    self._packName = "Chat"
    self._compName = "ChatTextView"
    self._rootDepth = LayerDepth.PopWindow
    self._channelId=2
    self.chatList=false
    self._updateTimeId=false
end

function ChatTextView:_initUI()
    LuaLogE("M _initUI")
    self._msgList=self.view:getChildAutoType("list_chat") 
    local msgInput = self.view:getChildAutoType("msgInput")
    
    self._sendBtn = self.view:getChildAutoType("sendBtn")
    self.msgInput = BindManager.bindTextInput(msgInput)
    self.msgInput:setMaxLength(40)
    self:initChatTxtList(self._channelId)
end

function ChatTextView:getChatData(channelType)
    printTable(6, "当前的type", channelType)
    if channelType == ModelManager.ChatModel.ChatType.NotUse then
        return ModelManager.ChatModel.synthesizeChatArray
    elseif channelType == ModelManager.ChatModel.ChatType.System then
        return ModelManager.ChatModel.sysChatArray
    elseif channelType == ModelManager.ChatModel.ChatType.World then
        return ModelManager.ChatModel.worldChatArray
    elseif channelType == ModelManager.ChatModel.ChatType.Guild then
        return ModelManager.ChatModel.guildChatArray
    elseif channelType == ModelManager.ChatModel.ChatType.Private then
        return ModelManager.ChatModel.privateChatArray
    elseif channelType == ModelManager.ChatModel.ChatType.Crossrealm then
        return ModelManager.ChatModel.crossrealmArray
    elseif channelType == ModelManager.ChatModel.ChatType.worldCross then
        return ModelManager.ChatModel.worldcrossrealmArray
	elseif channelType == ModelManager.ChatModel.ChatType.GodMarket then
        return ModelManager.ChatModel.GodMarket
    end
end

function ChatTextView:initChatTxtList(id) --聊天框文本列表
    self.chatList = self:getChatData(id)
    if not self.chatList then
        return
    end
    printTable(9, "当前答应的数据", self.chatList)
      self._msgList:setVirtual()
    --  self._msgList:setVirtualListChangedFlag(true)
    self._msgList:setItemRenderer(
        function(index, obj)
            obj:removeClickListener(5)
            --池子里面原来的事件注销掉
            obj:addClickListener(
                function(context)
                    -- self:itemClick(index)
                end,
                5
            )
            local chatItemInfo = self.chatList[index + 1]
            self:itemShow(obj, chatItemInfo)
        end
    )
    self._msgList:setItemProvider(
        function(index)
            local playId = ModelManager.PlayerModel.userid
            local curItem = self.chatList[index + 1]
            local isvoice,content,audioLen= ChatModel:isVoiceItem(curItem)
            if curItem.chatType == ChatModel.ChatType.System and curItem.viewType == 1 then
                return "ui://Chat/com_chatSystem"
            else
                if isvoice==true then
                    if (curItem.fromPlayer.playerId == playId) then
                        printTable(6, "当前的Item", index, curItem.fromPlayer.playerId, playId)
                        return "ui://Chat/com_chatVoiceRight"
                    else
                        return "ui://Chat/com_chatVoiceLeft"
                    end
                else
                    if (curItem.fromPlayer.playerId == playId) then
                        printTable(6, "当前的Item", index, curItem.fromPlayer.playerId, playId)
                        return "ui://Chat/com_chatRight"
                    else
                        return "ui://Chat/com_chatLeft"
                    end
                end
            end
        end
    )
    local num = 0
    if self.chatList then
        num = #self.chatList
    end
    self._msgList:setNumItems(num)
        --     self._msgList:refreshVirtualList()
    self._msgList:scrollToView(#self.chatList - 1, true, true)
end

function ChatTextView:itemShow(obj, chatData)
        if chatData.chatType == ChatModel.ChatType.System and chatData.viewType == 1 then
            local msgLabel = obj:getChildAutoType("msgLabel")
            msgLabel:setAnchorTextUnderline(false)
            msgLabel:setText("")
            msgLabel:setWidth(400)
            local parseStr = ModelManager.ChatModel:parse(chatData.content)
            local textCell = ChatTextCell.new(msgLabel)
            textCell:setText(parseStr, chatData)
            msgLabel:setWidth(msgLabel:getTextSize().width)
            local txt_chanelname = obj:getChildAutoType("txt_chanelname")
            txt_chanelname:setText(ChatModel:getsysChannelName(chatData))
        else
            local chatName = obj:getChildAutoType("chatName")
            if chatData.chatType == ChatModel.ChatType.Crossrealm then
                local positionStr = ""
                if chatData.fromPlayer.province and chatData.fromPlayer.cityId then
                    positionStr = ChatModel:getPositionName(chatData.fromPlayer.province, chatData.fromPlayer.cityId)
                end
                chatName:setText(chatData.fromPlayer.name .. "[" .. positionStr .. "]")
            elseif chatData.chatType == ChatModel.ChatType.worldCross then 
                local positionStr = ""
                if chatData.fromPlayer and chatData.fromPlayer.serverId then
                    positionStr= chatData.fromPlayer.serverId
                end
                chatName:setText(chatData.fromPlayer.name .. "[S." .. positionStr .. "]")
            else
                chatName:setText(chatData.fromPlayer.name)
            end
            local timeLabel = chatName:getChildAutoType("timeLabel")
            if chatData.receiveMs then
                timeLabel:setText(string.format(timeStr, msToString(chatData.receiveMs, format_normal)))
            else
                timeLabel:setText("")
            end
            local msgLabel = obj:getChildAutoType("msgLabel")
            msgLabel:setAnchorTextUnderline(false)
            msgLabel:setText("")
            local isvoice,content,audioLen ,contentArr= ChatModel:isVoiceItem(chatData)
            if isvoice==true  then--是语音item
                local voiceTime = obj:getChildAutoType("voiceTime") 
                local timeLabel=  voiceTime:getChildAutoType("timeLabel")
                timeLabel:setText(audioLen.."s")
                msgLabel:setText(content)
                voiceTime:removeClickListener(100)
                voiceTime:addClickListener(
                    function(context)
                        ChatSpeechUtil:btnTouchPlayVoice(chatData,contentArr)
                    end,
                    100
                )
                if self._channelId == ModelManager.ChatModel.ChatType.Private then
                    msgLabel:setWidth(260)
                else
                    msgLabel:setWidth(260)
                end
                msgLabel:setWidth(msgLabel:getTextSize().width)
            else--普通文本显示样式
                if self._channelId == ModelManager.ChatModel.ChatType.Private then
                    msgLabel:setWidth(260)
                else
                    msgLabel:setWidth(260)
                end
                -- local sdf= fgui.UBBParser:parse(132,  false)
                local parseStr = ModelManager.ChatModel:parse(chatData.content)
                --msgLabel:setText(parseStr) --EmojiParser::getInstance()->parse(chatData.content.c_str())
                local textCell = ChatTextCell.new(msgLabel)
                textCell:setText(parseStr)
            end
            msgLabel:setWidth(msgLabel:getTextSize().width)
            local sex = obj:getChildAutoType("sex")
            sex:setURL(PathConfiger.getHeroSexIcon(chatData.fromPlayer.sex))
            local playerHead = obj:getChildAutoType("playerHead")
            local heroItem = BindManager.bindPlayerCell(playerHead)
            heroItem:setHead(chatData.fromPlayer.head, chatData.fromPlayer.level,nil,nil,chatData.fromPlayer.headBorder)
            playerHead:removeClickListener(100)
            playerHead:addClickListener(
                function(context)
                    local playId = ModelManager.PlayerModel.userid
                    local playerid = chatData.fromPlayer.playerId
                    if playId ~= playerid then
                        local serverId = chatData.fromPlayer.serverId
                      if chatData.chatType == ChatModel.ChatType.Crossrealm or   chatData.chatType == ChatModel.ChatType.worldCross then
                        ViewManager.open("ViewPlayerView", {noHideLast=true,playerId = playerid, serverId = serverId,chatNeedBtn = false})
                      else
                        ViewManager.open("ViewPlayerView", {noHideLast=true,playerId = playerid, serverId = serverId})
                      end  
                    else
                        RollTips.show(Desc.chat_need_rename1)
                    end
                end,
                100
            )
        end
end

function ChatTextView:_initEvent(...)
    self._sendBtn:addClickListener(
        --发送按钮
        function()
            local text=self.msgInput:getText()
            local playId = ModelManager.PlayerModel.userid
            local serverId = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
            ModelManager.ChatModel:sendMsg(playId, self._channelId, text, serverId, 9)
        end
    )


    self._updateTimeId=  Scheduler.schedule(
        function()
            local text=DescAuto[96] -- [96]="12月14日，国家市场监管总局对阿里巴巴投资有限公司收购银泰商业（集团）有限公司股权、阅文收购新丽传媒控股有限公司股权"
            local playId = ModelManager.PlayerModel.userid
            local serverId = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
            ModelManager.ChatModel:sendMsg(playId, self._channelId, text, serverId, 9)
        end,
        3
    )
end



function ChatTextView:update_chatInfo(_, copytype)
    self.chatList = self:getChatData(self._channelId)
    if not self.chatList then
        return
    end
    printTable(155, "刷新聊天列表", #self.chatList, self.scrollStateTag)
    self._msgList:setNumItems(#self.chatList)
    self._msgList:getScrollPane():scrollBottom()
    self._msgList:scrollToView(#self.chatList - 1, true, false)
  
end


--页面退出时执行
function ChatTextView:_exit(...)
    print(1, "ChatView _exit")
    if self._updateTimeId then
        Scheduler.unschedule(self._updateTimeId)
    end
end

return ChatTextView
