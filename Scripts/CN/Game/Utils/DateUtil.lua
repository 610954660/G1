--时间日期处理类

module("DateUtil", package.seeall)
local callbacks = {}
local clockId = -1
local function onTick(self)
	for k, v in pairs(callbacks) do
		v.callback(v.params)
	end
end

--[[
注册回调
@param	callback		[function]	回调函数
@param	callbackParams	[function]	回调函数附带的参数

@example
local function callback(curTime, params)
	
end
Cache.serverTimeCache.registerCallback(callback, {a=1, b=?})
]]
function registerCallback(callback, callbackParams)
	if not callbacks[callback] and type(callback) == "function" then
		callbacks[callback] = {callback=callback, params = callbackParams}
	end
	
	if clockId == -1 then
		CountDownUtil.start(10000000000000, 1000, onTick)
	end
end
--取消注册
function unregisterCallback(callback)
	callbacks[callback] = nil	
	if table.isEmpty(callbacks) then
		CountDownUtil.stop(clockId)
		clockId = -1
	end
end

--检测天数是不是和之前不同
local lastDate = -1
function dateCheckerOnTick()
	local nowDate = getOppostieDays()
	if lastDate ~= -1 then
		if nowDate > lastDate then
			setTimeout(function()
				Dispatcher.dispatchEvent(EventTypes.PUBLIC_DATE_CHANGE) end, 10000)
		end
	end
	lastDate = nowDate
end

--开始日期检测 
function startDateChecker()
	registerCallback(dateCheckerOnTick)
end

--停止日期检测
function stopDateChecker()
	unregisterCallback(dateCheckerOnTick)
	for k, v in pairs(callbacks) do
		unregisterCallback(v.callback)
	end
end

--最大容错时间(s)
local MAX_TIME_DIFF = 5
local MAX_NUM_FAILED_TIMES = 2
--超过最大容错的次数
local numFailedTimes = 0

--检测系统时间是不是有修改过(用于防作弊)
function checkSystemTime(serverTime)
	local timeDiff = math.abs(getServerTime() - serverTime)
	if timeDiff >= MAX_TIME_DIFF then
		numFailedTimes = numFailedTimes + 1
		if numFailedTimes >= MAX_NUM_FAILED_TIMES or timeDiff >= MAX_TIME_DIFF * 3 then
			--Cache.loginCache.loginOutReason = Language.getString(101014)
			--Session.SessionManager:abandon(Rmi.SessionType.GateSession)
			print("系统时间更改") --  
			return
		end			
	end
	print(1, "-----checkSystemTime", serverTime, timeDiff, numFailedTimes)
end

--断线重连时的清理
function cleanup()
	CountDownUtil.stop(clockId)
	clockId = -1	
	callbacks = {}
	numFailedTimes = 0
end

--[[获取指定年月的天数和第一天的星期 
year 年份
month 月份
]]
function getDays(year, month)
	local year = tonumber(year)       
	local month = tonumber(month)       
    local bigmonth = "(1)(3)(5)(7)(8)(10)(12)"
    local strmonth = "(" .. tonumber(month) .. ")"
    local week = os.date("*t", os.time{year = year, month = month, day = 1})["wday"]
    if month == 2 then
        if year % 4 == 0 or (year % 400 == 0 and year % 400 ~= 0) then
            return 29, week
        else
            return 28, week
        end
    elseif string.find(bigmonth, strmonth) ~= nil then
        return 31, week
    else
        return 30, week
    end
end

--[[
2015-04-24 tanjianran修正，程序里的“时间精确来说是相对于1970年1月1日08点0分0秒已过去的时间”，所以算天数修正为先加上8小时
8小时=8*60*60秒，即28800秒
1天=24*60*60秒，即86400秒
-----------修正end

获取当前日期的相对天数（1970年1月1日）
]]
function getOppostieDays()
	--return math.floor(os.serverTime()/60/60/24)
	return math.floor((ModelManager.ServerTimeModel:getServerTime() + 28800)/86400)
end	

