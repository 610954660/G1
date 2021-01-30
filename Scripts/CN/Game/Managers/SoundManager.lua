--音乐管理器
local SoundManager = {}
local AudioEngine = ccexp.AudioEngine
local fileUtils = cc.FileUtils:getInstance()
local textureManager = cc.ResourceManager:getInstance()

INVALID_AUDIO_ID = -1

--是否处于静音状态
local _isSilence = false
--背景音量[0-100]
local _musicVolume = 100
--特效音量[0-100]
local _soundVolume = 100

--是否处于语音模式中（录音或播放语音状态）
local _isVoiceMode = false
--录音或播放语音前音量保存
local _savedMusicVolume, _savedSoundVolume = 0, 0


--战斗特效速度
local _battleSoundSpeed = false


--正在播放中的背景音乐
local _playingMusic = INVALID_AUDIO_ID
local _playingMusicPath = nil

--正在播放中的音效
local _playingSounds = {}
local _playingSoundsPath = {}

local MusicIdArr = {}
local testMusicPathReplace = {
			{"music", "music2"}
	}

--移除下载监听
local removeEventListener = function() end


local _dict = nil

function SoundManager.getDict()
	if not _dict then
		--[[if __USE_TEST_SOUND__ or __AGENT_CODE__ == "g1pingce1" then
			_dict =DynamicConfigData.t_sound2;
		else--]]
			_dict =DynamicConfigData.t_sound;
--		end
	end
	return _dict
end
function SoundManager.hasVoice(musicKey)
	return SoundManager.getDict()[musicKey]
end

local function getFilePath(soundKey)
	local t = SoundManager.getDict()[soundKey]
	printTable(5,'>>>>>>>>>>>基础声音',soundKey,t)
	if t then
		local soundFile = t.stillSound
		if _battleSoundSpeed and string.find(soundFile,"attack/") then
			soundFile = string.gsub(soundFile,".mp3",_battleSoundSpeed)
			--LuaLogE("playSound:"..soundFile)
		end
		return fileUtils:isFileExist(soundFile), soundFile, t.noOverlap, (t.volume or 100)
	end

	return false, false, false, 100
end

function SoundManager.getPlayingMusic()
	return _playingMusic
end

function SoundManager.getPlayingMusicPath()
	return _playingMusicPath
end

