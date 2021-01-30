local BaseModel = require "Game.FMVC.Core.BaseModel"
local ShopModel = class("PlayerModel", BaseModel)

function ShopModel:ctor()
	print(8848,"ShopModel ctor")
	self.limitList = {}
	self.discountList = {}
	self.dictFile = false
	self.shopList = {}
	self.realNameInfo = false
	self.isActivityEnd = false  -- 用来判断活动是否已经结束
	self.isShop 	= false 	-- 判断是不是购买了某个商品，用来判断要不要播放动画 
	self.refreshFlag = false		
	self.activityTypeIndex = false
	self.periods 	 = false 	-- 活动期数
	self.redCheckMap = {}  -- 记录按钮红点，点击按钮会消失，所以记录一下，点过的就不检测红点了，
	self.upShopTypeTime = false
end

function ShopModel:init()
	self:_initListeners()
end

function ShopModel:_initListeners()
	self:initListeners()
end

-- 商城刷新按钮是否弹提示框  （保存状态)
function ShopModel:setCheckTips(index)
	local dayStr = DateUtil.getOppostieDays()
	index = index or FileCacheManager.getIntForKey("ShopView_isCheckTips" .. dayStr,0)
	FileCacheManager.setIntForKey("ShopView_isCheckTips" .. dayStr,index)
end

-- 通过type和id获取具体某个商品的信息
function ShopModel:getShopItemInfo(type,id)
	if not DynamicConfigData.t_MallTotal[type] then
		if DynamicConfigData.t_MallCollectActivity and DynamicConfigData.t_MallCollectActivity[type] and DynamicConfigData.t_MallCollectActivity[type][id] then
			return DynamicConfigData.t_MallCollectActivity[type][id]
		end
	else
		if DynamicConfigData.t_MallTotal and DynamicConfigData.t_MallTotal[type] and DynamicConfigData.t_MallTotal[type][id] then
			return DynamicConfigData.t_MallTotal[type][id]
		end
	end
end

-- 获取展示商品的所有信息
function ShopModel:getShopInfoByType(shopType,category)
	local shopData = self:getShopList(shopType)
	local shopInfo = {} 	 	-- 所有的商品
	local heroCombine = DynamicConfigData.t_heroCombine	
	for k,v in pairs(shopData) do
		local shopId 	= v.id
		local data = self:getShopItemInfo(shopType,shopId)
		local category = 0 
		if not shopInfo[k] then
			shopInfo[k] = {}
		end
		shopInfo[k] = data
		shopInfo[k].category = 0
		local getRes = shopInfo[k].getRes[1]
		if heroCombine[getRes.code] then
			shopInfo[k].category = heroCombine[getRes.code].category
		end
	end
	if category == 0 or not category then
		local keys = {
			{key = "sortKey",asc = false},
		}
		TableUtil.sortByMap(shopInfo,keys)
		return shopInfo or {}
	else
		local shopInfo2 = {} 	-- 根据种族筛选显示商品
		for k,v in pairs(shopInfo) do
			if v.category == category then
				table.insert(shopInfo2,v)
			end
		end
		local keys = {
			{key = "sortKey",asc = false},
		}
		TableUtil.sortByMap(shopInfo2,keys)
		return shopInfo2 or {}
	end
end

-- 通过商品id获取服务端下推商品的信息
function ShopModel:getReqShopDataById(shopId,shopType)
	local shopData = self:getShopList(shopType)
	for k,v in pairs(shopData) do
		if v.id == shopId then
			return v
		end
	end
	return {}
end


-- 通过type获取对应类型的商品数据
function ShopModel:getShopItemInfoByType(type)
	if not DynamicConfigData.t_MallTotal[type] then
		return DynamicConfigData.t_MallCollectActivity[type]
	else
		return DynamicConfigData.t_MallTotal[type]
	end
end

-- 请求商品数据
function ShopModel:reqShopData(shopType,fresh,activityType)
	RPCReq.Shop_GetMallInfo({shopType = shopType,activityType=activityType})
