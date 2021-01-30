--Name : QuickUseView.lua
--Author : generated by FairyGUI
--Date : 2020-5-9
--Desc : 

local QuickUseView,Super = class("QuickUseView", View)

function QuickUseView:ctor(args)
	--LuaLog("QuickUseView ctor")
	self._packName = "MainUI"
	self._compName = "QuickUseView"
	--self._rootDepth = LayerDepth.Window
	
	self.itemCell = false
	self.heroItem = false
	self.txt_name = false
	self.btn_use = false
	self.closeButton = false
	
	self._data = args.data
	self._itemCode = self._data:getItemCode()
end

function QuickUseView:_initUI( )
	local itemCell = self.view:getChildAutoType("itemCell")
	self.heroItem = self.view:getChildAutoType("heroItem")
	self.txt_name = self.view:getChildAutoType("txt_name")
	self.btn_use = self.view:getChildAutoType("btn_use")
	self.closeButton = self.view:getChildAutoType("closeButton")
	
	self.itemCell = BindManager.bindItemCell(itemCell)
	self.itemCell:setItemData(self._data, CodeType.ITEM, "quickUse")
	self.txt_name:setText(self._data:getName())
	
	self.closeButton:addClickListener(function()
		self:closeView()
	end)	

	self.btn_use:addClickListener(function()
		local params = {}
		params.bagType = self._data:getBagType()
		params.itemId = self._data:getItemId()
		params.amount = 1
		params.onSuccess = function( res )
			print(1,res)
			RollTips.show(DescAuto[194]) -- [194]="使用成功"
		end
		RPCReq.Bag_UseItem(params, params.onSuccess)
		self:closeView()
	end)
end

function QuickUseView:closeView()
	if self.view:getParent() then
		self.view:getParent():removeChild(self.view)
	end
	Dispatcher.dispatchEvent(EventType.mainui_closeQuickUse, self._data:getItemCode())
end

function QuickUseView:updateAmount(amount)
	self.itemCell:setAmount(amount)
end



return QuickUseView
