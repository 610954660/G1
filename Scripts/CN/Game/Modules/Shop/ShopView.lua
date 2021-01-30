
local ShopView,Super = class("ShopView", MutiWindow)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger"
local TimeLib = require "Game.Utils.TimeLib"
local TimeUtil = require "Game.Utils.TimeUtil"
local FashionConfiger = require "Game.ConfigReaders.FashionConfiger"

local lastInterTime = 0.02
local maxInterTime = 0.5
function ShopView:ctor()
	LuaLogE("ShopView ctor")
	self._packName = "Shop"
	self._compName = "shopView"
	self._rootDepth = LayerDepth.Window
	self._isFullScreen = true
	self.isEnd = true

	self.shopList	= false
	self.showType 	= 1  		-- 1限购 2特惠  大页签展示类型
	self.refresh 	= false  	-- 限购刷新按钮
	self.shopType 	= 1  		-- 商店类型 1普通商店 2系统商店 3积分商店
	self.shopDesc 	= false 	
	self.buyTime 	= 100 		-- 刷新次数
	self.buyMoney 	= {} 		-- 货币
	self.allShopData = {} 		-- 商品的详细信息
	self._tabBarName = "shopList2"

	self.shopArr 	= {}
	self.tabIndex 	= {} 			-- 三级页签索引
	self.tabSecondIndex 	= {}	-- 二级页签索引
	self.shopNum 	= false 		-- 三级页签的个数
	
	self.schedulerID = false 			-- 刷新按钮的计时器，用来防止玩家点击过快
	self.timer 		 = false 			-- 计时器
	self.activityOpenNum 	= false 	-- 活动商店开启的个数
	self.timerActivity 		= false 	-- 活动倒计时计时器
	self.txt_activityTime 	= false 	-- 活动倒计时文本
	self.txt_tips 	= false 			-- tips文本
	self.categoryList 		= false 	-- 种族列表页签
	self.category 			= 0 		-- 种族 0 表示显示全部
	self.category 			= 0 		-- 种族 0 表示显示全部
	self.scheduler 		= {}
	self.dataArr = {}
	self.heroMap = {};

	self.mysteryTimer = false
end

function ShopView:_initUI()
	LuaLogE("ShopView _initUI")
	self:setBg("bg_shop.jpg")
	self.refreshCtrl = self.view:getController("refresh")
	self.showtypeCtrl = self.view:getController("showtype")
	self.shopDesc = self.view:getChildAutoType("desc")
	self.refresh = self.view:getChildAutoType("refresh")
	self.shopList = self.view:getChildAutoType("list")
	self.txt_activityTime = self.view:getChildAutoType("txt_activityTime")
	self.categoryList = self.view:getChildAutoType("categoryList")
	self.txt_tips = self.view:getChildAutoType("txt_tips")
	self.txt_timer = self.view:getChildAutoType("txt_timer")
	self.isMystery = self.view:getController("isMystery")
	self.txt_timerTitle = self.view:getChildAutoType("txt_timerTitle")

	self.shopType = ShopModel:getMallType()
	self.activityOpenNum = ShopModel:getOpenActivityNum()
	self:initTabConfig()
	self:setCategoryList()
	self:ShopView_upDataList()
	local showData = ShopModel:getShopItemInfoByType(self.shopType)
	local activityType = -1
	for k,v in pairs(showData) do
		activityType = v.relatedToActivity
		break
	end
	self:shop_refreshItem()
	ShopModel:reqShopData(self.shopType,false,activityType) 	-- 请求商品信息
	self.btn_help:removeClickListener()
    self.btn_help:addClickListener(function(...)
		local info={}
		info['title']=Desc["help_StrTitle"..ModuleId.Shop.id]
		info['desc']=Desc["help_StrDesc"..ModuleId.Shop.id]
		ViewManager.open("GetPublicHelpView",info) 
    end)
end


function ShopView:_initEvent()
	self:addEventListener(EventType.money_change,self)
	self:initRefreshBtn()
	self.isMystery:setSelectedIndex(self.shopType ~= GameDef.ShopType.Limits and 1 or 0)
	self:countTimeMystery()
end

