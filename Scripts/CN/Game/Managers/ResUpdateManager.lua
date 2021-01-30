module("ResUpdateManager", package.seeall)

------可修改控制参数---------------------------------------------------
--是否输出log
local NEED_LOG = true
--最大log文件大小（字节）
local MAX_LOG_SIZE = 1024 * 1024 --1M

--下载重试的最大次数
local downloadRetryTimes = 3
------内部使用参数-----------------------------------------------------------
local maxDownloadNum = 2                        --最大同时下载数量
local isInited = false                          --是否初始化
local working = false                           --是否检查下载中
--初始化参数
local downloadURLList = false                   --下载地址队列，按顺序一个一个尝试去下载，都失败了才认为下载失败
local serverListMD5 = false                     --最新资源列表MD5
local localServerListMD5 = ""                   --本地资源列表MD5
local latestCodeVersion = false                 --最新代码版本号
local forceUpdateResVersion = false             --强制更新的资源版本号
local latestResVersion = false                  --最新资源版本号
local isUpdateServerList = false                --本次启动是否更新过列表
local initParams = false                        --初始化参数表，用于脚本更新完成后重启LuaEngine时初始化数据

--回调方法
local onEndHandler = false                      --结束回调
local onComparingHandler = false                --检查过程回调
local onDownloadingHandler = false              --下载过程回调
local onAlertHandler = false                    --提示回调

--文件列表
local serverResList = {}                        --服务器资源列表（源结构，程序使用）
local serverResDict = {}                        --服务器资源列表（字典结构，程序使用）
local md5AssetsExists = {}                      --大量fileUtil:isFileExist会导致长时间无响应，lua维护一份存在列表
local md5Pack1Exists = {}                       --大量fileUtil:isFileExist会导致长时间无响应，lua维护一份存在列表
local missingDownloadingAssets = {}             --正在下载的资源
local packetDownloadingAssets = {}                 --正常分包下载

--下载队列控制参数
local downloadQueue = {}     --下载队列
local priorityQueue = false     --优先队列,里面资源顺序跟游戏运行顺序一致

--下载统计
local totalDLSize = 0           --总的资源大小
local currentDLSize = 0         --当前已经下载的资源大小

local curPacketTotalNum = 0     --当前分包总下载数
local curPacketTotalSize = 0    --当前分包总下载大小

local curPacketSuccessNum = 0   --下载成功的资源数
local curPacketSuccessSize = 0  --下载成功的资源大小

local downloadingNum = 0        --下载中的资源数
local downloadTime = 0          --下载开始时间

local curPacketFailedNum = 0    --最终下载失败的资源数
local curPacketFailedSize = 0   --最终下载失败的资源大小

local failedList = {}           --最终下载失败记录

-- 下载次数失败记录
local failedRecord = {}
local failedRecordForPackageIndex = {} -- 顺便记录是哪包的
-- 下载中的资源记录
local bufferRecord = {}

--是否更新了脚本
local isKeyResUpdated = false
--是否游戏内的分包更新
local isGameDownload = false
--资源比对范围
local minCompareIndex = 0
local maxCompareIndex = 0
--资源下载范围
local minDownloadIndex = 0
local maxDownloadIndex = 0

local fileUtil = cc.FileUtils:getInstance()
local writablePath = fileUtil:getWritablePath()     --可写路径

--更新路径
local updatePath = gy.GYScriptManager:getInstance():getUpdateDirectory()

--更新数据存放路径
local updateInfoFilePath = gy.GYScriptManager:getInstance():getUpdateInfoFilePath()

local needPurgeGame = false

local frClientTbl = {}
local timer = false

local dirCreateCache = {}
local dirMissingResInPackageDownload = {}

local urlCheckList = {}
local urlCheckTimer = false
local urlFailList = {}
local urlReportTime = 0
--脚本下载队列
local keyResCheckDict = {}              --放待更新的S和U路径，等全部都下载完成后才把"@"后缀去掉
local keyResDownloadQueue = {}       --用于存放待下载的补丁脚本文件，需要在确保基础脚本更新成功之后再去下载

local baseScriptName = "ScriptS"       --基础脚本包名称
local patchScriptName = "ScriptU"      --补丁脚本包名称

local ResPathConfig = {
    ServerResList = "server_res_list.data",
    LogText = "resLog.txt",
}

local backupURLList = false                     --备机地址列表
local backupAccess = 0                          --访问备机地址次数
local backupConfigList = {}


local downLoadCount = 5

local TABLE_INSERT = table.insert
local TABLE_REMOVE = table.remove

local STRING_FIND = string.find
local STRING_SUB = string.sub
local STRING_FORMAT = string.format

local private = {}

function private.divineParams(paramStr)
    return json.decode(paramStr)
end

function private.combineParams()
    return json.encode(initParams)
end

function private.saveParams()
    if initParams then
        setUpdateInfo("ResUpdateParams", private.combineParams())
    end
end


local miniTimeout = 15       --最小超时时间(秒)
local maxTimeout = 3600      --最大超时时间(秒)
local baseSpeed = 10 * 1024  --计算超时的默认网络下载速度(字节/秒)
--[[
    根据资源大小动态计算下载超时时间
    @param  resSize     资源大小(字节)
    @return [int]       超时时长(秒)
--]]
function private.getTimeoutByResSize(resSize)
    if type(resSize) ~= "number" then resSize = 0 end

    local calTime = math.ceil(resSize / baseSpeed)
    if calTime < miniTimeout then
        return miniTimeout
    elseif calTime > maxTimeout then
        return maxTimeout
    else
        return calTime
    end
end

--[[
    获取下载节点IP地址
--]]
function private.getIpByDownloadURL(url)
    if type(url) ~= "string" then url = "" end
    local ip
    local startIdx = STRING_FIND(url, "//")
    local endIdx = STRING_FIND(url, "/update/")
    if startIdx and endIdx then
        ip = gy.GYHttpClient:getIpByDomainName(STRING_SUB(url, startIdx + 2, endIdx-1))
    end
    return ip or ""
end

--[[
    是否是脚本资源(0-非关键非脚本资源 1-脚本资源 3-关键非脚本资源ResourceC0、ResourceC1、协议等等)
--]]
function private.isScriptRes(resType)
    return resType and resType == 1
end

--[[
    是否是基础脚本(ScriptS)
--]]
function private.isBaseScript(resPath, resType)
    local ret = false
    if private.isScriptRes(resType) then
        local b = STRING_FIND(resPath, baseScriptName)
        if b then
            ret = true
        end
    end
    return ret
end

function private.isKeyRes(resType)
    return resType == 1 or resType == 3
end

--[[
    是否关键资源(0-非关键非脚本资源 1-脚本资源 3-关键非脚本资源)
    全部下载成功后再一起替换，purgeGame()后生效
--]]
function private.isForceUpdateRes(resType)
    --脚本
    if resType == 1 then
        -- 判断该次更新的脚本是否必须下载到
        if private.isForeceUpdate() then
            return true
        end

    --关键资源
    elseif resType == 3 then
        return true
    end

    return false
end

--[[
    资源替换为zip格式
--]]
function private.getZip(resPath)
    return string.gsub(resPath, "%.%a+","%.zip")
end

--[[
    获取文件名
--]]
function private.getFileName(resPath)
    return string.gsub(resPath, "(.*/)","")
end

--[[
    获取去掉后缀的文件名
--]]
function private.getNoSubfixFileName(resPath)
    local fileName = private.getFileName(resPath)
    return string.gsub(fileName, "%.%a+","")
end

--[[
    获取下载保存文件名, 关键资源先保存成临时文件
--]]
function private.getSaveName(resPath, resType)
   if private.isKeyRes(resType) then
        return private.getFileName(resPath) .. "@"
   end
    return private.getFileName(resPath)
end

--[[
    获取保存文件路径
    @param      resPath     包含文件名的全路径
    @return     [string]    目录路径
--]]
function private.getSavePath(resPath)
    if type(resPath) ~= "string" then resPath = "" end

    local sPath = ""
    local b = STRING_FIND(resPath, "/")
    if not b then
        sPath = ""
    else
        sPath = string.gsub(resPath, "(.*/).*","%1")
    end
    return sPath
end

--[[
    是否是arm64设备
--]]
function private.isArm64Device()
    return gy.GYDeviceUtil:isArm64Device()
end

--本地记录数据相关----------------------------------------------------
function private.saveUpdateInfo(info)
    info = info or {}
    local str = json.encode(info)
    fileUtil:writeStringToFile(str, updateInfoFilePath)
end

function private.loadUpdateInfo()
    if fileUtil:isFileExist(updateInfoFilePath) then
        local str = fileUtil:getStringFromFile(updateInfoFilePath)
        local info = json.decode(str)
        if type(info) == "table" then
            return info
        end
    end
    return {}
end

function getUpdateInfo(key, default)
    local info = private.loadUpdateInfo()
    return info[key] or default
end

function setUpdateInfo(key, value)
    local info = private.loadUpdateInfo()
    info[key] = value
    private.saveUpdateInfo(info)
