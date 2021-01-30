--added by xhd
--背包道具批量使用
local BatchUseView = class("BatchUseView",Window)
local ItemCell = require "Game.UI.Global.ItemCell"
function BatchUseView:ctor( ... )
    self._packName = "UIPublic_Window"
	self._compName = "BatchUseView"
	self._rootDepth = LayerDepth.Top
	self.itemCell = false
	self.nameLabel = false
	self.okBtn = false
	self.slider = false
	self.minLabel = false
	self.maxLabel = false
	self.numLabel = false
	self.addBtn = false
	self.subBtn = false
	self.itemData = false
	self._curNum = 1
	self._maxNum = 1
	self.itemCellObj = false
end



-- [子类重写] 初始化UI方法
function BatchUseView:_initUI( ... )
	self.itemCell = self.view:getChildAutoType("itemCell")
	self.nameLabel = self.view:getChildAutoType("nameLabel")
	self.okBtn = self.view:getChildAutoType("okBtn")
	self.slider = self.view:getChildAutoType("con/slider")
	self.minLabel = self.view:getChildAutoType("con/minLabel")
    self.maxLabel = self.view:getChildAutoType("con/maxLabel")
    self.numLabel = self.view:getChildAutoType("con/numLabel")
    self.addBtn = self.view:getChildAutoType("con/addBtn")
    self.subBtn = self.view:getChildAutoType("con/subBtn")
    self:initData()
end

--初始化数据
function BatchUseView:initData(  )
    self.itemData = self._args
    self._maxNum = self.itemData:getItemAmount()
    self:showPanel()    
end

function BatchUseView:showPanel( ... )
	-- self.itemCell:setItemData(self._itemData)
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
function BatchUseView:_initEvent( ... )
	self.addBtn:addClickListener(function ( ... )
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

	self.okBtn:addClickListener(function ( ... )
		 if self._curNum< 1 then
		 	 return
		 end
		 local params = {}
		 params.bagType = self.itemData:getBagType()
		 params.itemId = self.itemData:getItemId()
		 params.amount = self._curNum
		 params.onSuccess = function( res )
		 	print(1,res)
		 end
		 RPCReq.Bag_UseItem(params, params.onSuccess)
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

-- [子类重写] 添加后执行
function BatchUseView:_enter()
end

-- [子类重写] 移除后执行
function BatchUseView:_exit()
end

--更新num的位置
function BatchUseView:updatePos( ... )
	local width = self.slider:getWidth()
	local posX = self.slider:getX() + width * self.slider:getValue()/100
	self.numLabel:setX(posX)
end

return BatchUseView