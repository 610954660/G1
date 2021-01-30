--Date :2020-12-29
--Author : 李接健
--Desc : 

local SealDevilView,Super = class("SealDevilView", Window)
local SealDevilMapRect = require "Game.Modules.SealDevil.SealDevilMapRect"
local SealDevilPlayer = require "Game.Modules.SealDevil.SealDevilPlayer"


function SealDevilView:ctor()
	--LuaLog("SealDevilView ctor")
	self._packName = "SealDevil"
	self._compName = "SealDevilView"
	--self._rootDepth = LayerDepth.Window
	self._mapRect=false
	self._player=false
end

function SealDevilView:_initEvent( )
	
end

function SealDevilView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:SealDevil.SealDevilView
	self.helpBtn = viewNode:getChildAutoType('$helpBtn')--GButton
	self.buffShow = viewNode:getChildAutoType('buffShow')--GButton
	self.checkComp = viewNode:getChildAutoType('checkComp')--GComponent
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.recordBoard = viewNode:getChildAutoType('recordBoard')--GLabel
	self.resetBtn = viewNode:getChildAutoType('resetBtn')--GButton
	self.sTypeCtrl = viewNode:getController('sTypeCtrl')--Controller
	self.successCtrl = viewNode:getController('successCtrl')--Controller
	--{autoFieldsEnd}:SealDevil.SealDevilView
	--Do not modify above code-------------
end

function SealDevilView:_initListener( )
	
	--self.btn1:addClickListener(function()

	--end)

	--self.btn2:addClickListener(function()

	--end)

	--self.btn3:addClickListener(function()

	--end)

	self.buffShow:addClickListener(function()
           ViewManager.open("DevilResView")
	end)
	self.resetBtn:addClickListener(function()
			local info = {}
			info.text = Desc.DevilRoad_str3
			info.mask = true
			info.type = "yes_no"
			info.onYes = function()
				SealDevilModel:devilRoad_Reset()
			end
			info.onNo = function()
				
			end
			Alert.show(info)
	end)

	self.helpBtn:addClickListener(function()
		RollTips.showHelp(Desc.help_StrTitle249, Desc.help_StrDesc249);
	end)

end

function SealDevilView:_initUI( )
	self:_initVM()
	self:_initListener()
	self:setBg("devilRoad.jpg")
	
	
	
	local gate=self._args.gate or 1
	--选择关卡信息
	SealDevilModel:chooseGate(gate,function ()   
			self._mapRect = SealDevilMapRect.new(self.checkComp)
			self._mapRect:initMap()
			self._player=SealDevilPlayer.new(self.checkComp,self._mapRect:getMapItem())
	end)
	self:moveTitleToTop()
	
end

function SealDevilView:DevilRoad_MoveGrid(_,point)	
   self._player:setMove(point)
	
end

function SealDevilView:DevilRoad_Reset(_,param)
	self._mapRect:resetMap(true)
	local gridInfo= SealDevilModel:getPlayerGrid()
	self._player:setMove(gridInfo.point[1])
end


function SealDevilView:DevilRoad_updateGrid(_,param)
	self._mapRect:updateGrid(param)
end


function SealDevilView:_exit()
	Scheduler.scheduleNextFrame(function()
			Dispatcher.dispatchEvent(EventType.module_open_hint)
	end)
end


return SealDevilView