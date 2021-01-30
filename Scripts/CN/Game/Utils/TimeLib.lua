local TimeLib = {}
local MathToInteger = math.tointeger
local math = math

local pattern_full,sz_full = "(%d+)%-(%d+)%-(%d+)[T ](%d+):(%d+):(%d+)%.(%d+)",23
local pattern_sec,sz_sec= "(%d+)%-(%d+)%-(%d+)[T ](%d+):(%d+):(%d+)",19
local pattern_day,sz_day = "(%d+)%-(%d+)%-(%d+)",10

local format_normal_date = "%Y-%m-%d"

local msperday = 24 * 60 * 60 * 1000
local msperhour = 60 * 60 * 1000
local msperminute = 60 * 1000
local mspersecond = 1000

TimeLib.msperday = msperday
local MATH_FLOOR = math.floor
local MATH_CEIL = math.ceil
local MATH_MAX = math.max

-- 获取与服务器时间差值：秒
function TimeLib.getOffsetTime(seconds)
	return math.abs(ServerTimeModel:getServerTime() - seconds)
end

function TimeLib.showHMS( seconds )
	-- body
	return os.date("%X", seconds) 
end

-- 格式化时间：xx秒，xx分钟，xx小时，xx天
function TimeLib.getFormatTimeByType(seconds, type)
	local value = TimeLib.getOffsetTime(seconds)
	if type== "s" then
		return value
	elseif type=="m" then
		return MATH_FLOOR(value/60)
	elseif type=="h" then
		return MATH_FLOOR(value/3600)
	elseif type=="d" then
		return MATH_FLOOR(value/86400)
	end
end

-- xx:xx:xx的格式化
function TimeLib.formatTime(seconds,showHour,hideSec)
	local hour = MATH_FLOOR(seconds/3600)
	hour = hour<10 and ("0"..hour) or hour
	local min = MATH_FLOOR(seconds%3600/60)
	min = min<10 and ("0"..min )or min
	local sec = MATH_FLOOR(seconds%60)
	sec = sec<10 and ("0"..sec )or sec

	if showHour or seconds >= 3600 then
		return hour..":"..min .. ( not hideSec and ( ":" .. sec ) or "" )
	else
		return min..":"..sec
	end
end

function TimeLib.skynetTimeStampFormat(format,microsecond)
	return os.date(format,microsecond / 100)
end

-- 倒计时(不受加速影响)
-- seconds 	当isOffset为false时为倒计时秒数值，为true时是与当前服务器时间的差值为倒计时数值
-- callFunc 	每秒回调，参数为格式化的剩余倒计时
-- onEnd        倒计时结束回调
-- isOffset  	
-- isUp  		是否为正计时
local timeHandleT = {}
function TimeLib.newCountDown(seconds, onCountDown, onEnd, isOffset, isUp , needFormat)
	local sec = seconds	
	if needFormat==nil then needFormat = true end
	if isOffset then
		sec = getOffsetTime(seconds)
	end
	local endTime = os.time() + sec
	local beginTime = os.time()
	local id = nil
	local update = function()
		local count 
		if not isUp then
			count = endTime - os.time()  
			if (not isUp and count > 0) then
				if needFormat then
					onCountDown(TimeLib.formatTime(count))
				else 
					onCountDown( count )
				end
			else
				TimeLib.clearCountDown(id)
				if onEnd then
					onEnd()
				end
			end
		else
			count = os.time()  - beginTime + seconds
			if needFormat then
				onCountDown(TimeLib.formatTime(count))
			else 
				onCountDown( count )
			end
		end
	end
	update()
	id = Scheduler.schedule(update, 0.2)
	timeHandleT[id] = true
	return id
end

-- 倒计时析构
function TimeLib.clearCountDown(id)
	if timeHandleT[id] then
		Scheduler.unschedule(id)
		timeHandleT[id] = nil
	end
end


