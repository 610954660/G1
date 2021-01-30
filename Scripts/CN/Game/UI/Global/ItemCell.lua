--added by xhd
--道具框封裝
local ItemCell = class("ItemCell",BindView)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local FashionConfiger = require "Game.ConfigReaders.FashionConfiger"
local BagType = GameDef.BagType
function ItemCell:ctor(view,noClick)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
	self.noClick = noClick
	self.lockCtrl = false
	self.noNumCtrl = false
	self.frameLoader = false
	self.iconLoader = false
	self.effectLoader = false
	self.selectCtrl = false
	self.doubleShowCtrl = false
	self.starList = false
	self.hookCtrl = false;
	self.nameTextField = false

    
	self.itemCode = 0
	self.codeType = 0 --code的类型 
	self.winType = 0 -- 只是一個标记位 标记是否是从背包打开的item
    --数量label
	self.txtNum = false
	-- --道具数据
	self._itemData = false
	--是否选中
	self.isSelected = false
    --背景
    self.itembg = false
    self.itemName = false
	self._clickAble = true --是否可以点击出tips
	self.showAmountType = true
	self._size = "normal"  --是否大的itemCell
	self.cardStarObj = false
	self.cardStar = false
	self._isCost = false --是否消耗（消耗时货币用扁平图标）
	self._isNoQualityEffect = false --是否隐藏品质特效
	self.noNameColor = false --是否名字颜色不变
	self.emblemBg = false -- 纹章中间层背景
	
	self.receiveFrame=false
	self.hightFrame = false
	self.receiveFrameName=""
	self.hightFrameName =""
	self.lastReceiveFrameName=""
	self.lastHightFrameName =""
end

function ItemCell:init( ... )
	self.lockCtrl = self.view:getController("lockCtrl")
	self.noNumCtrl = self.view:getController("noNumCtrl")
	self.selectCtrl = self.view:getController("select")
	self.doubleShowCtrl = self.view:getController("showDouble")
	self.nameCtrl = self.view:getController("c1")
	self.frameLoader = self.view:getChildAutoType("frameLoader")
	self.iconLoader = self.view:getChildAutoType("iconLoader")
	self.effectLoader = self.view:getChildAutoType("effectLoader")
	self.starList = self.view:getChildAutoType("starList")
	self.txtNum = self.view:getChildAutoType("num")
	self.cardStarObj = self.view:getChildAutoType("cardStar")
	self.emblemBg = self.view:getChildAutoType("emblemBg")
	self.expCtrl = self.view:getController("c3")
	if self.txtNum then
		self.txtNum:setText("")
	end
	self.txtExp = self.view:getChildAutoType("txt_exp")

    self.itembg = self.view:getChildAutoType("cellbg")
    self.itemName = self.view:getChildAutoType("itemName")
	self.starCtrl = self.view:getController("starCtrl")
	self.hookCtrl = self.view:getController("hook");
    if self.itembg then
    	self.itembg:setVisible(false)
	end
	
	self.view:removeClickListener(33)
	if not self.noClick  then
		self.view:addClickListener(function(context)
			if self._clickAble then
				context:stopPropagation()
				self:onClickCell()
			end
		end,33)
	end
end

--道具框清空
function ItemCell:setEmpty(  )
	-- body
end

function ItemCell:getItemData()
	return self._itemData
end

--设置是否显示数量
function ItemCell:setAmountVisible( type )
	self.showAmountType = type
end




--设置是否消耗（消耗时货币用扁平图标）
function ItemCell:setIsCost(isCost)
	self._isCost = isCost
end

--设置是否大itemCell
function ItemCell:setIsBig(isBig)
	if isBig then
		self._size = "big"
	end
end

function ItemCell:setIsMid(isMid)
	if isMid then
		self._size = "mid"
	end
end

