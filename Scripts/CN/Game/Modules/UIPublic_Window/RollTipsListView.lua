--Name : RollTipsListView.lua
--Author : generated by FairyGUI
--Date : 2020-7-10
--Desc : 

local RollTipsListView,Super = class("RollTipsListView", View)

function RollTipsListView:ctor()
	--LuaLog("RollTipsListView ctor")
	self._packName = "UIPublic_Window"
	self._compName = "RollTipsListView"
	--self._rootDepth = LayerDepth.Window
	
end

function RollTipsListView:_initEvent( )
	
end

function RollTipsListView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:UIPublic_Window.RollTipsListView
		--{vmFieldsEnd}:UIPublic_Window.RollTipsListView
	--Do not modify above code-------------
end

function RollTipsListView:_initUI( )
	self:_initVM()

end




return RollTipsListView