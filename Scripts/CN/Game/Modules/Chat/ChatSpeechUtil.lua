local BaseModel = require "Game.FMVC.Core.BaseModel"
local ChatSpeechUtil = class("ChatSpeechUtil", BaseModel)
function ChatSpeechUtil:ctor()
    self.isInPlay = false
    self.curPlayFile = false
    self.isRecordComplete = true --录音是否结束(是否收到录音结束的回调)
    self.lastRecordTime = 0 --上次录音时间
    self.recordFileName = false --录音文件名
    self.recordFileNameQueue = {} --录音文件名队列
    self.waitForPlayQueue = {} --等待播放队列
    self.contentQueue = {} --内容队列
    self.__downloadingVoices = {} --正在下载的语音
    self.__hadPlay = {} --是否播放过的语音
    self.hasStar = false
    self.__autoPlayVoiceQueue={} --自动播放语音队列
    self.__curPlayingFileName=false

    self.voiceTooShort=false
    self.channelType = false
    self.toPlayerId = false
    self.serverId = false
end

function ChatSpeechUtil:setVoiceTooShort(tooShort)--时间少于一秒太短不发送出去
    self.voiceTooShort=tooShort
end

function ChatSpeechUtil:getVoiceTooShort()
   return self.voiceTooShort
end

function ChatSpeechUtil:init()
    SpeechUtil.registerRecordHandler(
        function(params)
            self:recordCallback(params)
        end
    )
    SpeechUtil.registerPlayHandler(
        function(params)
            self:playCallback(params)
        end
    )
end

function ChatSpeechUtil:recordCallback(params)
    printTable(157,"recordCallback",params)
    self.isRecordComplete = true
    SoundManager.setIsVoiceMode(false)
    local content = params.reason
    local validVoice = false
    --录音成功
   
    if params.recordStatus then
        validVoice = true
    else --录音失败
        if content == "Cancel" then
            RollTips.show(DescAuto[64]) -- [64]="录音取消"
        elseif string.find(content, "AudioReconizeError") then --语音识别失败! 可能是被百度限制了，还是需要发出来
            content = ""
            validVoice = true
        else
            LuaLogE(DescAuto[65] .. content) -- [65]="录音失败 "
            RollTips.show(content)
        end
    end

    if validVoice then
        local requestId = SpeechUtil.getRequestId()
        if self.recordFileName and self:isRecordFileExist(self.recordFileName) then
   
            if __ENGINE_VERSION__ > 1 then
                local fileName =self.recordFileName
                 local dir= SpeechUtil.getRecordDir()
                 dir= dir..fileName
                SpeechUtil.getVoiceText(dir,function (data)
                    printTable(159,"翻译后的数据",data)
                    local str = data.result and data.result[1] or ""
                    if not self:getVoiceTooShort() then
                        local canSend ,desc=self:canSendMsg(str)
                        if canSend  then
                            table.insert(self.recordFileNameQueue, self.recordFileName) --将名字插入队列中
                            table.insert(self.contentQueue, str)
                            -- Dispatcher.dispatchEvent(
                            --     EventType.chat_sendVoiceMsg,
                            --     {
                            --         fileName = self.recordFileName,
                            --         content = str,
                            --         audioID = 123456789,
                            --         requestId = requestId,
                            --         channelType = self.channelType,
                            --         toPlayerId = self.toPlayerId,
                            --         serverId = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
                            --     }
                            -- )
                            self:upload(self.recordFileName, requestId)
                        end
                    end
                end)
            else
               if not self:getVoiceTooShort() then
                local canSend ,desc=self:canSendMsg(content)
                if canSend then
                    table.insert(self.recordFileNameQueue, self.recordFileName) --将名字插入队列中
                    table.insert(self.contentQueue, content)
                    -- Dispatcher.dispatchEvent(
                    --     EventType.chat_sendVoiceMsg,
                    --     {
                    --         fileName = self.recordFileName,
                    --         content = content,
                    --         audioID = 123456789,
                    --         requestId = requestId,
                    --         channelType = self.channelType,
                    --         toPlayerId = self.toPlayerId,
                    --         serverId = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
                    --     }
                    -- )
                    self:upload(self.recordFileName, requestId)
                end
               end
            end
            LuaLogE(string.format(DescAuto[66], requestId, content)) -- [66]="请求id: %s content：%s"
        end
    end
