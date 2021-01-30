--Name : GetCardsYjActivityView.lua
--Author : generated by FairyGUI
--Date : 2020-10-19
--Desc : 异界招募

local GetCardsYjActivityView,Super = class("GetCardsYjActivityView", Window)

function GetCardsYjActivityView:ctor()
	--LuaLog("GetCardsYjActivityView ctor")
	self._packName = "GetCardsYjActivity"
	self._compName = "GetCardsYjActivityView"
	self._rootDepth = LayerDepth.Window
	self.leftbtn = false
	self.rightbtn = false
	self.itemicon = false
	self.itemnum = false
	self.btn_gl = false
	self.typeVal = GameDef.HeroLotteryType.Farplane
	self.lastTimeLab = false

	self.costItemLeft = false
	self.costItemRight = false
	self.itemCellArr = {}
	self.viewData = {}
    self.lotteryIdList = {}
	self.data = false
	self.luckType = false
	self.__timerId = false
end

-------------------常用------------------------
--UI初始化
function GetCardsYjActivityView:_initUI( ... )
  self.leftCtrl  = self.view:getController("leftCtrl")
  self.leftbtn = self.view:getChildAutoType("leftbtn")
  self.rightbtn = self.view:getChildAutoType("rightbtn")
  self.itemicon = self.view:getChildAutoType("itemicon")
  self.itemnum = self.view:getChildAutoType("itemnum")
  self.lastTimeLab = self.view:getChildAutoType("gj_lastTime_lab")
  self.btn_gl = self.view:getChildAutoType("btn_gl")
  self.zhscBtn = self.view:getChildAutoType("zhscBtn")
  
  self.costItemLeft = self.view:getChildAutoType("costItemLeft")
  self.costItemRight = self.view:getChildAutoType("costItemRight")

  self.costItemObj1 = BindManager.bindCostItem(self.costItemLeft)
  self.costItemObj2 = BindManager.bindCostItem(self.costItemRight)
  self.costItemObj1:setUseMoneyItem(true);
  self.costItemObj2:setUseMoneyItem(true);
  
  self.btnAdd = self.view:getChildAutoType("btnAdd")
  self.btnChange = self.view:getChildAutoType("btn_change")
  self.hadNextCtrl = self.view:getController("hadNextCtrl")
  self.btn_help = self.view:getChildAutoType("btn_help")
  self.btn_view = self.view:getChildAutoType("btn_view")
  self.itemCell = self.view:getChildAutoType("itemCell")
  self.progressBar = self.view:getChildAutoType("progressBar")
  self.tipShowBtn = self.view:getChildAutoType("tipShowBtn")
  self.protxt = self.view:getChildAutoType("protxt")
  self.txt_countTime = self.view:getChildAutoType("txt_countTime")
  RedManager.register("V_SUBACTIVITY_YJ", self.view:getChildAutoType("img_red"))
end


function GetCardsYjActivityView:__setColorForCostItem(specific, costItem, type, code, amount)
	local hasNum = 0
	if type == CodeType.ITEM then
		hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(code)
	elseif type == CodeType.MONEY then
		hasNum = ModelManager.PlayerModel:getMoneyByType(code)
	end
	local colorController = costItem:getController("color")
	if specific then
		if hasNum >= amount then
			colorController:setSelectedPage("specificEnough")
		else
			colorController:setSelectedPage("specificNotEnough")
		end
	else
		if hasNum >= amount then
			colorController:setSelectedPage("enough")
		else
			colorController:setSelectedPage("notEnough")
		end
	end
end