--删除特效
function ItemCell:removeAllEffect()
	self.lastReceiveFrameName = self.receiveFrameName
	self.lastHightFrameName = self.hightFrameName
	self.hightFrameName = ""
	self.receiveFrameName = ""
	--下一帧才去删除（如果又加上了，就没必要删了）
	Scheduler.scheduleOnce(0, function()
		if tolua.isnull(self.view) then return end
		if self.receiveFrameName == "" then
			if self.receiveFrame then
				self.receiveFrame:removeFromParent()
				self.receiveFrame = false
			end
		end

		if self.hightFrameName == "" then
			if self.hightFrame then
				self.hightFrame:removeFromParent()
				self.hightFrame = false
			end
		end
	end)
end

-- 纹章的单独处理 配置表中没有星级种族等信息，只能外部传入
function ItemCell:setEmblemData(data)
	if self.effectLoader then
		self:removeAllEffect()
	end
	local conf = DynamicConfigData.t_Emblem[data.code];
	-- self.frameLoader:setURL(PathConfiger.getItemFrame(itemInfo.color, self._size))
	-- local pos = vertex2(self.frameLoader:getWidth()/2,self.frameLoader:getHeight()/2)
	-- if  self._size == "mid" then
	-- 	pos = vertex2(self.frameLoader:getWidth()/2,self.frameLoader:getHeight()/2+10)
	-- end
	if (conf) then
		local icon = string.format("Icon/Emblem/%s.png", conf.icon);
		self:setIcon(icon);
	end
	-- 数量
	if (data.amount) then
		self.txtNum:setText(data.amount);
	else
		self.txtNum:setText("");
	end
	-- 底板
	if self.frameLoader then
		local url = PathConfiger.getItemFrame(data.color, self._size)
		self.frameLoader:setIcon(url);
	end
	-- 中间层
	if self.emblemBg and data.color then
		self.emblemBg:setIcon(string.format("Icon/Emblem/frame%s.png", data.color))
	end
	-- 旋转
	if data.pos then
		local ctrl = self.view:getController("emblemCtrl");
		if (ctrl) then
			ctrl:setSelectedIndex(data.pos);
		end
	end
end

--直接设设置code的数据
--codeType code类型  使用CodeType里面的枚举 默认是item
function ItemCell:setData(itemCode, amount, codeType, winType)
	if (self.emblemBg) then
		self.emblemBg:setURL("")
	end
	if self.effectLoader then
		self:removeAllEffect()
	end
	if itemCode == 0 then
		self:setIcon(nil)
		self.itemCode = false
		self._itemData = false
		return
	end

	codeType = codeType and codeType or CodeType.ITEM 
	self.itemCode = itemCode
	self.codeType = codeType
	self.winType = winType and winType or 0
	if codeType == CodeType.SKILL then
		local skillInfo = DynamicConfigData.t_skill[itemCode]
		if skillInfo then
			self._itemData = skillInfo
			local ultSkillurl = ModelManager.CardLibModel:getItemIconByskillId(skillInfo.icon)
			self:setIcon(ultSkillurl) --放了一张技能图片
			if (self.txtNum) then 
				self.txtNum:setText("") 
			end
		end	
	elseif codeType == CodeType.PASSIVE_SKILL  then
		local skillInfo = DynamicConfigData.t_passiveSkill[itemCode]
		if skillInfo then
			self._itemData = skillInfo
			local passiveUrl = ModelManager.CardLibModel:getItemIconByskillId(skillInfo.icon)
			self:setIcon(passiveUrl) --放了一张技能图片
			if (self.txtNum) then
				 self.txtNum:setText("") 
			end
		end
	else
		-- local ItemBase = require "Game.Modules.Pack.ItemBase"
		self._itemData =  ItemsUtil.createItemData({data = {code = itemCode, type = codeType}})
		
		--如果是纹章道具，又是固定开出某纹章的，icon需要显示成纹章的，tips也要显示成纹章的
		if self._itemData and self._itemData.__itemInfo and self._itemData.__itemInfo.type==28 and self:getEmblemCode(self._itemData.__itemInfo.para) ~= -1 then
			local emblemCode = self:getEmblemCode(self._itemData.__itemInfo.para)
			local config = DynamicConfigData.t_Emblem[emblemCode]
			local emblemData = {code = emblemCode, amount = amount, color = config.rank, pos = config.pos}
			self:setEmblemData(emblemData)
			return
		end
		
		self:setFrame()
		self:setStars()
		self:setItemName()
		local url = ItemConfiger.getItemIconByCode(self._itemData:getItemInfo().code, codeType, self.isCost)
		self:setIcon(url)
		local extraInfoCtrl = self.view:getController("extraInfo");
		extraInfoCtrl:setSelectedIndex(0);
		local splitCtrl = self.view:getController("splitCtrl")
		if splitCtrl then splitCtrl:setSelectedIndex(0) end
		local fashionCtrl = self.view:getController("fashionCtrl")
		if fashionCtrl then fashionCtrl:setSelectedIndex(0) end

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
			extraInfoCtrl:setSelectedIndex(1);
			extra:setText(itemInfo.effectStr)
		else
			--如果是卡牌碎片
			if self._itemData:getItemInfo().category == 4 then
				self:setSplitInfo()
			elseif self._itemData:getItemInfo().category == 8 and comCode >= 80014001 then --如果是精灵碎片
				self:setSplitInfo()
			elseif self._itemData:getItemInfo().category == BagType.Normal and itemInfo.type == GameDef.ItemType.FashioDebris then --时装碎片
				self:setSplitInfo()
			elseif self._itemData:getItemInfo().category == BagType.Fashion and itemInfo.type == GameDef.ItemType.Fashion then --时装道具
				self:setSplitInfo()
			end
		end
	end
