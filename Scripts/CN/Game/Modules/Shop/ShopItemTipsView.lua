-- added by wyz
-- 商城购买物品提示窗口

local ShopItemTipsView = class("ShopItemTipsView", Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器

function ShopItemTipsView:ctor()
	self._packName = "Shop"
	self._compName = "ShopItemTipsView"
	self._rootDepth = LayerDepth.PopWindow
	self.itemCell  = false 		-- 展示的物品
	self.txt_itemName = false 	-- 展示的物品名字
	self.costItem1 	  = false	-- 购买物品消耗的货币
	self.costItem2 	  = false 	-- 售价
	self.txt_buyTime  = false 	-- 可购买的次数
	self.btn_ok 	  = false 	-- 确定按钮
	self.data 		  = {} 		-- 传进来的数据
	self.buyTime 	  = false 	-- 可购买的次数


	self.btn_sub 	  = false 	-- 减少按钮
	self.btn_add 	  = false 	-- 增加按钮
	self.btn_max 	  = false 	-- 最大购买数量按钮
	self.txt_num 	  = false 	-- 数量展示 默认为1

end

function ShopItemTipsView:_initUI()
	self.itemCell 		= self.view:getChildAutoType("itemCell")
	self.txt_itemName 	= self.view:getChildAutoType("txt_itemName")
	self.costItem1 		= self.view:getChildAutoType("costItem1")
	self.costItem2 		= self.view:getChildAutoType("costItem2")
	self.txt_buyTime 	= self.view:getChildAutoType("txt_buyTime")
	self.btn_ok 		= self.view:getChildAutoType("btn_ok")

	self.btn_add 		= self.view:getChildAutoType("btn_add")
	self.btn_sub 		= self.view:getChildAutoType("btn_sub")
	self.btn_max 		= self.view:getChildAutoType("btn_max")
	self.btn_min 		= self.view:getChildAutoType("btn_min")
	self.txt_num 		= self.view:getChildAutoType("txt_num")
	self.buyTimeCtrl 	= self.view:getController("buyTimeCtrl")

	self.data 			= self._args
end

function ShopItemTipsView:_initEvent()
	self:ShopItemTipsView_upDate()
end


function ShopItemTipsView:ShopItemTipsView_upDate()
	local showData 	= self.data.showData
	local buyTime 	= self.data.buyTime
	local getRes 	= showData.getRes[1] 		-- 展示的物品信息
	local costRes 	= showData.costRes[1] 		-- 消耗的物品信息

	local itemCell 	= BindManager.bindItemCell(self.itemCell)
	itemCell:setData(getRes.code, getRes.amout, getRes.type)
	itemCell:setIsBig(true)
	itemCell:setNoFrame(true)
	self.itemCell:setScale(2,2)

	-- printTable(8848,"showData",showData)
	-- 物品信息介绍
	self.txt_itemName:setText(ItemConfiger.getItemNameByCode(getRes.code))

	local itemData = DynamicConfigData.t_item
	if not itemData then return end
	itemData = itemData[getRes.code]
	if not itemData then return end
	local txt_propDec = self.view:getChildAutoType("txt_propDec"):getChildAutoType("title")
	txt_propDec:setText(itemData.descStr)

	-- 消耗的物品
	local costItem1  	= BindManager.bindCostItem(self.costItem1)
	costItem1:setData(costRes.type,  costRes.code, costRes.amount,true)

	local iconLoader 	= self.view:getChildAutoType("iconLoader")
	local url 			= ItemConfiger.getItemIconByCode(costRes.code, costRes.type, true)
	local txt_price 	= self.view:getChildAutoType("txt_price")
	txt_price:setText(costRes.amount)
	iconLoader:setURL(url)

	-- 购买次数
	self.txt_buyTime:setText(string.format(Desc.shop_buyTime, buyTime ))

	-- 名字列表
	local list_name = self.view:getChildAutoType("list_name")
	list_name:setItemRenderer(function(idx,obj)
		local title = obj:getChildAutoType("title")
		title:setText(string.format("%s x%s",ItemConfiger.getItemNameByCode(getRes.code),getRes.amount))
	end)
	list_name:setNumItems(1)

	-- 批量购买
	self.buyTimeCtrl:setSelectedIndex(buyTime > 1 and 1 or 0)
	local buyNum 	= 1  -- 购买数量

	local haveMoney = 0
	if showData.relatedToActivity>0 then
		haveMoney =  ModelManager.PackModel:getItemsFromAllPackByCode(costRes.code)
	elseif costRes.type == 3 then
		haveMoney =  ModelManager.PackModel:getItemsFromAllPackByCode(costRes.code)
	else
		haveMoney =  PlayerModel:getMoneyByType(costRes.code)
	end
	self.btn_max:removeClickListener(888)
	self.btn_max:addClickListener(function()
		local needMoney = buyTime * costRes.amount
		if haveMoney >= needMoney then
			buyNum = buyTime
		else
			buyNum = math.floor(haveMoney/costRes.amount)
		if buyNum == 0 then buyNum = 1 end 
		end
		costItem1:setData(costRes.type,  costRes.code, costRes.amount * buyNum,true)
		self.txt_num:setText(buyNum)
	end,888)

	self.btn_sub:removeClickListener(888)
	self.btn_sub:addClickListener(function()
		if buyNum > 1 then
			buyNum = buyNum - 1
		end
		costItem1:setData(costRes.type, costRes.code, costRes.amount * buyNum,true)
		self.txt_num:setText(buyNum)
	end,888)

	self.btn_add:removeClickListener(888)
	self.btn_add:addClickListener(function()
		if buyNum < buyTime then
			buyNum = buyNum + 1
		end
		costItem1:setData(costRes.type,  costRes.code, costRes.amount * buyNum,true)
		self.txt_num:setText(buyNum)
	end,888)

	self.btn_min:removeClickListener(888)
	self.btn_min:addClickListener(function()
		buyNum = 1
		costItem1:setData(costRes.type,  costRes.code, costRes.amount * buyNum,true)
		self.txt_num:setText(buyNum)
	end,888)
	

	-- 折扣
	local dazhe = self.view:getChildAutoType("dazhe")
	local txt_zhekou = self.view:getChildAutoType("txt_zhekou")
	if showData.rate > 0 and showData.rate < 10 then
		dazhe:setVisible(true)
		txt_zhekou:setVisible(true)
		txt_zhekou:setText(string.format(Desc.shop_zhe2,showData.rate))
	else
		txt_zhekou:setVisible(false)
		dazhe:setVisible(false)
	end

	-- -- 购买次数小于1 购买按钮置灰
	if buyTime < 1 then
		self.btn_ok:getChildAutoType("n32"):setGrayed(true)
		self.btn_ok:setTouchable(false)
	end


	-- print(8848,"haveMoney>>>>>>>>",haveMoney,">>>>>amount>>>>>>>>>",costRes.amount)
	self.btn_ok:removeClickListener(888)
	self.btn_ok:addClickListener(function()
		if ShopModel.isActivityEnd then
			RollTips.show(Desc.shop_exchangeEnd)
			return 
		end

		if haveMoney >= (costRes.amount * buyNum) then
			-- print(8848,"haveMoney>>>>>>>>",haveMoney,">>>>>amount>>>>>>>>>",costRes.amount)
			if VipModel.level < showData.vipLimit then 
				local txt = string.format(Desc.shop_vipLimitTips,showData.vipLimit)
				RollTips.show(txt)
				return
			end
			RPCReq.Shop_BuyMallItem({shopType = showData.shopType,index = showData.id,amount =buyNum},
				function(args)
					-- printTable(8848,"args123",args)
					-- if tolua.isnull(self.view) then return end
					ModelManager.ShopModel.isShop = true
					-- print(8848,"ModelManager.ShopModel.isShop1>>>>>>>>>",ModelManager.ShopModel.isShop)
					self:buyResult(args,showData.obj, buyNum)
					buyTime = self.data.buyTime
				end)
			ViewManager.close("ShopItemTipsView")
		else
			if not PlayerModel:isCostEnough({{type = costRes.type, code = costRes.code, amount = costRes.amount * buyNum}}) then
				return
			end
		end
	end,888)

	-- 背包中物品数量
	local hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(getRes.code)
	local txt_haveNum = self.view:getChildAutoType("txt_haveNum")
	txt_haveNum:setText(Desc.shop_haveDec .. ":" ..hasNum)

	-- 特性书要展示英雄
	local heroCtrl = self.view:getController("heroCtrl");
	if (showData.shopType == 11) then
		heroCtrl:setSelectedIndex(1);
		CardLibModel:setCardsByCategory(0);
		local heroMap = CardLibModel:getHeroInfoToIndex(true, 2);
		local skillId = showData.getRes[1].code - 10004000;
		local heroCodeMap = {};
		local codeList = {};
		local suggestPassive = DynamicConfigData.t_SuggestPassive;
		local heroConf = DynamicConfigData.t_hero;
		for _, hero in pairs(heroMap) do
			local suggestList = {}
			local hConf = heroConf[hero.code]
			local suggestId = hConf.suggestpassive;
			-- 高级特性技能推荐
			for _, id in ipairs (suggestPassive[suggestId].passivecombin) do
				suggestList[id] = true;
			end
			for _, id in ipairs (hConf.passiveSkill) do
				suggestList[id] = true
			end
			local learnedMap = {}
			if (hero.newPassiveSkill) then
				for id, info in pairs(hero.newPassiveSkill) do
					if (info.skillId and info.skillId > 0) then
						learnedMap[info.skillId] = true
					end
				end
			end
			if (hero and hero.star > 3 
				and (not heroCodeMap[hero.code]) 
				and (suggestList[skillId] and (not learnedMap[skillId]))) then
				heroCodeMap[hero.code] = hero;
				table.insert(codeList, hero.code);
			end
		end
		local list_hero = self.view:getChildAutoType("list_hero");
		heroCtrl:setSelectedIndex(#codeList == 0 and 0 or 1);
		list_hero:setItemRenderer(function (idx, obj)
			local key = codeList[idx + 1];
			local d = heroCodeMap[key];
			if (not obj.cell) then
				obj.cell = BindManager.bindHeroCell(obj);
			end
			obj.cell:setBaseData(d);
			obj.cell.img_category_frame:setVisible(false);
			obj.cell.img_category:setVisible(false);
			obj.cell.img_career:setVisible(false);
			obj.cell.level_frame:setVisible(false);
			obj.cell.level:setVisible(false);
			obj.cell.cardStar:setVisible(false);
			obj.cell.img_quality:setVisible(false);
			local lvbg = obj:getChildAutoType("img_lvBg")
			if (lvbg) then
				lvbg:setVisible(false);
			end
			local lvbg = obj:getChildAutoType("img_lvBg1")
			if (lvbg) then
				lvbg:setVisible(false);
			end
			obj:removeClickListener();
			obj:addClickListener(function ()
				Dispatcher.dispatchEvent("HeroInfo_Show", {heroArray={d}});
			end)
		end)
		list_hero:setNumItems(#codeList);
	else
		heroCtrl:setSelectedIndex(0);
	end
end


function ShopItemTipsView:buyResult( args ,obj, buyNum)
	if tolua.isnull(obj) then return end
	local c1 = obj:getController("c1")
	if args.ret == 0 then
		local showData 	= self.data.showData
		local getRes 	= showData.getRes[1] 	
		RollTips.show(Desc.shop_success:format(ItemConfiger.getItemNameByCode(getRes.code), getRes.amount * buyNum))
		self.data.buyTime = args.buyTime 
		local buyTime = self.data.buyTime
		c1:setSelectedIndex(buyTime < 1 and 0 or 1)

		for k,v in pairs(ShopModel.shopList[showData.shopType].list) do
			if args.id == v.id then
				v.buyTime = buyTime
				break	
			end
		end
		ShopModel:upDateRed(showData.shopType);
		Dispatcher.dispatchEvent(EventType.shop_refreshItem)
	else
		--Alert.show(Desc.shop_success)
	end
end

return ShopItemTipsView
