	--added by wyang
--秘境摇骰子组件
local TwistRegimentRoll = class("TwistRegimentRoll")
function TwistRegimentRoll:ctor(view)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);

end






function TwistRegimentRoll:isSpeedUp(isUp)
	if isUp then
		self._defaultSpeed 	= 40 	-- 默认速度 					-- 默认速度40  3倍数
		self._changeSpeed 	= 20 	-- 每50次降低一次速度 		-- 每20次下降一次速度
		self._speedDesc 	= 20  	-- 每次速度下降 				-- 每次速度下降 20
		self._minSpeed 		= 20	-- 最小移动速度 				-- 最小移动速度 20
		self._poor			= 14
	else
		self._defaultSpeed 	= 20 	
		self._changeSpeed 	= 40 	
		self._speedDesc 	= 10  	
		self._minSpeed 		= 10
		self._poor 			= 10	
	end
end


--退出操作 在close执行之前 
function TwistRegimentRoll:__onExit()
    print(1,"TwistRegimentRoll __onExit")
	Scheduler.unschedule(self._updateTimeId)
end

return TwistRegimentRoll