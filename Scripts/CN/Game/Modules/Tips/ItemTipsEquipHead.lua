--装备tips
--added by wyang
local ItemTipsEquipHead = class("ItemTipsEquipHead",View)
local ItemCell = require "Game.UI.Global.ItemCell"
local  HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
function ItemTipsEquipHead:ctor(args)
	self._packName = "ToolTip"
	if args.winType and args.winType=="bag" then
		self._compName = "ItemTipsEquipHead_Bag"
	else
		self._compName = "ItemTipsEquipHead"
	end
	self.isBag = args.winType and args.winType=="bag" 
   self._isFullScreen = false
	self.nameLabel = false
	--self.pic_color = false
	self.itemCell = false
	
	self._data = args.data
end

function ItemTipsEquipHead:init( ... )
	-- body
end

-- [子类重写] 初始化UI方法
function ItemTipsEquipHead:_initUI( ... )

	--self.pic_color = self.view:getChildAutoType("pic_color")
	self.nameLabel = self.view:getChildAutoType("nameLabel")
	self.itemCell = self.view:getChildAutoType("itemCell")
	
	local txt_attrName1 = self.view:getChildAutoType("txt_attrName1") 
	local txt_attrName2 = self.view:getChildAutoType("txt_attrName2") 

	local txt_attr1 = self.view:getChildAutoType("txt_attr1") 
	local txt_attr2 = self.view:getChildAutoType("txt_attr2") 

	
	local itemInfo = self._data:getItemInfo()
	local equipInfo = DynamicConfigData.t_equipEquipment[itemInfo.code]
	
	
	
	local list_star = self.view:getChildAutoType("list_star")
	if list_star then
		list_star:setItemRenderer(function(index,obj)
			--obj:removeClickListener()--池子里面原来的事件注销掉
			--local starIcon= obj:getChild("img_star");
			--starIcon:setURL(PathConfiger.getCardStar(self.starImg))--放了卡牌图片
			end
		)
		list_star:setNumItems(equipInfo.staramount)
	end

	
	
	
	txt_attrName1:setText(Desc.itemtips_attrNameEquipPos) --部位 
	txt_attrName2:setText(Desc.itemtips_attrNameScore) --评分
	txt_attr1:setText(Desc["common_equipPos"..equipInfo.position])
	
	local totalPower = 0
	totalPower = HeroConfiger.CaleAttrPower(equipInfo)
	local uuid = self._data:getUuid()
	local skilldata = EquipmentModel:getSkillData(uuid)
	if skilldata  then
		totalPower = totalPower + HeroConfiger.CaleSkillPower(skilldata)
	end
	txt_attr2:setText(totalPower)
	
	
	local bgLoader = self.view:getChildAutoType("bgLoader") 
	if bgLoader then
		bgLoader:setURL(PathConfiger.getItemTipsHeadBg(self._data:getColorId()))
	end
	
	self.nameLabel:setText(self._data:getName())
	if self.isBag then
		self.nameLabel:setColor(self._data:getColor())
	else
		self.nameLabel:setColor(self._data:getItemTipsColor())
	end
	--self.pic_color:setColor(self._data:getColor())
	-- self.typeLabel:setText()
	

    local itemcellobj = BindManager.bindItemCell(self.itemCell)
	if self._args.winType and self._args.winType=="bag" then
		itemcellobj:setIsBig(true)
	else
		itemcellobj:setIsBig(false)
	end
    itemcellobj:setItemData(self._data)
end

-- [子类重写] 准备事件
function ItemTipsEquipHead:_initEvent( ... )
    
end 

-- [子类重写] 添加后执行
function ItemTipsEquipHead:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsEquipHead:_exit()
end


return ItemTipsEquipHead