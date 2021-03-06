--Name : PushMapHuiguView.lua
--Author : generated by FairyGUI
--Date : 2020-4-20
--Desc : 

local PushMapHuiguView,Super = class("PushMapHuiguView", Window)

function PushMapHuiguView:ctor()
	--LuaLog("PushMapHuiguView ctor")
	self._packName = "Film"
	self._compName = "PushMapHuiguView"
	self._rootDepth = self._args._rootDepth or LayerDepth.PopWindow
	
end

function PushMapHuiguView:_initEvent( )
	
end

function PushMapHuiguView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Film.PushMapHuiguView
		vmRoot.list = viewNode:getChildAutoType("$list")--list
	--{vmFieldsEnd}:Film.PushMapHuiguView
	--Do not modify above code-------------
end

function PushMapHuiguView:_initUI( )
	self:_initVM()
	
	local data = self._args.data
	self.list:setItemRenderer(function(index,obj)
			local d_info = string.split(data[index+1].name,",")
			obj:getChildAutoType("name"):setText(d_info[1])
			local t_info = string.split(data[index+1].text,",")
			obj:getChildAutoType("title"):setText(t_info[1])
		end)
	self.list:setNumItems(self._args.index )
	self.list:scrollToView(self._args.index - 1)
end




return PushMapHuiguView