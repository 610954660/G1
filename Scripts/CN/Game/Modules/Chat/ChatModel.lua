local BaseModel = require "Game.FMVC.Core.BaseModel"
local ChatModel = class("ChatModel", BaseModel)
local TABLE_INSERT = table.insert
function ChatModel:ctor()
    self.chatList = {}
    self.settingType = {
        friend = 1, -- 设置1
        system = 2, -- 设置2
        world = 3, -- 设置2
        guild = 4, -- 设置3
        crossreal = 5, -- 设置5
        worldCross = 6, -- 设置6
        GodMarket = 7, -- 设置7
    }
    self.ChatType = {
        NotUse = 0, -- 综合
        System = 2 ^ 0, -- 系统频道
        World = 2 ^ 1, -- 世界频道
        Guild = 2 ^ 2, -- 工会频道
        Private = 2 ^ 3, -- 私聊
        Crossrealm = 2 ^ 4, -- 同城
        worldCross = 2 ^ 5, --世界跨服频道
        GodMarket = 2 ^ 6 --神墟
    }
    self.channelInfo = {
        [1] = {messageNum = 80, cacheCCObj = true, channelType = 0, desc = Desc.chatView_str20}, --综合
        [2] = {messageNum = self:getChannelMessageNum(1), cacheCCObj = true, channelType = 1, desc = Desc.chatView_str4}, --系统
        [3] = {messageNum = self:getChannelMessageNum(2), cacheCCObj = true, channelType = 2, desc = Desc.chatView_str5}, --世界
        [4] = {messageNum = self:getChannelMessageNum(4), cacheCCObj = true, channelType = 4, desc = Desc.chatView_str6}, --工会
        [5] = {messageNum = self:getChannelMessageNum(8), cacheCCObj = true, channelType = 8, desc = Desc.chatView_str7}, --私聊
        [6] = {messageNum = self:getChannelMessageNum(8), cacheCCObj = true, channelType = 16, desc = Desc.chatView_str8}, --同城
        [7] = {messageNum = self:getChannelMessageNum(8), cacheCCObj = true, channelType = 32, desc = Desc.chatView_str9}, --跨服
        [8] = {messageNum = self:getChannelMessageNum(8), cacheCCObj = true, channelType = 64, desc = Desc.chatView_str25} --跨服
    }
    self.chanelList = {
        -- [1] = {channelType = 0, desc = Desc.chatView_str20},
        [1] = {channelType = 1, desc = Desc.chatView_str4},
        [2] = {channelType = 2, desc = Desc.chatView_str5},
        [3] = {channelType = 4, desc = Desc.chatView_str6},
        [4] = {channelType = 8, desc = Desc.chatView_str7},
        [5] = {channelType = 16, desc = Desc.chatView_str8},
        [6] = {channelType = 32, desc = Desc.chatView_str15},
		[7] = {channelType = 64, desc = Desc.chatView_str25},
    }
    self.chanelMap = {[2] = 2, [4] = 3, [8] = 4, [16] = 5, [32] = 6, [64] = 7}
    self.sendPlayId = false
    self.sendServerId = false
    self.privateName=false
    self.curChannelId=2
    self.fromPlayTipsInfo = {}
    --点击头像获取数据
    self.chatSetting = {}
    self.synthesizeChatArray = {}
    --综合频道列表
    self.sysChatArray = {} --系统公告列表
    self.worldChatArray = {} --世界聊天列表
    self.guildChatArray = {} --工会聊天列表
    self.privateChatArray = {}
    --私聊列表
    self.diversionsArray = {}
    --跑马灯列表
    self.crossrealmArray = {}
    --同城聊天列表
    self.worldcrossrealmArray = {}
	--神墟聊天列表
	self.godMarketArray = {}
    --跨服聊天列表
    --私聊
    self.privateChatList = {}
    self.privateChatBeforeSevenTime = {}
    self.privateChatupdateTimeId = false
    --私聊
    --私聊聊天列表
    self.chatCountDownTime = {}
    --聊天倒计时
    self.chatCountDownTimeTag = {}
    --聊天倒计时状态
    self.tagInfo = false
    self._updateTimeId = false
    self._currentOpenChannel = 0 --当前打开的是哪个面板（如果是打开的情况下，收到新的消息不需要出现红点）
    self.chatPrivateTag = false
    --请求私聊离线数据
    self.battleChatList = {}
    self.mainchatTime = false
    self:firstLoginchat()
    self._updateTimeId1 = false
    self.selectedDefaultChanelId = 1
    self.curinputTextStr = ""
    self.loginHistoryState = false
    --登录协议下发状态有没有下发
    self.loginHistoryInfoMap = {}
    --登录历史消息保存的数据
    self.chatCountNum = 0 --聊天数
    self.serverListName = {} --服务器名称

    self.privateChatRedMs={}--前端保存服务器私聊消息时间做红点显示
    self.privateChatRedstate={}--前端保存服务器私聊消息时间做红点显示
    self.curprivateChatRedKey=false--前端保存服务器私聊消息时间做红点显示

   
    self.chatBannedtoPostList={} --被后台禁言的玩家的Id列表
    self.chatBannedtoPostState=false --被后台禁言的玩家刷新状态

	self.arenaRecordData={}--录像数据

	
	self.videoBattleData={}--

	
	
	self.addLikeData={}--
    
    self.curAtMsgStr=""--当前@的真实信息
    self.curCopyMsgStr={}--当前回复的信息
    self.curTouchCopyMsg={}--当前点击的@按钮
    self.chatVoiceAnim=false
    self.faceConfigTable={}

    self.recivegiftTime={}--接收礼物和赠送次数
    self.reciveGiftList={}--受赠礼物列表
    self.sendGiftPlayer={}--受赠礼物玩家
end

function ChatModel:init()
 
end

function ChatModel:initFaceConfig()
    local map=DynamicConfigData.t_Emoji
    for key, value in pairs(map) do
        for k, v in pairs(value) do
            self.faceConfigTable[v.emojiRes]=v
        end
    end
end

function ChatModel:requestPhPStr(toPlayerId, toRoleName, chatTime,msgStr,chatType,chatTypeName)
    local typeName=DescAuto[61] -- [61]="世界"
    for key, value in pairs(self.chanelList) do
      if value.channelType==chatType then
            typeName=  value.desc
      end
    end
    PHPUtil.reportChat(toPlayerId,toRoleName, ServerTimeModel:getServerTime(),msgStr,chatType,typeName)
end

function ChatModel:setCurAtMsgStr(str)
    self.curAtMsgStr=str
end

function ChatModel:getCurAtMsgStr()
    return self.curAtMsgStr
end

function ChatModel:setCurCopyMsgStr(info)--设置当前回复的信息
    local channel=tonumber(info.channel) 
    local map=self.curCopyMsgStr[channel]
    if not map then
        map={}
    end
    local onlyKey=info.key.."_"..info.itemIndex.."_"..info.ms
    if not self.curTouchCopyMsg[onlyKey] then
        map[onlyKey]=info
    end
    self.curCopyMsgStr[channel]=map
end

function ChatModel:getCurCopyMsgStr(channel)
    return  self.curCopyMsgStr[channel] or {}
end