-- 刷新按钮
function ShopView:initRefreshBtn()
	self:setMystery()

	self.refresh:addClickListener(function()
		local otherLimit = 0
		if  ShopModel.shopList and ShopModel.shopList[self.shopType] and ShopModel.shopList[self.shopType].otherLimit then
			otherLimit = ShopModel.shopList[self.shopType].otherLimit
		end
		-- 服务端的数据还没有返回，弹提示
		if (ModelManager.ShopModel.refreshFlag) then
			RollTips.show(Desc.delegate_waitRefresh);
			return;
		end
		-- 货币不足，弹提示
		if  otherLimit == 0 then
			if not PlayerModel:isCostEnough({{type = 2, code = self.buyMoney.code, amount = self.buyMoney.amount}}) then
				return
			end
		end
		if self.buyTime-ShopModel.shopList[self.shopType].cout > 0  then
			-- 刷新太快 弹提示
			if self.schedulerID then
				RollTips.show(Desc.shop_refreshfast)
				return
			end
			local dayStr = DateUtil.getOppostieDays()
			local isfresh = FileCacheManager.getIntForKey("ShopView_isCheckTips" .. dayStr,0)
			ModelManager.ShopModel.refreshFlag = true
			local function success(param)
				self.isEnd = true
				self:shop_refreshItem()
				ShopModel.redCheckMap[self.shopType] = {}
				ModelManager.ShopModel.refreshFlag = false
			end
			local function fail(data)
				ModelManager.ShopModel.refreshFlag = false
				RollTips.showError(data)
			end
			if self.buyMoney.amount == 0  or isfresh == 1 or  otherLimit > 0 then
				self.schedulerID = Scheduler.schedule(function()
					Scheduler.unschedule(self.schedulerID)
					self.schedulerID = false
				end,2)
				RPCReq.Shop_ManualMallRefresh({shopType = self.shopType},success,fail)
				return
			end

			local info = {}
			info.text = Desc.shop_refresh_tips:format(self.buyMoney.amount,Desc["common_moneyType"..self.buyMoney.code])
			info.type = "yes_no"
			info.mask = true
			info.onYes = function()
				self.schedulerID = Scheduler.schedule(function()
						Scheduler.unschedule(self.schedulerID)
						self.schedulerID = false
				end,2)
				RPCReq.Shop_ManualMallRefresh({shopType = self.shopType},success,fail)
			end
			ViewManager.open("ShopRefreshTipsView",{data = info})
		else
			Alert.show(Desc.shop_nofresh)
		end
	end)
end

-- 商品列表
function ShopView:ShopView_upDataList()
	CardLibModel:setCardsByCategory(0);
	self.heroMap = CardLibModel:getHeroInfoToIndex(true, 3);
	self.shopList:setItemRenderer(function(index,obj)
			self:itemShow(obj,index)
	end)
end

-- 种族列表页签
function ShopView:setCategoryList()
	self.categoryList:setItemRenderer(function(idx,obj)
		local title = obj:getChildAutoType("title")
		title:setText(string.format(Desc["common_category"..idx]))
	end)
	self.categoryList:setNumItems(6)
	self.categoryList:setSelectedIndex(0)
	self.categoryList:removeClickListener(111)
	self.categoryList:addClickListener(function()
		local index = self.categoryList:getSelectedIndex()
		self.categoryList:setSelectedIndex(index)
		self.category = index
		self:shop_refreshItem()
	end,111)
end

-- 初始化页签
function ShopView:initTabConfig()
	self.mallConfig = DynamicConfigData.t_mall
	self.costConfig = DynamicConfigData.t_mallRefreshCost
	self.coinConfig = DynamicConfigData.t_mallCoinShow
	self.secondShop = {}
	local data = {}
	local tabSecondIndex = {}
	for i = 1, #self.mallConfig do
		if self.activityOpenNum < 1 and i == #self.mallConfig then
			break 
		end
		local t = {}
		t.page = i-1
		t.btData = {}
		t.btData.title = self.mallConfig[i][1].name
		--t.btData.titleEng = self.mallConfig[i].desc
		local secondData = {}
		secondData = DynamicConfigData.t_mall
		secondData = secondData[i]
		self.secondShop[i] = {}
		for m = 1, #secondData do
			local op = false
			for n = 1, #secondData[m].shopArr do
				local shopData = self.coinConfig[secondData[m].shopArr[n]]
				if ModuleUtil.moduleOpen(shopData.moduleId,false) then
					op = true
					break
				end
			end
			if op then 
				table.insert(self.secondShop[i],secondData[m])
			end
		end
		self.tabIndex[i] = {}
		if #self.secondShop[i] > 0 then
			table.insert(data,t)
		end

		for j =1,#self.secondShop[i] do
			tabSecondIndex[i]=1
			self.tabIndex[i][j] = 0
		end
	end
	for k,v in pairs(self.tabIndex) do
		if TableUtil.GetTableLen(v) == 0 then
			table.remove(self.tabIndex,k)
		end
	end

	for i=1,TableUtil.GetTableLen(tabSecondIndex) do
		self.tabSecondIndex[i] = 1
	end
	for k,v in pairs(self.secondShop) do
		if TableUtil.GetTableLen(v) == 0 then
			table.remove(self.secondShop,k)
		end
	end
	local data2 = {}
	for i=1,TableUtil.GetTableLen(data) do
		local v = data[i]
		local t = {}
		t.page = i-1
		t.btData = {}
		t.btData.title = self.mallConfig[v.page+1][1].name
		table.insert(data2,t)
	end
	self:setTabBarData(data2) 	-- 设置大页签数据（一级页签）

	-- 设置左侧小页签（二级页签）
	local childs = self._tabBar:getChildren()
	for i = 1, #childs do
		local obj 			= childs[i]
		local list_midTag 	= obj:getChildAutoType("list_midTag")
		local clickArea 	= obj:getChildAutoType("clickArea")
		list_midTag:setSelectedIndex(0)
		local objTitle 		= obj:getChildAutoType("title")
		local arrowCtrl = obj:getController("arrowCtrl")
		if i == 1 and (not self._args.shopType) then
			arrowCtrl:setSelectedIndex(0)
		else
			arrowCtrl:setSelectedIndex(1)
		end
		list_midTag:setItemRenderer(function(idx2,obj2)
			local data 		= self.secondShop[i][idx2+1]
			local title 	= obj2:getChildAutoType("title")
			title:setText(data.desc)
		end)
		list_midTag:setData(self.secondShop[i])
		list_midTag:resizeToFit(TableUtil.GetTableLen (self.secondShop[i]))
		if i ==  1 and (not self._args.shopType) then
			obj:setSize(list_midTag:getWidth(), list_midTag:getHeight()+70)
			list_midTag:setVisible(true)
		end
	end

	--  右侧页签（三级页签）
	self.secondList = self.view:getChildAutoType("secondList")
	self.secondList:setItemRenderer(function(index,obj)
		local shopType = self.dataArr[index+1]
		local info = self.coinConfig[shopType]
		local openType2 = self.coinConfig[shopType].openType2
		local openState = false
		obj:setTitle(info.name)
		obj:addClickListener(function(context)
			self.shopType = shopType
			self.tabIndex[self.showType][self.tabSecondIndex[self.showType]] = index
			if self.costConfig[self.shopType] then
				self.refreshCtrl:setSelectedIndex(1)
			else
				self.refreshCtrl:setSelectedIndex(0)
			end
			self.moneyBar:setData(self.coinConfig[self.shopType].coinShow)
			
			local showData = ShopModel:getShopItemInfoByType(self.shopType)
			local activityType = -1
			for k,v in pairs(showData) do
				activityType = v.relatedToActivity
				break
			end
			ShopModel:reqShopData(shopType,false,activityType)
		end,33)
	end)

	self.showType = -1 
	self.shopType = ShopModel:getMallType()  -- 获取默认的商店类型
	
	-- 判断是不是从其它页面跳转进的商店，初始化相应的页签，和商品数据，并选中对应页签
	if self._args.shopType then
		self.shopType = self._args.shopType
		for k,v in pairs(self.secondShop)  do
			local data = self.secondShop[k]
			for o,p in pairs(data) do
				for m,n in pairs(p.shopArr) do
					local mid = self.coinConfig[self.shopType].moduleId
					if n == self.shopType and ModuleUtil.moduleOpen(mid,false) then
						self.showType = k
						self.tabSecondIndex[k] = o
						self.tabIndex[k][self.tabSecondIndex[k]] = m-1
						local childs = self._tabBar:getChildren()
						local itemObj = childs[self._preIndex+1]
						local list_midTag = itemObj:getChildAutoType("list_midTag")
						itemObj:setSize(list_midTag:getWidth(), 70)
						list_midTag:setVisible(false)

						itemObj = childs[self.showType]
						list_midTag = itemObj:getChildAutoType("list_midTag")
						itemObj:setSize(list_midTag:getWidth(), list_midTag:getHeight()+70)
						list_midTag:setVisible(true)
						break
					end
				end
				if self.showType > 0 then
					break
				end
			end
			if self.showType > 0 then
				break
			end
		end 
	end
	
	if self.showType == -1 then
		self.showType = 1
	end
	self:_setPage(self.showType-1)
