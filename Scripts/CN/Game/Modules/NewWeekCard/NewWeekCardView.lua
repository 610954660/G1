-- added by wyz
-- 周卡

local NewWeekCardView 	= class("NewWeekCardView",Window)
local ItemConfiger 	= require "Game.ConfigReaders.ItemConfiger" 

function NewWeekCardView:ctor()
	self._packName 	= "NewWeekCard"
	self._compName	= "NewWeekCardView" 
	self._rootDepth = LayerDepth.PopWindow

	self.txt_countTitle  = false 	-- 倒计时标题
	self.txt_countTime 	 = false 	-- 倒计时文本
	self.btn_buy 		 = false 	-- 购买按钮
	self.txt_rebackPrice = false 	-- 返利文本
	self.list_page 		 = false 	-- 页签列表
	self.txt_state 		 = false 	-- 活动已结束文本
	self.txt_accDays	 = false 	-- 累计登陆多少天

	self.isBuy 	 		 = false 	-- 是否购买
	self.timer 			 = false
	self.giftState 		 = {}

	self.pageIndex 		 = 1
	self.isEnd   		 = false
end

function NewWeekCardView:_initUI()
	self.txt_rebackPrice = self.view:getChildAutoType("txt_rebackPrice")
	self.txt_countTitle	 = self.view:getChildAutoType("txt_countTitle")
	self.txt_countTime 	 = self.view:getChildAutoType("txt_countTime")
	self.btn_buy 		 = self.view:getChildAutoType("btn_buy")
	self.list_page 		 = self.view:getChildAutoType("list_page")
	self.txt_state 		 = self.view:getChildAutoType("txt_state")
	self.txt_accDays 	 = self.view:getChildAutoType("txt_accDays")
end

function NewWeekCardView:_initEvent()
	self:NewWeekCardView_refreshPanal()
end

function NewWeekCardView:NewWeekCardView_refreshPanal()
	self:setPageList()
end

function NewWeekCardView:setPageList()
	local pageData = ModelManager.NewWeekCardModel:getPageData()
	self.list_page:setSelectedIndex(self.pageIndex - 1)
	printTable(8848,">>pageData>>",pageData)
	self:setRewardList(pageData[self.pageIndex].level,pageData[self.pageIndex].price,pageData[self.pageIndex].discount, pageData[self.pageIndex].showName1)
	self.list_page:setItemRenderer(function(idx,obj)
		local index = idx + 1
		local data  = pageData[index]
		local gear  = data.level  	-- 档位
		local title = obj:getChildAutoType("title")
		local img_red = obj:getChildAutoType("img_red")
		title:setText(string.format(Desc.NewWeekCard_price,data.price))
		RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.NewWeekCard.. gear, img_red)
	end)
	self.list_page:setData(pageData)
	self.list_page:removeClickListener(111)
	self.list_page:addClickListener(function()
		if self.isEnd then
			self.list_page:setSelectedIndex(self.pageIndex - 1)
			RollTips.show(Desc.NewWeekCard_end)
			return
		end
		local pageIndex = self.list_page:getSelectedIndex() + 1
		local data = pageData[pageIndex]
		self.pageIndex = pageIndex
		-- 刷新列表
		local gear = data.level  	-- 档位
		local price = data.price
		local discount = data.discount
		self:setRewardList(gear,price,discount,data.showName1)
	end,111)
end