end

function ChatSpeechUtil:playCallback(params)
    self.isInPlay = false
    SoundManager.setIsVoiceMode(false)
    if self.curPlayFile then
        LuaLogE(string.format(DescAuto[67], params.playStatus, self.curPlayFile)) -- [67]="播放回调(ChatSpeechUtil)：%s  %s"
        Dispatcher.dispatchEvent(EventType.chat_voicePlay_end, self.curPlayFile)
    else
        LuaLogE(string.format(DescAuto[68], params.playStatus)) -- [68]="播放回调：%s"
    end
    self.curPlayFile = false
    if params.playStatus then
        --播放完一条查看自动播放队列还有没有语音
        local fileName = table.remove(self.waitForPlayQueue, 1)
        if fileName then
            LuaLogE(string.format(DescAuto[69], fileName)) -- [69]="接着播放下一条%s"
            if self:isRecordFileExist(fileName) then
                self:startPlaySelf(fileName)
            elseif self:isVoiceFileExist(fileName) then
                self:starPlay(fileName)
            end
        end
    else
        local content = params.reason
        if content ~= "Stop" then
            LuaLogE(string.format(DescAuto[70], content)) -- [70]="播放错误：%s"
            RollTips.show(DescAuto[71] .. content) -- [71]="语音播放失败"
        end
    end
end

-- --录音按钮
function ChatSpeechUtil:starRecord(notNeedDelay)
    local curTime = cc.millisecondNow()
    --没有收到回调则五秒内不可继续录音
    if not self.isRecordComplete and curTime - self.lastRecordTime < 5000 and not notNeedDelay then
        LuaLogE(DescAuto[72]) -- [72]="尚未收到录音完毕回调"
        RollTips.show(DescAuto[72]) -- [72]="尚未收到录音完毕回调"
        return
    end
    --停止播放声音
    self:stopPlay()
    self.lastRecordTime = curTime
    self.isRecordComplete = false
    local fileName =SpeechUtil.getFileName()
    self.recordFileName = fileName

    --  local requestId = SpeechUtil.getRequestId()
    --  self:upload("10371yuan538321", requestId)

    LuaLogE(string.format(DescAuto[73], fileName)) -- [73]="录音文件名: %s"
    SoundManager.setIsVoiceMode(true)
    SpeechUtil.startRecord(fileName)
    self.hasStar = true
    Dispatcher.dispatchEvent(EventType.chat_autoPlay_pause)
end

function ChatSpeechUtil:stopPlay(reserve)
    SpeechUtil.stopPlay()
end