end

--监听多页切换，并构建
function ShopView:onViewControllerChanged()
	Super.onViewControllerChanged(self)
	self.showType = self._preIndex+1
	self.category = 0
	self.categoryList:setSelectedIndex(self.category)
	-- -- 0807 by wyz start
	local childs = self._tabBar:getChildren()
	for i = 1, #childs do

		local obj 			= childs[i]
		local list_midTag 	= obj:getChildAutoType("list_midTag")
		local clickArea 	= obj:getChildAutoType("clickArea")
		local objTitle 		= obj:getChildAutoType("title")
		-- 红点 10.12号版本
		local img_red1 		= obj:getChildAutoType("img_red")
		RedManager.register("V_SHOP_DISCOUNT".. i, img_red1)

		list_midTag:setSelectedIndex(self.tabSecondIndex[i]-1)
		list_midTag:setItemRenderer(function(idx2,obj2)
			local data 		= self.secondShop[i][idx2+1]
			local title 	= obj2:getChildAutoType("title")
			title:setText(data.desc)
			-- 红点 10.12号版本
			local img_red2 	= obj2:getChildAutoType("img_red")
			local shopArr 	= data.shopArr
			for k,v in pairs(shopArr) do
				RedManager.register("V_SHOP_DISCOUNT".. i .. v, img_red2)
			end
		end)
		list_midTag:setData(self.secondShop[i])
		list_midTag:resizeToFit(TableUtil.GetTableLen (self.secondShop[i]))

		list_midTag:removeClickListener(222)
		list_midTag:addClickListener(function()
			local secondIndex = list_midTag:getSelectedIndex()+1
			local childs 	  = list_midTag:getChildren()
			if self.tabSecondIndex[i] == secondIndex then return end
			self.tabSecondIndex[i] = secondIndex
			local title 	 = childs[secondIndex]:getChildAutoType("title")
			self:onViewControllerChanged()
		end,222)

		local arrowCtrl = obj:getController("arrowCtrl")
		if i == self._preIndex + 1 then
			arrowCtrl:setSelectedIndex(0)
		else
			arrowCtrl:setSelectedIndex(1)
		end

		clickArea:removeClickListener(111)
		clickArea:addClickListener(function()
			local pre = self._preIndex + 1
			if (pre > 0) and (i ~= pre) then
					local obj1 = childs[pre]
					local list_midTag1 = obj1:getChildAutoType("list_midTag")
					-- 之前按钮弹起
					obj1:setSize(list_midTag1:getWidth(), 70)
					list_midTag1:setVisible(false)
					self.tabSecondIndex[pre] = 1
			end
			local state = list_midTag:isVisible()
			if not state then
				arrowCtrl:setSelectedIndex(0)
				obj:setSize(list_midTag:getWidth(), list_midTag:getHeight()+70)
			else
				arrowCtrl:setSelectedIndex(1)
				obj:setSize(list_midTag:getWidth(), 70)
			end
			list_midTag:setVisible(not state);
		end,111)
	end

	self.shopArr = self.secondShop[self.showType][self.tabSecondIndex[self.showType]].shopArr
	local shopNum = #self.secondShop[self.showType][self.tabSecondIndex[self.showType]].shopArr
	local pageNum = #self.secondShop 	-- 如果是最后一个页签 展示活动
	self.shopType = self.secondShop[self.showType][self.tabSecondIndex[self.showType]].shopArr[self.tabIndex[self.showType][self.tabSecondIndex[self.showType]]+1]
	if shopNum > 1 then
		self.shopNum = shopNum
		self.showtypeCtrl:setSelectedIndex(1)
		self.dataArr = {}
		for k,v in pairs(self.shopArr) do
			local shopType = v
			local mid = self.coinConfig[shopType].moduleId
			if ModuleUtil.moduleOpen(mid,false) then
				table.insert(self.dataArr,v)
			end
		end
		self.secondList:setData(self.dataArr)
		self.secondList:setSelectedIndex(self.tabIndex[self.showType][self.tabSecondIndex[self.showType]])
	elseif self.costConfig[self.shopType] then
		self.showtypeCtrl:setSelectedIndex(0)
	else
		self.showtypeCtrl:setSelectedIndex(3)
	end

	if ShopModel:checkIsActivityByType(self.shopType) then
		self.showtypeCtrl:setSelectedIndex(2)
	end

	if self.shopType == GameDef.ShopType.Daily or self.shopType == GameDef.ShopType.Special then
		self.showtypeCtrl:setSelectedIndex(4)
	end

	if self.costConfig[self.shopType] then
		self.refreshCtrl:setSelectedIndex(1)
	else
		self.refreshCtrl:setSelectedIndex(0)
	end
	self.moneyBar:setData(self.coinConfig[self.shopType].coinShow) 	-- 设置顶部货币显示

	local showData = ShopModel:getShopItemInfoByType(self.shopType)
	local activityType = -1
	for k,v in pairs(showData) do
		activityType = v.relatedToActivity
		break
	end
	self:shopView_refreshActivityBtn()
	self.isMystery:setSelectedIndex(self.shopType ~= GameDef.ShopType.Limits and 1 or 0)
	ShopModel:reqShopData(self.shopType,false,activityType)
