--added by wyang
--道具框封裝
--local CostBar = class("CostBar")
local CostBar,Super = class("CostBar",BindView)
function CostBar:ctor(view)
	self.list_cost = false
	self._costData = false
	self._noHasNum = false
	self._onlyHasNum = false
	self._hasNumOnRight = false
	self._greenColor = false
	self._redColor = false
	self._normalColor = false
	self._darkBg = false  --是否深色背景
	self._allTextCanChangeColor = false
end



--直接设设置code的数据
function CostBar:setData(costData, noHasNum, onlyHasNum)
	if noHasNum == nil then noHasNum = true end
	self._noHasNum = noHasNum and true or false
	self._onlyHasNum  = onlyHasNum and true or false
	self._costData = costData
	self.list_cost:setNumItems(#self._costData)
end

-- 设置拥有的数量在右边
function CostBar:setHasNumOnRight(bool)
	self._hasNumOnRight = bool;
end

-- 设置绿色色号 参数为富文本形式
-- @param color #000000
function CostBar:setGreenColor(color)
	if (color) then
		self._greenColor = color;
	end
end

function CostBar:setRedColor(color)
	if (color) then
		self._redColor = color;
	end
end

-- 设置正常色号 参数为富文本形式
-- @param color CCColor3B
function CostBar:setNormalColor(color)
	if (color) then
		self._normalColor = color;
	end
end

-- 因为有策划想要文本颜色都变 所以再加一个
function CostBar:setAllInfoChangeColor(boolean)
	self._allTextCanChangeColor = boolean
end

--设置是否深色背景
function CostBar:setDarkBg(isDark)
	self._darkBg = isDark
end

function CostBar:_initUI( ... )
	self.list_cost = self.view:getChildAutoType("list_cost")
	local textColorController = self.view:getController("textColor")
	if textColorController and textColorController:getSelectedIndex() == 1 then
		self._darkBg = true
	end
	if not self.list_cost then self.list_cost = self.view end
	self.list_cost:setItemRenderer(function (index,obj)
		local costData = self._costData[index + 1]
		if (not obj.costItem) then
			obj.costItem = BindManager.bindCostItem(obj)
		end
		obj.costItem:setHasNumOnRight(self._hasNumOnRight);
		if self._darkBg then
			obj.costItem:setGreenColor(ColorUtil.textColorStr_Light.green) 
			obj.costItem:setRedColor(ColorUtil.textColorStr_Light.red)
		end
		if (self._greenColor) then 
			obj.costItem:setGreenColor(self._greenColor) 
		end
		if (self._redColor) then
			obj.costItem:setRedColor(self._redColor)
		end
		if (self._normalColor) then
			obj.costItem:setNormalColor(self._normalColor) 
		end
		if (self._allTextCanChangeColor) then
			obj.costItem:setAllInfoChangeColor(self._allTextCanChangeColor)
		end
		obj.costItem:setData(costData.type, costData.code, costData.amount, self._noHasNum, self._onlyHasNum,false,false)
		-- obj.costItem:setUseMoneyItem(true);
	end)
end

function CostBar:setVisible(visible)
	self.view:setVisible(visible)
end

--退出操作 在close执行之前 
function CostBar:_onExit()
    print(1,"CostBar __onExit")
end

return CostBar