--背包道具tips
--added by xhd
local ItemTipsBagView = class("ItemTipsBagView",View)
local ItemCell = require "Game.UI.Global.ItemCell"
local  HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local FashionConfiger = require "Game.ConfigReaders.FashionConfiger"

function ItemTipsBagView:ctor( ... )
	self._packName = "ToolTip"
    self._compName = "ItemTipsView_Bag"
    self._rootDepth = LayerDepth.PopWindow
	
	self.data = self._args
	self.codeType = self._args.codeType
	self.itemData = self._args.data
	self.winType = self._args.winType and self._args.winType or false
	self.viewListHead = false
	self.viewListMid = false
	self.itemTypeCtrl = false
	self.btn_laiyuan = false
	self.btn_laiyuanLong = false
	self.btn_shiyong = false
	self.btn_shiyongLong = false
	self.btn_decompose = false
	self.btn_sell = false
	self.btn_hecheng = false
	self.btn_chuandai = false
	self.btn_rebuild = false; -- 重铸
	self.btn_fenjieSmall = false;
end


-- [子类重写] 初始化UI方法
function ItemTipsBagView:_initUI( ... )
	self.viewListHead = self.view:getChildAutoType("infoPanel/viewListHead")
	self.viewListMid = self.view:getChildAutoType("infoPanel/viewListMid")
	self.itemTypeCtrl = self.view:getController("itemTypeCtrl")
	self.btn_laiyuan = self.view:getChildAutoType("btn_laiyuan")
	self.btn_laiyuanLong = self.view:getChildAutoType("btn_laiyuanLong")
	self.btn_shiyong = self.view:getChildAutoType("btn_shiyong")
	self.btn_shiyongLong = self.view:getChildAutoType("btn_shiyongLong")
	self.btn_decompose = self.view:getChildAutoType("btn_decompose")
	self.btn_sell = self.view:getChildAutoType("btn_sell")
	self.btn_sell2 = self.view:getChildAutoType("btn_sell2")
	self.btn_hecheng = self.view:getChildAutoType("btn_hecheng")
	self.btn_hecheng2 = self.view:getChildAutoType("btn_hecheng2")
	self.btn_chuandai = self.view:getChildAutoType("btn_chuandai")
	self.btn_rebuild = self.view:getChildAutoType("btn_rebuild");
	self.btn_fenjieSmall = self.view:getChildAutoType("btn_fenjieSmall");

	local itemInfo = self.itemData:getItemInfo()
	if itemInfo.category == GameDef.Category.Normal or itemInfo.category == GameDef.Category.Special or itemInfo.category == GameDef.Category.HeroComponent then
		self:addItemHead()
		self:addDesc(Desc.itemtips_itemDesc, self.itemData:getDescStr())
		self:addBtnPanel()
	elseif itemInfo.category == GameDef.Category.Rune then
		self:addItemHead()
        self:addRuneAttr()
        self:addBtnPanel()
	elseif itemInfo.category == GameDef.Category.Equipment then
		self:addEquipHead()
		self:addEquipAttr()
		self:addEquipSuitAttr()
		--self:addEquipSkill()
		self:addDesc(Desc.itemtips_itemDesc, self.itemData:getDescStr())
		self:addBtnPanel()
	elseif itemInfo.category == GameDef.Category.Jewelry then
		self:addJewelryHead()
		self:addJewelryAttr()
		self:addBtnPanel();
	elseif itemInfo.category == GameDef.Category.Elf then
		self:addItemHead()
		-- self:addJewelryAttr();
		self:addDesc(Desc.itemtips_itemDesc, self.itemData:getDescStr())
		self:addBtnPanel();
	end

	self:updateSize()
end


--添加物品头
function ItemTipsBagView:addItemHead()
	local ItemTipsItemHead = require "Game.Modules.Tips.ItemTipsItemHead"
	local head = ItemTipsItemHead.new({parent = self.viewListHead, data=self.itemData,winType="bag"})
	head:toCreate()
end