end

-- 刷新商城数据
function ShopView:shop_refreshItem()
	local costCf =  self.costConfig and self.costConfig[self.shopType] or false   -- 判断有没有配置商城刷新按钮
	self.buyTime = 0
	if costCf then
		local flag = ShopModel.shopList and ShopModel.shopList[self.shopType] and ShopModel.shopList[self.shopType].cout
		if not flag then return end
		local count = ShopModel.shopList[self.shopType].cout
		local otherLimit = ShopModel.shopList[self.shopType].otherLimit or 0
		local rMoney = nil
		local max  = {type=2,code = 1,amount = -1}
		for k,v in pairs(costCf) do
			if count>=v.timeStart and count<=v.timeEnd then
				rMoney = v.cost[1]
			end
			if self.buyTime < v.timeEnd then
				self.buyTime = v.timeEnd
			end 
			if max.amount < v.cost[1].amount then
				max = v.cost[1]
			end
		end
		if not rMoney then rMoney = max end
		
		printTable(8848,"rMoney",rMoney)

		self.buyMoney = rMoney
		-- 红点 10.12号版本
		local refresh_imgRed = self.refresh:getChildAutoType("img_red")
		refresh_imgRed:setVisible(rMoney.amount == 0 and (self.shopType == GameDef.ShopType.Limits ) or otherLimit>0)--or self.shopType == 11))

		self.refresh:getChildAutoType("title"):setText(Desc.shop_refreshBtn:format(count,self.buyTime)) -- 刷新按钮
		local costItem = self.view:getChildAutoType("costItem")
		local costItemTitle = self.view:getChildAutoType("n60") 
		local bindCostItem = BindManager.bindCostItem(costItem)
		local txt_free 		= self.view:getChildAutoType("txt_free")
		if rMoney.amount > 0 and otherLimit < 1 then
			costItem:setVisible(true)
			costItemTitle:setVisible(true)
			txt_free:setVisible(false)
			bindCostItem:setData(rMoney.type,rMoney.code,rMoney.amount,true)
		else
			txt_free:setVisible(true)
			costItemTitle:setVisible(true)
			costItem:setVisible(false)
		end
		
		if self.timer then
			TimeUtil.clearTime(self.timer)
		end

		local txt_refreshCount = self.view:getChildAutoType("txt_refreshCount") 	-- 商店刷新倒计时
		local time = ServerTimeModel:getTodayLastSeconds()
		self.timer = TimeUtil.upText(txt_refreshCount,time - 1,"%s")
		txt_refreshCount:setText(TimeLib.formatTime(time - 1))

		if  self.buyTime - count < 1 then
			self.refresh:setGrayed(true)
			self.refresh:setTouchable(false)
		else
			self.refresh:setGrayed(false)
			self.refresh:setTouchable(true)
		end
	end

	self.allShopData = {}
	self.allShopData = ShopModel:getShopInfoByType(self.shopType,self.category)
	-- 清除商品的动画
	for i,v in ipairs(self.scheduler) do
		if self.scheduler[i] then
			Scheduler.unschedule(self.scheduler[i])
	        self.scheduler[i] = false
		end
	end
	self:setCriticalShop()
	self.shopList:setData(self.allShopData)
	ModelManager.ShopModel.isShop = false
	
	--显示开放条件tips
	if self.shopType == GameDef.ShopType.Guild then --现在需要只有公会商店的，其他商店也要的话再加上吧
		local type,minDay,maxDay = ShopModel:getSellLimit(self.shopType)
		if type ~= -1 then
			self.txt_tips:setVisible(true)
			if maxDay ~= -1 then
				self.txt_tips:setText(string.format(Desc.guild_shopItemOpentips1, minDay))
			else
				self.txt_tips:setText(Desc.guild_shopItemOpentips2)	
			end
		else
			self.txt_tips:setVisible(false)
		end
	else
		self.txt_tips:setVisible(false)
	end

	self.isMystery:setSelectedIndex(self.shopType ~= GameDef.ShopType.Limits and 1 or 0)
	self:countTimeMystery()