--事件初始化
function GetCardsYjActivityView:_initEvent( ... )
	self.btn_help:removeClickListener()
	self.btn_help:addClickListener(function( ... )
	   local actiInfo = ActivityModel:getActityByType( GameDef.ActivityType.Farplane )
	   if not actiInfo then --没数据 活动可能关了
		   return
	   end
		ViewManager.open("GCTyTipsView",{moduleId=self.viewData.showContent.moduleId})
	end)

	self.tipShowBtn:addClickListener(function( )
		local cost = DynamicConfigData.t_heroLottery[self.lotteryIdList[1]].cost
		local itemInfo = ItemConfiger.getInfoByCode(cost[1].code)
		local itemData = ItemsUtil.createItemData({data = {type = itemInfo.type, code = itemInfo.code, amount = 1}})
		ViewManager.open("ItemTips", {codeType = itemInfo.type, id = itemInfo.code, data = itemData})
	end)

	self.zhscBtn:removeClickListener()
	self.zhscBtn:addClickListener(function( ... )
		ModuleUtil.openModule(219, true)
	end)

	self.btn_view:addClickListener(function ( ... )
		if not  self.viewData then
			RollTips.show(Desc.activity_txt13)
			return
		end
    	ViewManager.open("GetCardsYjAwardView",{actType=GameDef.ActivityType.Farplane,data=GetCardsYjActivityModel:getData(  ) })
    end)
	--单抽按钮
    self.leftbtn:removeClickListener(100)
	self.leftbtn:addClickListener(function ( ... )
		if  not self.lotteryIdList[1] then
			return 
		end
		if not self.viewData then
			RollTips.show(Desc.shop_activityEnd)
			return
		end
		local idArr = {self.lotteryIdList[1],self.lotteryIdList[3]}
		local cost = DynamicConfigData.t_heroLottery[idArr[1]].cost --异界单抽
		-- local cost2 = DynamicConfigData.t_heroLottery[idArr[2]].cost --异界钻石
		local itemCode = cost[1].code --道具需要
		-- local xhnum = cost2[1].amount --钻石消耗
		local hadFreeNum = self.data.data.freeTimes
		local num = PackModel:getItemsFromAllPackByCode(itemCode)
		if hadFreeNum>=1 then --如果是免费
			local params = {}
			params.id = self.lotteryIdList[5]
			params.activityId = self.viewData.id
			params.onSuccess = function (res )
				-- printTable(1,res)
				local data = {}
				data.resultList = res.resultList
				-- if num-cost[1].amount>=0 then --道具还足够
					data.id = idArr[1]
					data.cost = cost
					data.xhType = 1
				-- else --道具不足
				-- 	data.id = idArr[2]
				-- 	data.cost = cost2
				-- 	data.xhType = 2
				-- end
				data.activityId = self.viewData.id
				self:updatePanel()
				ViewManager.open("GetTYSuccessView",data) 
			end
			printTable(1,"前端params",params)
			RPCReq.HeroLottery_ActivityDraw(params, params.onSuccess)
		elseif num >=cost[1].amount then
			local params = {}
			params.id = idArr[1]
			params.activityId = self.viewData.id
			params.onSuccess = function (res )
				local data = {}
				data.resultList = res.resultList
				local num = PackModel:getItemsFromAllPackByCode(itemCode)
				local temp = num - cost[1].amount
				-- if temp>=0 then --道具还足够
					data.id = idArr[1]
					data.cost = cost
					data.xhType = 1
				-- else --道具不足
				-- 	data.id = idArr[2]
				-- 	data.cost = cost2
				-- 	data.xhType = 2
				-- end
				data.activityId = self.viewData.id
				self:updatePanel()
				ViewManager.open("GetTYSuccessView",data) 
				end
				printTable(1,"前端params",params)
			RPCReq.HeroLottery_ActivityDraw(params, params.onSuccess)
			-- elseif PlayerModel:getMoneyByType(GameDef.MoneyType.Diamond)>=xhnum then --钻石消耗足够
			-- 	local info = {
			-- 		text=string.format(Desc.getCard_2,cost2[1].amount,1000,1,Desc.getCard_5),
			-- 		type="yes_no",
			-- 	}
			-- 	info.onYes = function()
			-- 		local params = {}
			-- 		params.id = idArr[2]
			-- 		params.activityId = self.viewData.id
			-- 		params.onSuccess = function (res )
			-- 			local data = {}
			-- 			data.resultList = res.resultList
			-- 			data.id = idArr[2]
			-- 			data.cost = cost2
			-- 			data.xhType = 2
			-- 			data.activityId = self.viewData.id
			-- 			self:updatePanel()
			-- 			ViewManager.open("GetTYSuccessView",data) 
			-- 		end
			-- 		printTable(1,"前端params",params)
			-- 		RPCReq.HeroLottery_ActivityDraw(params, params.onSuccess)
			-- 	end
			-- 	Alert.show(info);
		else
			-- ModelManager.PlayerModel:isCostEnough(cost, true)
			local info = {}
			local itemName = ItemConfiger.getItemNameByCode(cost[1].code)
			-- local costNameIcon2 = ItemConfiger.getItemIconStrByCode(cost[1].code, cost[1].type, true)
			info.text = string.format("%s%s",itemName,Desc.activity_txt37)
			info.okText = Desc.activity_txt42
			info.type = "ok"
			info.noClose = "no"
			info.onOk = function(flag)
				ModuleUtil.openModule(ModuleId.ActYjShopView.id)
			end
			Alert.show(info);
		end
	end,100)
	
	--十连抽按钮
    self.rightbtn:removeClickListener(100)
	self.rightbtn:addClickListener(function ( ... )
		if  not self.lotteryIdList[2] then
			return 
		end

		if not self.viewData then
			RollTips.show(Desc.shop_activityEnd)
			return
		end

		local idArr = {self.lotteryIdList[2],self.lotteryIdList[4]}
		local cost = DynamicConfigData.t_heroLottery[idArr[1]].cost --异界十连（高V）
		-- local cost2 = DynamicConfigData.t_heroLottery[idArr[2]].cost --异界十连-钻石（高V）
		local itemCode =cost[1].code --道具消耗
		local num = PackModel:getItemsFromAllPackByCode(itemCode)
		-- local xhnum = cost2[1].amount --钻石消耗
		if num >=cost[1].amount then  --道具足够
			local params = {}
				params.id = idArr[1]
				params.activityId = self.viewData.id
				printTable(1,params)
			params.onSuccess = function (res )
				local data = {}
				data.resultList = res.resultList
				local temp = num - cost[1].amount
				-- if temp>=0 then --道具还足够
					data.id = idArr[1]
					data.cost = cost
					data.xhType = 1
				-- else --道具不足
				-- 	data.id = idArr[2]
				-- 	data.cost = cost2
				-- 	data.xhType = 2
				-- end
				data.activityId = self.viewData.id
				self:updatePanel()
				ViewManager.open("GetTYSuccessView",data) 
			end
			RPCReq.HeroLottery_ActivityDraw(params, params.onSuccess)
		-- elseif PlayerModel:getMoneyByType(GameDef.MoneyType.Diamond)>=xhnum then --钻石消耗足够
		-- 		local info = {
		-- 			text=string.format(Desc.getCard_2,cost2[1].amount,10000,10,Desc.getCard_5),
		-- 			type="yes_no",
		-- 		}
		-- 		info.onYes = function()
		-- 			local params = {}
		-- 			params.id = idArr[2]
		-- 			params.activityId = self.viewData.id
		-- 			printTable(1,params)
		-- 			params.onSuccess = function (res )
		-- 				local data = {}
		-- 				data.resultList = res.resultList
		-- 				data.cost = cost2
		-- 				data.id = idArr[2]
		-- 				data.xhType = 2
		-- 				data.activityId = self.viewData.id
		-- 				self:updatePanel()
		-- 				ViewManager.open("GetTYSuccessView",data) 
		-- 			end
		-- 			RPCReq.HeroLottery_ActivityDraw(params, params.onSuccess)
		-- 		end
		-- 		Alert.show(info);
		else
			-- ModelManager.PlayerModel:isCostEnough(cost, true)
			local info = {}
			local itemName = ItemConfiger.getItemNameByCode(cost[1].code)
			-- local costNameIcon2 = ItemConfiger.getItemIconStrByCode(cost[1].code, cost[1].type, true)
			info.text = string.format("%s%s",itemName,Desc.activity_txt37)
			info.okText = DescAuto[120] -- [120]="前往商城"
			info.type = "ok"
			info.noClose = "no"
			info.onOk = function(flag)
				ModuleUtil.openModule(ModuleId.ActYjShopView.id)
			end
			Alert.show(info);
		end
	end,100)
    
	self.btn_gl:removeClickListener(100)
    self.btn_gl:addClickListener(function()
		ViewManager.open("HelpSystemView",{page="HelpSysRecomView"})
	end,100)

	
	--异界打开探员
	self.btnAdd:removeClickListener(100)
	self.btnAdd:addClickListener(function( ... )
		if not  self.viewData then
			RollTips.show(Desc.activity_txt13)
			return
		end
		ViewManager.open("GCHeroChooseView",{viewData = self.viewData})
	end,100)

	self.btnChange:removeClickListener(100)
	self.btnChange:addClickListener(function( ... )
		if not  self.viewData then
			RollTips.show(Desc.activity_txt13)
			return
		end
		ViewManager.open("GCHeroChooseView",{viewData=self.viewData})
	end,100)
	self:setPageGB()
	self:updatePanel()
