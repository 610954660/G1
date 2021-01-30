--道具tips
--added by wyang
local ItemTipsEquipAttr = class("ItemTipsEquipAttr",View)
--local ItemCell = require "Game.UI.Global.ItemCell"
function ItemTipsEquipAttr:ctor(args)
	self._packName = "ToolTip"
	if args.winType and args.winType=="bag" then
		self._compName = "ItemTipsEquipAttr_Bag"
	else
		self._compName = "ItemTipsEquipAttr"
	end
   self._isFullScreen = false

	self._data = args.data
end

function ItemTipsEquipAttr:init( ... )
	-- body
end

-- [子类重写] 初始化UI方法
function ItemTipsEquipAttr:_initUI( ... )
	local list_attr = self.view:getChildAutoType("list_attr")
	
	local itemInfo = self._data:getItemInfo()
	local info = DynamicConfigData.t_equipEquipment[itemInfo.code]
	
	local sx = {}
	if info.hp>0 then
		sx[#sx+1] = {name = Desc.equipment_sx1, key="hp", value = info.hp}
	end
	if info.attack>0 then
		sx[#sx+1] = {name = Desc.equipment_sx2, key="attack", value = info.attack}
	end
	if info.defense>0 then
		sx[#sx+1] = {name = Desc.equipment_sx3, key="defense", value = info.defense}
	end
	if info.magic>0 then
		sx[#sx+1] = {name = Desc.equipment_sx4, key="magic", value = info.magic}
	end
	if info.magicDefense>0 then
		sx[#sx+1] = {name = Desc.equipment_sx5, key="magicDefense", value = info.magicDefense}
	end
	if info.speed>0 then
		sx[#sx+1] = {name = Desc.equipment_sx6, key="speed", value = info.speed}
	end
		
	
	
	list_attr:setItemRenderer(function(index,obj)
			local sxInfo = sx[index+1]
			local name = obj:getChildAutoType("name")
			name:setText(sxInfo.name)
			local value = obj:getChildAutoType("value")
			value:setText(sxInfo.value)
			
			local up = obj:getChildAutoType("up")
			local down = obj:getChildAutoType("down")
			
			up:setVisible(false)
			down:setVisible(false)
		end)
	list_attr:setNumItems(#sx)
	list_attr:resizeToFit(#sx)
end

-- [子类重写] 准备事件
function ItemTipsEquipAttr:_initEvent( ... )
    
end 

-- [子类重写] 添加后执行
function ItemTipsEquipAttr:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsEquipAttr:_exit()
end


return ItemTipsEquipAttr