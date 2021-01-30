--added by xhd
--道具框封裝
local ItemCellCircle = class("ItemCellCircle",BindView)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
-- local GameDef.BagType = GameDef.GameDef.BagType
function ItemCellCircle:ctor(view,noClick)
    self.view = view
    self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
    self.noClick = noClick
    -- self.lockCtrl = false
    self.frameLoader = false
    self.iconLoader = false
    -- self.selectFrameImg = false
    -- self.buttonCtrl = false
    -- self.selectCtrl = false
    -- self.starList = false
    
    self.itemCode = 0
    self.codeType = 0 --code的类型 
    self.winType = 0 -- 只是一個标记位 标记是否是从背包打开的item
    --数量label
    self.txtNum = false
    -- --道具数据
    self._itemData = false
    --是否选中
    -- self.isSelected = false
    --背景
    -- self.itembg = false
    -- self.itemName = false
    self._clickAble = true --是否可以点击出tips
    self.showAmountType = true
    self.skeletonNode = false;
    self.cardStarObj = false
    -- self._isBig = false  --是否大的ItemCellCircle

end

function ItemCellCircle:init( ... )
    self.frameLoader = self.view:getChildAutoType("frameLoader");
    self.iconLoader = self.view:getChildAutoType("iconLoader");
    self.txtNum = self.view:getChildAutoType("txt_num");
	self.cardStarObj = self.view:getChildAutoType("cardStar")
    self.view:removeClickListener()
    if not self.noClick  then
        self.view:addClickListener(function()
            self:onClickCell()
        end)
    end
end

--设置碎片信息
function ItemCellCircle:setSplitInfo()
	local splitCtrl = self.view:getController("splitCtrl")
	local img_category = self.view:getChildAutoType("img_category")
	local img_categoryBg = self.view:getChildAutoType("img_categoryBg")
	local starList = BindManager.bindCardStar(self.view:getChildAutoType("cardStar"))
	local elvesSplitCtrl = self.view:getController("elvesSplitCtrl")
	local itemInfo= self._itemData:getItemInfo()

	if splitCtrl then splitCtrl:setSelectedIndex(1) end
	if starList then starList:setData(self._itemData:getItemInfo().star) end
	local category = ItemConfiger.getSplitCategory (self.itemCode)
	if img_category then 
		img_category:setVisible(category ~= 0)
		img_category:setURL(PathConfiger.getCardCategory(category))
	end
	
	if img_categoryBg then img_categoryBg:setVisible(category ~= 0) end

	-- if itemInfo.category == GameDef.BagType.Elf and elvesSplitCtrl then 	-- 如果是精灵碎片 不显示星级
	-- 	elvesSplitCtrl:setSelectedIndex(1)
	-- elseif elvesSplitCtrl then
	-- 	elvesSplitCtrl:setSelectedIndex(0)
	-- end
end

function ItemCellCircle:getItemData()
    return self._itemData
end

--设置是否显示数量
function ItemCellCircle:setAmountVisible( type )
    self.showAmountType = type
end

-- --设置是否大ItemCellCircle
-- function ItemCellCircle:setIsBig(isBig)
-- 	self._isBig = isBig
-- end

--直接设设置code的数据
--codeType code类型  使用CodeType里面的枚举 默认是item
function ItemCellCircle:setData(itemCode, amount, codeType, winType)
    codeType = codeType and codeType or CodeType.ITEM 
    self.itemCode = itemCode
    self.codeType = codeType
    self.winType = winType and winType or 0
    
	local img_category = self.view:getChildAutoType("img_category")
    local img_categoryBg = self.view:getChildAutoType("img_categoryBg")
    img_category:setVisible(false)
    img_categoryBg:setVisible(false)
    if codeType == CodeType.SKILL then
        local skillInfo = DynamicConfigData.t_skill[itemCode]
        if skillInfo then
            self._itemData = skillInfo
            local ultSkillurl = ModelManager.CardLibModel:getItemIconByskillId(skillInfo.icon)
            self:setIcon(ultSkillurl) --放了一张技能图片
            self.txtNum:setText("")
        end	
    elseif codeType == CodeType.PASSIVE_SKILL  then
        local skillInfo = DynamicConfigData.t_passiveSkill[itemCode]
        if skillInfo then
            self._itemData = skillInfo
            local passiveUrl = ModelManager.CardLibModel:getItemIconByskillId(skillInfo.icon)
            self:setIcon(passiveUrl) --放了一张技能图片
            self.txtNum:setText("")
        end
    else
        self._itemData =  ItemsUtil.createItemData({data = {code = itemCode, type = codeType}})
		self:setFrame()
		self:setStars()
		self:setItemName()
		local url = ItemConfiger.getItemIconByCode(self._itemData:getItemInfo().code, codeType, self.isCost)
		self:setIcon(url)
		if amount ~= nil then
			self:setAmount(amount)
		end
		local itemInfo= self._itemData:getItemInfo()
		local comCode 	= self._itemData:getItemCode();
		if itemInfo.type==GameDef.ItemType.Other and itemInfo.effect==GameDef.GameResType.Hero then
			self:setHeroInfo()
		elseif itemInfo.type == GameDef.ItemType.HeadBorder then
			self:setHeadBorder()
		elseif itemInfo.type == GameDef.ItemType.Heraldry then
			local extra = self.view:getChildAutoType("extraInfo");
			local c = self.view:getController("extraInfo");
			c:setSelectedIndex(1);
			extra:setText(itemInfo.effectStr)
		else
			--如果是卡牌碎片
			if self._itemData:getItemInfo().category == 4 then
				self:setSplitInfo()
			elseif self._itemData:getItemInfo().category == 8 and comCode >= 80014001 then --如果是精灵碎片
				self:setSplitInfo()
			else
				local splitCtrl = self.view:getController("splitCtrl")
				if splitCtrl then splitCtrl:setSelectedIndex(0) end
			end
		end
    end
