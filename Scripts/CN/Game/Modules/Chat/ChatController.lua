local ChatController = class("ChatController", Controller)
local ChatObjType = require "Game.Consts.ChatObjType"

function ChatController:init()
    LuaLogE("ChatController init")
    gy.GYStringUtil:loadFilterData("Filter/filter.data", false)
end

function ChatController:Chat_ChatMsg(_, args)
    printTable(158, "服务器发送过来的消息", args)
    if args.infos then
        if ChatModel.loginHistoryState == false then --登录协议下发状态有没有下发
            ChatModel:initAtMeMsgInfo()
            for k, v in pairs(args.infos) do
                table.insert(ChatModel.loginHistoryInfoMap, v)
            end
        else
            -- TableUtil.sortByMap(args.infos, {{key = "receiveMs", asc = false}})
            for k, v in pairs(args.infos) do --遍历频道，把消息插到相应的频道
                printTable(153, "服务器发送过来的消息", v.receiveMs, v.content)
                ChatModel:reviceData(v)
            end
        end
    end
    Dispatcher.dispatchEvent(EventType.update_chatInfo)
end

function ChatController:BattleRecord_PlayerInfo(_, args)
    ChatModel:setAddLikeData(args.likesRecords)
end

function ChatController:update_chatClientPrivte(_, args)
    if not args or not args.level then
        return
    end
    local roleLv = PlayerModel.level
    if args.level then
        local configInfo = DynamicConfigData.t_Channel[8]
        if roleLv < configInfo.level then
            RollTips.show(string.format(Desc.CohesionReward_str1, configInfo.level))
            return
        elseif args.level < configInfo.level then
            RollTips.show(string.format(Desc.CohesionReward_str2, configInfo.level))
            return
        end
    end
    ViewManager.open(
        "ChatView",
        nil,
        function(arg, arg2)
            Dispatcher.dispatchEvent(EventType.update_chatClientPrivteOpenView, args)
        end
    )
    -- local isShow = ViewManager.isShow("ChatView")
    -- if isShow == false then
    --     ViewManager.open(
    --         "ChatView",
    --         nil,
    --         function(arg, arg2)
    --             Dispatcher.dispatchEvent(EventType.update_chatClientPrivteOpenView, args)
    --         end
    --     )
    --     return
    -- end
    -- Dispatcher.dispatchEvent(EventType.update_chatClientPrivteOpenView, args)
end


function ChatController:update_openChatClientChannelId(_, ChannelId)
    ViewManager.open(
        "ChatView",
        nil,
        function(arg, arg2)
            Dispatcher.dispatchEvent(EventType.update_chatClientOpenViewByChannelId, ChannelId)
        end
    )
end


function ChatController:update_chatClientGuildDivination(_, args) --公会占卜
    local isShow = ViewManager.isShow("ChatView")
    if isShow == false then
        ViewManager.open(
            "ChatView",
            nil,
            function(arg, arg2)
                Dispatcher.dispatchEvent(EventType.update_chatClientGuildOpenView, args)
            end
        )
        return
    end
    Dispatcher.dispatchEvent(EventType.update_chatClientGuildOpenView, args)
end

function ChatController:update_chatClientCardShare(_, args) --分享
    local isShow = ViewManager.isShow("ChatView")
    if isShow == false then
        ViewManager.open(
            "ChatView",
            nil,
            function(arg1, arg2)
                Dispatcher.dispatchEvent(EventType.update_chatClientCardShareOpenView, args)
            end
        )
        return
    end
    Dispatcher.dispatchEvent(EventType.update_chatClientCardShareOpenView, args)
end

function ChatController:update_chatClientRoleNameShare(_, args) --玩家角色名分享
    local isShow = ViewManager.isShow("ChatView")
    if isShow == false then
        ViewManager.open(
            "ChatView",
            nil,
            function(arg1, arg2)
                Dispatcher.dispatchEvent(EventType.update_chatClientRoleNameShareOpenView, args)
            end
        )
        return
    end
    Dispatcher.dispatchEvent(EventType.update_chatClientRoleNameShareOpenView, args)
end

function ChatController:update_chatClientVideoShare(_, args) --视频分享
    printTable(5656, "视频分享", args)
    if not args or not args.recordInfo then
        return
    end
    ViewManager.open(
        "ChatView",
        nil,
        function(arg1, arg2)
            Dispatcher.dispatchEvent(EventType.update_chatClientVideoShareOpenView, args.recordInfo)
        end
    )
