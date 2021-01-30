--道具tips
--added by wyang
local ItemTipsGiftBox = class("ItemTipsGiftBox",View)
function ItemTipsGiftBox:ctor(args)
	self._packName = "ToolTip"
	self._isFullScreen = false
   	if args.winType and args.winType=="bag" then
		self._compName = "ItemTipsGiftBox_Bag"
	else
		self._compName = "ItemTipsGiftBox"
	end
	
	self.txt_title = false
	self.txt_desc = false
	
	self._data = args.data
end

function ItemTipsGiftBox:init( ... )
	-- body
end

-- [子类重写] 初始化UI方法
function ItemTipsGiftBox:_initUI( ... )
	self.txt_title = self.view:getChildAutoType("txt_title")
	self.txt_desc = self.view:getChildAutoType("txt_desc")
	self.list_award = self.view:getChildAutoType("list_award")
	
	self.txt_title:setText(self._data.title)
	self.txt_desc:setText(self._data.desc)
	
	 self.list_award:setItemRenderer(
        function(index, obj)
            local reward = self._data.reward[index + 1]
			local rewardObj = BindManager.bindItemCell(obj)
			rewardObj:setData(reward.code, reward.amount, reward.type)
			
		end)
	self.list_award:setNumItems(#self._data.reward)
end

-- [子类重写] 准备事件
function ItemTipsGiftBox:_initEvent( ... )
    
end 

-- [子类重写] 添加后执行
function ItemTipsGiftBox:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsGiftBox:_exit()
end


return ItemTipsGiftBox