end

function GetCardsYjActivityView:update_getCardsView( ... )
	self:updatePanel()
end

function GetCardsYjActivityView:setPageGB(  )
	self.view:getChildAutoType("bg"):setURL("Bg/getcard_bg8.jpg")
end


--监听协议 限制次数限制下发
function GetCardsYjActivityView:update_cardListTime( ... )
	print(1,"update_cardListTime")
    if tolua.isnull(self.view) then return end
	local timeLimit = DynamicConfigData.t_heroLottery[self.lotteryIdList[1]].timesLimit
	if (not self.data) and (not self.data.data) then return end
	local temp = timeLimit - self.data.data.count
	if tolua.isnull(self.view) then
		return
	end
	self.lastTimeLab:setText(Desc.getCard_9..temp)
	local num = self.data.leftUpCount>0 and self.data.leftUpCount or 1
	self.view:getChildAutoType("page7Text"):setVar("count",tostring(num))
	self.view:getChildAutoType("page7Text"):flushVars()
	-- self:updateItemCount()
end


function GetCardsYjActivityView:update_yj_heroPage()
   self:updatePanel()
end

--更新活动时间
function GetCardsYjActivityView:updateActTimeShow( ... )
	if self.__timerId then
		TimeLib.clearCountDown(self.__timerId)
		self.__timerId = false
	end
	local  id = 0 
	if self.viewData then
		id = self.viewData.id
	end
	local status,timems = ActivityModel:getActStatusAndLastTime( id)
	if status ==0 then
		self.txt_countTime:setText(Desc.activity_txt13)
		return
	end

	if timems == -1 then
		self.txt_countTime:setText(Desc.activity_txt5)
		return
	end
	if timems==0 then
		self.txt_countTime:setText(Desc.activity_txt13)
		return
	end
	timems = timems/1000
	
	local function updateCountdownView(time)
		if tolua.isnull(self.txt_countTime) then return end
		if time > 0 then
			local timeStr = TimeLib.GetTimeFormatDay(time,2)
			self.txt_countTime:setText(timeStr)
		else
			self.txt_countTime:setText(Desc.activity_txt18)
		end
	end
	updateCountdownView(timems)
	self.__timerId = TimeLib.newCountDown(timems, function(time)
		updateCountdownView(time)
	end, function()
		self.txt_countTime:setText(Desc.activity_txt4) -- TODO
	end, false, false, false)