end

function ChatController:chat_sendVoiceMsg(e, params)
    -- local params={
    --      fileName ="yuanfeng",
    --      audioID =  "group1/M00/00/0A/rB8wFlhvKBuAbO9gAAARnSqnxBU9305332",
    --      requestId = "yuanfeng123",
    --      content = "你可真优秀",
    --      channelType = 2,
    --      toPlayerId = ModelManager.PlayerModel.userid
    -- }
    if DeviceUtil.getNetworkStatus() == gy.NETWORK_STATUS_NOT_CONNECTED or Cache.networkCache.__IN_RELINK then
        RollTips.show(DescAuto[60]) -- [60]="网络连接已断开,无法发送语音"
        return
    end
    local fileName = params.fileName or ""
    local audioID = params.audioID
    local requestId = params.requestId
    local content = params.content
    local channelType = params.channelType
    local toPlayerId = params.toPlayerId
    local audioLen = ChatSpeechUtil:getSpeechFileLen(fileName)
    local realText = string.format("gyjz2_v@%s@%s@%s@%s@%s", fileName, requestId, audioID, audioLen, content)
    local playId, serverId = ModelManager.ChatModel:getServerIdAndPlayerId()
    local _channelId = ChatModel.curChannelId
    ModelManager.ChatModel:sendMsg(playId, _channelId, realText, serverId, 9)
end

-- fromPlayer	1:PChat_PlayerInfo
-- 		content		2:string
-- 		items 		3:*PItem_Item 			#发送的物品
-- 		cheatMark 	4:integer				#诈骗标记
-- 		receiveMs	5:integer				#时间
-- 		exInfo 		6:*string 				#广播中携带的一些字符串信息
function ChatController:Chat_PrivateAccept(_, args)
    printTable(157, "服务器发送过来的私聊消息", args)
    local playerInfo = {}
    playerInfo = args.fromPlayer
    local textArr = {}
    textArr["fromPlayer"] = args.fromPlayer
    textArr["content"] = args.content
    textArr["receiveMs"] = args.receiveMs
    ChatModel:getPrivateChatRedMs(playerInfo.playerId .. "_" .. playerInfo.serverId, args.receiveMs)
    ModelManager.ChatModel:setPrivateClientInfo(playerInfo, textArr)
    ChatModel:setChannelIndex({chatType = 8})
    Dispatcher.dispatchEvent(EventType.update_chatClientPrivteInfo)
end

--登录的历史消息
function ChatController:Chat_LoginHistoryMsg(_, args)
    printTable(158, "登录的历史消息", args)
    ChatModel:initAtMeMsgInfo()
    if args.infos then
        for k, v in pairs(args.infos) do
            for key, value in pairs(v.infos) do
                if value.receiveMs then
                    table.insert(ChatModel.loginHistoryInfoMap, value)
                end
            end
        end
        ChatModel.loginHistoryState = true
        --登录协议下发状态有没有下发
        TableUtil.sortByMap(ChatModel.loginHistoryInfoMap, {{key = "receiveMs", asc = false}})
        printTable(154, "服务器发送过来的登录的历史消息", ChatModel.loginHistoryInfoMap)
        for k, v1 in pairs(ChatModel.loginHistoryInfoMap) do
            ChatModel:reviceData(v1)
        end
    end
end

function ChatController:Chat_ResponseDropRecord(_, args)
    printTable(6, "服务器发送过来的ResponseDropRecord", args)
end

--告诉客户端有没有离线消息
function ChatController:Chat_SendHadOfflinePrivateMsg(_, args)
    printTable(6, "服务器发送过来的告诉客户端有没有离线消息", args)
end

