--Name : PveStarTempleCardResultView.lua
--Author : generated by FairyGUI
--Date : 2020-7-29
--Desc : 

local PveStarTempleCardResultView,Super = class("PveStarTempleCardResultView", Window)

function PveStarTempleCardResultView:ctor()
	--LuaLog("PveStarTempleCardResultView ctor")
	self._packName = "PveStarTemple"
	self._compName = "PveStarTempleCardResultView"
	self._rootDepth = LayerDepth.PopWindow
	self.targetCard = self._args.targetCard
	self.myCard = self._args.myCard
	self.result = self._args.result
end

function PveStarTempleCardResultView:_initEvent( )
	
end

function PveStarTempleCardResultView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:PveStarTemple.PveStarTempleCardResultView
		--{vmFieldsEnd}:PveStarTemple.PveStarTempleCardResultView
	--Do not modify above code-------------
end

function PveStarTempleCardResultView:_initUI( )
	self:_initVM()
	self.myCardCtrl = self.view:getChildAutoType("my"):getController("type")
	self.targetCardCtrl = self.view:getChildAutoType("target"):getController("type")
	self.resultCtrl = self.view:getController("result")
	self:updateView()
end

function PveStarTempleCardResultView:_exit()
	self.targetCard = false
	self.myCard = false
	self.result = false
end

function PveStarTempleCardResultView:updateView()
	self.myCardCtrl:setSelectedIndex(self.myCard)
	self.targetCardCtrl:setSelectedIndex(self.targetCard)
	self.resultCtrl:setSelectedIndex(self.result)
end

return PveStarTempleCardResultView