end

--[[
    获取本地包号
--]]
function private.getLocalPackageID()
    return getUpdateInfo("loadedRes", 1)
end

--[[
    获取连续下载数
--]]
function private.getDownloadRepeatTime()
    return getUpdateInfo("dRepeat", 0)
end

--[[
    设置连续下载数
--]]
function private.setDownloadRepeatTime(value)
    setUpdateInfo("dRepeat", value)
end

--[[
    获取检查记录
--]]
function private.getCheckedContent()
    return getUpdateInfo("checkedContent", "")
end

--[[
    设置检查记录
    @params serverListMD5   完成检查的资源列表MD5
    @params pID             完成检查的分包数
--]]
function private.setCheckedContent(serverListMD5, pID)
    if type(serverListMD5) ~= "string" or type(pID) ~= "number" then 
        return 
    end

    setUpdateInfo("checkedContent", STRING_FORMAT("%s%d", serverListMD5, pID))
end

--[[
    获取资源版本号
--]]
function private.getResVerison()
    return getUpdateInfo("keyResVer", 0)
end

--[[
    设置资源版本号
--]]
function private.setResVersion(resVer)
    if type(resVer) ~= "number" then 
        return 
    end

    setUpdateInfo("keyResVer", resVer)
end

--[[
    读取删除标记
--]]
function private.getRemoveMark()
    return getUpdateInfo("rMark", 0)
end

--[[
    设置删除标记
--]]
function private.setRemoveMark(value)
    if type(value) ~= "number" then 
        return 
    end

    setUpdateInfo("rMark", value)
end

-------------方法---------------------------------------------------------------
--[[
    是否为code版本升级
--]]
function private.isUpgradingCodeVersion()
    if type(latestCodeVersion) == "string" and __SCRIPT_VERSION__ ~= latestCodeVersion then
        return true
    end
    return false
end

--[[
    资源版本是否有效
--]]
function private.isResVersionAvailble()
    if type(forceUpdateResVersion) == "number" and private.getResVerison() < forceUpdateResVersion then
        return false
    end
    return true
end

--[[
    是否为强制更新
--]]
function private.isForeceUpdate()
    -- do return true end
    if private.isUpgradingCodeVersion() or not private.isResVersionAvailble() then
        return true
    end
    return false
end

--[[
    资源更新结束回调
    @param code     更新结果
    @param info     更新结束信息
    @param exParam  是否更新了脚本
--]]
function private.runEndHandler(code, info, exParam)
    if type(onEndHandler) == "function" then
        onEndHandler(code, info, exParam)
        return true
    end
    return false
end


--[[
    获取已经下载的资源总大小
--]]
function private.getBufferSize()
    local bufferSize = 0
    for _, v in pairs(bufferRecord) do
        bufferSize = bufferSize + v
    end
    return bufferSize
end

    -- "bufferByte"    = 684126
    -- "currentDLSize" = 53707533
    -- "failedByte"    = 0
    -- "failedNum"     = 0
    -- "successByte"   = 82523
    -- "successNum"    = 3
    -- "time"          = 2.186
    -- "totalByte"     = 18670730
    -- "totalDLSize"   = 604359389
    -- "totalNum"      = 160

--[[
    资源下载回调
--]]
function private.runDownloadHandler()
    if type(onDownloadingHandler) == "function" then
        local dict = {
            totalNum = curPacketTotalNum, -- 当前分包总下载数 160
            successNum = curPacketSuccessNum,--下载成功的资源数 3
            failedNum = curPacketFailedNum,--最终下载失败的资源数 0
            totalByte = curPacketTotalSize,--当前分包总下载大小 17.80m
            successByte = curPacketSuccessSize,--下载成功的资源大小 0.07m
            failedByte = curPacketFailedSize,--最终下载失败的资源大小 0
            
            totalDLSize = totalDLSize,--总的资源大小 576.36m
            currentDLSize = currentDLSize,--当前已经下载的资源大小 51.21m
            
            bufferByte = private.getBufferSize(), --正下到一半的大小 0.65m
            time = downloadTime, --已下载时间 2.18
        }
        onDownloadingHandler(dict)
        return true
    end
    return false
end

--[[
    提示框回调
--]]
function private.runAlertHandler(confirmCallback, cancelCallback, data)
    if type(onAlertHandler) == "function" then
        onAlertHandler(confirmCallback, cancelCallback, data)
    else
        if type(confirmCallback) == "function" then
            confirmCallback()
        end
    end
end

--[[
    检查设备空间是否足够
--]]
function private.isSpaceEnough(needSpace)
    if type(needSpace) ~= "number" then
        needSpace = 0
    end
    local deviceSpace = fileUtil:getAvailableSize()

    if needSpace > deviceSpace then
        return false
    end

    return true
end

--[[
    失败次数
--]]
function private.getFailedRecord(resPath)
    return failedRecord[resPath] or 0 , failedRecordForPackageIndex[resPath] or 1
end

--[[
    失败次数
--]]
function private.setFailedRecord(resPath, times, packageIndex)
    failedRecord[resPath] = times
    failedRecordForPackageIndex[resPath] = packageIndex
end

function getAllFailedRecord()
    return failedRecord, failedRecordForPackageIndex
end

function getMaxFailedTimes()
    return #downloadURLList
end

--[[
    添加一个数据到下载队列
    @param  resPath     待下载文件路径
--]]
function private.pushKeyResDownloadQueue(resPath)
    --初始化下载队列    
    TABLE_INSERT(keyResDownloadQueue, resPath)
end

--[[
    从下载队列取出一个数据
--]]
function private.popKeyResDownloadQueue()
    return TABLE_REMOVE(keyResDownloadQueue, 1) or false
end

--[[
    添加一个数据到下载队列
    @param  resPath     待下载文件路径
--]]
function private.pushDownloadQueue(resPath)
    --初始化下载队列    
    TABLE_INSERT(downloadQueue, resPath)
end

--[[
    从下载队列取出一个数据
--]]
function private.popDownloadQueue()    
    if #downloadQueue <= 0 then
        return false
    else
        return TABLE_REMOVE(downloadQueue, 1)
    end
end

--[[
    删除Log文件
--]]
function private.removeLogFile()
    if NEED_LOG then
        local filePath = STRING_FORMAT("%s%s", writablePath, ResPathConfig.LogText)
        local fileSize = -1
        if fileUtil:isFileExist(filePath) then
            fileSize = fileUtil:getFileSize(filePath)
        end

        print(10, "###check log file size ", fileSize, MAX_LOG_SIZE)
        if fileSize >= MAX_LOG_SIZE then
            fileUtil:removeFile(filePath)
        end
    end
end

--根据文件名获取真正的资源路径
local function getRealResPath(fmd5)
    if not fmd5 or fmd5 == "" then
        return ""
    end
    return STRING_FORMAT("GameAssets/%s", fmd5)
end


--[[
    保存Log数据
--]]
function private.saveLog(logStr)
    if NEED_LOG then
        gy.GYStringUtil:appandStringToFile(ResPathConfig.LogText, logStr)
    end
end

