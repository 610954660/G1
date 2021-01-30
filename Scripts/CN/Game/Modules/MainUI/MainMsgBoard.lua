--added by wyang
--主界面上的聊天消息显示面板
local MainMsgBoard = class("MainMsgBoard")
local ChatTextCell = require "Game.UI.Global.ChatTextCell"
function MainMsgBoard:ctor(view, view1)
    self.view = view
    --self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
    self.list_msg = false
    self._lastShowTime = -1
    self._msgList = {}
    self._ChatmsgList = {}
    self._updateTimeId = false
    self.tweenId = {}
    self.view1 = view1
end

function MainMsgBoard:init(...)
    self.list_msg = self.view:getChildAutoType("list_msg")
    self.list_msg:setVisible(false)
    self._updateTimeId =
        Scheduler.scheduleOnce(
        1.0,
        function()
            self._updateTimeId = false
        end
    )
    self.list_msg:setItemRenderer(
        function(index, obj)
            obj:removeClickListener()
            obj:addClickListener(
                function(context)
                end,
                5
            )
            local txtObj = obj:getChildAutoType("txt_msg")
            local chatItemInfo = self._msgList[index + 1]
            local chatItemObj = self._ChatmsgList[index + 1]  
            self:showMsg(txtObj, chatItemInfo,chatItemObj)
        end
    )
    local num = 0
    if self._msgList then
        num = #self._msgList
    end
    self.list_msg:setNumItems(num)
    if #self._msgList > 1 then
        self.list_msg:scrollToView(#self._msgList - 1, true, true)
    end
end

function MainMsgBoard:channelName(data)
    if data.chatType == ChatModel.ChatType.World then
        return ColorUtil.formatColorString(Desc.chatView_str81, "#35FF43")
    elseif data.chatType == ChatModel.ChatType.Guild then
        return ColorUtil.formatColorString(Desc.chatView_str82, "#00FFFF")
    elseif data.chatType == ChatModel.ChatType.Private then
        return ColorUtil.formatColorString(Desc.chatView_str83, "#FF66CC")
    elseif data.chatType == ChatModel.ChatType.Crossrealm then
        return ColorUtil.formatColorString(Desc.chatView_str84, "#FF4F58")
    elseif data.chatType == ChatModel.ChatType.worldCross then
        return ColorUtil.formatColorString(Desc.chatView_str85, "#9999FF")
    elseif data.chatType == ChatModel.ChatType.System then
        local config = DynamicConfigData.t_boardingMsg[tonumber(data.contentId)]
        if config and config.channelname then
            printTable(29, "sddddddddd", config.channelname)
            if config.channelname == Desc.chatView_str86 then
                return ColorUtil.formatColorString("[" .. config.channelname .. "]", "#00FFFF")
            else
                return ColorUtil.formatColorString("[" .. config.channelname .. "]", "#FF8B35")
            end
        else
            return ColorUtil.formatColorString(Desc.chatView_str87, "#FF8B35")
        end
    end
    return ""
end

--收到新消息
function MainMsgBoard:onNewMsg1(data)
    printTable(27, ">>>>>>>>>>>", data)
    if not data or not data.content then
        return
    end
    local qianzui = self:channelName(data)
    local servserChat=""
    if data.content1 then
        servserChat= data.content1
    else
        servserChat=data.content
    end
    local str = qianzui .. servserChat
    if data.fromPlayer and data.fromPlayer.name then
        local isvoice, content, audioLen = ChatModel:isVoiceItem(data)
        local isBigFace ,faceId= GMethodUtil:isfacesetURL(servserChat)
        if isvoice == true  then
            str =string.format( "%s%s%s%s",qianzui,ColorUtil.formatColorString1(data.fromPlayer.name, "#6ae5FF"),":" , "语音消息")
        elseif isBigFace then 
            local faceConfig= ChatModel.faceConfigTable[tonumber(faceId)]
            local faceStr="表情包"
            if faceConfig then
                faceStr=faceConfig.emojiLanguage
            end
            str =string.format( "%s%s%s%s",qianzui, ColorUtil.formatColorString1(data.fromPlayer.name, "#6ae5FF"),":",faceStr )
        else
            str =string.format( "%s%s%s%s",qianzui,ColorUtil.formatColorString1(data.fromPlayer.name, "#6ae5FF"),":",servserChat)
        end
    end
    table.insert(self._msgList, str)
    table.insert(self._ChatmsgList, data)  
    if (#self._msgList > 2) then
        table.remove(self._msgList, 1)
        table.remove(self._ChatmsgList, 1)
    end
    printTable(25, "接收到的聊天消息>>>>>>1111111", self._msgList)
    self.list_msg:setNumItems(#self._msgList)
    if #self._msgList > 1 then
        self.list_msg:scrollToView(#self._msgList - 1, true, true)
    end
    self.list_msg:setVisible(true)
end

--显示下一条聊天消息
function MainMsgBoard:showNext()
    local curTime = ModelManager.ServerTimeModel:getServerTime()
    if self._lastShowTime == -1 or curTime - self._lastShowTime > 0 then
        self._lastShowTime = curTime
        self.list_msg:setNumItems(#self._msgList)
        if #self._msgList > 1 then
            self.list_msg:scrollToView(#self._msgList - 1, true, true)
        end
    end
end

--显示一条聊天消息
function MainMsgBoard:showMsg(obj, data,dataobj)
    obj:setText("")
    obj:setWidth(254)
    obj:setAnchorTextUnderline(false)
    local parseStr = ModelManager.ChatModel:parse(data)
    local textCell = ChatTextCell.new(obj,1)--1聊天
    parseStr = StringUtil.expendEnter(parseStr)
    parseStr = StringUtil.expendtabs(parseStr, 1)
    textCell:setText(parseStr,dataobj)
    obj:setWidth(obj:getTextSize().width)
end

--退出操作 在close执行之前
function MainMsgBoard:__onExit()
    -- self:clearTween()
    print(16, "999999999999999999")
end

return MainMsgBoard