--[[关闭界面时自动清理的倒计时
@params 
	count 			[number]倒计时次数,0表示无限次(回调参数表示两次调用之间正常应该调用的次数),非零表示倒计时次数(回调参数表示剩余次数)
	interval 		[number]间隔(s)
	callback 		[function]回调函数
]]
function TimeLib.newCountDownObj(count,interval,callback)
	local node = cc.Node:create()
	local repeatCount = count
	local needCountDown = repeatCount > 0
	local handle

	local function listener(dt)
		if tolua.isnull(node) then
			Scheduler.unschedule(handle)
			return
		end

		if needCountDown then
			repeatCount = repeatCount - MATH_MAX(MATH_CEIL(dt/interval-0.2),0)
			if repeatCount <= 0 then
				repeatCount = 0
				Scheduler.unschedule(handle)
			end
		else
			repeatCount = MATH_MAX(MATH_CEIL(dt/interval-0.2),0)
		end

		if callback then
			callback(repeatCount)
		end
	end

	function node:setRepeatCount(count)
		repeatCount = count
	end

	handle = Scheduler.schedule(listener, interval, count)
	node:onNodeEvent("cleanup",function ()
		Scheduler.unschedule(handle)
	end)
	return node,handle
end

function TimeLib.getYear(ms)
	ms = ms or ServerTimeModel:getServerTimeMS()
	return MathToInteger(os.date("%Y", MATH_FLOOR(ms/1000)))
end

function TimeLib.getMonth(ms)
	ms = ms or ServerTimeModel:getServerTimeMS()
	return MathToInteger(os.date("%m", MATH_FLOOR(ms/1000)))
end

function TimeLib.getDay(ms)
	ms = ms or ServerTimeModel:getServerTimeMS()
	return MathToInteger(os.date("%d", MATH_FLOOR(ms/1000)))
end

-- 获取当月有多少天数 added by xhd
function TimeLib.getThisMoneyAllDay( ms )
	ms = ms or ServerTimeModel:getServerTimeMS()
	print(1,ms)
	local dayAmount = os.date("%d", os.time({year=TimeLib.getYear(), month=TimeLib.getMonth()+1, day=0})) 
	return MathToInteger(dayAmount)
end

function TimeLib.getNormalDay(ms)
	ms = ms or ServerTimeModel:getServerTimeMS()
	local year=MathToInteger(os.date("%Y", MATH_FLOOR(ms)))
	local mount=MathToInteger(os.date("%m", MATH_FLOOR(ms)))
	local day=MathToInteger(os.date("%d", MATH_FLOOR(ms)))
	return year.."/"..mount.."/"..day
end

-- 获取当日距凌晨12点还有多少秒
function TimeLib.getDayResidueSecond(ms)
	ms = ms or ServerTimeModel:getServerTimeMS()
	local residue= 24 * 60 * 60- ((ms-TimeLib.GetDateStamp())/1000)
	return residue
end

--获取星期几 added by xhd
function TimeLib.getCurWeekDayShow(y,m,d)
	if not y or not m or not d then
	end
	y = TimeLib.getYear()
	m = TimeLib.getMonth()
	d = TimeLib.getDay()
    if m == 1 or m == 2 then
        m = m + 12
        y = y - 1  
    end
    local m1,_ = math.modf(3 * (m + 1) / 5)
    local m2,_ = math.modf(y / 4)
    local m3,_ = math.modf(y / 100)
    local m4,_ = math.modf(y / 400)
 
    local iWeek = (d + 2 * m + m1 + y + m2 - m3  + m4 ) % 7 +1
    local weekTab = {
        ["1"] = Desc.common_week..Desc.common_1,
        ["2"] = Desc.common_week..Desc.common_2,
        ["3"] = Desc.common_week..Desc.common_3,
        ["4"] = Desc.common_week..Desc.common_4,
        ["5"] = Desc.common_week..Desc.common_5,
        ["6"] = Desc.common_week..Desc.common_6,
        ["7"] = Desc.common_week..Desc.common_day,
    }
    return weekTab[tostring(iWeek)] 
end

function TimeLib.getHour(ms)
	ms = ms or ServerTimeModel:getServerTimeMS()
	return MathToInteger(os.date("%H", MATH_FLOOR(ms/1000)))
end

function TimeLib.getMin( ms )
	ms = ms or ServerTimeModel:getServerTimeMS()
	return MathToInteger(os.date("%M", MATH_FLOOR(ms/1000)))
end

function TimeLib.getSec( ms )
	ms = ms or ServerTimeModel:getServerTimeMS()
	return MathToInteger(os.date("%S", MATH_FLOOR(ms/1000)))
end

function TimeLib.getHNM( ms )
	ms = ms or ServerTimeModel:getServerTimeMS()
	return os.date("%H:%M", MATH_FLOOR(ms/1000))
end

function TimeLib.getHMS( ms )
	ms = ms or ServerTimeModel:getServerTimeMS()
	return os.date("%H:%M:%S", MATH_FLOOR(ms/1000))
