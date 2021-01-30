--added by wyang
--带消耗的按钮
--local CostButton = class("CostButton")
local CostButton,Super = class("CostButton",BindView)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
function CostButton:ctor(view)
	self.txt_num = false
	self.iconLoader = false
	self.costCtrl = false
	
	self._needNum = 0
	self._itemCodeType = false
	self._itemCode = false
	self._itemData = false
	self._useMoneyItem = true;
	self.__userCostType = false
	self._defaultColor = false
	self._addX = false
	self._setCostIndex = false
end

function CostButton:setAddX(isAdd)
	self._addX = isAdd
end



function CostButton:_initUI( ... )
	self.iconLoader = self.view:getChildAutoType("icon")
	self.txt_num = self.view:getChildAutoType("cost")
	self.costCtrl  = self.view:getController("cost")
	
	self._defaultColor = self.view:getChildAutoType("title"):getColor()
end

--直接设设置code的数据
function CostButton:setData(cost)
	if not cost then cost = {type = 0, code = 0, amount=0} end
	self._itemCodeType = cost.type
	self._itemCode = cost.code
	self._needNum = cost.amount

	local url = ItemConfiger.getItemIconByCode(self._itemCode)
	if (self._useMoneyItem and self._itemCodeType == CodeType.MONEY) then
		url = PathConfiger.getMoneyIcon(self._itemCode);
	end
    self.iconLoader:setURL(url)
	self:updateNum()
end

function CostButton:updateNum()
	if tolua.isnull(self.view) then return end 
	if not ModelManager.PlayerModel then return end 
	if self._needNum == 0 then
		if self.costCtrl then self.costCtrl:setSelectedIndex(3) end
		return
	end
	local hasNum = 0
	if self._itemCodeType == CodeType.ITEM then
		hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(self._itemCode)
	elseif self._itemCodeType == CodeType.MONEY then
		hasNum = ModelManager.PlayerModel:getMoneyByType(self._itemCode)
	end
	if not tolua.isnull(self.txt_num) then
		local textStr = (self._addX and " x" or "")..MathUtil.toSectionStr(self._needNum)
		self.txt_num:setText(textStr)
		if not self.__userCostType then
			if self.costCtrl then self.costCtrl:setSelectedIndex(string.len(textStr) > 2 and 1 or 2) end
		end
		self.txt_num:setColor(hasNum >= self._needNum and self._defaultColor or ColorUtil.textColor.red)
	end
end

function CostButton:setCostCtrl( index )
	 index = index and index or 0
	 self.__userCostType = index
	 self.costCtrl:setSelectedIndex(index)
end

function CostButton:money_change(_,data)
	self:updateNum()
end

function CostButton:pack_herocomp_change(_,data)
	if data[1].itemCode == self._itemCode then
		self:updateNum()
	end
end

function CostButton:pack_item_change(_,data)
	if data[1].itemCode == self._itemCode then
		self:updateNum()
	end
end

function CostButton:pack_equip_change(_,data)
	if data[1].itemCode == self._itemCode then
		self:updateNum()
	end
end

function CostButton:pack_special_change(_,data)
	if data[1].itemCode == self._itemCode then
		self:updateNum()
	end
end


function CostButton:onClickCell( index )

end

--添加几个日常用的方法，方便作为显示对象直接使用
function CostButton:setVisible(visible )
	self.view:setVisible(visible)
end

function CostButton:removeClickListener(id)
	self.view:removeClickListener(id)
end

function CostButton:addClickListener(func, id)
	if id then
		self.view:addClickListener(func, id)
	else
		self.view:addClickListener(func)
	end
end

-- use == true 使用金币栏中的图标  added by zn
function CostButton:setUseMoneyItem(use)
	self._useMoneyItem = use;

	if (self._itemCode) then
		local url = ItemConfiger.getItemIconByCode(self._itemCode)
		if (self._useMoneyItem and self._itemCodeType == CodeType.MONEY) then
			url = PathConfiger.getMoneyIcon(self._itemCode);
		end
		self.iconLoader:setURL(url)
	end
end


--退出操作 在close执行之前 
function CostButton:_onExit()
    print(1,"CostButton __onExit")
end

return CostButton