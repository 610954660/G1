local DeviceUtil = {}
if not json then
    require "cocos.cocos2d.json"
end

-- local READABLE_DEVICES = {
-- 	test = {headHeight=30, headWidth=350, barHeight=20, barWidth=300, corner=20},
-- 	iPhoneX = {headHeight=58, headWidth=350, barHeight=20, barWidth=300, corner=40},
-- 	oppoR15 = {headHeight=55, headWidth=150, barHeight=0, barWidth=0, corner=30},
-- 	xiaomiMI8 = {headHeight=60, headWidth=350, barHeight=0, barWidth=0, corner=40},
-- 	huaweiNova3e = {headHeight=60, headWidth=150, barHeight=0, barWidth=0, corner=40},
-- 	oppoFindX = {headHeight=0, headWidth=0, barHeight=0, barWidth=0, corner=40},
-- }

-- 配置有刘海的机型
-- cutoutWidth	刘海宽度
-- cutoutHeight	刘海高度
-- barWidth		HomeIndicator宽度
-- barHeight	HomeIndicator高度
-- corner		圆角安全距离

local DISPLAY_CUTOUT_AND_CORNER = {cutoutWidth=200, cutoutHeight=50, barWidth=0, barHeight=0, corner=0}


local SAFE_AREA_MT = {}
function SAFE_AREA_MT.__tostring(t)
	return string.format("l:%d r:%d t:%d b:%d lh:%d, rh:%d, tw:%d, bw:%d, c:%d", t.l, t.r, t.t, t.b, t.lh, t.rh, t.tw, t.bw, t.c)
end

-- l:左安全距离 
-- r:右安全距离 
-- t:上安全距离 
-- b:下安全距离 
-- lh:左刘海高度 
-- rh:右刘海高度 
-- tw:上刘海宽度 
-- bw:下home键区宽度
-- c:圆角安全区距离
local _safeArea = {l=0, r=0, t=0, b=0, lh=0, rh=0, tw=0, bw=0, c=0}
setmetatable(_safeArea, SAFE_AREA_MT)

local _curScreenOrientation = 0
local _screenSchedulerID = false
local _lastClickScreen = 0
--当前屏幕亮度
local _curScreenBrightness = false
-- 更新安全区的值
local function __updateSafeArea(screenOrientation)
	_curScreenOrientation = screenOrientation
	local t = DISPLAY_CUTOUT_AND_CORNER
	if t then
		_safeArea.l, _safeArea.r, _safeArea.t, _safeArea.b = 0, 0, 0, 0
		_safeArea.lh, _safeArea.rh, _safeArea.tw, _safeArea.bw = 0, 0, 0, 0
		_safeArea.c = t.corner

		if screenOrientation == gy.DEVICE_ORIENTATION_LANDSCAPE_LEFT then
			_safeArea.l = t.cutoutHeight
			_safeArea.lh = t.cutoutWidth
			_safeArea.b = t.barHeight
			_safeArea.bw = t.barWidth

		elseif screenOrientation == gy.DEVICE_ORIENTATION_LANDSCAPE_RIGHT then
			_safeArea.r = t.cutoutHeight
			_safeArea.rh = t.cutoutWidth
			_safeArea.b = t.barHeight
			_safeArea.bw = t.barWidth

		elseif screenOrientation == gy.DEVICE_ORIENTATION_PORTRAIT then
			_safeArea.t = t.cutoutHeight
			_safeArea.tw = t.cutoutWidth
			_safeArea.b = t.barHeight
			_safeArea.bw = t.barWidth

		elseif screenOrientation == gy.DEVICE_ORIENTATION_PORTRAIT_UPSIDE_DOWN then
			_safeArea.t = t.barHeight
			_safeArea.tw = t.barHeight
			_safeArea.b = t.cutoutHeight
			_safeArea.bw = t.cutoutWidth
		end
		_safeArea.b = 0 --貌似没有这个必要了 下面是经验条
	end
end

local function onScreenOrientationChanged(value)
	__updateSafeArea(value)
	LuaLogE("~~~~~~~~~~screenOrientationChanged:" .. tostring(value))
	if Dispatcher then
		-- Dispatcher.dispatchEvent(EventType.SCREEN_ORIENTATION_CHANGED, getSafeArea())
	end
end

local function onLifecycleChanged(value)
	LuaLogE("~~~~~~~~~~onLifecycleChanged:", value)

	if Dispatcher then
		Dispatcher.dispatchEvent(EventType.APP_LIFECYCLE_CHANGED, value)
		if value == 2 then
			Dispatcher.dispatchEvent(EventType.APP_ENTER_BACKGROUND)
			if PushNotificationManager then
				PushNotificationManager.onEnterBackground()
			end
		elseif value == 3 then
			Dispatcher.dispatchEvent(EventType.APP_ENTER_FOREGROUND)
			if PushNotificationManager then
				PushNotificationManager.onEnterForeground()
			end
		end
	end
