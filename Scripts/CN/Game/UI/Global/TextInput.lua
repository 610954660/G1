--added by wyang
--输入文本框（主要是实现了有内容时隐藏提示文字，不使用fgui自带那个，那个不能设提示文字的字体）
local TextInput,Super = class("TextInput",BindView)
function TextInput:ctor(view)
	self.txt_input = false
	self.txt_hint = false
	self.onChangeCallBack = false
	self.onBeginCallBack = false
	self.onEndCallBack = false
end

function TextInput:init( ... )
	self.txt_input = self.view:getChildAutoType("txt_input")
	self.txt_hint = self.view:getChildAutoType("title")
	self.txt_show = self.view:getChildAutoType("txt_show")
	self.txt_showCenter = self.view:getChildAutoType("txt_showCenter") or false
	self.txt_input:onChanged(function (content)
        --self.txt_input:setText(StringUtil.limitStringLen(content, 12))
		self.txt_hint:setVisible(#content == 0)
		self.txt_show:setText(content)
		if self.txt_showCenter then self.txt_showCenter:setText(content) end
		if self.onChangeCallBack then
			self.onChangeCallBack(content)
		end
    end);
	if not self.txt_input.setInputEventLister then  -- 兼容老包的处理
		self.txt_input:setVisible(true)
		self.txt_hint:setVisible(false)
		self.txt_show:setVisible(false)
		if self.txt_showCenter then self.txt_showCenter:setVisible(false) end
		self.txt_show = self.txt_input
	end
	if self.txt_input.setInputEventLister then
		 self.txt_input:setInputEventLister(
			function(eventName)
				if eventName == "begin" then
					self.txt_hint:setVisible(false)
					self.txt_show:setVisible(false)
					if self.txt_showCenter then self.txt_showCenter:setVisible(false) end
					self.txt_input:setText(self.txt_show:getText())
					if self.onBeginCallBack then
						self.onBeginCallBack()
					end
				elseif eventName == "end" then
					local content = self.txt_input:getText() 
					self.txt_hint:setVisible(#content == 0)
					self.txt_show:setVisible(true)
					if self.txt_showCenter then self.txt_showCenter:setVisible(true) end
					self.txt_show:setText(content)
					if self.txt_showCenter then self.txt_showCenter:setText(content) end
					self.txt_input:setText("")
					if self.onEndCallBack then
						self.onEndCallBack()
					end
				end
			end
		)
	end
		
	self.txt_input:setFontSize(self.txt_hint:getFontSize())
	self.txt_show:setFontSize(self.txt_hint:getFontSize())
	if self.txt_showCenter then self.txt_showCenter:setFontSize(self.txt_hint:getFontSize()) end
	self.txt_input:setColor(self.txt_hint:getColor())
	self.txt_show:setColor(self.txt_hint:getColor())
	if self.txt_showCenter then self.txt_showCenter:setColor(self.txt_hint:getColor()) end
end

function TextInput:onChanged(func)
	self.onChangeCallBack = func
end

function TextInput:unRigisterEdibox()
	self.txt_input:setKeyboardType(1)
end

function TextInput:onInputBegin(func)
	self.onBeginCallBack = func
end

function TextInput:onInputEnd(func)
	self.onEndCallBack = func
end


function TextInput:setColor(color)
	self.txt_input:setColor(color)
	self.txt_show:setColor(color)
	if self.txt_showCenter then self.txt_showCenter:setColor(color) end
end


function TextInput:setText(v)
	v = tostring(v)
	self.txt_input:setText(v) 
	self.txt_show:setText(v)
	if self.txt_showCenter then self.txt_showCenter:setText(v) end
	self.txt_hint:setVisible(#v == 0)
end


function TextInput:setMaxLength(len)
	self.txt_input:setMaxLength(len);
end

function TextInput:getText()
	return self.txt_show:getText()
end

function TextInput:setVisible(v)
	self.view:setVisible(v)
end
function TextInput:setPosition(x,y)
	self.view:setPosition(x,y)
end
function TextInput:getWidth(x,y)
	return self.view:getWidth()
end
function TextInput:getHeight()
	return self.view:getHeight()
end
function TextInput:setAlpha(a)
	return self.view:setAlpha(a)
end
--[[function TextInput:setColor(a)
	return self.view:setColor(a)
end--]]

--退出操作 在close执行之前 
function TextInput:__onExit()
    -- print(1,"TextInput __onExit")
--   self:_exit() --执行子类重写
   --[[self:clearEventListeners()
   for k,v in pairs(self.baseCtlView) do
   		v:__onExit()
   end--]]
end

return TextInput