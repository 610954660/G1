--Name : ItemTipsView.lua
--Author : generated by FairyGUI
--Date : 2020-6-28
--Desc : 

local ItemTipsView,Super = class("ItemTipsView", View)

function ItemTipsView:ctor()
	--LuaLog("ItemTipsView ctor")
	self._packName = "ToolTip"
	self._compName = "ItemTipsView"
	--self._rootDepth = LayerDepth.Window
	
end

function ItemTipsView:_initEvent( )
	
end

function ItemTipsView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:ToolTip.ItemTipsView
		--{vmFieldsEnd}:ToolTip.ItemTipsView
	--Do not modify above code-------------
end

function ItemTipsView:_initUI( )
	self:_initVM()

end




return ItemTipsView