end

local function onReceiveMemoryWarning()
	LuaLogE("~~~~~~~~~~onReceiveMemoryWarning")
	do return end
	if Dispatcher then
		Dispatcher.dispatchEvent(EventType.APP_RECEIVE_MEMORY_WARNING)
	end
end

--获取刘海数据
function DeviceUtil.setCutoutSize(cutoutWidth, cutoutHeight, barWidth, barHeight, corner)
	DISPLAY_CUTOUT_AND_CORNER.cutoutWidth = cutoutWidth	
	DISPLAY_CUTOUT_AND_CORNER.barWidth = barWidth
	DISPLAY_CUTOUT_AND_CORNER.barHeight = barHeight
	
	if corner > 0 then
		DISPLAY_CUTOUT_AND_CORNER.corner = corner
	end

	--一般有刘海屏的手机都有圆角
	if cutoutHeight > 0 then
		DISPLAY_CUTOUT_AND_CORNER.cutoutHeight = cutoutHeight + 8
		if corner <= 0 then
			DISPLAY_CUTOUT_AND_CORNER.corner = cutoutHeight/3
		end
	else
		DISPLAY_CUTOUT_AND_CORNER.cutoutHeight = cutoutHeight
	end

	--更新数据
	onScreenOrientationChanged(_curScreenOrientation)
end

-- typedef enum {
-- 	GYNetworkStatusNotConnected = 0,
-- 	GYNetworkStatusWiFi,
-- 	GYNetworkStatusWWAN  //2G/3G/4G
--  GYNetworkStatus;
-- } 

local curNetworkStatus
local function onNetworkStatusChanged(status)	
	LuaLogE("~~~~~onNetworkStatusChanged~~~~~~"..tostring(status))
	curNetworkStatus = status
	do return end
	if Dispatcher then
		Dispatcher.dispatchEvent(EventType.NETWORK_STATUS_CHANGED, status)
	end
end

local firstLaunchGravity
local curX, curY
local xScale, yScale = 65, 65
local gravityHandle
local sensorX, sensorY
local lastOrientation
local xFactor, yFactor = 1, 1

local sensorHandler = {
	[gy.SENSOR_TYPE_GRAVITY] = function (info)   --重力感应, 范围-9~9
		local x = tonumber(info.value1)   
		local y = tonumber(info.value2)
		-- print(10, string.format("重力感应 x:%s  y:%s", x, y))
		if sensorX and math.abs(x-sensorX) <= 0.02 and sensorY and math.abs(y-sensorY) <= 0.02 then
			return
		end
		sensorX = x
		sensorY = y

		if firstLaunchGravity or lastOrientation ~= _curScreenOrientation then
			curX = x
			curY = y
			firstLaunchGravity = false
		end
		lastOrientation = _curScreenOrientation
		
		if _curScreenOrientation == gy.DEVICE_ORIENTATION_LANDSCAPE_LEFT then
			xFactor, yFactor = 1, 1

		elseif _curScreenOrientation == gy.DEVICE_ORIENTATION_LANDSCAPE_RIGHT then
			xFactor, yFactor = -1, -1
		end


		if not gravityHandle then
			local xDiff, yDiff
			local deltaX, deltaY
			local function updatePerframe()
				deltaX, deltaY = 0, 0
				xDiff = math.abs(curX - sensorX)
				yDiff = math.abs(curY - sensorY)

				local matchPos
				local tempStepX = xDiff/8
				local tempStepY = yDiff/8

				if curX < sensorX then
					curX = curX + tempStepX
					deltaX = tempStepX
					if curX > sensorX then
						deltaX = curX - sensorX
						curX = sensorX
					end

				elseif curX > sensorX then
					curX = curX - tempStepX
					deltaX = - tempStepX
					if curX < sensorX then
						deltaX = curX -sensorX
						curX = sensorX
					end
				end

				--匹配
				if curX == sensorX then
					matchPos = true
				end

				if curY < sensorY then
					curY = curY + tempStepY
					deltaY = tempStepY
					if curY > sensorY then
						deltaY = curY - sensorY
						curY = sensorY
					else
						matchPos = false
					end						
				elseif curY > sensorY then
					curY = curY - tempStepY
					deltaY = -tempStepY
					if curY < sensorY then
						deltaY = curY - sensorY
						curY = sensorY
					else
						matchPos = false
					end
				end

				if deltaX ~= 0 or deltaY ~= 0 then
					do return end
					Dispatcher.dispatchEvent(EventType.GRAVITY_CHANGE, deltaY*yScale*yFactor, deltaX*xScale*xFactor)
				end
			end
			gravityHandle = Scheduler.schedule(updatePerframe, 0, 0)
		end		
	end
}

