--道具tips
--added by xhd
local ItemTipsRuneAttr = class("ItemTipsRuneAttr",View)
--local ItemCell = require "Game.UI.Global.ItemCell"
function ItemTipsRuneAttr:ctor(args)
	self._packName = "ToolTip"
    self._compName = "ItemTipsEquipAttr"
   self._isFullScreen = false

	self._data = args.data
	-- printTable(1,self._data)
end

function ItemTipsRuneAttr:init( ... )
	-- body
end

-- [子类重写] 初始化UI方法
function ItemTipsRuneAttr:_initUI( ... )
	local list_attr = self.view:getChildAutoType("list_attr")
	local specialData = self._data:getItemSPecialData() 
	--不是背包的数据结果点击进来 但是服务器赋予了uuid
	if not specialData and self._data:getUuid() then
		local code = self._data:getItemCode()
		local uuid = self._data:getUuid()
		--去真正的背包拿 有才服务器属性数据
		if code and uuid then
			local itemData = PackModel:getRuneBag():getItemByUuid(code,uuid)
			if itemData then
				specialData = itemData:getItemSPecialData() 
			end
		end
		
	end
	local runeAttrs = {}
	if specialData and specialData.rune and specialData.rune.attrs then
		runeAttrs = specialData.rune.attrs
	end
	list_attr:setItemRenderer(function(index,obj)			
            obj:getChildAutoType("name"):setText(Desc["common_fightAttr"..runeAttrs[index+1].id])
			obj:getChildAutoType("value"):setText("+"..GMethodUtil:getFightAttrName(runeAttrs[index+1].id,runeAttrs[index+1].value))
			local up = obj:getChildAutoType("up")
			local down = obj:getChildAutoType("down")
			
			up:setVisible(false)
			down:setVisible(false)
		end)
	list_attr:setData(runeAttrs)
	list_attr:resizeToFit(#runeAttrs)
end

-- [子类重写] 准备事件
function ItemTipsRuneAttr:_initEvent( ... )
    
end 

-- [子类重写] 添加后执行
function ItemTipsRuneAttr:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsRuneAttr:_exit()
end


return ItemTipsRuneAttr