--[[
根据字符串得到日期（秒） 2013-12-30 23:20:20
]]
function getDateSecByStr(str)
	local sec = 0
	--print("getDateSecByStr:",str)
	local strArr = string.split(str," ")
	local strArrD = string.split(strArr[1],"-")
	local strArrT = string.split(strArr[2],":")
	local curYear = tonumber(strArrD[1])
	local curMon = tonumber(strArrD[2])
	local curDay = tonumber(strArrD[3])
	local curHour = tonumber(strArrT[1])
	local curmin = tonumber(strArrT[2])
	local cursec = tonumber(strArrT[3])
	
	if curYear >= 2036 then curYear = 2035 end --因为在安卓里面，到2036年，数值已经超了int支持最大值了，算出来的sec会是nil
	sec = os.time{year=curYear, month=curMon, day=curDay, hour = curHour, min = curmin, sec = cursec}
	return sec
end

function getTimeSecByStr(str)
	local sec = 0
	--print("getDateSecByStr:",str)
	local strArrT = string.split(str,":")
	local curHour = tonumber(strArrT[1])
	local curmin = tonumber(strArrT[2])
	local cursec = tonumber(strArrT[3])
	sec = curHour * 60*60 + curmin*60 + cursec
	
	return sec
end


function getTimeStrBySec(second)
	local hour = math.floor(second/3600)
	local min = math.floor(math.mod(second,3600)/60)
	local sec = math.mod(second,60)
	if hour > 0 then
		return string.format("%s:%s:%s",formatString(hour),formatString(min),formatString(sec))
	else
		return string.format("%s:%s",formatString(min),formatString(sec))
	end
end


--[[
	把时间格式化成字符串
]]
function format(sec, formatStr)
	if not formatStr then 
		formatStr = "hh:mm:ss"
	end
	return Cdl.createDate(sec):asString(formatStr)
end

local secondsPerDay = 60 * 60 * 24
local secondsPerHour = 60 * 60
--[[
	通过秒数获取剩余时间
	showHour bool 是否显示小时，非中文的时候，不显示小时则会将时间加落分钟。 格式59:30
	showAsChinese bool 是否显示中文 中文格式 4小时30分钟20秒
	isFull bool 是否显示完整时间，false的时候，小于1天只显示小时，小于1小时只显示分钟，小于1分钟只显示秒数
	noShowSec 是否显示秒数
]]
function getRemainingTime(totalsec,showHour,showAsChinese,isFull,noShowSec)
	local str = ""
	local days = 0 --天
	local daysR = 0--去除天后剩余的秒
	local hour = 0--小时数
	local hoursR = 0--去除小时后剩余的秒
	local min = 0--分钟数
	local minR = 0--去小时数后剩余的秒数
	local sec = 0--秒数
	
	days = math.floor(totalsec / secondsPerDay)
	if days < 0 then 
		days = 0
	end
	daysR = totalsec % secondsPerDay
	hour = math.floor(daysR / secondsPerHour)
	if hour < 0 then 
		hour = 0
	end
	hoursR = daysR % secondsPerHour;
	min = math.floor(hoursR / 60)
	if min < 0 then 
		min = 0
	end
	minR = hoursR % 60;
	sec = math.floor(minR % 60)
	if sec < 0 then 
		sec = 0
	end
			
	if not showAsChinese and showHour then 
		str = formatString(hour+days*24)..":"..formatString(min)..":"..formatString(sec)
	elseif not showAsChinese then
		str = formatString(min+hour*60)..":"..formatString(sec)
	elseif showAsChinese and isFull then
		if days > 0 then 
			str = str..days.."d "
		end
		if hour>0 then
			str = str..hour.."h "
		else
			str = str.. 0 .."h "
		end
		if min>0 then
			str = str..min.."min "
		else
			str = str.. 0 .."min"
		end
		if not noShowSec then
			str = str..sec.."s"
		else
			
		end
	elseif showAsChinese then
		if days > 0 then 
			str = str..days.."d "
			return str
		end
		if hour>0 then
			str = str..hour.."h "
			return str
		end
		if min>0 then
			str = str..min.."min "
			return str
		end
		if not noShowSec then
			str = str..sec.."s"
		else
			
		end
	end

	return str
end


