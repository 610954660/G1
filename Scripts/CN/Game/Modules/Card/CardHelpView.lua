--获取途径
--added by xhd
local CardHelpView,Super = class("CardHelpView",Window)
function CardHelpView:ctor( arg )
    self._packName = "CardSystem"
	self._compName = "cardHelpTipsView"
	self.title = false
	self.txtDesc = false
end

function CardHelpView:_initUI()
	local viewRoot = self.view
	self.txtDesc=viewRoot:getChild("n12")
	printTable(5,">>>>>>>>>>>>>>>",self._args)
	self:showViewInfo()
	local closeBtn=viewRoot:getChild('closeButton1')
	closeBtn:addClickListener(function (context)
		ViewManager.close('CardHelpView');
	end)
end

function CardHelpView:showViewInfo( )
	if  self._args.desc==nil then
		return;
	end
	local desc=self._args.desc;
	self.txtDesc:setText(desc);
end

function CardHelpView:_initEvent( ... )
   
end

--initUI执行之前
function CardHelpView:_enter( ... )

end

--页面退出时执行
function CardHelpView:_exit( ... )
	print(1,"CardHelpView _exit")
end

return CardHelpView