end


function ShopModel:haddleShopData(data)
	if data  == nil or next(data) == nil then
		return
	end
end

-- 进入游戏默认请求商品类型1的数据
function ShopModel:public_enterGame()
	self:reqShopData(1,false,-1)
	if (ModuleUtil.hasModuleOpen(ModuleId.Shop_Talent.id)) then
		self:reqShopData(11, nil, 0)
	end
end

-- 获取商品列表
function ShopModel:getShopList(shopType)
	local shopList = {}
	if self.shopList[shopType]  then
		local list = self.shopList[shopType].list
		for k,v in pairs(list) do
			if v.buyTime == 0 then
				v.sellout = 1
			end
			if self:getShopItemInfo(shopType,v.id) then
				table.insert(shopList, v)
			end
		end
	end
	local keys ={
			{key = "sortKey",asc = false},
	}
	TableUtil.sortByMap(shopList, keys)
	return shopList
end

-- 获取默认商店类型
function ShopModel:getMallType()
	local mallData = DynamicConfigData.t_mall
	if not mallData[1][1].shopArr[1] then return end
	return mallData[1][1].shopArr[1]
end

-- 服务器下推的商城数据
function ShopModel:updateShopData(data)
	self:setCheckTips()
	if data then 
		if data.shopType == 1 then
			local ll =1 
		end
		self.upShopTypeTime = data.upShopTypeTime or 0
		local list = {}
		for _,v in pairs(data.list) do
			v.sellout 	= 0 	-- 没卖完
			if v.buyTime == 0 then
				v.sellout = 1 	-- 卖完了
			end
			table.insert(list, v)
		end
		data.list = list
		self.shopList[data.shopType] = data
		-- 红点 10.12号版本
		self:upDateRed(data.shopType)
		Dispatcher.dispatchEvent(EventType.shop_refreshItem)
	end
end

-- 获取活动开启的个数
function ShopModel:getOpenActivityNum()
	local MallCollectActivityData 	= DynamicConfigData.t_MallCollectActivity 		 -- 活动商店的配置信息
	local MallActivityData 			= DynamicConfigData.t_MallActivity 				 -- 活动开启的配置信息
	local activityNum 				= TableUtil.GetTableLen(MallCollectActivityData) -- 活动的个数
	local num = 0
	for k,v in pairs(MallCollectActivityData) do
		local data = MallCollectActivityData[k]
		for o,p in pairs(data) do
			local activityData = {}
			activityData = MallActivityData[p.relatedToActivity][k][p.periods]
			if activityData then
				local openDay = ServerTimeModel:getOpenDay() + 1
				local minServerOpenDay = activityData.minServerOpenDay
				local maxServerOpenDay = activityData.maxServerOpenDay
				if openDay >= minServerOpenDay and openDay < maxServerOpenDay then
					self.activityTypeIndex = k
					self.periods = p.periods
					num = num + 1
					break
				end
			end
		end
	end
	return num
end

