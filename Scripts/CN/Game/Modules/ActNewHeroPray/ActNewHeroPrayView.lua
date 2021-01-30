--Date :2021-01-28
--Author : added by xhd 
--Desc : 新英雄皮肤售卖

local ActNewHeroPrayView,Super = class("ActNewHeroPrayView", Window)

function ActNewHeroPrayView:ctor()
	--LuaLog("ActNewHeroPrayView ctor")
	self._packName = "ActNewHeroPray"
	self._compName = "ActNewHeroPrayView"
	--self._rootDepth = LayerDepth.Window
	self.aniFlag = ActNewHeroPrayModel:getAniFlag()
	self.costItemObj1 = false
	self.costItemObj2 = false
	self.__timerId = false
	self.viewData = {}
end

function ActNewHeroPrayView:_initEvent( )
	
end

function ActNewHeroPrayView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:ActNewHeroPray.ActNewHeroPrayView
	self.awardList = viewNode:getChildAutoType('awardList')--GList
	self.btnLayer = viewNode:getChildAutoType('btnLayer')--GGroup
	self.btn_rule = viewNode:getChildAutoType('btn_rule')--GButton
	self.checkBox = viewNode:getChildAutoType('checkBox')--GButton
	self.checkBtn = viewNode:getChildAutoType('checkBtn')--GButton
	self.cost = viewNode:getChildAutoType('cost')--GGroup
	self.costItemLeft = viewNode:getChildAutoType('costItemLeft')--spcostItem2
		self.costItemLeft.iconLoader = viewNode:getChildAutoType('costItemLeft/iconLoader')--GLoader
		self.costItemLeft.txt_num = viewNode:getChildAutoType('costItemLeft/txt_num')--GRichTextField
	self.costItemRight = viewNode:getChildAutoType('costItemRight')--spcostItem2
		self.costItemRight.iconLoader = viewNode:getChildAutoType('costItemRight/iconLoader')--GLoader
		self.costItemRight.txt_num = viewNode:getChildAutoType('costItemRight/txt_num')--GRichTextField
	self.freeTxt = viewNode:getChildAutoType('freeTxt')--GTextField
	self.heroBtn = viewNode:getChildAutoType('heroBtn')--heroBtn
		self.heroBtn.heroName = viewNode:getChildAutoType('heroBtn/heroName')--GImage
		self.heroBtn.heroText = viewNode:getChildAutoType('heroBtn/heroText')--GTextField
	self.heroBtn2 = viewNode:getChildAutoType('heroBtn2')--GButton
	self.itemicon = viewNode:getChildAutoType('itemicon')--GLoader
	self.itemnum = viewNode:getChildAutoType('itemnum')--GTextField
	self.itemtxt = viewNode:getChildAutoType('itemtxt')--GTextField
	self.leftCtrl = viewNode:getController('leftCtrl')--Controller
	self.leftbtn = viewNode:getChildAutoType('leftbtn')--GButton
	self.page = viewNode:getController('page')--Controller
	self.rightbtn = viewNode:getChildAutoType('rightbtn')--GButton
	self.tipShowBtn = viewNode:getChildAutoType('tipShowBtn')--GButton
	self.txt_countTime = viewNode:getChildAutoType('txt_countTime')--GTextField
	self.txt_countTitle = viewNode:getChildAutoType('txt_countTitle')--GTextField
	--{autoFieldsEnd}:ActNewHeroPray.ActNewHeroPrayView
	--Do not modify above code-------------
end

function ActNewHeroPrayView:__setColorForCostItem(specific, costItem, type, code, amount)
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

function ActNewHeroPrayView:_initListener( )
	
	self.awardList:setItemRenderer(function(index, obj)
	   local itemObj = BindManager.bindItemCell(obj)
	   local data = self.awardList._dataTemplate[index+1]
	   itemObj:setData(data.code, data.amount, data.type)
	end)

	self.btn_rule:addClickListener(function()
		local info={}
		info['title']=Desc["help_StrTitle187"]
		info['desc']=Desc["help_StrDesc187"]
		ViewManager.open("GetPublicHelpView",info) 
	end)

	self.checkBtn:addClickListener(function()
		local actiInfo = ActivityModel:getActityByType( GameDef.ActivityType.NewHeroSummon )
		if not actiInfo then --没数据 活动可能关了
			return
		end
		 local config = ActNewHeroPrayModel:getAllYJZMAllConfig(self.viewData.showContent.moduleId)
		 RollTips.showRateTips(config)
	end)

	--跳过动画
	self.checkBox:addClickListener(function( ... )
		-- body
		self.aniFlag = not self.aniFlag
		ActNewHeroPrayModel:setAniFlag(self.aniFlag )
	end)
end

function ActNewHeroPrayView:update_getCardsView( ... )
	self:updatePanel()
end