end

--设置数据
function ItemCell:setItemData(itemData, codeType, winType)
	if not itemData then
		itemData = false
		return
	end
	if self.effectLoader then
		self:removeAllEffect()
	end
	self.itemCode = itemData:getItemCode()
	codeType = codeType and codeType or itemData:getCodeType() or CodeType.ITEM
	self.codeType = codeType
	self.winType = winType and winType or 0
	--if codeType == CodeType.ITEM then
		self._itemData = itemData
		self:setFrame()
		self:setStars()
		local url = ItemConfiger.getItemIconByCode(self._itemData:getItemInfo().code, codeType, self.isCost)--ItemConfiger.getItemIconByCode(itemData:getItemCode(), itemData:getItemType())
		self:setIcon(url)
		self:setAmount(self._itemData:getItemAmount())
		self:setItemName()
		local fashionCtrl = self.view:getController("fashionCtrl")
		if fashionCtrl then fashionCtrl:setSelectedIndex(0) end
		local itemInfo= self._itemData:getItemInfo()
		local comCode 	= self._itemData:getItemCode();
		if itemInfo.type==GameDef.ItemType.Other and itemInfo.effect==GameDef.ItemType.Other then--卡牌
			self:setHeroInfo()
		elseif itemInfo.type == GameDef.ItemType.HeadBorder then
			self:setHeadBorder()
		elseif itemInfo.type == GameDef.ItemType.Medal then
			self:setIcon(string.format("Icon/medal/%s.png", itemInfo.icon))
		else
			if itemInfo.category == 4 then
				self:setSplitInfo()
			elseif self._itemData:getItemInfo().category == 8 and comCode >= 80014001 or (comCode >= 10000077 and comCode <= 10000078) then --如果是精灵碎片
				self:setSplitInfo()
			elseif itemInfo.category == BagType.Normal and itemInfo.type == GameDef.ItemType.FashioDebris then --时装碎片
				self:setSplitInfo()
			elseif self._itemData:getItemInfo().category == BagType.Fashion and itemInfo.type == GameDef.ItemType.Fashion then --时装道具
				self:setSplitInfo()
			else
				local splitCtrl = self.view:getController("splitCtrl")
				if splitCtrl then splitCtrl:setSelectedIndex(0) end
			end
		end
	--end
end

function ItemCell:setSplitCtrl( index )
	if not index then 
		index = 1
	end
	local splitCtrl = self.view:getController("splitCtrl")
	if splitCtrl then splitCtrl:setSelectedIndex(index) end
end