end

-- 商品展示
function ShopView:itemShow( obj,index )
	local showData  = self.allShopData[index+1]
	local shopData 	= ShopModel:getReqShopDataById(showData.id,self.shopType)

	if showData and showData.costRes then
		local costRes 	= showData.costRes[1]
		local costItem  = BindManager.bindCostItem(obj:getChildAutoType("costItem"))
		costItem:setNoTips(true)
		costItem:setData(costRes.type, costRes.code, costRes.amount,true)
	end
	local c1 = obj:getController("c1") 				-- 判断卖没卖完
	local list_flag = obj:getChildAutoType("list_flag")
	local txt_limitType = obj:getChildAutoType("txt_limitType")
	local txt_vipLimit 	= obj:getChildAutoType("txt_vipLimit")
	if showData and showData.limitType > 0 then
		txt_limitType:setVisible(true)
		txt_limitType:setText(string.format(Desc["shop_limitType"..showData.limitType],shopData.buyTime))
	else
		txt_limitType:setVisible(false)
	end

	if showData and showData.limitType == 0 then
		txt_limitType:setVisible(false)
	elseif showData and showData.limitType == 1 and DynamicConfigData.t_mallRefreshCost[self.shopType] then
		txt_limitType:setVisible(false)
	else
		txt_limitType:setVisible(true)
		txt_limitType:setText(string.format(Desc["shop_limitType"..showData.limitType],shopData.buyTime))
	end 

	local flagListData = {}
	if ( showData and showData.rate ~= 0) and (showData and showData.rate ~= 10) and showData.rate then  -- 折扣
		table.insert(flagListData,1)
	end
	if showData and showData.vipLimit ~= 0 and showData.vipLimit then 	-- vip限制
		table.insert(flagListData,2)
	end
	if showData and showData.titleDec ~= 0 and showData.titleDec and self.shopType ~= GameDef.ShopType.Fashion  then 	-- 必买
		table.insert(flagListData,3)
	end
	-- 时装特殊处理
	if showData and showData.titleDec ~= 0 and self.shopType == GameDef.ShopType.Fashion  then 	-- 时装
		table.insert(flagListData,4)
	end

	list_flag:setItemRenderer(function(idxF,objF)
		local flagIndex = flagListData[idxF+1]
		local iconLoader = objF:getChildAutoType("iconLoader")
		local txt_desc 	= objF:getChildAutoType("txt_desc")
		iconLoader:setURL("UI/Shop/flag" .. flagIndex ..".png")
		if flagIndex == 1 then -- 折扣
			txt_desc:setText(string.format(Desc.shop_zhe2,showData.rate))
		elseif flagIndex == 2 then -- vip限购
			txt_desc:setText(string.format(Desc.shop_vipLimit,showData.vipLimit))
		elseif flagIndex == 3 then -- 必买
			iconLoader:setURL("UI/Shop/flag2.png")
			txt_desc:setText(showData.titleDec)
		elseif flagIndex == 4 then -- 时装
			local getRes 	= showData.getRes[1]
			local fashionId = getRes.code
			local existTime = DynamicConfigData.t_item[fashionId].existTime
			if existTime == 0 then
				iconLoader:setURL("UI/Shop/flag2.png")
			end
			txt_desc:setText(showData.titleDec)
		end
	end)
	list_flag:setData(flagListData)

	local interTime = maxInterTime/#self.allShopData
    if interTime >= lastInterTime then
    	interTime = lastInterTime
    end
	obj:setVisible(false)
	if not ModelManager.ShopModel.isShop and self.isEnd then 
		self.scheduler[index+1] = Scheduler.scheduleOnce((index+1)*interTime, function( ... )
			if obj and  (not tolua.isnull(obj)) then
				obj:setVisible(true)
				obj:getTransition("t0"):play(function( ... )
				end);
			end
		end)
	else
		obj:setVisible(true)
	end

	local buyTime = shopData.buyTime
	c1:setSelectedIndex(buyTime > 0 and 1 or 0)
	local getRes = showData.getRes[1]
	local name = obj:getChildAutoType("txt_times")
	local item = DynamicConfigData.t_item[getRes.code]
	name:setText(ItemConfiger.getItemNameByCode(getRes.code))
	if item.color == 1 then
		name:setColor(cc.c3b(69,69,69))
	else
		name:setColor(ColorUtil.getItemColor(item.color))
	end
	
	local itemCell =  BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
	itemCell:setData(getRes.code, getRes.amount, getRes.type)

	if buyTime < 1 then
		itemCell.view:getChildAutoType("frameLoader"):setGrayed(true)
		itemCell.view:getChildAutoType("iconLoader"):setGrayed(true)
		itemCell.view:getChildAutoType("effectLoader"):setVisible(false)
		txt_limitType:setColor(cc.c3b(120,120,120))
	else
		itemCell.view:getChildAutoType("frameLoader"):setGrayed(false)
		itemCell.view:getChildAutoType("iconLoader"):setGrayed(false)
		itemCell.view:getChildAutoType("effectLoader"):setVisible(true)
		txt_limitType:setColor(cc.c3b(255,132,41))
	end

	--时装商店展示不一样
	local fashionIcon = obj:getChildAutoType("fashionIcon/fashionIcon")
	if self.shopType == GameDef.ShopType.Fashion then
		local getRes 	= showData.getRes[1]
		local fashionId = getRes.code
		local heroId  	= FashionConfiger.getHeroIdByFashionId(fashionId)
		fashionIcon:setURL(PathConfiger.getHeroCardex(heroId,fashionId))
		itemCell.view:setVisible(false)
		name:setText("")
	else
		fashionIcon:setURL("")
		itemCell.view:setVisible(true)
	end

	--名字是新手引导查找商品用的，别删
	obj:setName(showData.id)
	
	obj:removeClickListener(33)--池子里面原来的事件注销掉
	obj:addClickListener(function(context)
		print(33,obj,context)
		if not ShopModel.redCheckMap[self.shopType] then
			ShopModel.redCheckMap[self.shopType] = {};
		end
		obj:getChildAutoType("img_red"):setVisible(false);
		ShopModel.redCheckMap[self.shopType][index] = true;
		if self.shopType == GameDef.ShopType.Character then
			ShopModel:upDateRed(self.shopType);
		end
		self:itemClick(index,obj)
	end,33)
	

	-- 维护单 #10424  特性书需要显示能激活的英雄（战力最高）头像 并添加红点
	local img_red = obj:getChildAutoType("img_red");
	local headCtrl = obj:getController("headCtrl");
	img_red:setVisible(false);
	headCtrl:setSelectedIndex(0);
	if (showData.shopType == 11 and buyTime > 0 and PlayerModel:isCostEnough(showData.costRes, false)) then
		local suggestPassive = DynamicConfigData.t_SuggestPassive;
		local heroConf = DynamicConfigData.t_hero;
		local skillId = showData.getRes[1].code - 10004000;
		local heroCode = false;
		for _, hero in ipairs(self.heroMap) do
			local suggestList = {}
			local hConf = heroConf[hero.code]
			local suggestId = hConf.suggestpassive;
			-- 高级特性技能推荐
			for _, id in ipairs (hConf.passiveSkill) do
				suggestList[id] = true
			end
			for _, id in ipairs (suggestPassive[suggestId].passivecombin) do
				suggestList[id] = true;
			end
			if (hero.hasBattle == 1 and suggestList[skillId] and not TalentModel:isLearnedTalent(hero, skillId)) then
				heroCode = hero.code
				if (not ShopModel.redCheckMap[self.shopType] or not ShopModel.redCheckMap[self.shopType][index]) then
					-- img_red:setVisible(true);
				end
				break;
			end
		end
		if heroCode then
			headCtrl:setSelectedIndex(1);
			obj:getChildAutoType("heroIcon"):setIcon(PathConfiger.getHeroCard(heroCode))
		end
	end

	-- #15259-【商城】在系统商店处增加贵族商店，根据VIP等级开启，同时VIP界面增加跳转。
	-- if self.shopType == GameDef.ShopType.Noble then -- 贵族商店
	-- 	local vipLevel = VipModel.level == -1 and 0 or VipModel.level
	-- 	local txt_vipLimit = obj:getChildAutoType("txt_vipLimit")
	-- 	local checkVip 	= obj:getController("checkVip")
	-- 	if showData and showData.vip then
	-- 		txt_vipLimit:setText(string.format(Desc.shop_vipLimitOpen,showData.vip))
	-- 		checkVip:setSelectedIndex(VipModel.level>=showData.vip and 1 or 0)
	-- 	end
	-- end
