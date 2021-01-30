--语音工具类
local SpeechUtil = {}
local audioManager = gy.GYAudioManager:getInstance()

local uploadURL = AgentConfiger.speechUploadURL
local downloadURL = AgentConfiger.speechDownloadURL

local audioDir = cc.FileUtils:getInstance():getWritablePath() .. "audio/"
local recordDir = audioDir .. "record/"
local downloadDir = audioDir .. "download/"

local sizeTotimeFactor = 1/(16000*2/10)
local firstUse = true

local __access_token = ""

local function getRoleInfo()
	local username = Cache.loginCache:getUserName()

	local playerId = 0
	if Cache.loginCache.__loginServerReturn then
		playerId = Cache.loginCache.__loginServerReturn.playerId
	end

	local roleCache = Cache.roleCache
	local loginCache = Cache.loginCache

	local roleInfo = FRRoleInfo:create(
		username, 
		tostring(playerId),
		FRMD5(roleCache:getName(), string.len(roleCache:getName())),--roleCache:getName(), 转成md5是为了解决名字中有特殊字符导致发不了语音的bug
		roleCache.getLevel(), 
		loginCache:getServerId(), 
		loginCache:getServerId(), 
		loginCache:getServerId(), 
		loginCache:getUnitServerId(), 
		AgentConfiger.tokenKey
	)
	return roleInfo
end

--[[
	初始化, 只需要调用一次
]]
function SpeechUtil.init()
	if not CC_TARGET_PLATFORM == CC_PLATFORM_IOS and not CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
		print(10,"移动平台才需要进行初始化")
		return 
	end

	local fileUtil = cc.FileUtils:getInstance()
	if fileUtil:isDirectoryExist(recordDir) then
		fileUtil:removeDirectory(recordDir)
	end
	if fileUtil:isDirectoryExist(downloadDir) then
		fileUtil:removeDirectory(downloadDir)
	end
	fileUtil:createDirectory(recordDir)
	fileUtil:createDirectory(downloadDir)

	if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
		local version = gy.GYDeviceUtil:getDeviceVersion()
		if version and type(version) == "string" and version ~= "" then
			version = string.sub(version,1,1)
			if version and tonumber(version) >= 5  and  tonumber(version) < 6 then
				if audioManager.setNeedMute then
					audioManager:setNeedMute(false)
				end
			end
		end
	end
end

--[[
	获取文件名，以玩家ID加时间的方式组合
]]

