--Name : ItemTipsItemComposeView.lua
--Author : generated by FairyGUI
--Date : 2020-6-28
--Desc : 

local ItemTipsItemComposeView,Super = class("ItemTipsItemComposeView", View)

function ItemTipsItemComposeView:ctor()
	--LuaLog("ItemTipsItemComposeView ctor")
	self._packName = "ToolTip"
	self._compName = "ItemTipsItemComposeView"
	--self._rootDepth = LayerDepth.Window
	
end

function ItemTipsItemComposeView:_initEvent( )
	
end

function ItemTipsItemComposeView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:ToolTip.ItemTipsItemComposeView
		--{vmFieldsEnd}:ToolTip.ItemTipsItemComposeView
	--Do not modify above code-------------
end

function ItemTipsItemComposeView:_initUI( )
	self:_initVM()

end




return ItemTipsItemComposeView