 --added by wyang
--道具图标（有配道具来源的话，点击后会显示道具来源窗口）
--local CostIcon = class("CostIcon")
local CostIcon,Super = class("CostIcon",BindView)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
function CostIcon:ctor(view)
	self.iconLoader = view
	self._itemData = false
end


function CostIcon:_initUI( ... )
	
end


--直接设设置code的数据
function CostIcon:setData(codeType, itemCode, useMoneyItem)
	local url = ItemConfiger.getItemIconByCode(itemCode, codeType,useMoneyItem)
    self.iconLoader:setURL(url)	
	 self._itemData =  ItemsUtil.createItemData({data = {code = itemCode, type = codeType}})
	local itemInfo = ItemConfiger.getInfoByCode(itemCode, GameDef.GameResType.Item)
	if itemInfo then
		self.iconLoader:setTouchable(true)
		self.iconLoader:removeClickListener(333)
		self.iconLoader:addClickListener(function( ... )
			  local cost = {
				code = itemCode,
				type = codeType,
			}
			--ViewManager.open("ItemNotEnoughView", cost)
			ViewManager.open("ItemTips", {codeType = cost.type, id = cost.code, data = self._itemData})
		   end,333)
	else
		self.iconLoader:setTouchable(false)
	end

end


-- use == true 使用金币栏中的图标  added by zn
function CostIcon:setUseMoneyItem(use)
	self._useMoneyItem = use;

	if (self._itemCode) then
		local url = ItemConfiger.getItemIconByCode(self._itemCode, 2, self._useMoneyItem)
		if (self._useMoneyItem or self._itemCodeType == CodeType.MONEY) then
			url = PathConfiger.getMoneyIcon(self._itemCode);
		end
		self.iconLoader:setURL(url)
	end
end



function CostIcon:onClickCell( index )

end



--退出操作 在close执行之前 
function CostIcon:_onExit()
    print(1,"CostIcon __onExit")
end

return CostIcon