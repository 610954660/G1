-- added by wyz 
-- 每日礼包

local TimeLib = require "Game.Utils.TimeLib"
local TimeUtil = require "Game.Utils.TimeUtil"
local MonthlyGiftBagView = class("MonthlyGiftBagView",Window)

function MonthlyGiftBagView:ctor()
	self._packName 	= "MonthlyGiftBag"
	self._compName 	= "MonthlyGiftBagView"

	self.timer 		 = false
	self.list_reward = false
	self.txt_countTimer = false
	self.banner 	 = false
end

function MonthlyGiftBagView:_initUI()
	self.list_reward = self.view:getChildAutoType("list_reward")
	self.txt_countTimer = self.view:getChildAutoType("txt_countTimer")
	self.banner  		= self.view:getChildAutoType("banner")
	self.banner:setURL("UI/MonthlyGiftBag/img_meiyue_banner.png")
end


function MonthlyGiftBagView:_initEvent()
	self:MonthlyGiftBagView_refresh()
end

function MonthlyGiftBagView:MonthlyGiftBagView_refresh()
	local dayStr = DateUtil.getOppostieDays()
	FileCacheManager.setBoolForKey("MonthlyGiftBagView_isShow"..dayStr, true)
	MonthlyGiftBagModel:redCheck()
	self:refreshPanal()
	self:countTime()
end

function MonthlyGiftBagView:refreshPanal()
	local giftData = {}
	giftData = MonthlyGiftBagModel:sortData()
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
		local discount  	= data.discount
		local img_red 		= btn_take:getChildAutoType("img_red")

		RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.MoonGift ..data.price, img_red)

		if discount ~= 0 and discount ~= 10 then
			discountCtrl:setSelectedIndex(0)
			txt_zhe:setText(string.format(Desc.DailyGiftBag_disCount,data.discount))
		else
			discountCtrl:setSelectedIndex(1)
		end

		local times = 0 
		if data.buyTimes and MonthlyGiftBagModel.data and MonthlyGiftBagModel.data[data.giftId] and MonthlyGiftBagModel.data[data.giftId].buyTimes then
			times = data.buyTimes - MonthlyGiftBagModel.data[data.giftId].buyTimes
		end

		title:setText(data.name)
		txt_times:setText(string.format(Desc.WeeklyGiftBag_times,times,data.buyTimes))

		if times == 0 then
			takeCtrl:setSelectedIndex(2)
			btn_take:setTitle(Desc.DailyGiftBag_soldOut)
		elseif data.price == 0 and (not (MonthlyGiftBagModel.data[data.giftId].buyTimes >= data.buyTimes) or times > 0) then 
			takeCtrl:setSelectedIndex(1)
			btn_take:setTitle(Desc.WeeklyGiftBag_takeFree)
		else
			takeCtrl:setSelectedIndex(0)
			btn_take:setTitle(string.format(Desc.DailyGiftBag_money,data.price))
		end 

		list_reward:setItemRenderer(function(idx2,obj2)
			local reward 	= rewardData[idx2+1]
			local itemCell 	= BindManager.bindItemCell(obj2)
			itemCell:setData(reward.code, reward.amount, reward.type)
		end)
		list_reward:setData(rewardData)

		btn_take:removeClickListener(888)
		btn_take:addClickListener(function()
			if data.price == 0 then
				RPCReq.Activity_MoonGift_Reward{id = data.giftId}
			else
				ModelManager.RechargeModel:directBuy(data.price,  GameDef.StatFuncType.SFT_BuyMoonGift, data.giftId, data.name, nil, data.showName1)
			end
		end,888)
	end)
	self.list_reward:setData(giftData)
end

function MonthlyGiftBagView:countTime()
	local lastTime = TimeLib.nextMonthBeginTime() - ServerTimeModel:getServerTime()
	if not tolua.isnull(self.txt_countTimer) then
		self.txt_countTimer:setText(TimeLib.GetTimeFormatDay(lastTime,2))
	end
	local function onCountDown( time )
		if not tolua.isnull(self.txt_countTimer) then
			self.txt_countTimer:setText(TimeLib.GetTimeFormatDay(time,2))
		end
    end
	local function onEnd( ... )
		if self.timer then
			TimeLib.clearCountDown(self.timer)
		end
    	self:MonthlyGiftBagView_refresh()
    end
    if self.timer then
    	TimeLib.clearCountDown(self.timer)
    end
    self.timer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false,false)
end

function MonthlyGiftBagView:_exit()
	if self.timer then
    	TimeLib.clearCountDown(self.timer)
    end
end

return MonthlyGiftBagView