function SpeechUtil.getFileName()
	local speakTime = tostring(os.time())
	return ModelManager.PlayerModel.userid.."yuan" .. string.sub(speakTime,#speakTime-5,#speakTime)
end

function SpeechUtil.getRequestId()
	local uploadTime = tostring(os.time())
	return string.sub(uploadTime,#uploadTime-3,#uploadTime)
end
--[[
	获取录音文件存放位置
]]
function SpeechUtil.getRecordDir()
	return recordDir
end

--[[
	获取下载的音频文件存放位置
]]
function SpeechUtil.getDownloadDir()
	return downloadDir
end

--[[
	开始录音
	@filename	文件名(自动存放到recordDir)
]]
function SpeechUtil.startRecord(filename)
	return audioManager:startRecord(recordDir .. filename)
end


--[[
	取消录音
]]
function SpeechUtil.cancelRecord()
	audioManager:cancelRecord()
end

--[[
	停止录音
]]
function SpeechUtil.stopRecord()
	audioManager:stopRecord()
end

--[[
	注册录音结果处理回调
]]
function SpeechUtil.registerRecordHandler(callBackFunc)
	audioManager:registerRecordHandler(callBackFunc)
end

--[[
	播放录音
	@filename	文件名(自动从downloadDir读取)
]]
function SpeechUtil.startPlay(filename)
	return audioManager:startPlay(downloadDir .. filename)
end

function SpeechUtil.startPlaySelf(filename)
	return audioManager:startPlay(recordDir .. filename)
end
--[[
	停止播放
]]
function SpeechUtil.stopPlay()
	audioManager:stopPlay()
end

--[[
	注册播放结果处理回调
]]
function SpeechUtil.registerPlayHandler(callBackFunc)
	audioManager:registerPlayHandler(callBackFunc)
end

--[[
	下载
	@filename	文件名(会自动从recordDir读取)
	@requestID	自定义的requestID,用户下面注册回调时区分哪次上传结果
]]
function SpeechUtil.upload(filename, requestID)
	return audioManager:upload(recordDir .. filename, requestID, getRoleInfo())
end

--[[
	下载
	@filename	文件名(会自动从downloadDir读取)
	@requestID	自定义的requestID,用户下面注册回调时区分哪次下载结果
	@audioID	服务器上存放的资源ID
]]
function SpeechUtil.download(filename, requestID, audioID)
	return audioManager:download(downloadDir .. filename, requestID, audioID, getRoleInfo())
end

--录音文件是否存在
function SpeechUtil.isRecordFileExist(filename)
	local fileUtil = cc.FileUtils:getInstance()
	local rltFilename = string.format("%s%sgy",recordDir,filename)
	return fileUtil:isFileExist(rltFilename)
end

--下载的语音文件是否存在
function SpeechUtil.isVoiceFileExist(filename)
	local fileUtil = cc.FileUtils:getInstance()
	local rltFilename = string.format("%s%sgy",downloadDir,filename)
	return fileUtil:isFileExist(rltFilename)
end


function SpeechUtil.removeRecordFile(filename)
	local fileUtil = cc.FileUtils:getInstance()
	local rltFilename = string.format("%s%s",recordDir,filename)
	if fileUtil:isFileExist(rltFilename) then
		fileUtil:removeFile(rltFilename)
	end
end

--[[
	获取语音长度(单位:秒)
	注: path为全路径,需要自行拼装(getRecordDir() & getDownloadDir())
]]
function SpeechUtil.getAudioLength(path)
	return math.ceil(cc.FileUtils:getInstance():getFileSize(path) * sizeTotimeFactor)
end

function SpeechUtil.setFirstUse(isFirstUse)
	-- body
	firstUse = isFirstUse
end

function SpeechUtil.isFirstUse()
	-- body
	return firstUse
end


function SpeechUtil.getVoiceText(path,cb)
--RollTips.show(path)
	HttpUtil.sendPostFile({
		url = string.format("https://vop.baidu.com/pro_api?dev_pid=80001&cuid=%s&token=%s", gy.GYDeviceUtil:getDeviceID(), __access_token),
		fileFullPath = path,
		header = {"Content-Type: audio/pcm;rate=16000"},
		isCompress = false,		
		onFinish = function (dict)
			if dict.code ~= 200 then
				RollTips.show(string.format("%d,%s",dict.code, dict.dlMsg))
				--uploadVoice("")
				return
			end
			local matchData = string.match(dict.data, "{.+}")  --返回有时有些奇怪的字符，因此过滤一下
			local data = json.decode(matchData)
			if cb then
				cb(data)
			end
		end,
	})
end



function SpeechUtil:initAccessToken()

	if __access_token == "" then
		local key = "baiduyuyin_key"	
		local str = FileCacheManager.getStringForKey(key, "", false, true)
		local savedToken
		repeat
			if str == "" then
				break
			end

			local time, token = string.match(str, "(.*)##(.*)")
			if not time or not token then
				break
			end
			local halfMonth = 15*24*3600000
			time = tonumber(time)
			local curTime = ModelManager.ServerTimeModel:getServerTimeMS()
			if curTime - time > halfMonth then
				break				
			end
			savedToken = token
		until true

		if savedToken then
			__access_token = savedToken
			return __access_token
		else			
			local url = "https://openapi.baidu.com/oauth/2.0/token"
			local data = "grant_type=client_credentials&client_id=2QzFZRj8go8S0Tebobx8b8NE&client_secret=zWXp2CC16btGcdHTWuOgXkRwipmuKB8n"
			local times = 0
			local function getBaiduToken()
				times = times + 1
				if times > 3 then
					LuaLogE("3次获取百度token失败")
					return
				end

				gy.GYHttpClient:send(url, data, function (dict)
					if dict.code ~= 200 then
						LuaLogE("baiduSpeech fail %d,%s", dict.code, dict.dlMsg)
						getBaiduToken()
						return
					end

					local matchData = string.match(dict.data, "{.+}")  --返回有时有些奇怪的字符，因此过滤一下
					local status, result = pcall(json.decode, matchData)

					if not status then
						getBaiduToken()
						return
					end

					__access_token = result.access_token
					local content = string.format("%s##%s", ModelManager.ServerTimeModel:getServerTimeMS(), __access_token)
					FileCacheManager.setStringForKey(key, content, false, true)
				end, false, false, true, 30, 60)
			end
			getBaiduToken()
		end	
	else
		return __access_token
	end
end

return SpeechUtil