--#客户端把所有的 发送者为这个id的玩家信息删除
function ChatController:Chat_SendBanChatState(_, args)
    if args.tarPlayerId then
        for k, v in pairs(ChatModel.chanelList) do
            local arr = {}
            local channelType = v.channelType
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
             if channelType~= ModelManager.ChatModel.ChatType.System and channelType ~= ModelManager.ChatModel.ChatType.NotUse then
                for i = #arr,1, -1 do
                    local chatItem = arr[i]
                    if chatItem and chatItem.fromPlayer and chatItem.fromPlayer.playerId == args.tarPlayerId then
                        table.remove(arr, i)
                    end
                end
             end
        end

        local txtArr = ModelManager.ChatModel.privateChatList
        for key, value in pairs(txtArr) do
            local prinvateInfo = txtArr[key]
            local privateInfolist = prinvateInfo.strArr or {}
            for j = #privateInfolist,1 , -1 do
                local privateChatItem = privateInfolist[j]
                if privateChatItem==nil then
                    printTable(159,"ssssss",j)
                end
                if privateChatItem and privateChatItem.fromPlayer and privateChatItem.fromPlayer.playerId == args.tarPlayerId then
                    table.remove(privateInfolist, j)
                end
            end
        end
            for i = # ChatModel.battleChatList,1, -1 do
                local chatItem =  ChatModel.battleChatList[i]
                if chatItem and chatItem.fromPlayer and chatItem.fromPlayer.playerId == args.tarPlayerId then
                    table.remove( ChatModel.battleChatList, i)
                end
            end
        Dispatcher.dispatchEvent(EventType.chat_jingyan_updataInfo,args.tarPlayerId)
        Dispatcher.dispatchEvent(EventType.update_chatClientPrivteInfo)
        Dispatcher.dispatchEvent(EventType.update_chatInfo)
    end
end

-- 手动注册方法
function ChatController:_initListeners()
    LuaLogE("ChatController_initListeners")

    Dispatcher.addEventListener(RecvType.Shop_SendChatWoldMsg, self)
end

function ChatController:Shop_SendChatWoldMsg(_, args)
    -- LuaLogE("Shop_SendChatWoldMsg")
    ChatModel:pushChatData(args)
    Dispatcher.dispatchEvent(EventType.update_chat)
end

function ChatController:Relationship_UpdateGiftRecord(_, args)--#赠礼记录
    if args and args.giftRecords then
        ChatModel:setReciveGiftList(args.giftRecords)
    end
    Dispatcher.dispatchEvent(EventType.update_upChatGiftGiftRecord)
end

function ChatController:Relationship_UpdateGiftTimes(_, args)--#接收次数
    if args then
        ChatModel:setRecivegiftTime(args)
        Dispatcher.dispatchEvent(EventType.update_upChatGiftTimes) 
    end
end

--聊天里面超链接点击
function ChatController:chat_clickLink(evt, data)
    if (data.type == ChatObjType.ITEMLIST) then
        printTable(12, "asdf>>>>>", data)
        local itemData = ItemsUtil.createItemData({data = {code = data.itemCode, type = data.itemType}})
        ViewManager.open("ItemTips", {winType = 0, codeType = data.itemType, id = data.itemCode, data = itemData})
    elseif (data.type == ChatObjType.ITEM) then
        local itemData = ItemsUtil.createItemData({data = {code = data.itemCode, type = data.itemType}})
        ViewManager.open("ItemTips", {winType = 0, codeType = data.itemType, id = data.itemCode, data = itemData})
    elseif (data.type == ChatObjType.PLAYER) then
        local playId = ModelManager.PlayerModel.userid
        local playerid = data.playerId
        if playId ~= playerid then
            local serverId = data.serverId
            --ModelManager.ChatModel:getChatHeadInfo(playerid, serverId)
            ViewManager.open("ViewPlayerView", {noHideLast = true, playerId = playerid, serverId = serverId})
        else
            RollTips.show(Desc.CohesionReward_str3)
        end
    elseif (data.type == ChatObjType.GUILD) then
    elseif (data.type == ChatObjType.HERO) then
        printTable(29, "herherahesrehrher", data)
        local cardData = DynamicConfigData.t_hero[tonumber(data.itemCode)]
        if not cardData then
            return
        end
        local categoryHeros = DynamicConfigData.t_HeroTotems[cardData.category]
        local _cardInfoList = {}
        for _, v in pairs(categoryHeros) do
            if tonumber(data.itemCode) == v.hero then
                table.insert(_cardInfoList, v)
            end
        end
        ViewManager.open("HeroInfoView", {index = 1, heroId = tonumber(data.itemCode), heroList = _cardInfoList})
    elseif (data.type == ChatObjType.DIVINATION) then
        local playId = data.playerId
        GuildModel:divinationHelpReq(playId)
    elseif data.type == ChatObjType.SHARECARD then
        local cardId = data.cardId
        local cardUid = data.cardUid
        local cardStar = data.cardStar
        local data = {
            playerInfo = {playerId = data.playerId, serverId = data.serverId},
            heroArray = {cardUid},
            index = 1
        }
        Dispatcher.dispatchEvent(EventType.HeroInfo_Show, data)
    elseif data.type == ChatObjType.SHAREROLENAME then
        local heroName = data.heroName
        local playerId = data.playerId
        local serverId = data.serverId
        ViewManager.open("PlayerInfoView", {openType = 1, playerID = playerId, serverID = serverId})
    elseif data.type == ChatObjType.SHAREVIDEO then --分享战绩视频
        ViewManager.open("ShareVideoView", data)
    elseif data.type == ChatObjType.MOUDLEOPEN then --打开模块
        local moduleId = data.moduleId
        ModuleUtil.openModule(moduleId)
    elseif data.type == ChatObjType.GUILDWAR then --打开公会联赛
        ModuleUtil.openModule(ModuleId.GuildLeague.id)
    end
