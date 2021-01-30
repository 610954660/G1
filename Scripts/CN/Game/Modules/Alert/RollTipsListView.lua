--可以支持多行的飘字
local RollTipsListView,Super = class("RollTipsListView", View)


function RollTipsListView:ctor(args)
	--LuaLogE("RollTips ctor")
	self._packName = "UIPublic_Window"
	self._compName = "RollTipsListView"
	self._rootDepth = LayerDepth.Message
	self.args = args
	self.title = false
	self._isFullScreen = true
	self.tipsItem = false
	
	self.list_msg = false
	self._rollMsgList = {}
	self._rollTipsTimer = false
	self._hideMsgTimer = false
	
	self._allShowMsg = {}
	self._showTime = 2000  --显示时间，超过这个时间就移除
	
	self._objPool = {}
	
	self._allItem = {}
	
	self._beginPosX = 0  --消息出来的点
	self._beginPosY = 0  --消息出来的点
	
	self.loader_msg = false
	
--[[	Scheduler.schedule(function()
			self:onRollUpdate()
		end,0.01)--]]
end


function RollTipsListView:_initUI()
	self.loader_msg = self.view:getChildAutoType("loader_msg")
	self.tipsItem = self.view:getChildAutoType("tipsItem")
	self:addMsgList(self.args)
end

function RollTipsListView:addMsgList(msgList)
	--[[for _,v in ipairs(self._allShowMsg) do
		v.showTime = cc.millisecondNow() - self._showTime + 200
	end--]]
	for _,v in ipairs(msgList) do
		self:addMsg(v)
	end
end

--获取一个消息对象
function RollTipsListView:getMsgObj(parent)
	if #self._objPool > 0 then
		local obj = self._objPool[1]
		parent:addChild(obj)
		obj:release() --放到对象池的时候已经retain过的了，这里要release一次
		table.remove(self._objPool, 1)
		return obj
	else
		local obj  = FGUIUtil.createObjectFromURL("UIPublic_Window","com_rollTipsItem")
		parent:addChild(obj)
		return obj
	end
end

function RollTipsListView:addMsgItem(args)
	local obj = self:getMsgObj(self.loader_msg)
	local strList = string.split(args.text, " ")
	local c1 = obj:getController("c1")
	if type(args.text) == "table" then
		c1:setSelectedIndex(1)
		obj:getChildAutoType("title"):setText(TableUtil.join(args.text, " "))
		obj:getChildAutoType("txt_left"):setText(args.text[1])
		obj:getChildAutoType("txt_right"):setText(args.text[2])
	else
		c1:setSelectedIndex(0)
		obj:getChildAutoType("title"):setText(args.text)
	end
	
	obj:setPosition(self._beginPosX,self._beginPosY)
	TableUtil.insertTo(self._allItem, 1, obj)
	args.showTime = cc.millisecondNow()
	args.item = obj
	TableUtil.insertTo(self._allShowMsg, 1, args)
	
	for i,v in ipairs(self._allItem) do
		local posY = v:getPosition().y 
		--if posY > -30*i + self._beginPosY then
			local targetY = -30*i + self._beginPosY
			v:setPosition(self._beginPosX, targetY)
		--end
		if #self._allItem > 15 then
			self:recycleItem()
		end
	end
	
end

--[[function RollTipsListView:onRollUpdate()
	for i,v in ipairs(self._allItem) do
		local posY = v:getPosition().y 
		if posY > -30*i + self._beginPosY then
			local targetY = posY - 10
			v:setPosition(self._beginPosX, targetY)
		end
	
	end
end--]]

function RollTipsListView:addMsg(msg)
	local arg = {text = msg}
	table.insert(self._rollMsgList, arg)
	if(#self._rollMsgList > 10) then
		table.remove(self._rollMsgList, 1)
	end
	--if self._rollTipsTimer == false then
	--	self._rollTipsTimer  = Scheduler.schedule(function()
			self:_showNextTips()
	--	end,0.1)
	--	self:_showNextTips()
	--end
end

function RollTipsListView:_showNextTips()
	print(1, "RollTipsListView.showNextTips")
	if not self._hideMsgTimer then
		self._hideMsgTimer = Scheduler.schedule(function()
			self:_hidetips()
		end,0.1)
	end
	if #self._rollMsgList  == 0 then
		if self._rollTipsTimer then
			Scheduler.unschedule(self._rollTipsTimer)
			self._rollTipsTimer = false
		end
	end
	
	if #self._rollMsgList > 0 then
		local args = self._rollMsgList[1]
		table.remove(self._rollMsgList, 1)
		self:addMsgItem(args)
	end	
end

function RollTipsListView:recycleItem()
	if #self._allItem == 0 then return end
	local item = self._allItem[#self._allItem]
	table.insert(self._objPool,item)
	item:retain()
	self.view:removeChild(item)
	self._allShowMsg[#self._allShowMsg] = nil
	self._allItem[#self._allItem] = nil
end

function RollTipsListView:_hidetips()
	if #self._allShowMsg > 0 then
		local msg = self._allShowMsg[#self._allShowMsg]
		while (cc.millisecondNow() - msg.showTime) >= self._showTime do
			self:recycleItem()
			if #self._allShowMsg > 0 then
				msg = self._allShowMsg[#self._allShowMsg]
			else
				break
			end
		end
	else
		for _,v in pairs(self._objPool) do
			v:release()
		end
		self:closeView()
		Scheduler.unschedule(self._hideMsgTimer)
	end
end


return RollTipsListView