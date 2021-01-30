--道具tips
--added by wyang
local ItemTipsDesc = class("ItemTipsDesc",View)
function ItemTipsDesc:ctor(args)
	self._packName = "ToolTip"
	self._isFullScreen = false
   	if args.winType and args.winType=="bag" then
		self._compName = "ItemTipsDesc_Bag"
	else
		self._compName = "ItemTipsDesc"
	end
	
	self.txt_title = false
	self.txt_desc = false
	
	self._data = args.data
end

function ItemTipsDesc:init( ... )
	-- body
end

-- [子类重写] 初始化UI方法
function ItemTipsDesc:_initUI( ... )
	self.txt_title = self.view:getChildAutoType("txt_title")
	self.txt_desc = self.view:getChildAutoType("txt_desc")
	
	self.txt_title:setText(self._data.title)
	self.txt_desc:setText(self._data.desc)
end

-- [子类重写] 准备事件
function ItemTipsDesc:_initEvent( ... )
    
end 

-- [子类重写] 添加后执行
function ItemTipsDesc:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsDesc:_exit()
end


return ItemTipsDesc