local V, Super = class("SevenDayActView", Window)
local NewSevenDayConfiger = require("Game.ConfigReaders.NewSevenDayConfiger")
local HeroConfiger = require("Game.ConfigReaders.HeroConfiger")
local ActivityType = GameDef.ActivityType

local DayTabStatusControllerIndex = {
	Locked = 0,
	Selectable = 1,
	Selected = 2,
}

local MAX_DAY = 7
local MAX_POINT_PROGRESS_STEP  = 5

local ContentType = {
	Task = 1, -- 任务
	Goods = 2, -- 商品
}

function V:_activityType()
	return ActivityType.SevenDayRecord
end

function V:_configer()
	return NewSevenDayConfiger.new()
end

function V:ctor()
	--LuaLog("SevenDayActView ctor")
	self._packName = "SevenDayActivity"
	self._compName = "SevenDayActView"
	self.skeletonNode = false
	self._moneyType = false
	self._hideCloseBtn = true
	--self._rootDepth = LayerDepth.Window
	-- printTable(1,self._args.actData)
end

function V:_model()
	return SevenDayActivityModel
end

function V:_bg()
	return "img_qiri_bg.jpg"
end

function V:_hideLiHui()
	return true
end

local function setClickListenerFor(view, listener)
	view:removeClickListener(0)
	view:addClickListener(listener, 0)
end

function V:_initEvent( )
	
end

function V:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	vmRoot.Btn4 = viewNode:getChildAutoType("$Btn4")--Button
	vmRoot.Btn3 = viewNode:getChildAutoType("$Btn3")--Button
	vmRoot.Btn2 = viewNode:getChildAutoType("$Btn2")--Button
	vmRoot.itemCell1 = viewNode:getChildAutoType("itemCell1")--Button
	vmRoot.itemCell2 = viewNode:getChildAutoType("itemCell2")--Button
	vmRoot.itemCell3 = viewNode:getChildAutoType("itemCell3")--Button
	vmRoot.itemCell4 = viewNode:getChildAutoType("itemCell4")--Button
	vmRoot.itemCell5 = viewNode:getChildAutoType("itemCell5")--Button
	vmRoot.progressBar1 = viewNode:getChildAutoType("progressBar1")--ProgressBar
	vmRoot.progressBar2 = viewNode:getChildAutoType("progressBar2")--ProgressBar
	vmRoot.progressBar3 = viewNode:getChildAutoType("progressBar3")--ProgressBar
	vmRoot.progressBar4 = viewNode:getChildAutoType("progressBar4")--ProgressBar
	vmRoot.progressBar5 = viewNode:getChildAutoType("progressBar5")--ProgressBar
	vmRoot.indicator1 = viewNode:getChildAutoType("indicator1")--ProgressBar
	vmRoot.indicator2 = viewNode:getChildAutoType("indicator2")--ProgressBar
	vmRoot.indicator3 = viewNode:getChildAutoType("indicator3")--ProgressBar
	vmRoot.indicator4 = viewNode:getChildAutoType("indicator4")--ProgressBar
	vmRoot.indicator5 = viewNode:getChildAutoType("indicator5")--ProgressBar
	vmRoot.Btn7 = viewNode:getChildAutoType("$Btn7")--Button
	vmRoot.Btn1 = viewNode:getChildAutoType("$Btn1")--Button
	vmRoot.Btn5 = viewNode:getChildAutoType("$Btn5")--Button

	vmRoot.Btn6 = viewNode:getChildAutoType("$Btn6")--Button

	--
	vmRoot.btnClose = viewNode:getChildAutoType("btnClose")
	--
	vmRoot.taskList = viewNode:getChildAutoType("taskList")
	vmRoot.taskList:setVirtual()
	--
	for index = 1, MAX_DAY do
		local name = string.format("dayTab%d", index)
		vmRoot[name] = viewNode:getChildAutoType(name)
	end
	--
	vmRoot.tabList = viewNode:getChildAutoType("tabList")
	--
	vmRoot.activityCountdownView = viewNode:getChildAutoType("activityCountdownView")
