--Name : RuneBagView.lua
--Author : generated by FairyGUI
--Date : 2020-5-21
--Desc : 

local RuneBagView,Super = class("RuneBagView", View)
local ItemCell = require "Game.UI.Global.ItemCell"
local PackConfiger = require "Game.ConfigReaders.PackConfiger"
function RuneBagView:ctor()
	--LuaLog("RuneBagView ctor")
	self._packName = "RuneSystem"
	self._compName = "RuneBagView"
	self.listData = false
	self.itemcellArr = {}
	--self._rootDepth = LayerDepth.Window
	
end

function RuneBagView:_refresh( ... )
	-- do return end
	Dispatcher.dispatchEvent(EventType.rune_changeSmallPage,{status=0})
	self.list:setSelectedIndex(0)
	if self.itemcellArr[1]  then
		self.itemcellArr[1]:onClickCell()
	end
end

function RuneBagView:_initEvent( )
	Dispatcher.dispatchEvent(EventType.rune_changeSmallPage,{status=0})
	self:pack_rune_change()
end

function RuneBagView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:RuneSystem.RuneBagView
		vmRoot.list = viewNode:getChildAutoType("$list")--list
		vmRoot.numVal = viewNode:getChildAutoType("$numVal")--list
	--{vmFieldsEnd}:RuneSystem.RuneBagView
	--Do not modify above code-------------
end

function RuneBagView:_initUI( )
	-- do return end
	self:_initVM()
	self.list:setVirtual()
	self.list:setItemRenderer(function (index,obj)
		local itemcell = BindManager.bindItemCell(obj)
		self.itemcellArr[index+1] = itemcell
		itemcell:setIsBig(true)
		itemcell:setAmountVisible(false)
		itemcell:setItemData(self.listData[index+1],CodeType.ITEM, "rune")
	end
	)
	self.list:setVirtual()
	self.listData = ModelManager.PackModel:getRuneBag():sort_bagDatas()
	self.list:setData(self.listData)
	self.numVal:setText(string.format("[color=#ffd440]%d[/color][color=#ffffff]%s[/color]",#self.listData,"/"..PackConfiger.getPackInfoByType(GameDef.BagType.Rune).maxCapacity))
	self.list:setSelectedIndex(0)
	if self.itemcellArr[1]  then
		self.itemcellArr[1]:onClickCell()
	end
end

--监听符文背包道具变化
function RuneBagView:pack_rune_change( ... )
    self.listData = ModelManager.PackModel:getRuneBag():sort_bagDatas()
	self.list:setData(self.listData)
	self.numVal:setText(string.format("[color=#ffd440]%d[/color][color=#ffffff]%s[/color]",#self.listData,"/"..PackConfiger.getPackInfoByType(GameDef.BagType.Rune).maxCapacity))
	-- self.numVal:setText(#self.listData.."/"..PackConfiger.getPackInfoByType(BagType.Rune).maxCapacity)
end



return RuneBagView