--设置碎片信息
function ItemCell:setSplitInfo()
	local splitCtrl = self.view:getController("splitCtrl")
	local img_category = self.view:getChildAutoType("img_category")
	local img_categoryBg = self.view:getChildAutoType("img_categoryBg")
	local starList = self.view:getChildAutoType("starList")
	local elvesSplitCtrl = self.view:getController("elvesSplitCtrl")
	local itemInfo= self._itemData:getItemInfo()
	local fashionCtrl = self.view:getController("fashionCtrl")
	if splitCtrl then splitCtrl:setSelectedIndex(1) end
	if starList then starList:setNumItems(self._itemData:getItemInfo().star) end
	local category = ItemConfiger.getSplitCategory (self.itemCode)
	if img_category then 
		img_category:setVisible(category ~= 0)
		img_category:setURL(PathConfiger.getCardCategory(category))
	end
	
	if img_categoryBg then img_categoryBg:setVisible(category ~= 0) end

	if itemInfo.category == BagType.Elf and elvesSplitCtrl then 	-- 如果是精灵碎片 不显示星级
		elvesSplitCtrl:setSelectedIndex(1)
	elseif elvesSplitCtrl then
		elvesSplitCtrl:setSelectedIndex(0)
	end
	if fashionCtrl and (itemInfo.type == GameDef.ItemType.FashioDebris or itemInfo.type == GameDef.ItemType.Fashion)then --时装碎片或时装道具
		fashionCtrl:setSelectedIndex(1)
	elseif fashionCtrl then
		fashionCtrl:setSelectedIndex(0)
	end
end

--设置头像信息
function ItemCell:setHeadBorder()
	local url = PathConfiger.getHeadFrame(self._itemData:getItemInfo().code)
	self:setIcon(url)
	self:setAmount(0)
end

--设置卡牌信息
function ItemCell:setHeroInfo()
	local level = self.view:getChildAutoType("level")
	local splitCtrl = self.view:getController("splitCtrl")
	local img_category = self.view:getChildAutoType("img_category")
	local img_categoryBg = self.view:getChildAutoType("img_categoryBg")
	local starList = self.view:getChildAutoType("starList")
	if level then level:setText("Lv.1") end
	if splitCtrl then splitCtrl:setSelectedIndex(2) end
	if starList then starList:setNumItems(self._itemData:getItemInfo().star) end
	local category = ItemConfiger.getHeroCategory (self.itemCode)
	if img_category then 
		img_category:setVisible(category ~= 0)
		img_category:setURL(PathConfiger.getCardCategory(category)) 
	end
	
	if img_categoryBg then img_categoryBg:setVisible(category ~= 0) end
end

--物品的数量 数字换成万、亿
function ItemCell:toSectionStr(num, noSimplify)
	local stringAdd = ""
	if not noSimplify then
		if num <= 99999 then
			stringAdd = ""
		elseif num <= 99999999 then
			num = math.floor(num/10000)
			stringAdd = Desc.common_w
		elseif num <= 999999999999 then
			num = math.floor(num/10000000)/10
			stringAdd = Desc.common_y
		else
			num = math.floor(num/100000000000)/10
			stringAdd = Desc.common_wy
		end
	end
	return num..stringAdd
