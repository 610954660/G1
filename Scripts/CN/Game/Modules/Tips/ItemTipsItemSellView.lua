--道具tips
--added by wyang
local ItemTipsItemSellView = class("ItemTipsItemSellView",Window)
--local ItemCell = require "Game.UI.Global.ItemCell"
function ItemTipsItemSellView:ctor(args)
	self._packName = "ToolTip"
    self._compName = "ItemTipsItemSellView"
	self._rootDepth = LayerDepth.PopWindow

	self._data = args
	
	self.useNum = 1
end

function ItemTipsItemSellView:init( ... )
	-- body
end

-- [子类重写] 初始化UI方法
function ItemTipsItemSellView:_initUI( ... )
	local itemInfo = self._data:getItemInfo()
	local viewRoot = self.view;
	local itemCell = viewRoot:getChildAutoType("itemCell")
    local btn_sub = viewRoot:getChildAutoType("btn_sub") 
    local btn_add = viewRoot:getChildAutoType("btn_add") 
    local txt_num = viewRoot:getChildAutoType("txt_num") 
    local txt_goldNum = viewRoot:getChildAutoType("txt_goldNum") 
    local btn_use = viewRoot:getChildAutoType("btn_use") 
    local btn_max = viewRoot:getChildAutoType("btn_max") 
	self.useNum = self._data:getItemAmount()
	txt_num:setText(self.useNum)
	txt_goldNum:setText(itemInfo.sellPrice * self.useNum)
	if self._data:getBagType()== GameDef.BagType.Rune then
		local code = self._data:getItemCode()
		local amount = DynamicConfigData.t_Rune[code].salePrice[1].amount
		txt_goldNum:setText(amount * self.useNum)
	end
	local itemcellobj = BindManager.bindItemCell(itemCell)
    itemcellobj:setItemData(self._data)
	
	
	btn_add:addClickListener(function()
		if self.useNum >= self._data:getItemAmount() then return end
		if self._data:getBagType()== GameDef.BagType.Rune then
			return
		end
		self.useNum = self.useNum + 1
		txt_num:setText(self.useNum)
		txt_goldNum:setText(itemInfo.sellPrice * self.useNum )
	end)
	
	btn_sub:addClickListener(function()
		if self.useNum <= 1 then return end
		if self._data:getBagType()== GameDef.BagType.Rune then
			return
		end
		self.useNum = self.useNum - 1
		txt_num:setText(self.useNum)
		txt_goldNum:setText(itemInfo.sellPrice * self.useNum )
	end)

	btn_max:addClickListener(function()
		if self._data:getBagType()== GameDef.BagType.Rune then
			return
		end
		self.useNum = self._data:getItemAmount()
		txt_num:setText(self.useNum)
		txt_goldNum:setText(itemInfo.sellPrice * self.useNum )
	end)

	btn_use:addClickListener(function()
		local code = self._data:getItemCode()
		if code == 50000001 or code == 50000004 or code == 50000007 then
			local params = {}
			params.itemUuid = self._data:getUuid()
			params.onSuccess = function( res )
				self:closeView()
				ViewManager.close("ItemTipsBagView")
			end
			RPCReq.Rune_Sale(params, params.onSuccess)
			return 
		end 

		local params = {}
		params.bagType = self._data:getBagType()
		params.itemId = self._data:getItemId()
		params.amount = self.useNum
		params.onSuccess = function( res )
			print(1,res)
			self:closeView()
			if self._data:getItemAmount() == self.useNum then
				ViewManager.close("ItemTipsBagView")
			end
		 end
		RPCReq.Bag_SellItem(params, params.onSuccess)
	end)
end

-- [子类重写] 准备事件
function ItemTipsItemSellView:_initEvent( ... )
    
end 

-- [子类重写] 添加后执行
function ItemTipsItemSellView:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsItemSellView:_exit()
end


return ItemTipsItemSellView