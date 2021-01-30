--Date :2021-01-02
--Author : generated by FairyGUI
--Desc : 阵营试炼

local TrialActivityView,Super = class("TrialActivityView", Window)

function TrialActivityView:ctor()
	--LuaLog("TrialActivityView ctor")
	self._packName = "TrialActivity"
	self._compName = "TrialActivityView"
	self._rootDepth = LayerDepth.Window
	self.timer = false
	self.isEnd = false
	self.moduleId = TrialActivityModel:getModuleId()
	self.exChangeData = DynamicConfigData.t_TrialExchange[self.moduleId]
	self._args.moduleId = 258
	self.isShilianEnd = false
end

function TrialActivityView:_initEvent( )
	
end

function TrialActivityView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:TrialActivity.TrialActivityView
	self.btn_go = viewNode:getChildAutoType('btn_go')--GButton
	self.btn_shop = viewNode:getChildAutoType('btn_shop')--GButton
	self.exChangeList = viewNode:getChildAutoType('exChangeList')--GList
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.icon1 = viewNode:getChildAutoType('icon1')--GLoader
	self.icon2 = viewNode:getChildAutoType('icon2')--GLoader
	self.icon3 = viewNode:getChildAutoType('icon3')--GLoader
	self.icon4 = viewNode:getChildAutoType('icon4')--GLoader
	self.icon5 = viewNode:getChildAutoType('icon5')--GLoader
	self.model = viewNode:getChildAutoType('model')--GLoader
	self.money1 = viewNode:getChildAutoType('money1')--GTextField
	self.money2 = viewNode:getChildAutoType('money2')--GTextField
	self.money3 = viewNode:getChildAutoType('money3')--GTextField
	self.money4 = viewNode:getChildAutoType('money4')--GTextField
	self.money5 = viewNode:getChildAutoType('money5')--GTextField
	self.shilianText = viewNode:getChildAutoType('shilianText')--GRichTextField
	self.txt_countTimer = viewNode:getChildAutoType('txt_countTimer')--GTextField
	self.txt_countTitle = viewNode:getChildAutoType('txt_countTitle')--GTextField
	--{autoFieldsEnd}:TrialActivity.TrialActivityView
	--Do not modify above code-------------
end

function TrialActivityView:_initListener( )
	self.btn_goText = self.btn_go:getTitle()
	self.btn_go:addClickListener(function()
		if not TrialActivityModel.isCanShilian then
			RollTips.show(Desc.trialActivity_desc7)
			return
		end
		if TrialActivityModel.restTimes <= 0 then
			RollTips.show(Desc.trialActivity_desc10)
			return 
		end

		if TrialActivityModel.match then
			Dispatcher.dispatchEvent("trialActivity_matchFinish")
		else
			TrialActivityModel:reqPlayer()
		end
	end)

	self.btn_shop:addClickListener(function()
		ViewManager.open("TrialActivityAddView")
	end)

	
	self.exChangeList:setItemRenderer(function(index, obj)
		local data = self.exChangeList._dataTemplate[index+1]
		local itemcell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
		local itemData = ItemsUtil.createItemData({data = data.reward[1]})
		itemcell:setItemData(itemData)
		
		local btn_get = obj:getChildAutoType("btn_get")
		local times_txt = obj:getChildAutoType("times")

		local isYes = true
		for i = 1,3 do
			local price = data.price[i]
			local icon = obj:getChildAutoType("icon"..i)
			local jia = obj:getChildAutoType("jia"..i)
			local money = obj:getChildAutoType("money"..i)
			local c1 = obj:getController("c1")
			if price then
				local url = ItemConfiger.getItemIconByCode(price.code, price.type, false)
				local itemData = ItemsUtil.createItemData({data = {code = price.code, type = price.type}})
				local code = itemData:getItemInfo().code
				local hasNum = 0
				if code > 2000 and code < 2100 then
					hasNum=	PlayerModel:getMoneyByType(code - 2000)
				else
					hasNum=	ModelManager.PackModel:getItemsFromAllPackByCode(code)
				end
				icon:setURL(url)
				money:setText(StringUtil.transValue(hasNum).."/"..StringUtil.transValue(price.amount))
				icon:addClickListener(function()
					ViewManager.open("ItemTips", {codeType = price.type, id = price.code,data = itemData})
				end)
				if price.amount > hasNum then
					isYes = false
				end
			else
				c1:setSelectedIndex(i-1)
				jia:setVisible(false)
				icon:setVisible(false)
				money:setVisible(false)
			end
		end
		btn_get:addClickListener(function()
			if not isYes then
				RollTips.show(Desc.trialActivity_desc8)
				return 
			end
			if data.canBuyNum <= 0 then
				RollTips.show(Desc.trialActivity_desc9)
				btn_get:getController("button"):setSelectedIndex(2)
				return 
			end
			if TrialActivityModel.changeTips then
				ViewManager.open("TrialActivityTipsView",{exdata = data,itemData = itemData})
			else
				TrialActivityModel:reqExchange(data.id)
			end
		end,33)

		if data.canBuyNum > 0 then
			btn_get:setGrayed(false)
			times_txt:setText(data.canBuyNum)
			btn_get:getChildAutoType("img_red"):setVisible(isYes)
		else
			times_txt:setText(0)
			btn_get:setGrayed(true)
			btn_get:getController("button"):setSelectedIndex(2)
			btn_get:getChildAutoType("img_red"):setVisible(false)
		end
		
	end)

