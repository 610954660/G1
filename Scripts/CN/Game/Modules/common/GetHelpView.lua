--Name : GetHelpView.lua
--Author : generated by FairyGUI
--Date : 2020-3-7
--Desc : 

local GetHelpView,Super = class("GetHelpView", View)

function GetHelpView:ctor()
	--LuaLog("GetHelpView ctor")
	self._packName = "UIPublic_Window"
	self._compName = "GetHelpView"
	self._rootDepth = LayerDepth.Window
	
end

function GetHelpView:_initEvent( )
	
end

function GetHelpView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:common.GetHelpView
		--{vmFieldsEnd}:common.GetHelpView
	--Do not modify above code-------------
end

function GetHelpView:_initUI( )
	self:_initVM()

end




return GetHelpView