end

--设置卡牌信息
function ItemCellCircle:setHeroInfo()
	local level = self.view:getChildAutoType("level")
	-- local splitCtrl = self.view:getController("splitCtrl")
	local img_category = self.view:getChildAutoType("img_category")
	local img_categoryBg = self.view:getChildAutoType("img_categoryBg")
	local starList = BindManager.bindCardStar(self.view:getChildAutoType("cardStar"))
	if level then level:setText("Lv.1") end
	-- if splitCtrl then splitCtrl:setSelectedIndex(2) end
	if starList then starList:setData(self._itemData:getItemInfo().star) end
	local category = ItemConfiger.getHeroCategory (self.itemCode)
	if img_category then 
		img_category:setVisible(category ~= 0)
		img_category:setURL(PathConfiger.getCardCategory(category)) 
	end
	
	if img_categoryBg then img_categoryBg:setVisible(category ~= 0) end
end

function ItemCellCircle:setHeadBorder()
	local url = PathConfiger.getHeadFrame(self._itemData:getItemInfo().code)
	self:setIcon(url)
	self:setAmount(0)
end

function ItemCellCircle:setIcon(url)
	if not url or url == "" then
		self.iconLoader:setVisible(false)
		return
	end
	
	self.iconLoader:setURL(url)

    self.iconLoader:setVisible(true)
end

--物品的数量 数字换成万、亿
function ItemCellCircle:toSectionStr(num, noSimplify)
    local stringAdd = ""
    if not noSimplify then
        if num <= 9999 then
            stringAdd = ""
        elseif num <= 99999999 then
            num = math.floor(num/10000)
            stringAdd = DescAuto[328] -- [328]="万"
        elseif num <= 999999999999 then
            num = math.floor(num/10000000)/10
            stringAdd = DescAuto[329] -- [329]="亿"
        else
            num = math.floor(num/100000000000)/10
            stringAdd = DescAuto[330] -- [330]="万亿"
        end
    end
    return num..stringAdd
end

--设置数量
function ItemCellCircle:setAmount( count )
    if not self.showAmountType then
        return
    end
    if self.txtNum then
        if count>0 then
            self.txtNum:setText(self:toSectionStr(count))
            else
            self.txtNum:setText('')
        end
    end
end

function ItemCellCircle:setItemName()
    if(not self._itemData) then return end
    local itemInfo = self._itemData:getItemInfo()
    if not itemInfo then
        if self.itemName then
            self.itemName:setText("")
        end
        return
    end
    if self.itemName then
        self.itemName:setText(self._itemData:getName())
        if not self.noNameColor then
            self.itemName:setColor(ColorUtil.getItemColor(itemInfo.color))
        end
    end

    if self.nameTextField then 
        self.nameTextField:setText(self._itemData:getName())
        if not self.noNameColor then
            self.nameTextField:setColor(ColorUtil.getItemColor(itemInfo.color))
        end
    end
end