end

function TrialActivityView:_initUI( )
	self:_initVM()
	self:_initListener()

	self:setBg("TrialActivity_bg.jpg")

	RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.Trial.."times", self.btn_go:getChildAutoType("img_red"))
	RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.Trial.."shop", self.btn_shop:getChildAutoType("img_red"))
	SpineUtil.createModel(self.model, {x = 0, y =0}, "stand", HandbookModel.heroOpertion or PlayerModel.head,true,nil,HandbookModel.fashionCode)

	self:refreshPanal()
	TrialActivityModel:updateRed()
end

function TrialActivityView:refreshPanal()

	self:updateExChangeList()
	self:updateCountTimer()
	self:updateBottomInfo()
end

function TrialActivityView:updateExChangeList()
	local exchangeC = TrialActivityModel.exchange or {}
	for k,v in pairs(self.exChangeData) do
		local buyNum = exchangeC[v.id] and exchangeC[v.id].times or 0
		v.canBuyNum = v.limit - buyNum
		if v.canBuyNum == 0 then
			v.status = 0
		else
			v.status = 1
		end
	end

	TableUtil.sortByMap(self.exChangeData, {{key = "status", asc = true},{key = "id", asc = false}})
	self.exChangeList:setData(self.exChangeData)
end

function TrialActivityView:updateBottomInfo()
	for i = 1,5 do
		local itemCode = 10000120 + i
		local itemData = ItemsUtil.createItemData({data = {code = itemCode, type = 3}})
		local hasNum = 0
		local code = itemData:getItemInfo().code
		if code > 2000 and code < 2100 then
			hasNum=	PlayerModel:getMoneyByType(code - 2000)
		else
			hasNum=	ModelManager.PackModel:getItemsFromAllPackByCode(code)
		end
		self["money"..i]:setText(hasNum)
		self["icon"..i]:addClickListener(function()
			ViewManager.open("ItemTips", {codeType = 3, id = itemCode,data = itemData})
		end)
	end
	self.btn_go:setTitle(string.format("%s(%d/%d)",self.btn_goText,TrialActivityModel.restTimes,TrialActivityModel.limit))
	if TrialActivityModel.restTimes <= 0 then
		self.btn_go:setGrayed(true)
	end
end

