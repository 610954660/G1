--added by xhd 卡牌召唤
local GetCardsView,Super = class("GetCardsView",Window)
local TimeLib = require "Game.Utils.TimeLib"
local lotteryType = GameDef.HeroLotteryType
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
function GetCardsView:ctor( ... )
	self._packName = "GetCards"
	self._compName = "GetCardsWindow"
	self.showconCtrl = false
	self.leftList = false

	self.lastTime = false
	self.progressBar = false
	self.aixinBtn = false
	self.leftbtn = false
	self.rightbtn = false
	self.itemicon = false
	self.itemnum = false
	self.btn_gl = false
	self.btn_vipShop = false

	self.curPage = 1
	self.prePage = false
	self.calltimer = false
	self.pageMapTypeVal = {lotteryType.Normal,lotteryType.Rare,lotteryType.Special,lotteryType.FriendShip,lotteryType.NewPlayer,lotteryType.Up,lotteryType.SeniorVIP} 
	self._showParticle=true
	self.lastTimeLab = false

	self.costItemLeft = false
	self.costItemRight = false
	
	self.cur_type = 1 --当前选择的类型
	self.isSpecColor = false
	
	

  --特异召唤------------------
  self.btn_tygn= false
  self.btn_tyzm =false
  self.tyList =false
  self.btn_tyshop = false
  self.costItem = false
  self.tykeyValArr = {22,23,24,21} --特异的ID
  self.tabArr = {}
  self.tyItemCellArr = {}
  self.timeId = false
end

-------------------常用------------------------
--UI初始化
function GetCardsView:_initUI( ... )
  self.showconCtrl = self.view:getController("showcrtl1")
  self.timeShowCtrl = self.view:getController("timeShowCtrl")
  self.leftCtrl  = self.view:getController("leftCtrl")
  self.leftList = self.view:getChildAutoType("leftList") 
  self.roleImg = self.view:getChildAutoType("roleImg")

  self.lastTime = self.view:getChildAutoType("lastTime")
  self.timeTxt = self.view:getChildAutoType("timeTxt")
  self.progressBar = self.view:getChildAutoType("progressBar")
  self.aixinBtn = self.view:getChildAutoType("aixinBtn")
  self.aixinNum = self.view:getChildAutoType("aixinNum")
  self.leftbtn = self.view:getChildAutoType("leftbtn")
  self.rightbtn = self.view:getChildAutoType("rightbtn")
	local itemicon = self.view:getChildAutoType("itemicon")
	self.itemicon = BindManager.bindCostIcon(itemicon)
  self.itemnum = self.view:getChildAutoType("itemnum")
  self.lastTimeLab = self.view:getChildAutoType("gj_lastTime_lab")
  self.btn_gl = self.view:getChildAutoType("btn_gl")
  self.btn_vipShop = self.view:getChildAutoType("btn_vipShop")
  
  self.costItemLeft = self.view:getChildAutoType("costItemLeft")
  self.costItemRight = self.view:getChildAutoType("costItemRight")

  self.costItemObj1 = BindManager.bindCostItem(self.costItemLeft)
  self.costItemObj2 = BindManager.bindCostItem(self.costItemRight)
  self.costItemObj1:setUseMoneyItem(true);
  self.costItemObj2:setUseMoneyItem(true);
  
  --特异召唤------------------
  self.btn_tygn= self.view:getChildAutoType("btn_tygn")
  self.btn_tyzm = self.view:getChildAutoType("btn_tyzm")
  self.tyList = self.view:getChildAutoType("tyList")
  self.btn_tyshop = self.view:getChildAutoType("btn_tyshop")
  self.btn_tylibao = self.view:getChildAutoType("btn_tylibao")
  self.costItem = self.view:getChildAutoType("costItem")
  self.btn_tyzh = self.view:getChildAutoType("btn_tyzh")
	--SpineUtil.createSpineObj(self.btn_tygn, vertex2(58,54), "teyi_gongneng", "Spine/ui/button", "anniu_texiao", "anniu_texiao",true)
	--SpineUtil.createSpineObj(self.btn_tyshop, vertex2(59,80), "teyi_shangcheng", "Spine/ui/button", "anniu_texiao", "anniu_texiao",true)
 --------------------------------------
  self.btnAdd = self.view:getChildAutoType("btnAdd")
  self.btnChange = self.view:getChildAutoType("btn_change")
  self.maskAni = self.view:getChildAutoType("maskAni")
--   self:playOpenAni()
end

--播放开场动画
function GetCardsView:playOpenAni(  )
	if self.timeId then
		Scheduler.unschedule(self.timeId)
		self.timeId = false
	end			
	
	self.maskAni:setVisible(true)
	local timeCount = 0
	local function updateCall(interval)
		timeCount = timeCount + interval*1.5
		if timeCount>=1 then
			if tolua.isnull(self.maskAni) then
				return
			end
			self.maskAni:setVisible(false)
			Scheduler.unschedule(self.timeId)
			self.timeId = false
		end
		self.maskAni:getChildAutoType("n211"):setScale(12*timeCount,12*timeCount)
	end
	
	self.timeId = Scheduler.schedule(updateCall,0,0)
end

--对应关系 1普通 2高级 3特异 4 友情 5 新手 6 up  7 仙魔   8 异界
function GetCardsView:makeWindowTab()
	local data = {}

	-- 普通
	table.insert(data, {
		mid=ModuleId.GetCard_Normal.id,
		page = 1,
		text = Desc.GetCard_Text2,
		redType = "V_GETCARD_NORMAL",
	})

	-- 高级
	table.insert(data, {
		mid=ModuleId.GetCard_Senior.id,
		page = 2,
		text = Desc.GetCard_Text3,
		redType = "V_GETCARD_SENIOR",
	})

	-- 特异
	table.insert(data, {
		mid=ModuleId.TeyiGetCard.id,
		page = 3,
		text = Desc.GetCard_Text4,
		redType = "V_GETCARD_SPECIAL",
	})

	-- 友情
	table.insert(data, {
		mid=ModuleId.GetCard_Friend.id,
		page = 4,
		text = Desc.GetCard_Text5,
		redType = "V_GETCARD_FRIEND",
	})

	 --    local time  = GetCardsModel:getNewPlayerTime()
	-- local lastCount  = GetCardsModel:getNewPlayerLastCount()
	-- if time>0 and lastCount>0 then
	-- 	local temp = {}
	-- 	temp.page = 5  --新手
	-- 	temp.redType = "V_GETCARD_NEWPLAYER"
	-- 	table.insert(data,temp)
	-- end

 --    time  = GetCardsModel:getUpTime()
	-- lastCount  = GetCardsModel:getUpLastCount()
	-- if time>0 and lastCount>0 then
	-- 	local temp = {}
	-- 	temp.page = 6  --UP
	-- 	temp.redType = "V_GETCARD_UP"
	-- 	table.insert(data,temp)
 --    end

 	-- 仙魔
	 table.insert(data, {
		mid=ModuleId.GetCard_alienLand.id,
		page = 7,
		text = Desc.GetCard_Text6,
		redType = "V_GETCARD_ALIENLAND",
	})

	local confs={}
	for i = 1, #data, 1 do
		local configInfo= data[i]    
			local tips=ModuleUtil.moduleOpen(configInfo.mid,false)
			if tips==true then--前端开启了该功能
				table.insert( confs, configInfo)
			end
		end
	return confs