function ChatSpeechUtil:upload(filename, requestId)
    local tmpName = string.format("%sgy", filename)
    LuaLogE(string.format(DescAuto[74], requestId, tmpName)) -- [74]="上传文件id: %s ufn：%s"

    local username = ModelManager.PlayerModel.username
    local serverId = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
    local roleName = ModelManager.PlayerModel.username
    local roleLevel = ModelManager.PlayerModel.level

    local urlParams = {
        [28] = username,
        [29] = serverId,
        [30] = roleName,
        [31] = roleLevel
    }

    local urlData = HttpUtil.getFormatedURLData(urlParams, AgentConfiger.yySKey)
    --LuaLogE(string.format("打印的URL路径%s", urlData))
    local uploadURL = AgentConfiger.speechUploadURL .. urlData
    uploadURL = string.gsub(uploadURL, "sign=(.+)", "99=%1")

    local function onResponse(dict)
        LuaLogE(string.format(DescAuto[75], dict.dlStatus, dict.data)) -- [75]="上传回调：%s 返回id:%s"
       -- RollTips.show("返回code%s原因%s",dict.code)
        --上传成功，发消息
        if dict.code == 200 then
            local fileName = table.remove(self.recordFileNameQueue, 1)
            local content = table.remove(self.contentQueue, 1)
    
            if not fileName then
               -- RollTips.show("文件名不存在")
                LuaLogE(DescAuto[76]) -- [76]="文件名不存在(uploadCallback)"
                return
            end
    
            if not content then
               -- RollTips.show("文件内容不存在")
                LuaLogE(DescAuto[77]) -- [77]="文件内容不存在(uploadCallback)"
                return
            end

            --RollTips.show("上传成功，发消息")
            LuaLogE(DescAuto[78]) -- [78]="语音上传成功!"
            local audioID = dict.data
            if not self:getVoiceTooShort() then
                local canSend ,desc=self:canSendMsg(content)
                if canSend then
                    Dispatcher.dispatchEvent(
                        EventType.chat_sendVoiceMsg,
                        {
                            fileName = fileName,
                            content = content,
                            audioID = audioID,
                            requestId = requestId,
                            channelType = self.channelType,
                            toPlayerId = self.toPlayerId,
                            serverId = serverId
                        }
                    )
                else
                    RollTips.show(desc)
                end
            end
        else
            RollTips.show(dict.data)
            LuaLogE(string.format(DescAuto[79], dict.code,string.unicode2utf8(dict.data) )) -- [79]="语音上传失败!  retCode: %s 原因: %s"
            printTable(159,">>>>>>>>>>>>>>>>打印的返回值",dict.code,dict.data)
        end
    end

    local voiceFilePath = SpeechUtil.getRecordDir() .. tmpName
    LuaLogE(DescAuto[80] .. voiceFilePath) -- [80]="开始上传:\n"
    LuaLogE(string.format(DescAuto[81], uploadURL)) -- [81]="上传url:\n%s"
    HttpUtil.sendPostFile(
        {
            url = uploadURL,
            onFinish = onResponse,
            fileFullPath = voiceFilePath
        }
    )
end

function ChatSpeechUtil:download(isSelf, filename, requestID, audioID, callback)
    local tmpName = string.format("%sgy", filename)

    local username = ModelManager.PlayerModel.username
    local serverId = math.tointeger(LoginModel:getLoginServerInfo().unit_server)
    local roleName = ModelManager.PlayerModel.username
    local roleLevel = ModelManager.PlayerModel.level

    local urlParams = {
        [28] = username,
        [29] = serverId,
        [30] = roleName,
        [31] = roleLevel,
        [96] = audioID --"group1/M00/00/0A/rB8wFlhvKBuAbO9gAAARnSqnxBU9305332",
    }

    local urlData = HttpUtil.getFormatedURLData(urlParams, AgentConfiger.yySKey)
    local downloadURL = AgentConfiger.speechDownloadURL .. urlData
    downloadURL = string.gsub(downloadURL, "sign=(.+)", "99=%1")
    local function onResponse(dict)
        local downloadSuccess = false
        if dict.code == 200 then
            downloadSuccess = true --已经下载成功则设置，以后不再下载
        else
            RollTips.show(string.format(DescAuto[82], dict.code, dict.data)) -- [82]="语音下载失败!  retCode: %s 原因: %s"
        end

        if type(callback) == "function" then
            callback(downloadSuccess, filename, isSelf)
        end
    end

    LuaLogE(string.format(DescAuto[83], tmpName, requestID, audioID, downloadURL)) -- [83]="dfn：%s 请求id: %s 声音id：%s 下载地址：%s "

    local voiceFilePath = isSelf and SpeechUtil.getRecordDir() or SpeechUtil.getDownloadDir()
    HttpUtil.sendGetFile(
        {
            url = downloadURL,
            onFinish = onResponse,
            fileName = tmpName,
            filePath = voiceFilePath
        }
    )
end

function ChatSpeechUtil:stopRecord(type, id, sid) --没有开始录音
    if self.hasStar then
        if not type then
            self.channelType = false
        else
            self.channelType = type
        end
        self.toPlayerId = id
        self.serverId = sid
        SpeechUtil.stopRecord()
    else
        LuaLogE(DescAuto[84]) -- [84]="没有开始录音"
    end
    self.hasStar = false
    Dispatcher.dispatchEvent(EventType.chat_autoPlay_continue)
end

--取消录音
function ChatSpeechUtil:cancelRecord()
    SpeechUtil.cancelRecord()
    Dispatcher.dispatchEvent(EventType.chat_autoPlay_continue)