local function onSensorCallback(data)
	local sensorInfo = json.decode(data)
	if sensorInfo then
		local func = sensorHandler[sensorInfo.type]
		if func then
			func(sensorInfo)
		end
	end
end

function DeviceUtil.init()
	--机型检测
	--local PhoneCheck = require "Game.GlobalFuncs.PhoneCheck"
	--PhoneCheck.checkShaderPrecision()
	--PhoneCheck.check2ForceLoadRGD()

	local gyDeviceStatusListener = gy.GYDeviceStatusListener:getInstance()
	--_curScreenOrientation = gyDeviceStatusListener:getScreenOrientation()
	--lastOrientation = _curScreenOrientation	
	--__updateSafeArea(_curScreenOrientation)
	
	--LuaLogE("init orientation:", _curScreenOrientation, "  phoneType：", gy.GYDeviceUtil:getDeviceModel())

	--注册网络变化事件监听器
	--gyDeviceStatusListener:addNetStatusEventListener(onNetworkStatusChanged)
	--注册屏幕朝向变化事件
	--gyDeviceStatusListener:addScreenOrientationEventListener(onScreenOrientationChanged)
	--app生命周期事件
	gyDeviceStatusListener:addLifecycleEventListener(onLifecycleChanged)
	--内存不够时触发
	--gyDeviceStatusListener:addReceiveMemoryWarningEventListener(onReceiveMemoryWarning)
	--传感器
	--gy.GYSensorManager:getInstance():registerCallback(onSensorCallback)
end

-- 获取安全区
function DeviceUtil.getSafeArea()
	return _safeArea
end

function DeviceUtil.getNetworkStatus()
	return curNetworkStatus
end

function DeviceUtil.registerSensor(type)
	firstLaunchGravity = true
	gy.GYSensorManager:getInstance():registerSensor(type)
end

function DeviceUtil.unregisterSensor(type)
	if gravityHandle then
		Scheduler.unschedule(gravityHandle)
		gravityHandle = false
	end
	gy.GYSensorManager:getInstance():unregisterSensor(type)
end

-- 模拟朝向变化
-- orientation	#int		想要模拟的朝向，枚举在EngineEx文件中，如gy.DEVICE_ORIENTATION_LANDSCAPE_LEFT
-- deviceModel	#string		想要模拟的机型，看本文件最上方的CONTAIN_SAFE_AREA_DEVICES表，可不传
function DeviceUtil.simulateOrientationChange(orientation, deviceModel)
	if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 or CC_TARGET_PLATFORM == CC_PLATFORM_MAC then
		local tmp = gy.GYDeviceStatusListener:getInstance()
		function tmp:getScreenOrientation()
			return orientation
		end
		if deviceModel and deviceModel ~= "" then
			function gy.GYDeviceUtil.getDeviceModel()
				return deviceModel
			end
		end
		onScreenOrientationChanged(orientation)
		
		-- showSafeArea()

	end
end


-- 屏幕进入省电模式
function DeviceUtil.screenPowerSaving()
	--LuaLogE("DeviceUtil.screenPowerSaving")
	--if CC_TARGET_PLATFORM ~= CC_PLATFORM_WIN32 or CC_TARGET_PLATFORM ~= CC_PLATFORM_MAC then
		--_curScreenBrightness = gy.GYDeviceUtil:getScreenBrightness()
		--gy.GYDeviceUtil:setScreenBrightness(0.1)
	--end
end

-- 屏幕恢复亮度
function DeviceUtil.screenPowerNormal()
	--LuaLogE("DeviceUtil.screenPowerNormal")
	--if CC_TARGET_PLATFORM ~= CC_PLATFORM_WIN32 or CC_TARGET_PLATFORM ~= CC_PLATFORM_MAC then
		--if _curScreenBrightness then
			--gy.GYDeviceUtil:setScreenBrightness(_curScreenBrightness)
			--_curScreenBrightness = false
		--end
	--end
end

-- 屏幕省电检测
function DeviceUtil.screenPowerCheckUpdate()
	--LuaLogE("DeviceUtil.screenPowerCheckUpdate")
	--if CC_TARGET_PLATFORM ~= CC_PLATFORM_WIN32 or CC_TARGET_PLATFORM ~= CC_PLATFORM_MAC then
		--local time = os.time()
		--if time - _lastClickScreen < 20 then return end
		--_lastClickScreen = time
		--if _screenSchedulerID then
			--Scheduler.unschedule(_screenSchedulerID)
		--end
		--DeviceUtil.screenPowerNormal()
		--_screenSchedulerID = Scheduler.scheduleOnce(180,function()
				--DeviceUtil.screenPowerSaving()
			--end)
	--end
end


return  DeviceUtil