end
--设置数量
function ItemCell:setAmount( count,needCount)
	if not self.showAmountType then
		if self.noNumCtrl then
			self.noNumCtrl:setSelectedIndex(1)
		end
		return
	end
    --[[--如果是符文 统一不要数量
    if self._itemData:getItemInfo().category == 5 then
    	if self.noNumCtrl then
			self.noNumCtrl:setSelectedIndex(1)

		end
		self.txtNum:setText('')
		return
    end--]]
    
    if self.txtNum then
		if needCount then
			self.txtNum:setText(string.format("%s/%s",self:toSectionStr(count),self:toSectionStr(needCount)))
			self.txtNum:setColor(count >= needCount and ColorUtil.textColor.green or ColorUtil.textColor.red)
        else
			if count>0 then
				self.txtNum:setText(self:toSectionStr(count))
			else
				self.txtNum:setText('')
			end
        end
    end
    --只有碎片特殊 设置进度
	local progress = self.view:getChildAutoType("progressBar")
	local itemInfo = self._itemData:getItemInfo()
	local comCode 	= self._itemData:getItemCode()
	if progress then
		if itemInfo.category == BagType.HeroComponent then 	
			local max = DynamicConfigData.t_heroCombine[self.itemCode].amount
			progress:setMax(max)
			progress:setValue(count)
		elseif itemInfo.category == BagType.Elf and comCode >= 80014001 or (comCode >= 10000077 and comCode <= 10000078)  then -- 精灵碎片
			local max = DynamicConfigData.t_ElfCombine[self.itemCode].amount
			progress:setMax(max)
			progress:setValue(count)
		elseif itemInfo.category == BagType.Normal and itemInfo.type == GameDef.ItemType.FashioDebris then --皮肤碎片
			local fashionComposeConfig = FashionConfiger.getFashionComposeConfigerByFashionId(self._itemData:getItemInfo().effect)
			local consume = fashionComposeConfig.consume[1]
			local max = consume and consume.amount
			progress:setMax(max)
			progress:setValue(count)
		end
	end
	
end

function ItemCell:setExpNum(str)
	self.txtExp:setText(str)
end

function ItemCell:setAmountStr(str)--秘武升级材料为零的时候显示文字
	self.txtNum:setText(str)
end

function ItemCell:setStars( ... ) 
	local itemInfo = self._itemData:getItemInfo()
	local comCode  = self._itemData:getItemCode()
	if self.cardStarObj then --如果有星級組件
		self.cardStar= BindManager.bindCardStar(self.cardStarObj)
		local starCount = 0 
		if self.starCtrl then
			self.starCtrl:setSelectedIndex(1)
		end
				
		if itemInfo.category == BagType.Equip then --装备 星级从装备表获取
				local code = self._itemData:getItemCode()
				starCount = DynamicConfigData.t_equipEquipment[code].staramount
		else
			starCount = itemInfo.star
		end
		--[[if (itemInfo.type==GameDef.ItemType.Other and itemInfo.effect==GameDef.GameResType.Hero) or 
		itemInfo.type==GameDef.ItemType.OptionalGiftBox or 
		itemInfo.type == GameDef.ItemType.StarReplacement or
		itemInfo.type == GameDef.ItemType.HeroCard then--用于完整卡牌显示/自选礼包
			if self.starCtrl then
				self.starCtrl:setSelectedIndex(1)
			end
			starCount = itemInfo.star
			-- local star = itemInfo.star
			-- if star=="" then
			-- 	star = 0
			-- end
			-- local starImg,numStar=ModelManager.CardLibModel:getCurStarIcon(star);
			-- starCount = numStar
		else
			if itemInfo.category == BagType.HeroComponent then --碎片
				if self.starCtrl then
					self.starCtrl:setSelectedIndex(1)
				end
				starCount = itemInfo.star
				-- local star = itemInfo.star
				-- if star=="" then
				-- 	star = 0
				-- end
				-- local starImg,numStar=ModelManager.CardLibModel:getCurStarIcon(star);
				-- starCount = numStar
			-- elseif itemInfo.category == BagType.Elf and comCode >= 80014001 then 
			-- 	if self.starCtrl then
			-- 		self.starCtrl:setSelectedIndex(1)
			-- 	end
			-- 	starCount = itemInfo.star
			elseif itemInfo.category == BagType.Equip then --装备 星级从装备表获取
				if self.starCtrl then
					self.starCtrl:setSelectedIndex(1)
				end
				
				local code = self._itemData:getItemCode()
				starCount = DynamicConfigData.t_equipEquipment[code].staramount
			end
		end --]]
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
				if itemInfo.category == BagType.HeroComponent then
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
				elseif itemInfo.category == BagType.Equip then --装备 星级从装备表获取
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

function ItemCell:setClickable(clickAble)
	self._clickAble = clickAble
end

