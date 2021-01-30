--TimeUtil的一些具体封装处理
local TimeLib = require "Game.Utils.TimeLib"
local TimeUtil = {}

--控制按钮显示状态,   例如：倒计时:
--示例：
--self.timer = TimeUtil.upCompEnable(self.reward , "奖励%s秒", 10 , true )
--TimeUtil.clearTime(self.timer)
function TimeUtil.upCompEnable(view , times , textStr , needFormat)
	if view then
		local preTxt = view:getText();
		local curTime = false		 
		view:setGrayed(true)
		view:setTouchable(false)
		local curTxt = times  
		if needFormat then curTxt = TimeLib.formatTime( times ); end
		view:setText( string.format( textStr, curTxt ) )
		local function onCountDown(time)			
			if view then			
				view:setText( string.format( textStr, time) )			
			else				
				TimeUtil.clearTime(curTime);
			end;			
		end
		local function onEnd( ... )
			if view then 
				view:setGrayed(false)
				view:setTouchable(true)
				view:setText(preTxt)				
			end
			TimeUtil.clearTime(curTime);
		end
		curTime = TimeLib.newCountDown(times-1, onCountDown, onEnd, false, false , needFormat)
		return curTime
	end
end
--文本倒计时，使用方式同上
--@param endStr    倒计时结束后需要显示的内容,如果不传的话，会默认使用当前文本内容
function TimeUtil.upText(view ,times , textStr , endStr,  needFormat)
	if view then
		if endStr == nil then endStr = view:getText() end
		local curTime = false
		local curTxt = times  
		if needFormat then curTxt = TimeLib.formatTime( times ); end
		view:setText( string.format( textStr, curTxt ) )
		local function onCountDown(time)			
			if view then			
				view:setText( string.format( textStr, time) )			
			else				
				TimeUtil.clearTime(curTime);
			end;			
		end
		local function onEnd( ... )
			if view then 			
				view:setText( endStr )			
			end
			TimeUtil.clearTime(curTime);
		end
		curTime = TimeLib.newCountDown(times-1, onCountDown, onEnd, false, false , needFormat)
		return curTime
	end
end
--清除倒计时
function TimeUtil.clearTime(timer)
	TimeLib.clearCountDown(timer);
	timer = nil
end


return TimeUtil