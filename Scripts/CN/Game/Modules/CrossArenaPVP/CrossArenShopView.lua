--Date :2020-12-26
--Name : CrossArenShopView.lua
--Author : generated by FairyGUI
--Desc : 

local CrossArenShopView,Super = class("CrossArenShopView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
function CrossArenShopView:ctor() 
	
	--LuaLog("CrossArenShopView ctor")
	self._packName = "CrossArenaPVP"
	self._compName = "CrossArenShopView"
	self._rootDepth = LayerDepth.PopWindow
	
	self.cancel=false
	self.buy=false
	self.itemCell=false
	self.tickeLeftTime=false
	self.ArenaInfo=false
	self.buyNum=1
	self.canBuyNum=0

	
end

function CrossArenShopView:_initEvent()
	
end

function CrossArenShopView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Arena.CrossArenShopView
		vmRoot.closeButton = viewNode:getChildAutoType("$closeButton")--Label
	--{vmFieldsEnd}:Arena.CrossArenShopView
	--Do not modify above code-------------
end

function CrossArenShopView:_initUI( )
	self:_initVM()
	self.itemCell=self.view:getChildAutoType("itemCell")
	self.cancel=self.view:getChildAutoType("cancel")
	self.buy=self.view:getChildAutoType("buy")
	self.tickeLeftTime=self.view:getChildAutoType("tickeLeftTime")
	self.buy = BindManager.bindCostButton(self.buy)
	
    self:initData()
end

--初始化数据
function  CrossArenShopView:initData()

	local item=DynamicConfigData.t_CrossArenaConfig[1].ticketCode
	local itemData = ItemsUtil.createItemData({data = {type=3,code=item,amount=1,}})
	local itemcell = BindManager.bindItemCell(self.itemCell)
	itemcell:setItemData(itemData)
	
	self.canBuyNum=DynamicConfigData.t_CrossArenaConfig[1].ticketLimit
	self.ArenaInfo = CrossArenaPVPModel:getSeverData()
	self.buyNum=self.ArenaInfo.buyTimes
	self.tickeLeftTime:setText(Desc.CrossArenaPVPDesc6:format(self.buyNum,self.canBuyNum))
	
	if self.canBuyNum==0 then
		self.buyNum=0
	end

	self:checkButtonState()
	self.buy:addClickListener(function ()
			if self.buyNum>self.canBuyNum or self.canBuyNum==0 then
				RollTips.show(Desc.Arena_DetailsStr2)
				
			else
				RPCReq.CrossArena_Buy({num = 1},function(data)
					self:buySuccess(self.buyNum)
				end)

			end
	end)
	self.cancel:addClickListener(function ()
			ViewManager.close("CrossArenShopView")
	end)
	self.closeButton:addClickListener(function ()
			ViewManager.close("CrossArenShopView")
	end)
end


--购买成功
function  CrossArenShopView:buySuccess()
	RollTips.show(Desc.Arena_DetailsStr3)
	CrossArenaPVPModel.severData.buyTimes = CrossArenaPVPModel.severData.buyTimes + 1
	Dispatcher.dispatchEvent(EventType.crossArena_updateTickInfo)
	ViewManager.close("CrossArenShopView")	
end

function  CrossArenShopView:checkButtonState()

	local cfg_arena= DynamicConfigData.t_CrossArenaConfig[1]
	local costDiamond=cfg_arena.costDiamond
	self.buy:setData({type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond, amount = costDiamond})


end



return CrossArenShopView