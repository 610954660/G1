--道具tips
--added by wyang
local ItemTipsItemHead = class("ItemTipsItemHead",View)

function ItemTipsItemHead:ctor(args)
	self._packName = "ToolTip"
	if args.winType and args.winType=="bag" then
		self._compName = "ItemTipsItemHead_Bag"
	else
		self._compName = "ItemTipsItemHead"
	end
    
   self._isFullScreen = false
	self.isBag = args.winType and args.winType=="bag" 
	self.pic_color = false
	self.itemCell = false
	self.nameLabel = false
	--self.typeLabel = false
	--self.levelLabel = false
	
	self._data = args.data
end

function ItemTipsItemHead:init( ... )
	-- body
end

-- [子类重写] 初始化UI方法
function ItemTipsItemHead:_initUI( ... )
	local attrNumCtrl = self.view:getController("attrNumCtrl")
	self.pic_color = self.view:getChildAutoType("pic_color")
	self.itemCell = self.view:getChildAutoType("itemCell")
	self.nameLabel = self.view:getChildAutoType("nameLabel")
	local txt_attrName1 = self.view:getChildAutoType("txt_attrName1") 
	local txt_attrName2 = self.view:getChildAutoType("txt_attrName2") 
	local txt_attrName3 = self.view:getChildAutoType("txt_attrName3") 
	local txt_attr1 = self.view:getChildAutoType("txt_attr1") 
	local txt_attr2 = self.view:getChildAutoType("txt_attr2") 
	local txt_attr3 = self.view:getChildAutoType("txt_attr3") 
	local bgLoader = self.view:getChildAutoType("bgLoader") 
	if bgLoader then
		bgLoader:setURL(PathConfiger.getItemTipsHeadBg(self._data:getColorId()))
	end
	
	local code = self._data:getItemInfo().code
	local hasNum = 0
	if code > 2000 and code < 2100 then
		hasNum=	PlayerModel:getMoneyByType(code - 2000)
	else
		hasNum=	ModelManager.PackModel:getItemsFromAllPackByCode(code)
	end
	txt_attrName2:setText(Desc.itemtips_text5)
	txt_attr2:setText(StringUtil.transValue(hasNum))
	self.nameLabel:setText(self._data:getName())
	if self.isBag then
		self.nameLabel:setColor(self._data:getColor())
	else
		self.nameLabel:setColor(self._data:getItemTipsColor())
	end
	
	if self.pic_color then
		self.pic_color:setColor(self._data:getItemTipsColor())
	end
	
	-- self.typeLabel:setText()
	local itemInfo = self._data:getItemInfo()
	if itemInfo.category == GameDef.Category.Normal or itemInfo.category == GameDef.Category.Special or itemInfo.category == GameDef.Category.Jewelry or itemInfo.category == GameDef.Category.Rune then
		--普通道具或者特殊道具
		--attrNumCtrl:setSelectedIndex(1)
		txt_attrName1:setText(Desc.itemtips_attrNameUse) --用途
		txt_attr1:setText(itemInfo.usageDesc)

		--local desc = self._data:getUsageDesc()
	    --txt_attr1:setText(desc)
	elseif itemInfo.category == GameDef.Category.HeroComponent then
		--装备碎片
		--attrNumCtrl:setSelectedIndex(1)
		txt_attrName1:setText(Desc.itemtips_attrNameUse) --用途
		txt_attr1:setText(itemInfo.usageDesc)
	end

    
    local itemcellobj = BindManager.bindItemCell(self.itemCell)
	
	if self._args.winType and self._args.winType=="bag" then
		itemcellobj:setIsBig(true)
	else
		itemcellobj:setIsBig(false)
	end
	itemcellobj:setAmountVisible(false)
    itemcellobj:setItemData(self._data)
end

-- [子类重写] 准备事件
function ItemTipsItemHead:_initEvent( ... )
    
end 

-- [子类重写] 添加后执行
function ItemTipsItemHead:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsItemHead:_exit()
end


return ItemTipsItemHead