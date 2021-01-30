local V, Super = class("AccumulativeDayActivityView", Window)
local AccumulativeDayActivityConfiger = require "Game.ConfigReaders.AccumulativeDayActivityConfiger"
local ItemCell = require "Game.UI.Global.ItemCell"

local function setClickListenerFor(view, listener)
	view:removeClickListener(0)
	view:addClickListener(listener, 0)
end

function V:ctor()
	--LuaLog("SevenDayActView ctor")
	self._packName = "AccumulativeDayActivity"
	self._compName = "AccumulativeDayActivityView"
	self.txt_countDown = false;
	self.timer = false;
	self.list_type = false;
	self.pageIndex = 1   -- 礼包索引
end

function V:_initUI()
	self.tvPayHint = self.view:getChildAutoType("tvPayHint")
	self.tvAlreadyPayDay = self.view:getChildAutoType("tvAlreadyPayDay")
	self.itemCellBig = self.view:getChildAutoType("itemCellBig")
	self.itemCell1 = self.view:getChildAutoType("itemCell1")
	self.itemCell2 = self.view:getChildAutoType("itemCell2")
	self.itemCell3 = self.view:getChildAutoType("itemCell3")
	self.tvDayBig = self.view:getChildAutoType("tvDayBig")
	self.tvDay1 = self.view:getChildAutoType("tvDay1")
	self.tvDay2 = self.view:getChildAutoType("tvDay2")
	self.tvDay3 = self.view:getChildAutoType("tvDay3")
	self.rewardsList = self.view:getChildAutoType("rewardsList")
	self.list_type = self.view:getChildAutoType("list_type")

	
	local pageData = AccumulativeDayActivityConfiger:getPageConfig(self.pageIndex)
	self.list_type:setSelectedIndex(self.pageIndex-1)
	self.list_type:setItemRenderer(function(idx,obj)
		local index = idx + 1
		local data 	= pageData[index]
		local title = obj:getChildAutoType("title")
		title:setText(string.format(Desc.AccumulativeDay_pageName,data.lowestCharge))
		
		local img_red 	= obj:getChildAutoType("img_red")
		RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.AccumulativeDay.. index, img_red)
	end)
	self.list_type:setData(pageData)

	self.list_type:removeClickListener(11)
	self.list_type:addClickListener(function()
		local index = self.list_type:getSelectedIndex() + 1
		self.pageIndex = index
		self:update()
	end,11)

	--
	self.rewardsList:setItemRenderer(function(index, view)
		self:__renderRewardsItem(index+1, view)
	end)
	self.rewardsList:setVirtual()

	self:update()
end

function V:_initEvent( )
	-- TODO
end

function V:__renderRewardsItem(index, view)
	local config = self.__rewardsListData[index]

	-- 满足条件
	local tvCondition = view:getChildAutoType("tvCondition")
	tvCondition:setText(string.format(Desc.AccumulativeDay_accDay, config.day)) -- TODO

	-- 按钮状态
	local btnGet = view:getChildAutoType("btnGet")
	local btnGoto = view:getChildAutoType("btnGoto")
	local statusController = view:getController("status")
	local status = AccumulativeDayActivityModel:getRewardStatus(self.pageIndex,config.day)

	local img_red 	= btnGet:getChildAutoType("img_red")
	RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.AccumulativeDay.. self.pageIndex .. config.day, img_red)

	if status == 0 then -- 不可领取
		local currentAccumulativeDay = AccumulativeDayActivityModel:getCurrentAccumulativeDay(self.pageIndex)
		if currentAccumulativeDay + 1 == config.day and TimeLib.getTotalDays() > TimeLib.getTotalDays(AccumulativeDayActivityModel:getLastChangeTime(self.pageIndex)) then -- 前往
			statusController:setSelectedPage("goto")
			setClickListenerFor(btnGoto, function()
				--ModuleUtil.openModule(ModuleId.Recharge.id, true)
				ModuleUtil.openModule(ModuleId.DailyGiftBag)
			end)
		else -- 未开启
			statusController:setSelectedPage("unavailable")
		end
	elseif status == 1 then -- 可领取
		statusController:setSelectedPage("get")
		setClickListenerFor(btnGet, function()
			AccumulativeDayActivityModel:getReward(config.day,self.pageIndex)
		end)
	elseif status == 2 then -- 已领取
		statusController:setSelectedPage("got")
	end

	-- 奖励
	local rewardList = view:getChildAutoType("rewardList")
	rewardList:setVirtual()
	rewardList:setItemRenderer(function(index, itemCell)
		index = index + 1
		itemCell = BindManager.bindItemCell(itemCell)
		--local itemData = ItemsUtil.createItemData({data = })
		local data = config.reward[index]
		itemCell:setData(data.code, data.amount, data.type)
	end)
	rewardList:setNumItems(#config.reward)
end

function V:update()
	local config = AccumulativeDayActivityConfiger:getCurrentConfig(self.pageIndex)
	if not config then return end
	-- 充值
	self.tvPayHint:setText(string.format("%d", config.lowestCharge*10))

	-- 已充值天数
	local currentDay = AccumulativeDayActivityModel:getCurrentAccumulativeDay(self.pageIndex)
	local maxDay = AccumulativeDayActivityConfiger:getMaxDay(self.pageIndex)
	self.tvAlreadyPayDay:setText(string.format(Desc.AccumulativeDay_rechargeDay, currentDay, maxDay)) -- TODO

	-- 稀有奖励物品
	local num = math.min(#config.dayShow, #config.itemShow)
	for index = 1, num do
		local itemCell = string.format("itemCell%d", index)
		itemCell = self[itemCell]
		local tvDay = string.format("tvDay%d", index)
		tvDay = self[tvDay]
		--
		itemCell = BindManager.bindItemCell(itemCell)
		local data = config.itemShow[index]
		--local itemData = ItemsUtil.createItemData({})
		itemCell:setData(data.code, data.amount, data.type)
		--
		tvDay:setText(string.format(Desc.AccumulativeDay_day, config.dayShow[index])) -- TODO
	end

	-- 特别奖励物品
	local itemCellBig = BindManager.bindItemCell(self.itemCellBig)
	--itemCellBig:setIsBig(true)
	local data = config.specialItem[1]
	itemCellBig:setData(data.code, data.amount, data.type)
	--
	self.tvDayBig:setText(string.format(Desc.AccumulativeDay_day, config.specialDay)) -- TODO

	-- 右侧奖励列表
	self.__rewardsListData = AccumulativeDayActivityConfiger:getDayList(self.pageIndex)
	self.rewardsList:setNumItems(#self.__rewardsListData)
end

function V:accumulative_day_activity_update()
	self:update()
end


function V:_exit()
	-- TODO
end

return V