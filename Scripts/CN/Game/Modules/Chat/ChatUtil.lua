local BaseModel = require "Game.FMVC.Core.BaseModel"
local ChatUtil = class("ChatUtil", BaseModel)
function ChatUtil:ctor()
end

function ChatUtil:init()
end

function ChatUtil:checkTouch(point, rect)
    if cc.rectContainsPoint(rect, cc.p(point.x, point.y)) then
        return true
    end
    return false
end

--录音按钮
function ChatUtil:createRecordButton(btnObj)
    local clickTime = 0
    local obj = btnObj:displayObject()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(
        function(touch, event)
            ChatSpeechUtil:setVoiceTooShort(false)
            local point = touch:getLocation()
            local objPos = btnObj:localToGlobal(Vector2.zero)
            local pitch = self:checkTouch(point,cc.rect(objPos.x,display.height-objPos.y- btnObj:getHeight(),btnObj:getWidth() ,btnObj:getHeight()))
            printTable(156, "begin",point,objPos)
            if pitch then
                local _currentOpenChannel= ChatModel._currentOpenChannel
                if _currentOpenChannel == 0 then
                    RollTips.show(DescAuto[97]) -- [97]="该频道无法发言"
                    return
                end 
                local hasGuild = GuildModel.guildHave
                if _currentOpenChannel==ModelManager.ChatModel.ChatType.Guild  and hasGuild == false then --没有公会
                    RollTips.show(DescAuto[98]) -- [98]="请先加入公会"
                    return
                end
                local level = ModelManager.PlayerModel.level
                local configInfo=DynamicConfigData.t_Channel[_currentOpenChannel]
                if configInfo and level<configInfo.level then
                    RollTips.show(string.format(Desc.chatView_str18,configInfo.level))
                    return
                end
                clickTime = cc.millisecondNow()
                printTable(156, "begin")
                ViewManager.open("ChatStudioRecordingView", {recordType = 0})
                ChatSpeechUtil:starRecord()
                local delayTime = cc.DelayTime:create(15)
                local callFunc =
                    cc.CallFunc:create(
                    function()
                        RollTips.show(DescAuto[99]) -- [99]="录音超时"
                        ChatSpeechUtil:setVoiceTooShort(false)
                        ChatSpeechUtil:stopRecord(false,false,false)
                        ViewManager.close("ChatStudioRecordingView")
                    end
                )
                obj:runAction(cc.Sequence:create({delayTime, callFunc}))
                return true
            end
            return false
        end,
        cc.Handler.EVENT_TOUCH_BEGAN
    )
    listener:registerScriptHandler(
        function(touch, event)
            printTable(156, "move")
            local point = touch:getLocation()
            if point.y > 150 then
                ChatSpeechUtil:setVoiceTooShort(true)
                obj:stopAllActions()
                ChatSpeechUtil:cancelRecord()
                ViewManager.close("ChatStudioRecordingView")
                ViewManager.open("ChatStudioRecordingView", {recordType = 1})
            else
                ChatSpeechUtil:setVoiceTooShort(false)
            end
            printTable(156, "移动的距离 ", point.x, point.y)
            return true
        end,
        cc.Handler.EVENT_TOUCH_MOVED
    )
    listener:registerScriptHandler(
        function(touch, event)
            local objPos = btnObj:localToGlobal(Vector2.zero)
            local point = touch:getLocation()
            local pitch = self:checkTouch(point,cc.rect(objPos.x,display.height-objPos.y- btnObj:getHeight(),btnObj:getWidth() ,btnObj:getHeight()))
            if pitch then
                obj:stopAllActions()
                local now = cc.millisecondNow()
                local tooShort = now - clickTime < 1100
                if tooShort then
                    ChatSpeechUtil:setVoiceTooShort(true)
                    ChatSpeechUtil:cancelRecord()
                    RollTips.show(DescAuto[100]) -- [100]="语音时长小于1秒，无法发送"
                end
                ChatSpeechUtil:stopRecord(false,false,false)
                ViewManager.close("ChatStudioRecordingView")
            else
                ChatSpeechUtil:setVoiceTooShort(false)
                obj:stopAllActions()
                RollTips.show(DescAuto[101]) -- [101]="取消录音"
                ViewManager.close("ChatStudioRecordingView")
                ChatSpeechUtil:cancelRecord()
            end
            return true
        end,
        cc.Handler.EVENT_TOUCH_ENDED
    )
    obj:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, obj)
    return listener
end
return ChatUtil
