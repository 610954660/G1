-----------------------------
--上报信息上报
-----------------------------
local RPUtil = {}


--初始化
function RPUtil.init()
	
end

--游戏版本
function RPUtil.getGameVer()
	return __SCRIPT_VERSION__
end

--设备id
function RPUtil.getDeviceId()
	return gy.GYDeviceUtil:getDeviceID()
end

--游戏ID
function RPUtil.getGameId()
	return "g1"  
end

--渠道代号
function RPUtil.getPlatform()
	return AgentConfiger.getRealAgent()
end

--渠道ID
function RPUtil.getChannelId()
	return SDKUtil.getChannelId()
end

--游戏包名
function RPUtil.getPackageName()
	local packageName = gy.GYPlatform:getBundleID()
	if packageName == "" then
		packageName = "unknown_param"
	end
	return packageName
end

--设备型号
function RPUtil.getDeviceModel()
	local deviceModel = gy.GYDeviceUtil:getDeviceModel()
	if deviceModel == "" then
		deviceModel = "model_not_implement"
	end
	return deviceModel
end

--OsCode
function RPUtil.getOsCode()
	return CC_TARGET_PLATFORM
end

--网络类型
function RPUtil.getNetType()
	local networkType = gy.GYDeviceStatusListener:getInstance():getNetStatus()
	if networkType == gy.NETWORK_STATUS_WIFI then
		networkType = "wifi"

	elseif networkType == gy.NETWORK_STATUS_MOBILE then
		networkType = "Mobile"

	else
		networkType = "unknown_param"
	end
	return networkType
end

--resolution
function RPUtil.getResolution()
	local resolution = gy.GYDeviceUtil:getScreenResolution()
	return resolution
end

--screenWidth
function RPUtil.getSreenWidth()
	local resolution = gy.GYDeviceUtil:getScreenResolution()
	local screenWidth="-1"
	local screenHeight="-1"
	if resolution~= "" then
		local resolutionParam = string.split(resolution, "*")
		screenWidth = resolutionParam[1] or "-1"
		screenHeight = resolutionParam[2] or "-1"
	end
	return screenWidth
end

--screenHeight
function RPUtil.getSscreenHeight()
	local resolution = gy.GYDeviceUtil:getScreenResolution()
	local screenWidth="-1"
	local screenHeight="-1"
	if resolution~= "" then
		local resolutionParam = string.split(resolution, "*")
		screenWidth = resolutionParam[1] or "-1"
		screenHeight = resolutionParam[2] or "-1"
	end
	return screenHeight
end

--PackageName
function RPUtil.getPackageName()
	local packageName = gy.GYPlatform:getBundleID()
	if packageName == "" then
		packageName = "unknown_param"
	end
	return packageName
end

--系统版本
function RPUtil.getOsVer()
	local deviceVer = gy.GYDeviceUtil:getDeviceVersion()
	if not deviceVer or deviceVer == "" then
		deviceVer = "unknown_param"
	end	
	return deviceVer
end

--Android 的Android_imei  或者IOS的IDFA
function RPUtil.getImeiOrIdfa()
	local imeiOrIdfa = gy.GYDeviceUtil:getIDFA()
	if not imeiOrIdfa or imeiOrIdfa == "" then 
		imeiOrIdfa = gy.GYDeviceUtil:getDeviceID()
	end
	if not imeiOrIdfa or imeiOrIdfa == "" then 
		imeiOrIdfa = "-1"
	end
	return  imeiOrIdfa
end

--CPU核数
function RPUtil.getCpuNum()
	return gy.GYDeviceUtil:getCPUNumber() or 1
end

--CPU型号
function RPUtil.getCpuModel()
	return gy.GYDeviceUtil:getGPUModel() or "unknow"
end

--RAM大小单位GB
function RPUtil.getRamSize()
	return gy.GYDeviceUtil:getMemSize() or "-1"
end

--ROM大小单位KB
function RPUtil.getRomSize()
	--return cc.FileUtils:getInstance():getAvailableSize() or "-1"--ROM大小单位KB
	return cc.FileUtils:getInstance().getExternalSize and cc.FileUtils:getInstance():getExternalSize() or "-1"--ROM大小单位KB
end

--时区
function RPUtil.getTimeZone()
	return DateUtil.getCurTimeZone()
end


function RPUtil.fillCommonInfos(params)
	if not params then params = {} end
	params.deviceMac =   RPUtil.getDeviceId() --:  设备mac信息 
    params.deviceName = RPUtil.getDeviceModel() --: 设备名称 (设备名与型号请以空格分开 : Samsung SM-G900H ) 
    params.deviceOsType = RPUtil.getOsCode() --: 设备系统类型 : ios 苹果；android 安卓；pc 电脑 
    params.deviceNetType = RPUtil.getNetType() --: 网络类型 :2g/3g/4g/wifi 
    params.deviceOsVersion = RPUtil.getOsVer() --: 设备的系统版本 
    params.deviceId = RPUtil.getDeviceId() --:  [获取优先级规则： imei\androidId\idfa ->  mac -> 客户端自定义生成的设备唯一标识 (md5转小写)] 
    params.deviceImeiOrIdfa  = RPUtil.getImeiOrIdfa() --: 安卓的imei 或者 IOS的IDFA 
    params.deviceScreenWidth = RPUtil.getSreenWidth() --: 设备的屏幕宽 
    params.deviceScreenHeight = RPUtil.getSscreenHeight() --: 设备的屏幕高 
    params.deviceCpuAmount= RPUtil.getCpuNum() --: 设备的CPU核数 
    params.deviceCpuModel = RPUtil.getCpuModel() --: 设备的CPU型号 
    params.deviceRamSize = RPUtil.getRamSize() --: 设备的RAM大小（单位KB） 
    params.deviceRomSize = RPUtil.getRomSize() --: 设备的ROM大小（单位KB） 
end


return RPUtil