--Date :2020-12-09
--Author : added by xhd
--Desc : 取出

local GuildBuyTipsView,Super = class("GuildBuyTipsView", Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器

function GuildBuyTipsView:ctor()
	--LuaLog("GuildBuyTipsView ctor")
	self._packName = "GuildHourse"
	self._compName = "GuildBuyTipsView"
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

function GuildBuyTipsView:_initEvent( )
	
end


function GuildBuyTipsView:_initUI( )
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

function GuildBuyTipsView:_initEvent()
	self:GuildBuyTipsView_upDate()
end


function GuildBuyTipsView:GuildBuyTipsView_upDate()
	local showData 	= self.data.showData
	local buyTime 	= showData.buyTime
	local getRes 	= showData.getRes		-- 展示的物品信息
	local costRes 	= showData.costRes 		-- 消耗的物品信息
 
	local itemCell 	= BindManager.bindItemCell(self.itemCell)
	itemCell:setData(getRes.code)
	itemCell:setIsBig(true)
	itemCell:setNoFrame(true)
	self.itemCell:setScale(2,2)
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

	local haveMoney  =  PlayerModel:getMoneyByType(costRes.code)
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
	-- local dazhe = self.view:getChildAutoType("dazhe")
	-- local txt_zhekou = self.view:getChildAutoType("txt_zhekou")
	-- if showData.rate > 0 and showData.rate < 10 then
	-- 	dazhe:setVisible(true)
	-- 	txt_zhekou:setVisible(true)
	-- 	txt_zhekou:setText(string.format(Desc.shop_zhe2,showData.rate))
	-- else
	-- 	txt_zhekou:setVisible(false)
	-- 	dazhe:setVisible(false)
	-- end

	-- -- 购买次数小于1 购买按钮置灰
	if buyTime < 1 then
		self.btn_ok:getChildAutoType("n32"):setGrayed(true)
		self.btn_ok:setTouchable(false)
	end


	-- print(8848,"haveMoney>>>>>>>>",haveMoney,">>>>>amount>>>>>>>>>",costRes.amount)
	self.btn_ok:removeClickListener(888)
	self.btn_ok:addClickListener(function()
		--如果时间过期 
		if  ServerTimeModel:getServerTimeMS() >showData.expireMS then
			RollTips.show("物品已消失了")
			return
		end
		local haveMoney  =  PlayerModel:getMoneyByType(costRes.code)
		if haveMoney<costRes.amount * buyNum then
			RollTips.show("货币不足")
			return 
		end

		-- if not PlayerModel:isCostEnough({{type = costRes.type, code = costRes.code, amount = costRes.amount * buyNum}}) then
		-- 	return
		-- end

		if haveMoney >= (costRes.amount * buyNum) then
			-- print(8848,"haveMoney>>>>>>>>",haveMoney,">>>>>amount>>>>>>>>>",costRes.amount)
			RPCReq.Guild_GuildPackTakeOutItem({packType = showData.packType,id = showData.id,amount =buyNum,code=showData.code},
				function(args)
					buyTime = buyTime - buyNum
					-- self:buyResult(args,showData.obj,buyNum)
					ViewManager.close("GuildBuyTipsView")
				end)
			
		end
	end,888)

	-- 库中物品数量
	local hasNum = showData.amount
	local txt_haveNum = self.view:getChildAutoType("txt_haveNum")
	txt_haveNum:setText(Desc.shop_haveDec .. ":" ..hasNum)
end

--公会金库数据更新
function GuildBuyTipsView:Guild_PackUpdateNotify(_,data)

end


function GuildBuyTipsView:buyResult( args ,obj, buyNum)
	if tolua.isnull(obj) then return end
	local c1 = obj:getController("c1")
	if args.ret == 0 then
		local showData 	= self.data.showData
		local getRes 	= showData.getRes[1] 	
		RollTips.show(Desc.shop_success:format(ItemConfiger.getItemNameByCode(getRes.code), getRes.amount * buyNum))
		self.data.buyTime = args.buyTime 
		local buyTime = self.data.buyTime
		c1:setSelectedIndex(buyTime < 1 and 0 or 1)

		-- for k,v in pairs(ShopModel.shopList[showData.shopType].list) do
		-- 	if args.id == v.id then
		-- 		v.buyTime = buyTime
		-- 		break	
		-- 	end
		-- end
		-- ShopModel:upDateRed(showData.shopType);
		-- Dispatcher.dispatchEvent(EventType.shop_refreshItem)
	else
		--Alert.show(Desc.shop_success)
	end
end



return GuildBuyTipsView