end

-- 点击打开购买界面
function ShopView:itemClick( index ,obj)
	local showData  = self.allShopData[index+1] 	-- 展示的信息
	local shopData 	= ShopModel:getReqShopDataById(showData.id,self.shopType)
	showData.obj = obj
	showData.index = index
	if self.shopType == GameDef.ShopType.Fashion then -- 皮肤商店特殊处理
		local getRes = showData.getRes[1]
		local costRes = showData.costRes[1]
		local fashionInfo = {
			reward 		= showData.getRes,
			fashionId 	= getRes.code,
			money  		= costRes.amount,
			shopId 		= showData.id,
			buyTime 	= shopData.buyTime,
			cost 	    = showData.costRes,
		}
		ViewManager.open("FashionShopTipsView",{fashionInfo = fashionInfo})
	else
		ViewManager.open("ShopItemTipsView", {showData = showData,buyTime=shopData.buyTime})
	end
end

-- 临界商店特殊处理
function ShopView:setCriticalShop()
	local criticalGroup = self.view:getChildAutoType("criticalGroup")
	local btn_attrEx 	= self.view:getChildAutoType("btn_attrEx")
	local txt_criticalTips = self.view:getChildAutoType("txt_criticalTips")
	local maskBg 		= self.view:getChildAutoType("maskBg")
	local frame 		= self.view:getChildAutoType("frame")
	local list 	= self.view:getChildAutoType("list")
	local categoryList 	= self.view:getChildAutoType("categoryList")
	local secondList 	= self.view:getChildAutoType("secondList")
	local shopList2 	= self.view:getChildAutoType("shopList2")
	local txt_criticalDesc = self.view:getChildAutoType("txt_criticalDesc")
	

	local curDifficulty = BoundaryMapModel:getPowerDifficult()
	local maxDifficulty = table.nums(DynamicConfigData.t_BoundaryNode)

	if self.shopType == GameDef.ShopType.Boundary then
		criticalGroup:setVisible(true)
		btn_attrEx:setVisible((curDifficulty ~= maxDifficulty))
		if (curDifficulty ~= maxDifficulty) then
			txt_criticalTips:setText(string.format(Desc.shop_criticalTips,curDifficulty+1))
			local config = DynamicConfigData.t_BoundaryDifficulty[curDifficulty + 1].unlock
			txt_criticalDesc:setText(string.format(Desc.shop_criticalDesc,config[1],config[2]))
		end
	else
		criticalGroup:setVisible(false)
	end

	btn_attrEx:removeClickListener(11)
	btn_attrEx:addClickListener(function()  
		maskBg:setVisible(not maskBg:isVisible())
		txt_criticalDesc:setVisible(maskBg:isVisible())
	end,11)

	frame:removeClickListener(11)
	frame:addClickListener(function()  
		maskBg:setVisible(false)
		txt_criticalDesc:setVisible(maskBg:isVisible())
	end,11)

	list:removeClickListener(11)
	list:addClickListener(function() 
		maskBg:setVisible(false)
		txt_criticalDesc:setVisible(maskBg:isVisible())
	end,11)

	categoryList:removeClickListener(11)
	categoryList:addClickListener(function() 
		maskBg:setVisible(false)
		txt_criticalDesc:setVisible(maskBg:isVisible())
	end,11)

	secondList:removeClickListener(11)
	secondList:addClickListener(function() 
		maskBg:setVisible(false)
		txt_criticalDesc:setVisible(maskBg:isVisible())
	end,11)

	shopList2:removeClickListener(11)
	shopList2:addClickListener(function() 
		maskBg:setVisible(false)
		txt_criticalDesc:setVisible(maskBg:isVisible())
	end,11)

