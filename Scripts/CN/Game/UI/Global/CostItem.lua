 --added by wyang
--道具框封裝
--local CostItem = class("CostItem")
local CostItem,Super = class("CostItem",BindView)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
function CostItem:ctor(view)
	self.txt_num = false
	self.iconLoader = false
	
	self._needNum = 0
	self._itemCodeType = false
	self._itemCode = false
	self._itemData = false
	self.itemCell = false
	
	self._bindMap = {}
	
	self._noHasNum = false
	self._onlyHasNum = false --只显示当前有的数量（同样要变色）
	self._noColorChange = false
	self._speType = false
	self._useMoneyItem = true; -- 图标使用金币栏里的图标
	self._hasNumOnRight = false; -- 拥有的数量在右边
	self._greenColor = false --外部控制绿色色号 兼容不同地方色号差异
	self._normalColor = false -- 正常显示色号 现在默认是灰的 可能有的地方是白的
	self._redColor = false--外部控制红色色号 兼容不同地方色号差异
	self._isNoTips = false --是否不显示tips
	self._allTextCanChangeColor = false -- 因为有策划想要文本颜色都变 所以再加一个
	self._noFIxTextSize = false --文本大小根据文本框设置
end


function CostItem:_initUI( ... )
	self.iconLoader = self.view:getChildAutoType("iconLoader")
	local textColorController = self.view:getController("textColor")
	if textColorController and textColorController:getSelectedIndex() == 1 then
		self:setGreenColor(ColorUtil.textColorStr_Light.green)
		self:setRedColor(ColorUtil.textColorStr_Light.red)
	else
		self:setGreenColor(ColorUtil.textColorStr.green)
		self:setRedColor(ColorUtil.textColorStr.red)	
	end
	local itemCell = self.view:getChildAutoType("itemCell")
	if itemCell then
		self.itemCell = BindManager.bindItemCell(itemCell)
		self.itemCell:setIsCost(true)
		if self.iconLoader then self.iconLoader:setVisible(false) end
	end
	self.txt_num = self.view:getChildAutoType("txt_num")
end

function CostItem:setDarkBg(isDark)
	if isDark then
		self:setGreenColor(ColorUtil.textColorStr_Light.green)
		self:setRedColor(ColorUtil.textColorStr_Light.red)
	else
		self:setGreenColor(ColorUtil.textColorStr.green)
		self:setRedColor(ColorUtil.textColorStr.red)
	end
end

-- 设置拥有的数量在右边
function CostItem:setHasNumOnRight(bool)
	self._hasNumOnRight = bool;
end

-- 设置绿色色号 参数为富文本形式
-- @param color #000000
function CostItem:setGreenColor(color)
	if (color) then
		self._greenColor = string.format("[color=%s]%%s[/color]", color);
	end
end

-- 设置红色色号 参数为富文本形式
-- @param color #000000
function CostItem:setRedColor(color)
	if (color) then
		self._redColor = string.format("[color=%s]%%s[/color]", color);
	end
end 


-- 设置正常色号
-- @param color CCColor3B
function CostItem:setNormalColor(color)
	if (color) then
		self._normalColor = color;
		if (type(color) ~= "string") then
			self.txt_num:setColor(color)
		end
	end
end

-- 因为有策划想要文本颜色都变 所以再加一个
function CostItem:setAllInfoChangeColor(boolean)
	self._allTextCanChangeColor = boolean
end

-- type == "money"的话，显示平面图标
function CostItem:setIconType(type)
	if self.itemCell then
		self.itemCell:setIsCost(type == "money")
	end
	self._useMoneyItem = type == "money"
end

--直接设设置code的数据
function CostItem:setData(codeType, itemCode, amount, noHasNum, onlyHasNum,noColorChange,speType,noFIxTextSize)
	self._noHasNum  = noHasNum and true or false
	self._onlyHasNum  = onlyHasNum and true or false
 	self._noColorChange = noColorChange and true or false
	self._itemCodeType = codeType
	self._itemCode = itemCode
	self._needNum = amount
	self._speType = speType and speType or false
	self._noFIxTextSize  = noFIxTextSize or false
    self._itemData =  ItemsUtil.createItemData({data = {code = itemCode, type = codeType}})
	local url = ItemConfiger.getItemIconByCode(itemCode, codeType,self._useMoneyItem)
	--[[if (self._useMoneyItem and (self._itemCodeType == CodeType.MONEY or itemCode == 10000006)) then
		url = PathConfiger.getMoneyIcon(self._itemCode);
	end--]]
    if self.iconLoader then self.iconLoader:setURL(url) end
	if self.itemCell then self.itemCell:setData(itemCode, 0, codeType) end
	self:updateNum()
	
	local itemInfo = ItemConfiger.getInfoByCode(itemCode, GameDef.GameResType.Item)
	if itemInfo then
		if self.iconLoader then
			self.iconLoader:setTouchable(true)
			self.iconLoader:removeClickListener(333)
			self.iconLoader:addClickListener(function( ... )
				  local cost = {
					code = itemCode,
					type = codeType,
				}
				--ViewManager.open("ItemNotEnoughView", cost)
				if not self._isNoTips then
					ViewManager.open("ItemTips", {codeType = cost.type, id = cost.code, data = self._itemData})
				end
			   end,333)
		end
	else
		if self.iconLoader then self.iconLoader:setTouchable(false) end
	end

