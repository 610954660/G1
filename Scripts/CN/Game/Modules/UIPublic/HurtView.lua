--Name : HurtView.lua
--Author : generated by FairyGUI
--Date : 2020-3-5
--Desc : 

local HurtView,Super = class("HurtView", View)

function HurtView:ctor()
	--LuaLog("HurtView ctor")
	self._packName = "UIPublic"
	self._compName = "HurtView"
	--self._rootDepth = LayerDepth.Window
	
end

function HurtView:_initEvent( )
	
end

function HurtView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:UIPublic.HurtView
		--{vmFieldsEnd}:UIPublic.HurtView
	--Do not modify above code-------------
end

function HurtView:_initUI( )
	self:_initVM()

end




return HurtView