function NewWeekCardView:setRewardList(gear,price,discount,showName)
	local rewardData = ModelManager.NewWeekCardModel:getRewardData(gear)
	local isBuy   = ModelManager.NewWeekCardModel:getGiftBuyState(gear)
	local startTime = ModelManager.NewWeekCardModel:getGiftStartTime(gear)
	local reachDay 	= ModelManager.ServerTimeModel:getDay(startTime) + 1-- 达成天数
	print(8848,">>>>>>>>>>>>>>>>达成天数>>>>>>",reachDay)
	self.txt_rebackPrice:setText(discount.."%")
	local sp1 = {}
	for i=1,7 do
		local obj 	= self.view:getChildAutoType(string.format("item_%s",i))
		local effectLoader = obj:getChildAutoType("effectLoader")
		effectLoader:displayObject():removeAllChildren()
		sp1[i] = false
	end
	for i=1,7 do
		local obj 	= self.view:getChildAutoType(string.format("item_%s",i))
		local data 	= rewardData[i]
		local takeCtrl = obj:getController("takeCtrl") -- 0 未领取 1 可领取 2 已领取 3 已达成
		local txt_day  = obj:getChildAutoType("txt_day")
		local txt_day2 = obj:getChildAutoType("txt_day2")
		local txt_name = obj:getChildAutoType("txt_name")
		local itemCell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
		local txt_tips = obj:getChildAutoType("txt_tips")
		local img_red  = obj:getChildAutoType("img_red")
		local tipsCtrl = obj:getController("tipsCtrl")
		local reward = data.reward[1]
		itemCell:setData(reward.code,reward.amount,reward.type)
		RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.NewWeekCard.. gear .. i, img_red)
		local effectLoader = obj:getChildAutoType("effectLoader")
		local x1 = effectLoader:getWidth() / 2;
		local y1 = effectLoader:getHeight() / 2;
		
		tipsCtrl:setSelectedIndex(0)
		txt_day:setText(data.day)
		txt_day2:setText(data.day)
		txt_name:setText(ItemConfiger.getItemNameByCode(reward.code))
		local takeState = data.state
		if not isBuy and i <= reachDay then
			takeState = 3
			if i == reachDay then
				txt_tips:setText(string.format(Desc.WeekCard_tips,reachDay))
				tipsCtrl:setSelectedIndex(1)
			else
				tipsCtrl:setSelectedIndex(0)
			end
		end



		takeCtrl:setSelectedIndex(takeState)
		itemCell:setIsHook(takeState == 2 and true or false)

		obj:getChildAutoType("itemCell"):setTouchable(takeState == 1 and false or true)
		obj:getChildAutoType("itemCell"):setTouchable(true)
		if takeState == 1 then
			obj:getChildAutoType("itemCell"):setTouchable(false)
			sp1[i] = SpineUtil.createSpineObj(effectLoader, cc.p(x1, y1), "ui_zhoukalingqu", "Effect/UI", "efx_heijinzhouka", "efx_heijinzhouka", true);
		else
			obj:getChildAutoType("itemCell"):setTouchable(true)
		end

		obj:removeClickListener(888)
		obj:addClickListener(function()
			if self.isEnd then
				RollTips.show(Desc.NewWeekCard_end)
				return
			end
			print(8848,">>>领取奖励被点击>>>")
			if takeState ==  3 then
				RollTips.show(Desc.NewWeekCard_shopTips)
				return 
			end
			if self.giftState[gear] then
				if isBuy and takeState == 1 then
					RollTips.show(Desc.NewWeekCard_rewardEnd)
				else 
					RollTips.show(Desc.NewWeekCard_end)
				end
				return
			end
			local reqInfo = {
				level 	= gear,
				day 	= data.day,
			}
			printTable(8848,">>>reqInfo>>",reqInfo)
			RPCReq.Activity_NewWeekCard_Recieve(reqInfo,function(params)
				effectLoader:displayObject():removeAllChildren()
				sp1[i] = false
			end)
		end,888)
	end

	local buyCtrl = self.view:getController("buyCtrl")
	buyCtrl:setSelectedIndex(isBuy and 1 or 0)
	-- self.btn_buy:setVisible(not self.isBuy)
	self.btn_buy:getChildAutoType("title"):setText(string.format(Desc.WeekCard_price,price))
	self.btn_buy:removeClickListener(888)
	self.btn_buy:addClickListener(function()
		if self.isEnd then
			RollTips.show(Desc.NewWeekCard_end)
			return
		end
		if self.giftState[gear] then
			RollTips.show(Desc.NewWeekCard_end)
			return
		end
		print(8848,">>>>price>>>gear>>>>",price,gear)
		ModelManager.RechargeModel:directBuy(price, GameDef.StatFuncType.SFT_NewWeekCard,gear,Desc.NewWeekCard_name,nil, showName)
	end,888)

	local giftEndTime = ModelManager.NewWeekCardModel:getGiftEndTime(gear)
	-- if self.timer then
	-- 	TimeLib.clearCountDown(self.timer)
	-- end
	self:countTime(gear,giftEndTime)
end

function NewWeekCardView:countTime(gear,giftEndTime)
	if self.isEnd then
		self.txt_countTime:setText(Desc.NewWeekCard_end)
		return
	end
	local serverTime = ServerTimeModel:getServerTimeMS()
	print(8848,">>>giftEndTime>>>serverTime>>>",giftEndTime,serverTime)
    giftEndTime = (giftEndTime-serverTime)/1000
    -- print(8848,"lastTime",lastTime)

	printTable(8848,">>>giftEndTime>>",giftEndTime)
	if giftEndTime > 0 then
		self.txt_countTime:setText(TimeLib.GetTimeFormatDay(giftEndTime,2))
		local function onCountDown( time )
			self.txt_countTime:setText(TimeLib.GetTimeFormatDay(time,2))
		end
		local function onEnd( ... )
			-- self.txt_countTime:setVisible(false)
			self.giftState[gear] = true
			self.txt_countTime:setText(Desc.NewWeekCard_end)
			self.isEnd = true
		end
		if self.timer then
			TimeLib.clearCountDown(self.timer)
		end
		self.timer = TimeLib.newCountDown(giftEndTime, onCountDown, onEnd, false, false,false)
	else
		-- self.txt_countTime:setVisible(false)
		self.giftState[gear] = true
		self.txt_countTime:setText(Desc.NewWeekCard_end)
	end
end


function NewWeekCardView:_exit()
	if self.timer then
		TimeLib.clearCountDown(self.timer)
	end
end


return NewWeekCardView