end

--录音文件是否存在
function ChatSpeechUtil:isRecordFileExist(filename)
    return SpeechUtil.isRecordFileExist(filename)
end

--下载的语音文件是否存在
function ChatSpeechUtil:isVoiceFileExist(filename)
    return SpeechUtil.isVoiceFileExist(filename)
end

function ChatSpeechUtil:startPlaySelf(fileName, forceBreak)
    LuaLogE(string.format(DescAuto[85], fileName)) -- [85]="开始播放后自己的playVoice: %s"
    if self:playVoice(fileName, forceBreak) then
        local tmpName = string.format("%sgy", fileName)
        self.curPlayFile = fileName
        SpeechUtil.startPlaySelf(tmpName)
        SoundManager.setIsVoiceMode(true)
    end
end

function ChatSpeechUtil:starPlay(fileName,forceBreak)
	if self:playVoice(fileName,forceBreak) then
        local tmpName = string.format("%sgy",fileName)
        self.curPlayFile = fileName
		SpeechUtil.startPlay(tmpName)
		SoundManager.setIsVoiceMode(true)
	end
end

function ChatSpeechUtil:playVoice(fileName, forceBreak)
    if self.isInPlay then
        -- table.insert(waitForPlayQueue,fileName)
        -- while #waitForPlayQueue > 30 do
        -- 	table.remove(waitForPlayQueue,1)
        -- end
        self.waitForPlayQueue[1] = fileName
        -- if forceBreak then
        self:stopPlay(true)
        -- end
        return
    end
    self.isInPlay = true
    return true
end

function ChatSpeechUtil:getSpeechFileLen(filename)
    return math.abs(SpeechUtil.getAudioLength(string.format("%s%sgy", SpeechUtil.getRecordDir(), filename)))
end

--正在下载的语音
function ChatSpeechUtil:setDownloadingVoices(name, isDownloading)
    self.__downloadingVoices[name] = isDownloading
end

function ChatSpeechUtil:isDownloading(name)
    return self.__downloadingVoices[name]
end

--是否已经下载
function ChatSpeechUtil:setVoicePlay(name, played)
    self.__hadPlay[name] = played
    FileCacheManager.setBoolForKey("chat" .. name, played)
end

function ChatSpeechUtil:isVoicePlayed(name)
    if self.__hadPlay[name] then
        return true
    end
    return FileCacheManager.getBoolForKey("chat" .. name, false)
end

