
local ResDownloadModel = class("ResDownloadModel", BaseModel)

local doOnce = false


local STATUS_READY = 0  --准备下载
local STATUS_DOWNLOADING = 1  --正在下载
local STATUS_FINISH = 2  --下载完成
local STATUS_FAIL = 3  --下载失败
local STATUS_STOP = 4  --下载停止


function ResDownloadModel:ctor()
	self._maxDownloadSize = 1
	self._downloadSize = 0
	self._maxVal = 0
	self._curVal = 0
	self.status = 0
	self.isVal = false 	-- 判断有没有给最大值赋过值
end

function ResDownloadModel:init()
	self:initListeners()
end


function ResDownloadModel:startResDownLoad(delayTime)
	if doOnce or AgentConfiger.isAudit() then return end
	doOnce = true
	if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID or CC_TARGET_PLATFORM == CC_PLATFORM_IOS) or ScriptType == ScriptTypePackS then
		local function endHandler(code, info, exParam) 
			local str = "~~~~~~~~startDownload endHandler: fromPID:%s toPID:%s nextDownloadPID:%s code:%s info:%s exParam:%s"
			str = string.format(str, 1, 2, 2,code, info, exParam)
			LuaLogE(str)

			--下载成功
			if code == 1 or code == 2 or code == 5 then
				self.status = STATUS_FINISH
				FileCacheManager.setIntForKey("DownLoadGift",self.status) 	-- 将数据存储到本地缓存 防止玩家下载完没有领取奖励后下线再上线 无法领取奖励
				ResUpdateManager.setUpdateInfo("loadedRes", 2)
				ResUpdateManager.stopDownload()
				Dispatcher.dispatchEvent(EventType.resDownLoad_status,{code = self.status,curSize = self._downloadSize,allSize = self._maxDownloadSize})
				PHPUtil.reportStep(ReportStepType.SUBPACK_DOWN_FINISH)
			else
				self.status = STATUS_FAIL
				Dispatcher.dispatchEvent(EventType.resDownLoad_status,{code = self.status,curSize = self._downloadSize,allSize = self._maxDownloadSize})
			end
			
		end

		local function comparingHandler(dict)
			--dict.comparedNum, dict.totalNum
			--LuaLogE("comparingHandler:"..json.encode(dict))
		end

		local function downloadingHandler(dict)
			--LuaLogE("downloadingHandler:"..json.encode(dict))
			self.status = STATUS_DOWNLOADING
			self._maxDownloadSize = dict.totalByte
			if not self.isVal then self._maxVal =  dict.totalByte ;self.isVal = true end
			self._downloadSize = dict.successByte + dict.failedByte + dict.bufferByte
			Dispatcher.dispatchEvent(EventType.resDownLoad_status,{code = self.status,curSize = self._downloadSize,allSize = self._maxDownloadSize})
		end
		
		self:stopResDownLoad()
		-- self._maxDownloadSize = 0
		-- self._downloadSize = 0
		--延迟5秒后开始下载
		LuaLog("ready ResUpdateManager.downloadResGame")
		local scene = display.getRunningScene()
		scene:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime or 5),cc.CallFunc:create(function()
		--Scheduler.scheduleOnce(function()
				LuaLog("start ResUpdateManager.downloadResGame")
				self.status = STATUS_READY
				Dispatcher.dispatchEvent(EventType.resDownLoad_status,{code = self.status,curSize = self._downloadSize,allSize = self._maxDownloadSize})
				ResUpdateManager.downloadResGame(true,1,2,1,3,endHandler,comparingHandler,downloadingHandler)
			--end,8)
				end) ));
	end
	
end

--开始下载
--Dispatcher.dispatchEvent(EventType.resDownLoad_start)
--停止下载
--Dispatcher.dispatchEvent(EventType.resDownLoad_stop)
--下载状态 code=1时为正在下载 curSize当前下载了多少KB allSize总大小 KB
--code=2时为下载完成
--Dispatcher.dispatchEvent(EventType.resDownLoad_status,{code = 1,curSize = 11,allSize = 9999})

function ResDownloadModel:stopResDownLoad()
	doOnce = false
	ResUpdateManager.stopDownload()
end

function ResDownloadModel:resDownLoad_start()
	self.status = STATUS_READY
	self:startResDownLoad(1)
	PHPUtil.reportStep(ReportStepType.SUBPACK_DOWN_START)
end

function ResDownloadModel:resDownLoad_stop()
	self.status = STATUS_STOP
	self._curVal = self._downloadSize + self._curVal 		-- 暂停时保存当前下载进度
	self:stopResDownLoad()
end

function ResDownloadModel:clear()
	self:stopResDownLoad()
end

function ResDownloadModel:resDownLoad_file(_,fileName)

	--LuaLog("resDownLoad_file:"..fileName)
	if cc.TextureCache:getInstance():getTextureForKey(fileName) then
		--LuaLog("reloadTexture :"..fileName)
		local fullpath = cc.FileUtils:getInstance():fullPathForFilename(fileName)
		cc.TextureCache:getInstance():renameTextureWithKey (fileName,fullpath)
		--cc.TextureCache:getInstance():reloadTexture(fileName)
	else
		--LuaLog("UIPackage:reloadTempTexture:"..fileName)
		fgui.UIPackage:reloadTempTexture(fileName)
	end
	
end

return ResDownloadModel