--是否固定开出某纹章的物品（带随机的不算）
function ItemCell:getEmblemCode(para)
	local codeStr = ""
	for i = 1,3 do
		if not para[i] or para[i] == -1 then
			return -1
		end
		codeStr = codeStr..para[i]
	end
	return tonumber(codeStr)
end


function ItemCell:onClickCell(forceClick)
    --tips弹出
	--
    printTable(1,self._itemData)
	if self._clickAble or forceClick then
		if self.winType =="bag" or self.winType =="rune" or self.winType == "elves" then
			ViewManager.close("ItemTipsBagView")
			ViewManager.open("ItemTipsBagView", {winType = self.winType, codeType = self.codeType, id = self.itemCode, data = self._itemData})
		else
			if self._itemData and self._itemData.__data and self._itemData.__data.type==4 then
				local itemCode=self._itemData.__data.code
				local cardData = DynamicConfigData.t_hero[tonumber(itemCode)]
				if not cardData then
					return
				end
				local categoryHeros = DynamicConfigData.t_HeroTotems[cardData.category]
				local _cardInfoList = {}
				for _,v in pairs(categoryHeros) do
					if  tonumber(itemCode)==v.hero then
						table.insert(_cardInfoList, v)
					end
				end
				ViewManager.open("HeroInfoView",{index = 1,heroId =tonumber(itemCode),heroList = _cardInfoList })
			elseif self._itemData and self._itemData.__itemInfo and self._itemData.__itemInfo.type==28 and self:getEmblemCode(self._itemData.__itemInfo.para) ~= -1 then
				--如果是纹章道具，又是固定开出某个纹章的，显示纹章的tips
				local emblemCode = self:getEmblemCode(self._itemData.__itemInfo.para)
				local config = DynamicConfigData.t_Emblem[emblemCode]
				local emblemData = {star = 0, code = emblemCode, exp = 0, category = 0, pos = config.pos, color = config.rank}
				ViewManager.open("EmblemCompareView", {data = emblemData, winType = "tips"})
			elseif self._itemData and self._itemData.__itemInfo and self._itemData.__itemInfo.category == 13 and self._itemData.__itemInfo.type==35 then --时装道具
				local info = {}
				info.isSpecialShow = true
				info.fashionId = self.itemCode
				ViewManager.open("FashionShopTipsView", {fashionInfo = info})
			else
				if self._itemData and self._itemData.getItemInfo and self._itemData:getItemInfo().type==19 then --自选礼包特殊处理
					ViewManager.open("ItemSpeTipsView", {data = self._itemData})
				else
					ViewManager.open("ItemTips", {winType = self.winType, codeType = self.codeType, id = self.itemCode, data = self._itemData})
				end
				
			end
		end
		
	end
end


function ItemCell:setIcon(url)
	if not url or url == "" then
		self.iconLoader:setVisible(false)
		return
	end
	
	self.iconLoader:setURL(url)

    self.iconLoader:setVisible(true)
end


--根据实际大小 缩放iconLoader 
function ItemCell:adaptIconImg(needAdapt, scale)
    if needAdapt then
        scale = scale or 1
        self.iconLoader:setScale(scale,scale)
    else
        self.iconLoader:setScale(1)
    end
end

function ItemCell:setFrame()
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
    	self.frameLoader:setURL(PathConfiger.getItemFrame(itemInfo.color, self._size))
    	local pos = vertex2(self.frameLoader:getWidth()/2,self.frameLoader:getHeight()/2)
	    if  self._size == "mid" then
	    	pos = vertex2(self.frameLoader:getWidth()/2,self.frameLoader:getHeight()/2+10)
	    end
	    --只有紅色 橙色才有特效
	    if itemInfo.color == 5 or itemInfo.color == 6 then
			self.hightFrameName = "pingzhikuang_cheng"
	       if not self.hightFrame or self.hightFrameName ~= self.lastHightFrameName then
				if self.hightFrame and not tolua.isnull(self.hightFrame) then
					self.hightFrame:removeFromParent()
				end
				if not self._isNoQualityEffect then
				   self.hightFrame = SpineUtil.createSpineObj(self.effectLoader, vertex2(self.frameLoader:getWidth()/2,self.frameLoader:getHeight()/2), self.hightFrameName, "Spine/ui/item", "daojupinzhikuang", "daojupinzhikuang",true)
				   if self._size == "mid" then
					  self.hightFrame:setScale(0.8)
				   end
				end
	       end
	    end
    end