function ChatSpeechUtil:btnTouchPlayVoice(message, contentArr)
    local isSelf = false
    local array = contentArr
    local requestId, audioId, audioLen, content, fileName
    fileName = array[2]    --fileName,requestId,audioID,audioLen,content
    requestId = array[3]
    audioId = array[4]
    audioLen = array[5]
    content = array[6]
    local fromPlayer = message.fromPlayer
    if fromPlayer then
        local selfPlayerId = ModelManager.PlayerModel.userid
        if fromPlayer.playerId == selfPlayerId then
            isSelf = true
        end
    end
    local function playEndCallback(_, _, cbFileName)
        LuaLogE("当前暂停的回调")
       -- LuaLogE(string.format(DescAuto[86], cbFileName, fileName, tostring(playEndCallback))) -- [86]="播放回调(MessageParser) %s  %s  %s"
        if cbFileName == fileName then
            RollTips.show(cbFileName .. fileName)
            ChatModel.chatVoiceAnim=false
            Dispatcher.dispatchEvent(EventType.update_chatClientPrivteInfo)
            Dispatcher.dispatchEvent(EventType.update_chatInfo)
            self:setCurPlaying(false)
        end
    end

    local function playVoice(fileName, playSelf, forceBreak)
        local curPlayingVoice=  self:getCurPlaying()
        LuaLogE(string.format("playVoice: %s %s %s %s", fileName, playSelf, forceBreak,curPlayingVoice))
        if curPlayingVoice~=false and curPlayingVoice ~= fileName then
            return
        end
        self:setVoicePlay(fileName,true)
        self:setCurPlaying(fileName)
        if playSelf then
            self:startPlaySelf(fileName, forceBreak)
        else
            self:starPlay(fileName, forceBreak)
        end
    end

    local function downloadFiles(isSelf, fileName, requestId, audioId, forceBreak, completeFunc)
        if self:isDownloading(fileName) then --正在下载中
            ChatModel.chatVoiceAnim=false
            Dispatcher.dispatchEvent(EventType.update_chatClientPrivteInfo)
            Dispatcher.dispatchEvent(EventType.update_chatInfo)
            RollTips.show(DescAuto[87]) -- [87]="语音下载中..."
            return
        end
        LuaLogE(DescAuto[88] .. fileName) -- [88]="录音不存在，去下载"
        self:setDownloadingVoices(fileName, true)
        self:download(
            isSelf,
            fileName,
            requestId,
            audioId,
            completeFunc or function(success, fileName, isSelf)
                    self:setDownloadingVoices(fileName, false)
                    if success then
                        LuaLogE(DescAuto[89] .. fileName) -- [89]="下载完成，播放文件"
                        playVoice(fileName, isSelf, forceBreak)
                    end
                end
        )
    end
    --首次创建消息需要判断是否自动播放语音
    if not self:isVoicePlayed(fileName) and not isSelf then -- 不是自己的消息
        if not self:isVoiceFileExist(fileName) then --不存在就去下载
            downloadFiles(
                isSelf,
                fileName,
                requestId,
                audioId,
                true,
                function(success, fileName, isSelf)
                    self:setDownloadingVoices(fileName, false)
                    if success then
                        LuaLogE(DescAuto[90] .. fileName) -- [90]="下载完成，加入队列"
                        Dispatcher.dispatchEvent(
                            EventType.chat_autoPlayQueue_push,
                            {
                                fileName = fileName,
                                chatType = message.chatType,
                                isSelf = false
                            }
                        )
                    end
                end
            )
        else
            -- LuaLogE("自动播放,注册回调" .. tostring(playEndCallback))
            -- playVoice(fileName,false,true)
            Dispatcher.dispatchEvent(
                EventType.chat_autoPlayQueue_push,
                {
                    fileName = fileName,
                    chatType = message.chatType,
                    isSelf = false
                }
            )
        end
    end
    if isSelf then
        if self:isRecordFileExist(fileName) then
            LuaLogE(DescAuto[91] .. tostring(playEndCallback)) -- [91]="自己的录音文件存在,直接播放111 "
            playVoice(fileName, true, true)
            return
        elseif self:isVoiceFileExist(fileName) then
            LuaLogE(DescAuto[92]) -- [92]="自己的录音文件存在,直接播放222 "
            playVoice(fileName, true, true)
            return
        end
    else
        if self:isVoiceFileExist(fileName) then
            LuaLogE(DescAuto[93]) -- [93]="别人的录音文件存在,直接播放"
            playVoice(fileName, false, true)
            return
        end
    end
    downloadFiles(isSelf, fileName, requestId, audioId, true)
end

function ChatSpeechUtil:canSendMsg(str)
    local desc=""
    local canSend=false
    if str~="" then
        local shield =StringUtil.containShieldCharacter(str)
        if not shield then
            canSend=true
        else
            desc=DescAuto[94] -- [94]="有屏蔽字无法发送"
        end
    else
        desc=DescAuto[95] -- [95]="无法识别"
    end
    return canSend,desc
end

function ChatSpeechUtil:topOfAutoPlayQueue(  )--播放下载队列
	return self.__autoPlayVoiceQueue[1]
end

function ChatSpeechUtil:popOutAutoPlayQueue(  )
	return table.remove(self.__autoPlayVoiceQueue, 1)
end

function ChatSpeechUtil:sizeOfAutoPlayQueue(  )
	return #self.__autoPlayVoiceQueue
end

function ChatSpeechUtil:getAutoPlayQueue(  )
	return self.__autoPlayVoiceQueue
end

function ChatSpeechUtil:setCurPlaying( fileName )--设置当前播放的文件名
	self.__curPlayingFileName = fileName
end

function ChatSpeechUtil:getCurPlaying(  )--得到当前播放的文件名
	return self.__curPlayingFileName
end



return ChatSpeechUtil