-- 匹配成功
function TrialActivityView:trialActivity_matchFinish()
	if not TrialActivityModel.match then return end
	local view = ViewManager.open("FriendCheckView",{playerId = TrialActivityModel.match.playerId, serverId = TrialActivityModel.match.serverId, arrayType = GameDef.BattleArrayType.Trail})
	view = view.view
	view:getController("myselfCtrl"):setSelectedIndex(1)
	view:getController("shilian"):setSelectedIndex(1)
	local leftTime = view:getChildAutoType("leftTime")
	leftTime:setText(Desc.trialActivity_desc2:format(TrialActivityModel.restTimes))
	local btn_reset = view:getChildAutoType("btn_reset")
	local costObject=BindManager.bindCostButton(btn_reset)
	local costNum = DynamicConfigData.t_TrialConfig[1].costDiamond
	costObject:setData({code =2 ,type =2, amount = costNum})
	btn_reset:addClickListener(function()
		if not PlayerModel:isCostEnough({{type = 2, code = 2, amount = costNum}}) then
			return
		end
		TrialActivityModel:reqPlayer()
		ViewManager.close("FriendCheckView")
	end)

	view:getChildAutoType("btn_go"):addClickListener(function()
		if not TrialActivityModel.isCanShilian then
			RollTips.show(Desc.trialActivity_desc7)
			return
		end
		Dispatcher.dispatchEvent("trialActivity_battle",{playerId = TrialActivityModel.match.playerId, serverId = TrialActivityModel.match.serverId})
		ViewManager.close("FriendCheckView")
	end)
end

-- 兑换成功
function TrialActivityView:trialActivity_exchangeSuccess()
	self:updateExChangeList()
	self:updateBottomInfo()
end

-- 倒计时
function TrialActivityView:updateCountTimer()
	if self.isEnd then return end
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.Trial)
	if not actData then return end
	local actId   = actData.id
	local status, addtime = ModelManager.ActivityModel:getActStatusAndLastTime(actId)
	if not addtime then return end

	
	if status == 2 and addtime == -1 then
		self.isEnd = false
		self.txt_countTimer:setText(Desc.activity_txt5)
	else
		local lastTime = addtime / 1000
		if lastTime == -1 then
			self.txt_countTimer:setText(Desc.activity_txt5)
		elseif addtime < 0 then
			self.btn_go:setTouchable(false)
			self.btn_go:setGrayed(true)
		else
			if not tolua.isnull(self.txt_countTimer) then
				self.txt_countTimer:setText(TimeLib.GetTimeFormatDay(lastTime, 2))
			end
			local function onCountDown(time)
				if not tolua.isnull(self.txt_countTimer) then
					self.isEnd = false
					self.txt_countTimer:setText(TimeLib.GetTimeFormatDay(time, 2))
				end
			end
			local function onEnd(...)
				self.isEnd = true
				if not tolua.isnull(self.txt_countTimer) then
					--  self.activityEnable = true
					self.txt_countTimer:setText(Desc.activity_txt18)
					self.btn_go:setTouchable(false)
					self.btn_go:setGrayed(true)
					TrialActivityModel:updateRed()
				end
			end
			if self.timer then
				TimeLib.clearCountDown(self.timer)
			end
			self.timer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
		end
	end

	local addtime2 = addtime/1000 - DynamicConfigData.t_TrialConfig[1].endTrialTime * 60*60*24
	if addtime2 > 0 then

		self.shilianText:setText(Desc.trialActivity_desc5:format(TimeLib.GetTimeFormatDay(addtime2, 2)))
		
		local function onCountDown(time)
			if not tolua.isnull(self.shilianText) then
				self.isEnd = false
				self.shilianText:setText(Desc.trialActivity_desc5:format(TimeLib.GetTimeFormatDay(time, 2)))
			end
		end
		local function onEnd(...)
			self.isEnd = true
			if not tolua.isnull(self.shilianText) then
				--  self.activityEnable = true
				self.shilianText:setText(Desc.activity_txt18)
				self.btn_go:setGrayed(true)
				TrialActivityModel:updateRed()
			end
		end
		if self.timer2 then
			TimeLib.clearCountDown(self.timer2)
		end
		self.timer2 = TimeLib.newCountDown(addtime2, onCountDown, onEnd, false, false, false)
	else
		self.shilianText:setText(Desc.trialActivity_desc6)
		self.btn_go:setGrayed(true)
	end
end


function TrialActivityView:_exit()
	TimeLib.clearCountDown(self.timer)
	TimeLib.clearCountDown(self.timer2)
end



return TrialActivityView