local M, Super = class("M", Window)
local ChatTextCell = require "Game.UI.Global.ChatTextCell"
local msToString = TimeLib.msToString
local MATH_MIN = math.min
local MATH_MAX = math.max
local timeStr = "[%s]"
local format_normal = "%m-%d %H:%M"

function M:ctor()
    LuaLogE("Chat ctor")
    self._packName = "Chat"
    self._compName = "ChatView"
    self._rootDepth = LayerDepth.PopWindow
    self._closeBtn1 = false
    self._controlC2 = false
    self._controlC3 = false
    self._msgList = false
    self._sendBtn = false
    self._channelList = false
    self._channelId = 1
    self._openEmoji = false
    self._openVoice = false
    self.msgInput = false
    self._setting = false
    self._btnshare = false
    self._btn_jionguild = false
    self._listPrivate = false
    self._privateMsgList = false
    self._btnnewMsg = false
    self.curItem = false
    self.chatList = {}
    self.chatPrivateList = {}
    self.loginFirstInitTag = false
    -- self._updateTimeId=false
    self.scrollStateTag = false
    --是否是在查看历史消息
    self.scrollNum = 0
    --世界聊天列表滚动距离
    self.openVoiceListener = false --话筒事件
    self.curAtMeStrList = {}
    self.isScrollIng=false--正在滚动的状态
	self.showRoomChanel = self._args.showRoom == true --是否显示房间频道
	
end

function M:_initUI()
    LuaLogE("M _initUI")
    --local textureMemory = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
    --local str = string.format("现在内存是: %sM", textureMemory)
    --printTable(33,textureMemory)
    --LoginModel:readSavedServerInfo()
    self._controlC2 = self.view:getController("c2")
    self._controlC3 = self.view:getController("c3")
    self._controlC4 = self.view:getController("c4")
    self._controlC5 = self.view:getController("c5")
    self._controlC5:setSelectedIndex(0)
    self.com_copyandreply = self.view:getChildAutoType("com_copyandreply")
    self.copyandreplyCloseBtn = self.com_copyandreply:getChildAutoType("closeButton")
    self.btn_copy = self.com_copyandreply:getChildAutoType("btn_copy")
    self.btn_reply = self.com_copyandreply:getChildAutoType("btn_reply")
    self.list_atme = self.view:getChildAutoType("list_atme")
    self._closeBtn1 = self.view:getChildAutoType("closeBtn")
    local msgInput = self.view:getChildAutoType("msgInput")
    self.msgInput = BindManager.bindTextInput(msgInput)
    self.msgInput:setMaxLength(40)
    self._sendBtn = self.view:getChildAutoType("sendBtn")
    self._msgList = self.view:getChildAutoType("msgList")

    self.txt_nofriend = self.view:getChildAutoType("txt_nofriend")
    self._channelList = self.view:getChildAutoType("channelList")
    self._openEmoji = self.view:getChildAutoType("btn_openEmoji")
    self._openVoice = self.view:getChildAutoType("btn_openVoice")
    self._setting = self.view:getChildAutoType("btn_setting")
    self._btnshare = self.view:getChildAutoType("btn_share")
    self._btn_jionguild = self.view:getChildAutoType("btn_jionguild")
    self.btn_gift = self.view:getChildAutoType("btn_gift")
    self._listPrivate = self.view:getChildAutoType("list_private")
    self._closeAlphaBtn = self.view:getChildAutoType("closeButton")
    self._privateMsgList = self.view:getChildAutoType("privateMsgList")
    self._btnnewMsg = self.view:getChildAutoType("btn_newMsg")
    self._openFriendView = self.view:getChildAutoType("btn_openFriendView")
    self.com_copyandreply:setVisible(false)
    if self._args and self._args.isBattleView == 1 then
        self._capSceneSprite = true
    else
        self._capSceneSprite = false
    end
    if not tolua.isnull(self._btnnewMsg) then
        self._btnnewMsg:setVisible(false)
    end
    SpeechUtil:initAccessToken()
    ChatModel:setChatCountNumZero()
    self:initMsgScrollStateTag()
    self:initKeyBoardEven()
    self:initChanneList()
    self:initAtMeList()
	
	if self._args.curChannel then
		self:update_chatClientOpenViewByChannelId(1,self._args.curChannel)
	end
end