end

function V:__initDayTabs()
	for index = 1, MAX_DAY do
		local dayTab = string.format("dayTab%d", index)
		self[dayTab]:getChildAutoType("tvDay"):setText(string.format(Desc.activity_txt23, StringUtil.transNumToChnNum(index))) -- TODO

		RedManager.register(self:_model():getDayTabReddotKey(index), self[dayTab]:getChildAutoType("img_red"))

		setClickListenerFor(self[dayTab], function()
			self:switchDayTab(index)
		end)
	end
end

function V:_initUI()
	self:_initVM()
	self:setBg(self:_bg())
	setClickListenerFor(self.btnClose, function()
		self:closeView()
	end)

	-- 左上角Bg
	self.view:getChildAutoType("imgLeftTopBg"):setURL(PathConfiger.getSevenDayLeftTopBg(self:_activityType()))

	-- 左侧角色立绘
	if not self:_hideLiHui() then
		local activityBaseInfo = ActivityModel:getActityByType(self:_activityType())
		local heroId = activityBaseInfo.showContent.modelId
		local fashionId = activityBaseInfo.showContent.fashionId
		--local spine = SpineUtil.createHeroDraw(nil, Vector2(0,0), heroId)
		--self.view:getChildAutoType("character"):displayObject():addChild(spine)
		local lihuiDisplay = self.view:getChildAutoType("lihuiDisplay")
		lihuiDisplay = BindManager.bindLihuiDisplay(lihuiDisplay)
		lihuiDisplay:setData(heroId,nil,nil, fashionId)
	end

	-- 左侧奖励信息
	local pointRewardList = self:_configer():getPointRewardList()
	local bestReward = pointRewardList[MAX_POINT_PROGRESS_STEP].reward[1]
	local heroInfoView = self.view:getChildAutoType("heroInfo")
	if bestReward.type == 4 then -- 奖励的是英雄
		heroInfoView:setVisible(true)

		local info = HeroConfiger.getHeroInfoByID(bestReward.code)
		-- 英雄名
		heroInfoView:getChildAutoType("tvHeroName"):setText(info.heroName)
		-- 星级
		for index = 1, 5 do
			heroInfoView:getChildAutoType(string.format("star%d", index)):setVisible(index <= info.heroStar)
		end
		-- 稀有度文本
		local rare = DynamicConfigData.t_HeroRare[info.heroStar] or DT
		heroInfoView:getChildAutoType("tvQuality"):setText(rare.rare or "")

		-- 查看详情按钮
		setClickListenerFor(heroInfoView:getChildAutoType("btnGotoDetail"), function()
			self:__gotoHeroDetail(bestReward.code)
		end)
	else -- 奖励不是英雄
		heroInfoView:setVisible(false)
	end

	--
	local endTimeMs = self:_model():getEndTimeMs()
	local now = ServerTimeModel:getServerTimeMS()
	local remainingSeconds = math.floor((endTimeMs-now)/1000)
	local function updateCountdownView(time)
		if time > 0 then
			local timeStr = TimeLib.GetTimeFormatDay(time,2)
			self.activityCountdownView:setText(
					string.format(Desc.activity_txt24, timeStr) -- TODO
			)
		else
			self.activityCountdownView:setText(Desc.activity_txt4) -- TODO
		end
	end
	updateCountdownView(remainingSeconds)
	self.__timerId = TimeLib.newCountDown(remainingSeconds, function(time)
		updateCountdownView(time)
	end, function()
		self.activityCountdownView:setText(Desc.activity_txt4) -- TODO
		self:closeView()
	end, false, false, false)

	-- 积分奖励
	self.__pointRewardInnerItemCells = {}
	for index = 1, MAX_POINT_PROGRESS_STEP do
		local config = pointRewardList[index]
		-- 各阶段需要的积分
		local needPoint = self.view:getChildAutoType(string.format("needPoint%d", index))
		needPoint:setText(config.needPoint)
		-- 该积分阶段可获得的奖励
		local itemCell = self.view:getChildAutoType(string.format("itemCell%d", index))
		--if index == MAX_POINT_PROGRESS_STEP then
		--	local itemCell5 = BindManager.bindItemCell(self.itemCell5, true)
		--	--local itemData = ItemsUtil.createItemData({data = config.reward[1]})
		--	--itemCell5:setItemData(itemData)
		--	local reward = config.reward[1]
		--	itemCell5:setData(reward.code, reward.amount, reward.type)
		--else
			local innerItemCell = itemCell:getChildAutoType("itemCell")
			innerItemCell = BindManager.bindItemCell(innerItemCell, true)
			local reward = config.reward[1]
			--local itemData = ItemsUtil.createItemData({data = reward})
			--innerItemCell:setItemData(itemData)
			innerItemCell:setData(reward.code, reward.amount, reward.type)
			self.__pointRewardInnerItemCells[index] = innerItemCell
		--end
		-- 红点
		local reddot = itemCell:getChildAutoType("reddot")
		RedManager.register(self:_model():getPointRewardReddotKey(index), reddot)
	end

	-- 初始化左侧第x天页签
	self:__initDayTabs()

	-- 列表项渲染器
    self.taskList:setItemRenderer(function(index, obj)
		self:__renderContentItem(index+1, obj)
	end)

	--
	self:updateTopContent()
	-- 打开界面时切换至对应当前天数的页签
	self:updateAllDayTabStatus()
	local currentDay = self:_model():getCurrentDay()
	self:switchDayTab(currentDay)