end

function GetCardsView:getIndexByPageIndex( pageIndex )
	for i,v in ipairs(self.tabArr) do
		if v.page ==pageIndex then
			return i
		end
	end
	return nil
end

function GetCardsView:__setColorForCostItem(specific, costItem, type, code, amount)
	self.isSpecColor = specific
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
function GetCardsView:_initEvent( ... )

    --帮助按钮
     self.btn_help:removeClickListener()
	 self.btn_help:addClickListener(function( ... )
		if self.curPage == 1 or self.curPage ==2 or self.curPage ==4 then
			ViewManager.open("GetCardsHelpView",{moduleId = 1})
		elseif self.curPage ==7 then
			ViewManager.open("GetCardsHelpView",{moduleId = 2})
		elseif self.curPage == 3 then
			local info={}
	            info['title']=Desc["help_StrTitle"..62]
	            info['desc']=Desc["help_StrDesc"..62]
	            ViewManager.open("GetPublicHelpView",info)
		end
	 end)
	
	--左边召唤列表
	self.leftList:setItemRenderer(function (index,obj)
		local tempData = self.tabArr[index+1]
		RedManager.register(tempData.redType, obj:getChild("img_red"))
		obj:setTitle(tempData.text)
		obj:removeClickListener(100)
		obj:addClickListener(function( ... )
			if not ModuleUtil.moduleOpen(tempData.mid, true) then
				self.leftList:setSelectedIndex(self.cur_type)
				return
			end
			-- self:playOpenAni()
			self.cur_type = index
			if tempData.page == 3 then
				local mInfo = DynamicConfigData.t_module[ModuleId.TeyiGetCard.id]
				local tips = ModuleUtil.getModuleOpenTips(ModuleId.TeyiGetCard.id)
				if tips~=nil then
    	            self.leftList:setSelectedIndex(self.curPage-1)
					RollTips.show(tips..mInfo.name)
					return 
				end
			end

			if tempData.page == 5 then
				local time  = GetCardsModel:getNewPlayerTime()
				local lastCount  = GetCardsModel:getNewPlayerLastCount()
				if time<=0 then
    	            self.leftList:setSelectedIndex(self.curPage-1)
					RollTips.show(Desc.GetCard_Text7)
					return 
				end
				if lastCount<= 0 then
					self.leftList:setSelectedIndex(self.curPage-1)
					RollTips.show(Desc.GetCard_Text8)
					return 
				end
			end

			if tempData.page == 6 then
				local time  = GetCardsModel:getUpTime()
				local lastCount  = GetCardsModel:getUpLastCount()
				if time<=0 then
    	            self.leftList:setSelectedIndex(self.curPage-1)
					RollTips.show(Desc.GetCard_Text9)
					return 
				end
				if lastCount<= 0 then
					self.leftList:setSelectedIndex(self.curPage-1)
					RollTips.show(Desc.GetCard_Text10)
					return 
				end
			end

			self.curPage = tempData.page
            
			if self.prePage~=self.curPage then
				self.prePage = self.curPage
				GetCardsModel:setSelectPage(self.curPage)
				self:setPageGB()
				self:updatePanel()
			end

		end,100)
	end)
	
	--特异招募列表
    self.tyList:addEventListener(FUIEventType.ClickItem,function()
		local index = self.tyList:getSelectedIndex() + 1
		self.view:getController("page3CostCtrl"):setSelectedIndex(1)
        local costitemObj = BindManager.bindCostItem(self.costItem)
        local cost = DynamicConfigData.t_heroLottery[self.tykeyValArr[index]].cost[1]
        costitemObj:setData(cost.type, cost.code, cost.amount, true, false, true)
		self:__setColorForCostItem(true, self.costItem, cost.type, cost.code, cost.amount)
	end)

	for i=1,4 do
		local btn = self.view:getChildAutoType("page3Btn"..i)
		btn:addClickListener(function()
			ViewManager.open("GetTyAwardShowView",{selectIndex=i,})
		end)
	end
	
	--单抽按钮
    self.leftbtn:removeClickListener(100)
	self.leftbtn:addClickListener(function ( ... )
		if CardLibModel:isBagFull(1) then 
			local arg = {
                text = Desc.GetCard_Text19,
                type = "yes_no",
				onYes = function()  
					ModuleUtil.openModule(ModuleId.Hero.id, true)
				end,
				yesText = Desc.GetCard_Text20
            }
            Alert.show(arg)
			return 
		end
	    if self.curPage == 1 then
		 	local cost = DynamicConfigData.t_heroLottery[1].cost
		 	local itemCode = cost[1].code --需要道具
		 	if GetCardsModel:getFreeData( self.pageMapTypeVal[self.curPage])>=1 then --如果是免费
		 		local params = {}
		 		params.id = 6
		 		params.onSuccess = function (res )
	 			    local data = {}
		 		    data.resultList = res.resultList
		 		    data.itemCode = itemCode
		 		    data.id = 1
		 		    data.xhType = 1
		 		    data.cost = cost
		 			ViewManager.open("GetSuccess1View",data)
		 		end
		 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
		 	else
		 		if not ModelManager.PlayerModel:isCostEnough(cost, true) then
	    			return
	    		end
	 			local params = {}
		        params.id = 1
		 		params.onSuccess = function (res )
		 		    local data = {}
		 		    data.resultList = res.resultList
		 		    data.itemCode = itemCode
		 		    data.id = 1
		 		    data.xhType = 1
		 		    data.cost = cost
		 			ViewManager.open("GetSuccess1View",data)
		 		end
		 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
		 	end
		elseif self.curPage == 2 then
			local cost = DynamicConfigData.t_heroLottery[3].cost --高级单抽
			local cost2 = DynamicConfigData.t_heroLottery[8].cost --高级钻石

		 	local itemCode = cost[1].code --道具需要
		 	local xhnum = cost2[1].amount --钻石消耗

		 	if GetCardsModel:getFreeData( self.pageMapTypeVal[self.curPage])>=1 then --如果是免费
		 		local params = {}
		 		params.id = 7
		 		params.onSuccess = function (res )
		 		    local data = {}
		 		    data.resultList = res.resultList
		 		    local temp = PackModel:getItemsFromAllPackByCode(itemCode)
                    if temp >=1 then --有道具 成功页显示道具
		 		       data.id = 3
		 		       data.xhType = 1
		 		       data.itemCode = itemCode
		 		       data.cost = cost
		 		    else --没有道具 显示钻石
		 		    	data.id = 8
		 		    	data.xhType = 2
		 		    	data.itemCode = cost2[1].code
		 		        data.cost = cost2
		 		    end
		 			ViewManager.open("GetSuccess1View",data)
		 		end
		 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
		 	elseif PackModel:getItemsFromAllPackByCode(itemCode) >=cost[1].amount then
		 		local num = PackModel:getItemsFromAllPackByCode(itemCode)
	 			local params = {}
		        params.id = 3
		 		params.onSuccess = function (res )
		 			local data = {}
		 		    data.resultList = res.resultList
		 		    local temp = num -cost[1].amount
		 		    if temp >=cost[1].amount then --道具还足够
		 		       data.id = 3
		 		       data.xhType = 1
		 		       data.itemCode = itemCode
		 		       data.cost = cost
		 		    else  --道具刚好用完
		 		    	data.id = 8
		 		    	data.xhType = 2
		 		    	data.itemCode = cost2[1].code
		 		        data.cost = cost2
		 		    end
		 			ViewManager.open("GetSuccess1View",data)
		 		end
		 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
			 elseif PlayerModel:getMoneyByType(GameDef.MoneyType.Diamond)>=xhnum then --钻石消耗足够
				local info = {
					text=string.format(Desc.getCard_2,cost2[1].amount,1000,1,Desc.getCard_3),
					type="yes_no",
				}
				info.onYes = function()
					local params = {}
						params.id = 8
						params.onSuccess = function (res )
						local data = {}
						data.resultList = res.resultList
						data.itemCode = cost2[1].code
						data.id = 8
						data.xhType = 2
						data.cost = cost2
						ViewManager.open("GetSuccess1View",data)
					end
					RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
				end
				Alert.show(info);
		 		
			else
                ModelManager.PlayerModel:isCostEnough(cost, true)
		 	end
		elseif self.curPage == 4 then --友情
			local cost = DynamicConfigData.t_heroLottery[30].cost
		 	local itemCode = cost[1].code --需要道具
	 		if not ModelManager.PlayerModel:isCostEnough(cost, true) then
    			return
    		end
 			local params = {}
	        params.id = 30
	 		params.onSuccess = function (res )
	 		    local data = {}
	 		    data.resultList = res.resultList
	 		    data.itemCode = itemCode
	 		    data.id = 30
	 		    data.xhType = 3
	 		    data.cost = cost
	 			ViewManager.open("GetSuccess1View",data)
	 		end
	 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
	 	elseif self.curPage == 5 then --新手
	 		local cost = DynamicConfigData.t_heroLottery[32].cost 
			local cost2 = DynamicConfigData.t_heroLottery[34].cost 

		 	local itemCode = cost[1].code --道具需要
		 	local xhnum = cost2[1].amount --钻石消耗

		 	if GetCardsModel:getFreeData( self.pageMapTypeVal[self.curPage])>=1 then --如果是免费
		 		local params = {}
		 		params.id = 36
		 		params.onSuccess = function (res )
		 		    local data = {}
		 		    data.resultList = res.resultList
		 		    local temp = PackModel:getItemsFromAllPackByCode(itemCode)
                    if temp >=1 then --有道具 成功页显示道具
		 		       data.id = 32
		 		       data.xhType = 1
		 		       data.itemCode = itemCode
		 		       data.cost = cost
		 		    else --没有道具 显示钻石
		 		    	data.id = 34
		 		    	data.xhType = 2
		 		    	data.itemCode = cost2[1].code
		 		        data.cost = cost2
		 		    end
		 			ViewManager.open("GetSuccess1View",data)
		 		end
		 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
		 	elseif PackModel:getItemsFromAllPackByCode(itemCode) >=cost[1].amount then
		 		local num = PackModel:getItemsFromAllPackByCode(itemCode)
	 			local params = {}
		        params.id = 32
		 		params.onSuccess = function (res )
		 			local data = {}
		 		    data.resultList = res.resultList
		 		    local temp = num -cost[1].amount
		 		    if temp >=cost[1].amount then --道具还足够
		 		       data.id = 32
		 		       data.xhType = 1
		 		       data.itemCode = itemCode
		 		       data.cost = cost
		 		    else  --道具刚好用完
		 		    	data.id = 34
		 		    	data.xhType = 2
		 		    	data.itemCode = cost2[1].code
		 		        data.cost = cost2
		 		    end
		 			ViewManager.open("GetSuccess1View",data)
		 		end
		 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
		 	elseif PlayerModel:getMoneyByType(GameDef.MoneyType.Diamond)>=xhnum then --钻石消耗足够
		 		local params = {}
	 		    params.id = 34
		 		params.onSuccess = function (res )
		 			local data = {}
		 		    data.resultList = res.resultList
		 		    data.itemCode = cost2[1].code
		 		    data.id = 34
		 		    data.xhType = 2
		 		    data.cost = cost2
		 			ViewManager.open("GetSuccess1View",data)
		 		end
		 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
			else
                ModelManager.PlayerModel:isCostEnough(cost, true)
		 	end
		elseif self.curPage == 6 then --UP
	 		local cost = DynamicConfigData.t_heroLottery[41].cost 
			local cost2 = DynamicConfigData.t_heroLottery[43].cost 
		 	local itemCode = cost[1].code --道具需要
		 	local xhnum = cost2[1].amount --钻石消耗

		 	if PackModel:getItemsFromAllPackByCode(itemCode) >=cost[1].amount then
		 		local num = PackModel:getItemsFromAllPackByCode(itemCode)
	 			local params = {}
		        params.id = 41
		 		params.onSuccess = function (res )
		 			local data = {}
		 		    data.resultList = res.resultList
		 		    local temp = num -cost[1].amount
		 		    if temp >=cost[1].amount then --道具还足够
		 		       data.id = 41
		 		       data.xhType = 1
		 		       data.itemCode = itemCode
		 		       data.cost = cost
		 		    else  --道具刚好用完
		 		    	data.id = 43
		 		    	data.xhType = 2
		 		    	data.itemCode = cost2[1].code
		 		        data.cost = cost2
		 		    end
		 			ViewManager.open("GetSuccess1View",data)
		 		end
		 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
		 	elseif PlayerModel:getMoneyByType(GameDef.MoneyType.Diamond)>=xhnum then --钻石消耗足够
		 		local params = {}
	 		    params.id = 43
		 		params.onSuccess = function (res )
		 			local data = {}
		 		    data.resultList = res.resultList
		 		    data.itemCode = cost2[1].code
		 		    data.id = 43
		 		    data.xhType = 2
		 		    data.cost = cost2
		 			ViewManager.open("GetSuccess1View",data)
		 		end
		 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
			else
                ModelManager.PlayerModel:isCostEnough(cost, true)
			end
		elseif self.curPage == 7 then --仙魔
			local cost = DynamicConfigData.t_heroLottery[45].cost --仙魔单抽
			local cost2 = DynamicConfigData.t_heroLottery[47].cost --仙魔钻石

		 	local itemCode = cost[1].code --道具需要
		 	local xhnum = cost2[1].amount --钻石消耗

		 	if GetCardsModel:getFreeData( self.pageMapTypeVal[self.curPage])>=1 then --如果是免费
		 		local params = {}
				params.id = 49
				 params.onSuccess = function (res )
					printTable(1,res)
		 		    local data = {}
		 		    data.resultList = res.resultList
		 		    local temp = PackModel:getItemsFromAllPackByCode(itemCode)
                    if temp >=1 then --有道具 成功页显示道具
		 		       data.id = 45
		 		       data.xhType = 1
		 		       data.itemCode = itemCode
		 		       data.cost = cost
		 		    else --没有道具 显示钻石
		 		    	data.id = 47
		 		    	data.xhType = 2
		 		    	data.itemCode = cost2[1].code
		 		        data.cost = cost2
		 		    end
		 			ViewManager.open("GetSuccess1View",data)
				 end
				 printTable(1,params)
		 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
		 	elseif PackModel:getItemsFromAllPackByCode(itemCode) >=cost[1].amount then
		 		local num = PackModel:getItemsFromAllPackByCode(itemCode)
	 			local params = {}
		        params.id = 45
		 		params.onSuccess = function (res )
		 			local data = {}
		 		    data.resultList = res.resultList
		 		    local temp = num -cost[1].amount
		 		    if temp >=cost[1].amount then --道具还足够
		 		       data.id = 45
		 		       data.xhType = 1
		 		       data.itemCode = itemCode
		 		       data.cost = cost
		 		    else  --道具刚好用完
		 		    	data.id = 47
		 		    	data.xhType = 2
		 		    	data.itemCode = cost2[1].code
		 		        data.cost = cost2
		 		    end
		 			ViewManager.open("GetSuccess1View",data)
		 		end
		 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
			 elseif PlayerModel:getMoneyByType(GameDef.MoneyType.Diamond)>=xhnum then --钻石消耗足够
				local info = {
					text=string.format(Desc.getCard_2,cost2[1].amount,1000,1,Desc.getCard_4),
					type="yes_no",
				}
				info.onYes = function()
					local params = {}
					params.id = 47
					params.onSuccess = function (res )
						local data = {}
						data.resultList = res.resultList
						data.itemCode = cost2[1].code
						data.id = 8
						data.xhType = 2
						data.cost = cost2
						ViewManager.open("GetSuccess1View",data)
					end
					RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
				end
				Alert.show(info);
			else
                ModelManager.PlayerModel:isCostEnough(cost, true)
			end
		end
	end,100)
	
	--十连抽按钮
    self.rightbtn:removeClickListener(100)
	self.rightbtn:addClickListener(function ( ... )
		if CardLibModel:isBagFull(10) then 
			-- RollTips.show(Desc.getCard_bagFull)
			local arg = {
                text = Desc.GetCard_Text19,
                type = "yes_no",
				onYes = function()  
					ModuleUtil.openModule(ModuleId.Hero.id, true)
				end,
				yesText = Desc.GetCard_Text20
            }
            Alert.show(arg)
			return 
		end
		if self.curPage == 1 then
		 	--请求服务器
		 	local cost = DynamicConfigData.t_heroLottery[2].cost --单抽10
		 	local itemCode = cost[1].code --道具消耗
		 	if not ModelManager.PlayerModel:isCostEnough(cost, true) then
    			return
    		end
	 		local params = {}
 		    params.id = 2
	 		params.onSuccess = function (res )
	 			local data = {}
	 		    data.resultList = res.resultList
				data.resultList = TableUtil.randomSortArray(data.resultList)
	 		    data.itemCode = itemCode
	 		    data.id = 2
	 		    data.xhType = 1
	 		    data.cost = cost
	 			ViewManager.open("GetSuccess2View",data)
	 		end
	 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
		elseif self.curPage == 2 then
			local cost = DynamicConfigData.t_heroLottery[4].cost --高级10
			local cost2 = DynamicConfigData.t_heroLottery[9].cost --高级钻石10
		 	local itemCode =cost[1].code --道具消耗
		 	local num = PackModel:getItemsFromAllPackByCode(itemCode)
		 	local xhnum = cost2[1].amount --钻石消耗
		 	if num >=cost[1].amount then  --道具足够
		 		local params = {}
	 		    params.id = 4
		 		params.onSuccess = function (res )
		 			local data = {}
		 		    data.resultList = res.resultList
					data.resultList = TableUtil.randomSortArray(data.resultList)
		 		    
		 		    local temp = num - cost[1].amount
		 		    if num>=cost[1].amount then --道具还足够
		 		    	data.id = 4
		 		    	data.xhType = 1
		 		    	data.itemCode = itemCode
		 		    	data.cost = cost
		 		    else --道具不足
		 		    	data.id = 9
		 		    	data.xhType = 2
		 		    	data.itemCode = cost2[1].code
		 		    	data.cost = cost2
		 		    end
		 			ViewManager.open("GetSuccess2View",data)
		 		end
		 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
			 elseif PlayerModel:getMoneyByType(GameDef.MoneyType.Diamond)>=xhnum then --钻石消耗足够
				local info = {
					text=string.format(Desc.getCard_2,cost2[1].amount,10000,10,Desc.getCard_3),
					type="yes_no",
				}
				info.onYes = function()
					local params = {}
					params.id = 9
					params.onSuccess = function (res )
						local data = {}
						data.resultList = res.resultList
					   data.resultList = TableUtil.randomSortArray(data.resultList)
						data.itemCode = cost2[1].code
						data.id = 9
						data.xhType = 2
						data.cost = cost2
						ViewManager.open("GetSuccess2View",data)
					end
					RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
				end
				Alert.show(info);
		 	else
                ModelManager.PlayerModel:isCostEnough(cost, true)
		 	end
		elseif  self.curPage == 4 then
			local cost = DynamicConfigData.t_heroLottery[31].cost --友情10
		 	local itemCode = cost[1].code --道具消耗
		 	if not ModelManager.PlayerModel:isCostEnough(cost, true) then
    			return
    		end
	 		local params = {}
 		    params.id = 31
	 		params.onSuccess = function (res )
	 			local data = {}
	 		    data.resultList = res.resultList
				data.resultList = TableUtil.randomSortArray(data.resultList)
	 		    data.itemCode = itemCode
	 		    data.id = 31
	 		    data.xhType = 3
	 		    data.cost = cost
	 			ViewManager.open("GetSuccess2View",data)
	 		end
	 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
		elseif self.curPage ==5 or self.curPage ==6 then
			local idArr = {}
			if self.curPage == 5 then
				idArr = {33,35}
			elseif self.curPage == 6 then
				idArr = {42,44}
			end

			local cost = DynamicConfigData.t_heroLottery[idArr[1]].cost
			local cost2 = DynamicConfigData.t_heroLottery[idArr[2]].cost 
		 	local itemCode =cost[1].code --道具消耗
		 	local num = PackModel:getItemsFromAllPackByCode(itemCode)
		 	local xhnum = cost2[1].amount --钻石消耗
		 	if num >=cost[1].amount then  --道具足够
		 		local params = {}
	 		    params.id = idArr[1]
		 		params.onSuccess = function (res )
		 			local data = {}
		 		    data.resultList = res.resultList
					data.resultList = TableUtil.randomSortArray(data.resultList)
		 		    
		 		    local temp = num - cost[1].amount
		 		    if num>=cost[1].amount then --道具还足够
		 		    	data.id =idArr[1]
		 		    	data.xhType = 1
		 		    	data.itemCode = itemCode
		 		    	data.cost = cost
		 		    else --道具不足
		 		    	data.id = idArr[2]
		 		    	data.xhType = 2
		 		    	data.itemCode = cost2[1].code
		 		    	data.cost = cost2
		 		    end
		 			ViewManager.open("GetSuccess2View",data)
		 		end
		 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
		 	elseif PlayerModel:getMoneyByType(GameDef.MoneyType.Diamond)>=xhnum then --钻石消耗足够
		 		local params = {}
	 		    params.id = idArr[2]
		 		params.onSuccess = function (res )
		 			local data = {}
		 		    data.resultList = res.resultList
					data.resultList = TableUtil.randomSortArray(data.resultList)
		 		    data.itemCode = cost2[1].code
		 		    data.id = idArr[2]
		 		    data.xhType = 2
		 		    data.cost = cost2
		 			ViewManager.open("GetSuccess2View",data)
		 		end
		 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
		 	else
                ModelManager.PlayerModel:isCostEnough(cost, true)
			 end
		elseif self.curPage == 7 then
			local cost = DynamicConfigData.t_heroLottery[46].cost --仙魔十连（高V）
			local cost2 = DynamicConfigData.t_heroLottery[48].cost --仙魔十连-钻石（高V）
		 	local itemCode =cost[1].code --道具消耗
		 	local num = PackModel:getItemsFromAllPackByCode(itemCode)
		 	local xhnum = cost2[1].amount --钻石消耗
		 	if num >=cost[1].amount then  --道具足够
		 		local params = {}
	 		    params.id = 46
		 		params.onSuccess = function (res )
		 			local data = {}
		 		    data.resultList = res.resultList
					data.resultList = TableUtil.randomSortArray(data.resultList)
		 		    
		 		    local temp = num - cost[1].amount
		 		    if num>=cost[1].amount then --道具还足够
		 		    	data.id = 46
		 		    	data.xhType = 1
		 		    	data.itemCode = itemCode
		 		    	data.cost = cost
		 		    else --道具不足
		 		    	data.id = 48
		 		    	data.xhType = 2
		 		    	data.itemCode = cost2[1].code
		 		    	data.cost = cost2
		 		    end
		 			ViewManager.open("GetSuccess2View",data)
		 		end
		 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
			 elseif PlayerModel:getMoneyByType(GameDef.MoneyType.Diamond)>=xhnum then --钻石消耗足够
				local info = {
					text=string.format(Desc.getCard_2,cost2[1].amount,10000,10,Desc.getCard_4),
					type="yes_no",
				}
				info.onYes = function()
					local params = {}
					params.id = 48
					params.onSuccess = function (res )
						local data = {}
						data.resultList = res.resultList
					   data.resultList = TableUtil.randomSortArray(data.resultList)
						data.itemCode = cost2[1].code
						data.id = 48
						data.xhType = 2
						data.cost = cost2
						ViewManager.open("GetSuccess2View",data)
					end
					RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
				end
				Alert.show(info);
		 	else
                ModelManager.PlayerModel:isCostEnough(cost, true)
			end
		end
	end,100)
    
    --爱心
    self.aixinBtn:removeClickListener(100)
	self.aixinBtn:addClickListener(function ( ... )
		-- ModuleUtil.openModule(ModuleId.AixinCards.id);
		ViewManager.open("GetAixinCardsView")
	end,100)

    self.btn_tygn:removeClickListener(100)
	self.btn_tygn:addClickListener(function( ... )
		-- ModuleUtil.openModule(ModuleId.GetSpeCards.id, true);
		ViewManager.open("GetSpeCardsView")
	end,100)
	self.btn_tyzh:removeClickListener(100)
	self.btn_tyzh:addClickListener(function()
		ModuleUtil.openModule(ModuleId.GetTyChange.id, true);
		
	end,100)
	self.btn_gl:removeClickListener(100)
    self.btn_gl:addClickListener(function()
		ViewManager.open("HelpSystemView",{page="HelpSysRecomView"})
	end,100)

	self.btn_vipShop:removeClickListener(100)
    self.btn_vipShop:addClickListener(function()
		ModuleUtil.openModule(ModuleId.NoBilityWeekGift.id)
	end,100)

    --特异 单次招募
	self.btn_tyzm:removeClickListener(100)
	self.btn_tyzm:addClickListener(function( ... )
		local index = self.tyList:getSelectedIndex()
		if index< 0 then
           RollTips.show(Desc.GetCard_Text11)
           return
		end
		local cost = DynamicConfigData.t_heroLottery[self.tykeyValArr[index+1]].cost
		if not ModelManager.PlayerModel:isCostEnough(cost, true) then
			return
		end
		local params = {}
		params.id = self.tykeyValArr[index+1]
 		params.onSuccess = function (res )
 		    --printTable(1,res)
			local data = {}
 		    data.resultList = res.resultList
 		    data.id = self.tykeyValArr[index+1]
 		    data.cost = DynamicConfigData.t_heroLottery[self.tykeyValArr[index+1]].cost
 		    self:updatePanel()
 			ViewManager.open("GetTYSuccessView",data)
 		end
 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
	end,100)
    --特异商城
	self.btn_tyshop:removeClickListener(100)
	self.btn_tyshop:addClickListener(function( ... )
		ModuleUtil.openModule( ModuleId.Shop.id , true,{shopType = 9} )
	end,100)
	
	self.btn_tylibao:removeClickListener(100)
	self.btn_tylibao:addClickListener(function( ... )
		ModuleUtil.openModule( ModuleId.PriviligeGiftView.id )
	end,100)

    self.tabArr = self:makeWindowTab()
	self.leftList:setNumItems(#self.tabArr)
	GetCardsModel:checkRedot( )
	RedManager.register("V_GETCARD_SPECIAL_1",self.btn_tygn:getChildAutoType("img_red"))
	self:initPanel()
end

function GetCardsView:initPanel( ... )
	--默认选中
    if self._args.page then
    	self.curPage = self._args.page
    	local index = self:getIndexByPageIndex(self.curPage)
    	if not index then
    		self.curPage = self.tabArr[2].page
    		self.leftList:setSelectedIndex(1)
    	else
    		self.leftList:setSelectedIndex(index-1)
    	end
    	
    else
    	self.curPage = self.tabArr[2].page
    	self.leftList:setSelectedIndex(1)
    end

    GetCardsModel:setSelectPage(self.curPage)
    self:setPageGB()
    self:updatePanel()
end

function GetCardsView:setPageGB(  )
	self:setBg("getcard_bg"..self.curPage..".jpg")
	if self.curPage == 7 then
		self.view:getChildAutoType("role1"):setURL("UI/GetCard/role5_1.png")
		self.view:getChildAutoType("role2"):setURL("UI/GetCard/role5_2.png")
	end
end

function GetCardsView:money_change(  )
	print(1,"1111111money_change")
	self:updatePanel()
	-- if self.curPage == 4 then
	-- 	local cost = DynamicConfigData.t_heroLottery[30].cost
	-- 	local cost2 = DynamicConfigData.t_heroLottery[31].cost
	-- 	local img_red_left = self.leftbtn:getChildAutoType("img_red")
	-- 	local img_red_right = self.rightbtn:getChildAutoType("img_red")
	-- 	if  ModelManager.PlayerModel:isCostEnough(cost, false) then
	-- 		img_red_left:setVisible(true)
	-- 	else
	-- 		img_red_left:setVisible(false)
	-- 	end

	-- 	if  ModelManager.PlayerModel:isCostEnough(cost2, false) then
	-- 		img_red_right:setVisible(true)
	-- 	else
	-- 		img_red_right:setVisible(false)
	-- 	end

	-- 	self.costItemObj1:setData(cost[1].type, cost[1].code, cost[1].amount, true, false, true)
	-- 	self:__setColorForCostItem(self.isSpecColor , self.costItemLeft, cost[1].type, cost[1].code, cost[1].amount)

	--  	self.costItemObj2:setData(cost2[1].type, cost2[1].code, cost2[1].amount, true, false, true)
	-- 	self:__setColorForCostItem(self.isSpecColor , self.costItemRight, cost2[1].type, cost2[1].code, cost2[1].amount)
		
	-- 	--更新当前拥有
	-- 	self.itemicon:setData(cost2[1].type, cost2[1].code)
	-- 	local hadItemNum = ModelManager.PlayerModel:getMoneyByType(cost2[1].code)
	-- 	self.itemnum:setText(hadItemNum)
	-- elseif self.curPage == 2 or self.curPage == 7 then
	-- 	local cost = DynamicConfigData.t_heroLottery[3].cost
	-- 	local cost2 = DynamicConfigData.t_heroLottery[4].cost
	-- 	if self.curPage == 2 then
	-- 		cost = DynamicConfigData.t_heroLottery[3].cost[1] --高抽单
	-- 		cost2 = DynamicConfigData.t_heroLottery[4].cost[1] --高抽10
	-- 	elseif self.curPage == 7 then
	-- 		cost = DynamicConfigData.t_heroLottery[47].cost
	-- 		cost2 = DynamicConfigData.t_heroLottery[48].cost
	-- 	end
	-- 	self.costItemObj1:setUseMoneyItem(true);
	-- 	self.costItemObj2:setUseMoneyItem(true);

	-- 	self.costItemObj1:setData(cost[1].type, cost[1].code, cost[1].amount, true, false, true)
	-- 	self:__setColorForCostItem(false, self.costItemLeft, cost[1].type, cost[1].code, cost[1].amount)
	-- 	self.costItemObj2:setData(cost2[1].type, cost2[1].code, cost2[1].amount, true, false, true)
	-- 	self:__setColorForCostItem(false, self.costItemRight, cost2[1].type, cost2[1].code, cost2[1].amount)
	-- end
end

--监听事件协议 更新界面
function GetCardsView:update_getCardsView( ... )
	print(1,"update_getCardsView")
	if  tolua.isnull(self.view) then
		return
	end
	self:updateAixin()
	self:updatePanel()
end

--监听协议 限制次数限制下发
function GetCardsView:update_cardListTime( ... )
	print(1,"update_cardListTime")
	if self.curPage == 2 then
		local txt = GetCardsModel:getGjLastTime()
	    self.lastTimeLab:setText(Desc.getCard_8..txt)
	elseif self.curPage == 5 then
		local txt = GetCardsModel:getNewPlayerLastCount()
		self.lastTimeLab:setText(Desc.getCard_9..txt)
	elseif self.curPage == 6 then
		local txt = GetCardsModel:getUpLastCount()
		self.lastTimeLab:setText(Desc.getCard_9..txt)
	elseif self.curPage == 7 then
		local txt = GetCardsModel:getAlienLandLastCount()
		self.lastTimeLab:setText(Desc.getCard_9..txt)
	end
end

--检测新手的限时剩余
function GetCardsView:checkNewPlayerTime( ... )
	local time = GetCardsModel:getNewPlayerTime()
	if time>0 then
		if self.calltimer then
			TimeLib.clearCountDown(self.calltimer)
		end
	    self.timeTxt:setText(TimeLib.GetTimeFormatDay(time,1))
	    local function onCountDown( time )
	    	if  tolua.isnull(self.timeTxt) then
	    		return
	    	end
	    	 self.timeTxt:setText(TimeLib.GetTimeFormatDay(time,1))
	    end
	    local function onEnd( ... )
	    	self.timeTxt:setText(Desc.common_txt1)
	    end
	    self.calltimer = TimeLib.newCountDown(time, onCountDown, onEnd, false, false,false)
	end
end

--检测UP的限时剩余
function GetCardsView:checkUpTime( ... )
	local time = GetCardsModel:getUpTime()
	if time>0 then
		if self.calltimer then
			TimeLib.clearCountDown(self.calltimer)
		end
	    self.timeTxt:setText(TimeLib.GetTimeFormatDay(time,1))
	    local function onCountDown( time )
	    	if  tolua.isnull(self.timeTxt) then
	    		return
	    	end
	    	self.timeTxt:setText(TimeLib.GetTimeFormatDay(time,1))
	    end
	    local function onEnd( ... )
	    	self.timeTxt:setText(Desc.common_txt1)
	    end
	    self.calltimer = TimeLib.newCountDown(time, onCountDown, onEnd, false, false,false)
	end
end

--更新爱心
function GetCardsView:updateAixin( ... )
	if self.curPage ==1 or self.curPage == 2 or self.curPage == 4 or self.curPage == 5 or self.curPage == 6  or self.curPage == 7 then
		if GetCardsModel:getLuckyValue() >= 1000 then
			self.view:getTransition("t0"):play(function( ... )
			end)
		else
			self.view:getTransition("t0"):stop()
		end
		self.progressBar:setValue(GetCardsModel:getLuckyValue())
		self.aixinNum:setText(GetCardsModel:getLuckyValue())
	end
end

function GetCardsView:update_yj_heroPage()
   self:updatePanel()
end

--监听礼包事件
function GetCardsView:PriviligeGift_upGiftData( ... )
	self.btn_tylibao:setVisible(not PriviligeGiftModel:getGiftStatusById(4))
end

--更新页面
function GetCardsView:updatePanel( ... )
	print(1," updatePanel self.curPage",self.curPage)
	if (self.curPage>=1 and self.curPage<=4) or self.curPage ==7  then
       self.btn_help:setVisible(true)
	else
		self.btn_help:setVisible(false)
	end
	if self.calltimer then
		TimeLib.clearCountDown(self.calltimer)
	end

	if self.curPage == 2 or self.curPage == 5 or self.curPage == 6 or self.curPage == 7  or self.curPage == 8 then
		self:update_cardListTime()
	end
	
	if self.curPage == 7 then
		self.btn_vipShop:setVisible(ActivityModel:getActityByModuleId( ModuleId.NoBilityWeekGift.id ) ~= nil)
		if not self.btn_vipShop.btn_vipShop and self.btn_vipShop:isVisible() then
			self.btn_vipShop.vipShopSpine =  SpineUtil.createSpineObj(self.btn_vipShop, vertex2(self.btn_vipShop:getWidth()/2,self.btn_vipShop:getHeight()/2), "animation", "Spine/ui/chouka2", "qianwangtishi_texiao", "qianwangtishi_texiao")
		end
	end
			
	--切换显示
	self.showconCtrl:setSelectedIndex(self.curPage-1)
	self.roleImg:setURL("UI/GetCard/role"..self.curPage..".png")
    self:updateAixin()

	local img_red_left = self.leftbtn:getChildAutoType("img_red")
	local img_red_right = self.rightbtn:getChildAutoType("img_red")
	-- local btn1control = self.leftbtn:getController("showctrl")
 --    btn1control:setSelectedIndex(2)
	--更新
	self.lastTime:setColor(ColorUtil.textColor.green)
	self.costItemObj1:setUseMoneyItem(true);
	self.costItemObj2:setUseMoneyItem(true);
	if self.curPage == 1 then 
		local cost = DynamicConfigData.t_heroLottery[1].cost[1]
		local cost2 = DynamicConfigData.t_heroLottery[2].cost[1]
	    local itemType = cost.type --道具消耗
	    local itemCode = cost.code --道具消耗
	 	local hadItemNum = PackModel:getItemsFromAllPackByCode(cost.code)	 
	 	local hadFreeNum = GetCardsModel:getFreeData( self.pageMapTypeVal[self.curPage])
	 	if hadFreeNum >=1 then
            -- btn1control:setSelectedIndex(0)
            self.timeShowCtrl:setSelectedIndex(0)
			img_red_left:setVisible(true)
			self.leftCtrl:setSelectedIndex(0)
	 	else
	 		self.leftCtrl:setSelectedIndex(1)
	 		self.timeShowCtrl:setSelectedIndex(1)
	 		-- btn1control:setSelectedIndex(1)
            self.costItemObj1:setData(cost.type, cost.code, cost.amount, true, false, true)
			self:__setColorForCostItem(false, self.costItemLeft, cost.type, cost.code, cost.amount)
            --如果道具足够
            if hadItemNum>=cost.amount then
				img_red_left:setVisible(true)
            else
				img_red_left:setVisible(false)
            end

            local time = ServerTimeModel:getTodayLastSeconds()
            self.lastTime:setText(TimeLib.formatTime(time)..Desc.getCard_lastTime)
            local function onCountDown( time )
            	self.lastTime:setText(time..Desc.getCard_lastTime)
            end
            local function onEnd( ... )
            	-- btn1control:setSelectedIndex(0)
            	self.timeShowCtrl:setSelectedIndex(0)
            	img_red_left:setVisible(true)
            end
            self.calltimer = TimeLib.newCountDown(time, onCountDown, onEnd, false, false)
	 	end
	 	
	 	self.costItemObj2:setData(cost2.type, cost2.code, cost2.amount, true, false, true)
		self:__setColorForCostItem(false, self.costItemRight, cost2.type, cost2.code, cost2.amount)
        if hadItemNum>=cost2.amount then --道具数量足够
			img_red_right:setVisible(true)
        else
			img_red_right:setVisible(false)
        end
	 	--当前拥有
	 	--local url = ItemConfiger.getItemIconByCode(itemCode)
	 	--self.itemicon:setURL(url)
		self.itemicon:setData(itemType, itemCode)
        self.itemnum:setText(hadItemNum)
	elseif self.curPage == 2 then
		local cost = DynamicConfigData.t_heroLottery[3].cost[1] --高抽单
		local cost2 = DynamicConfigData.t_heroLottery[4].cost[1] --高抽10
		local cost3 = DynamicConfigData.t_heroLottery[8].cost[1] --高抽单钻石
		local cost4 = DynamicConfigData.t_heroLottery[9].cost[1] --高抽10钻石

	    local itemType = DynamicConfigData.t_heroLottery[3].cost[1].type --高级道具消耗
	    local itemCode = DynamicConfigData.t_heroLottery[3].cost[1].code --高级道具消耗
	 	local hadFreeNum = GetCardsModel:getFreeData( self.pageMapTypeVal[self.curPage])
	 	local hadItemNum = PackModel:getItemsFromAllPackByCode(itemCode)
	 	if hadFreeNum>=1 then --有免费次数
            -- btn1control:setSelectedIndex(0)
            self.timeShowCtrl:setSelectedIndex(0)
            img_red_left:setVisible(true)
            self.leftCtrl:setSelectedIndex(0)
	 	else
	 		self.leftCtrl:setSelectedIndex(1)
	 		self.timeShowCtrl:setSelectedIndex(1)
	 		-- btn1control:setSelectedIndex(1)

			
	 		if hadItemNum>=cost.amount then --召唤券足够
				 self.costItemObj1:setData(cost.type, cost.code, cost.amount, true, false, true)
				 self:__setColorForCostItem(false, self.costItemLeft, cost.type, cost.code, cost.amount)
	 			img_red_left:setVisible(true)
	 		else
				 self.costItemObj1:setData(cost3.type, cost3.code, cost3.amount, true, false, true)
				 self:__setColorForCostItem(false, self.costItemLeft, cost3.type, cost3.code, cost3.amount)
	 			img_red_left:setVisible(false)
			 end
			 

	 		local time = ServerTimeModel:getTodayLastSeconds()
            self.lastTime:setText(TimeLib.formatTime(time)..Desc.getCard_lastTime)
			
			local function onCountDown( time )
			    if tolua.isnull(self.view) then  return end
            	self.lastTime:setText(time..Desc.getCard_lastTime)
            end

			local function onEnd( ... )
				if tolua.isnull(self.view) then  return end
            	-- btn1control:setSelectedIndex(0)
            	self.timeShowCtrl:setSelectedIndex(0)
            	img_red_left:setVisible(true)
            end
            self.calltimer = TimeLib.newCountDown(time, onCountDown, onEnd, false, false)
	 	end

        if hadItemNum>=cost2.amount then --道具数量足够
			img_red_right:setVisible(true)
        	self.costItemObj2:setData(cost2.type, cost2.code, cost2.amount, true, false, true)
			self:__setColorForCostItem(false, self.costItemRight, cost2.type, cost2.code, cost2.amount)
        else
        	img_red_right:setVisible(false)
        	--道具不足 检测钻石
    	    self.costItemObj2:setData(cost4.type, cost4.code, cost4.amount, true, false, true)
			self:__setColorForCostItem(false, self.costItemRight, cost4.type, cost4.code, cost4.amount)
        end
	 	--当前拥有
	 	--local url = ItemConfiger.getItemIconByCode(itemCode)	
	 	--self.itemicon:setURL(url)
		self.itemicon:setData(itemType, itemCode)
        self.itemnum:setText(hadItemNum)
	elseif self.curPage ==3 then --特异召唤更新
        --更新消耗
        local cost 
        if self.tyList:getSelectedIndex()<0 then
        	self.view:getController("page3CostCtrl"):setSelectedIndex(0)
        	 cost = DynamicConfigData.t_heroLottery[self.tykeyValArr[1]].cost[1]
        else
        	self.view:getController("page3CostCtrl"):setSelectedIndex(1)
        	local index = self.tyList:getSelectedIndex() + 1
	        local costitemObj = BindManager.bindCostItem(self.costItem)
	        cost = DynamicConfigData.t_heroLottery[self.tykeyValArr[index]].cost[1]
	        costitemObj:setData(cost.type, cost.code, cost.amount, true, false, true)
			self:__setColorForCostItem(true, self.costItem, cost.type, cost.code, cost.amount)
        end

        --当前拥有
	 	--local url = ItemConfiger.getItemIconByCode(cost.code)	
	 	local hadItemNum = PackModel:getItemsFromAllPackByCode(cost.code)
		self.itemicon:setData(cost.type, cost.code)
	 	--self.itemicon:setURL(url)
        self.itemnum:setText(hadItemNum)
		self.btn_tyzm:getChild("img_red"):setVisible(PlayerModel:isCostEnough({cost},false))
		self.btn_tylibao:setVisible(not PriviligeGiftModel:getGiftStatusById(4))
		
	elseif  self.curPage == 4 then
		self.costItemObj1:setUseMoneyItem(false);
		self.costItemObj2:setUseMoneyItem(false);
	 	self.leftCtrl:setSelectedIndex(1)
	 	self.timeShowCtrl:setSelectedIndex(0)
        local cost = DynamicConfigData.t_heroLottery[30].cost[1] --友情单
		local cost2 = DynamicConfigData.t_heroLottery[31].cost[1] --友情10
	    local itemCode = cost.code --道具消耗
	 	local hadItemNum = ModelManager.PlayerModel:getMoneyByType(itemCode)
 		-- btn1control:setSelectedIndex(1)
        self.costItemObj1:setData(cost.type, cost.code, cost.amount, true, false, true)
		self:__setColorForCostItem(false, self.costItemLeft, cost.type, cost.code, cost.amount)
        --如果道具足够
        if hadItemNum>=cost.amount then
			img_red_left:setVisible(true)
        else
			img_red_left:setVisible(false)
        end

	 	self.costItemObj2:setData(cost2.type, cost2.code, cost2.amount, true, false, true)
		self:__setColorForCostItem(false, self.costItemRight, cost2.type, cost2.code, cost2.amount)
        if hadItemNum>=cost2.amount then --道具数量足够
			img_red_right:setVisible(true)
        else
			img_red_right:setVisible(false)
        end
	 	--当前拥有
	 	--local url = ItemConfiger.getItemIconByCode(itemCode, cost.type, true)
	 	--self.itemicon:setURL(url)
		self.itemicon:setData(cost.type, cost.code)
        self.itemnum:setText(hadItemNum)

	elseif self.curPage ==5 or  self.curPage ==6 then  --新手 /up
		local idArr = {}
		if self.curPage == 5 then
			self:checkNewPlayerTime()
			idArr = {32,33,34,35}
		elseif self.curPage == 6 then
			self:checkUpTime()
			idArr = {41,42,43,44}
		end
		
		local cost = DynamicConfigData.t_heroLottery[idArr[1]].cost[1] --新手单
		local cost2 = DynamicConfigData.t_heroLottery[idArr[2]].cost[1] --新手10
		local cost3 = DynamicConfigData.t_heroLottery[idArr[3]].cost[1] --新手单钻石
		local cost4 = DynamicConfigData.t_heroLottery[idArr[4]].cost[1] --新手10钻石

	    local itemType = DynamicConfigData.t_heroLottery[idArr[1]].cost[1].type --高级道具消耗
	    local itemCode = DynamicConfigData.t_heroLottery[idArr[1]].cost[1].code --高级道具消耗
	 	local hadFreeNum = GetCardsModel:getFreeData( self.pageMapTypeVal[self.curPage])
	 	local hadItemNum = PackModel:getItemsFromAllPackByCode(itemCode)
	 	self.timeShowCtrl:setSelectedIndex(0)
	 	if hadFreeNum>=1 then --有免费次数
            img_red_left:setVisible(true)
            self.leftCtrl:setSelectedIndex(0)
	 	else
	 		self.leftCtrl:setSelectedIndex(1)
	 		if hadItemNum>=cost.amount then --召唤券足够
	 			self.costItemObj1:setData(cost.type, cost.code, cost.amount, true, false, false)
				self:__setColorForCostItem(false, self.costItemLeft, cost.type, cost.code, cost.amount)
	 			img_red_left:setVisible(true)
	 		else
	 			self.costItemObj1:setData(cost3.type, cost3.code, cost3.amount, true, false, false)
				self:__setColorForCostItem(false, self.costItemLeft, cost3.type, cost3.code, cost3.amount)
	 			img_red_left:setVisible(false)
	 		end
	 	end

        if hadItemNum>=cost2.amount then --道具数量足够
			img_red_right:setVisible(true)
        	self.costItemObj2:setData(cost2.type, cost2.code, cost2.amount, true, false, false)
			self:__setColorForCostItem(false, self.costItemRight, cost2.type, cost2.code, cost2.amount)
        else
        	img_red_right:setVisible(false)
        	--道具不足 检测钻石
    	    self.costItemObj2:setData(cost4.type, cost4.code, cost4.amount, true, false, false)
			self:__setColorForCostItem(false, self.costItemRight, cost4.type, cost4.code, cost4.amount)
        end
	 	--当前拥有
	 	--local url = ItemConfiger.getItemIconByCode(itemCode)	
	 	--self.itemicon:setURL(url)
		self.itemicon:setData(itemType, itemCode)
		self.itemnum:setText(hadItemNum)
	elseif self.curPage == 7 then --仙魔
		local cost = DynamicConfigData.t_heroLottery[45].cost[1] --仙魔单
		local cost2 = DynamicConfigData.t_heroLottery[46].cost[1] --仙魔10
		local cost3 = DynamicConfigData.t_heroLottery[47].cost[1] --仙魔单钻石
		local cost4 = DynamicConfigData.t_heroLottery[48].cost[1] --仙魔10钻石

	    local itemType = DynamicConfigData.t_heroLottery[45].cost[1].type --高级道具消耗
	    local itemCode = DynamicConfigData.t_heroLottery[45].cost[1].code --高级道具消耗
	 	local hadFreeNum = GetCardsModel:getFreeData( self.pageMapTypeVal[self.curPage])
		local hadItemNum = PackModel:getItemsFromAllPackByCode(itemCode)
		print(1,"hadFreeNum",hadFreeNum)
	 	if hadFreeNum>=1 then --有免费次数
            -- btn1control:setSelectedIndex(0)
            self.timeShowCtrl:setSelectedIndex(0)
            img_red_left:setVisible(true)
            self.leftCtrl:setSelectedIndex(0)
	 	else
	 		self.leftCtrl:setSelectedIndex(1)
	 		self.timeShowCtrl:setSelectedIndex(1)
	 		-- btn1control:setSelectedIndex(1)

	 		if hadItemNum>=cost.amount then --召唤券足够
				 self.costItemObj1:setData(cost.type, cost.code, cost.amount, true, false, true)
				 self:__setColorForCostItem(true, self.costItemLeft, cost.type, cost.code, cost.amount)
	 			img_red_left:setVisible(true)
	 		else
				 self.costItemObj1:setData(cost3.type, cost3.code, cost3.amount, true, false, true)
				 self:__setColorForCostItem(true, self.costItemLeft, cost3.type, cost3.code, cost3.amount)
	 			img_red_left:setVisible(false)
			 end

	 		local time = ServerTimeModel:getTodayLastSeconds()
            self.lastTime:setText(TimeLib.formatTime(time)..Desc.getCard_lastTime)
			self.lastTime:setColor(ColorUtil.textColor_Light.green)
			local function onCountDown( time )
			    if tolua.isnull(self.view) then  return end
            	self.lastTime:setText(time..Desc.getCard_lastTime)
            end

			local function onEnd( ... )
				if tolua.isnull(self.view) then  return end
            	-- control:setSelectedIndex(0)
            	self.timeShowCtrl:setSelectedIndex(0)
            	img_red_left:setVisible(true)
            end
            self.calltimer = TimeLib.newCountDown(time, onCountDown, onEnd, false, false)
	 	end

        if hadItemNum>=cost2.amount then --道具数量足够
			img_red_right:setVisible(true)
			self.costItemObj2:setData(cost2.type, cost2.code, cost2.amount, true, false, true)
			self:__setColorForCostItem(true, self.costItemRight, cost2.type, cost2.code, cost2.amount)
        else
        	img_red_right:setVisible(false)
        	--道具不足 检测钻石
			self.costItemObj2:setData(cost4.type, cost4.code, cost4.amount, true, false, true)
			self:__setColorForCostItem(true, self.costItemRight, cost4.type, cost4.code, cost4.amount)
		end
		
	 	--当前拥有
	 	--local url = ItemConfiger.getItemIconByCode(itemCode)	
	 	--self.itemicon:setURL(url)
		self.itemicon:setData(itemType, itemCode)
		self.itemnum:setText(hadItemNum)
	end

end

--initUI执行之前
function GetCardsView:_enter( ... )

end

--页面退出时执行
function GetCardsView:_exit( ... )
	print(1,"GetCardsView _exit")
	if self.timeId then
		Scheduler.unschedule(self.timeId)
		self.timeId = false
	end
	TimeLib.clearCountDown(self.calltimer)
end

-------------------常用------------------------

return GetCardsView