end


function TimeLib.getMS( ms )
	ms = ms or ServerTimeModel:getServerTimeMS()
	return os.date("%M:%S", MATH_FLOOR(ms/1000))
end

function TimeLib.getTotalDays(ms)
	ms = ms or ServerTimeModel:getServerTimeMS()
	local timeZoneDiffMs = ServerTimeModel:getCurTimeZone() * msperhour
	return MATH_FLOOR( (ms-timeZoneDiffMs) / msperday) + 1
end

function TimeLib.getWeekDay(ms)
	ms = ms or ServerTimeModel:getServerTimeMS()
	local days = TimeLib.getTotalDays(ms)
	return (days + 2) % 7 + 1
end
function TimeLib.getWeekDay2(ms)
	ms = ms or ServerTimeModel:getServerTimeMS()
	return tonumber( os.date("%w", ms) )
	-- local days = TimeLib.getTotalDays(ms)
	-- return (days + 2) % 7 + 1
end
--当月的最后一天
function TimeLib.getMonthLastDay(ms)
	ms = ms or ServerTimeModel:getServerTimeMS()
	local year = MathToInteger(os.date("%Y", MATH_FLOOR(ms/1000)))
	local month = MathToInteger(os.date("%m", MATH_FLOOR(ms/1000)))
	return os.date("%d",os.time({year=year,month=month+1,day=0}))
end

function TimeLib.GetDateStr(format)
	local dateStamp = Timestamp()
	return TimeLib.MsToString(dateStamp,format)
end

function TimeLib.getDiffDay(ms1,ms2)
	-- print
	return getTotalDays(ms1) - getTotalDays(ms2)
end

-- params = {
-- 	year = 2017,--必须包含字段
-- 	month = 10,	--必须包含字段
-- 	day = 26,	--必须包含字段
-- 	hour = 14,	--默认值0
-- 	min = 55,	--默认值0
-- 	sec = 10, 	--默认值0
-- 	isdst = nil --默认值nil
-- } 或者 params = nil
function TimeLib.getTime(params)
	return os.time(params)
end

local format_normal = "%Y-%m-%d %H:%M:%S"
function TimeLib.msToString( ms, format )
	format = format or format_normal
	return os.date(format, MATH_FLOOR(ms / 1000))
end

-- xx天xx小时xx分xx秒
function TimeLib.GetTimeFormatDay(less_time,type)
    less_time = tonumber(less_time) or 0
    local day = MATH_FLOOR(less_time/86400)
    local lessT = MATH_FLOOR(less_time%86400)
    local hour = MATH_FLOOR(lessT / 3600)
    local min = MATH_FLOOR((lessT % 3600) / 60)
    local sec = MATH_FLOOR(lessT % 3600 % 60)
    local dayStr = ""
    dayStr = day..Desc.common_day
    if less_time>=24*3600 then -- xx天xx小时
    	if type == 1 then
    		return dayStr..hour..Desc.common_hour
    	else
    		return dayStr..hour..Desc.common_hour..min..Desc.common_minute
    	end
	else
		return hour..Desc.common_hour..min..Desc.common_minute..sec..Desc.common_second
	end
end

-- xx天xx小时
function TimeLib.GetTimeFormatDay1(less_time)
    less_time = tonumber(less_time) or 0
    local day = MATH_FLOOR(less_time/86400)
    local lessT = MATH_FLOOR(less_time%86400)
    local hour = MATH_FLOOR(lessT / 3600)
    local min = MATH_FLOOR((lessT % 3600) / 60)
    local sec = MATH_FLOOR(lessT % 3600 % 60)
	local dayStr = ""
	if day>0 then -- xx天xx小时
		dayStr=string.format( "%s"..Desc.common_day.."%s"..Desc.common_hour,day,hour)
	elseif day==0 and hour>0 then
		dayStr=string.format( "%s"..Desc.common_hour.."%s"..Desc.common_minute,hour,min)	
	else
		dayStr=string.format( "%s"..Desc.common_minute.."%s"..Desc.common_second,min,sec)
	end
	return dayStr
end



function TimeLib.getTimeFormatMS(time)
	return os.date(Desc.common_timeFormat, time)