--[[
	商城中限时购买的倒计时
	通过秒数获取剩余时间
	showHour bool 是否显示小时，非中文的时候，不显示小时则会将时间加落分钟。 格式59:30
	showAsChinese bool 是否显示中文 中文格式 4小时30分钟20秒
	isFull bool 是否显示完整时间，false的时候，小于1天只显示小时，小于1小时只显示分钟，小于1分钟只显示秒数
]]
function getRemainingTimeForStore(totalsec,showHour,showAsChinese,isFull)
	local str = ""
	local days = 0 --天
	local daysR = 0--去除天后剩余的秒
	local hour = 0--小时数
	local hoursR = 0--去除小时后剩余的秒
	local min = 0--分钟数
	local minR = 0--去小时数后剩余的秒数
	local sec = 0--秒数
	
	days = math.floor(totalsec / secondsPerDay)
	if days < 0 then 
		days = 0
	end
	daysR = totalsec % secondsPerDay
	hour = math.floor(daysR / secondsPerHour)
	if hour < 0 then 
		hour = 0
	end
	hoursR = daysR % secondsPerHour;
	min = math.floor(hoursR / 60)
	if min < 0 then 
		min = 0
	end
	minR = hoursR % 60;
	sec = math.floor(minR % 60)
	if sec < 0 then 
		sec = 0
	end
			
	if not showAsChinese and showHour then 
		str = formatString(hour+days*24)..":"..formatString(min)..":"..formatString(sec)
	elseif not showAsChinese then
		str = formatString(min+hour*60)..":"..formatString(sec)
	elseif showAsChinese and isFull then
		if days > 0 then 
			str = str..days.."天"
		end
		if hour>0 then
			str = str..hour.."时"
		else
			str = str.. 0 .."时"
		end
--		if min>0 then
--			str = str..min.."分"
--		else
--			str = str.. 0 .."分"
--		end
--		str = str..sec.."秒"
	elseif showAsChinese then
		if days > 0 then 
			str = str..days.."天"
			return str
		end
		if hour>0 then
			str = str..hour.."时"
			return str
		end
--		if min>0 then
--			str = str..min.."钟"
--			return str
--		end
--		str = str..sec.."秒"
	end

	return str
end

--传入截止时间，判断是否过期
--参数：2015-01-20 00:00:00.000 
function isDateExsit(lastHotDt)
	--根据字符串得到日期（秒）
	local hot_totalsec = DateUtil.getDateSecByStr(lastHotDt)
	--print("剩余秒数",hot_totalsec- os.serverTime())
	if hot_totalsec - os.serverTime()> 0 then
		return true
	end
	return false
end

function formatString(value)
	if value < 0 then
		return "00"
	end
			
	local str
	if value <= 9 then
		str = "0"..value
	else
		str = value..""
	end			
	return str
end


--[[
获取当前时区，东区为正数，西区为负数，例如北京时间为东八区，返回的值为8
]]
function getCurTimeZone()
	local standardTime = os.time({year=1970, month=1, day=1, hour = 24, min = 0, sec = 0})
	standardTime = 24 - standardTime/3600
	return standardTime
end

function getDisplayStr(sec)
	local day = math.floor(sec/secondsPerDay)
	local hour = math.floor(sec % secondsPerDay / 3600)     --计算时 3600进制
	local min = math.floor((sec % 3600) / 60)   --计算分  60进制
	local sec = sec % 60   --计算秒  余下的全为秒数
	
	local text
	if day >= 1 then
		if hour ~= 0 then
			text = string.format("%dd%dh",day, hour)
		else
			text = string.format("%dd",day)
		end
	elseif hour >= 1 then
		if min ~= 0 then
			text = string.format("%dh%dm",hour, min)
		else
			text = string.format("%dh",hour)
		end
	elseif min >= 1 then
		if sec~= 0 then
			text = string.format("%dm%ds",min, sec)
		else
			text = string.format("%dm",min)
		end
	else
		text = string.format("%ds", sec)
	end
	return text
end

--获取指定时刻所在当天0时0分0秒的秒数
function getThedaySecond(sec)
	local date = os.date("*t",sec)
	date.hour = 0
	date.min = 0
	date.sec = 0
	return os.time(date)
end