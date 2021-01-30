-- added by wyz 
-- 精灵羁绊界面

local ElvesPromoteView = class("ElvesPromoteView",Window)

local __itemCode = 10000079

function ElvesPromoteView:ctor()
    self._packName = "ElvesSystem"
	self._compName = "ElvesPromoteView"
    self._rootDepth = LayerDepth.PopWindow

    self.list_attr  = false     -- 属性列表
    self.itemCell   = false     -- 物品
    self.btn_use    = false     -- 使用
    self.bar_exp    = false     -- 经验条
end

function ElvesPromoteView:_initUI()
    self.c1 = self.view:getController("c1")
    self.list_attr  = self.view:getChildAutoType("list_attr")
    self.itemCell   = self.view:getChildAutoType("itemCell")
    self.btn_use    = self.view:getChildAutoType("btn_use")
    self.bar_exp    = self.view:getChildAutoType("bar_exp")
end

function ElvesPromoteView:_initEvent()
	self:ElvesPromoteView_refreshPanal()
end

function ElvesPromoteView:ElvesPromoteView_refreshPanal( )
	self:refreshPanal()
end

function ElvesPromoteView:refreshPanal( )
	local configInfo = DynamicConfigData.t_ElfAttrItem
	local itemCode=configInfo[__itemCode].itemCost
	local maxLimit=configInfo[__itemCode].limit
	local itemcell = BindManager.bindItemCell(self.itemCell)
	itemcell:setData(itemCode, 1, CodeType.ITEM)
	local hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(itemCode)
	itemcell:setAmount(hasNum)
	local count = ModelManager.ElvesSystemModel.limitFetterCount[itemCode] or 0
	if count ~= 0 then
		count = count.limit or 0
	end
	self.btn_use:removeClickListener(11)
	self.btn_use:addClickListener(function(context)
		if hasNum == 0 then
			RollTips.show(Desc.ElvesSystem_noProp)
			return
		end
		ModelManager.ElvesSystemModel:reqElfFetterUseItem()
	end,11)

	self.bar_exp:setMax(maxLimit)
	self.bar_exp:setValue(count)
	if maxLimit==count then
		self.c1:setSelectedIndex(2)
	else
		self.c1:setSelectedIndex(1)
	end
	local attMap=configInfo[__itemCode].addAttr
	self.list_attr:setItemRenderer(
		function(index, obj)
		local itemAttr=attMap[index+1]
		local attrName= GMethodUtil:getFightAttrName(itemAttr.type)
		local attrNum=	GMethodUtil:getFightAttrName(itemAttr.type,itemAttr.value*count)
		local c1= obj:getController("c1")	
		c1:setSelectedIndex(1)
		local txt_attrName= obj:getChildAutoType("txt_attrName")	
		txt_attrName:setText(attrName)
		local txt_cur= obj:getChildAutoType("txt_cur")	
		txt_cur:setText(attrNum)
		local iconLoader = obj:getChildAutoType("loader_attrIcon")
		iconLoader:setURL(PathConfiger.getFightAttrIcon(itemAttr.type))
        end
    )
    self.list_attr:setNumItems(#attMap)
end


return ElvesPromoteView