--[[
    获取对应文件路径的下载包路径
--]]
function private.getDownloadURL(resPath, needMD5, failedTimes, resType)
    if not failedTimes then 
        failedTimes = 0 
    end

    if not downloadURLList or failedTimes >= #downloadURLList then
		if os.time() > urlReportTime + 5 then
			urlReportTime = os.time()
			local reason = urlFailList[resPath] or "--"
			SDKUtil.reportDownLoadError(string.format("download fail:url=%s",resPath),string.format("tryTime:%d\n reason:%s",tonumber(failedTimes),reason ))
        end
		LuaLogE(STRING_FORMAT("not downloadURLList or failedTimes >= #downloadURLList %s", failedTimes >= #downloadURLList,failedTimes))
        return
    end

    local URLInfo = downloadURLList[failedTimes + 1]
    if resType ~= 1 and private.isKeyRes(resType) then
        -- 普通资源，名字已经带有md5
        return STRING_FORMAT("%s%s?v=%s", URLInfo.url, resPath, needMD5), URLInfo.ip
    else    
        return STRING_FORMAT("%sGameAssets/%s", URLInfo.url, needMD5), URLInfo.ip
    end
end

--[[
    从文件读取内容作为table返回
    @param      filePath        读取的文件路径
--]]
function private.readTableFromFile(filePath)
    --读取文件内容
    local str = fileUtil:getStringFromFile(writablePath .. filePath)
    --如果为空退出
    if not str or str == "" then
        return false
    end

    local fromIndex, strLen = 1, string.len(str)
    local normalRes = {}
    local resultT = {normalRes}

    local pairs = pairs
    while true do
        local from, to = STRING_FIND(str, ",\n\n", fromIndex)
        if not from then
            from = strLen-1
        else
            from = from - 1
        end
        
        local tmpStr = STRING_SUB(str, fromIndex, from)
        LuaLogE("server_res_list split position:", fromIndex, from, to, strLen)
        local t = dostring(STRING_FORMAT("return {%s}", tmpStr))
                
        for k, v in pairs(t) do
            local tag = TABLE_REMOVE(v,1)
            if tag == 1 then                
                normalRes[#normalRes+1] = v
            else
                resultT[#resultT + 1] = v
            end            
        end

        if not to then
            break
        end
        fromIndex = to + 1
    end
    LuaLogE("server_res_list result table len:", table.nums(resultT))
    return resultT
end

--[[
    加载服务器文件列表和字典
--]]
function private.loadServerResListAndDict()
    serverResDict = {}
    serverResList = private.readTableFromFile(ResPathConfig.ServerResList) or {}    
    local len = #serverResList
    if len == 0 then
        LuaLogE("server list is empty!!!")
        return
    end

    local assetsList = serverResList[1]
    if type(assetsList) ~= "table" then
        serverResList = {}
        LuaLogE("server list group 1 is not a table!!!")
        return
    end

    totalDLSize = 0
    local assetsLen = #assetsList
    for i = 1, assetsLen do -- ipairs性能不怎么好
        local resInfo = assetsList[i]

        local name = getRealResPath(resInfo[1])
        totalDLSize = totalDLSize + resInfo[4]
        serverResDict[name] = resInfo
    end
    
    --S、U、C0、C1之类的特殊资源
    for i = 2, len do
        local specResInfo = serverResList[i]
        local name = specResInfo[1]
		if specResInfo[4] == 1 then
			name = getRealResPath(specResInfo[2])
		end
		serverResDict[name] = { specResInfo[2], specResInfo[3], specResInfo[4], specResInfo[5] }
		

        totalDLSize = totalDLSize + specResInfo[5]
    end
end

--[[
    扫描目录中的所以存在文件
--]]
function private.scanExistMd5Assets()
    -- update目录
    md5AssetsExists = {}

    local function scan(data)
        local needDeleteRes = {}
        for k, v in pairs(data) do
            if not v.isdir then
                local needDelete
                local fullPath = v.path
                if fullPath ~= "" then
                    local ext = STRING_SUB(fullPath, -4,-1)
                    if ext == ".tmp" then
                        needDeleteRes[fullPath] = true
                        needDelete = true
                    end
                end

                if not needDelete then
                    local resPath = private.getNativePathFromFullPath(fullPath, updatePath)
                    md5AssetsExists[resPath] = true
                end
            end
        end

        for k,_ in pairs(needDeleteRes) do
            fileUtil:removeFile(k)
        end
    end
    fileUtil:visitDirectory(scan, updatePath, true)

    -- 包1资源
    md5Pack1Exists = {}
    for i, v in ipairs(cc.ResourceManager:getInstance():getPack1List()) do
        if v and v ~= "" then
            md5Pack1Exists[v] = true
        end
    end
end

----------------------------------------------------------------------------
function private.stopDownloadCallbackTimer()
    if timer then
        Scheduler.unschedule(timer)
        timer = false
    end
end

function private.startDownloadCallbackTimer()
    if not timer then
        local callbackInterval = 0.1   --进度条平滑一些
        local startTime = cc.millisecondNow()
        local function doCallback()
            downloadTime = (cc.millisecondNow() - startTime) * 0.001
            private.runDownloadHandler()
        end
        timer = Scheduler.schedule(doCallback, callbackInterval)
    end
end


function private.stopCheckDownloadTimeOut()
	if urlCheckTimer then
		Scheduler.unschedule(urlCheckTimer)
	end
	urlCheckTimer = false
end

function private.startCheckDownloadTimeOut()

	if not urlCheckTimer then
		local callbackInterval = 6 --7秒执行一次
		
		local function doCallback()
			local curTime = os.time()
			for k,v in pairs(urlCheckList) do
				local costTime = curTime - v.time

				if costTime > 5 then

					SDKUtil.reportDownLoadError(string.format("timeOut:url=%s",k),string.format("tryTime:%d",tonumber(v.ftime) ))
					urlCheckList[k] = nil
					break
				end
			end
		end
		urlCheckTimer = Scheduler.schedule(doCallback, callbackInterval)
	end
end

function private.cleanupData()
    --清除统计数据
    curPacketTotalNum = 0
    curPacketTotalSize = 0

    curPacketSuccessNum = 0
    curPacketSuccessSize = 0

    curPacketFailedNum = 0
    curPacketFailedSize = 0

    downloadingNum = 0
    downloadTime = 0

    failedList = {}
    failedRecord = {}
    bufferRecord = {}

    isKeyResUpdated = false
    isGameDownload = false
    --清除下载和比较队列
    downloadQueue = {}
    keyResCheckDict = {}
    keyResDownloadQueue = {}
    --释放资源表
    isUpdateServerList = false
end

function private.cleanupHandler()
    onComparingHandler = false
    onDownloadingHandler = false
    onEndHandler = false
end

function private.unusedProgressHandler() 
end

function private.checkFinish(code, info, exParam)
    if not working then
        return
    end
    --设置检查标志位
    working = false

    private.stopDownloadCallbackTimer()
	private.stopCheckDownloadTimeOut()
    private.runDownloadHandler()

    local downloadIPText = ""
    local function getDownloadIPText()
        if downloadURLList and downloadIPText == "" then
            for k, v in ipairs(downloadURLList) do
                downloadIPText = downloadIPText .. v.ip
                if k < #downloadURLList then
                    downloadIPText = downloadIPText .. "，"
                end
            end
        end
        return downloadIPText
    end

    local failedText = false
    if code == 1 or code == 5 then
        if code == 5 then
            currentDLSize = totalDLSize
            -- if Dispatcher then
            --     Dispatcher.dispatchEvent("addPrompt",GlobalUtil.getPromptKey(ModuleType.DOWNLOAD_GIFT))
            -- end
        end

        private.setDownloadRepeatTime(0)
        private.setCheckedContent(serverListMD5, private.getLocalPackageID())
        private.setResVersion(latestResVersion)
    elseif code == 2 then
        private.setResVersion(latestResVersion)
        local numFailed = #failedList
        if numFailed > 0 then
            failedText = STRING_FORMAT(Desc.resupdate_tips1, numFailed, getDownloadIPText())
            for i, v in ipairs(failedList) do
                if i > 50 then
                    break
                end
                failedText = STRING_FORMAT("%s\n%s(%s)", failedText, v[1], v[2])
            end
        end
    elseif code == 104 then
        failedText = STRING_FORMAT(Desc.resupdate_tips2, info, getDownloadIPText())
    elseif code == 105 then
        failedText = STRING_FORMAT(Desc.resupdate_tips3, info, getDownloadIPText())
    elseif code == 106 then
        failedText = Desc.resupdate_tips4
    elseif code == 107 then
        failedText = STRING_FORMAT(Desc.resupdate_tips5, info)
    elseif code == 109 then
        failedText = STRING_FORMAT(Desc.resupdate_tips6, info)
    end

    if failedText then
        LuaLogE("~~~~~download exist some error!~~~~", failedText,debug.traceback())
        PHPUtil.reportBug(BugInfoType.RES_UPDATE_FAILED, failedText)
    end

    print(1,code,info,exParam)
    private.runEndHandler(code, info, exParam)
    --清除数据
    private.cleanupData()
    --清除回调
    private.cleanupHandler()
end

--[[
    删除标记的资源
--]]
function private.removeMarkedRes()
    --读取删除标记
    local removeMark = private.getRemoveMark()
    if removeMark > 0 then
        for resPath, resInfo in pairs(serverResDict) do
            --取包号
            local resPackageIndex = resInfo[2]
            if resPackageIndex and resPackageIndex <= removeMark then
                --删除update目录下的旧文件
                fileUtil:removeFile(STRING_FORMAT("%s%s", updatePath, resPath))
            end
        end
    end
    --还原标记
    private.setRemoveMark(0)
end

--[[
    根据完整路径获取相对与prePath的相对路径
--]]
function private.getNativePathFromFullPath(fullPath, prePath)
    local len = string.len(prePath)
    local preSub = STRING_SUB(fullPath, 1, len)
    if preSub ~= prePath then
        return fullPath
    else
        return STRING_SUB(fullPath, len + 1)
    end
end

--[[
    检查资源是否不在资源列表中
--]]
function private.checkIsUnsedRes(resPath)
    return not serverResDict[resPath]
end

--[[
    清除update目录下不再使用的旧资源
--]]
function private.cleanupUnusedRes()
    local function deleteUnusedRes(data)
        if type(data) ~= "table" then 
            return 
        end
        for k, v in pairs(data) do
            --如果非文件夹再去查找资源列表是否存在
            if not v.isdir then
                local fullPath = v.path
                local resPath = private.getNativePathFromFullPath(fullPath, updatePath)
                if private.checkIsUnsedRes(resPath) then
                    fileUtil:removeFile(fullPath)
                end
            end
        end
    end
    --递归遍历update目录
    fileUtil:visitDirectory(deleteUnusedRes, updatePath, true)
end

--[[
    从文件读取内容作为table返回
    @param      filePath        读取的文件路径
--]]
function private.getTableFromFile(filePath)
    --读取文件内容
    local str = fileUtil:getStringFromFile(filePath)
    --如果为空退出
    if not str or str == "" then
        return false
    end

    local fromIndex, strLen = 1, string.len(str)
    local resultT = {}

    local pairs = pairs
    while true do
        local from, to = STRING_FIND(str, ",\n\n", fromIndex)
        if not from then
            from = strLen-1
        else
            from = from - 1
        end
        
        local tmpStr = STRING_SUB(str, fromIndex, from)
        LuaLogE("getTableFromFile split position:", fromIndex, from, to, strLen)
        local t = dostring(STRING_FORMAT("return {%s}", tmpStr))
                
        for k, v in pairs(t) do            
            resultT[#resultT + 1] = v
        end

        if not to then
            break
        end
        fromIndex = to + 1
    end
    LuaLogE("getTableFromFile result table len:", table.nums(resultT))
    return resultT
end

--[[
    初始化下载队列
--]]
function private.initDownloadQueue(checkScriptRes)
    needPurgeGame = false

    local assetsList = serverResList[1]
    if type(assetsList) ~= "table" then
        LuaLogE("initDownloadQueue serverResList content is not correct")
        private.saveLog("initDownloadQueue serverResList content is not correct")
        --读取资源信息失败，检查结束
        private.checkFinish(106)
        return false
    end

    local assetsLen = #assetsList
    --已经处理的资源
    LuaLogE(STRING_FORMAT("current maxCompareIndex: %s",maxCompareIndex))
    currentDLSize = 0

    --已经加到下载队列的资源
    local dealedAssets = {}

    --五个分包内的资源都按照顺序下载
    if maxCompareIndex <= 4 then
        if not priorityQueue then
            priorityQueue = private.getTableFromFile("priorityQueue.txt")
        end

        if priorityQueue and next(priorityQueue) then
            local tmpMap = {}
            for i = 1, assetsLen do 
                local resInfo = assetsList[i]
                local fmd5 = resInfo[1]
                tmpMap[fmd5] = resInfo
                --LuaLogE("tmpMap: " .. fmd5)
            end

            local len = #priorityQueue
            for i = 1, len do 
                local relPath = priorityQueue[i]
                --LuaLogE("relPath: " .. relPath)
                local remapName = fileUtil:getNewFilename(relPath)
                --LuaLogE("remapName: " .. remapName)
                if remapName ~= "" then
                    local resInfo = tmpMap[remapName]
                    if resInfo then
                        --取包号
                        local resPackageIndex = resInfo[2]
                        if resPackageIndex and resPackageIndex <= maxCompareIndex then
                            local fmd5 = remapName
                            local resPath = getRealResPath(fmd5)
                            --LuaLogE("resPath: " .. resPath)
                            if not dealedAssets[fmd5] and not md5AssetsExists[resPath] and not md5Pack1Exists[fmd5] then
                                LuaLogE(string.format("dealedAssets:%s  [%s] ", fmd5,relPath))
                                dealedAssets[fmd5] = true
                                --加入下载队列
                                private.pushDownloadQueue(resPath)
                                --记录下载个数
                                curPacketTotalNum = curPacketTotalNum + 1
                                --记录下载资源总大小
                                curPacketTotalSize = curPacketTotalSize + resInfo[4]
                            end
                        end
                    end
                end
            end
        else
            LuaLogE("加载队列失败!")
            priorityQueue = false
        end
    else
        LuaLogE("超出了按序下载分包范围")
        priorityQueue = false
    end

    LuaLogE(STRING_FORMAT("curPacketTotalNum: %s", curPacketTotalNum))

    local resourceManager = cc.ResourceManager:getInstance()
    for i = 1, assetsLen do
        local resInfo = assetsList[i]
        --取包号
        local fmd5 = resInfo[1]
        local resPackageIndex = resInfo[2]
        if resPackageIndex > maxCompareIndex+1 then
            local rawFileName = resourceManager:getRawNameByRealName(fmd5)
            LuaLogE(STRING_FORMAT("res pack index:%s file: %s", resPackageIndex, rawFileName))
            break
        end
        
        local existRes
        local resPath = getRealResPath(fmd5)
        if md5AssetsExists[resPath] or md5Pack1Exists[fmd5] or dealedAssets[fmd5] then
            currentDLSize = currentDLSize + resInfo[4]
            existRes = true
        end

        if resPackageIndex <= maxCompareIndex then
            if not existRes then
                --加入下载队列
                private.pushDownloadQueue(resPath)
                --记录下载个数
                curPacketTotalNum = curPacketTotalNum + 1
                --记录下载资源总大小
                curPacketTotalSize = curPacketTotalSize + resInfo[4]
            end
        end
    end


    local checkImportentRes = {}

    if checkScriptRes then
        -- 重要资源检查
        local len = #serverResList
        for i = 2, len do
            local specResInfo = serverResList[i]
            local resName = specResInfo[1]
            local resMD5 = specResInfo[2]
            local resType = specResInfo[4]
            resMD5 = STRING_SUB(resMD5,5, -1)
			if resType == 1 then
				resName = getRealResPath(specResInfo[2])
			end
			--LuaLogE(resName.." specResInfo = "..specResInfo[4])
			
            private.removeFullPathCache(resName)

            -- 重要资源文件检查
            if resMD5 ~= gy.GYStringUtil:getFileMD5(resName) then
                needPurgeGame = true  --游戏需要重启,缺资源下载就暂停了
                isKeyResUpdated = true   --有重要文件需要更新或者重命名            

                md5AssetsExists[resName] = nil            
                local tmpFile = STRING_FORMAT("%s%s@", updatePath, resName)
                local md5 = gy.GYStringUtil:getFileMD5(tmpFile)

                --临时文件检查
                if resMD5 ~= md5 then
                    -- 删除临时文件
                    fileUtil:removeFile(tmpFile)
                    fileUtil:removeFile(tmpFile..".tmp")
                    LuaLogE("==== need update key res: " .. tmpFile)
                    -- 关联标记，完成后统一替换
                    keyResCheckDict[resName] = false
                    -- 加入下载队列
                    private.pushKeyResDownloadQueue(resName)
                    --记录下载个数
                    curPacketTotalNum = curPacketTotalNum + 1
                    --记录下载资源总大小
                    curPacketTotalSize = curPacketTotalSize + specResInfo[5]
                else
                    -- 关联标记，完成后统一替换
                    keyResCheckDict[resName] = true
                    checkImportentRes[resName] = true
                    currentDLSize = currentDLSize + specResInfo[5]
                end
            end
        end
    end

    local logStr = STRING_FORMAT("~~~~~~ %s files need to download size:%.2fKB ~~~~~~", curPacketTotalNum, curPacketTotalSize/1024)
    LuaLogE(logStr)
    private.saveLog(logStr)

    --已经是最新资源，检查结束
    if curPacketTotalNum == 0 then        
        local needPurge
        for resName,_ in pairs(checkImportentRes) do 
            LuaLogE(STRING_FORMAT("~~~~~~ Need replace resource: %s ~~~~~~~",resName))
            needPurge = true
            local replaceRes = STRING_FORMAT("%s%s", updatePath, resName)
            local tempRes = replaceRes.."@"
            if not fileUtil:renameFile(tempRes, replaceRes) then
                LuaLogE(STRING_FORMAT("file %s rename to %s failed", tempRes, replaceRes))
            end
        end

        if needPurge then
            LuaLogE("~~~~~~ Script rename done, restart game!  ~~~~~~~")
            stopDownload()
			VersionChange:clear()
            Scheduler.scheduleOnce(0.5, function()
                GlobalUtil.purgeGame()
            end)
            return false
        end

        private.checkFinish(5)
        return false
    end

    return true
end

--[[
    重命名关键资源
	添加了isEnd参数
	G1 项目脚本作为单个文件更新,关键资源的重命名放到全部包1资源下载完毕的时候执行
	
]]
function private.checkIfRenameKeyRes(isEnd)

	if not isEnd then return end
	
    if not next(keyResCheckDict) then
        return
    end

    local keyResUnFinish
    for k, v in pairs(keyResCheckDict) do
        if not v then
            keyResUnFinish = k
            break
        end
    end

    if keyResUnFinish then
        LuaLogE("====  key res wait to update: " .. keyResUnFinish)
        return
    end

    -- 必须等全部脚本验证通过，才能删除存在的源脚本文件
    LuaLogE(STRING_FORMAT("ready to rename key res: %s",cc.millisecondNow()))
    for k, _ in pairs(keyResCheckDict) do
        --替换资源全路径:verifyRes去掉@后缀
        local replaceRes = STRING_FORMAT("%s%s", updatePath, k)
        --下载资源全路径:updatePath+resPath
        local tempRes = replaceRes.."@"
        if not fileUtil:renameFile(tempRes, replaceRes) then
            LuaLogE(STRING_FORMAT("~~~~~ file %s rename to %s failed", tempRes, replaceRes))
        else
            LuaLogE(STRING_FORMAT("~~~~~ replace script from %s to %s ",tempRes, replaceRes))
        end
    end

    keyResCheckDict = {}
    LuaLogE(STRING_FORMAT("key res rename done: %s",cc.millisecondNow()))    
end


--[[
    验证脚本
--]]
function private.verifyKeyRes(resPath, needMd5)    
    --需要的md5
    needMd5 = needMd5 or ""    
    local tmpFile = STRING_FORMAT("%s%s@", updatePath, resPath)
    --下载到文件的MD5
    local gotMd5 = gy.GYStringUtil:getFileMD5(tmpFile)
    --验证结果
    local isCorrect = gotMd5 == needMd5
    
    keyResCheckDict[resPath] = isCorrect
    if not isCorrect then
        local failedText = STRING_FORMAT("关键资源%s更新错误, needMd5:%s gotMd5:%s", resPath,needMd5, gotMd5)
		LuaLogE(failedText)
        PHPUtil.reportBug(BugInfoType.RES_UPDATE_FAILED, failedText)
        
    end
    private.checkIfRenameKeyRes()

    return isCorrect, gotMd5, needMd5
end

--[[
    验证资源
--]]
function private.verifyRes(resPath, resType, needMd5)
    if not resPath or not serverResDict[resPath] then
        return false, "", ""
    end

    if private.isKeyRes(resType) then
        return private.verifyKeyRes(resPath, needMd5)
    else
        private.checkIfRenameKeyRes()
    end

    return true, "", ""
end

--[[
    --清除全路径缓存（避免之前资源全路径缓存为包内的路径导致update目录下的资源没有被读取）
--]]
function private.removeFullPathCache(resPath)
    local removePath = resPath
    if STRING_SUB(resPath, -1) == "@" then
        removePath = STRING_SUB(resPath, 1, -2)
    end
    fileUtil:removeFullPathCache(removePath)
end

--[[
    完成下载队列的文件下载
--]]
function private.doNextDownload()
    local resourceManager = cc.ResourceManager:getInstance()
    while downloadingNum < maxDownloadNum do
        -- 从下载队列取下载数据
        local resPath = false
		downLoadCount = downLoadCount + 1
		if downLoadCount >4 then
			downLoadCount = 0
			resPath = private.popDownloadQueue() or private.popKeyResDownloadQueue()
		else
			resPath = private.popKeyResDownloadQueue() or private.popDownloadQueue()
		end      
        -- 有待下载文件，进入下载处理
        if resPath then
            local resInfo = serverResDict[resPath]
            if resInfo then
                repeat            
                    local resType = resInfo[3]
                    if not private.isScriptRes(resType) then
                        if md5AssetsExists[resPath] then   --已经新下载过了就不用再下载了
                            local resSize = resInfo[4]
                            curPacketSuccessNum = curPacketSuccessNum + 1
                            curPacketSuccessSize = curPacketSuccessSize + resSize
                            print(10,"已经下载过了，无需再次下载",curPacketSuccessSize,resPath)
                            break
                        end 

                        if missingDownloadingAssets[resPath] then
                            print(10,"missing download 正在下载,不必重复下载了",resPath)
                            break
                        end
                    end

                    local key = resPath.."1"
                    if frClientTbl[key] then
                        LuaLogE("res is downloading... " .. resPath)
                        break
                    end

                    local failedTimes = private.getFailedRecord(resPath)

                    local resMD5 = resInfo[1]
                    local resSize = resInfo[4]

                    local dResPath = resPath
                    
                    local updateURL, updateIP = private.getDownloadURL(dResPath, resMD5, failedTimes, resType)
                    -- print(10,"下载信息:",tostring(updateURL),tostring(updateIP),dResPath,resMD5,failedTimes,resType)

                    if not updateURL then
                        curPacketFailedSize = curPacketFailedSize + resSize
                        curPacketFailedNum = curPacketFailedNum + 1
                        private.saveLog(STRING_FORMAT("%s download failed.\n", resPath))

                        if private.isForceUpdateRes(resType) then
                            local fileName = private.getFileName(resPath)
                            private.checkFinish(109, fileName)
                            return
                        end

                        private.doNextDownload()
                        return
                    end

                    -- 下载过程通用回调
                    local function onProgress(dict)
                        --记录下载资源大小
                        bufferRecord[resPath] = dict.dlNow
						
						local checkurl = urlCheckList[updateURL]
						if checkurl then
							checkurl.time = os.time()
						end
                    end

                    resMD5 = STRING_SUB(resMD5, 5, -1)
                    --下载完成回调
                    local function onDownloaded(dict)
                        frClientTbl[key] = nil
						urlCheckList[updateURL] = nil
						
                        downloadingNum = downloadingNum - 1
							--LuaLogE("downloadingNum = ",downloadingNum,resPath)
                        --清除路径缓存
                        local realName = resPath
                        local _,endPos = STRING_FIND(resPath,"GameAssets/")
                        if endPos then
                            realName = STRING_SUB(resPath,endPos+1, -1)
                        end

                        local rawFileName = resourceManager:getRawNameByRealName(realName)
                        private.removeFullPathCache(rawFileName)
                        --print(10,"清除文件缓存", rawFileName)
						LuaLogE(string.format("downloadingNum = %d,  %s", downloadingNum,resPath))

                        packetDownloadingAssets[resPath] = nil
                        bufferRecord[resPath] = nil

                        local isCorrectRes, failedReason = false, dict.dlStatus
                        --下载成功才验证资源的正确性
                        if dict.dlStatus == 0 then
                            local isCorrect, gotMD5, needMD5 = private.verifyRes(resPath, resType, resMD5)
                            --验证资源
                            isCorrectRes = isCorrect
                            if not isCorrect then
                                local pMd5 = tostring(needMD5)
                                local fMd5 = tostring(gotMD5)
                                if string.len(pMd5) > 4 then
                                    pMd5 = STRING_SUB(pMd5, 1, 4)
                                end
                                if string.len(fMd5) > 4 then
                                    fMd5 = STRING_SUB(fMd5, 1, 4)
                                end
                                failedReason = STRING_FORMAT("MD5 not match. need:%s got:%s", pMd5, fMd5)
                            end
                        else
                            failedReason = dict.dlMsg
							xpcall(function()
									urlFailList[dResPath] = json.encode(dict)
							end,__G__TRACKBACK__)
							
                        end

                        if isCorrectRes then
                            print(10,"分包下载资源成功", resPath)
                            md5AssetsExists[resPath] = true

                            curPacketSuccessNum = curPacketSuccessNum + 1
                            curPacketSuccessSize = curPacketSuccessSize + resSize
                            currentDLSize = currentDLSize + resSize

                            -- print(10,"=== 分包下载数量:",curPacketSuccessNum,curPacketSuccessSize)
                            -- 丢失的资源在分包下载中完成
                            private.finishMissingRes(resPath)
                        else
                            private.saveLog(STRING_FORMAT("%s:%s\n", resPath, failedReason))

                            local failedTimes = private.getFailedRecord(resPath)
                            failedTimes = failedTimes + 1
                            private.setFailedRecord(resPath, failedTimes, resInfo[2])
                            private.pushDownloadQueue(resPath)

                            TABLE_INSERT(failedList, {updateURL, failedReason})

                            -- 云测找问题
                            LuaLogE(STRING_FORMAT("%s:%s\n", resPath, failedReason))
                        end
                        private.doNextDownload()
                    end

                    local savePath = STRING_FORMAT("%s%s", updatePath, private.getSavePath(resPath))                    
                    local saveName = private.getSaveName(resPath, resType)
                    if not dirCreateCache[savePath] then
                        dirCreateCache[savePath] = true
                        fileUtil:createDirectory(savePath)
                    end
                    
                    local tmp = resMD5
                    if STRING_SUB(resMD5,-4,-1) == ".mp3" then
                        LuaLogE("1 过滤mp3 " .. tmp)
                        tmp = ""
                    end

                    if GlobalUtil.isPCDownload() then
                        LuaLogE(string.format("~~~正常分包下载: %s %s", savePath, saveName))
                    end

                    frClientTbl[key] = gy.GYHttpClient:download(
                        updateURL, 
                        savePath, 
                        saveName, 
                        onDownloaded, 
                        onProgress, 
                        false, 
                        10, 
                        private.getTimeoutByResSize(resSize),
                        math.max(2,math.floor(maxDownloadNum/2)),
                        tmp
                    )
                    packetDownloadingAssets[resPath] = true
                    downloadingNum = downloadingNum + 1

                until true
            end
        else
            --更新界面更新了关键资源需要重启
            if downloadingNum == 0 then
				private.checkIfRenameKeyRes(true)
                if isKeyResUpdated and not (isGameDownload or next(keyResCheckDict)) then
					currentDLSize = totalDLSize
					private.runDownloadHandler()
                    private.saveParams()
					
					VersionChange:clear()
					-- 跨版本升级检删除不使用的旧资源
					local changeVersion = VersionChange and VersionChange.isChangeVersion
					if __SCRIPT_VERSION__ ~= latestCodeVersion and not changeVersion then
						private.cleanupUnusedRes()
					end
					
                    stopDownload()
					
					
					
                    LuaLogE("~~~~~~ Update done ready to restart game ~~~~~~~")
                    -- 为让下载进度条动画播放完，延时一点重启
                    Scheduler.scheduleOnce(1.5, function()
                        LuaLogE("~~~~~~ Update done restart game ~~~~~~~")
                        GlobalUtil.purgeGame()
                    end)                
                else
                    local logStr = STRING_FORMAT("~~~~~~~~ 分包%d下载完成 是否完整:%d",maxCompareIndex,curPacketSuccessNum >= curPacketTotalNum and 1 or 0)
                    LuaLogE(logStr)
                    private.saveLog(logStr)

                    if curPacketSuccessNum >= curPacketTotalNum then
                        private.checkFinish(1, nil, isKeyResUpdated)
                    else
                        private.checkFinish(2, nil, isKeyResUpdated)
                    end
                end
            else
                LuaLogE(STRING_FORMAT("~~~~~~ downloading res num:%s ~~~~~~~",downloadingNum))
            end
            break
        end
    end
end

--[[
    更新服务器资源列表（当本地保存服务器列表比最新版本低时，从服务器下载最新列表）
    @param  callBack    下载完成回调
    @param  reason      开始下载的原因（可为空，用于在下载失败时重新尝试下载时传入）
--]]
function private.updateServerResList(callBack, reason)
    --设置下载地址
    local zipRes = private.getZip(ResPathConfig.ServerResList)
    local failedTimes = private.getFailedRecord(ResPathConfig.ServerResList)
    local updateURL = private.getDownloadURL(zipRes, serverListMD5, failedTimes, 3)
	
    if not updateURL then
        --获取资源列表下载失败，检查结束
        private.checkFinish(104, reason)
        return
    end

    --标志更新
    isUpdateServerList = true
    local dataRes = STRING_FORMAT("%s%s", writablePath, ResPathConfig.ServerResList)

    local function onDownloaded(dict)
        local isCorrectRes, retryReason = false, dict.dlStatus
        if dict.dlStatus == 0 then
            local gotMD5 = gy.GYStringUtil:getFileMD5(dataRes)            
            LuaLogE(STRING_FORMAT("update serverlist %s %s",tostring(gotMD5),tostring(serverListMD5)))

            if gotMD5 == serverListMD5 then
                isCorrectRes = true
                retryReason = "ok"
            else
                local pMd5 = tostring(serverListMD5)
                local fMd5 = tostring(gotMD5)
                if string.len(pMd5) > 4 then
                    pMd5 = STRING_SUB(pMd5, 1, 4)
                end
                if string.len(fMd5) > 4 then
                    fMd5 = STRING_SUB(fMd5, 1, 4)
                end
                retryReason = STRING_FORMAT("need:%s got:%s", pMd5, fMd5)
            end
        end

        if not isGameDownload or not isCorrectRes then
            private.saveLog(STRING_FORMAT("%s:%s(%s)\n", ResPathConfig.ServerResList, dict.dlStatus, retryReason))
        end

        if isCorrectRes then
            -- 下载成功
            PHPUtil.reportStep(ReportStepType.GET_RES_LIST)
            callBack()
        else
            -- 下载失败
            local failedTimes = private.getFailedRecord(ResPathConfig.ServerResList)
            failedTimes = failedTimes + 1
            LuaLogE(STRING_FORMAT("serverlist download failed: %s", failedTimes))
            private.setFailedRecord(ResPathConfig.ServerResList, failedTimes, 1)
            private.updateServerResList(callBack, retryReason)
        end
    end

    --删除update目录下的旧文件
    fileUtil:removeFile(dataRes)
    --删除update目录下的旧压缩文件
    fileUtil:removeFile(STRING_FORMAT("%s%s", writablePath, zipRes))
    --启动下载
    gy.GYHttpClient:download(updateURL, writablePath, zipRes, onDownloaded, private.unusedProgressHandler)
end

-- 启动界面下载入口
function private.doLoadingDownload()
    -- 当前本地serverResList文件的md5
    localServerListMD5 = gy.GYStringUtil:getFileMD5(STRING_FORMAT("%s%s", writablePath, ResPathConfig.ServerResList))

    -- 检查需要下载serverResList文件的
    if serverListMD5 == "" --最新列表MD5为空
        or localServerListMD5 == "" --本地没有该文件
        or localServerListMD5 ~= serverListMD5 --资源列表与最新不一致
    then
        --没有更新过，执行更新
        if not isUpdateServerList then
            LuaLogE("update ServerList!!!")
            private.updateServerResList(private.doLoadingDownload)
            return
        end
    end

    --如果该列表的检查已经完成，直接退出更新
    local currentPId = private.getLocalPackageID()
    if __SCRIPT_VERSION__ == latestCodeVersion and private.getCheckedContent() == localServerListMD5..currentPId then
        LuaLogE(STRING_FORMAT("serverlist check done %s  %s",tostring(localServerListMD5),tostring(currentPId)))
        --已经是最新资源，检查结束
        private.checkFinish(5)
        return
    end

    if __IN_AUDITING__ then
        -- 审核状态不更新
        private.checkFinish(5)
        return
    end

    private.loadServerResListAndDict()

   

    -- 初始化下载队列
    if private.initDownloadQueue(true) then
        -- 执行一次回调，不然进度条不显示
        if type(onComparingHandler) == "function" then
            onComparingHandler({
                totalNum = 1,
                totalByte = 1,
                comparedNum = 1,
            })
        end
		PHPUtil.reportStep(ReportStepType.UPDATE_BEGIN)
        -- 开始下载
        private.doNextDownload()
        private.startDownloadCallbackTimer()
		private.startCheckDownloadTimeOut()
    end
end

-- 游戏内分包下载入口
function private.doGameDownload(needLoadServerList)
    -- 当前本地serverResList文件的md5
    localServerListMD5 = gy.GYStringUtil:getFileMD5(STRING_FORMAT("%s%s", writablePath, ResPathConfig.ServerResList))
    -- 检查需要下载serverResList文件的
    if serverListMD5 == "" --最新列表MD5为空
        or localServerListMD5 == "" --本地没有该文件
        or localServerListMD5 ~= serverListMD5 --资源列表与最新不一致
    then
        LuaLogE(STRING_FORMAT("###Compare ResList MD5 local: %s, server:%s",tostring(localServerListMD5),tostring(serverListMD5)))
        -- 没有更新过，执行更新
        if not isUpdateServerList then
            LuaLogE("do update serverResList:")
            private.updateServerResList(private.doGameDownload)
            return
        end
    end

    if needLoadServerList then
        LuaLogE("游戏内下载,重新加载serverList")
        private.loadServerResListAndDict()
    else
        LuaLogE("游戏内下载,无需反复加载serverList")
    end
    
    -- 初始化下载队列
    if private.initDownloadQueue() then
        -- 开始下载
        private.doNextDownload()
        private.startDownloadCallbackTimer()
    end
end

----外部调用方法---------------------------------------------------------------------
--[[
初始化方法
@param  latCodeVersion      #string     当前服务器资源列表版本号
@param  resURL              #string     资源下载路径
@param  md5                 #string     服务器资源列表md5
@param  repeatToBackup      #number     失败多少次后切备机
@param  percent             #number     切备机的机率
@param  cdnDomain           #table      备用cdn地址 
@param  clientDomain        #table      备机地址 
@param  forceUpVersion      #string     强制更新资源版本
@param  latResVersion       #string     最新资源版本
--]]
function init(params)
    params = params or {}
    
    -- printTable(10,"初始化下载", params)

    --下载地址
    local resURL = params.resURL

    if type(resURL) ~= "string" or STRING_FIND(resURL, "http") == nil then
        LuaLogE("ResUpdateManager-init:invalid resURL")
        return
    end

    initParams = params

    --删除上次的Log文件
    private.removeLogFile()

    --保存最新代码版本号
    latestCodeVersion = params.latCodeVersion or ""
    --保存服务器列表MD5
    serverListMD5 = params.md5 or ""

    --强制更新资源版本号
    forceUpdateResVersion = params.forceUpVersion or 0
    --最新资源版本号
    latestResVersion = params.latResVersion or 0

    -- 初始化下载地址队列
    downloadURLList = {}
    -- 主CDN下载地址放第1位
    TABLE_INSERT(downloadURLList, {url=resURL, ip=private.getIpByDownloadURL(resURL)})
    -- 备用CDN下载地址
    local beginPos = STRING_FIND(resURL, "/update/")
    local appendUrl
    if beginPos then
        appendUrl = STRING_SUB(resURL, beginPos+1, -1)
    end

    if params.cdnDomain and appendUrl and appendUrl ~= "" then
        for _, v in ipairs(params.cdnDomain) do
            local url = STRING_FORMAT(AgentConfiger.backupCDNUrlFormat, v, appendUrl)
            TABLE_INSERT(downloadURLList, {url=url, ip=private.getIpByDownloadURL(url)})
        end
    end

    -- 备机下载地址
    if appendUrl and appendUrl ~= "" then        
		local serverUrl = STRING_FORMAT(AgentConfiger.serverClientUrlFormat, appendUrl)
		TABLE_INSERT(downloadURLList, {url=serverUrl, ip=private.getIpByDownloadURL(serverUrl)})
    end

    --设置初始化成功
    isInited = true

    local logStr = STRING_FORMAT(
        "\n####%s#####\nserverListMD5:%s\ndownloadURL:%s\n",
        os.date(),
        serverListMD5,
        resURL
    )
    LuaLogE(logStr)
    --写入log
    private.saveLog(logStr)

    -- 开启自动下载缺少资源
    cc.ResourceManager:getInstance():addDownloadResEventHandler(private.downloadResHandler)
    -- 停止下载暂时不需要的资源
    cc.ResourceManager:getInstance():stopDownloadResEventHandler(private.stopDownloadResHandler,"GameAssets/")    
    private.scanExistMd5Assets()
end

-- 使用本地保存的数据开始游戏（有脚本更新后第一次启动时执行）
function initWithSaveParams()
    local resUpdateParams = getUpdateInfo("ResUpdateParams","")
    if resUpdateParams ~= "" then
        setUpdateInfo("ResUpdateParams","")
        init(private.divineParams(resUpdateParams))
        return true
    end
    return false
end

function getMd5DataFile()
	return ResPathConfig.ServerResList
end

function getLocalServerListMD5()
	return localServerListMD5
end
--[[
资源检查方法（根据玩家下包的情况完全检查用到的资源）
@param      endHandler           更新结束回调
@param      comparingHandler     资源比较过程回调
@param      downloadingHandler   资源下载过程回调   
@param      downloadNum          同时下载数
@param      md5ThreadNum         MD5线程
--]]
function downloadResLoading(endHandler, comparingHandler, downloadingHandler, downloadNum, md5ThreadNum)
    --保存回调方法
    onEndHandler = endHandler or false
    onComparingHandler = comparingHandler or false
    onDownloadingHandler = downloadingHandler or false

    --检查启动
    working = true

    --下载参数未初始化
    if not isInited then
        print(10, "ResUpdateManager:start check failed, not inited")
        private.checkFinish(108)
        return
    end

    --清空统计数据
    private.cleanupData()
    --设置最大下载数
    maxDownloadNum = downloadNum or 8

    minCompareIndex = 0
    maxCompareIndex = private.getLocalPackageID()
    minDownloadIndex = minCompareIndex
    maxDownloadIndex = maxCompareIndex

    --启动检查
    private.doLoadingDownload()
end

--[[
分包资源下载（全部重新下载指定包号资源）
@param      minPID              起始分包id
@param      maxPID              结束分包id
@param      md5ThreadNum        MD5比对最大线程数
@param      downloadNum         最大下载数
@param      endHandler          整体下载结束回调
@param      comparingHandler    单组文件md5比较完成回调
@param      downloadingHandler  整体下载过程回调
--]]
function downloadResGame(needLoadServerList, minPID, maxPID, md5ThreadNum, downloadNum, endHandler, comparingHandler, downloadingHandler)
    if __IGNORE_UPDATE__ then
        LuaLogE("===== __IGNORE_UPDATE__ =====")
        return
    end

    --其他下载未完成
    if working then
        LuaLogE("ResUpdateManager:start check failed, other check uncomplete")
        return
    end
    --保存回调方法
    onEndHandler = endHandler or false
    onComparingHandler = comparingHandler or false
    onDownloadingHandler = downloadingHandler or false
    
    --检查启动
    working = true

    --下载参数未初始化
    if not isInited then
        LuaLogE("ResUpdateManager:start download failed, not inited")
        private.checkFinish(108)
        return
    end

    --清空统计数据
    private.cleanupData()
    --设置最大下载数
    maxDownloadNum = downloadNum or 1

    minCompareIndex = minPID
    maxCompareIndex = maxPID
    minDownloadIndex = minCompareIndex
    maxDownloadIndex = maxCompareIndex

    isGameDownload = true

    --启动下载
    private.doGameDownload(needLoadServerList)
end

--获取当前已经下载的资源大小
function getCurrentDownloadSize()
    return currentDLSize    
end

--获取需要下载的资源的总大小
function getTotalDownloadSize()
    return totalDLSize 
end

function setCurrentDownloadSize(size)
    currentDLSize = size
end

--停止下载
function stopDownload()
    --设置检查标志位
    working = false

    downloadQueue = {}
    keyResCheckDict = {}
    keyResDownloadQueue = {}

    --清空内存数据
    serverResDict = {}
    serverResList = {}

    --停止下载链接
    for resPath, frClient in pairs(frClientTbl) do
        frClient:stop()
    end
	private.stopCheckDownloadTimeOut()
    private.stopDownloadCallbackTimer()
end

--清除所有S和U文件后重启游戏
function clearScriptsAndRestart()
    if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS or CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) or (ScriptType == ScriptTypePackS) then
        stopDownload()

        private.setCheckedContent("", private.getLocalPackageID())
        
        local filePath = STRING_FORMAT("%s%s", updatePath, baseScriptName)
        fileUtil:removeFile(filePath)

        for i = 1, 8 do
            filePath = STRING_FORMAT("%s%s%d", updatePath, patchScriptName, i)
            fileUtil:removeFile(filePath)
        end

        --其他关键资源一起清理掉
        local otherKeyRes = {
            "ResourceC0",
            "ResourceC1",
            "C2S.proto",
            "S2C.proto",
        }

        for _, v in ipairs(otherKeyRes) do
            local filePath = STRING_FORMAT("%s%s", updatePath, v)
            fileUtil:removeFile(filePath)    
        end
        GlobalUtil.purgeGame()
    end
end


---游戏内动态下载相关逻辑-----------------------------------------

local downloadQueue2 = false          --下载队列2
local downloadQueueSpecial = false    --优先级高一些的资源

local dQueue2FinishMap = {}     --下载队列2资源映射
local downloadingNum2 = 0       --第2下载队列下载中的资源
local maxDownloadNum2 = 8      --第2下载队列最大同时下载数

--[[
    添加一个数据到下载队列2
    @param  resPath     待下载文件路径
--]]
function private.pushDownloadQueue2(resPath, fileName)
    local findSpecialRes

    if fileName and resPath then
        if resPath ~= "" then
            local resInfo = serverResDict[resPath]
            if resInfo then
                findSpecialRes = tonumber(resInfo[3]) == 2
            end
        end
    end

    --初始化下载队列
    if not downloadQueueSpecial then
        downloadQueueSpecial = {}
    end

    if not downloadQueue2 then
        downloadQueue2 = {}
    end

    if findSpecialRes then
        --添加待下载文件
        TABLE_INSERT(downloadQueueSpecial,1,resPath)
    else
        --添加待下载文件
        TABLE_INSERT(downloadQueue2, 1, resPath)
    end

    if fileName then
        private.pushFinishMap(resPath, fileName)
    end
end

function private.pushFinishMap(resPath, fileName)
    -- print(10,"放入完成队列", fileName)
    local fileSet = dQueue2FinishMap[resPath]
    if not fileSet then
        fileSet = {[fileName] = 1}
        dQueue2FinishMap[resPath] = fileSet
    end

    if not fileSet[fileName] then
        fileSet[fileName] = 1
    else
        fileSet[fileName] = fileSet[fileName] + 1    
    end
end

function private.finishMissingRes(resPath)
    local fileSet = dQueue2FinishMap[resPath]
    if fileSet then
        for fileName, _ in pairs(fileSet) do
            cc.ResourceManager:getInstance():finishMissingRes(fileName)
            if Dispatcher then
                Dispatcher.dispatchEvent(EventType.resDownLoad_file, fileName)
            end
        end
        dQueue2FinishMap[resPath] = nil
    end
end
--[[
    从下载队列2取出一个数据
--]]
function private.popDownloadQueue2()
    if downloadQueueSpecial and #downloadQueueSpecial > 0 then
        return TABLE_REMOVE(downloadQueueSpecial, 1)
    else
        if not downloadQueue2 or #downloadQueue2 <= 0 then
            return false
        else
            local resPath = TABLE_REMOVE(downloadQueue2, 1)
            return resPath
        end
    end
end

function private.doMissingResDownload()
    local resourceManager = cc.ResourceManager:getInstance()

    --开启下载数到最大限制
    while (downloadingNum2 < maxDownloadNum2) do
        --从队列取数据
        local resPath = private.popDownloadQueue2()
        --取到数据则启动下载
        if resPath then
            local resInfo = serverResDict[resPath]
            if resInfo then
                repeat 
                    if packetDownloadingAssets[resPath] then
                        print(10,"packet download 正在下载,不必重复下载了",resPath)
                        break
                    end

                    -- 启动下载
                    local key = resPath.."2"                
                    if frClientTbl[key] then
                        LuaLogE("res is in missingdownloading... " .. resPath)
                        break
                    end

                    local failedTimes = private.getFailedRecord(resPath)
            
                    local resMD5 = resInfo[1]
                    local resType = resInfo[3]
                    local resSize = resInfo[4]

                    local dResPath = resPath

                    local updateURL, updateIP = private.getDownloadURL(dResPath, resMD5, failedTimes, resType)
                    if not updateURL then
                        private.saveLog(STRING_FORMAT("%s missing download failed.\n", resPath))
                        private.doMissingResDownload()
                        return
                    end

                    local function onProgress(dict)
                        bufferRecord[resPath] = dict.dlNow
                    end

                    resMD5 = STRING_SUB(resMD5, 5, -1)
                    --下载结束回调
                    local function getEndHandler(dict)
                        -- private.saveLog(STRING_FORMAT("%s%s:%s\n", "MissingRes:", resPath, dict.dlStatus))
                        frClientTbl[key] = nil
                        downloadingNum2 = downloadingNum2 - 1
                        --清除全路径缓存（避免之前资源全路径缓存为包内的路径导致update目录下的资源没有被读取）
                        local realName = resPath
                        local _,endPos = STRING_FIND(resPath,"GameAssets/")
                        if endPos then
                            realName = STRING_SUB(resPath,endPos+1, -1)
                        end

                        local rawFileName = resourceManager:getRawNameByRealName(realName)
                        private.removeFullPathCache(rawFileName)
                        print(10,"清除文件缓存", rawFileName)
                        
                        missingDownloadingAssets[resPath] = nil

                        local isCorrectRes, failedReason
                        if dict.dlStatus == 0 then
                            local isCorrect, gotMD5, needMD5 = private.verifyRes(resPath, resType, resMD5)
                            isCorrectRes = isCorrect
                            if not isCorrect then
                                local pMd5 = tostring(needMD5)
                                local fMd5 = tostring(gotMD5)
                                if string.len(pMd5) > 4 then
                                    pMd5 = STRING_SUB(pMd5, 1, 4)
                                end
                                if string.len(fMd5) > 4 then
                                    fMd5 = STRING_SUB(fMd5, 1, 4)
                                end
                                failedReason = STRING_FORMAT("MD5 not match. need:%s got:%s", pMd5, fMd5)
                            end

                        else
                            failedReason = dict.dlMsg
                        end

                        if isCorrectRes then
                            if packetDownloadingAssets[resPath] then
                                packetDownloadingAssets[resPath] = nil
                                curPacketSuccessNum = curPacketSuccessNum + 1
                                curPacketSuccessSize = curPacketSuccessSize + resSize
                                print(10,"missing download 中下载了分包资源")
                            end

                            currentDLSize = currentDLSize + resSize
                            -- print(10,"缺资源下载好了", resPath)
                            md5AssetsExists[resPath] = true
                            private.finishMissingRes(resPath)
                        else
                            local failedTimes = private.getFailedRecord(resPath)
                            failedTimes = failedTimes + 1
                            private.setFailedRecord(resPath, failedTimes)            
                            private.pushDownloadQueue2(resPath)
                            private.saveLog(STRING_FORMAT("%s:%s\n", resPath, failedReason))
                            TABLE_INSERT(failedList, {updateURL, failedReason})
                            -- 云测找问题
                            LuaLogE(STRING_FORMAT("%s:%s\n", resPath, failedReason))
                        end
                        --队列还有数据，继续补充下载
                        private.doMissingResDownload()
                    end

                    --设置保存路径
                    local savePath = STRING_FORMAT("%s%s", updatePath, private.getSavePath(resPath, resType))                    
                    if not dirCreateCache[savePath] then
                        dirCreateCache[savePath] = true
                        fileUtil:createDirectory(savePath)
                    end

                    local saveName = private.getSaveName(resPath, resType)
                    local tmp = resMD5
                    if STRING_SUB(tmp,-4,-1) == ".mp3" then
                        LuaLogE("2 过滤mp3 " .. tmp)
                        tmp = ""
                    end
                    missingDownloadingAssets[resPath] = true
                    
                    if GlobalUtil.isPCDownload() then
                        LuaLogE(string.format("~~~缺资源下载: %s %s", savePath, saveName))
                    end

                    frClientTbl[key] = gy.GYHttpClient:download(
                        updateURL, 
                        savePath, 
                        saveName, 
                        getEndHandler, 
                        onProgress, 
                        false, 
                        10, 
                        private.getTimeoutByResSize(resSize),
                        math.floor(maxDownloadNum2/2),
                        tmp
                    )
                    downloadingNum2 = downloadingNum2 + 1
                until true
            end
        else
            break
        end
    end
end

function private.downloadResHandler(fileName)
    if not fileName then
        print(10,"~~~~~没有文件名")
        return
    end    

    if needPurgeGame then
        print(10,"~~~~~needPurgeGame")
        return
    end

    -- 无网络
    if DeviceUtil.getNetworkStatus() == gy.NETWORK_STATUS_NOT_CONNECTED then
        LuaLogE("网络未连接，无法下载")
        return
    end

    local realFileName = fileUtil:getNewFilename(fileName)
    local resPath = getRealResPath(realFileName)
        
    if not next(serverResDict) then
        LuaLogE("~~~~~ loadServerResListAndDict")
        private.loadServerResListAndDict()
    end

    -- --已经处在下载队列或者下载中
    if not dQueue2FinishMap[resPath] and not frClientTbl[resPath .. "1"] and not frClientTbl[resPath .. "2"] then
        --加入下载队列
        private.pushDownloadQueue2(resPath, fileName)
        --开启下载
        private.doMissingResDownload()
    else
        --正在下载，添加到映射表
        private.pushFinishMap(resPath, fileName)
    end
end

--特殊目录
local specialDirs = {"Map/", "Model/Boss/", "Model/Npc/"}
local count2 = 0
--某些界面关闭了，暂时不下载对应资源了
function private.stopDownloadResHandler(fileName)
    if not fileName then
        return 
    end

    local realFileName = fileUtil:getNewFilename(fileName)
    local resPath = getRealResPath(realFileName)

    -- print(10,"界面关闭了", fileName, realFileName, resPath)
    if #downloadQueue > 0 and maxCompareIndex <= 8 then
        for _, dir in ipairs(specialDirs) do
            if STRING_FIND(fileName, dir) then
                for k,v in ipairs(downloadQueue) do
                    if k > 50 then     --只对前面部分做检查，提高性能
                        break
                    end
                    -- print(10,"界面关闭了，无需下载", fileName)
                    if v == resPath then
                        local res = TABLE_REMOVE(downloadQueue,k)
                        TABLE_INSERT(downloadQueue,res)
                        break
                    end
                end                
                break
            end
        end        
    end

    local findRes
    local fileCount = 0
    local fileSet = dQueue2FinishMap[resPath]
    if fileSet then
        for fn,count in pairs(fileSet) do
            if fn == fileName then
                local tmpCount = count - 1
                if tmpCount < 0 then
                    tmpCount = 0
                end
                fileSet[fn] = tmpCount
                break
            end
        end

        for _, count in pairs(fileSet) do
            fileCount = fileCount + count
        end

        if fileCount <= 0 then            
            for k,v in ipairs(downloadQueue2) do
                if v == resPath then
                    print(10,"从队列中移除暂时无需下载的资源",resPath,fileName)
                    TABLE_REMOVE(downloadQueue2,k)
                    findRes = true
                    break
                end
            end

            if not findRes then
                for k,v in ipairs(downloadQueueSpecial) do
                    if v == resPath then
                        print(10,"从队列中移除暂时无需下载的资源",resPath,fileName)
                        TABLE_REMOVE(downloadQueueSpecial,k)
                        findRes = true
                        break
                    end
                end
            end
        end
    end

    if fileCount > 0 then
        print(10,"~~~~~~ 文件数量:",fileName,fileCount)
    end

    --把文件从请求队列中移除
    if findRes then
        local inMissingDownload
        local key = resPath .. "1"

        local gyHttpClient = frClientTbl[key]
        if not gyHttpClient then
            key = resPath .. "2"
            gyHttpClient = frClientTbl[key]
            inMissingDownload = true
        end

        if gyHttpClient then
            local success = gyHttpClient:stopTask()
            count2 = count2 + 1
            if success then
                print(10,"从请求队列中移除数据",count2,inMissingDownload,fileName)
                frClientTbl[key] = nil
                bufferRecord[resPath] = nil

                if inMissingDownload then
                    downloadingNum2 = downloadingNum2 - 1
                    missingDownloadingAssets[resPath] = nil
                    private.doMissingResDownload()
                else
                    downloadingNum = downloadingNum - 1
					LuaLogE("downloadingNum = ",downloadingNum,resPath)
                    packetDownloadingAssets[resPath] = nil
                    private.pushDownloadQueue(resPath)
                    private.doNextDownload()
                end
            end
        end
    end
end