function M:initAtMeList()
    local map = ChatModel:getCurCopyMsgStr(self._channelId)
    local temp = {}
    if next(map) ~= nil then
        for k, v in pairs(map) do
            temp[#temp + 1] = v
        end
    end
    TableUtil.sortByMap(temp, {{key = "ms", asc = true}})
    self.curAtMeStrList = temp
    self.list_atme:setItemRenderer(
        function(index, obj)
            obj:removeClickListener(100)
            obj:addClickListener(
                function(context)
                    local info = self.curAtMeStrList[index + 1]
                    ChatModel:deleteCurCopyMsgStr(
                        self._channelId,
                        string.format("%s_%s_%s", info.key, info.itemIndex, info.ms)
                    )
                    self:upAtMeList()
                   -- local itemIndex = tonumber(info.itemIndex)
                   local itemIndex=self:getAtItemIndex(tonumber(info.servserTime))
                    self._msgList:scrollToView(itemIndex-1, true, true)
                end,
                100
            )
        end
    )
    if next(map) ~= nil then
        self._controlC4:setSelectedIndex(1)
    else
        self._controlC4:setSelectedIndex(0)
    end
    self.list_atme:setNumItems(#temp)
end

function M:getAtItemIndex(servserTime)
    local chatdata= self:getChatData(self._channelId)
    for i = 1, #chatdata, 1 do
        if chatdata[i] and chatdata[i].receiveMs then
            local ms=chatdata[i].receiveMs
            if ms== servserTime then
                return i 
            end
        end
    end
    return #chatdata
end

function M:upAtMeList()
    local map = ChatModel:getCurCopyMsgStr(self._channelId)
    local temp = {}
    if next(map) ~= nil then
        for k, v in pairs(map) do
            temp[#temp + 1] = v
        end
    end
    TableUtil.sortByMap(temp, {{key = "ms", asc = true}})
    self.curAtMeStrList = temp
    if next(map) ~= nil then
        self.list_atme:setNumItems(#temp)
        self._controlC4:setSelectedIndex(1)
    else
        self.list_atme:setNumItems(0)
        self._controlC4:setSelectedIndex(0)
    end
end

function M:initKeyBoardEven()
    self.msgInput:onInputBegin(
        function(str)
            if self._closeAlphaBtn then
                self._closeAlphaBtn:removeClickListener()
            end
        end
    )

    self.msgInput:onInputEnd(
        function(str)
            if self._closeAlphaBtn then
                self._closeAlphaBtn:removeClickListener()
                Scheduler.scheduleOnce(
                    0.3,
                    function()
                        if tolua.isnull(self._closeAlphaBtn) then
                            return
                        end
                        self._closeAlphaBtn:addClickListener(
                            function()
                                self:closeView()
                            end
                        )
                    end
                )
            end
        end
    )

    self.msgInput:onChanged(
        function(str)
            --printTable("输入框中的文字修改",str)
            if str=="" then
                ChatModel:setCurAtMsgStr("")
            end
            ChatModel:setCurinputTextStr(str)
        end
    )
    local text = ChatModel:getCurinputTextStr()
    self.msgInput:setText(text)
end

function M:initMsgScrollStateTag()
    self._msgList:removeEventListener(FUIEventType.Scroll, 100)
    self._msgList:addEventListener(
        FUIEventType.Scroll,
        function(context)
            --printTable(159, "滚动开始》》》》》")
            self.isScrollIng=true--策划需要正在滚动的时候不能点击头像
            local x = self._msgList:getScrollPane():getPosY()
            if x < self.scrollNum - 70 then
                self.scrollStateTag = true
            else
                self.scrollStateTag = false
                self._btnnewMsg:setVisible(false)
                ChatModel:setChatCountNumZero()
            end
        end,
        100
    )
    self._msgList:addEventListener(
        FUIEventType.ScrollEnd,
        function(context)
           -- printTable(159, "滚动结束》》》》》")
           self.isScrollIng=false
        end,
        100
    )
    self.view:addEventListener(
        FUIEventType.TouchEnd,
        function(context)
           -- printTable(159, "滚动结束》》》》》")
           self.isScrollIng=false
        end,
        100
    )
    
end

function M:setMsgScrollStateNum()
    local x = self._msgList:getScrollPane():getPosY()
    self.scrollNum = x
    self.scrollStateTag = false
    self._btnnewMsg:setVisible(false)
    ChatModel:setChatCountNumZero()
    printTable(152, "222222222", x)
end

function M:initChanneList()
    local channelType = ModelManager.ChatModel.chanelList
    self._channelList:setItemRenderer(
        function(index, obj)
            --池子里面原来的事件注销掉
            obj:removeClickListener(10)
            --local name = channelType[index + 1].desc
            local channel = channelType[index + 1].channelType
            local img_red = obj:getChildAutoType("img_red")
            local redType = ""
            if channel == ModelManager.ChatModel.ChatType.Private then
                redType = "V_CHAT_PRIVATE"
            elseif channel == ModelManager.ChatModel.ChatType.Guild then
                redType = "V_CHAT_GUILD"
            elseif channel == ModelManager.ChatModel.ChatType.World then
                redType = "V_CHAT_WORLD"
            elseif channel == ModelManager.ChatModel.ChatType.Crossrealm then
                redType = "V_CHAT_CROSSREAL"
            elseif channel == ModelManager.ChatModel.ChatType.worldCross then
                redType = "V_CHAT_WORLDCROSS"
		elseif channel == ModelManager.ChatModel.ChatType.GodMarket then
                redType = "V_CHAT_GODMARKET"
            end
            RedManager.register(redType, img_red)
            obj:addClickListener(
                function(context)
                    self._btnnewMsg:setVisible(false)
                    ChatModel:setChatCountNumZero()
                    self._channelId = channel
                    self:upAtMeList()
                    ChatModel:setCurChannelId(channel)
                    if
                        channel == ModelManager.ChatModel.ChatType.NotUse or
                            channel == ModelManager.ChatModel.ChatType.System
                     then
                        self._controlC2:setSelectedIndex(1)
                    else
                        self._controlC2:setSelectedIndex(0)
                    end
                    if channel == ModelManager.ChatModel.ChatType.Guild then
                        local hasGuild = GuildModel.guildHave
                        if hasGuild == false then --没有公会
                            ModelManager.ChatModel.guildChatArray = {}
                            self._controlC2:setSelectedIndex(2)
                        else
                            self._controlC2:setSelectedIndex(0)
                        end
                    end
                    -- if channel == ModelManager.ChatModel.ChatType.Guild then
                    --     local hasGuild=GuildModel.guildHave;
                    --     if hasGuild==false then --没有公会
                    --         if self.curItem then
                    --             self.curItem:setSelected(true)
                    --         end
                    --         RollTips.show("请先加入公会")
                    --         obj:setSelected(false)
                    --         return
                    --     end
                    --     ModelManager.ChatModel:setCurrentOpenChannel(ModelManager.ChatModel.ChatType.Guild)
                    -- end
                    if channel == ModelManager.ChatModel.ChatType.World then
                        ModelManager.ChatModel:setCurrentOpenChannel(ModelManager.ChatModel.ChatType.World)
                    elseif channel == ModelManager.ChatModel.ChatType.Crossrealm then
						ModelManager.ChatModel:setCurrentOpenChannel(ModelManager.ChatModel.ChatType.Crossrealm)
					elseif channel == ModelManager.ChatModel.ChatType.worldCross then
						ModelManager.ChatModel:setCurrentOpenChannel(ModelManager.ChatModel.ChatType.worldCross)
					elseif channel == ModelManager.ChatModel.ChatType.Private then
						ModelManager.ChatModel:setCurrentOpenChannel(ModelManager.ChatModel.ChatType.Private)
					elseif channel == ModelManager.ChatModel.ChatType.Guild then
						ModelManager.ChatModel:setCurrentOpenChannel(ModelManager.ChatModel.ChatType.Guild)
					elseif channel == ModelManager.ChatModel.ChatType.GodMarket then
						ModelManager.ChatModel:setCurrentOpenChannel(ModelManager.ChatModel.ChatType.GodMarket)
					else
						ModelManager.ChatModel:setCurrentOpenChannel(0)
                    end
                    if channel == ModelManager.ChatModel.ChatType.Private then
                        if ChatModel.chatPrivateTag == false then
                            ChatModel.chatPrivateTag = true
                            ModelManager.ChatModel:setServerIdAndPlayerId(
                                ModelManager.PlayerModel.userid,
                                math.tointeger(LoginModel:getLoginServerInfo().unit_server)
                            )
                            ChatModel:GetHistoryPrivateContentRecord()
                        end

                        self._controlC3:setSelectedIndex(1)
                        self:initChatPrivateList()
                    else
                        local playId = ModelManager.PlayerModel.userid
                        local serverId = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
                        ModelManager.ChatModel:setServerIdAndPlayerId(playId, serverId)
                        self._controlC3:setSelectedIndex(0)
                        if self.loginFirstInitTag == false then
                            self:initChatTxtList(channel)
                            self.loginFirstInitTag = true
                        else
                            self.chatList = self:getChatData(channel)
                            printTable(155, ">>>>>", self.chatList)
                            if not self.chatList then
                                return
                            end
                            self._msgList:setNumItems(0)
                            self._msgList:setNumItems(#self.chatList)
                            self:NextFramescroll()
                        end
                    end
                    self:setMsgScrollStateNum()
                    self.curItem = obj
                end,
                10
            )
            --obj:setTouchable(false)
            local defaultId = ChatModel:getChannelIndex()
            --默认选中的频道
            if index == defaultId - 1 then
                self.curItem = obj
                local channel = channelType[index + 1].channelType
                if
                    channel == ModelManager.ChatModel.ChatType.NotUse or
                        channel == ModelManager.ChatModel.ChatType.System
                 then
                    self._controlC2:setSelectedIndex(1)
                else
                    self._controlC2:setSelectedIndex(0)
                end
                self._channelId = channel
                ChatModel:setCurChannelId(channel)
                local playId = ModelManager.PlayerModel.userid
                local serverId = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
                ModelManager.ChatModel:setServerIdAndPlayerId(playId, serverId)
                ModelManager.ChatModel:setCurrentOpenChannel(channel)
                if channel == ModelManager.ChatModel.ChatType.Private then
                    if ChatModel.chatPrivateTag == false then
                        ChatModel.chatPrivateTag = true
                        ModelManager.ChatModel:setServerIdAndPlayerId(
                            ModelManager.PlayerModel.userid,
                            math.tointeger(LoginModel:getLoginServerInfo().unit_server)
                        )
                        ChatModel:GetHistoryPrivateContentRecord()
                    end
                    ModelManager.ChatModel:setCurrentOpenChannel(ModelManager.ChatModel.ChatType.Private)
                    self._controlC3:setSelectedIndex(1)
                    self:initChatPrivateList()
                else
                    self._controlC3:setSelectedIndex(0)
                    if self.loginFirstInitTag == false then
                        self:initChatTxtList(self._channelId)
                        self.loginFirstInitTag = true
                    end
                end
            end
        end
    )
    local defaultId = ChatModel:getChannelIndex()
    self._channelList:setNumItems(self.showRoomChanel and 7 or 6)
    self._channelList:setSelectedIndex(defaultId - 1)
end

function M:getChatData(channelType)
    printTable(6, "当前的type", channelType)
    local arr = {}
    if channelType == ModelManager.ChatModel.ChatType.NotUse then
        arr = ModelManager.ChatModel.synthesizeChatArray
    elseif channelType == ModelManager.ChatModel.ChatType.System then
        arr = ModelManager.ChatModel.sysChatArray
    elseif channelType == ModelManager.ChatModel.ChatType.World then
        arr = ModelManager.ChatModel.worldChatArray
    elseif channelType == ModelManager.ChatModel.ChatType.Guild then
        arr = ModelManager.ChatModel.guildChatArray
    elseif channelType == ModelManager.ChatModel.ChatType.Private then
        arr = ModelManager.ChatModel.privateChatArray
    elseif channelType == ModelManager.ChatModel.ChatType.Crossrealm then
        arr = ModelManager.ChatModel.crossrealmArray
    elseif channelType == ModelManager.ChatModel.ChatType.worldCross then
        arr = ModelManager.ChatModel.worldcrossrealmArray
	elseif channelType == ModelManager.ChatModel.ChatType.GodMarket then
        arr = ModelManager.ChatModel.godMarketArray
    end
   -- local map = {}
   -- if ChatModel.chatBannedtoPostState then
        -- local banMap = ChatModel.chatBannedtoPostList
        -- if channelType~= ModelManager.ChatModel.ChatType.System and channelType ~= ModelManager.ChatModel.ChatType.NotUse then
        --     for i = 1, #arr, 1 do
        --         local chatItem = arr[i]
        --         if chatItem.fromPlayer and chatItem.fromPlayer.playerId and not banMap[chatItem.fromPlayer.playerId] then
        --             table.insert(map, chatItem)
        --         end
        --     end
        -- else
        --     map=arr
        -- end
     --   ChatModel.chatBannedtoPostState = false
    --else
       -- map = arr
  --  end
    return arr
end

function M:getPrivateData(privateInfolist)
    local arr={}
    arr=privateInfolist
    return arr
end

function M:initChatPrivateList()
    local txtArr = ModelManager.ChatModel.privateChatList
    printTable(8, "当前答应的私聊数据", txtArr)
    local temp = {}
    if next(txtArr) ~= nil then
        for k, v in pairs(txtArr) do
            temp[#temp + 1] = k
        end
    end
    if tolua.isnull(self.view) or tolua.isnull(self._listPrivate) then
        return
    end
    --self._listPrivate:setVirtual()
    self._listPrivate:setItemRenderer(
        function(index, obj)
            local chatItemKey = temp[index + 1]
            obj:setName("privateListObj" .. chatItemKey)
            local toPlayer = txtArr[chatItemKey].toPlayer
            local img_red = obj:getChild("img_red")
            printTable(12, "当前答应的私聊数据111")
            local playItem = obj:getChild("com_PlayerInfo")
            playItem:removeClickListener(5)
            playItem:addClickListener(
                function(context)
                    local chatItemKey = temp[index + 1]
                    ChatModel:setPrivateChatPlayerRedMs(chatItemKey)
                    img_red:setVisible(false)
                    self.chatPrivateList =self:getPrivateData(txtArr[chatItemKey].strArr) 
                    local listPos = StringUtil.lua_string_split(chatItemKey, "_")
                    ChatModel.sendGiftPlayer["playerId"]=listPos[1]
                    ChatModel.sendGiftPlayer["serverId"]=listPos[2]
                    ModelManager.ChatModel:setServerIdAndPlayerId(listPos[1], listPos[2], toPlayer.name)
                    printTable(18, "打印的私聊消息", self.chatPrivateList)
                    self:showPrivateList(self.chatPrivateList)
                end,
                5
            )
            local txtName = playItem:getChildAutoType("txt_name")
            txtName:setText(toPlayer.name)
            local btn_closeOne = obj:getChildAutoType("btn_closeOne")
            btn_closeOne:removeClickListener(100)
            --池子里面原来的事件注销掉
            btn_closeOne:addClickListener(
                function(context)
                    ChatModel:deletePrivate(chatItemKey)
                end,
                100
            )
            local txtLine = playItem:getChildAutoType("txt_line")
            local gCtr = playItem:getController("c1")
            local contr1 = 1
            local isLine = ColorUtil.formatColorString1(Desc.chatView_str21, ColorUtil.itemColorStr[1])
            if toPlayer.online == true then
                isLine = ColorUtil.formatColorString1(Desc.chatView_str22, ColorUtil.itemColorStr[2])
                contr1 = 0
            end
            txtLine:setText(isLine)
            gCtr:setSelectedIndex(contr1)
            local playerHead = playItem:getChildAutoType("playerHead")
            local heroItem = BindManager.bindPlayerCell(playerHead)
            heroItem:setHead(toPlayer.head, toPlayer.level, nil, nil, toPlayer.headBorder)
            -- local frameLoader=playerHead:getChildAutoType("frameLoader")
            -- frameLoader:setIcon(PlayerModel:getUserHeadURL(toPlayer.head))
            -- local headLevel = playerHead:getChildAutoType("level")
            -- headLevel:setText(toPlayer.level)
            local playId, serverId = ModelManager.ChatModel:getServerIdAndPlayerId()
            if playId == ModelManager.PlayerModel.userid then
                if index == 0 then
                    ChatModel:setPrivateChatPlayerRedMs(chatItemKey)
                    img_red:setVisible(false)
                    self._listPrivate:scrollToView(index, true, true)
                    printTable(18, "获取私聊聊天记录22", playId, serverId)
                    obj:setSelected(true)
                    self.chatPrivateList =self:getPrivateData(txtArr[chatItemKey].strArr or {})  
                    local listPos = StringUtil.lua_string_split(chatItemKey, "_")
                    ModelManager.ChatModel:setServerIdAndPlayerId(listPos[1], listPos[2], toPlayer.name)
                    ChatModel.sendGiftPlayer["playerId"]=listPos[1]
                    ChatModel.sendGiftPlayer["serverId"]=listPos[2]
                    self:showPrivateList(self.chatPrivateList)
                else
                    local red = ChatModel.privateChatRedstate[chatItemKey] or false
                    img_red:setVisible(red)
                    obj:setSelected(false)
                end
            else
                local playerKey = playId .. "_" .. serverId
                if chatItemKey == playerKey then
                    ChatModel:setPrivateChatPlayerRedMs(playerKey)
                    img_red:setVisible(false)
                    obj:setSelected(true)
                    self._listPrivate:scrollToView(index, true, true)
                    self.chatPrivateList = self:getPrivateData(txtArr[chatItemKey].strArr or {}) 
                    self:showPrivateList(self.chatPrivateList)
                else
                    local red = ChatModel.privateChatRedstate[chatItemKey] or false
                    img_red:setVisible(red)
                    obj:setSelected(false)
                end
            end
        end
    )
    local info = ChatModel.privateChatRedMs
    if #temp == 0 then
        self.btn_gift:setVisible(false)
        self.txt_nofriend:setVisible(true)
    else
        self.btn_gift:setVisible(true)
        self.txt_nofriend:setVisible(false)
    end
    self._listPrivate:setNumItems(#temp)
end

function M:showPrivateList(txtArr)
    -- if __ENGINE_VERSION__ >= 3 then
    --     self._privateMsgList:setVirtual()
    -- end
    self._privateMsgList:setItemRenderer(
        function(index, obj)
            obj:removeClickListener()
            obj:addClickListener(
                function(context)
                end,
                5
            )
            local chatItemInfo = self.chatPrivateList[index + 1]
            printTable(10, ">>>>>>>>>>>>?????????????", chatItemInfo)
            self:itemShow(obj, chatItemInfo, index + 1)
        end
    )
    self._privateMsgList:setItemProvider(
        function(index)
            local playId = ModelManager.PlayerModel.userid
            local curItem = self.chatPrivateList[index + 1]
            local isvoice, content, audioLen = ChatModel:isVoiceItem(curItem)
            if curItem.chatType == ChatModel.ChatType.System and curItem.viewType == 1 then
                return "ui://Chat/com_chatSystem"
            else
                if isvoice == true then
                    if (curItem.fromPlayer.playerId == playId) then
                        printTable(6, "当前的Item", index, curItem.fromPlayer.playerId, playId)
                        return "ui://Chat/com_privatechatVoiceRight"
                    else
                        return "ui://Chat/com_privatechatVoiceLeft"
                    end
                else
                    if (curItem.fromPlayer.playerId == playId) then
                        printTable(6, "当前的Item", index, curItem.fromPlayer.playerId, playId)
                        return "ui://Chat/com_privatechatRight"
                    else
                        return "ui://Chat/com_privatechatLeft"
                    end
                end
            end
        end
    )
    local num = 0
    if self.chatPrivateList then
        num = #self.chatPrivateList
    end
    printTable(18, "刷新啥车速度符333", #self.chatPrivateList)
    self._privateMsgList:setNumItems(num)
    self._privateMsgList:scrollToView(#self.chatPrivateList - 1, true, true)
end

function M:initChatTxtList(id) --聊天框文本列表
    self.chatList = self:getChatData(id)
    if not self.chatList then
        return
    end
    printTable(9, "当前答应的数据", self.chatList)
    -- if __ENGINE_VERSION__ >=3  then
    --  self._msgList:setVirtual()
    -- end
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
            self:itemShow(obj, chatItemInfo, index + 1)
        end
    )
    self._msgList:setItemProvider(
        function(index)
            local playId = ModelManager.PlayerModel.userid
            local curItem = self.chatList[index + 1]
            local isvoice, content, audioLen = ChatModel:isVoiceItem(curItem)
            if curItem.chatType == ChatModel.ChatType.System and curItem.viewType == 1 then
                return "ui://Chat/com_chatSystem"
            else
                if isvoice == true then
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
    self._msgList:removeChildrenToPool()
    self._msgList:setNumItems(num)
    if self._msgList and not tolua.isnull(self._msgList) then
        self._msgList:scrollToView(#self.chatList - 1, true, false)
    end
    self:setMsgScrollStateNum()
end

function M:itemShow(obj, chatData, pos)
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
        if not tolua.isnull(txt_chanelname) then
            local str = ChatModel:getsysChannelName(chatData)
            if str == nil then
                str = DescAuto[102] -- [102]="系统"
            end
            txt_chanelname:setText(str)
        end
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
                positionStr =chatData.fromPlayer.serverId
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
        local isvoice, content, audioLen, contentArr = ChatModel:isVoiceItem(chatData)
        if isvoice == true then --是语音item
            local voiceTime = obj:getChildAutoType("voiceTime")
            local timeLabel = voiceTime:getChildAutoType("timeLabel")
            timeLabel:setText(audioLen .. "s")
            msgLabel:setText(content)
            if ChatModel.chatVoiceAnim==contentArr[2] then
                self:showVoiceEff(voiceTime,"t0")
            else
                self:stopVoiceEff(voiceTime,"t0")
            end
            voiceTime:removeClickListener(100)
            voiceTime:addClickListener(
                function(context)
                    ChatModel.chatVoiceAnim=contentArr[2]
                    ChatSpeechUtil:btnTouchPlayVoice(chatData, contentArr)
                    self:showVoiceEff(voiceTime,"t0")
                    Dispatcher.dispatchEvent(EventType.update_chatInfo)
                    Dispatcher.dispatchEvent(EventType.update_chatClientPrivteInfo)
                end,
                100
            )
            if self._channelId == ModelManager.ChatModel.ChatType.Private then
                msgLabel:setWidth(260)
            else
                msgLabel:setWidth(260)
            end
            msgLabel:setWidth(msgLabel:getTextSize().width)
        else --普通文本显示样式
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
        local isBigFace = GMethodUtil:isfacesetURL(chatData.content)
        local msgBg = obj:getChildAutoType("msgBg")
        if isBigFace == true then
            msgBg:setVisible(false)
        else
            msgBg:setVisible(true)
        end
        msgLabel:setWidth(msgLabel:getTextSize().width)
        -- printTable(16,'????????????????????',chatData.content,msgLabel:getTextSize().width)
        local sex = obj:getChildAutoType("sex")
        sex:setURL(PathConfiger.getHeroSexIcon(chatData.fromPlayer.sex))

        local playerHead = obj:getChildAutoType("playerHead")
        local heroItem = BindManager.bindPlayerCell(playerHead)
        heroItem:setHead(chatData.fromPlayer.head, chatData.fromPlayer.level, nil, nil, chatData.fromPlayer.headBorder)
        if chatData.chatType and chatData.chatType ~= ModelManager.ChatModel.ChatType.Private then
            local playId = ModelManager.PlayerModel.userid
            local playerid = chatData.fromPlayer.playerId
            if playId ~= playerid then
                local isLongTouch = false
                playerHead:removeLongPressListener()
                playerHead:addLongPressListener(
                    function(context) --@别人
                        printTable(159, "点击结果》》》》》",self.isScrollIng)
                        if  self.isScrollIng==true then
                            return
                        end
                        isLongTouch = true
                        if PlayerModel.level<32 then
                            RollTips.show(DescAuto[103]) -- [103]="32级后可进行回复，请努力提升等级！"
                        else
                            local atStr = ChatModel:getCurAtMsgStr()
                            if atStr~=""  then
                                RollTips.show(DescAuto[104]) -- [104]="无法同时@多人"
                            else
                                local longTouchKey = string.format("%s_%s", chatData.fromPlayer.playerId, chatData.fromPlayer.serverId)
                                local info = {
                                    key = longTouchKey,
                                    playName = chatData.fromPlayer.name,
                                    itemIndex = pos
                                }
                                local str =
                                    string.format(
                                    "<MsgObj>ATOTHER,%s,%s,%s,%s,%s,%s</MsgObj>",
                                    info.key,
                                    info.playName,
                                    info.itemIndex,
                                    self._channelId,
                                    ServerTimeModel:getServerTimeMS(),
                                    chatData.receiveMs
                                )
                                local atText = self.msgInput:getText() .. string.format("@%s", chatData.fromPlayer.name)
                                self.msgInput:setText(atText)
                                ChatModel:setCurinputTextStr(atText)
                                local realText = ChatModel:getCurAtMsgStr() .. str
                                -- string.format("gychatAt_1@%s@%s@%s@", info.key, info.playName, info.itemIndex)
                                ChatModel:setCurAtMsgStr(realText)
                                self._controlC5:setSelectedIndex(1)

                            end
                        end

                    end,
                    1,
                    function(context)
                        printTable(159, "点击结果》》》》》",self.isScrollIng)
                        if  self.isScrollIng==true then
                            return
                        end
                        if isLongTouch == false then
                            local playId = ModelManager.PlayerModel.userid
                            local playerid = chatData.fromPlayer.playerId
                            if playId ~= playerid then
                                --ModelManager.ChatModel:getChatHeadInfo(playerid, serverId)
                                local serverId = chatData.fromPlayer.serverId
                                if
                                    chatData.chatType == ChatModel.ChatType.Crossrealm or
                                        chatData.chatType == ChatModel.ChatType.worldCross
                                 then
                                    ViewManager.open(
                                        "ViewPlayerView",
                                        {
                                            noHideLast = true,
                                            playerId = playerid,
                                            serverId = serverId,
                                            chatNeedBtn = false
                                        }
                                    )
                                else
                                    ViewManager.open(
                                        "ViewPlayerView",
                                        {noHideLast = true, playerId = playerid, serverId = serverId}
                                    )
                                end
                            else
                                RollTips.show(Desc.chat_need_rename1)
                            end
                        end
                        isLongTouch = false
                    end
                )
            end
        end
    end

    -- local msgBg = obj:getChildAutoType("msgBg")
    -- msgBg:setWidth(MATH_MIN(msgLabel:getWidth(), msgLabel:getWidth()))
    -- print(15, "msgHeight")
    -- timeLabel:setX(title:getX() + 20)

    -- local msgHeight =msgLabel:getViewHeight()
    -- local msgBgHeight = msgBg:getViewHeight()
    -- print(15,"msgHeight",msgHeight,";msgBgHeight",msgBgHeight)
    -- msgBg:setHeight(MATH_MAX(msgHeight, msgBgHeight))
    -- if msgHeight > msgBgHeight then
    -- 	obj:setHeight(obj:getHeight()+ msgHeight - 20)
    -- 	msgBg:setHeight( msgHeight )
    -- end
end

function M:showVoiceEff(voiceTime,str)
    local transition =voiceTime:getTransition(str);
   -- LuaLogE(string.format("大于的是当前不法第三播放的item数据%s",str,transition))
    if not tolua.isnull(transition) then
        transition:stop();
        transition:playReverse();
        transition:play(function ()
            self:showVoiceEff(voiceTime,str)
        end)
    end
end

function M:stopVoiceEff(voiceTime,str)
    local transition =voiceTime:getTransition(str);
    LuaLogE(string.format("当前暂停的不法第三的item数据%s",str,transition))
    if not tolua.isnull(transition) then
        transition:stop();
    end
    --transition:playReverse();
end

function M:_addRed(...)
    RedManager.register(
        "V_CHAT_SENDGIFTRED",
        self.btn_gift:getChildAutoType("img_red"),
        ModuleId.ChatGift.id
    )
end

function M:_initEvent(...)
    self._closeBtn1:addClickListener(
        function()
            ViewManager.close("ChatView")
        end
    )

    self._setting:addClickListener(
        function()
            ViewManager.open("ChatSettingView")
        end
    )

    self._btnshare:addClickListener(
        function()
            ViewManager.open("ChatPlayShareView")
        end
    )

    self._openEmoji:addClickListener(
        function()
            --Dispatcher.dispatchEvent(EventType.Chat_SendBanChatState,{tarPlayerId=54604})
            ViewManager.open("ChatFaceView")
        end
    )
    self.openVoiceListener = ChatUtil:createRecordButton(self._openVoice)
    --打开话筒
    self.view:getChild("btn_voiceLayer"):setVisible(false)

    self.btn_copy:addClickListener(
        function()
            -- gy.GYDeviceUtil:setClipboardStr(CardList[index+1].code.."")
            self._controlC5:setSelectedIndex(0)
        end
    )

    self.btn_reply:addClickListener(
        function()
            --gy.GYDeviceUtil:setClipboardStr(CardList[index+1].code.."")
            self._controlC5:setSelectedIndex(0)
        end
    )

    self.copyandreplyCloseBtn:addClickListener(
        function()
            self._controlC5:setSelectedIndex(0)
        end
    )

    self._openFriendView:addClickListener(
        function()
            ModuleUtil.openModule(ModuleId.Friend)
        end
    )

    self._btn_jionguild:addClickListener(
        function()
            ModuleUtil.openModule(ModuleId.Guild, true)
        end
    )

    self._btnnewMsg:addClickListener(
        function()
            self._btnnewMsg:setVisible(false)
            ChatModel:setChatCountNumZero()
            self.chatList = self:getChatData(self._channelId)
            if not self.chatList then
                return
            end
            self._msgList:setNumItems(#self.chatList)
            if self._msgList and not tolua.isnull(self._msgList) then
                self._msgList:scrollToView(#self.chatList - 1, true, false)
            end
            self:setMsgScrollStateNum()
        end
    )

    self._sendBtn:addClickListener(
        --发送按钮
        function()
            if self._channelId == ModelManager.ChatModel.ChatType.NotUse then
                RollTips.show(Desc.chat_need_rename2)
            else
                local isOpen, tipsStr = ChatModel:getChannelIsOpen(self._channelId)
                if isOpen == false then
                    RollTips.show(tipsStr)
                    self.msgInput:setText("")
                    ChatModel:setCurinputTextStr("")
                else
                    local timeIng = ChatModel:getChannelCountTimeTag(self._channelId)
                    if timeIng == true then
                        local time = ChatModel:getChannelCountTime(self._channelId)
                        RollTips.show(time .. Desc.chat_need_rename3)
                    else
                        local text = ChatModel:getCurinputTextStr() --self.msgInput:getText()
                        if text ~= "" then
                            ChatModel.chatCountDownTimeTag[self._channelId] = true
                            -- if #ModelManager.PlayerModel.username > 10 then
                            -- 	RollTips.show(Desc.chat_need_rename)
                            -- 	return
                            -- end
                            --[[if StringUtil.containShieldCharacter(text) then
                                RollTips.show(Desc.chat_sensitive_word)
                                return
                            end--]]
                            local atStr = ChatModel:getCurAtMsgStr()
                            if atStr ~= "" then
                                text = StringUtil.filterString(text)
                                text = GMethodUtil:clearHTML(text)
                                text = atStr .. text
                            else
                                text = StringUtil.filterString(text)
                                text = GMethodUtil:checkThreeStar(text)
                                text = string.gsub(text, "%[", "")
                                text = string.gsub(text, "%]", "")
                                printTable(26, "发送出去的消息", text)
                                text = GMethodUtil:clearHTML(text)
                            end
                            --RPCReq.Shop_CharWorld({msg = text})
                            local playId, serverId, privateName = ModelManager.ChatModel:getServerIdAndPlayerId()
                            printTable(8, "发送出去的消息", playId, serverId)
                            -- if tonumber(ModelManager.PlayerModel.level) >= 30 then
                            ModelManager.ChatModel:sendMsg(playId, self._channelId, text, serverId, 9)
                            ChatModel:requestPhPStr(playId, privateName, "", text, self._channelId)
                            -- else
                            --RollTips.show("达到30级才可发言")
                            -- end
                            self.msgInput:setText("")
                            ChatModel:setCurinputTextStr("")
                            ChatModel:setCurAtMsgStr("")
                        end
                    end
                end
            end
        end
    )

    self.btn_gift:addClickListener(
        function()
            local playerId= ChatModel.sendGiftPlayer.playerId
            ChatModel:openGiftView(1,ChatModel.sendGiftPlayer,playerId)
        end
    )

end

function M:update_chatFace(_, faceTxt)
    printTable(6, "打印的表情", faceTxt)
    if self._channelId ~= ModelManager.ChatModel.ChatType.NotUse then
        if self.msgInput then
            local isOpen, tipsStr = ChatModel:getChannelIsOpen(self._channelId)
            if isOpen == false then
                RollTips.show(tipsStr)
                self.msgInput:setText("")
                ChatModel:setCurinputTextStr("")
            else
                local timeIng = ChatModel:getChannelCountTimeTag(self._channelId)
                if timeIng == true then
                    local time = ChatModel:getChannelCountTime(self._channelId)
                    RollTips.show(time .. Desc.chat_need_rename3)
                else
                    if math.floor(tonumber(faceTxt) / 100) > 2 then
                        local playId, serverId = ModelManager.ChatModel:getServerIdAndPlayerId()
                        ModelManager.ChatModel:sendMsg(playId, self._channelId, "{/" .. faceTxt .. "}", serverId, 9)
                        ChatModel:requestPhPStr(playId, "", "", "{/" .. faceTxt .. "}", self._channelId)
                    else
                        self.msgInput:setText(self.msgInput:getText() .. "{/" .. faceTxt .. "}")
                        ChatModel:setCurinputTextStr(self.msgInput:getText())
                    end
                end
            end
        end
    end
end

function M:update_chatClientOpenViewByChannelId(_, chatType)
    ChatModel:setChannelIndex({chatType = chatType})
    local defaultId = ChatModel:getChannelIndex()
    if tolua.isnull(self._channelList) then
        return
    end
    if chatType==8 then--私聊特殊处理
        else
            self._channelList:setSelectedIndex(defaultId - 1)
            self._controlC2:setSelectedIndex(0)
            self._controlC3:setSelectedIndex(0)
            self._channelId = chatType
            ChatModel:setCurChannelId(chatType)
            self:initChatTxtList(self._channelId)
    end
   
end


function M:update_chatClientPrivteOpenView(_, playerInfo)
    ChatModel:setChannelIndex({chatType = 8})
    local defaultId = ChatModel:getChannelIndex()
    if tolua.isnull(self._channelList) then
        return
    end
    self._channelList:setSelectedIndex(defaultId - 1)
    printTable(6, "点击了私聊按钮", playerInfo)
    -- for i = 1, 4 do
    --     if tolua.isnull(self._channelList) then
    --         return
    --     end
    --     local listItem = self._channelList:getChildAt(i - 1)
    --     if i == 4 then
    --         listItem:setSelected(true)
    --     else
    --         listItem:setSelected(false)
    --     end
    -- end
    if ChatModel.chatPrivateTag == false then
        ChatModel.chatPrivateTag = true
        ChatModel:GetHistoryPrivateContentRecord()
    end
    ModelManager.ChatModel:setPrivateClientInfo(playerInfo, nil)
    self._controlC2:setSelectedIndex(0)
    self._controlC3:setSelectedIndex(1)
    self._channelId = ModelManager.ChatModel.ChatType.Private
    ChatModel:setCurChannelId(ModelManager.ChatModel.ChatType.Private)
    local playId = playerInfo.playerId
    local serverId = playerInfo.serverId
    ModelManager.ChatModel:setServerIdAndPlayerId(playId, serverId)
    self:initChatPrivateList()
end

function M:update_chatClientGuildOpenView(_, playerInfo)
    printTable(6, "点击了公会", playerInfo)
    ChatModel:setChannelIndex({chatType = 4})
    local defaultId = ChatModel:getChannelIndex()
    if tolua.isnull(self._channelList) then
        return
    end
    self._channelList:setSelectedIndex(defaultId - 1)
    -- for i = 1, 4 do
    --     if tolua.isnull(self._channelList) then
    --         return
    --     end
    --     local listItem = self._channelList:getChildAt(i - 1)
    --     if i == 3 then
    --         listItem:setSelected(true)
    --     else
    --         listItem:setSelected(false)
    --     end
    -- end
    self._controlC2:setSelectedIndex(0)
    self._controlC3:setSelectedIndex(0)
    self._channelId = ModelManager.ChatModel.ChatType.Guild
    ChatModel:setCurChannelId(ModelManager.ChatModel.ChatType.Guild)
    -- local playId = ModelManager.PlayerModel.userid
    -- local serverId = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
    -- ModelManager.ChatModel:setServerIdAndPlayerId(playId, serverId)
    -- local str='万能的会友啊~来个手气好的小伙伴帮我提升一下手气吧~' ..'<MsgObj>DIVINATION,'..playId..','..serverId..'</MsgObj>'--'<MsgObj>ITEM,10000004,100</MsgObj>'
    -- ModelManager.ChatModel:sendMsg(playId, self._channelId, str, serverId, 9)
    self:initChatTxtList(self._channelId)
end

--分享
function M:update_chatClientCardShareOpenView(_, playerInfo)
    if not playerInfo or not playerInfo.cardUuid then
        return
    end
    local playId = ModelManager.PlayerModel.userid
    local serverId = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
    local str =
        "<MsgObj>SHARECARD," ..
        playerInfo.cardId ..
            "," ..
                playerInfo.cardUuid ..
                    "," .. (playerInfo.cardStar or 1) .. "," .. playId .. "," .. serverId .. "</MsgObj>"
    if (playerInfo.rank) then
        str =
            "<MsgObj>SHARECARD," ..
            playerInfo.cardId ..
                "," ..
                    playerInfo.cardUuid ..
                        "," ..
                            (playerInfo.cardStar or 1) ..
                                "," .. playId .. "," .. serverId .. "," .. playerInfo.rank .. "</MsgObj>"
    end
    --'<MsgObj>ITEM,10000004,100</MsgObj>'
    local playId, serverId = ModelManager.ChatModel:getServerIdAndPlayerId()
    ModelManager.ChatModel:sendMsg(playId, self._channelId, str, serverId, 9)
    ChatModel:requestPhPStr(playId, "", "", str, self._channelId)
end

--玩家战绩视频分享
function M:update_chatClientVideoShareOpenView(_, playerInfo)
    if not playerInfo then
        return
    end
    local playId = ModelManager.PlayerModel.userid
    local serverId = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
    local str =
        string.format(
        "<MsgObj>SHAREVIDEO,%s,%s,%s,%s,%s,%s</MsgObj>",
        playerInfo.playName,
        playerInfo.enemyName,
        playerInfo.gamePlayType,
        playerInfo.fromBattleRecordType,
        playerInfo.recordId,
        playerInfo.serverId
    ) --"<MsgObj>SHAREVIDEO," .. playerInfo.name .. "," .. playerInfo.gamePlayType .. "," .. playerInfo.recordId .. "</MsgObj>"
    ModelManager.ChatModel:sendMsg(playId, playerInfo.chatType, str, serverId, 9)
    ChatModel:requestPhPStr(playId, "", "", str, self._channelId)
    local defaultId = ChatModel:getChannelIndex()
    if tolua.isnull(self._channelList) then
        return
    end
    self._channelList:setSelectedIndex(defaultId - 1)
    self._channelId = playerInfo.chatType
    ChatModel:setCurChannelId(playerInfo.chatType)
end

--玩家角色名分享
function M:update_chatClientRoleNameShareOpenView(_, playerInfo)
    if not playerInfo then
        return
    end
    local playId = ModelManager.PlayerModel.userid
    local serverId = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
    local str = "<MsgObj>SHAREROLENAME," .. playerInfo.name .. "," .. playId .. "," .. serverId .. "</MsgObj>"
    local playId, serverId = ModelManager.ChatModel:getServerIdAndPlayerId()
    ModelManager.ChatModel:sendMsg(playId, ChatModel.ChatType.World, str, serverId, 9)
    ChatModel:requestPhPStr(playId, "", "", str, ChatModel.ChatType.World)
    local defaultId = ChatModel:getChannelIndex()
    if tolua.isnull(self._channelList) then
        return
    end
    self._channelList:setSelectedIndex(defaultId - 1)
    self._channelId = ModelManager.ChatModel.ChatType.World
    ChatModel:setCurChannelId(ModelManager.ChatModel.ChatType.World)
end

function M:update_chatClientPrivteInfo(_, playerInfo)
    local playId, serverId = ModelManager.ChatModel:getServerIdAndPlayerId()
    ChatModel.sendGiftPlayer["playerId"]=playId
    ChatModel.sendGiftPlayer["serverId"]=serverId
    printTable(18, "获取私聊聊天记录11", playId, serverId)
    if playId ~= ModelManager.PlayerModel.userid then
        local playerKey = playId .. "_" .. serverId
        local txtArr = ModelManager.ChatModel.privateChatList
        if tolua.isnull(self.view) or tolua.isnull(self._listPrivate) then
            return
        end
        local obj = self._listPrivate:getChildAutoType("privateListObj" .. playerKey)
        if obj then
            for key, value in pairs(ChatModel.privateChatRedstate) do
                local obj = self._listPrivate:getChildAutoType("privateListObj" .. key)
                local red = ChatModel.privateChatRedstate[key] or false
                if obj then
                    obj:getChildAutoType("img_red"):setVisible(value)
                end
            end
            local toPlayer = txtArr[playerKey].toPlayer
            local playItem = obj:getChild("com_PlayerInfo")
            local txtLine = playItem:getChildAutoType("txt_line")
            local isLine = ColorUtil.formatColorString1(Desc.chat_need_rename4, ColorUtil.itemColorStr[1])
            if toPlayer.online == true then
                isLine = ColorUtil.formatColorString1(Desc.chat_need_rename5, ColorUtil.itemColorStr[2])
            end
            txtLine:setText(isLine)
        end
        self.chatPrivateList =self:getPrivateData(txtArr[playerKey].strArr or {}) 
        printTable(18, ">>>>|||设置的数据11", #self.chatPrivateList)
        self:showPrivateList(self.chatPrivateList)
        self._privateMsgList:scrollToView(#self.chatPrivateList - 1, true, true)
    else
        self:initChatPrivateList()
    end
end

function M:update_deletechatClientPrivteInfo(_, playerInfo)
    local playId, serverId = ModelManager.ChatModel:getServerIdAndPlayerId()
    if playId ~= ModelManager.PlayerModel.userid then
        local playerKey = playId .. "_" .. serverId
        local txtArr = ModelManager.ChatModel.privateChatList
        local obj = self._listPrivate:getChildAutoType("privateListObj" .. playerKey)
        if obj then
            ChatModel:setPrivateChatPlayerRedMs(playerKey)
            obj:getChildAutoType("img_red"):setVisible(false)
            local toPlayer = txtArr[playerKey].toPlayer
            local playItem = obj:getChild("com_PlayerInfo")
            local txtLine = playItem:getChildAutoType("txt_line")
            local isLine = ColorUtil.formatColorString1(Desc.chat_need_rename4, ColorUtil.itemColorStr[1])
            if toPlayer.online == true then
                isLine = ColorUtil.formatColorString1(Desc.chat_need_rename5, ColorUtil.itemColorStr[2])
            end
            txtLine:setText(isLine)
        end
        self.chatPrivateList =self:getPrivateData(txtArr[playerKey].strArr or {}) 
        printTable(18, "刷新啥车速度符", #self.chatPrivateList)
        self._privateMsgList:setNumItems(#self.chatPrivateList)
        -- if #self.chatPrivateList > 6 then
        --     self._privateMsgList:scrollToView(#self.chatPrivateList - 1, true, true)
        --     self._privateMsgList:refreshVirtualList()
        -- end
        self._privateMsgList:scrollToView(#self.chatPrivateList - 1, true, true)
    else
        printTable(18, "刷新啥车速度符111", #self.chatPrivateList)
        self.chatPrivateList = {}
        self._privateMsgList:setNumItems(0)
        self:initChatPrivateList()
    end
end

function M:update_chatInfo(_, copytype)
    ChatModel:setChatCountNum()
    self.chatList = self:getChatData(self._channelId)
    if not self.chatList then
        return
    end
    self:upAtMeList()
  --  if __ENGINE_VERSION__ < 3 then
        if #self.chatList == 50 then
            self._msgList:removeChildrenToPool()
        end
   -- end
    if self.scrollStateTag == true then --在查看历史消息状态
        self._btnnewMsg:setVisible(true)
        local num = ChatModel:getChatCountNum()
        if num >= 99 then
            self._btnnewMsg:getChildAutoType("title"):setText(Desc.chatView_str23)
        else
            self._btnnewMsg:getChildAutoType("title"):setText(string.format(Desc.chatView_str24, num))
        end
    else
        ChatModel:setChatCountNumZero()
        self._btnnewMsg:setVisible(false)
    end
    printTable(155, "刷新聊天列表", #self.chatList, self.scrollStateTag)
    self._msgList:setNumItems(#self.chatList)
    if self.scrollStateTag == false then
        if self._msgList and not tolua.isnull(self._msgList) then
            self._msgList:scrollToView(#self.chatList - 1, true, false)
        end
        self:setMsgScrollStateNum()
    end

    -- self._updateTimeId  = Scheduler.scheduleOnce(3.0,function()
    --     printTable(152, "刷新聊天列表")
    --     self._updateTimeId = false
    --     self._msgList:getScrollPane():scrollBottom()
    -- end)
    -- if #self.chatList > 6 then
    --     -- local item =self.chatList:getChildAt(#self.chatList - 1)
    --     -- self._msgList:getScrollPane():scrollToView(item, true, true)
    --     --self._msgList:getScrollPane():scrollBottom()
    -- end
end

function M:NextFramescroll()
    if self._msgList and not tolua.isnull(self._msgList) then
        self._msgList:scrollToView(#self.chatList - 1, true, false)
    end
end

function M:unregister_edibox(...)
    self.msgInput:unRigisterEdibox()
end

function M:chat_voicePlay_end(e, cbFileName)
    ChatSpeechUtil:setCurPlaying(false)
end

--页面退出时执行
function M:_exit(...)
    --	self.itemcellArrs = {}
    print(1, "ChatView _exit")
    if self.openVoiceListener then
        self._openVoice:displayObject():getEventDispatcher():removeEventListener(self.openVoiceListener)
    end
    if (ModelManager.ChatModel) then
        ModelManager.ChatModel:setCurrentOpenChannel(0)
    end
    ChatModel:setPrivateChatRedMsForFile()
    ChatModel:setAtMeMsgInfoForFile()
    local atStr = ChatModel:getCurAtMsgStr()
    if atStr ~= "" then
        ChatModel:setCurinputTextStr("")
        ChatModel:setCurAtMsgStr("")
    end

    --写入文件
end

return M
