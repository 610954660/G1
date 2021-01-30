--功能：公用二次确认框
local AlertViewCost,Super = class("AlertViewCost", Window)

function AlertViewCost:ctor(args)
	LuaLogE("AlertViewCost ctor")
	self._packName = "UIPublic_Window"
	self._compName = "AlertViewCost"
	self.viewName = ""
	self._rootDepth = args._rootDepth or LayerDepth.Alert
	self.yesBtn = false
	self.noBtn= false
	self.okBtn = false
	self.closeButton= false
	self.titleText= false
	self.text = false
	self.text_left = false
	self.text_hintEx = false
	self.args = args
	
	self.align = args.align and args.align or "center"
end



function AlertViewCost:_initUI()
	LuaLogE("AlertViewCost _initUI")
	--self.view:getChildAutoType("closeButton"):setVisible(false)
	local moneyBar = self.view:getChild("moneyComp")
	self.moneyBar = BindManager.bindMoneyBar(moneyBar)
	self.moneyBar:setData(self.showMoneyType)
	
	if(self.args.costType) then
		self:setMoneyType(self.args.costType)
		--[[local costBar = self.view:getChildAutoType("costBar")
		--costBar:setVisible(true)
		--self.view:getController("c1"):setSelectedIndex(1)
		local costBarClass = BindManager.bindCostBar(costBar)
		costBarClass:setData(self.args.cost, self.args.noHasNum, self.args.onlyHasNum)
		if self.args.costTxt then
            costBar:getChildAutoType("n1"):setText(self.args.costTxt)
		end--]]
	end
	--self:__Blur();
	
	--self:centerScreen()
	self.view:getChildAutoType("frame"):getChildAutoType("closeButton"):setVisible(false)
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
	self.text_hintEx = self.view:getChildAutoType("text_hintEx")
	self.text_left = self.view:getChildAutoType("text_left")
	self.text:setText(self.args.text)
	self.text_left:setText(self.args.text)
	self:setTitle(self.args.title)
	
	self.text_hintEx:setText(self.args.hintEx)
	
	
	
	self.text_left:setVisible(self.align == "left")
	self.text:setVisible(self.align ~= "left")
	
	
	self.okBtn = self.view:getChildAutoType("okBtn")

	self.okBtn:addClickListener(function()
			--Dispatcher.dispatchEvent(EventType.login_doLogin)
			self:closeView();
			if self.args.onOk then
				self.args.onOk()
			end
	end)
	if self.args.okText then
		self.okBtn:getChildAutoType("title"):setText(self.args.okText)
	end

	self.yesBtn = self.view:getChildAutoType("yesBtn")

	self.yesBtn:addClickListener(function()
			self:closeView();
			if self.args.onYes then
				self.args.onYes()
			end
	end)
	
	if self.args.yesText then
		self.yesBtn:getChildAutoType("title"):setText(self.args.yesText)
	end
	
	self.noBtn = self.view:getChildAutoType("noBtn")
	
	self.noBtn:addClickListener(function()
			self:closeView();
			if self.args.onNo then
				self.args.onNo()
			end
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
	
	if self.args.noClose == "yes" then
		self._closeBtn:setVisible(false)
	end
	local frame = self.view:getChild('frame')
	--[[if self.text:getHeight() > 162 then
		frame:setHeight(390 + self.text:getHeight() - 162)
		self.text:setPosition(frame:getPosition().x + 319, frame:getPosition().y + 182  + (self.text:getHeight() - 162)/2)
	end--]]
	
	local win = self.view:getChild('win')
	win:setPosition(win:getPosition().x, (720 - frame:getHeight())/2 )
end

function AlertViewCost:closeView()
	Super.closeView(self)
	Alert.close(self.viewName)
	if self.args.onClose then
		self.args.onClose()
	end
end

return AlertViewCost