function ChatModel:deleteCurCopyMsgStr(channel,key)
    local map=self.curCopyMsgStr[channel]
    if not map then
        map={}
    end
    map[key]=nil
    self.curCopyMsgStr[channel]=map
    self.curTouchCopyMsg[key]=true
end

function ChatModel:setAtMeMsgInfo(chatData)
    self:paraseAtObj(chatData.content)
    -- local isAtOther, content, AtArr=self:isAtOtherItem(chatData)--是否是@item
    -- if isAtOther==true then
    --     local arr=StringUtil.lua_string_split(AtArr[2], "_")
    --     local playerId=arr[1]
    --     local servserId=arr[2]
    --     local myserverId = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
    --     local myPlayerId=ModelManager.PlayerModel.userid
    --     if tonumber(playerId)==myPlayerId and tonumber(servserId)==myserverId then
    --         local info = {
    --             key = AtArr[2],
    --             playName = AtArr[3],
    --             itemIndex = AtArr[4],
    --             channel = chatData.chatType,
    --             ms=chatData.receiveMs
    --         }
    --         self:setCurCopyMsgStr(info)
    --     end
    -- end
end

function ChatModel:initAtMeMsgInfo()
    local userId=0
    if PlayerModel and PlayerModel.userid then
        userId=PlayerModel.userid
    end 
    local time=string.format("%s%s",FileDataType.AtMEMSGINFO,userId)
    local sevenTimeId= FileCacheManager.getStringForKey(time, "", nil, true)
   if sevenTimeId~= "" then
        local sevenTimeInfo = json.decode(sevenTimeId)
        self.curTouchCopyMsg=sevenTimeInfo
        else
        self.curTouchCopyMsg={}  
    end
end

function ChatModel:setAtMeMsgInfoForFile()
    local userId=0
    if PlayerModel and PlayerModel.userid then
        userId=PlayerModel.userid
    end 
    local time= string.format("%s%s",FileDataType.AtMEMSGINFO,userId)
    FileCacheManager.setStringForKey(time, json.encode(self.curTouchCopyMsg), nil, true)
end



function ChatModel:initPrivateChatRedMs()
    local userId=0
    if PlayerModel and PlayerModel.userid then
        userId=PlayerModel.userid
    end
    local time=string.format("%s%s",FileDataType.PRIVATECHAT_REDTIME,userId)
    local sevenTimeId= FileCacheManager.getStringForKey(time, "", nil, true)
   if sevenTimeId~= "" then
        local sevenTimeInfo = json.decode(sevenTimeId)
        self.privateChatRedMs=sevenTimeInfo
        else
        self.privateChatRedMs={}  
    end
end

function ChatModel:setPrivateChatRedMsForFile()
    local userId=0
    if PlayerModel and PlayerModel.userid then
        userId=PlayerModel.userid
    end
    local time= string.format("%s%s",FileDataType.PRIVATECHAT_REDTIME,userId)
    FileCacheManager.setStringForKey(time, json.encode(self.privateChatRedMs), nil, true)
end

function ChatModel:setPrivateChatRedMs(key,time)
    if not self.privateChatRedMs[key] then
        self.privateChatRedMs[key]=time
    end
    self:getPrivateChatRedMs(key,time)
end

function ChatModel:setPrivateChatPlayerRedMs(key)
    self.curprivateChatRedKey=key
    local time=ServerTimeModel:getServerTimeMS()
    self.privateChatRedMs[key]=time
    self:getPrivateChatRedMs(key,time)
end

function ChatModel:getPrivateChatRedMs(key,time)
    local red=false
     local oldtime= self.privateChatRedMs[key]
     if not oldtime and not self.curprivateChatRedKey then
        red=true 
     end
    if oldtime and self.curprivateChatRedKey~=key and oldtime<time then
        red=true
    end
    self.privateChatRedstate[key]=red
end

function ChatModel:getgamePlaytypeStr(gamePlaytype)
    local str=Desc.chat_playertypestr1
    if gamePlaytype==GameDef.GamePlayType.Arena then
        str=Desc.chat_playertypestr1
    elseif gamePlaytype==GameDef.GamePlayType.HigherPvp then
		str=Desc.chat_playertypestr2
	elseif gamePlaytype==GameDef.GamePlayType.WorldArena then
		str=Desc.chat_playertypestr3
	elseif gamePlaytype==GameDef.GamePlayType.WorldSkyPvp then
		str=Desc.chat_playertypestr4
	end
    return  ColorUtil.formatColorString1(str,"#1988c8") 
end

function ChatModel:getChatCountNum()
    return self.chatCountNum
end

function ChatModel:setChatCountNum()
    self.chatCountNum = self.chatCountNum + 1
end

function ChatModel:setChatCountNumZero() --重置为0
    self.chatCountNum = 0
end

-- function ChatModel:setLoginServerName() --聊天服务器数据
--     --local serverInfo = LoginModel:getLoginServerInfo()
--     local serverGroups = LoginModel:getServerGroups()
--     for key, serverInfo in pairs(serverGroups) do
--         for k, serverInfo1 in pairs(serverInfo) do
--             self.serverListName[serverInfo1.unit_server] = serverInfo1
--         end
--     end
-- end

-- function ChatModel:getLoginServerName(servserId) --聊天服务器数据
--     local str = ""
--     local serverInfo = self.serverListName[servserId]
--     if serverInfo then
--         str = serverInfo.name
--     end
--     return str
-- end

function ChatModel:getPositionName(province, cityId) --聊天省份位置
    -- local str = ""
    -- if not province or not cityId then
    --     return str
    -- end
    -- local array = DynamicConfigData.t_provinces[province]
    -- if not array then
    --     return str
    -- end
    -- str = array[1].provinces
    -- if not array[cityId] then
    --     return str
    -- end
    -- str = str .. array[cityId].city
    -- return str
    local str = ""
    if province==0 then
        province=1
    end
    if not province or not cityId then
        return str
    end
    local array = DynamicConfigData.t_provinces[province]
    if not array then
        return str
    end
    str = array[1].provinces
    return str
end

function ChatModel:setCurinputTextStr(str)
    self.curinputTextStr = str
end

function ChatModel:getCurinputTextStr()
    return self.curinputTextStr
end

function ChatModel:setChannelIndex(chatData)
    local channelId = 1
    if chatData and chatData.contentId ~= nil then
        local configInfo = DynamicConfigData.t_boardingMsg[tonumber(chatData.contentId)]
        if not configInfo then
            return
        end
        local value = configInfo.channels[1]
        if value == 2 then
            channelId = 4
        end
    else
        channelId = chatData.chatType
    end
    printTable(152, "11111111111111111222222", channelId, self.selectedDefaultChanelId)
    if self.chanelMap[channelId] == nil then
        self.selectedDefaultChanelId = 2
        return
    end
    self.selectedDefaultChanelId = self.chanelMap[channelId]
    printTable(152, "11111111111111111222222", channelId)
end

function ChatModel:getChannelIndex()
    if self.selectedDefaultChanelId == nil then
        return 1
    end
    return self.selectedDefaultChanelId
end