end

-- 前往活动按钮
function ShopView:shopView_refreshActivityBtn()
	local showData = ShopModel:getShopItemInfoByType(self.shopType)
	local activityType = -1
	for k,v in pairs(showData) do
		activityType = v.relatedToActivity
		break
	end
	if activityType > 0 then
		local ActivityData ={}
		ActivityData = ActivityModel:getActityByType(activityType)
		local MallActivityData 	= DynamicConfigData.t_MallActivity
		local btn_goBtn 		= self.view:getChildAutoType("btn_goBtn") 	--前往活动
		self:countTime(activityType,self.shopType)
		btn_goBtn:removeClickListener(888)
		btn_goBtn:addClickListener(function()
			if ActivityData then
				ViewManager.close("ShopView")
				local periods = ModelManager.ShopModel.periods
				ModuleUtil.openModule(MallActivityData[activityType][self.shopType][periods].moduleOpen)
			else
				RollTips.show(Desc.shop_activityEnd)
			end
		end,888)
	end
end

-- 神秘商店倒计时
function ShopView:countTimeMystery()
	self:setMystery()
	if self.mysteryTimer then
		Scheduler.unschedule(self.mysteryTimer)
		self.mysteryTimer = false
	end

	local conf =  DynamicConfigData.t_MallUpData[self.shopType] 	
	local upDataTime = false  		-- 免费刷新时间间隔
	if conf and conf.upDataTime then
		upDataTime = conf.upDataTime
	end
	if not upDataTime or (not ShopModel.upShopTypeTime ) or (ShopModel.upShopTypeTime==0) then
		self.txt_timerTitle:setText("")
		self.txt_timer:setText("")
		return
	end

	local count = 0  	-- 已使用的刷新次数
	local otherLimit = 0 	-- 额外的免费次数

	if  ShopModel.shopList and ShopModel.shopList[self.shopType] and ShopModel.shopList[self.shopType].otherLimit then
		otherLimit = ShopModel.shopList[self.shopType].otherLimit
	end
	if ShopModel.shopList and ShopModel.shopList[self.shopType] and ShopModel.shopList[self.shopType].cout then
		count = ShopModel.shopList[self.shopType].cout
	end

	-- local serverTime = ServerTimeModel:getServerTime()  --当前服务器时间
	-- local countEndTime = ShopModel.upShopTypeTime+upDataTime 	-- 倒计时结束的时间搓

	-- local nowTime = countEndTime - serverTime + 2 	 	-- 要显示的时间


	-- local runTime =  ServerTimeModel:getServerTime() - ShopModel.upShopTypeTime
	-- runTime = math.mod(runTime, upDataTime)
	-- local lastTime = upDataTime - runTime

	local nowTime = (ShopModel.upShopTypeTime+upDataTime+2) - ServerTimeModel:getServerTime() 
	
	if nowTime > 0 and otherLimit <= conf.timeLimit and nowTime <= (upDataTime+2) then
		self.txt_timerTitle:setVisible(true)
		self.txt_timer:setVisible(true)
		self.txt_timerTitle:setText(Desc.shop_str1)
        local function onCountDown(dt)
            nowTime = nowTime - dt
            if not tolua.isnull(self.txt_timer) then
                self.txt_timer:setText(TimeLib.GetTimeFormatDay(math.floor(nowTime),2))
            end
			if nowTime <= 0 then
				if self.shopType == GameDef.ShopType.Limits and self.mysteryTimer and self.isEnd then
					self.isEnd = false
					ShopModel:reqShopData(self.shopType,false,nil)
				end
                Scheduler.unschedule(self.mysteryTimer)
                self.mysteryTimer = false
            end
		end
        if not tolua.isnull(self.txt_timer) then
            self.txt_timer:setText(TimeLib.GetTimeFormatDay(tonumber(nowTime),2))
        end
		self.mysteryTimer = Scheduler.schedule(function(dt)
            onCountDown(dt)
        end,0.1)
    else
        if self.mysteryTimer then
            Scheduler.unschedule(self.mysteryTimer)
            self.mysteryTimer = false
		end
		self.txt_timerTitle:setText("")
		self.txt_timer:setText("")
		self.txt_timerTitle:setVisible(false)
		self.txt_timer:setVisible(false)
    end