function ItemTipsBagView:addEquipHead()
	local ItemTipsEquipHead = require "Game.Modules.Tips.ItemTipsEquipHead"
	local head = ItemTipsEquipHead.new({parent = self.viewListHead, data=self.itemData,winType="bag"})
	head:toCreate()
end


function ItemTipsBagView:addEquipAttr()
	local ItemTipsEquipAttr = require "Game.Modules.Tips.ItemTipsEquipAttr"
	local head = ItemTipsEquipAttr.new({parent = self.viewListMid, data=self.itemData,winType="bag"})
	head:toCreate()
end

function ItemTipsBagView:addEquipSuitAttr()--套装属性
	 local itemInfo = self.itemData:getItemInfo()
    local info = DynamicConfigData.t_equipEquipment[itemInfo.code]
    local taozhuang = DynamicConfigData.t_equipsuit[info.color]
    if taozhuang then
        taozhuang = taozhuang[info.staramount]
        if not taozhuang then
            taozhuang = {}
        end
    else
        taozhuang = {}
    end
	if #taozhuang > 0 then
		local ItemTipsEquipSuitAttr = require "Game.Modules.Tips.ItemTipsEquipSuitAttr"
		local head = ItemTipsEquipSuitAttr.new({parent = self.viewListMid, data=self.itemData,winType="bag"})
		head:toCreate()
	end
end

function ItemTipsBagView:addRuneAttr()
	local ItemTipsRuneAttr = require "Game.Modules.Tips.ItemTipsRuneAttr"
	local head = ItemTipsRuneAttr.new({parent = self.viewListMid, data=self.itemData,winType="bag"})
	head:toCreate()
end

function ItemTipsBagView:addEquipSkill()
	local uuid = self.itemData:getUuid()
	local skilldata = EquipmentModel:getSkillData(uuid)
	if skilldata then
		local ItemTipsEquipSkill = require "Game.Modules.Tips.ItemTipsEquipSkill"
		local head = ItemTipsEquipSkill.new({parent = self.viewListMid, data=self.itemData})
		head:toCreate()
	end
end

function ItemTipsBagView: addJewelryAttr()
	local itemData = self.itemData.__data;
	local jewelryData = itemData.specialData.jewelry;
	local data = jewelryData;
	if data then
		local ItemTipsJewelryAttr = require "Game.Modules.Tips.ItemTipsJewelryAttr"
		local head = ItemTipsJewelryAttr.new({parent = self.viewListMid, data=data})
		head:toCreate()
	end
end

function ItemTipsBagView: addJewelryHead()
	-- local itemData = self.itemData.__data;
	-- local jewelryData = itemData.specialData.jewelry;
	-- local data = jewelryData;
	if self.itemData then
		local ItemTipsJewelryAttr = require "Game.Modules.Tips.ItemTipsJewelryHead"
		local head = ItemTipsJewelryAttr.new({parent = self.viewListMid, data=self.itemData})
		head:toCreate()
	end
end