function ChatModel:firstLoginchat()
    self._updateTimeId1 =
        Scheduler.scheduleOnce(
        3,
        function()
            if #self.synthesizeChatArray == 0 then
                local v = {}
                v.showArea = 4
                v.exInfo = {}
                v.guildId = 820
                v.contentId = 1030002
                v.chatType = 1
                v.receiveMs = ModelManager.ServerTimeModel:getServerTime()
                self:reviceData(v)
            end
            self._updateTimeId1 = false
        end
    )
end

function ChatModel:getShareAllCards()
    local temp = {}
    for category, groupInfos in pairs(CardLibModel.__heroInfos) do
        for k, v in pairs(CardLibModel.__heroInfos[category]) do
            temp[#temp + 1] = v
        end
    end
    TableUtil.sortByMap(temp, {{key = "level", asc = true}, {key = "star", asc = true}, {key = "code", asc = false}})
    return temp
end

function ChatModel:getDiversionsArray()
    return self.diversionsArray
end

function ChatModel:setChannelCountTime()
    self._updateTimeId =
        Scheduler.schedule(
        function()
            for key, value in pairs(self.chatCountDownTime) do
                printTable(11, "dsafweqr", self.chatCountDownTime[key])
                self.chatCountDownTime[key] = self.chatCountDownTime[key] - 1
                if self.chatCountDownTime[key] <= 0 then
                    self.chatCountDownTime[key] = 0
                    self.chatCountDownTimeTag[key] = false
                    self:clearChannelCountTime()
                end
            end
        end,
        1,
        0
    )
end

function ChatModel:clearChannelCountTime()
    local clearInfo = true
    for key, value in pairs(self.chatCountDownTimeTag) do
        if self.chatCountDownTimeTag[key] == true then
            clearInfo = false
        end
    end
    if clearInfo == true then
        if (self._updateTimeId) then
            self.tagInfo = false
            Scheduler.unschedule(self._updateTimeId)
            self._updateTimeId = false
        end
    end
end

function ChatModel:getChannelCountTime(channelType)
    return self.chatCountDownTime[channelType]
end

function ChatModel:getChannelCountTimeTag(channelType)
    local tag = false
    if self.chatCountDownTimeTag[channelType] == nil then
        tag = false
    else
        tag = self.chatCountDownTimeTag[channelType]
    end

    local configInfo = DynamicConfigData.t_Channel[channelType]
    if not configInfo then
        return 1
    end
    if self.chatCountDownTime[channelType] == nil then
        self.chatCountDownTime[channelType] = configInfo.chatCd
    end
    if tag == false then
        self.chatCountDownTime[channelType] = configInfo.chatCd
    end
    if self.tagInfo == false then
        self.tagInfo = true
        self:setChannelCountTime()
    end
    return self.chatCountDownTimeTag[channelType]
end

function ChatModel:getsysChannelName(data)
    if data and data.contentId then
        local color = "#FFFFFF"
        local config = DynamicConfigData.t_boardingMsg[tonumber(data.contentId)]
        if config and config.channelname then
            if config.channelname == Desc.chatView_str16 then
                color = "#FFFFFF"
            else
                color = "#FFFFFF"
            end
            return ColorUtil.formatColorString(config.channelname, color)
        else
            return ColorUtil.formatColorString(Desc.chatView_str4, color)
        end
    end
    return ""
end

function ChatModel:getChannelIsOpen(channelType)
    local configInfo = DynamicConfigData.t_Channel[channelType]
    if not configInfo then
        return false, ""
    end
    local open = false
    local str =string.format( Desc.chatView_str18,configInfo.level)
    if PlayerModel.level >= configInfo.level then
        open = true
        str = ""
    end
    return open, str
end

function ChatModel:getChannelMessageNum(channelType)
    local configInfo = DynamicConfigData.t_Channel[channelType]
    if not configInfo then
        return 50
    end
    return configInfo.count
end

function ChatModel:setCurrentOpenChannel(channelType)
    self._currentOpenChannel = channelType
    if (channelType == ModelManager.ChatModel.ChatType.Private) then
        RedManager.updateValue("V_CHAT_PRIVATE", false)
    elseif (channelType == ModelManager.ChatModel.ChatType.Guild) then
        RedManager.updateValue("V_CHAT_GUILD", false)
    elseif (channelType == ModelManager.ChatModel.ChatType.World) then
        RedManager.updateValue("V_CHAT_WORLD", false)
    elseif (channelType == ModelManager.ChatModel.ChatType.Crossrealm) then
        RedManager.updateValue("V_CHAT_CROSSREAL", false)
    elseif (channelType == ModelManager.ChatModel.ChatType.worldCross) then
        RedManager.updateValue("V_CHAT_WORLDCROSS", false) 
	elseif (channelType == ModelManager.ChatModel.ChatType.GodMarket) then
        RedManager.updateValue("V_CHAT_GODMARKET", false)
    end
end
function ChatModel:parse(content)
    if not content then
        return
    end
    -- local info=string.split(content,']')
    -- local str=''
    -- printTable(8,'>>>>>>>>>>>>>',info)
    -- for key, value in pairs(info) do
    --       if string.find(value, "%[:") == 1 then
    --         local res = string.gsub(value, "%[:", "<img src='ui://Chat/")
    --         str=str..res.."'/>"
    --         printTable(8,'>>>>>>>>>>>>>打印的123',str)
    --       else
    --         str=str..value
    --       end
    -- end
    -- printTable(8,'>>>>>>>>>>>>>打印的',str)
    -- return str
    --if string.find(content, "[:]") == 1 then
    -- local res = string.gsub(content, "%[:", "<img src='ui://Chat/")
    -- local res1 = string.gsub(res, "%]", "'/>")

    --res1 = "接收到的接收到的接收到的接收到的接收到的<font color='#FF0000'><a href='1'>聊天消息</a></font>"
    --res1 = "12345678923456234562345623456234566<MsgObj>ITEM,10000005,100</MsgObj>"
    --res1 = "123456789<MsgObj>PLAYER,3108,玩家名字, 1</MsgObj>"
    --return res1
    --else
    --<MsgObj>PLAYER,0</MsgObj>购买了月卡，<MsgObj>COLOR,5,八倍</MsgObj>绑元天天领！
    --<MsgObj>PET,{$1},{$1},{$1},{$1}</MsgObj>
    --<MsgObj>COLOR,2,{$1}</MsgObj>锐不可当，最高评价通关<MsgObj>COLOR,2,{$2}</MsgObj>，获得大量装备掉落！
    --end
    local htmltext = content
    local firstIdx = 1 --文本段开始位置
    local length = string.len(htmltext)
    local resultStr = ""
    while (firstIdx < length + 1) do
        local starIdx = string.find(htmltext, "%{/", firstIdx)
        printTable(9, ">>>>>>>>>>>>1", content, length, starIdx)
        if not starIdx then
            resultStr = resultStr .. string.sub(htmltext, firstIdx, length)
            firstIdx = length
            break
        else
            resultStr = resultStr .. string.sub(htmltext, firstIdx, starIdx - 1)
            firstIdx = starIdx + 2
            local fontEnd = string.find(htmltext, "%}", starIdx)
            if not fontEnd then
                fontEnd = starIdx
            else
                resultStr = resultStr .. self:getObjDipsplayStr(string.sub(htmltext, firstIdx, fontEnd - 1))
            end
            firstIdx = fontEnd + 1
        end
    end
    return resultStr
end

function ChatModel:getObjDipsplayStr(dataStr)
    local returnStr = ""
    returnStr = "<img src='ui://Chat/" .. dataStr .. "'/>"
    return returnStr
end

--把所有MsgObj的对象数据提取出来
function ChatModel:paraseAtObj(content)
    if not content then
       return 
    end
    local htmltext = content
    local firstIdx = 1 --文本段开始位置
    local length = string.len(htmltext)
    local resultStr = ""
    while (firstIdx < length + 1) do
        local starIdx = string.find(htmltext, "<MsgObj>", firstIdx)
        if not starIdx then
            resultStr = resultStr .. string.sub(htmltext, firstIdx, length)
            firstIdx = length
            break
        else
            resultStr = resultStr .. string.sub(htmltext, firstIdx, starIdx - 1)
            firstIdx = starIdx + 8
            local fontEnd = string.find(htmltext, "</MsgObj>", starIdx)
            if not fontEnd then
                fontEnd = starIdx
            else
                resultStr = resultStr ..self:getAtObjDipsplayStr(string.sub(htmltext, firstIdx, fontEnd - 1))
            end
            firstIdx = fontEnd + 9
        end
    end
    return resultStr
end

--把MsgObj对象数据转成htmlText
function ChatModel:getAtObjDipsplayStr(dataStr)
    local data = string.split(dataStr, ",")
    local returnStr = ""
       if (data[1] == "ATOTHER") then --"@别人"
            local key= data[2] 
            local playName=data[3] 
            local itemIndex=data[4] 
            local arr=StringUtil.lua_string_split(key, "_")
            local playerId=arr[1]
            local servserId=arr[2]
            local myserverId = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
            local myPlayerId=ModelManager.PlayerModel.userid
            if tonumber(playerId)==myPlayerId and tonumber(servserId)==myserverId then
                local info = {
                    key = key,
                    playName = playName,
                    itemIndex =itemIndex,
                    channel =data[5],
                    ms=data[6],
                    servserTime=data[7],
                }
                self:setCurCopyMsgStr(info)
            end
    end
    return returnStr
end


function ChatModel:reviceData(data)
    self:setAtMeMsgInfo(data)--设置显示@我的数据
    self:setChannelIndex(data)
    printTable(156, "接收到的聊天消息", data)
    if data.chatType ~= self.ChatType.System then
        if #self.synthesizeChatArray >= self.channelInfo[1].messageNum then
            table.remove(self.synthesizeChatArray, 1)
        end
        table.insert(self.synthesizeChatArray, data)
    end
    if data.chatType == self.ChatType.System then --系统
        self:setSystem(data)
    elseif data.chatType == self.ChatType.World then --世界
        if #self.worldChatArray >= self.channelInfo[3].messageNum then
            table.remove(self.worldChatArray, 1)
        end
        table.insert(self.worldChatArray, data)
        if (self._currentOpenChannel ~= ModelManager.ChatModel.ChatType.World) then
            local chooseData = ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.world]
            if chooseData then
                RedManager.updateValue("V_CHAT_WORLD", true)
            end
        end
    elseif data.chatType == self.ChatType.Guild then --工会
        local guildChatArrayNum = 0
        if self.guildChatArray then
            guildChatArrayNum = #self.guildChatArray
        end
        if guildChatArrayNum >= self.channelInfo[4].messageNum then
            table.remove(self.guildChatArray, 1)
        end
        table.insert(self.guildChatArray, data)
        if (self._currentOpenChannel ~= ModelManager.ChatModel.ChatType.Guild) then
            local chooseData = ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.guild]
            if chooseData and data.fromPlayer and data.fromPlayer.playerId ~= PlayerModel.userid then
                RedManager.updateValue("V_CHAT_GUILD", true)
            end
        end
    elseif data.chatType == self.ChatType.Private then --私聊
        if #self.privateChatArray >= self.channelInfo[5].messageNum then
            table.remove(self.privateChatArray, 1)
        end
        table.insert(self.privateChatArray, data)
        if (self._currentOpenChannel ~= ModelManager.ChatModel.ChatType.Private) then
            local chooseData = ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.friend]
            if chooseData and data.fromPlayer and data.fromPlayer.playerId ~= PlayerModel.userid then
                RedManager.updateValue("V_CHAT_PRIVATE", true)
            end
        end
    elseif data.chatType == self.ChatType.Crossrealm then --同城
        if #self.crossrealmArray >= self.channelInfo[6].messageNum then
            table.remove(self.crossrealmArray, 1)
        end
        table.insert(self.crossrealmArray, data)
        if (self._currentOpenChannel ~= ModelManager.ChatModel.ChatType.Crossrealm) then
            local chooseData = ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.crossreal]
            if chooseData then
                RedManager.updateValue("V_CHAT_CROSSREAL", true)
            end
        end
    elseif data.chatType == self.ChatType.worldCross then --跨服
        if #self.worldcrossrealmArray >= self.channelInfo[7].messageNum then
            table.remove(self.worldcrossrealmArray, 1)
        end
        table.insert(self.worldcrossrealmArray, data)
        if (self._currentOpenChannel ~= ModelManager.ChatModel.ChatType.worldCross) then
            local chooseData = ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.worldCross]
            if chooseData then
                RedManager.updateValue("V_CHAT_WORLDCROSS", true)
            end
        end 
	elseif data.chatType == self.ChatType.GodMarket then --跨服
        if #self.godMarketArray >= self.channelInfo[7].messageNum then
            table.remove(self.godMarketArray, 1)
        end
        table.insert(self.godMarketArray, data)
        if (self._currentOpenChannel ~= ModelManager.ChatModel.ChatType.GodMarket) then
            local chooseData = ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.GodMarket]
            if chooseData then
                RedManager.updateValue("V_CHAT_GODMARKET", true)
            end
        end
    end
    -- if data.receiveMs >self.mainchatTime*1000 then
    self.mainchatTime = ModelManager.ServerTimeModel:getServerTime()
    --local add=data.receiveMs-self.mainchatTime*1000
    --printTable(25, "接收到的聊天消息",data.receiveMs, self.mainchatTime, add)
    if (#self.battleChatList >= 2) then
        table.remove(self.battleChatList, 1)
    end
    table.insert(self.battleChatList, data)
    printTable(27, "接收到的聊天消息", self.battleChatList)
    Dispatcher.dispatchEvent(EventType.chat_newMsg, data)
    --  end
end

function ChatModel:setSystem(data)
    if tonumber(data.contentId) == 0 then --后台公告显示在跑马灯和世界频道
        printTable(25, "wwwwwwwwwwwww", data)
        if #self.diversionsArray >= self.channelInfo[3].messageNum then
            table.remove(self.diversionsArray, 1)
        end
        table.insert(self.diversionsArray, data)
        data["viewType"] = 1
        if #self.sysChatArray >= self.channelInfo[3].messageNum then
            table.remove(self.sysChatArray, 1)
        end
        table.insert(self.sysChatArray, data)
        Dispatcher.dispatchEvent(EventType.update_chat_runMonkeyMsg, data)
    else
        local configInfo = DynamicConfigData.t_boardingMsg[tonumber(data.contentId)]
        if not configInfo then
            return
        end
        local mainStr=configInfo.content2
        local str = configInfo.content
        printTable(12, "a大约有第三方亚士大夫", data)
        for key, value in pairs(data.exInfo) do
            str = string.gsub(str, "%%s", value, 1)
        end
        for key, value in pairs(data.exInfo) do
            mainStr = string.gsub(mainStr, "%%s", value, 1)
        end
        printTable(12, "打印的str。。。。。。阿斯蒂芬", str)
        data["content1"] = mainStr--主界面显示用的
        data["content"] = str
        data["viewType"] = configInfo.viewType
        if configInfo.topnews == 1 then
            if #self.diversionsArray >= self.channelInfo[3].messageNum then
                table.remove(self.diversionsArray, 1)
            end
            table.insert(self.diversionsArray, data)
            Dispatcher.dispatchEvent(EventType.update_chat_runMonkeyMsg, data)
        end
        for key, value in pairs(configInfo.channels) do
            if value == 0 then --综合
                if #self.synthesizeChatArray > self.channelInfo[1].messageNum then
                    table.remove(self.synthesizeChatArray, 1)
                end
                table.insert(self.synthesizeChatArray, data)
            elseif value==1 then--世界
                if #self.worldChatArray >= self.channelInfo[3].messageNum then
                    table.remove(self.worldChatArray, 1)
                end
                table.insert(self.worldChatArray, data)
            elseif value == 2 and data.guildId and GuildModel.guildHave and data.guildId == GuildModel.guildList.id then --公会
                if #self.guildChatArray >= self.channelInfo[4].messageNum then
                    table.remove(self.guildChatArray, 1)
                end
                table.insert(self.guildChatArray, data)
            elseif value == 3 then --私聊
                if #self.privateChatArray >= self.channelInfo[5].messageNum then
                    table.remove(self.privateChatArray, 1)
                end
                table.insert(self.privateChatArray, data)
            elseif value == 4 then --跑马灯
                if #self.diversionsArray >= self.channelInfo[3].messageNum then
                    table.remove(self.diversionsArray, 1)
                end
                table.insert(self.diversionsArray, data)
                Dispatcher.dispatchEvent(EventType.update_chat_runMonkeyMsg, data)
            elseif value == 5 then --系统
                if #self.sysChatArray >= self.channelInfo[2].messageNum then
                    table.remove(self.sysChatArray, 1)
                end
                table.insert(self.sysChatArray, data)
            end
        end
    end
end

function ChatModel:setChatSetting(data)
    printTable(12, "登录下推的设置", data)
    if not data then
        return
    end
    if data.system ~= nil then
        self.chatSetting[self.settingType.system] = data.system
    end
    if data.world ~= nil then
        self.chatSetting[self.settingType.world] = data.world
    end
    if data.guild ~= nil then
        self.chatSetting[self.settingType.guild] = data.guild
    end
    if data.friend ~= nil then
        self.chatSetting[self.settingType.friend] = data.friend
    end
    if data.Cross ~= nil then
        self.chatSetting[self.settingType.crossreal] = data.Cross
    else
        self.chatSetting[self.settingType.crossreal] = false
    end
    if data.WorldCross ~= nil then
        self.chatSetting[self.settingType.worldCross] = data.WorldCross
    else
        self.chatSetting[self.settingType.worldCross] = false
    end
end

function ChatModel:setCurChannelId(channelId)
    self.curChannelId=channelId
end

function ChatModel:setServerIdAndPlayerId(playerId, serverId,privateName)
    if playerId == nil then
        playerId = ModelManager.PlayerModel.userid
    end
    if serverId == nil then
        serverId = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
    end
    self.sendPlayId = playerId
    self.sendServerId = serverId
    if not privateName then
        privateName=""
    end
    self.privateName=privateName
end

function ChatModel:getServerIdAndPlayerId()
    if self.sendPlayId == nil then
        self.sendPlayId = ModelManager.PlayerModel.userid
    end
    if self.sendServerId == nil then
        self.sendServerId = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
    end
    return self.sendPlayId, self.sendServerId,self.privateName
end

function ChatModel:setPrivateClientInfo(data, textArr)
    local serverId = data.serverId or math.tointeger(LoginModel:getLoginServerInfo().unit_server)
    local key = data.playerId .. "_" .. serverId
    printTable(18, ">>>>|||设置的数据", key)
    local privateList = self.privateChatList[key]
    if privateList == nil then
        local info = {}
        info["idex"] = #self.privateChatList + 1
        info["toPlayer"] = data
        info["strArr"] = {}
        if textArr ~= nil then
            table.insert(info["strArr"], textArr)
        end
        privateList = info
        self.privateChatList[key] = privateList
    else
        self.privateChatList[key]["toPlayer"] = data
        printTable(8, ">>>>|||设置的数据11", data)
        local chatArr = self.privateChatList[key].strArr
        if #chatArr >= self.channelInfo[5].messageNum then
            table.remove(chatArr, 1)
        end
        table.insert(chatArr, textArr)
    end
    --暂时注释
    -- if textArr ~= nil then
    --     self.privateChatBeforeSevenTime[key]={sorttime=textArr.receiveMs,keyId=key}
    -- end
    -- local time=tostring(FileDataType.PRIVATECHAT_TIME..ModelManager.PlayerModel.userid)
    -- FileCacheManager.setStringForKey(time, json.encode(self.privateChatBeforeSevenTime), nil, true)
    --   Scheduler.unschedule( self.privateChatupdateTimeId)
    --   self.privateChatupdateTimeId = Scheduler.schedule(function()
    --     local str=tostring(FileDataType.PRIVATECHAT_STR..ModelManager.PlayerModel.userid)
    --     FileCacheManager.setStringForKey(str, json.encode(self.privateChatList), nil, true)
    -- end,30,1)
    printTable(16, ">>>>|||设置的数据11", self.privateChatList)
    -- if #self.synthesizeChatArray >= self.channelInfo[1].messageNum then
    --     table.remove(self.synthesizeChatArray, 1)
    -- end
    -- table.insert(self.synthesizeChatArray, textArr)
        local myPlayId= ModelManager.PlayerModel.userid
    if (self._currentOpenChannel ~= ModelManager.ChatModel.ChatType.Private and textArr ~= nil) then
        local chooseData = ModelManager.ChatModel.chatSetting[ModelManager.ChatModel.settingType.friend]
        if chooseData and data.fromPlayer and data.fromPlayer.playerId ~= myPlayId then
            RedManager.updateValue("V_CHAT_PRIVATE", true)
        elseif chooseData and textArr and  textArr.fromPlayer and textArr.fromPlayer.playerId~= myPlayId then
            RedManager.updateValue("V_CHAT_PRIVATE", true)
        end
    end
    -- local add=textArr.receiveMs-self.mainchatTime*1000
    -- printTable(25, "细聊打印的信息>>>>>>>>", data, textArr,add)
    -- if  textArr and textArr.receiveMs >self.mainchatTime*1000 then
    if textArr then
        local chatnewMsg = {}
        chatnewMsg = textArr
        chatnewMsg["chatType"] = self.ChatType.Private
        --   printTable(25, "细聊打印的信息>>>>>>>>111", chatnewMsg)
        if (#self.battleChatList >= 2) then
            table.remove(self.battleChatList, 1)
        end
        table.insert(self.battleChatList, chatnewMsg)
        Dispatcher.dispatchEvent(EventType.chat_newMsg, chatnewMsg)
    end
    Dispatcher.dispatchEvent(EventType.update_chatInfo)
end
--end

function ChatModel:deletePrivate(key)
    --暂时注释
    -- self.privateChatList[key]=nil
    -- self.privateChatBeforeSevenTime[key]=nil
    -- local playId = ModelManager.PlayerModel.userid
    -- local serverId = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
    -- ModelManager.ChatModel:setServerIdAndPlayerId(playId, serverId)
    -- local time=tostring(FileDataType.PRIVATECHAT_TIME..ModelManager.PlayerModel.userid)
    -- FileCacheManager.setStringForKey(time, json.encode(self.privateChatBeforeSevenTime), nil, true)
    -- local str=tostring(FileDataType.PRIVATECHAT_STR..ModelManager.PlayerModel.userid)
    -- FileCacheManager.setStringForKey(str, json.encode(self.privateChatList), nil, true)
    -- Dispatcher.dispatchEvent(EventType.update_deletechatClientPrivteInfo)
    local function success(data)
    end
    local listPos = StringUtil.lua_string_split(key, "_")
    local info={
        fromPlayerId=tonumber(listPos[1]) 
    }
    RPCReq.Chat_DeleteFormPlayerInfo(info,success) 
    self.privateChatList[key] = nil
    local playId = ModelManager.PlayerModel.userid
    local serverId = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
    ModelManager.ChatModel:setServerIdAndPlayerId(playId, serverId)
    Dispatcher.dispatchEvent(EventType.update_deletechatClientPrivteInfo)
end

--#发消息接口
function ChatModel:sendMsg(playerId, chatType, content, serverId, shareType)
    local  banChatTime= ModelManager.PlayerModel.banChatTime or 0
   local reminTime= banChatTime-ModelManager.ServerTimeModel:getServerTimeMS()
   if reminTime>0 then
       local str=string.format( DescAuto[62],TimeLib.GetTimeFormatDay(reminTime/1000, 2)) -- [62]="亲爱的探长，您已被禁言，剩余%s，详细情况请联系游戏客服，谢谢合作"
       RollTips.show(str)
       return
   end
    local function success(data)
        --result			1:boolean				#成功与否
        --items 			2:*PItem_Item 			#发送的物品
        --content 		3:string 				#消息的内容
        --receiveMs		4:integer				#时间
        printTable(18, "前段发消息接口返回", data)
        if tonumber(playerId) ~= ModelManager.PlayerModel.userid then
            local playerInfo = {}
            playerInfo["playerId"] = playerId
            playerInfo["serverId"] = serverId
            playerInfo["online"] = data.result
            local toPlayId = self.privateChatList[playerId .. "_" .. serverId]
            if toPlayId then
                printTable(8, "前段发消息接口返回", toPlayId)
                playerInfo["name"] = toPlayId.toPlayer.name
                playerInfo["level"] = toPlayId.toPlayer.level
                playerInfo["head"] = toPlayId.toPlayer.head
                playerInfo["sex"] = toPlayId.toPlayer.sex
            end
            local textArr = {}
            local fromInfo = {}
            fromInfo["online"] = data.result
            fromInfo["playerId"] = ModelManager.PlayerModel.userid
            fromInfo["name"] = ModelManager.PlayerModel.username
            fromInfo["level"] = ModelManager.PlayerModel.level
            fromInfo["head"] = ModelManager.PlayerModel.head
            fromInfo["sex"] = ModelManager.PlayerModel.sex
            fromInfo["headBorder"] = ModelManager.PlayerModel.headBorder   
            fromInfo["serverId"] = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
            textArr["fromPlayer"] = fromInfo
            textArr["content"] = data.content
            textArr["receiveMs"] = data.receiveMs
            self:setPrivateClientInfo(playerInfo, textArr)
            Dispatcher.dispatchEvent(EventType.update_chatClientPrivteInfo)
        end
        --Dispatcher.dispatchEvent(EventType.cardView_configurationPoint,data);
    end
    local info = {
        playerId = playerId, --1:integer 				#玩家ID
        chatType = chatType, --2:integer 				#消息类型
        content = content, --3:string 				#消息内容
        serverId = serverId, --4:integer				#服务器id
        shareType = shareType --5:integer 				#分享类型
    }
    self:setChannelIndex({chatType = chatType})
    printTable(157, "前段发送的消息", info)
    RPCReq.Chat_SendMessage(info, success)
end

--聊天对象信息（弃用）
-- function ChatModel:formPlayerInfo(playerId,serverId)
--     print(6,playerId,serverId)
--     local function success(data)
--         printTable(6, "ChatPlayTipsView", data)
--         self.fromPlayTipsInfo=data.fromPlayer;
--         ViewManager.open('ChatPlayTipsView');
--     end
--     local info = {
--         playerId = playerId, --1:integer 				#玩家ID
--         serverId = serverId, --4:integer				#服务器id
--     }
--     printTable(6, "前段发送的消息", info)
--     RPCReq.Chat_FormPlyaerInfo(info, success)
-- end

--聊天设置
function ChatModel:chatSetMessage(friend, world, guild, system,Cross,WorldCross)
    local function success(data)
        printTable(7, "聊天设置返回", data.ret)
        self:setChatSetting(data.ret)
    end
    local setState = {
        friend = friend, --	0:boolean
        world = world, --1:boolean
        guild = guild, --2:boolean
        system = system, --3:boolean
        Cross = Cross, --4:boolean
        WorldCross = WorldCross --5:boolean
    }
    local info = {
        info = setState
    }
    printTable(7, "聊天设置发送的消息", info)
    RPCReq.Chat_SetMessage(info, success)
end

--#广播消息
function ChatModel:broadcastByFixedFormat(contentId, exInfo, items, chatType, entitys)
    local function success(data)
        printTable(6, "属性点重置请求返回", data)
    end
    local info = {
        contentId = contentId, --1:integer				#格式ID
        exInfo = exInfo, --2:*string 				#携带的一些字符串信息
        items = items, --3:*PItem_Item 			#发送的物品
        chatType = chatType, --4:integer				#消息类型
        entitys = entitys --6:*PChat_PlayerInfo		#广播中的玩家信息
    }
    printTable(6, "广播消息", info)
    RPCReq.Chat_BroadcastByFixedFormat(info, success)
end

--#读取来自玩家fromId的消息
function ChatModel:readPrivateContent(fromId)
    local function success(data)
        printTable(6, "fromId的消息请求返回", data)
    end
    local info = {
        fromId = fromId --1:string
    }
    printTable(6, "fromId的消息", info)
    RPCReq.Chat_ReadPrivateContent(info, success)
end

--#一键私聊 向所有好友
function ChatModel:oneKeyPrivateChat(content, extInfo)
    local function success(data)
        printTable(6, "fromId的消息请求返回", data)
    end
    local info = {
        content = content, --	1:string 				#消息内容
        extInfo = extInfo --	2:*string
    }
    printTable(6, "fromId的消息", info)
    RPCReq.Chat_OneKeyPrivateChat(info, success)
end

--#获取跨服玩家聊天需要的头像信息（备用）
function ChatModel:getChatHeadInfo(playerId, serverId)
    local function success(data)
        printTable(6, "返回跨服玩家聊天需要的头像信息", data)
        self.fromPlayTipsInfo = data.headInfo
        ViewManager.open("ChatPlayTipsView")
    end
    local info = {
        playerId = playerId, --0:integer
        serverId = serverId --1:integer
    }
    printTable(6, "跨服玩家聊天需要的头像信息", info)
    RPCReq.Chat_GetChatHeadInfo(info, success)
end

--#获取跨服多个玩家聊天需要的头像信息（备用）
function ChatModel:getChatHeadInfos(playerIds)
    local function success(data)
        printTable(6, "返回跨服玩家聊天需要的头像信息", data)
    end
    local info = {
        playerIds = playerIds --0:integer
    }
    printTable(6, "跨服玩家聊天需要的头像信息", info)
    RPCReq.Chat_GetChatHeadInfos(info, success)
end

--#发送私聊信息(单独处理，原来的私聊屏蔽掉)
function ChatModel:sendPrivateMessage(playerId, content, serverId, shareType)
    local function success(data)
        printTable(6, "返回发送私聊信息", data)
    end
    local info = {
        playerId = playerId, --1:integer 				#玩家ID
        content = content, --2:string 				#消息内容
        serverId = serverId, --3:integer				#服务器id
        shareType = shareType --4:integer 				#分享类型
    }
    printTable(6, "发送私聊信息", info)
    RPCReq.Chat_SendPrivateMessage(info, success)
end

--#获取离线聊天记录
function ChatModel:getOfflinePrivateChatContent(fromPlayerId)
    local function success(data)
        printTable(6, "返回获取离线聊天记录", data)
    end
    local info = {
        fromPlayerId = fromPlayerId --0:integer #想获取和谁的聊天记录
    }
    printTable(6, "获取离线聊天记录", info)
    RPCReq.Chat_GetOfflinePrivateChatContent(info, success)
end

--#获取私聊聊天记录
function ChatModel:GetHistoryPrivateContentRecord()
    local function success(data)
        printTable(156, "获取私聊聊天记录", data)
        if not next(data) then
            return
        end
        for key, value in pairs(self.privateChatList) do
            value=nil
        end
        for key, args in pairs(data.infos) do
            if args.toPlayer.playerId ~= ModelManager.PlayerModel.userid then
                local playerInfo = {}
                playerInfo = args.toPlayer
                local textArr = {}
                textArr["fromPlayer"] = args.fromPlayer
                textArr["content"] = args.content
                textArr["receiveMs"] = args.receiveMs
                textArr["hadRead"] = args.hadRead  
                self:setPrivateClientInfo(playerInfo, textArr)
            else
                local playerInfo = {}
                playerInfo = args.fromPlayer
                local textArr = {}
                textArr["fromPlayer"] = args.fromPlayer
                textArr["content"] = args.content
                textArr["receiveMs"] = args.receiveMs
                textArr["hadRead"] = args.hadRead   
                self:setPrivateClientInfo(playerInfo, textArr)
            end
            self:setChannelIndex({chatType = 8})
        end
 
        for key, value in pairs(self.privateChatList) do
            if value.strArr then
                -- for k, v in pairs(value.strArr) do
                --    if v.hadRead then
                --         red=true
                --    end 
                -- end
                TableUtil.sortByMap(value.strArr, {{key="receiveMs",asc=false}})  
            end
        end
        -- RedManager.updateValue("V_CHAT_PRIVATE", red)
        for key, value in pairs(self.privateChatList) do
            if value.strArr then
                for k, v in pairs(value.strArr) do
                   if v.receiveMs then
                    self:setPrivateChatRedMs(key,v.receiveMs)
                   end 
                end
            end
        end
        local privatefirstLoginRed=false
        for k, v in pairs(self.privateChatRedstate) do
            if v==true then
                privatefirstLoginRed=true
            end
        end
        RedManager.updateValue("V_CHAT_PRIVATE", privatefirstLoginRed)
        Dispatcher.dispatchEvent(EventType.update_chatClientPrivteInfo)
    end
    printTable(12, "获取私聊聊天记录")
    RPCReq.Chat_GetHistoryPrivateContentRecord({}, success)
    --暂时注释
    -- local time=tostring(FileDataType.PRIVATECHAT_TIME..ModelManager.PlayerModel.userid)
    -- local sevenTimeId= FileCacheManager.getStringForKey(time, "", nil, true)
    -- local temp={}
    -- if sevenTimeId~= "" then
    --     local sevenTimeInfo = json.decode(sevenTimeId)
    --     for key, value in pairs(sevenTimeInfo) do
    --         temp[#temp+1] = value
    --     end
    -- end
    -- TableUtil.sortByMap(temp, {{key="sorttime",asc=true}})
    --  local reverstr=tostring(FileDataType.PRIVATECHAT_STR..ModelManager.PlayerModel.userid)
    -- local lastIput = FileCacheManager.getStringForKey(reverstr, "", nil, true)
    -- local Beforeseven={}
    -- if lastIput ~= "" then
    --     local Info = json.decode(lastIput)
    --    for i = 1, 7, 1 do
    --        local mode =temp[i]
    --        if mode then
    --             Beforeseven[mode.keyId]=Info[mode.keyId]
    --        end
    --    end
    -- end
    -- self.privateChatList=Beforeseven
    -- FileCacheManager.setStringForKey(reverstr, json.encode(Beforeseven), nil, true)
    -- printTable(18,"打印本地的私聊数据>>>>>>,,,.",self.privateChatList)
end

function ChatModel:pushChatData(data)
    TABLE_INSERT(self.chatList, data)
end



function ChatModel:getVideoRecordData(gamePlayType)
	return self.arenaRecordData[gamePlayType]
end


function ChatModel:addBattleData(recordId,battleData)
	local arrayType=battleData.gamePlayInfo.arrayType
	local gamePlayType=battleData.gamePlayInfo.gamePlayType --or GameDef.GamePlayType.WorldArena
	if gamePlayType then
		local battleDatas=self.videoBattleData[gamePlayType] or {}
		battleDatas[recordId]=battleData
		self.videoBattleData[gamePlayType]=battleDatas
	end
end

function ChatModel:getBattleData(gamePlayType,recordId)
	if self.videoBattleData[gamePlayType] then
		return self.videoBattleData[gamePlayType][recordId]
	end
end


function ChatModel:requestTotalRecord(gamePlayType,finished)
	local function success(data)
		self.arenaRecordData[gamePlayType]=data
		if finished then
			finished()
		end
		printTable(5656, "获取录像库", data,gamePlayType)
	end
	local paramas ={
		gamePlayType=gamePlayType
		
	}
	RPCReq.BattleRecord_OnGetTotalRecords(paramas, success)
end



function ChatModel:requestOneRecordInfo(paramas,finished)
	local function success(data)
		if finished then
			if paramas.gamePlayType ==GameDef.GamePlayType.Arena then
				finished(data.arenaRecordInfo)
			end
			if paramas.gamePlayType ==GameDef.GamePlayType.HigherPvp then
				finished(data.higherPvpRecordInfo)
			end
			if paramas.gamePlayType ==GameDef.GamePlayType.WorldArena then
				finished(data.arenaRecordInfo)
			end
			if paramas.gamePlayType ==GameDef.GamePlayType.WorldSkyPvp then
				finished(data.higherPvpRecordInfo)
			end
		end
		printTable(5656, "获取单条记录信息返回", data)
	end
	--local paramas= {
		--gamePlayType           1:integer
		--serverId               2:integer
		--recordId               3:integer
	--}
	printTable(5656, "获取单条记录信息请求", paramas)
	RPCReq.BattleRecord_OnGetRecordInfo(paramas, success)
end

function ChatModel:isSharePlayType(gamePlayType)
	local canShare=false
	if gamePlayType ==GameDef.GamePlayType.Arena or gamePlayType ==GameDef.GamePlayType.HigherPvp or gamePlayType ==GameDef.GamePlayType.WorldArena then
		canShare=true
	end
    return canShare
end





--更新录像库自己的点赞信息
function ChatModel:setAddLikeData(data)
	self.addLikeData=data
end

function ChatModel:getAddLikeData()
	return self.addLikeData
end

function ChatModel:getAddLikeCount()
	local  count=0
	if next(self.addLikeData)~=nil then
		for k, data in pairs(self.addLikeData) do
			for k1, v in pairs(data.likeList) do
				count=count+1
			end	
		end 
	end
	print(565600,"当日总的点赞次数"..count)
	return count
end


function ChatModel:isAtOtherItem(message)--是否是@item
    local array ={}
    local isAt=false   
    local content=message.content or ""
    local fromPlayer = message.fromPlayer
	if fromPlayer and content and string.sub(content,1,10) == "gychatAt_1" then
        content = string.gsub(content,"@",",")
        array= string.split(content,",")
		local index = 0
		local beginPos = 1
		local pos
		while true do 
			beginPos = string.find(content,",",beginPos+1)
			if beginPos then
				pos = beginPos
			else
				break
			end
			index = index + 1
			if index >= 5 then
				break
			end
		end

		if pos then
			local text = string.sub(content,pos+1,-1)
			content = text
        end
        isAt=true
    end
	return isAt,"@"..content,array
end


function ChatModel:isVoiceItem(message)--是否是语音item
    local array ={}
    local audioLen=0
    local isvoice=false       --处理语音
    local content=message.content
    local fromPlayer = message.fromPlayer
	if fromPlayer and content and string.sub(content,1,7) == "gyjz2_v" then
        content = string.gsub(content,"@",",")
        array= string.split(content,",")
        audioLen= array[5]
		local index = 0
		local beginPos = 1
		local pos
		while true do 
			beginPos = string.find(content,",",beginPos+1)
			if beginPos then
				pos = beginPos
			else
				break
			end
			index = index + 1
			if index >= 5 then
				break
			end
		end

		if pos then
			local text = string.sub(content,pos+1,-1)
			content = --[[string.format("<Msg>Voice%s,%s,%d</Msg>%s",string.sub(content,8,pos-1),text, 720, text)]]text
        end
        isvoice=true
    end
	return isvoice,content,audioLen,array
end


function ChatModel:setRecivegiftTime(info)
    self.recivegiftTime=info--接收礼物和赠送次数
    self:setGiftRecordList()
end

function ChatModel:setReciveGiftList(info)
    self.reciveGiftList=info--受赠礼物列表
    self:setGiftRecordList()
end

function ChatModel:setGiftRecordList()
    local red=false
    local red1=false
    local red2=false
    for key, value in pairs(self.reciveGiftList) do
        if value.status==1 then--可领取
            red1=true
            break
        end
    end
    for i=1,2,1 do
        local configInfo1 = DynamicConfigData.t_DonateGiftSetting[i]
        local servserTime1 = self:getRecvGiftTimes(i)--1礼包2道具接受次数
        if servserTime1<=configInfo1.recieveLimit then
            red2=true
            return
        end
    end 
    if red1 and red2 then
        red=true
    end
    RedManager.updateValue("V_CHAT_SENDGIFTRED", red) 
end

function ChatModel:getSendGiftTimes(type)--1礼包2道具赠送次数
    local times=0
    if   self.recivegiftTime.sendGiftTimes and self.recivegiftTime.sendGiftTimes[type] then
        times=self.recivegiftTime.sendGiftTimes[type].restTimes
    end
    return times
end

function ChatModel:getRecvGiftTimes(type)--1礼包2道具接受次数
    local times=0
    if   self.recivegiftTime.recvGiftTimes and self.recivegiftTime.recvGiftTimes[type] then
        times=self.recivegiftTime.recvGiftTimes[type].restTimes
    end
    return times
end

function ChatModel:openGiftView(viewType,curData,tarPlayerId)--viewType1好友界面2聊天界面
    local function success(data)
        if viewType==1 then
            self.sendGiftPlayer=curData
            ModuleUtil.openModule(ModuleId.ChatGift.id,true)
        end
    end
    local info = {
        tarPlayerId = tarPlayerId,           --2:integer #赠礼目标玩家playerId
    }
    printTable(5, "检测是否可以打开", info)
    RPCReq.Relationship_CheckCanDonate(info, success)
    if viewType==2 then
        self.sendGiftPlayer=curData
        ModuleUtil.openModule(ModuleId.ChatGift.id,true)
    end
end

--#赠礼给玩家
function ChatModel:RelationshipDonate(tarPlayerId,serverId,giftType,giftId,words)--赠礼
    local function success(data)
        printTable(5, "赠礼给玩家成功", data)
        local itemInfo=DynamicConfigData.t_DonateGift[giftType][giftId]
        local code=itemInfo.clientshow[1].code
        local amount=itemInfo.clientshow[1].amount
        local type=itemInfo.clientshow[1].type
        local content= string.format( "<MsgObj>SERCERSTR,送你</MsgObj><MsgObj>ITEM,%s,%s,%s</MsgObj>,并寄语%s",type,code,amount,words)
        ModelManager.ChatModel:setPrivateClientInfo(self.sendGiftPlayer, nil)
        ModelManager.ChatModel:sendMsg(tonumber(tarPlayerId), 8, content, tonumber(serverId), 9)
        --Dispatcher.dispatchEvent(EventType.CooperationActivitie_refresh)
    end
    local info = {
        tarPlayerId =tonumber(tarPlayerId),           --2:integer #赠礼目标玩家playerId
		giftType   = giftType,               --3:integer #赠礼类型
		giftId    = giftId,                --4:integer
		words     = words,                --5:string  #赠言
    }
    printTable(5, "赠礼给玩家", info)
    RPCReq.Relationship_Donate(info, success)
end

--#赠礼给玩家
function ChatModel:RelationshipGetGiftReward(giftType,uuid)--赠礼
    local function success(data)
        printTable(5, "领取赠礼成功", data)
        if data and data.uuid then
            self.reciveGiftList[data.uuid]=data.status
        end
        Dispatcher.dispatchEvent(EventType.update_upChatGiftGiftRecord)
    end
    local info = {
        giftType =giftType,              -- 1:integer #赠礼类型
		uuid   =uuid               --  2:string  
    }
    printTable(5, "领取赠礼", info)
    RPCReq.Relationship_GetGiftReward(info, success)
end

function ChatModel:getChatList()
    return self.chatList
end

return ChatModel