function ItemCellCircle:setStars( ... ) 
	local itemInfo = self._itemData:getItemInfo()
	local comCode  = self._itemData:getItemCode()
	if self.cardStarObj then --如果有星級組件
		self.cardStar= BindManager.bindCardStar(self.cardStarObj)
		local starCount = 0 
		if (itemInfo.type==GameDef.ItemType.Other and itemInfo.effect==GameDef.GameResType.Hero) or 
		itemInfo.type==GameDef.ItemType.OptionalGiftBox or 
		itemInfo.type == GameDef.ItemType.StarReplacement or
		itemInfo.type == GameDef.ItemType.HeroCard then--用于完整卡牌显示/自选礼包
			if self.starCtrl then
				self.starCtrl:setSelectedIndex(1)
			end
			starCount = itemInfo.star
		else
			if itemInfo.category == GameDef.BagType.HeroComponent then --碎片
				if self.starCtrl then
					self.starCtrl:setSelectedIndex(1)
				end
				starCount = itemInfo.star
			elseif itemInfo.category == GameDef.BagType.Equip then --装备 星级从装备表获取
				if self.starCtrl then
					self.starCtrl:setSelectedIndex(1)
				end
				local code = self._itemData:getItemCode()
				starCount = DynamicConfigData.t_equipEquipment[code].staramount
			end
		end 
		self.cardStar:setData(starCount)
		if starCount<=0 then
			if self.starCtrl then
				self.starCtrl:setSelectedIndex(0)
			end
		end
	else
		if self.starList and self.starCtrl then
			local starCount = 0
			if itemInfo.type==GameDef.ItemType.Other and itemInfo.effect==GameDef.GameResType.Hero then--用于完整卡牌显示
				self.starCtrl:setSelectedIndex(1)
				local star = itemInfo.star
				if star=="" then
					star = 0
				end
				local starImg,numStar=ModelManager.CardLibModel:getCurStarIcon(star);
				starCount = numStar
				self.starList:setItemRenderer(function(index,obj)
						local starIcon= obj:getChild("img_star");
						starIcon:setURL(PathConfiger.getCardStar(starImg))--放了卡牌图片
					end
				)
			else
				if itemInfo.category == GameDef.BagType.HeroComponent then
					self.starCtrl:setSelectedIndex(1)
					local star = itemInfo.star
					if star=="" then
						star = 0
					end
					local starImg,numStar=ModelManager.CardLibModel:getCurStarIcon(star);
					starCount = numStar
					self.starList:setItemRenderer(function(index,obj)
							local starIcon= obj:getChild("img_star");
							starIcon:setURL(PathConfiger.getCardStar(starImg))--放了卡牌图片
						end
					)
				elseif itemInfo.category == GameDef.BagType.Equip then --装备 星级从装备表获取
					self.starCtrl:setSelectedIndex(1)
					self.starList:setItemRenderer(function(index,obj)
							local starIcon= obj:getChild("img_star");
						end
					)
					local code = self._itemData:getItemCode()
					starCount = DynamicConfigData.t_equipEquipment[code].staramount
				end
			end
			self.starList:setNumItems(starCount)
			if starCount<=0 then
				self.starCtrl:setSelectedIndex(0)
			end
		end
	end
end

function ItemCellCircle:setClickable(clickAble)
    self._clickAble = clickAble
end

function ItemCellCircle:onClickCell()
    --tips弹出
    --printTable(1,self._itemData)
    if self._clickAble then
        ViewManager.open("ItemTips", {winType = self.winType, codeType = self.codeType, id = self.itemCode, data = self._itemData})
    end
end


function ItemCellCircle:setIcon(url)
    if not url or url == "" then
        self.iconLoader:setVisible(false)
        return
    end
    
    self.iconLoader:setURL(url)

    self.iconLoader:setVisible(true)
end


--根据实际大小 缩放iconLoader 
function ItemCellCircle:adaptIconImg(needAdapt, scale)
    if needAdapt then
        scale = scale or 1
        self.iconLoader:setScale(scale)
    else
        self.iconLoader:setScale(1)
    end
end

function ItemCellCircle:setFrame()
    if(not self._itemData) then return end
    local itemInfo = self._itemData:getItemInfo()
    if not itemInfo then
        if self.itembg then
            self.itembg:setVisible(true)
        end
        return
    end
    if self.itembg then
        self.itembg:setVisible(false)
    end
    
    if self.frameLoader then
        -- self.frameLoader:displayObject():removeChildByTag(100)
        self.frameLoader:setURL("Icon/itemFrame/itemFrameCircle"..itemInfo.color..".png")
        self:addColorEffcet();
    end
end

--设置品质框
function ItemCellCircle:setQualityFrameURL(url)
    if not url then
        url=""
    end
    if self.frameLoader then
        self.frameLoader:setURL(url)
    end
end

function ItemCellCircle:addColorEffcet()
    if(not self._itemData) then return end
    local itemInfo = self._itemData:getItemInfo()
    if itemInfo.color == 5 or itemInfo.color == 6 then
        if (not self.skeletonNode) then
            self.skeletonNode = SpineUtil.createSpineObj(self.frameLoader, vertex2(self.frameLoader:getWidth()/2,self.frameLoader:getHeight()/2), "pingzhikuang_cheng", "Spine/ui/item", "daojupinzhikuang", "daojupinzhikuang",true)
            self.skeletonNode:setScale(0.75)
        end
    elseif (self.skeletonNode) then
        SpineUtil.clearEffect(self.skeletonNode);
        self.skeletonNode = false;
    end
end

function ItemCellCircle:setGrayed(grayed)
    if (grayed) then
        if (self.skeletonNode) then
            SpineUtil.clearEffect(self.skeletonNode);
            self.skeletonNode = false;
        end
    else
        self:addColorEffcet();
    end
    self.view:setGrayed(grayed);
    -- self.frameLoader:setGrayed(grayed);
    -- self.iconLoader:setGrayed(grayed);
end

--退出操作 在close执行之前 
function ItemCellCircle:__onExit()
    -- print(1,"ItemCellCircle __onExit")
--   self:_exit() --执行子类重写
   --[[self:clearEventListeners()
   for k,v in pairs(self.baseCtlView) do
           v:__onExit()
   end--]]
   if (self.skeletonNode) then
        SpineUtil.clearEffect(self.skeletonNode);
        self.skeletonNode = nil;
   end
end

return ItemCellCircle
