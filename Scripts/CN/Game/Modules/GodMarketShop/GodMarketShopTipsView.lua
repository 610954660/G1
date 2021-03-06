local GodMarketShopTipsView = class("GodMarketShopTipsView",Window)
function GodMarketShopTipsView:ctor()
    self._packName  = "GodMarketShop"
    self._compName  = "GodMarketShopTipsView"

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
	
	self.activityType = self._args.activityType
	self.refreshCallBack = self._args.refreshCallBack or false
end


function GodMarketShopTipsView:_initUI()
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

function GodMarketShopTipsView:_initEvent()
	self:GodMarketShopTipsView_upDate()
end


function GodMarketShopTipsView:GodMarketShopTipsView_upDate()
	local showData 	= self.data.showData
	local buyTime 	= self.data.showData.limit
	local getRes 	= showData.reward[1] 		-- 展示的物品信息
	local costRes 	= showData.price[1] 		-- 消耗的物品信息
	local buyRecords = self.data.buyRecords or {count = 0}
	buyTime = buyTime - buyRecords.count
	local itemCell 	= BindManager.bindItemCell(self.itemCell)
	itemCell:setData(getRes.code, getRes.amout, getRes.type)
	itemCell:setIsBig(true)
	itemCell:setNoFrame(true)
    self.itemCell:setScale(2,2)
    local timesCtrl = self.view:getController("timesCtrl")
    timesCtrl:setSelectedIndex(buyTime == -1 and 1 or 0)

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

	if costRes.type == 3 then
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
        if buyNum > 99 then
            buyNum = 99
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
		if buyNum < buyTime and buyNum ~= 99 then
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
	-- if showData.rate > 0 and showData.rate < 10 then
	-- 	dazhe:setVisible(true)
	-- 	txt_zhekou:setVisible(true)
	-- 	txt_zhekou:setText(string.format(Desc.shop_zhe2,showData.rate))
	-- else
		txt_zhekou:setVisible(false)
		dazhe:setVisible(false)
	-- end

	-- -- 购买次数小于1 购买按钮置灰
	if buyTime < 1 and buyTime ~= -1 then
		self.btn_ok:getChildAutoType("n32"):setGrayed(true)
		self.btn_ok:setTouchable(false)
	end


	self.btn_ok:removeClickListener(888)
	self.btn_ok:addClickListener(function()
		if PlayerModel:isCostEnough({{type = costRes.type, code = costRes.code, amount = costRes.amount * buyNum}},true) then
			local reqInfo = {
                activityId = self.activityType,
				id = showData.id,
				buyCount = buyNum,
            }  
            RPCReq.Activity_NewHeroShop_Buy(reqInfo,function(params)
				--Dispatcher.dispatchEvent(EventType.activity_GodMarketShop)
				if self.refreshCallBack then 
					self.refreshCallBack()
				end
            end)
			ViewManager.close("GodMarketShopTipsView")
		end
	end,888)

	-- 背包中物品数量
	local hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(getRes.code)
	local txt_haveNum = self.view:getChildAutoType("txt_haveNum")
	txt_haveNum:setText(Desc.shop_haveDec .. ":" ..hasNum)
end
function GodMarketShopTipsView:_exit()
end
return GodMarketShopTipsView