function SoundManager.getLastMusicId()
	return MusicIdArr[#MusicIdArr]
end

function SoundManager.initLastMusicArr()
	MusicIdArr={}
end

function SoundManager.deleteLastMusicId(viewName)
	-- printTable(1,"MusicIdArr 顺序=",MusicIdArr)
	--如果带viewName的，从后往前找到同view名相同的，因为战斗view可能是在中间，而且中途关闭的
	if viewName then
		for i = #MusicIdArr,1,-1 do
			if MusicIdArr[i].viewName == viewName  then
				table.remove(MusicIdArr,#MusicIdArr)
				return
			end
		end
	else
		table.remove(MusicIdArr,#MusicIdArr)
	end
	printTable(1,"删除后",MusicIdArr)
end


--------------------------------音乐----------------------------------

--播放音乐 循环播放 参数id为地图id--切换地图ID时会回收上次地图的所有音效和音乐资源--
function SoundManager.playMusic(musicKey, loadCall, isMainUI, viewName)
	if not musicKey then return end
	if not isMainUI and viewName then
		table.insert(MusicIdArr,{viewName = viewName, musicKey = musicKey})
	end
	printTable(1,"MusicIdArr 数据",MusicIdArr)
	removeEventListener()
	local exist, filePath,noOverlap,cVolume = getFilePath(musicKey)
	if not exist then
		if filePath then
			if textureManager:isFileExistGame(filePath) then
				textureManager:toDownloadRes(filePath)
				local function onMissingResGet(_, _, path)
					if path == filePath then
						playMusic(musicKey, loadCall)
					end
				end
				Dispatcher.addEventListener(EventType.MISSING_RESOURCE_GET, onMissingResGet)
				removeEventListener = function()
					Dispatcher.removeEventListener(EventType.MISSING_RESOURCE_GET, onMissingResGet)
					removeEventListener = function() end
				end
			end
		end
		print("Error! The music key " .. musicKey .. " is not exist!")
		return INVALID_AUDIO_ID
	end
	SoundManager.playCustomMusic(filePath, loadCall, cVolume)
end

function SoundManager.playCustomMusic(filePath, callback, cVolume)
	removeEventListener()
	if _playingMusic ~= INVALID_AUDIO_ID then
		if filePath ~= _playingMusicPath then
			AudioEngine:stop(_playingMusic)
			AudioEngine:uncache(_playingMusicPath)
			_playingMusicPath = ""
		else
			return _playingMusic
		end
	end

	local volume = _musicVolume
	if _isSilence then volume = 0 end

	if callback and "function" == type(callback) then
		AudioEngine:preload(filePath, function(isloadSuccess)
			callback(isloadSuccess)
		end)
	end
	cVolume = cVolume or 100
	_playingMusic = AudioEngine:play2d(filePath, true, volume / 100 * (cVolume/100))
	if _playingMusic ~= INVALID_AUDIO_ID then
		_playingMusicPath = filePath
	end

	return _playingMusic
end

--停止播放音乐-不可恢复
function SoundManager.stopMusic()
	removeEventListener()
	if _playingMusic ~= INVALID_AUDIO_ID then
		AudioEngine:stop(_playingMusic)
		_playingMusic = INVALID_AUDIO_ID
		_playingMusicPath = nil
		return true
	end

	_playingMusic = INVALID_AUDIO_ID
	_playingMusicPath = nil
	return false
end

--暂停背景音乐
function SoundManager.pauseMusic()
	if _playingMusic ~= INVALID_AUDIO_ID then
		AudioEngine:pause(_playingMusic)
		return true
	end
	return false
end

--恢复背景音乐
function SoundManager.resumeMusic()
	if _playingMusic ~= INVALID_AUDIO_ID then
		AudioEngine:resume(_playingMusic)
		return true
	end
	return false
end

--重新开始播放背景音乐
function SoundManager.restartMusic()
	if _playingMusic ~= INVALID_AUDIO_ID then
		AudioEngine:setCurrentTime(_playingMusic, 0)
		return true
	end

	return false
end

--设置背景音乐音量[0-100]
function SoundManager.getMusicVolume() return _musicVolume end
function SoundManager.setMusicVolume(value)
	if type(value) ~= "number" then return end

	if value < 0 then
		value = 0
	elseif value > 100 then
		value = 100
	end

	if _musicVolume ~= value then
		_musicVolume = value

		local volume = _musicVolume
		if _isSilence then volume = 0 end

		if _playingMusic ~= INVALID_AUDIO_ID then
			AudioEngine:setVolume(_playingMusic, volume / 100)
		end
	end
end

--得到音乐总时间长度
function SoundManager.getMusicDuration()
	if _playingMusic ~= INVALID_AUDIO_ID then
		return AudioEngine:getDuration(_playingMusic)
	end

	return 0
end

--得到音乐当前播放时间
function SoundManager.getMusicCurrentTime()
	if _playingMusic ~= INVALID_AUDIO_ID then
		return AudioEngine:getCurrentTime(_playingMusic)
	end

	return 0
end

--设置音乐当前播放时间 返回成功与否
function SoundManager.setMusicCurrentTime(curTime)
	--无效判断
	if _playingMusic == INVALID_AUDIO_ID then
		return false
	end
	--音乐长度
	local timeLength = AudioEngine:getDuration(_playingMusic)
	-- print(__SELF_PRINT_TYPE__, timeLength, _playingMusic, curTime)
	if timeLength <= 0 then
		return false
	end
	-- print(__SELF_PRINT_TYPE__, "-----",timeLength, _playingMusic, curTime)
	--处理参数
	curTime = (not curTime) and 0 or curTime
	curTime = (curTime < 0) and 0 or curTime
	curTime = (curTime > timeLength) and timeLength or curTime

	--设置时间
	AudioEngine:setCurrentTime(_playingMusic, curTime)

	return true
end

--播放立绘声音（播放下一个要停掉前面的，即使是不同界面折）
local heroSoundId
function SoundManager.playHeroSound(soundKey, isLoop,endCallback, isMusicSound, is3DSound)
	if heroSoundId then SoundManager.stopSound(heroSoundId) end
	heroSoundId = SoundManager.playSound(soundKey, isLoop,endCallback, isMusicSound, is3DSound)
	return heroSoundId
end

function SoundManager.stopHeroSound()
	if heroSoundId then SoundManager.stopSound(heroSoundId) end
end

--------------------------------音效----------------------------------
--is3DSound 3d音效 会随着主角远离而慢慢缩小 传两个实体过来 is3DSound = {node1, node2}
--isMusicSound 这个音效是天气类似 的 很长的音效
--播放音效--ResKey资源配置的key-返回音效ID
local maxDis = display.width*0.75 * display.width*0.75 + display.height*0.75 * display.height*0.75
function SoundManager.playSound(soundKey, isLoop,endCallback, isMusicSound, is3DSound)	
	isLoop = isLoop or false
	local exist, filePath, noOverlap, cVolume = getFilePath(soundKey)
	if not exist then
		if filePath then
			textureManager:toDownloadRes(filePath)
		end
		print("Error! The sound key " .. soundKey .. " is not exist!")
		return INVALID_AUDIO_ID
	end

	local volume = _soundVolume
	-- print(92, "ERROR _soundVolume", _soundVolume)
	if _isSilence then volume = 0 end
	if volume <= 0 and not isMusicSound then return INVALID_AUDIO_ID end

	if noOverlap and _playingSoundsPath[filePath] and next(_playingSoundsPath[filePath]) then
		return INVALID_AUDIO_ID
	end
	cVolume = cVolume or 100
	cVolume = cVolume/100
	local soundId = AudioEngine:play2d(filePath, isLoop, volume / 100 * (cVolume))
	if soundId ~= INVALID_AUDIO_ID then
		local function onPlayEnd(id, path)
			if _playingSoundsPath[filePath] then
				_playingSoundsPath[filePath][id] = nil
			end
			_playingSounds[id] = nil

			if type(endCallback) == "function" then
				endCallback(soundKey,id)
			end 
		end
		AudioEngine:setFinishCallback(soundId, onPlayEnd)
		_playingSounds[soundId] = filePath
		if not _playingSoundsPath[filePath] then
			_playingSoundsPath[filePath] = {}
		end
		_playingSoundsPath[filePath][soundId] = true
		if is3DSound then
			local node = cc.Node:create()
			cc.Director:getInstance():getRunningScene():addChild(node)
			local curA = 1
			node:onUpdate(function ( dt )
				-- body
				if not tolua.isnull(is3DSound[1]) and not tolua.isnull(is3DSound[2]) and _playingSounds[soundId] then
					local pos1 = cc.p(is3DSound[1]:getPosition())
					local pos2 = cc.p(is3DSound[2]:getPosition())
					local dis2CenterSquare = (pos1.x - pos2.x) ^ 2 + (pos1.y - pos2.y) ^ 2
					-- print(92, "dis2CenterSquare", dis2CenterSquare)
					local a = 1 - dis2CenterSquare/maxDis 
					if a >= 1 then
						a = 1
					elseif a <= 0 then
						a = 0
					end
					local v = volume
					curA = a
					v = v*a
					-- print(92, "volume a", volume, a)
					AudioEngine:setVolume(soundId, v / 100* (cVolume))
				
				else
					
					if _playingSounds[soundId] then
						curA = curA - curA*dt
						if curA<=0 then
							curA = 0
						end
						local v = volume
						v = v*curA
						AudioEngine:setVolume(soundId, v / 100* (cVolume))
					else
						node:removeFromParent()
					end
				end
			end)
		end
	end

	return soundId
end

--停止播放音效 soundId 调用播放特效时返回的音效ID
function SoundManager.stopSound(soundId)
	local filePath = _playingSounds[soundId]
	if filePath then
		AudioEngine:stop(soundId)
		if _playingSoundsPath[filePath] then
			_playingSoundsPath[filePath][soundId] = nil
		end
		_playingSounds[soundId] = nil

	end
end

--停止所有音效
function SoundManager.stopSounds()
	for k, v in pairs(_playingSounds) do
		AudioEngine:stop(k)
	end
	_playingSounds = {}
	_playingSoundsPath = {}
end

--暂停指定音效
function SoundManager.pauseSound(soundId)
	if _playingSounds[soundId] then
		AudioEngine:pause(soundId)
	end
end

--暂停所有音效
function SoundManager.pauseSounds()
	for k, v in pairs(_playingSounds) do
		AudioEngine:pause(k)
	end
end

--恢复指定音效--
function SoundManager.resumeSound(soundId)
	if _playingSounds[soundId] then
		AudioEngine:resume(soundId)
	end
end

--恢复所有暂停的音效--
function SoundManager.resumeSounds()
	for k, v in pairs(_playingSounds) do
		AudioEngine:resume(k)
	end
end

--设置音效音量--对当前正在播放的无效--value[0, 100]
function SoundManager.getSoundVolume() return _soundVolume end
function SoundManager.setSoundVolume(value)
	if type(value) ~= "number" then return end

	if value < 0 then
		value = 0
	elseif value > 100 then
		value = 100
	end

	if _soundVolume ~= value then
		_soundVolume = value

		local volume = _soundVolume
		if _isSilence then volume = 0 end

		for k, v in pairs(_playingSounds) do
			AudioEngine:setVolume(k, volume / 100)
		end
	end
end


-----------------------------新增API----------------------------

--设置是否静音
function SoundManager.getIsSilence() return _isSilence end
function SoundManager.setIsSilence(value)
	if _isSilence ~= value then
		_isSilence = value

		if _playingMusic ~= INVALID_AUDIO_ID then
			local volume = _musicVolume
			if _isSilence then volume = 0 end
			AudioEngine:setVolume(_playingMusic, volume / 100)
		end

		local volume = _soundVolume
		if _isSilence then volume = 0 end
		for k, v in pairs(_playingSounds) do
			AudioEngine:setVolume(k, volume / 100)
		end
	end
end

--语音模式
function SoundManager.getIsVoiceMode() return _isVoiceMode end
function SoundManager.setIsVoiceMode(value)
	if type(value) ~= "boolean" then return end

	if _isVoiceMode ~= value then
		_isVoiceMode = value

		if _isVoiceMode then
			_savedMusicVolume = _musicVolume
			_savedSoundVolume = _soundVolume
			SoundManager.setMusicVolume(0)
			SoundManager.setSoundVolume(0)
		else
			SoundManager.setMusicVolume(_savedMusicVolume)
			SoundManager.setSoundVolume(_savedSoundVolume)
		end
	end
end

--设置同时播放数量[1-23]--默认为23--
function SoundManager.setMaxNumSounds(num)
	if num < 1 or num > 23 then return false end
	AudioEngine:setMaxAudioInstance(num + 1)--加上背景音效
end

--停止所有音乐音效
function SoundManager.stopAll()
	AudioEngine:stopAll()
	_playingMusic = INVALID_AUDIO_ID
	_playingMusicPath = nil
	_playingSounds = {}
	_playingSoundsPath = {}
end

--暂停所有音乐音效
function SoundManager.pauseAll()
	AudioEngine:pauseAll()
end

--恢复所有音乐音效
function SoundManager.resumeAll()
	AudioEngine:resumeAll()
end

function SoundManager.playComposeSound()
	playSound("ui_compose")
end

function SoundManager.playPetUpgradeSound()
	playSound("pet_upgrade")
end

function SoundManager.setSoundSpeed(speed)
	if not speed then
		speed=1.5
	end
	if speed > 2 then
		_battleSoundSpeed = "_x3.mp3"
	elseif speed > 1.5 then
		_battleSoundSpeed = "_x2.mp3"
	else
		_battleSoundSpeed = false
	end
	LuaLogE("SoundManager.setSoundSpeed:"..speed)
end


--- 一些常用音效, 比如行走、打开窗口、技能等等
local excepAudioKeys = {
	"open",
	"close",
	"button",
	"walk",
	1207099,
	1212001,
}

function SoundManager.unCacheAll()
	local dict = getDict()

	local excepAudios = {}
	for _,v in ipairs(excepAudioKeys) do
		local info = dict[v]
		if info then
			excepAudios[#excepAudios+1] = info.src
		end
	end
	AudioEngine:uncacheAll(excepAudios)
end

return SoundManager