end

function CostItem:setNoTips(isNoTips)
	self._isNoTips = isNoTips
end

function CostItem:updateNum()
	local hasNum = 0
	if self._itemCodeType == CodeType.ITEM then
		hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(self._itemCode)
	elseif self._itemCodeType == CodeType.MONEY then
		hasNum = ModelManager.PlayerModel:getMoneyByType(self._itemCode)
	end
	if not tolua.isnull(self.txt_num) then
		local costStr =""
		if self._noColorChange then
			if self._speType==1 then
				costStr =  "X%s"
			else
				costStr =  "%s"
			end
		else
			local greedColor = "";
			local redColor = "";
			if self._speType==1 then
				greedColor = Desc.common_costNumGreen2
				redColor = Desc.common_costNumRed2
			else
				if self._noFIxTextSize then
					greedColor = Desc.common_costNumGreenNoSize
					redColor = Desc.common_costNumRedNoSize
				else
					greedColor = Desc.common_costNumGreen
					redColor = Desc.common_costNumRed
				end
			end
			if self._greenColor then
				greedColor = self._greenColor
			end
			if self._redColor then
				redColor = self._redColor
			end
			costStr = hasNum >= self._needNum and greedColor or redColor
		end
		if self._onlyHasNum then
			self.txt_num:setText(string.format(costStr, MathUtil.toSectionStr(hasNum)))
		elseif(self._noHasNum) then
			self.txt_num:setText(string.format(costStr, MathUtil.toSectionStr(self._needNum)))
		else
			hasNum = MathUtil.toSectionStr(hasNum)
			local needNum = MathUtil.toSectionStr(self._needNum);
			if (not self._hasNumOnRight) then
				if self._allTextCanChangeColor then
					self.txt_num:setText(string.format(costStr,hasNum.."/"..needNum))
				else
					self.txt_num:setText(string.format(costStr,hasNum.."/"..needNum))
				end
			else
				if self._allTextCanChangeColor then
					self.txt_num:setText(string.format(costStr, needNum.."/"..hasNum));
				else
					self.txt_num:setText(string.format(costStr, needNum).."/"..hasNum);
				end
			end
		end
		--self.txt_num:setColor(hasNum >= self._needNum and ColorUtil.textColor.green or ColorUtil.textColor.red)
	end
end

-- use == true 使用金币栏中的图标  added by zn
function CostItem:setUseMoneyItem(use)
	self._useMoneyItem = use;

	if (self._itemCode) then
		local url = ItemConfiger.getItemIconByCode(self._itemCode, 2, self._useMoneyItem)
		if (self._useMoneyItem or self._itemCodeType == CodeType.MONEY) then
			url = PathConfiger.getMoneyIcon(self._itemCode);
		end
		if self.iconLoader then self.iconLoader:setURL(url) end
	end
end

function CostItem:money_change(_,data)
	self:updateNum()
end

function CostItem:pack_herocomp_change(_,data)
	if data[1].itemCode == self._itemCode then
		self:updateNum()
	end
end

function CostItem:pack_item_change(_,data)
	if data[1].itemCode == self._itemCode then
		self:updateNum()
	end
end

function CostItem:pack_equip_change(_,data)
	if data[1].itemCode == self._itemCode then
		self:updateNum()
	end
end

function CostItem:pack_special_change(_,data)
	if data[1].itemCode == self._itemCode then
		self:updateNum()
	end
end

function CostItem:_refresh()
	self:updateNum()
end


function CostItem:onClickCell( index )

end



--退出操作 在close执行之前 
function CostItem:_onExit()
    print(1,"CostItem __onExit")
end

return CostItem