 --[[
 倒计时工具类 
 @author Administrator	penghu
 ]]
local CountDownUtil = {}
local scheduler = cc.Director:getInstance():getScheduler()

--保存当前正在倒计时的对象
local _clocks = {}

-----单个倒计时类，仅内部访问------------------------------------------------------

local Clock = class("Clock")

function Clock:ctor(params)
	self.__msTotal__ = params.msTotal
	self.__msTick__ = params.msTick
	self.__onTick = params.onTick
	self.__onFinish = params.onFinish
	self.__self__ = params.self
	
	self.__prevTick__ = cc.millisecondNow()
	self.__timePassed__ = 0
	self.__isRunning__ = true
	self.__leftTime__ = params.msTotal or 0
	
	local function onSchedule()
		if self.__isRunning__ then
			local __thisTick = cc.millisecondNow()
			local __deltaTime = __thisTick - self.__prevTick__
			self.__prevTick__ = __thisTick
			self.__timePassed__ = self.__timePassed__ + __deltaTime
			
			if self.__timePassed__ > self.__msTotal__ then
				self.__timePassed__ = self.__msTotal__
			end
			self.__leftTime__ = self.__msTotal__ - self.__timePassed__
			if type(self.__onTick) == "function" then
				self.__onTick(self.__self__, self.__timePassed__, self.__id__)
			end
			
			if self.__timePassed__ >= self.__msTotal__ then
				self:__clearTimer()
				
				if type(self.__onFinish) == "function" then
					self.__onFinish(self.__self__, self.__id__)
				end
			end
		end
	end
	self.__id__ = scheduler:scheduleScriptFunc(onSchedule, self.__msTick__/1000, false)
	
	_clocks[self.__id__] = self
end

function Clock:getID() return self.__id__ end

function Clock:getIsRunning() return self.__isRunning__ end

function Clock:getTimePassed()
	local __deltaTime = cc.millisecondNow() - self.__prevTick__
	return self.__timePassed__ + __deltaTime
end

function Clock:getLeftTime()
	return self.__leftTime__
end

function Clock:stop()
	self:__clearTimer()
end

function Clock:pause()
	if self.__isRunning__ then
		self.__isRunning__ = false
		
		local __deltaTime = cc.millisecondNow() - self.__prevTick__
		self.__timePassed__ = self.__timePassed__ + __deltaTime
	end
end

function Clock:resume()
	if not self.__isRunning__ then
		self.__isRunning__ = true
		self.__prevTick__ = cc.millisecondNow()
	end
end
	
function Clock:__clearTimer()
	if self.__isRunning__ then
		if self.__id__ > 0 then
			scheduler:unscheduleScriptEntry(self.__id__)
		end
		
		self.__isRunning__ = false
	end
	-- self.__timePassed__ = 0
	_clocks[self.__id__] = nil
end

----------------------------------------------------------------------

--[[
根据ID获取对应的倒数计时器，不公开，以防止被外部引用而导致可能出现的内存泄漏
@param id	生成时分配的ID
@return 	倒数计时器对象
]]
local function getClockByID(id)
	return _clocks[id]
end

--[[
开始一个新倒计时 
@param msTotal		[number]	总倒计时时间（ms）
@param msTick		[number]	触发onTick的时间间隔
@param onTick		[function]	每次tick时触发的回调函数【需要3个参数，第2个表示对应clock已经过去的时间（ms),第3个表示对应clock的ID(用于处理一个类中有个clock时)】，
								如：function callback(self, timePassed, clockId) end
@param onFinish		[function]	完成倒计时时的回调函数【需要2个参数,第2个表示对应clock的ID(用于处理一个类中有个clock时)】，
								如：function callback(self, clockId) end
@param self			[*]			onTick、onFinish回调时的self
@return 本倒计时对象对应的ID，用于中途想停止，暂停等操作
]]		
function CountDownUtil.startNew(msTotal, msTick, onTick, onFinish, self)
	assert(msTick > 0, "Invalid msTick, need a number > 0!")
	if msTotal <= 0 then return -1 end
	
	local __o = Clock.new({
		msTotal = msTotal, 
		msTick = msTick, 
		onTick = onTick, 
		onFinish = onFinish,
		self = self
	})
	local id = __o:getID()
	onTick(self, 0, id)
	return id
end

--[[
停止倒计时
@param id	对应倒计时对象ID
]]
function CountDownUtil.stop(id)
	if getClockByID(id) then
		getClockByID(id):stop()
	end
end

--[[
暂停倒计时，与resume对应
@param id	对应倒计时对象ID
]]	
function CountDownUtil.pause(id)
	if getClockByID(id) then
		getClockByID(id):pause()
	end
end