end

function V:sevenday_activity_update(_, activityType)
	if self:_activityType() ~= activityType then
		return
	end
	self:updateAllDayTabStatus()
	self:updateTopContent()
	self:updateCenterContent()
end

function V:__gotoHeroDetail(heroId)
	local info = HeroConfiger.getHeroInfoByID(heroId)
	local categoryHeros = DynamicConfigData.t_HeroTotems[info.category]
	local cardInfoList = {}
	local index = 1
	for _, v in pairs(categoryHeros) do
		table.insert(cardInfoList, v)
		if v.hero == heroId then
			index = #cardInfoList
		end
	end
	ViewManager.open("HeroInfoView",{index = index, heroId = heroId, heroList = cardInfoList})
end

--function V:__renderTaskItem(index, view)
--end
--
--function V:__renderGoodsItem(index, view)
--end

function V:__renderContentItem(index, view)
	local modeController = view:getController("mode")
	local statusController = view:getController("status")
	local title = view:getChildAutoType("title")
	local itemListView = view:getChildAutoType("itemList")
	local btnGoodsBlue = view:getChildAutoType("btnGoodsBlue")
	local btnTaskBlue = view:getChildAutoType("btnTaskBlue")
	local btnYellow = view:getChildAutoType("btnYellow")
	local taskProgress = view:getChildAutoType("taskProgress")
	local tvLoginTaskEnd = view:getChildAutoType("tvLoginTaskEnd")
	--local imgLoginTaskEnd = view:getChildAutoType("imgLoginTaskEnd")

	tvLoginTaskEnd:setVisible(false)
	--imgLoginTaskEnd:setVisible(false)

	-- 特别部分
	if self.__currentContentType == ContentType.Task then
		local config = self.__currentContentItemDataList[index]
		local taskDetail = self:_configer():getTaskDetail(config.taskId)
		-- 切换至任务模式
		modeController:setSelectedIndex(0)
		-- 任务名
		title:setText(taskDetail.name)
		-- 任务完成奖励
		local maxIndex = math.min(#config.taskReward, itemListView:getNumItems())
		for rewardIndex = 1, maxIndex do
			local itemCell = itemListView:getChildAt(rewardIndex-1)
			itemCell:setVisible(true)
			itemCell = BindManager.bindItemCell(itemCell)
			local itemData = ItemsUtil.createItemData({data = config.taskReward[rewardIndex]})
			itemCell:setItemData(itemData)
		end
		for emptyItemIndex = maxIndex+1, itemListView:getNumItems() do
			itemListView:getChildAt(emptyItemIndex-1):setVisible(false)
		end

		-- 任务进度
		local current, max = self:_model():getTaskProgress(config.taskId)
		--local taskProgress = view:getChildAutoType("taskProgress")
		taskProgress:setText(string.format("(%d/%d)", current, max))

		-- 任务状态
		local status = self:_model():getTaskStatus(config.taskId)
		print(1,"taskDetail.name",taskDetail.name,status)
		if status == 0 then -- 未完成
			statusController:setSelectedIndex(0)
			--btnTaskBlue:getController("iconCtrl"):setSelectedIndex(1) -- 隐藏货币icon
			setClickListenerFor(btnTaskBlue, function()
				if config.windowId == 5 then
					ViewManager.open("PataView" , { type = 6 , name=Desc.activity_txt25,activeType= 2000 , towerType=1,rankType=2,space = -15,showCount = 6,moveCount = 4} )
				else
					ModuleUtil.openModule(config.windowId, true)
				end
			end)

			if self:_model():isLoginTask(config.taskId) then
				btnTaskBlue:setVisible(false)
				tvLoginTaskEnd:setVisible(true)
				--imgLoginTaskEnd:setVisible(true)
			else
				btnTaskBlue:setVisible(true)
			end
		elseif status == 1 then -- 未领取
			statusController:setSelectedIndex(1)
			btnYellow:getChildAutoType("img_red"):setVisible(true)
			setClickListenerFor(btnYellow, function()
				self:_model():getTaskReward(config.taskId)
			end)
		elseif status == 2 then -- 已领取
			statusController:setSelectedIndex(2)
		end

		--self:__renderTaskItem(index, view)
	elseif self.__currentContentType == ContentType.Goods then
		local config = self.__currentContentItemDataList[index]
		-- 切换至商品模式
		modeController:setSelectedIndex(1)
		-- 礼包名
		title:setText(config.name)
		-- 礼包内道具
		local maxIndex = math.min(#config.reward, itemListView:getNumItems())
		for rewardIndex = 1, maxIndex do
			local itemCell = itemListView:getChildAt(rewardIndex-1)
			itemCell:setVisible(true)
			itemCell = BindManager.bindItemCell(itemCell)
			local itemData = ItemsUtil.createItemData({data = config.reward[rewardIndex]})
			itemCell:setItemData(itemData)
		end
		for emptyItemIndex = maxIndex+1, itemListView:getNumItems() do
			itemListView:getChildAt(emptyItemIndex-1):setVisible(false)
		end
		--
		--btnGoodsBlue:getController("iconCtrl"):setSelectedIndex(0) -- 显示货币icon
		--
		local oldPrice, sellPrice = config.oldPrice[1].amount, config.sellPrice[1].amount
		view:getChildAutoType("originalPrice"):setText(oldPrice)
		btnGoodsBlue:setText(sellPrice)
		btnGoodsBlue:getChildAutoType("img_red"):setVisible(sellPrice == 0)

		-- 礼包状态
		local remainingBuyTimes, maxBuyTimes = self:_model():getGoodsRemainingBuyTimesAndMaxBuyTimes(
				self.__currentSelectedDayTabIndex,
				config.id
		)
		-- 礼包剩余购买次数和最大可购买次数
		taskProgress:setText(string.format("(%d/%d)", remainingBuyTimes, maxBuyTimes))
		--
		--btnBlue:getController("mode"):setSelectedIndex(2) -- 购买
		if remainingBuyTimes == 0 then -- 购买完了
			statusController:setSelectedIndex(2)
		else -- 可购买
			statusController:setSelectedIndex(1)
			setClickListenerFor(btnGoodsBlue, function()
				local vipLimit = config.vipLimit or 0
				if VipModel.level < vipLimit then
					RollTips.show(string.format(Desc.activity_txt26, vipLimit)) -- TODO
					return
				end

				Alert.show({
					text = string.format(Desc.sevenActivity_buy_text1, sellPrice, config.name),
					type = "yes_no",
					align = "center",
					mask = true,
					onYes = function()
						self:_model():buyGift(self.__currentSelectedDayTabIndex, config.id)
					end
				})
			end)
		end

		--self:__renderGoodsItem(index, view)
	end
end

-- 刷新顶部内容（总积分，积分进度，积分奖励）
function V:updateTopContent()
	-- 当前总积分
	local totalPoint = self.view:getChildAutoType("totalPoint")
	local currentTotalPoint = self:_model():getCurrentTotalPoint()
	totalPoint:setText(currentTotalPoint)
	-- 积分进度和积分奖励
	local pointRewardList = self:_configer():getPointRewardList()
	for index = 1, MAX_POINT_PROGRESS_STEP do
		local config = pointRewardList[index]
		--
		local progressBar = self[string.format("progressBar%d", index)]
		local needPoint = config.needPoint
		local maxValue
		local currentValue
		if index > 1 then
			local lastNeedPoint = pointRewardList[index-1].needPoint
			maxValue = needPoint - lastNeedPoint
			currentValue = math.min(math.max(0, currentTotalPoint-lastNeedPoint), maxValue)
		else
			maxValue = needPoint
			currentValue = math.min(currentTotalPoint, maxValue)
		end
		progressBar:setMax(maxValue)
		progressBar:setValue(currentValue)
		--
		local function onClickItemCell()
			--if index == 5 then
			--	self:__gotoHeroDetail()
			--else
				self.__pointRewardInnerItemCells[index]:onClickCell()
			--end
		end
		local itemCell = self[string.format("itemCell%d", index)]
		local status = self:_model():getPointRewardStatus(index)
		local controller = itemCell:getController("status")
		local indicator = self[string.format("indicator%d", index)]
		if currentValue == maxValue then
			indicator:getController("status"):setSelectedIndex(1) -- 显示进度条上的黄点
			if status == 1 then
				-- 未领取
				controller:setSelectedIndex(1)
				setClickListenerFor(itemCell, function()
					self:_model():getPointReward(index)
				end)
			elseif status == 2 then
				-- 已领取
				controller:setSelectedIndex(2)
				setClickListenerFor(itemCell, onClickItemCell)
			end
		else
			indicator:getController("status"):setSelectedIndex(0) -- 显示进度条上的黑点
			-- 未达到条件，不可领取
			controller:setSelectedIndex(0)
			setClickListenerFor(itemCell, onClickItemCell)
		end
	end
end

-- 刷新中间内容（任务列表，商品列表）
function V:updateCenterContent()
	if not (self.__currentSelectedDayTabIndex and self.__currentSelectedContentTabIndex) then
		return
	end

	local titleList = self:_configer():getTitleList(self.__currentSelectedDayTabIndex)
	local config = titleList[self.__currentSelectedContentTabIndex]
	-- 完成标签
	local contentTab = self.tabList:getChildAt(self.__currentSelectedContentTabIndex-1)
	if config.libraryId == 0 then
		contentTab:getChildAutoType("imgAllFinish"):setVisible(false)
	else
		local completed = self:_model():haveCompletedAllTask(config.libraryId)
		contentTab:getChildAutoType("imgAllFinish"):setVisible(completed)
	end
	--
	if config.libraryId == 0 then
		local goodsList = self:_configer():getShopGoodsList(self.__currentSelectedDayTabIndex)
		self.__currentContentItemDataList = goodsList
		self.__currentContentType = ContentType.Goods
	else
		local taskList = self:_configer():getTaskList(config.libraryId)
		self.__currentContentItemDataList = taskList
		self.__currentContentType = ContentType.Task
	end
	if type(self.__currentContentItemDataList) == "table" then
		self.taskList:setNumItems(#self.__currentContentItemDataList)
	end
end

function V:switchContentTabTo(index)
	--if self.__currentSelectedContentTabIndex == index then
	--	return
	--end

	if self.__currentSelectedContentTabIndex then
		self.tabList:getChildAt(self.__currentSelectedContentTabIndex-1):getChildAutoType("icon"):setVisible(false)
	end
	self.tabList:getChildAt(index-1):getChildAutoType("icon"):setVisible(true)

	self.__currentSelectedContentTabIndex = index
	self:updateCenterContent()
end

function V:updateAllContentTab()
	if not self.__currentSelectedDayTabIndex then
		return
	end

	local titleList = self:_configer():getTitleList(self.__currentSelectedDayTabIndex)
	local numItems = self.tabList:getNumItems()
	for index = 1, math.min(numItems, #titleList) do
		local config = titleList[index]
		local contentTab = self.tabList:getChildAt(index-1)
		--
		contentTab:getChildAutoType("icon"):setVisible(index == self.__currentSelectedContentTabIndex)
		--
		contentTab:setText(config.name)
		-- 完成标签
		if config.libraryId == 0 then
			contentTab:getChildAutoType("imgAllFinish"):setVisible(false)
			RedManager.register(
					self:_model():getGoodsTypeTabReddotKey(self.__currentSelectedDayTabIndex),
					contentTab:getChildAutoType("reddot")
			)
		else
			local completed = self:_model():haveCompletedAllTask(config.libraryId)
			contentTab:getChildAutoType("imgAllFinish"):setVisible(completed)
			RedManager.register(
					self:_model():getTaskTypeTabReddotKey(self.__currentSelectedDayTabIndex, index),
					contentTab:getChildAutoType("reddot")
			)
		end
		--
		setClickListenerFor(contentTab, function()
			self:switchContentTabTo(index)
		end)
	end
end

function V:updateAllDayTabStatus()
	local currentDay = self:_model():getCurrentDay()
	for index = 1, MAX_DAY do
		local dayTab = string.format("dayTab%d", index)
		if index <= currentDay then
			if index == self.__currentSelectedDayTabIndex then
				self[dayTab]:getController("statusCtrl"):setSelectedIndex(DayTabStatusControllerIndex.Selected)
			else
				self[dayTab]:getController("statusCtrl"):setSelectedIndex(DayTabStatusControllerIndex.Selectable)
			end
		elseif index > currentDay then
			self[dayTab]:getController("statusCtrl"):setSelectedIndex(DayTabStatusControllerIndex.Locked)
		end
	end
end

function V:switchDayTab(day)
	if day == self.__currentSelectedDayTabIndex then
		return
	end
	--
	local currentDay = self:_model():getCurrentDay()
	if day > currentDay then
		RollTips.show(Desc.sevenActivity_txt1)
		return
	end
	-- 切换按钮状态
	local dayTab
	if self.__currentSelectedDayTabIndex then
		dayTab = string.format("dayTab%d", self.__currentSelectedDayTabIndex)
		self[dayTab]:getController("statusCtrl"):setSelectedIndex(DayTabStatusControllerIndex.Selectable)
	end
	dayTab = string.format("dayTab%d", day)
	self[dayTab]:getController("statusCtrl"):setSelectedIndex(DayTabStatusControllerIndex.Selected)
	--
	self.__currentSelectedDayTabIndex = day
	self:updateAllContentTab()
	self:switchContentTabTo(1) -- 切换后默认显示第一页
end

function V:_exit()
	if self.__timerId then
		TimeLib.clearCountDown(self.__timerId)
	end
end

return V