function ActNewHeroPrayView:updatePanel( ... )
	local moduleId = ActNewHeroPrayModel:getModuleId()
	local heroId = DynamicConfigData.t_NewHeroShow[moduleId].hero
	local cost = DynamicConfigData.t_NewHeroDrawConfig[moduleId][1].costItem[1]
	local cost2 = DynamicConfigData.t_NewHeroDrawConfig[moduleId][2].costItem[1]
	local func = function()
		local code = heroId
		local category = DynamicConfigData.t_hero[code].category
    	local categoryHeros = DynamicConfigData.t_HeroTotems[category]
		local _cardInfoList = {}
		for _,v in pairs(categoryHeros) do
			if  tonumber(code)==v.hero then
				table.insert(_cardInfoList, v)
			end
		end
		ViewManager.open("HeroInfoView",{index = 1,heroId =tonumber(code),heroList = _cardInfoList })
	end
    self.heroBtn:removeClickListener(100)
	self.heroBtn:addClickListener(function()
		func()
	end,100)

	self.heroBtn2:removeClickListener(100)
	self.heroBtn2:addClickListener(function()
		func()
	end,100)
	
	self.tipShowBtn:removeClickListener(100)
	self.tipShowBtn:addClickListener(function()
		local itemData = ItemsUtil.createItemData({data = {type = cost.type, code = cost.code, amount = 1}})
		ViewManager.open("ItemTips", {codeType = cost.type, id = cost.code, data = itemData})
	end,100)
	
	self.leftbtn:removeClickListener(100)
	self.leftbtn:addClickListener(function()
		if not self.viewData then
			RollTips.show(Desc.shop_activityEnd)
			return
		end
		local params = {}
		params.drawType = 1
		params.activityType = GameDef.ActivityType.NewHeroSummon
		params.onSuccess = function (res )
		end
		printTable(1,"前端params",params)
		RPCReq.Activity_NewHeroSummon_Draw(params, params.onSuccess)

	end,100)

	self.rightbtn:removeClickListener(100)
	self.rightbtn:addClickListener(function()
		if not self.viewData then
			RollTips.show(Desc.shop_activityEnd)
			return
		end
		local params = {}
		params.drawType = 2
		params.activityType = GameDef.ActivityType.NewHeroSummon
		params.onSuccess = function (res )
		end
		params.onSuccess = function (res )
		end
		RPCReq.Activity_NewHeroSummon_Draw(params, params.onSuccess)
	end,100)
	
	self.awardList:setData(DynamicConfigData.t_NewHeroShow[moduleId].item)
	
	if moduleId == 1 then
		self.page:setSelectedIndex(0) --御神子
	elseif moduleId == 2 then
		self.page:setSelectedIndex(1) --貂蝉
	end

	local actiInfo = ActivityModel:getActityByType( GameDef.ActivityType.NewHeroSummon )
	self.viewData = actiInfo
	printTable(1,"活动配置",self.viewData)
	self:updateActTimeShow()
	if not actiInfo then --没数据 活动可能关了
		return
	end
	self.data = ActNewHeroPrayModel:getData(  )

	local img_red_left = self.leftbtn:getChildAutoType("img_red")
	local img_red_right = self.rightbtn:getChildAutoType("img_red")
	if self.data and (not self.data.isFreeDraw) then --有免费次数
		img_red_left:setVisible(true)
		self.leftCtrl:setSelectedIndex(0)
	else
		self.leftCtrl:setSelectedIndex(1)
		img_red_left:setVisible(false)
		local flag = PlayerModel:isCostEnough(DynamicConfigData.t_NewHeroDrawConfig[moduleId][1].costItem, false)
		if flag then
			self.costItemObj1:setData(cost.type, cost.code, cost.amount, true, false, true)
			self:__setColorForCostItem(true, self.costItemLeft, cost.type, cost.code, cost.amount)
			-- img_red_left:setVisible(true)
		else
			self.costItemObj1:setData(cost.type, cost.code, cost.amount, true, false, true)
			self:__setColorForCostItem(true, self.costItemLeft, cost.type, cost.code, cost.amount)
			-- img_red_left:setVisible(false)
		end	
	end

	self.costItemObj2:setData(cost2.type, cost2.code, cost2.amount, true, false, true)
	self:__setColorForCostItem(true, self.costItemRight, cost2.type, cost2.code, cost2.amount)
	
	--当前拥有
	local url = ItemConfiger.getItemIconByCode(cost.code)	
	self.itemicon:setURL(url)
	local moneyNum =  PlayerModel:getMoneyByType(GameDef.MoneyType.NewHeroDrawCoin)
	self.itemnum:setText(moneyNum)

end

function ActNewHeroPrayView:_initUI( )
	self:_initVM()
	self:_initListener()
	self.costItemObj1 = BindManager.bindCostItem(self.costItemLeft)
	self.costItemObj2 = BindManager.bindCostItem(self.costItemRight)
	self.costItemObj1:setUseMoneyItem(true);
	self.costItemObj2:setUseMoneyItem(true);
	self:updatePanel()
end


--更新活动时间
function ActNewHeroPrayView:updateActTimeShow( ... )
	if self.__timerId then
		TimeLib.clearCountDown(self.__timerId)
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
		if tolua.isnull(self.txt_countTime) then
			return
		end
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
		if tolua.isnull(self.txt_countTime) then
			return
		end
		self.txt_countTime:setText(Desc.activity_txt4) -- TODO
	end, false, false, false)
end


--页面退出时执行
function ActNewHeroPrayView:_exit( ... )
	print(1,"ActNewHeroPrayView _exit")
	if self.__timerId then
		TimeLib.clearCountDown(self.__timerId)
	end
end



return ActNewHeroPrayView