-- added by wyz 
-- 每日礼包

local TimeLib = require "Game.Utils.TimeLib"
local TimeUtil = require "Game.Utils.TimeUtil"
local DailyGiftBagView = class("DailyGiftBagView",Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器

function DailyGiftBagView:ctor()
	self._packName 	= "DailyGiftBag"
	self._compName 	= "DailyGiftBagView"

	self.timer 		 = false
	self.list_reward = false
	self.txt_countTimer = false
	self.btn_shop 	 = false
	self.btn_quickShop 	= false 
	self.txt_oldPrice 	= false
end

function DailyGiftBagView:_initUI()
	self.list_reward = self.view:getChildAutoType("list_reward")
	self.txt_countTimer = self.view:getChildAutoType("txt_countTimer")
	self.btn_shop 	= self.view:getChildAutoType("btn_shop")
	self.btn_shop:addClickListener(function()
		ModuleUtil.openModule(ModuleId.Shop_elite.id)
	end)
	self.btn_quickShop = self.view:getChildAutoType("btn_quickShop")
	self.txt_oldPrice = self.view:getChildAutoType("txt_oldPrice")
end


function DailyGiftBagView:_initEvent()
	self:DailyGiftBagView_refresh()
end

function DailyGiftBagView:DailyGiftBagView_refresh()
	local dayStr = DateUtil.getOppostieDays()
	FileCacheManager.setBoolForKey("DailyGiftBagView_isShow"..dayStr, true)
	DailyGiftBagModel:redCheck()
	RPCReq.Welfare_DailyGift_InfoReq({},function(params)
		if tolua.isnull(self.view) then return end
		self:refreshPanal()
		self:countTime()
	end)
end

function DailyGiftBagView:refreshPanal()
	local giftData = {}
	giftData = DailyGiftBagModel:sortData()
	-- printTable(8848,">>>giftData>>",giftData)
	local isBuy = false
	for k,v in pairs(giftData) do
		local times = v.buyTime
		if DailyGiftBagModel.data.recvList[v.giftId] then
			times = v.buyTime - DailyGiftBagModel.data.recvList[v.giftId].count
		end
		if times == 0 and v.price ~= 0 then
			isBuy = true
			break
		end
	end

	local oldPriceData = DynamicConfigData.t_DailyGiftBuy
	self.txt_oldPrice:setText(string.format(Desc.DailyGiftBag_quickShopOldPrice,oldPriceData[1].oldPrice))
	self.btn_quickShop:removeClickListener(11)
	self.btn_quickShop:getChildAutoType("title"):setText(string.format(Desc.DailyGiftBag_quickShopPrice,oldPriceData[1].price))
	self.btn_quickShop:addClickListener(function()
		if isBuy then
			RollTips.show(Desc.DailyGiftBag_giftOut)
			return
		end
		ModelManager.RechargeModel:directBuy(oldPriceData[1].price,  GameDef.StatFuncType.SFT_OneKeyDailyGift, oldPriceData[1].id,"onekey",nil, oldPriceData[1].showName1)
	end,11)

	self.list_reward:setItemRenderer(function(idx,obj)
		local data 	= giftData[idx+1]
		local title = obj:getChildAutoType("title")
		local discountCtrl 	= obj:getController("discountCtrl")
		local takeCtrl 		= obj:getController("takeCtrl")
		local txt_times 	= obj:getChildAutoType("txt_times")
		local btn_take 		= obj:getChildAutoType("btn_take")
		local list_reward 	= obj:getChildAutoType("list_reward")
		local txt_zhe 		= obj:getChildAutoType("txt_zhe")

		local rewardData 	= data.reward
		-- printTable(8848,">>>rewardData>>",rewardData)
		local discount  	= data.discount
		local img_red 		= btn_take:getChildAutoType("img_red")

		RedManager.register("V_DAILYGIFTBAG"..data.price, img_red)

		if discount ~= 0 and discount ~= 10 then
			discountCtrl:setSelectedIndex(0)
			txt_zhe:setText(string.format(Desc.DailyGiftBag_disCount,data.discount))
		else
			discountCtrl:setSelectedIndex(1)
		end

		local times = data.buyTime
		if DailyGiftBagModel.data.recvList[data.giftId] then
			times = data.buyTime - DailyGiftBagModel.data.recvList[data.giftId].count
		end

		title:setText(data.name)
		txt_times:setText(string.format(Desc.DailyGiftBag_times,times,data.buyTime))

		if times == 0 then
			takeCtrl:setSelectedIndex(2)
			btn_take:setTitle(Desc.DailyGiftBag_soldOut)
		elseif data.price == 0 and not DailyGiftBagModel.data.recvList[data.giftId] then 
			takeCtrl:setSelectedIndex(1)
			btn_take:setTitle(Desc.DailyGiftBag_take)
		else
			takeCtrl:setSelectedIndex(0)
			btn_take:setTitle(string.format(Desc.DailyGiftBag_money,data.price))
		end 

		list_reward:setItemRenderer(function(idx2,obj2)
			local reward 	= rewardData[idx2+1]
			local itemCell 	= BindManager.bindItemCell(obj2)
			itemCell:setData(reward.code, reward.amount, reward.type)
			local dataShow = DynamicConfigData.t_DailyGift[data.giftId]
			local showDouble = dataShow.doubleShow and reward.type == CodeType.MONEY and reward.code == GameDef.MoneyType.Diamond
			itemCell:setShowDouble(showDouble)
		end)
		list_reward:setData(rewardData)

		btn_take:removeClickListener(888)
		btn_take:addClickListener(function()
			if data.price == 0 then
				RPCReq.Welfare_DailyGift_Reward{id = data.giftId}
			else
				ModelManager.RechargeModel:directBuy(data.price,  GameDef.StatFuncType.SFT_DailyGift, data.giftId, data.name,nil, data.showName1)
			end
		end,888)
	end)
	-- printTable(8848,"giftData",giftData)
	self.list_reward:setData(giftData)
end

function DailyGiftBagView:countTime()
	if self.timer then
		TimeUtil.clearTime(self.timer)
	end
	local time = ServerTimeModel:getTodayLastSeconds()
	self.timer = TimeUtil.upText(self.txt_countTimer,time - 1,"%s")
	self.txt_countTimer:setText(TimeLib.formatTime(time - 1))
end

function DailyGiftBagView:_exit()
	if self.timer then
		TimeUtil.clearTime(self.timer)
	end
end

return DailyGiftBagView