end
-- xx小时xx分xx秒
function TimeLib.getTimeFormatOneDay(less_time)
    less_time = tonumber(less_time) or 0
    local lessT = MATH_FLOOR(less_time%86400)
    local hour = MATH_FLOOR(lessT / 3600)
    local min = MATH_FLOOR((lessT % 3600) / 60)
    local sec = MATH_FLOOR(lessT % 3600 % 60)
    local hourStr = hour < 10 and ("0" .. hour .. Desc.common_hour) or (hour .. Desc.common_hour)
    local minStr = min < 10 and ("0" .. min .. Desc.common_minute) or (min .. Desc.common_minute)
    local secStr = sec < 10 and ("0" .. sec .. Desc.common_second) or (sec .. Desc.common_second)
    return hourStr..minStr..secStr

end

--大于1天显示X天,小于1天显示X小时X分X秒
function TimeLib.getTimeFormatOneDay2(less_time)
	less_time = tonumber(less_time) or 0
    local day = MATH_FLOOR(less_time/86400)
    local lessT = MATH_FLOOR(less_time%86400)
    local hour = MATH_FLOOR(lessT / 3600)
    local min = MATH_FLOOR((lessT % 3600) / 60)
    local sec = MATH_FLOOR(lessT % 3600 % 60)
	local dayStr = ""
	if day>0 then -- xx天xx小时
		dayStr=string.format( "%s"..Desc.common_day)
	else 
		dayStr=string.format( "%s"..Desc.common_hour.."%s"..Desc.common_minute.."%s"..Desc.common_second,hour,min,sec)	
	end
	return dayStr
end

function TimeLib.GetMinSecTime(less_time)
    less_time = tonumber(less_time) or 0
    local hour = MATH_FLOOR(less_time / 3600)
    hour = (hour < 10) and "0"..hour or hour
    local min = MATH_FLOOR((less_time % 3600) / 60)
    min = (min < 10) and "0"..min or min
    local sec = less_time % 3600 % 60
    sec = (sec < 10) and "0"..sec or sec
    return  min .. ":" .. sec
end

function TimeLib.getHourMinTime(less_time)
	less_time = tonumber(less_time) or 0
    local hour = MATH_FLOOR(less_time / 3600)
    hour = (hour < 10) and "0"..hour or hour
    local min = MATH_FLOOR((less_time % 3600) / 60)
    min = (min < 10) and "0"..min or min
    
    return  hour .. ":" .. min
end

function TimeLib.getMDHMS(less_time)
   return os.date("%m-%d %X ", less_time)
end

function TimeLib.BsonDate( ms )
	if ms then
		return bson.date(ms/1000)
	end
	return bson.date(Timestamp()/1000)
end

--[[ 字符串时间转成时间戳
@timeString: 字符串时间 ,时间格式必须为 2018-08-07 10:43:33
@return: 返回时间戳(int)
    例:  print (string2time('2018-08-07 10:43:33'))
--]]
 
function TimeLib.string2time(timeString)
    if type(timeString) ~= 'string' then error('string2time: timeString is not a string') return 0 end
    local fun = string.gmatch( timeString, "%d+")
    local y = fun() or 0
    if y == 0 then error('timeString is a invalid time string') return 0 end
    local m = fun() or 0
    if m == 0 then error('timeString is a invalid time string') return 0 end
    local d = fun() or 0
    if d == 0 then error('timeString is a invalid time string') return 0 end
    local H = fun() or 0
    if H == 0 then error('timeString is a invalid time string') return 0 end
    local M = fun() or 0
    if M == 0 then error('timeString is a invalid time string') return 0 end
    local S = fun() or 0
    if S == 0 then error('timeString is a invalid time string') return 0 end
    return os.time({year=y, month=m, day=d, hour=H,min=M,sec=S})
end


function TimeLib.ToTimestamp( dt )
	local xyear, xmonth, xday
	local xhour, xminute,xseconds, xmillisec = 0,0,0,0
	local sz = #dt
	if sz <= sz_day then
		xyear, xmonth, xday = dt:match(pattern_day)
	elseif sz <= sz_sec then
		xyear, xmonth, xday,xhour, xminute,xseconds = dt:match(pattern_sec)
	else
		xyear, xmonth, xday,xhour, xminute,xseconds,xmillisec = dt:match(pattern_full)
	end
	if xyear == nil then
		return
	end
	return os.time({year = xyear, month = xmonth, day = xday, hour = xhour, min = xminute, sec = xseconds}) * 1000 + xmillisec
end

local function Timestamp()
	return ServerTimeModel:getServerTimeMS()
