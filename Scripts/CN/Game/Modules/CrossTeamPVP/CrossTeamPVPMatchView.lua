--Date :2020-12-09
--Author : wyz
--Desc : 组队竞技 匹配界面

local CrossTeamPVPMatchView,Super = class("CrossTeamPVPMatchView", Window)

function CrossTeamPVPMatchView:ctor()
	--LuaLog("CrossTeamPVPMatchView ctor")
	self._packName = "CrossTeamPVP"
	self._compName = "CrossTeamPVPMatchView"
	self._rootDepth = LayerDepth.PopWindow
	
end

function CrossTeamPVPMatchView:_initEvent( )
	
end

function CrossTeamPVPMatchView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossTeamPVP.CrossTeamPVPMatchView
	self.closeButton = viewNode:getChildAutoType('$closeButton')--GLabel
	self.fObj1 = viewNode:getChildAutoType('fObj1')--GImage
	self.fObj2 = viewNode:getChildAutoType('fObj2')--GImage
	self.fObj3 = viewNode:getChildAutoType('fObj3')--GImage
	self.time = viewNode:getChildAutoType('time')--GRichTextField
	--{autoFieldsEnd}:CrossTeamPVP.CrossTeamPVPMatchView
	--Do not modify above code-------------
end

function CrossTeamPVPMatchView:_initUI( )
	self:_initVM()
	CrossTeamPVPModel.countTime = 60 		-- 进入匹配重新计时
	-- CrossTeamPVPModel:reqMatch()
	self:setAnimation()
end

-- 设置匹配动画
function CrossTeamPVPMatchView:setAnimation()
	self.timeStr = math.random(3,7)
	self.curTime = 0
	self.time:setText(string.format(Desc.CrossPVPDesc8,self.curTime))
	
	self.timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.update),1, false)

	local node = self.fObj1:displayObject()
	local arr = {}
	table.insert(arr,cc.RotateBy:create(3,360))
	node:runAction(cc.RepeatForever:create(cc.Sequence:create(arr)))

	local node = self.fObj2:displayObject()
	local arr = {}
	table.insert(arr,cc.RotateBy:create(3,-360))
	node:runAction(cc.RepeatForever:create(cc.Sequence:create(arr)))

	local node = self.fObj3:displayObject()
	local arr = {}
	table.insert(arr,cc.RotateBy:create(12,360))
	node:runAction(cc.RepeatForever:create(cc.Sequence:create(arr)))
end

function CrossTeamPVPMatchView:update(dt)
	self.curTime = self.curTime + dt
	self.time:setText(string.format(Desc.CrossPVPDesc8,math.floor(self.curTime)))
	if self.curTime >= self.timeStr then
		self:closeView()
		ViewManager.open("CrossTeamFightAnimateView")
		if self.timer then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
			self.timer = false
		end
	end
end

function CrossTeamPVPMatchView:_exit()
	if self.timer then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
		self.timer = false
	end
end

return CrossTeamPVPMatchView