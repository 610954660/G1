--added by xhd
--背包道具分解
local BagSplitView = class("BagSplitView",Window)
local ItemCell = require "Game.UI.Global.ItemCell"
function BagSplitView:ctor( ... )
    self._packName = "UIPublic_Window"
	self._compName = "BagSplitView"
	self._rootDepth = LayerDepth.Top
	self.itemCell = false
    self.nameLabel =false 
	self.okBtn = false
	self.slider =false 
	self.minLabel = false
    self.maxLabel = false
    self.addBtn =false 
    self.subBtn = false
    self.itemData = false
    self._maxNum =false
    self.itemCellObj = false
    self._curNum = 1
    self.numLabel = false
end

function BagSplitView:init( ... )
	-- body
end

-- [子类重写] 初始化UI方法
function BagSplitView:_initUI( ... )
	self.itemCell = self.view:getChildAutoType("itemCell")
    self.nameLabel = self.view:getChildAutoType("nameLabel")
	self.okBtn = self.view:getChildAutoType("okBtn")
	self.slider = self.view:getChildAutoType("con/slider")
	self.minLabel = self.view:getChildAutoType("con/minLabel")
    self.maxLabel = self.view:getChildAutoType("con/maxLabel")
    self.addBtn = self.view:getChildAutoType("con/addBtn")
    self.subBtn = self.view:getChildAutoType("con/subBtn")
    self.numLabel = self.view:getChildAutoType("con/numLabel")
    self:initData()
end

function BagSplitView:initData( ... )
    self.itemData = self._args
    self._maxNum = self.itemData:getItemAmount()
    self:showPanel()  
end

--展示界面
function BagSplitView:showPanel( ... )
	self.nameLabel:setText(self.itemData:getName())
	self.minLabel:setText(1)
	self.maxLabel:setText(self._maxNum)
    self.itemCellObj = BindManager.bindItemCell(self.itemCell)
    self.itemCellObj:setItemData(self.itemData)
    self.slider:setValue(0)
    self.numLabel:setText(self._curNum)
    self:updatePos()
end

-- [子类重写] 准备事件
function BagSplitView:_initEvent( ... )
	self.addBtn:addClickListener(function ( context )
		 self._curNum = self._curNum + 1
		 if self._curNum>=self._maxNum then
		 	self._curNum = self._maxNum
		 end
        local value =  math.ceil(self._curNum/self._maxNum*100)
        if value >=100 then
        	value = 100
        end
		self.slider:setValue(value) 
		self.numLabel:setText(self._curNum)
		self:updatePos()
	end)

	self.subBtn:addClickListener(function ( ... )
		self._curNum = self._curNum -1 
		 if self._curNum <= 1 then
		 	 self._curNum =1
		 end
        local value =  math.ceil(self._curNum/self._maxNum*100)
         if self._curNum == 1 then
         	self.slider:setValue(0) 
         else
         	self.slider:setValue(value) 
         end
		 self.numLabel:setText(self._curNum)
		 self:updatePos()
	end)
    
    --出售按钮点击
	self.okBtn:addClickListener(function ( ... )
		 if self._curNum< 1 then
		 	 return
		 end
		 local params = {}
		 params.bagType = self.itemData:getBagType()
		 params.itemId = self.itemData:getItemId()
		 params.amount = self._curNum
		 print(1,self._curNum)
		 params.onSuccess = function( res )
		 	print(1,res)
		 end
		 RPCReq.Bag_DecomposeItem(params, params.onSuccess)
	end)
    local function onChanged( ... )
    	local value = math.ceil(self.slider:getValue()/100*self._maxNum)
    	if value<=1 then value = 1 end
    	print(1,self._curNum)
    	self._curNum = value
    	self.numLabel:setText(self._curNum)
    	self:updatePos()
    end
	self.slider:addEventListener(FUIEventType.Changed, onChanged);
end 

function BagSplitView:updatePos()
	local width = self.slider:getWidth()
	local posX = self.slider:getX() + width * self.slider:getValue()/100
	self.numLabel:setX(posX)
end

-- [子类重写] 添加后执行
function BagSplitView:_enter()
end

-- [子类重写] 移除后执行
function BagSplitView:_exit()
end

return BagSplitView