end

--获取时间戳所代表的日期零时的时间戳
--[[
@timestamp:时间戳，妙级
@return 当天凌晨的时间戳
]]

function TimeLib.DayInWeek( ms )
	ms = ms or Timestamp()
	local weekday = tonumber(os.date("%w", math.floor(ms/1000)))
	if weekday == 0 then
		weekday = 7
	end
	return weekday
end

--获取时间戳所代表的日期零时的时间戳
--[[
@timestamp:时间戳，妙级
@return 当天凌晨的时间戳
]]
--Dean***:好像有问题
local function GetDateStamp(timestamp)
	timestamp = timestamp or Timestamp()
	return TimeLib.ToTimestamp(os.date(format_normal_date, timestamp/1000))
end
TimeLib.GetDateStamp = GetDateStamp

--[[
计算两个时间点的秒数之差
@fromMs:起始时间戳 毫秒级
@toMs:结束时间戳 毫秒级
@return 两个时间点相差的秒数
]]
function TimeLib.DifSec( fromMs, toMs )
	local diff = toMs - fromMs
	return math.floor(diff / mspersecond)
end

--[[
获得数字类型的日期，如：20170902
@ms:毫秒级时间戳
@return 数字类型的日期
]]
function TimeLib.NumberDate( ms )
	--20170902
	ms = ms or Timestamp()
	return tonumber(TimeLib.MsToString(ms, format_number))
end

--[[
计算两个时间相差的分钟数
@fromMs:起始时间戳 毫秒级
@toMs:结束时间戳 毫秒级
@return 两个时间点相差的分钟数
]]
function TimeLib.DifMin( fromMs, toMs )
	local diff = toMs - fromMs
	return math.floor(diff / msperminute)
end


--[[
计算两个日期相差的天数，注意，只要过了凌晨就算相隔一天，无论是否超过24小时
@fromMs:起始时间戳 毫秒级
@toMs:结束时间戳 毫秒级
@return 两个日期相隔的天数
]]
function TimeLib.DifDate( fromMs, toMs )
	local fromhourstamp = fromMs - GetDateStamp(fromMs)
	local tohourstamp = toMs - GetDateStamp(toMs)
	local days = TimeLib.DifDay(fromMs, toMs)
	if fromhourstamp > tohourstamp then
		days = days + 1
	end
	return days
end

--[[
计算两个日期相差的天数，注意，这个不同于DifDate，就是计算实际的时间差
@fromMs:起始时间戳 毫秒级
@toMs:结束时间戳 毫秒级
@return 两个时间点相隔的天数
]]
function TimeLib.DifDay( fromMs, toMs )
	local diff = toMs - fromMs
	return MATH_FLOOR(diff / msperday)
end

function TimeLib.TimestampWithoutHMS( ms )
	ms = ms or ServerTimeModel:getServerTimeMS()
	local totalDays = TimeLib.getTotalDays(ms)
	return (totalDays - 1) * msperday + ServerTimeModel:getCurTimeZone() * 3600 *1000
end

--[[ 
	added by zn
	这周日24点的时间戳
	isNature 是否自然周，自然周是周五开服，到周日第二周，不是自然周的话，那么要到开服第八天才算第二周
	@return 单位:s 
]]
function TimeLib.nextWeekBeginTime(isNature)
	if isNature == nil then isNature = true end
	if isNature then
		local today = TimeLib.DayInWeek();
		local ms = TimeLib.GetDateStamp() + (8 - today) * msperday -- 60 * 60 *24 *1000
		-- LuaLogE("这周结束时间戳", ms / 1000);
		return ms / 1000 -- 单位:s
	else
		local day = (7 - math.mod(ServerTimeModel:getOpenDay() + 1, 7)) 
		if day >= 7 then day = day - 7 end
		-- LuaLogE("这周结束时间戳", ms / 1000);
		return ServerTimeModel:getServerTime() + day * 60 * 60 *24  + TimeLib.getDayResidueSecond()
	end
end

--[[ 
	added by zn
	这月末24点的时间戳
	@return 单位:s 
]]
function TimeLib.nextMonthBeginTime()
	local allDay = TimeLib.getMonthLastDay();
	local ms = TimeLib.GetDateStamp() + (allDay - TimeLib.getDay() + 1) * msperday
	-- LuaLogE("这月结束时间戳", ms / 1000);
	return ms / 1000 -- 单位:s
end

