--Date :2021-01-20
--Author : generated by FairyGUI
--Desc : 

local com_iconView,Super = class("com_iconView", View)

function com_iconView:ctor()
	--LuaLog("com_iconView ctor")
	self._packName = "PushMap"
	self._compName = "com_iconView"
	--self._rootDepth = LayerDepth.Window
	
end

function com_iconView:_initEvent( )
	
end

function com_iconView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:PushMap.com_iconView
	self.img_onhook1 = viewNode:getChildAutoType('img_onhook1')--GLoader
	self.txt_onhook1 = viewNode:getChildAutoType('txt_onhook1')--GTextField
	self.txt_onhook2 = viewNode:getChildAutoType('txt_onhook2')--GTextField
	--{autoFieldsEnd}:PushMap.com_iconView
	--Do not modify above code-------------
end

function com_iconView:_initListener( )
	
end

function com_iconView:_initUI( )
	self:_initVM()
	self:_initListener()

end




return com_iconView