function ShopModel:checkActivityType(shopType)
	for k,v in pairs(DynamicConfigData.t_mall) do
		for o,p in pairs(v) do
			if shopType >= p.shopArr[1] and shopType <= p.shopArr[#p.shopArr] and self.activityTypeIndex >= p.shopArr[1] and self.activityTypeIndex <= p.shopArr[#p.shopArr] then
				return self.activityTypeIndex
			end
		end
	end
	return false
end

-- 判断是不是活动
function ShopModel:checkIsActivityByType(shopType)
	local isActivity = false 	-- 是不是活动
	for ik,iv in pairs(DynamicConfigData.t_MallActivity) do
		for jk,jv in pairs(iv) do
			for kk,kv in pairs(jv) do
				if kv.shopType == shopType then
					return true
				end
			end
		end
	end
	return isActivity
end

-- 获取商品开放条件范围
function ShopModel:getSellLimit(shopType)
	local minDay = -1
	local maxDay = -1
	local type = -1
	for ik,iv in pairs(DynamicConfigData.t_MallTotal[shopType]) do
		if #(iv.sellCtrl) > 0 then
			type = iv.sellCtrl[1]
			local nowNum
			if type == 1 then
				if not nowNum then
					nowNum = ModelManager.PataModel:getPataFloor(GameDef.GamePlayType.NormalTower)
				end
			end
			if not nowNum then nowNum = 0 end
			if nowNum < iv.sellCtrl[2] and (minDay == -1 or minDay > iv.sellCtrl[2])  then
				minDay = iv.sellCtrl[2]
			end
			
			if nowNum  < iv.sellCtrl[2] and (maxDay == -1 or maxDay < iv.sellCtrl[2]) then
				maxDay = iv.sellCtrl[2]
			end
		end
	end
	return type,minDay,maxDay
end


-- 更新红点
function ShopModel:upDateRed(shopType)
	-- GlobalUtil.delayCallOnce("ShopModel:upDateRed", function ()
		-- if shopType ~= 1 and shopType ~= 11 then return end
		if shopType ~= GameDef.ShopType.Limits then return end
		local costConfig = DynamicConfigData.t_mallRefreshCost
		local mallConfig = DynamicConfigData.t_mall
		local costCf =  costConfig and costConfig[shopType] or false
		local index = 0
		local keyArr = {}
		for i=1,#mallConfig do
			local keyArr2 =  {}
			for j = 1,#mallConfig[i] do
				local shopArr = mallConfig[i][j].shopArr
				for k,v in pairs(shopArr) do
					if v == shopType then
						index = i
					end
					table.insert(keyArr2,"V_SHOP_DISCOUNT" .. i .. v)
				end
			end
			table.insert(keyArr,"V_SHOP_DISCOUNT" .. i)
			RedManager.addMap("V_SHOP_DISCOUNT"..i, keyArr2)
		end
		RedManager.addMap("V_SHOP_DISCOUNT", keyArr)

		if costCf then
			local flag = self.shopList and self.shopList[shopType] and self.shopList[shopType].cout
			if not flag then return end
			local count = self.shopList[shopType].cout
			local otherLimit = self.shopList[shopType].otherLimit or 0
			local rMoney = nil
			local max  = {type=2,code = 1,amount = -1}
			for k,v in pairs(costCf) do
				if count>=v.timeStart and count<=v.timeEnd then
					rMoney = v.cost[1]
				end
				if max.amount < v.cost[1].amount then
					max = v.cost[1]
				end
			end
			if not rMoney then rMoney = max end
			local redFlag = rMoney.amount == 0;
			if (shopType == GameDef.ShopType.Character) then
				local shopData = self:getShopList(shopType)--self.shopList[shopType].list
				CardLibModel:setCardsByCategory(0);
				local heroMap = CardLibModel:getHeroInfoToIndex(true, 3);
				local heroConf = DynamicConfigData.t_hero;
				for i, info in pairs(shopData) do
					local goods = self:getShopItemInfo(11, info.id);
					local id = goods.getRes[1].code - 10004000;
					if ((not self.redCheckMap[shopType] or not self.redCheckMap[shopType][i - 1]) and info.buyTime > 0 and PlayerModel:isCostEnough(goods.costRes, false)) then
						local f = false;
						for _, hero in ipairs(heroMap) do
							local hConf = heroConf[hero.code]
							local suggestList = {}
							for _, id in ipairs (hConf.passiveSkill) do
								suggestList[id] = true
							end
							if (hero.hasBattle == 1 and suggestList[id] and not TalentModel:isLearnedTalent(hero, id)) then
								f = true;
								break;
							end
						end
						if (f) then 
							redFlag = redFlag or f;
							break 
						end
					end
				end
			end
			RedManager.updateValue("V_SHOP_DISCOUNT" .. index .. shopType, redFlag or otherLimit > 0)
		end
	-- end, self, 0.1)
end

-- function ShopModel:loginPlayerDataFinish()
-- 	self:reqShopData(11, nil, 0)
-- end

return ShopModel
