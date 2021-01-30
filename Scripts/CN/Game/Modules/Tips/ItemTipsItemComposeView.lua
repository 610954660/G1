--道具tips
--added by wyang
local ItemTipsItemComposeView = class("ItemTipsItemComposeView",Window)
--local ItemCell = require "Game.UI.Global.ItemCell"
function ItemTipsItemComposeView:ctor(args)
	self._packName = "ToolTip"
    self._compName = "ItemTipsItemComposeView"
	self._rootDepth = LayerDepth.PopWindow

	self._data = args
	
	self.useNum = 1
	self.maxNum = 0 --最大可以合成多少组
end

function ItemTipsItemComposeView:init( ... )
	-- body
end

-- [子类重写] 初始化UI方法
function ItemTipsItemComposeView:_initUI( ... )
	
	local comCode=self._data.__data.code;
	local _hasNum=self._data:getItemAmount();
	local itemCom= DynamicConfigData.t_heroCombine[comCode] 
	self.maxNum = math.floor(_hasNum/itemCom.amount)
		
	local viewRoot = self.view;
	local itemCell = viewRoot:getChildAutoType("itemCell")
    local btn_sub = viewRoot:getChildAutoType("btn_sub") 
    local btn_add = viewRoot:getChildAutoType("btn_add") 
    local txt_num = viewRoot:getChildAutoType("txt_num") 
    local btn_use = viewRoot:getChildAutoType("btn_use") 
	txt_num:setText(1)
	local itemcellobj = BindManager.bindItemCell(itemCell)
    itemcellobj:setItemData(self._data)
	
	btn_add:addClickListener(function()
		if self.useNum >= self.maxNum then return end
		self.useNum = self.useNum + 1
		txt_num:setText(self.useNum)
		txt_goldNum:setText()
	end)
	
	btn_sub:addClickListener(function()
		if self.useNum <= 1 then return end
		self.useNum = self.useNum - 1
		txt_num:setText(self.useNum)
		txt_goldNum:setText()
	end)

	btn_use:addClickListener(function()
		ModelManager.CardLibModel:combineCard(comCode,self.useNum)
		self:closeView()
	end)
end

-- [子类重写] 准备事件
function ItemTipsItemComposeView:_initEvent( ... )
    
end 

-- [子类重写] 添加后执行
function ItemTipsItemComposeView:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsItemComposeView:_exit()
end


return ItemTipsItemComposeView