--[[
获得时间戳在操作系统的日期
@ms:时间戳 毫秒级
@return 字符串格式的日期
]]
function TimeLib.OsDate( ms )
	return os.date(format_normal, math.floor(ms/1000))
end

local timeZone = false
function TimeLib.GetLocalTimeZone()
	if not timeZone then
		local now = os.time()
		timeZone = -math.ceil(os.difftime(now, os.time(os.date("!*t", now))) / 3600)
	end

	return timeZone
end

--[[
将秒转化为毫秒 
]]
function TimeLib.Sec2Mil( sec )
	return sec * 1000
end

function TimeLib.GetServerOpenDays( openDateMs ,mergeFirstDay)
	if not openDateMs then
		return 0
	end
	local days = TimeLib.GetTotalDays() - TimeLib.GetTotalDays(openDateMs) + 1
	if mergeFirstDay and days > 1 then
		days = days - 1
	end
	return days
end

--[[
计算两个日期相差的周数
@fromMs:起始时间戳 毫秒级
@toMs:结束时间戳 毫秒级
@return 两个时间点相隔的周数
]]
function TimeLib.DifWeek( fromMs, toMs)
	local difDate = TimeLib.DifDate(fromMs,toMs)
	local dayInWeek = TimeLib.DayInWeek(fromMs)

	return math.floor((difDate + dayInWeek - 1) / 7)
end

--[[
计算两个日期是否不是同一个月
@fromMs:起始时间戳 毫秒级
@toMs:结束时间戳 毫秒级
@return 是否不是同一个月
]]
function TimeLib.IsDifMonth( fromMs, toMs)
	local fromMonth = TimeLib.Month(fromMs)
	local fromYear = TimeLib.Year(fromMs)
	local toMonth = TimeLib.Month(toMs)
	local toYear = TimeLib.Year(toMs)
	if fromYear ~= toYear or fromMonth ~= toMonth then
		return true
	end
end

function TimeLib.IsCross( ms,crossHour )
	if not ms or ms <= 0 then
		return
	end

	local isCross
	local crossDay = 0
	local totalDays = TimeLib.GetTotalDays(ms)
	local nowTotalDays = TimeLib.GetTotalDays()
	local hour = TimeLib.Hour(ms)
	local nowHour = TimeLib.Hour()
	if totalDays > nowTotalDays then
		return
	end
	if totalDays == nowTotalDays then
		if hour < crossHour and nowHour >= crossHour then
			isCross = true
			crossDay = 1
		end
	else
		if nowTotalDays == totalDays + 1 then
			if hour < crossHour or nowHour >= crossHour then
				isCross = true
			end
		else
			isCross = true
		end

		crossDay = nowTotalDays - totalDays - 1
		if hour < crossHour then
			crossDay = crossDay + 1
		end
		if nowHour >= crossHour then
			crossDay = crossDay + 1
		end
	end
	return isCross,crossDay 
end

function TimeLib.BsonMs( date )
	local _, dateSec = bson.type(date)
	return dateSec * 1000
end

function TimeLib.GetTotalDaysByDateStr( dateStr )
	local dateMs = TimeLib.ToTimestamp(dateStr)
	return TimeLib.GetTotalDays(dateMs)
end

function TimeLib.WeekStartDay( ms )
	ms = ms or Timestamp()
	local totalDays = TimeLib.GetTotalDays(ms)--本来这里是要扣4天的，因为时间戳0也就是197001是周4如果ms太小就会出问题了，同时大家也按这个标准来做，就没太大问题了。
	local dayInWeek = TimeLib.DayInWeek(ms)
	return totalDays-dayInWeek
end

--通过 "12:00:00" 类似时间获取今天对应的时间戳
function TimeLib.GetTimestampByHMS( timeStr ,timeMs)
	local year = TimeLib.Year(timeMs)
	local month = TimeLib.Month(timeMs)
	local day = TimeLib.Date(timeMs)
	local dataStr = string.format("%s-%s-%s %s",year,month,day,timeStr)
	return TimeLib.ToTimestamp(dataStr)
end

-- 单位ms
function TimeLib.GetWeekStartStamp(timeStamp)
	timeStamp = timeStamp or TimeLib.Timestamp()
	local startWeekStamp = ((TimeLib.WeekStartDay(timeStamp)) * 24 + TimeLib.GetLocalTimeZone()) * 3600 * 1000
	return startWeekStamp
end

return TimeLib