end

function ShopView:setMystery()
	local count = 0 

	local otherLimit = 0
	if  ShopModel.shopList and ShopModel.shopList[self.shopType] and ShopModel.shopList[self.shopType].otherLimit then
		otherLimit = ShopModel.shopList[self.shopType].otherLimit
	end
	if ShopModel.shopList and ShopModel.shopList[self.shopType] and ShopModel.shopList[self.shopType].cout then
		count = ShopModel.shopList[self.shopType].cout
	end

	if (otherLimit>=6) or (not ShopModel.upShopTypeTime) or (ShopModel.upShopTypeTime==0) or ((count - otherLimit) == 0) then
		self.txt_timerTitle:setVisible(false)
		self.txt_timer:setVisible(false)
		self.txt_timerTitle:setText("")
		self.txt_timer:setText("")
	else
		self.txt_timerTitle:setVisible(true)
		self.txt_timer:setVisible(true)
		self.txt_timerTitle:setText(Desc.shop_str1)
	end
end


-- 活动商店倒计时
function ShopView:countTime(activityType,shopType)
	local MallActivityData 		= DynamicConfigData.t_MallActivity
	local periods = ModelManager.ShopModel.periods
	local lastTime 				= ServerTimeModel:getOpenDateTime() + (MallActivityData[activityType][shopType][periods].maxServerOpenDay-1 ) * 86400 - (ServerTimeModel:getOpenDateTime() - TimeLib.GetDateStamp((ServerTimeModel:getOpenDateTime() - 86400)*1000)/1000) + 86400
	lastTime = lastTime - ServerTimeModel:getServerTime()

	if lastTime ~= -1 then
		if lastTime >0 then
	    	self.txt_activityTime:setText(TimeLib.GetTimeFormatDay(lastTime,2))
		    local function onCountDown( time )
		    	ShopModel.isActivityEnd = false
		    	self.txt_activityTime:setText(TimeLib.GetTimeFormatDay(time,2))
		    end
		    local function onEnd( ... )
		    	ShopModel.isActivityEnd = true
		    	self.txt_activityTime:setText(Desc.shop_exchangeEnd)
		    end
		    if self.timerActivity then
		    	TimeLib.clearCountDown(self.timerActivity)
		    end
		    self.timerActivity = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false,false)
	    else
	    	ShopModel.isActivityEnd = true
	    	self.txt_activityTime:setText(Desc.shop_exchangeEnd)
	    end
	end
end

-- 监听货币数量变化
-- function ShopView:money_change()
-- 	self:shop_refreshItem()
-- end

-- 监听物品数量变化
function ShopView:pack_item_change()
	self:shop_refreshItem()
end

-- 退出商城，清除计时器
function ShopView:_exit()
	if self.timer then
		TimeUtil.clearTime(self.timer)
	end
	if self.mysteryTimer then
		Scheduler.unschedule(self.mysteryTimer)
		self.mysteryTimer = false
	end

	if self.timerActivity then
		TimeUtil.clearTime(self.timerActivity)
	end
	Scheduler.unschedule(self.schedulerID)
	for i,v in ipairs(self.scheduler) do
		if self.scheduler[i] then
			Scheduler.unschedule(self.scheduler[i])
	        self.scheduler[i] = false
		end
	end
end

return ShopView