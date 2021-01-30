local CrossPVPMatchView,Super = class("CrossPVPMatchView", Window)

function CrossPVPMatchView:ctor(data)
	self._packName = "CrossPVP"
	self._compName = "CrossPVPMatchView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
	self.baseData = data
	self.bttleResult = false
	self.waitServer = false
end

function CrossPVPMatchView:_initEvent()
	
end

function CrossPVPMatchView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossPVP.CrossPVPMatchView
	self.closeButton = viewNode:getChildAutoType('$closeButton')--GLabel
	self.fObj1 = viewNode:getChildAutoType('fObj1')--GImage
	self.fObj2 = viewNode:getChildAutoType('fObj2')--GImage
	self.fObj3 = viewNode:getChildAutoType('fObj3')--GImage
	self.spine = viewNode:getChildAutoType('spine')--GLoader
	self.time = viewNode:getChildAutoType('time')--GRichTextField
	--{autoFieldsEnd}:CrossPVP.CrossPVPMatchView
	--Do not modify above code-------------
end

function CrossPVPMatchView:_initUI()
	self:_initVM()
	if self.baseData.gameType == GameDef.BattleArrayType.Trail then
		self.waitServer = true
		self.timeStr = math.random(3,6)
	else
		self.timeStr = math.random(5,10)
	end
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
	self:_refreshView()
end
function CrossPVPMatchView:update(dt)
	self.curTime = self.curTime + dt
	self.time:setText(string.format(Desc.CrossPVPDesc8,math.floor(self.curTime)))
	if (self.curTime >= self.timeStr and not self.waitServer) or self.curTime > 10 then
		self:closeView()
		if self.baseData.gameType == GameDef.BattleArrayType.Trail then
			Dispatcher.dispatchEvent("trialActivity_matchFinish")
		else
			ViewManager.open("CrossFightAnimationView",self.baseData)
		end
		if self.timer then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
			self.timer = false
		end
	end
end


function CrossPVPMatchView:_refreshView()
	local spineNode = SpineMnange.createByPath("Spine/ui/CrossPVP","pipeizhong_texiao","pipeizhong_texiao")
	spineNode:setAnimation(0,"animation",true)
	self.spine:displayObject():addChild(spineNode)
end

function CrossPVPMatchView:trialActivity_matchSuccess()
	self.waitServer = false
end

function CrossPVPMatchView:onExit_()

end
function CrossPVPMatchView:_exit()
	if self.timer then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
		self.timer = false
	end
end
return CrossPVPMatchView