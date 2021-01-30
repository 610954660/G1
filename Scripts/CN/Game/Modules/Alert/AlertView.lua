--功能：公用二次确认框
local AlertView,Super = class("AlertView", Window)

function AlertView:ctor(args)
	LuaLogE("AlertView ctor")
	self._packName = "UIPublic_Window"
	self._compName = "AlertView"
	self.viewName = ""
	self._rootDepth = args._rootDepth or LayerDepth.Alert
	self.yesBtn = false
	self.noBtn= false
	self.okBtn = false
	self.titleText= false
	self.text = false
	self.text_left = false
	self.args = args
	
	self.align = args.align and args.align or "center"
end



function AlertView:_initUI()
	LuaLogE("AlertView _initUI")
	--self.view:getChildAutoType("closeButton"):setVisible(false)
	--self:__Blur();
	
	--[[if(self.args.cost) then
		local costBar = self.view:getChildAutoType("costBar")
		local costBarClass = BindManager.bindCostBar(costBar)
		costBarClass:setData(self.args.cost, self.args.noHasNum, self.args.onlyHasNum)
	end--]]
	
	self.checkBox = self.view:getChildAutoType("checkBox")
	--self:centerScreen()
	local c3Ctrl = self.view:getChildAutoType("frame"):getController("c3")
	-- local closeButton = self.view:getChildAutoType("frame"):getChildAutoType("closeButton")
	if c3Ctrl then c3Ctrl:setSelectedIndex(1) end
	if self.args.noClose ~= "no" then
		c3Ctrl:setSelectedIndex(1)
	else
		c3Ctrl:setSelectedIndex(0)
	end

	if self.args.mask == "yes" then
		
		local layer = cc.LayerColor:create(cc.c4b(0,0,0,120),display.width,display.height);
		layer:setAnchorPoint(0.5,0.5)
		local pos = self.view:localToGlobal(Vector2.zero)
		layer:setPosition(-pos.x+self.view:getWidth()/2,-pos.y+self.view:getHeight()/2)
		self.view:displayObject():addChild(layer,-1)
		
	end
	
	if self.args.swallow == "yes" then
		local aLoader = fgui.GLoader:create();
		aLoader:setSize(display.width,display.height);
		local pos = self.view:localToGlobal(Vector2.zero)
		aLoader:setPosition(-pos.x+self.view:getWidth()/2,-pos.y+self.view:getHeight()/2)
		self.view:addChildAt(aLoader,0)
	end
	

	self.text = self.view:getChildAutoType("label")
	self.text_left = self.view:getChildAutoType("text_left")
	self.text:setText(self.args.text)
	self.text_left:setText(self.args.text)
	self:setTitle(self.args.title)
	
	self.text_left:setVisible(self.align == "left")
	self.text:setVisible(self.align ~= "left")

	self.checkBox:setVisible(self.args.check)

	if self.args.checkTxt then
		self.checkBox:setTitle(self.args.checkTxt or Desc.alert_notips)
	end
	
	self.okBtn = self.view:getChildAutoType("okBtn")

	self.okBtn:addClickListener(function()
			--Dispatcher.dispatchEvent(EventType.login_doLogin)
			if self.args.onOk then
				self.args.onOk(self.checkBox:isSelected())
			end
			self:closeView();
	end)
	if self.args.okText then
		self.okBtn:getChildAutoType("title"):setText(self.args.okText)
	end

	self.yesBtn = self.view:getChildAutoType("yesBtn")
	self.yesBtn:addClickListener(function()
			if self.args.onYes then
				self.args.onYes(self.checkBox:isSelected())
			end
			self:closeView();
	end)
	
	if self.args.yesText then
		self.yesBtn:getChildAutoType("title"):setText(self.args.yesText)
	end
	
	self.noBtn = self.view:getChildAutoType("noBtn")
	
	self.noBtn:addClickListener(function()
			if self.args.onNo then
				self.args.onNo(self.checkBox:isSelected())
			end
			self:closeView();
	end)
	
	if self.args.noText then
		self.noBtn:getChildAutoType("title"):setText(self.args.noText)
	end
	
	if self.args.type == "yes_no" then
		self.yesBtn:setVisible(true)
		self.noBtn:setVisible(true)
	elseif self.args.type == "ok" then
		self.okBtn:setVisible(true)
	end
	
	local frame = self.view:getChild('frame')
	if self.text:getHeight() > 162 then
		frame:setHeight(280 + self.text:getHeight() - 98)
		self.text:setPosition(frame:getPosition().x + 319, frame:getPosition().y + 182  + (self.text:getHeight() - 162)/2)
	end
	
	local win = self.view:getChild('win')
	win:setPosition(win:getPosition().x, (720 - frame:getHeight())/2 )
end

function AlertView:closeView()
	Alert.close(self.args.viewName)
	if self.args.onClose then
		self.args.onClose()
	end
end

function AlertView:battle_end(_,args)
	printTable(5656,"BattleBuffView:battle_end",args)
	self:closeView();
end



return AlertView