--[[
恢复倒计时，与pause对应
@param id	对应倒计时对象ID
]]	
function CountDownUtil.resume(id)
	if getClockByID(id) then
		getClockByID(id):resume()
	end
end

--[[
获取倒计时已过去的时间(ms)
@param id	对应倒计时对象ID
@return 
]]	
function CountDownUtil.getTimePassed(id)
	if getClockByID(id) then
		return getClockByID(id):getTimePassed()
	end
	
	return -1;
end
--[[
获取倒计时已剩余的时间(ms)
@param id	对应倒计时对象ID
@return 
]]	
function CountDownUtil.getLeftTime(id)
	if getClockByID(id) then
		return getClockByID(id):getLeftTime()
	end
	
	return 0;
end

--[[
获取倒计时是否正在运行中
@param id	对应倒计时对象ID
@return 
]]	
function CountDownUtil.getIsRunning(id)
	if getClockByID(id) then
		return getClockByID(id):getIsRunning()
	end
	
	return false
end

--[[
将时间格式化为hh:mm:ss形式
@param ms	时间（毫秒）
@param fmt	格式化的字符串，如hh:mm:ss、hh时mm分ss秒、mm:ss、mm分ss秒
@return hh:mm:ss格式的时间
例子：   
CountDownUtil.formatTime(100000, "hh:mm:ss")	==> 08:09:04
CountDownUtil.formatTime(100000, "hh时mm分ss秒")	==> 08时09分04秒
CountDownUtil.formatTime(100000, "h:m:s")		==> 8:9:4
CountDownUtil.formatTime(100000, "mm:ss")		==> 09:04
]]	
function CountDownUtil.formatTime(ms, fmt)
	if type(fmt) == "function" then
		return fmt(ms)
	end
	
	if type(fmt) ~= "string" then fmt = Desc.common_timeFormat end
	
	local __sec = math.floor(ms / 1000)
	local o = {   
		["h+"] = math.floor(__sec / 60 / 60), --时   
		["m+"] = math.floor(__sec / 60 % 60), --分   
		["s+"] = __sec % 60, --秒   
	}
	
	for k, v in pairs(o) do
		local q = string.match(fmt, k)
		if q and string.len(q) > 1 then
			v = v > 9 and tostring(v) or ("0" .. v)
		end
		fmt = string.gsub(fmt, k, v)
	end
	
	return fmt 
end

--用于重新登录的清理
function CountDownUtil.clear()
	for k, v in pairs(_clocks) do
		stop(k)
	end
end

--创建计时器
--[[
]]		

SecondClock = class("SecondClock")
function SecondClock:ctor(params)
	params = params or {}
	self._time = tonumber(params.time) or 0
	self._time = math.max(0, self._time)
	self._isUp = params.isUp == true
	self._onTick = type(params.onTick) == "function" and params.onTick or false
	self._onFinish = type(params.onFinish) == "function" and params.onFinish or false
	self._clockId = false
	self._value = self._isUp and 0 or self._time
	self._event = params.event or false
	if params.isStart then
		self:start()
	end
end
function SecondClock:_updateValue(timePassed, isForce)
	local curT
	if self._isUp then
		curT = math.floor((timePassed)/1000)
	else
		curT = math.ceil((self._time * 1000 - timePassed)/1000)
	end
	if (self._onTick or self._event) and curT ~= self._value or isForce then
		self._value = curT
		if self._onTick then
			self._onTick(curT, self)
		end
		self:_dispatchEvent()
	else
		self._value = curT
	end
		
end
function SecondClock:_onMSTick(timePassed)
	self:_updateValue(timePassed)
end

function SecondClock:_onMSFinish()
	self._clockId = false
	if self._onFinish then
		self._onFinish(self)
	end
	self:_dispatchEvent()
end
function SecondClock:start(params)
	params = params or {}
	self:stop()
	self._time = tonumber(params.time) or self._time
	self._time = math.max(0, self._time)
	self._isUp = params.isUp or self._isUp
	self._onTick = type(params.onTick) == "function" and params.onTick or self._onTick
	self._onFinish = type(params.onFinish) == "function" and params.onFinish or self._onFinish
	self._value = self._isUp and 0 or self._time
	self._clockId = startNew(self._time * 1000, 1000, self._onMSTick, self._onMSFinish,self)
	if params.tmp then
		-- stop之后马上start会出现问题，他的下次更新时间有误差 time-time/1000
		self._value = 0
	end
	if self._clockId then
		self:_updateValue(self._value, true)
	end
end

function SecondClock:stop()
	if self._clockId then
		stop(self._clockId)
		self._clockId = false
	end
	self._value = self._isUp and 0 or self._time
end

function SecondClock:getValue()
	return self._value
end

function SecondClock:_dispatchEvent()
	if self._event then
		Dispatcher.dispatchEvent(self._event, self._value)
	end
end

return CountDownUtil