end


--更新页面
function GetCardsYjActivityView:updatePanel( ... )
    if tolua.isnull(self.view) then return end
	local actiInfo = ActivityModel:getActityByType( GameDef.ActivityType.Farplane )
	self.viewData = actiInfo
	self:updateActTimeShow()
	if not actiInfo then --没数据 活动可能关了qF
		return
	end
	
	self.data = GetCardsYjActivityModel:getData(  )
	
	if not self.data then
		return
	end
	
	--设置显示的道具
	local configShow = GetCardsModel:getYJZMRewardConfig(self.viewData.showContent.moduleId)
	local maxNum = #configShow>8 and 8 or #configShow
	for i=1,maxNum do
		if self.itemCellArr[i] then
			break
		end
		local item = self.view:getChildAutoType("itemCell"..i)
		local itemcell = BindManager.bindItemCell(item)
		local itemData = ItemsUtil.createItemData({data = configShow[i]})
		itemcell:setIsBig(false)
		-- itemcell:setAmountVisible(false)
		itemcell:setItemData(itemData)
		self.itemCellArr[i] = itemcell
		--设置气泡颜色
		local color =itemData:getColorId()
		print(1,color)
		local qipao = self.view:getChildAutoType("qipao"..i)
		qipao:getController("colorCtrl"):setSelectedIndex(color)
	end

	self.lotteryIdList = self.viewData.showContent.lotteryIdList

	-- printTable(1,"self.viewData",self.viewData)
	if self.viewData.showContent.countReward then
		self.luckType = self.viewData.showContent.countReward
	else
		self.luckType = DynamicConfigData.t_heroLottery[self.lotteryIdList[1]].type
	end

	self:update_cardListTime()
	local config = GetCardsYjActivityModel:getConfigByNextId( self.luckType,self.data.data.count)
    if config then
    	self.hadNextCtrl:setSelectedIndex(0)
    	local itemcellObj = BindManager.bindItemCell(self.itemCell)
		itemcellObj:setIsBig(false)
		local itemData = ItemsUtil.createItemData({data = config.reward[1]})
		itemcellObj:setItemData(itemData,CodeType.ITEM)

		self.progressBar:setMax(config.num)
		self.progressBar:setValue(self.data.data.count)
	    self.protxt:setText(self.data.data.count.."/"..config.num)
    else
    	self.hadNextCtrl:setSelectedIndex(1)
	end
	
	local img_red_left = self.leftbtn:getChildAutoType("img_red")
	local img_red_right = self.rightbtn:getChildAutoType("img_red")
	local heroCode = self.data.data.heroCode
	local  page7Ctrl = self.view:getController("page7Ctrl")
	if heroCode  and heroCode >0 then
		page7Ctrl:setSelectedIndex(1)
		self.view:getChildAutoType("iconMask"):getChildAutoType("icon"):setURL(PathConfiger.getHeroOfMonsterIcon(heroCode))
	else
		page7Ctrl:setSelectedIndex(0)
	end

	local idArr = self.lotteryIdList
	local cost = DynamicConfigData.t_heroLottery[idArr[1]].cost[1] --异界单
	local cost2 = DynamicConfigData.t_heroLottery[idArr[2]].cost[1] --异界10
	-- local cost3 = DynamicConfigData.t_heroLottery[idArr[3]].cost[1] --异界单钻石
	-- local cost4 = DynamicConfigData.t_heroLottery[idArr[4]].cost[1] --异界10钻石

	local itemCode = DynamicConfigData.t_heroLottery[idArr[1]].cost[1].code 
	local hadFreeNum = self.data.data.freeTimes
	local hadItemNum = PackModel:getItemsFromAllPackByCode(itemCode)
	print(1,"hadFreeNum",hadFreeNum)

	if hadFreeNum>=1 then --有免费次数
		img_red_left:setVisible(true)
		self.leftCtrl:setSelectedIndex(0)
	else
		self.leftCtrl:setSelectedIndex(1)
		if hadItemNum>=cost.amount then --召唤券足够
			self.costItemObj1:setData(cost.type, cost.code, cost.amount, true, false, true)
			self:__setColorForCostItem(true, self.costItemLeft, cost.type, cost.code, cost.amount)
			img_red_left:setVisible(true)
		else
			self.costItemObj1:setData(cost.type, cost.code, cost.amount, true, false, true)
			self:__setColorForCostItem(true, self.costItemLeft, cost.type, cost.code, cost.amount)
			-- self.costItemObj1:setData(cost3.type, cost3.code, cost3.amount, true, false, true)
			-- self:__setColorForCostItem(true, self.costItemLeft, cost3.type, cost3.code, cost3.amount)
			img_red_left:setVisible(false)
		end	
	end

	if hadItemNum>=cost2.amount then --道具数量足够
		img_red_right:setVisible(true)
		self.costItemObj2:setData(cost2.type, cost2.code, cost2.amount, true, false, true)
		self:__setColorForCostItem(true, self.costItemRight, cost2.type, cost2.code, cost2.amount)
	else
		img_red_right:setVisible(false)
		self.costItemObj2:setData(cost2.type, cost2.code, cost2.amount, true, false, true)
		self:__setColorForCostItem(true, self.costItemRight, cost2.type, cost2.code, cost2.amount)
		--道具不足 检测钻石
		-- self.costItemObj2:setData(cost4.type, cost4.code, cost4.amount, true, false, true)
		-- self:__setColorForCostItem(true, self.costItemRight, cost4.type, cost4.code, cost4.amount)
	end
	
	--当前拥有
	local url = ItemConfiger.getItemIconByCode(itemCode)	
	self.itemicon:setURL(url)
	self.itemnum:setText(hadItemNum)

end

function GetCardsYjActivityView:updateItemCount(  )
	local cost = DynamicConfigData.t_heroLottery[self.lotteryIdList[1]].cost
	local url = ItemConfiger.getItemIconByCode(cost[1].code)
	local hadItemNum = PackModel:getItemsFromAllPackByCode(cost[1].code)
	self.itemicon:setURL(url)
	self.itemnum:setText(hadItemNum)

end

--initUI执行之前
function GetCardsYjActivityView:_enter( ... )

end

--页面退出时执行
function GetCardsYjActivityView:_exit( ... )
	print(1,"GetCardsYjActivityView _exit")
	if self.__timerId then
		TimeLib.clearCountDown(self.__timerId)
		self.__timerId =false
	end
end

return GetCardsYjActivityView