function ItemTipsBagView:addBtnPanel()
	
	-- 来源
	local laiyuanFunc = function ()
		local itemInfo = self.itemData:getItemInfo()
		ViewManager.open("ItemNotEnoughView", {type = 3, code = itemInfo.code, amount = 1})
		ViewManager.close("ItemTipsBagView")
	end
	self.btn_laiyuan:removeClickListener(33)
	self.btn_laiyuan:addClickListener(laiyuanFunc, 33)
	self.btn_laiyuanLong:removeClickListener(33)
	self.btn_laiyuanLong:addClickListener(laiyuanFunc,33)

	--使用按钮
	local shiyongFunc = function ( ... )
	    print(1,"使用按钮被点击")
	    if self.winType =="rune" then
	    	Dispatcher.dispatchEvent("rune_changePage")
	    	ViewManager.close("ItemTipsBagView")
	    	return
	    end
		local itemInfo = self.itemData:getItemInfo()
		if itemInfo.type == GameDef.ItemType.ElfSkin then
			local code = self.itemData:getItemCode()
			local data = self.itemData:getData()
			local haveElfSkin = ElvesSystemModel:checkSkinById(code)
			local skinInfo 	= ElvesSystemModel:getSkinInfoBySkinId(code)
			local haveElf 	= ElvesSystemModel:isHaveElvesById(skinInfo.elfId)
			if not haveElf then 	-- 精灵不存在
				RollTips.show(Desc.ElvesSystem_pleaseActivate)
				return
			end
			ElvesSystemModel:reqElfAchieveSkin(data.uuid,code,skinInfo.elfId)
			ViewManager.close("ItemTipsBagView")
			return
		end

		if itemInfo.useType == 1 or itemInfo.useType == 3 then
			--直接使用一个，调用使用接口
			local params = {}
			 params.bagType =self.itemData:getBagType()
			 params.itemId = self.itemData:getItemId()
			 params.amount = 1
			 params.onSuccess = function( res )
				print(1,res)
			 end
			 RPCReq.Bag_UseItem(params, params.onSuccess)
		elseif itemInfo.useType == 2 or itemInfo.useType == 5 then
			if itemInfo.type == GameDef.ItemType.OptionalGiftBox then
				ViewManager.open("ItemTipsOptionalGiftBox", self.itemData)
			elseif itemInfo.type == GameDef.ItemType.OptionalGiftGroup then
				ViewManager.open("ItemTipsOptionalGiftBox2", self.itemData)
			else
				ViewManager.open("ItemTipsItemUseView", self.itemData)
			end
		elseif itemInfo.useType == 4 then
			--特殊处理 门票打开竞技场
			if itemInfo.jump~="" then
				--if itemInfo.type == GameDef.ItemType.ElfComponent then -- 精灵狗粮
				--	Dispatcher.dispatchEvent(EventType.ElvesSystemBaseView_setPage,{page = 1})
			--else
				if itemInfo.type ==  GameDef.ItemType.HeroTicket then --召唤券
					if self.itemData:getItemCode() ==10000004 then --普通GetCard
						ModuleUtil.openModule(ModuleId.GetCard,true,{page=1})
					elseif self.itemData:getItemCode() ==10000005 then--高级
						ModuleUtil.openModule(ModuleId.GetCard,true,{page=2})
					elseif self.itemData:getItemCode() ==10000053 then--特异
						ModuleUtil.openModule(ModuleId.GetCard,true,{page=3})
					elseif self.itemData:getItemCode() ==10000070 then--仙魔
						local tips=ModuleUtil.moduleOpen(138,false)
						if not tips then
						   RollTips.show(Desc.itemtips_text1)
						   return
						end
						ModuleUtil.openModule(ModuleId.GetCard,true,{page=7})
					else
						ModuleUtil.openModule(itemInfo.jump,true)
					end
				else
					ModuleUtil.openModule(itemInfo.jump,true)
				end
			elseif self.itemData:getItemCode() ==10000006 then
				ModuleUtil.openModule(ModuleId.Hero)
			elseif self.itemData:getItemCode() ==10000007 then
				ModuleUtil.openModule(ModuleId.Hero)
			elseif self.itemData:getItemCode() ==10000014 then
				ModuleUtil.openModule(ModuleId.Arena)
			elseif (self.itemData:getItemCode() >=10000008 and self.itemData:getItemCode() <=10000012) or (self.itemData:getItemCode() >=10000017 and self.itemData:getItemCode() <=10000020) then
				ModuleUtil.openModule(ModuleId.Hero)
			elseif self.itemData:getItemCode() ==10000013 then
				ModuleUtil.openModule(ModuleId.Hero)
			elseif self.itemData:getItemCode() ==10000021 then
				ModuleUtil.openModule(ModuleId.Maze)
		   	elseif self.itemData:getItemCode() >=20001101 and self.itemData:getItemCode() <=20004227 then
				ModuleUtil.openModule(ModuleId.Hero)
			elseif itemInfo.type ==  GameDef.ItemType.HeroTicket then --召唤券
				if self.itemData:getItemCode() ==10000004 then --普通GetCard
					ModuleUtil.openModule(ModuleId.GetCard,true,{page=1})
				elseif self.itemData:getItemCode() ==10000005 then--高级
					ModuleUtil.openModule(ModuleId.GetCard,true,{page=2})
				elseif self.itemData:getItemCode() ==10000053 then--特异
					ModuleUtil.openModule(ModuleId.GetCard,true,{page=3})
				end
			elseif itemInfo.type == GameDef.ItemType.FairyLandItem then
				--秘境随机道具
				ModuleUtil.openModule(ModuleId.FairyLand.id)
			elseif itemInfo.type == GameDef.ItemType.FairyLandItemEx then
				--秘境手动道具
				ModuleUtil.openModule(ModuleId.FairyLand.id, true, {type = GameDef.ItemType.FairyLandItemEx})
			end
		else
			if itemInfo.category == GameDef.Category.Equipment then
				ModuleUtil.openModule(ModuleId.Hero)
			end
		end
		ViewManager.close("ItemTipsBagView")
	end
	-- 使用
	self.btn_shiyong:removeClickListener(33)
	self.btn_shiyong:addClickListener(shiyongFunc,33)
	self.btn_shiyongLong:removeClickListener(33)
	self.btn_shiyongLong:addClickListener(shiyongFunc,33)
	-- 使用
	self.btn_sell:removeClickListener(33)
	self.btn_sell:addClickListener(function()
		ViewManager.open("ItemTipsItemSellView",self.itemData)
	end,33)
	self.btn_sell2:removeClickListener(33)
	self.btn_sell2:addClickListener(function()
		ViewManager.open("ItemTipsItemSellView",self.itemData)
	end,33)

	--合成按钮
	local hechengfunc = function ( ... )
		-- printTable(8848,"self.itemData",self.itemData)
		local itemInfo 	= self.itemData:getItemInfo()
		local comCode 	= self.itemData:getItemCode();
		local _hasNum 	= self.itemData:getItemAmount();
		local itemCom   = {}
		local _needNum=0

		if self.itemData:getBagType() == GameDef.BagType.Elf then
			if comCode >= 80014001 or ( comCode >= 10000077 and comCode <= 10000078 )then 
				-- 先判断碎片数量 数量不足直接弹提示
				itemCom = DynamicConfigData.t_ElfCombine[comCode]
				if itemCom then
					_needNum=itemCom.amount;
				end
				if _hasNum<_needNum then
					RollTips.show(Desc.ElvesSystem_noEnoughChips)
					return 
				end
				-- 判断精灵存在，提示已拥有该精灵
				local isHave = ModelManager.ElvesSystemModel:isHaveElvesById(itemInfo.icon,true)
				print(8848,">>>>>>>itemInfo.icon>>>",itemInfo.icon,">>>>isHave>>>",isHave)
				if isHave then
					RollTips.show(Desc.ElvesSystem_isHaveElves)
					return
				end
				-- 正常执行合成
				ViewManager.open("ElvesSyntheticView",self.itemData)
				ViewManager.close("ItemTipsBagView")
			end
			return;
		end

		if self.itemData:getBagType() == GameDef.BagType.Jewelry then
			ViewManager.open("EquipmentforgeView", {page = "JewelryMergeView"})
			return;
		elseif self.itemData:getBagType() == GameDef.BagType.Jewelry then --水晶合成
			ViewManager.open("forgeView", {page = 3})
			return;
		elseif itemInfo.category == GameDef.BagType.Normal and itemInfo.type == GameDef.ItemType.FashioDebris then 	--时装合成
			local fashionComposeConfig = FashionConfiger.getFashionComposeConfigerByFashionId(self.itemData:getItemInfo().effect)
			local consume = fashionComposeConfig.consume[1]
			if consume then 
				_needNum = consume.amount
			end
			if _hasNum < _needNum then
				RollTips.show(DescAuto[322]) -- [322]='数量不足,无法合成'
			elseif _hasNum >= _needNum then
				ViewManager.open("CardCombineSureView",self.itemData)
			end
			return
		end

		itemCom = DynamicConfigData.t_heroCombine[comCode] 
		if itemCom then
			_needNum=itemCom.amount;
		end
		
		printTable(8,"合成按钮被点击",self.itemData,_hasNum,_needNum)
			
		if _hasNum<_needNum then
			RollTips.show(DescAuto[322]) -- [322]='数量不足,无法合成'
		elseif _hasNum >=_needNum then
			if itemInfo.useType == 1 then --只合成一组
				ModelManager.CardLibModel:combineCard(comCode,1)
			else
				--可以选择合成多少组(至少要能合成一组才打开窗口)
				if self.itemData:getItemInfo().type == GameDef.ItemType.CrystalUpgrade then --这个是水晶碎片
					ViewManager.open("CrystalCombineView",self.itemData)
				else
					ViewManager.open("CardCombineSureView",self.itemData)
				end
			end
		end
		--ViewManager.close("ItemTipsBagView")
	end
	self.btn_hecheng:removeClickListener(33)
	self.btn_hecheng:addClickListener(hechengfunc,33)
	self.btn_hecheng2:removeClickListener(33)
	self.btn_hecheng2:addClickListener(hechengfunc,33)

	-- 穿戴
	self.btn_chuandai:removeClickListener(33)
	self.btn_chuandai:addClickListener(shiyongFunc,33)

	-- 重铸
	self.btn_rebuild:removeClickListener(33)
	self.btn_rebuild:addClickListener(function ()
		if self.itemData:getBagType() == GameDef.BagType.Jewelry then
			ViewManager.open("EquipmentforgeView", {page = "JewelryRebuildView"})
			Scheduler.scheduleNextFrame(function ()
				Dispatcher.dispatchEvent("jewelry_rebuildChoose", self.itemData:getUuid())
			end)
			return;
		end
	end, 33)

	local fenjieFunc = function ()
		if self.itemData:getType() == GameDef.ItemType.PassiveSkillBook then
			local code = self.itemData:getItemCode();
			local name = self.itemData:getName();
			local decompose = DynamicConfigData.t_item[code].decompose[1];
			local decomPoseName = DynamicConfigData.t_item[decompose.code].name;
			local info = {
			text = string.format(Desc.itemtips_text2, name, decomPoseName, decompose.amount),
				title = Desc.itemtips_text3,
				type = "yes_no",
				onYes = function ()
					local d = {type=GameDef.GameResType.Item, code = code, amount = 1};
					local bag = PackModel:getNormalBag()
					bag:decompose({[1]=d}, function ()
						if (bag:getAmountByCode(code) <= 0 and not tolua.isnull(self.view)) then
							self:closeView();
						end
					end)
					ViewManager.close("ItemTipsBagView")
				end
			}
			Alert.show(info);
		elseif self.itemData:getBagType() == GameDef.BagType.Jewelry then
			local uuid = self.itemData:getUuid();
			local code = self.itemData:getItemCode();
			print(2233, "===== 饰品分解 ====", uuid);
			local get = DynamicConfigData.t_item[code].decompose[1].amount
			local info = {
				text = string.format(Desc.Jewelry_decompose, get),
				title = Desc.itemtips_text3,
				type = "yes_no",
				onYes = function ()
					JewelryModel:decompose(uuid)
					ViewManager.close("ItemTipsBagView")
				end
			}
			Alert.show(info);
			return;
		elseif self.itemData:getBagType() == GameDef.BagType.Rune then --符文分解
			local code = self.itemData:getItemCode()
			local cost = DynamicConfigData.t_Rune[code].decomCost
			local decomProduct =  DynamicConfigData.t_Rune[code].decomProduct
			local lastCode = decomProduct[1].code
			local lastItemConfig = DynamicConfigData.t_item[tonumber(lastCode)]
			local decomAmount = decomProduct[1].amount
			local info = {
				text = string.format(Desc.Rune_txt41,self.itemData:getName(),decomAmount,lastItemConfig.name),
				title = Desc.itemtips_text3,
				type = "yes_no",
				cost = cost,
				costTxt = Desc.itemtips_text4,
				onYes = function ()
					-- JewelryModel:decompose(uuid)
					local params = {}
					params.itemUuid = self.itemData:getUuid()
					params.onSuccess = function( res )
						self:closeView()
					end
					RPCReq.Rune_Decom(params, params.onSuccess)
				end
			}
			Alert.show(info);
		elseif self.itemData:getBagType() == GameDef.BagType.Equip then --装备分解
			local uuid = self.itemData:getUuid();
			ViewManager.open("EquipmentUpstarView",{uuid = uuid})
			ViewManager.close("ItemTipsBagView")
		elseif self.itemData:getType() == GameDef.ItemType.ElfSkin then -- 精灵皮肤分解
			local code = self.itemData:getItemCode()
			local itemInfo = self.itemData:getItemInfo()
			local decompose = itemInfo.decompose[1]
			local reqInfo={
				{
					bagType = self.itemData:getBagType(),
					itemId  = self.itemData:getItemId(),             
					amount  = self.itemData:getItemAmount(),     
				}   
			}
			local info = {
				text 	= string.format(Desc.ElvesSystem_skinDecompose,ItemConfiger.getItemNameByCode(decompose.code),decompose.amount),
				title 	= Desc.itemtips_text3,
				type 	= "yes_no",
				onYes 	= function ()
						-- ElvesSystemModel:reqElfDecomposeSkin(code)
						-- printTable(8848,">>>reqInfo>>>",reqInfo)
						ElvesSystemModel:reqElfDecomposeSkin2(reqInfo)
						ViewManager.close("ItemTipsBagView")
				end
			}
			Alert.show(info);
		end
	end

	-- 分解
	self.btn_fenjieSmall:removeClickListener(33)
	self.btn_fenjieSmall:addClickListener(fenjieFunc, 33)

	self.btn_decompose:removeClickListener(33)
	self.btn_decompose:addClickListener(fenjieFunc, 33)
	self.btn_shiyongLong:setVisible(true)
	if self.itemData:getBagType() == GameDef.BagType.Normal or self.itemData:getBagType() == GameDef.BagType.Special   then
		local itemInfo = self.itemData:getItemInfo()
		local itemData = self.itemData:getData()
		local code = self.itemData:getItemCode();
		local haveElfSkin = false -- 标记有没有精灵皮肤
		if itemInfo.type == GameDef.ItemType.CrystalUpgrade and itemInfo.color ~= 6 then --这个是水晶碎片
			self.itemTypeCtrl:setSelectedIndex(7)
		elseif itemInfo.type == GameDef.ItemType.ElfSkin then
			self.itemTypeCtrl:setSelectedIndex(8)
			haveElfSkin = ElvesSystemModel:checkSkinById(code)
			self.btn_shiyongLong:setVisible(not haveElfSkin)
		elseif itemInfo.category == GameDef.BagType.Normal and itemInfo.type == GameDef.ItemType.FashioDebris then --时装碎片
			self.itemTypeCtrl:setSelectedIndex(3)
		else
			self.itemTypeCtrl:setSelectedIndex(itemInfo.sell == 1 and 6 or 0)
		end
		if itemInfo.useType ~= 0 then
			self.btn_shiyong:setTouchable(true)
			self.btn_shiyong:setGrayed(false)
		else
			self.btn_shiyong:setTouchable(false)
            self.btn_shiyong:setGrayed(true)
		end
		if #itemInfo.source > 0 then
			print(1,"22222222222222 source")
			self.btn_laiyuan:setTouchable(true)
            self.btn_laiyuan:setGrayed(false)
			self.btn_laiyuanLong:setTouchable(true)
			self.btn_laiyuanLong:setGrayed(false)
		else
			print(1,"22222222222222 source 22222222222")
			self.btn_laiyuan:setTouchable(false)
            self.btn_laiyuan:setGrayed(true)	
			self.btn_laiyuanLong:setTouchable(false)
            self.btn_laiyuanLong:setGrayed(true)
		end

		self.btn_decompose:setVisible(itemInfo.type == GameDef.ItemType.PassiveSkillBook or haveElfSkin)
		self.btn_fenjieSmall:setVisible(itemInfo.type == GameDef.ItemType.PassiveSkillBook)
		self.btn_laiyuan:setVisible(itemInfo.type ~= GameDef.ItemType.PassiveSkillBook)
		self.btn_laiyuanLong:setVisible(itemInfo.type ~= GameDef.ItemType.PassiveSkillBook)
	elseif self.itemData:getBagType() == GameDef.BagType.Rune then
		self.itemTypeCtrl:setSelectedIndex(4)
		-- self.btn_shiyong:setTouchable(true)
		-- self.btn_shiyong:setGrayed(false)
		local code = self.itemData:getItemCode();
		local config = DynamicConfigData.t_Rune[code]
		if config and config.level == 1 then --1级符文
			self.btn_fenjieSmall:setTouchable(false)
			self.btn_fenjieSmall:setGrayed(true)
			self.btn_sell:setTouchable(true)
			self.btn_sell:setGrayed(false)
		else
			self.btn_fenjieSmall:setTouchable(true)
			self.btn_fenjieSmall:setGrayed(false)
			self.btn_sell:setTouchable(false)
			self.btn_sell:setGrayed(true)
		end
	elseif self.itemData:getBagType() == GameDef.BagType.Equip then
		self.itemTypeCtrl:setSelectedIndex(1)
		-- if itemInfo.useType ~= 0 then
		-- 	table.insert(self._btnData, {name = "shiyongBtn", title = Desc.itemtips_btnWear})
		-- end
		-- if #itemInfo.source > 0 then
		-- 	table.insert(self._btnData, {name = "laiyuanBtn", title = Desc.itemtips_btnSource})
		-- end
	elseif self.itemData:getBagType() == GameDef.BagType.HeroComponent then
		self.itemTypeCtrl:setSelectedIndex(3)
		-- if itemInfo.useType ~= 0 then
		-- 	table.insert(self._btnData, {name = "hechengBtn", title = Desc.itemtips_btnCompose})
		-- end
		-- if #itemInfo.source > 0 then
		-- 	table.insert(self._btnData, {name = "laiyuanBtn", title = Desc.itemtips_btnSource})
		-- end
	elseif self.itemData:getBagType() == GameDef.BagType.Jewelry then
		self.itemTypeCtrl:setSelectedIndex(5);
	elseif self.itemData:getBagType() == GameDef.BagType.Elf then
		local code = self.itemData:getItemCode();
		if code >= 80014001 or (code >= 10000077 and code <= 10000078) then -- 碎片
			self.itemTypeCtrl:setSelectedIndex(3)
		else -- 不是碎片
			self.itemTypeCtrl:setSelectedIndex(2)
		end
	end
end



function ItemTipsBagView:addDesc(title, desc)
	local ItemTipsDesc = require "Game.Modules.Tips.ItemTipsDesc"
	local vieCls = ItemTipsDesc.new({parent = self.viewListMid, data={title = title, desc = desc},winType="bag"})
	vieCls:toCreate()
end


--根据列表高度决定是否需要滚动，然后做居中处理
function ItemTipsBagView:updateSize()
	self.viewListHead:resizeToFit(self.viewListHead:getNumItems()) --设置成头的高度
	self.viewListMid:resizeToFit(self.viewListMid:getNumItems())
end

-- [子类重写] 准备事件
function ItemTipsBagView:_initEvent( ... )
end 

-- [子类重写] 添加后执行
function ItemTipsBagView:_enter()
end

-- [子类重写] 移除后执行
function ItemTipsBagView:_exit()
end


return ItemTipsBagView