end

function ChatController:chat_autoPlay_pause(e, args) --开始录音时在播放语音的时候停止播放语音
    ChatSpeechUtil:stopPlay()
end

function ChatController:chat_autoPlayQueue_push(e, args)
    --需求：队列满时将不再push 直到队列空
    -- if ChatSpeechUtil:sizeOfAutoPlayQueue() == 0 then
    --     self.__canPushInVoiceAutoplayQueue = true
    -- end
    -- if ChatSpeechUtil:sizeOfAutoPlayQueue() < 20 and self.__canPushInVoiceAutoplayQueue then
    --     args.timeStamp = ModelManager.ServerTimeModel:getServerTimeMS()
    --     ChatSpeechUtil:pushInAutoPlayQueue(args)
    -- else
    --     self.__canPushInVoiceAutoplayQueue = false
    -- end
    -- if ChatSpeechUtil:sizeOfAutoPlayQueue() > 0 then
    --     if ChatSpeechUtil:isVoicePlaying() then
    --         return
    --     end
    --     local topOfQueue = ChatSpeechUtil:topOfAutoPlayQueue()
    --     local fileName = topOfQueue.fileName
    --     ChatSpeechUtil:setVoicePlay(fileName, true)
    --     ChatSpeechUtil:setCurPlaying(fileName)
    --     if topOfQueue.isSelf then
    --         ChatSpeechUtil:startPlaySelf(fileName, false)
    --     else
    --         ChatSpeechUtil:starPlay(fileName, false)
    --     end
    --     Dispatcher.dispatchEvent(EventType.chat_voicePlay_begin, fileName)
    -- end
end

function ChatController:chat_autoPlay_continue(e, args)
    if ChatSpeechUtil:sizeOfAutoPlayQueue() > 0 then
        local topOfQueue = ChatSpeechUtil:topOfAutoPlayQueue()
        local fileName = topOfQueue.fileName
        ChatSpeechUtil:setVoicePlay(fileName, true)
        ChatSpeechUtil:setCurPlaying(fileName)
        if topOfQueue.isSelf then
            ChatSpeechUtil:startPlaySelf(fileName, false)
        else
            ChatSpeechUtil:starPlay(fileName, false)
        end
        Dispatcher.dispatchEvent(EventType.chat_voicePlay_begin, fileName)
    end
end

function ChatController:chat_voicePlay_end(e, cbFileName)
    --如果手动播放的话 删掉播放时间早于它的
    ChatModel.chatVoiceAnim=false
    Dispatcher.dispatchEvent(EventType.update_chatClientPrivteInfo)
    Dispatcher.dispatchEvent(EventType.update_chatInfo)
    LuaLogE("当前暂停的回调文件大师傅",cbFileName)
    for i, v in ipairs(ChatSpeechUtil:getAutoPlayQueue()) do
        if cbFileName == v.fileName then
            for index = 1, i do
                ChatSpeechUtil:popOutAutoPlayQueue()
            end
            break
        end
    end
    if ChatSpeechUtil:sizeOfAutoPlayQueue() > 0 then
        Scheduler.scheduleOnce(
            0.2,
            function()
                local topOfQueue = ChatSpeechUtil:topOfAutoPlayQueue()
                local fileName = topOfQueue.fileName
                ChatSpeechUtil:setVoicePlay(fileName, true)
                ChatSpeechUtil:setCurPlaying(fileName)
                if topOfQueue.isSelf then
                    ChatSpeechUtil:startPlaySelf(fileName, false)
                else
                    ChatSpeechUtil:starPlay(fileName, false)
                end
                Dispatcher.dispatchEvent(EventType.chat_voicePlay_begin, fileName)
            end
        )
    end
end

return ChatController
