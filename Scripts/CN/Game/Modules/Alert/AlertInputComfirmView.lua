--功能：输入数字确认框
local AlertInputComfirmView,Super = class("AlertInputComfirmView", Window)

function AlertInputComfirmView:ctor(args)
	LuaLogE("AlertInputComfirmView ctor")
	self._packName = "UIPublic_Window"
	self._compName = "AlertInputComfirmView"
	self.viewName = ""
	self._rootDepth = args._rootDepth or LayerDepth.Alert
	self.yesBtn = false
	self.noBtn= false
	self.okBtn = false
	self.closeButton= false
	self.titleText= false
	self.text = false
	self.text_left = false
	self.txt_input = false
	self.args = args
	self.comfirmNum = ""
	
	self.align = args.align and args.align or "center"
end



function AlertInputComfirmView:_initUI()
	LuaLogE("AlertInputComfirmView _initUI")
	
	self.txt_input = self.view:getChildAutoType("txt_input")
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
	self.text:setText(string.format(self.args.text, self:getRandomNum()))
	self:setTitle(self.args.title)
	
	self.okBtn = self.view:getChildAutoType("okBtn")

	self.okBtn:addClickListener(function()
		if self.txt_input:getText() ~= self.comfirmNum then
			RollTips.show(Desc.alert_inputError)
			return
		end
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
		if self.txt_input:getText() ~= self.comfirmNum then
			RollTips.show(Desc.alert_inputError)
			return
		end
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
	
	local win = self.view:getChild('win')
	win:setPosition(win:getPosition().x, (720 - frame:getHeight())/2 )
end

--生成随机数字
function AlertInputComfirmView:getRandomNum()
	self.comfirmNum = ""
	for i = 1,4,1 do
		self.comfirmNum = self.comfirmNum..(math.floor(math.random() * 10))
	end
	return self.comfirmNum
end

function AlertInputComfirmView:closeView()
	Super.closeView(self)
	Alert.close(self.viewName)
	if self.args.onClose then
		self.args.onClose()
	end
end

return AlertInputComfirmView