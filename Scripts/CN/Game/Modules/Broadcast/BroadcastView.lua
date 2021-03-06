--Name : BroadcastView.lua
--Author : generated by FairyGUI
--Date : 2020-6-11
--Desc : 
local ChatTextCell = require "Game.UI.Global.ChatTextCell"
local BroadcastView,Super = class("BroadcastView", View)

function BroadcastView:ctor()
	--LuaLog("BroadcastView ctor")
	self._packName = "Broadcast"
	self._compName = "BroadcastView"
	self._rootDepth = LayerDepth.Message

	--walk
	self.walkSpeed = 150
	self._walkCd = false
	self._walkMsgs = {}
	
end

function BroadcastView:_initEvent( )
	
end

--走马灯显示消息
function BroadcastView:BoradWalk_AddMsg(_,msg )
	self:addWalkLabel(msg,msg)
end

function BroadcastView:update_chat_runMonkeyMsg(_,data)
	print(1,"update_chat_runMonkeyMsg")
	self:addWalkLabel(data.content,data)
end

function BroadcastView:addWalkLabel(msg,data)
	local function showNextWalkMsg()
		if tolua.isnull(self.view) then return end
		local msg = table.remove(self._walkMsgs, 1)
		if msg == nil then
			self.showCtrl:setSelectedIndex(0)
			self._walkCd = false
			return
		end

		self.showCtrl:setSelectedIndex(1)

		-- msg = StringUtil.expendEnter(msg)
		-- msg = StringUtil.expendtabs(msg, 1)
			-- self.walkLabel:setText(msg)
		local parseStr =ModelManager.ChatModel:parse(msg)
		local textCell = BindManager.bindChatTextCell(self.walkLabel)
		parseStr = StringUtil.expendEnter(parseStr)
		parseStr = StringUtil.expendtabs(parseStr, 1) 
		textCell:setText(parseStr,data)
		
	
		self.walkLabel:setX(self.walkBg:getWidth())

		local walkWidth = self.walkLabel:getWidth()
		local walkbgWidth = self.walkBg:getWidth()
		local arg = {}
		arg.from = Vector2(self.walkLabel:getPosition().x,self.walkLabel:getPosition().y)
		arg.to = Vector2(-walkWidth,self.walkLabel:getPosition().y)
		arg.time = (walkWidth+ walkbgWidth) / self.walkSpeed
		arg.ease = EaseType.Linear
		arg.tweenType = "Broadcast"
		arg.onComplete = function( ... )
			showNextWalkMsg()
		end
		
		TweenUtil.moveTo(self.walkLabel,arg)
	end

	table.insert(self._walkMsgs, msg)
	if self._walkCd == false then
		self._walkCd = true
		showNextWalkMsg()
	end
end

function BroadcastView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Broadcast.BroadcastView
		vmRoot.walkView = viewNode:getChildAutoType("$walkView")--
		vmRoot.specView = viewNode:getChildAutoType("$specView")--
	--{vmFieldsEnd}:Broadcast.BroadcastView
	--Do not modify above code-------------
end

function BroadcastView:_initUI( )
	self:_initVM()
    self.specView:setVisible(false) --暂时没用到  先屏蔽
    self.showCtrl = self.view:getController("showCtrl")
    self.showCtrl:setSelectedIndex(0)
    self.walkLabel = self.walkView:getChildAutoType("msgLabel")
    self.walkBg = self.walkView:getChildAutoType("bg")
end


function BroadcastView:_exit( ... )
	print(1,"BroadcastView exit")
	self._walkMsgs = {}
end




return BroadcastView