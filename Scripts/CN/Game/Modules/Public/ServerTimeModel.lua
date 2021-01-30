---added by xhd
--游戏服务器时间
local BaseModel = require "Game.FMVC.Core.BaseModel"
local ServerTimeModel = class("ServerTimeModel", BaseModel)
local scheduler = cc.Director:getInstance():getScheduler()
local millisecondNow = cc.millisecondNow

function ServerTimeModel:ctor()
    self.__clockId = 0
    self.__startTime = 0
    self.__preTime = 0
    self.__startTimestamp = 0

    self.__openDateTime = 0
    self.__timeZone = -8
    self.lastDay=false
    self.hadNotify5AM = false
    self.hadNotify10PM = false
end

--启动客户端与服务器时间同步的计时(可能有1s内的误差)
function ServerTimeModel:startClock(timeMs)
    if self.__clockId > 0 then
        scheduler:unscheduleScriptEntry(self.__clockId)
        self.__clockId = -1
    end
    self.__startTime = timeMs
    self.__startTimestamp = millisecondNow()

    local function onTick()
        os.time()
        local now = math.floor((self.__startTime + millisecondNow() - self.__startTimestamp)/1000)

        local tb = os.date("*t", now)
        local curDay = tb.day
        local curHour = tb.hour

        --跨天
        if self.lastDay ~= curDay then
        	Dispatcher.dispatchEvent(EventType.serverTime_crossDay)
        	self.hadNotify5AM = false
        	self.hadNotify10PM = false
        end
        self.lastDay = curDay

        --凌晨5点centerComp
        if not self.hadNotify5AM and curHour == 5 then
        	self.hadNotify5AM = true
        	Dispatcher.dispatchEvent(EventType.serverTime_cross5AM)
        end

        --晚上10点
        if not self.hadNotify10PM and curHour == 22 then
        	self.hadNotify10PM = true
        	Dispatcher.dispatchEvent(EventType.serverTime_cross10PM)
        end
    end

    self.__clockId = scheduler:scheduleScriptFunc(onTick,1,false)
end


-- 获取当前服务器的时间(s)
function ServerTimeModel:getServerTime()
    return math.ceil(self:getServerTimeMS() / 1000)
end

-- 获取当前服务器的时间(ms)
function ServerTimeModel:getServerTimeMS()
    local curTime
    if not self.__startTime or self.__startTime == 0 then
        curTime = os.time() * 1000
    else
        curTime = self.__startTime + millisecondNow() - self.__startTimestamp
    end
    return curTime
end


-- -- 设置开服时间
function ServerTimeModel:setOpenDateTime(openDateMs)
    self.__openDateTime = openDateMs / 1000
end

-- 获取开服时间
function ServerTimeModel:getOpenDateTime()
    return self.__openDateTime
end

-- 设置当前时区
function ServerTimeModel:setCurTimeZone(timeZone)
    self.__timeZone = timeZone
end

function ServerTimeModel:getCurTimeZone()
    return self.__timeZone
end

-- 返回当天时间的总秒数：0~24*60*60
-- ]]
-- function todayTime()
-- 	local timeStr = os.date("%X", getServerTime())
--     local t = { string.find(timeStr, "(%d+):(%d+):(%d+)") }
--     if t[1] then
--         return tonumber(t[3]) * 3600 + tonumber(t[4]) * 60 + tonumber(t[5])
--     end
--     return 0
-- end

---@return number@今天经过多少秒
function ServerTimeModel:getTodaySeconds()
    local time  = self:getServerTime()
    time = time - self.__timeZone*3600
    local daySec = 24*3600
    return time % daySec
end

--将有时区的时间转换
function ServerTimeModel:changeTimeBySconds( time )
   time = time - self.__timeZone*3600
   return time
end

function ServerTimeModel:getTodayLastSeconds(  )
    local time = self:getTodaySeconds()
    print(1,time)
    print(1,86400 - time)
    return 86400 - time
end

---@return number@现在几点
function ServerTimeModel:getHour(time)
    local seconds = self:getTodaySeconds(time)
    return math.floor(seconds / 3600)
end

---@return number@现在时间,时分秒
function ServerTimeModel:getHMS(time)
    local seconds = self:getTodaySeconds(time)
    return math.floor(seconds / 3600), math.floor((seconds % 3600) / 60), seconds % 60
end

--断线重连时的清理
function ServerTimeModel:clear()
    if self.__clockId > 0 then
        scheduler:unscheduleScriptEntry(self.__clockId)
        self.__clockId = -1
    end
    self.__startTime = 0
    self.__openDateTime = 0
    self.__timeZone = -8
end

--获取开服天数
function ServerTimeModel:getOpenDay()
    local openTime = self:getOpenDateTime()    
    return self:getDay(openTime)
end

--获取开服周数
function ServerTimeModel:getOpenWeek()
    local openTime = self:getOpenDateTime()    
    local day = self:getDay(openTime) + 1
	return math.ceil(day/7)
end

--获取开服自然周数（周五开服，第三天算第二周了）
function ServerTimeModel:getOpenNaturalWeek()
    local week=TimeLib.DifWeek( self:getOpenDateTime() * 1000, self:getServerTimeMS())
	return week
end

--获取天数
function ServerTimeModel:getDay(timeVal)
    timeVal = timeVal + 28800    
    local serverTime = self:getServerTime() + 28800
    local preDay = math.floor( timeVal / 86400 )
    local curDay = math.floor( serverTime / 86400 )
    return curDay - preDay
end
return ServerTimeModel