end

--设置可领取状态
function ItemCell:setReceiveFrame(show)
	if show then
		self.receiveFrameName = "pingzhikuang_hong"
		if not self.receiveFrame or self.receiveFrameName ~= self.lastReceiveFrameName then
			if self.receiveFrame then 
				self.receiveFrame:removeFromParent()
			end
			self.receiveFrame = SpineUtil.createSpineObj(self.effectLoader, vertex2(self.frameLoader:getWidth()/2,self.frameLoader:getHeight()/2), self.receiveFrameName, "Spine/ui/item", "daojupinzhikuang", "daojupinzhikuang",true)
			if not self._size == "big" then
				self.receiveFrame:setScale(0.7)
			end
		end
	else
		if  self.receiveFrame then
			self.receiveFrame:removeFromParent()
		end
		self.receiveFrameName = ""
		self.receiveFrame=false
	end
end



function ItemCell:setItemName()
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

--设置品质框
function ItemCell:setQualityFrameURL(url)
	if not url then
		url=""
	end
	if self.frameLoader then
		self.frameLoader:setURL(url)
	end
end

--设置不显示背景
function ItemCell:setNoFrame(isNoFrame)
	if self.frameLoader then
		self.frameLoader:setVisible(not isNoFrame)
	end
end

--设置不显示特效
function ItemCell:setNoQualityNoeffect(isNoFrame)
	self._isNoQualityEffect = isNoFrame
	--if self.effectLoader then
	--	self.effectLoader:setVisible(not isNoFrame)
	--end
end

--设置是否锁定
function ItemCell:setIsLock(isLock)
	self.lockCtrl:setSelectedIndex(isLock and 1 or 0)
end

--获取是否锁定
function ItemCell:getIsLock()
	return self.lockCtrl:getSelectedIndex() == 1
end

--设置是否选中
function ItemCell:setIsSelected(isLock)
	if not self.selectCtrl then
		return
	end
	self.selectCtrl:setSelectedIndex(isLock and 1 or 0)
end

--获取是否选中
function ItemCell:getIsSelected()
	if not self.selectCtrl then
		return false
	end
	return self.selectCtrl:getSelectedIndex() == 1
end

-- 设置是否勾选
function ItemCell:setIsHook(isHook)
	self.hookCtrl:setSelectedIndex(isHook and 1 or 0)
end

--设置是否显示名字
function ItemCell:setIsShowName(isShow)
	self.nameCtrl:setSelectedIndex(isShow and 1 or 0)
end

--设置是否显示经验底
function ItemCell:setIsShowExp(isShow)
	self.expCtrl:setSelectedIndex(isShow and 1 or 0)
end

--设置是否显示框体
function ItemCell:setFrameVisible(bool)
	if not self.selectCtrl then
		return
	end
	self.selectCtrl:setSelectedIndex(bool and 1 or 0)
end


--设置是否显示双倍
function ItemCell:setShowDouble(bool)
	if not self.doubleShowCtrl then
		return
	end
	self.doubleShowCtrl:setSelectedIndex(bool and 1 or 0)
end

--设置文本框
function ItemCell:setNameTextField(nameTextField)
	self.nameTextField = nameTextField
end

--设置名字颜色是否不随质量改变
function ItemCell:setSkipNameColor(skipNameColor)
	self.noNameColor = skipNameColor
end

--退出操作 在close执行之前 
function ItemCell:__onExit()
     print(086,"ItemCell __onExit")
--   self:_exit() --执行子类重写
   --[[self:clearEventListeners()
   for k,v in pairs(self.baseCtlView) do
   		v:__onExit()
   end--]]
end

return ItemCell