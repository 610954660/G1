--added by wyang

local MainQuickUseGroup,Super = class("MainQuickUseGroup",BindView)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
function MainQuickUseGroup:ctor(view)
	self.txt_num = false
	self.iconLoader = false
	
	self._needNum = 0
	self._itemCodeType = false
	self._itemCode = false
	self._itemData = false
	
	self._bindMap = {}
	
	self._noHasNum = false
	
	self.showingItems = {}
end


function MainQuickUseGroup:_initUI( ... )
	
end

--直接设设置code的数据
function MainQuickUseGroup:setData(codeType, itemCode, amount, noHasNum)
	
end

function MainQuickUseGroup:updateNum()
	
end

function MainQuickUseGroup:getQuickUseItem(itemData)
	if self.showingItems[itemData:getItemCode()] then return self.showingItems[itemData:getItemCode()] end
	local QuickUseView = require "Game.Modules.MainUI.QuickUseView"
	local head = QuickUseView.new({parent = self.view, data=itemData})
	head:toCreate()
	self.showingItems[itemData:getItemCode()] = head
	return head
end

function MainQuickUseGroup:checkNew(data)
	local itemData = data[1].itemData
	local itemInfo = data[1].itemData:getItemInfo()
	local amountChange = data[1].amountChange
	if(amountChange > 0) then
		if itemInfo.useType == 5 then  --5：获得时候，优先快捷使用
			local quickUseItem = self:getQuickUseItem(itemData)
			quickUseItem:updateAmount(itemData:getItemAmount())
		elseif itemInfo.useType == 3 then --3:获得时自动使用
			LuaLogE(DescAuto[184]); -- [184]="自动使用道具!!!!!!!!!!"
			--printTable(1, itemData);
			--printTable(1, itemInfo);
			local params = {}
			params.bagType = itemData:getBagType()
			params.itemId = itemData:getItemId()
			params.amount = amountChange
			params.onSuccess = function( res )
				print(1,res)
			end
			RPCReq.Bag_UseItem(params, params.onSuccess)
		end
	end
end

function MainQuickUseGroup:mainui_closeQuickUse(event, itemCode)
	self.showingItems[itemCode] = nil
end

function MainQuickUseGroup:pack_herocomp_change(_,data)
	self:checkNew(data)
	--[[if data[1].itemCode == self._itemCode then
		self:updateNum()
	end--]]
end

function MainQuickUseGroup:pack_item_change(_,data)
	self:checkNew(data)
	--[[if data[1].itemCode == self._itemCode then
		self:updateNum()
	end--]]
end

function MainQuickUseGroup:pack_equip_change(_,data)
	self:checkNew(data)
	--[[if data[1].itemCode == self._itemCode then
		self:updateNum()
	end--]]
end

function MainQuickUseGroup:pack_special_change(_,data)
	self:checkNew(data)
	--[[if data[1].itemCode == self._itemCode then
		self:updateNum()
	end--]]
end


function MainQuickUseGroup:onClickCell( index )
    --tips弹出

end



--退出操作 在close执行之前 
function MainQuickUseGroup:_onExit()
    print(1,"MainQuickUseGroup __onExit")
end

return MainQuickUseGroup
