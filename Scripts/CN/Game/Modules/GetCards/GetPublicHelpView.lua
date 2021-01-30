--获取途径
--added by xhd
local GetPublicHelpView,Super = class("GetPublicHelpView",Window)
function GetPublicHelpView:ctor( arg )
    self._packName = "UIPublic_Window"
	self._compName = "GetHelpView"
	self._rootDepth = LayerDepth.AlertWindow
	self.frame = false
	self.txtDesc = false
	self._minHeight = 200;
	self._maxHeight = 400;
end

function GetPublicHelpView:_initUI()
	local viewRoot = self.view
	self.frame=viewRoot:getChild("frame")
	self.txtDesc=viewRoot:getChild("txt_content"):getChild("txt_content")
	printTable(5,">>>>>>>>>>>>>>>",self._args)
	local closeBtn=viewRoot:getChild('closeButton')
	closeBtn:addClickListener(function (context)
		ViewManager.close('GetPublicHelpView');
	end)
	self:showViewInfo()
end

function GetPublicHelpView:showViewInfo( )
	if self._args.title==nil or self._args.desc==nil then
		return;
	end
	local txtTitle=self._args.title;
	local desc=self._args.desc;
	if not txtTitle then txtTitle = Desc.help_defaultTitle end
	self.frame:setTitle(txtTitle);


	self.txtDesc:setText(desc);
	local textHeight = self.txtDesc:getTextSize().height
	textHeight = textHeight > self._minHeight and textHeight or self._minHeight
	textHeight = textHeight < self._maxHeight and textHeight or self._maxHeight
	self.view:getChild("txt_content"):setHeight(textHeight)


	local frame = self.view:getChild('frame')
	local win = self.view:getChild('win')
	win:setPosition(win:getPosition().x, (720 - frame:getHeight())/2 )
end

function GetPublicHelpView:_initEvent( ... )
   
end

--initUI执行之前
function GetPublicHelpView:_enter( ... )

end

--页面退出时执行
function GetPublicHelpView:_exit( ... )
	print(1,"GetPublicHelpView _exit")
end

return GetPublicHelpView