-- added by xhd
-- 精灵主题活动  一番巡礼

local TimeLib = require "Game.Utils.TimeLib"
local TimeUtil = require "Game.Utils.TimeUtil"
local ActATourGiftView = class("ActATourGiftView",Window)
local lastInterTime = 0.02
local maxInterTime = 0.5
function ActATourGiftView:ctor()
	self._packName 	= "ActATourGift"
	self._compName 	= "ActATourGiftView"

	self.__timerId = false
	self.config = false
	self.serverData = false
	self.lastConfig = false
	self.lastConfig2 = false
	self.aniFlag = ActATourGiftModel:getAniFlag()
	self.actType = GameDef.ActivityType.ElfHis
	self.__aniTimerId = false
	self.timeCount = 0
	self.scheduler = {}
	self.scheduler2 = {}
	self.firstFlag = true
	self.aniFlagArr = {false,false}
end

function ActATourGiftView:updateItemCount(  )
	local config =ActATourGiftModel:getOneDrawConfig(1)
	local cost = config.costItem
	local url = ItemConfiger.getItemIconByCode(cost[1].code)
	local hadItemNum = PackModel:getItemsFromAllPackByCode(cost[1].code)
	self.itemicon:setURL(url)
	self.itemnum:setText(hadItemNum)
end

--刷新
function ActATourGiftView:_refresh( ... )
	self.aniFlagArr[1] = false
	self.aniFlagArr[2] = false
end

function ActATourGiftView:_initUI()
    --已经存在大奖选择器
	self.hadSelCtrl = self.view:getController("hadSelCtrl")
	self.hadGetCtrl = self.view:getController("hadGetCtrl")

	self.txt_countTimer = self.view:getChildAutoType("txt_countTimer")
	self.btn_rule  = self.view:getChildAutoType("btn_rule")	
	self.awardList = self.view:getChildAutoType("awardPanel/awardList")
	self.updateBtn = self.view:getChildAutoType("updateBtn")
	self.btn_dan = self.view:getChildAutoType("btn_dan")
	self.btn_shi = self.view:getChildAutoType("btn_shi")
	self.costItem_dan = self.btn_dan:getChildAutoType("costItem")
	self.costItem_shi = self.btn_shi:getChildAutoType("costItem")

	self.costItemObj1 = BindManager.bindCostItem(self.costItem_dan)
	self.costItemObj2 = BindManager.bindCostItem(self.costItem_shi)
	self.costItemObj1:setUseMoneyItem(true);
	self.costItemObj2:setUseMoneyItem(true);

	self.checkBox = self.view:getChildAutoType("checkBox")
	self.itemCell = self.view:getChildAutoType("itemCell")
	self.itemcellObj = BindManager.bindItemCell(self.itemCell)
	self.jiaBtn = self.view:getChildAutoType("jiaBtn")
	self.changeBtn = self.view:getChildAutoType("changeBtn")
	self.itemicon = self.view:getChildAutoType("itemicon")
	self.itemnum = self.view:getChildAutoType("itemnum")
	self.btn_help2 = self.view:getChildAutoType("btn_help2")
	self.awardList2 = self.view:getChildAutoType("awardPanel/awardList2")
	self.awardList3 = self.view:getChildAutoType("awardPanel/awardList3")
	self.awardList4 = self.view:getChildAutoType("awardPanel/awardList4")
	
	self.mubu_1 = self.view:getChildAutoType("mubu_1")
	self.mubu_2 = self.view:getChildAutoType("mubu_2")
	self.btn_add = self.view:getChildAutoType("btn_add")
	self.btn_add2 = self.view:getChildAutoType("btn_add2")
	self.numLab  = self.view:getChildAutoType("numLab")
	
    --跳转来源
	self.btn_add:addClickListener(function( ... )
		local config =ActATourGiftModel:getOneDrawConfig(1)
		local cost = config.costItem
		local itemInfo = ItemConfiger.getInfoByCode(cost[1].code)
		-- ViewManager.open("ItemNotEnoughView", {type = itemInfo.type, code = itemInfo.code, amount = 1})
		local itemData = ItemsUtil.createItemData({data = {type = itemInfo.type, code = itemInfo.code, amount = 1}})
		ViewManager.open("ItemTips", {codeType = itemInfo.type, id = itemInfo.code, data = itemData})
	end)

	self.btn_add2:addClickListener(function( ... )
		local config =ActATourGiftModel:getOneDrawConfig(1)
		local cost = config.costItem
		local itemInfo = ItemConfiger.getInfoByCode(cost[1].code)
		-- ViewManager.open("ItemNotEnoughView", {type = itemInfo.type, code = itemInfo.code, amount = 1})
		local itemData = ItemsUtil.createItemData({data = {type = itemInfo.type, code = itemInfo.code, amount = 1}})
		ViewManager.open("ItemTips", {codeType = itemInfo.type, id = itemInfo.code, data = itemData})
	end)

-- self.awardList:setVirtualAndLoop()
self.awardList:setVirtual()
self.awardList:setItemRenderer(function(idx,obj)
	local reward 	= self.lastConfig[idx+1]
	local itemCell  = obj:getChildAutoType("itemCell")
	local itemCellObj 	= BindManager.bindItemCell(itemCell)
	itemCellObj:setData(reward.code, reward.amount, reward.type)
	local interTime = maxInterTime/#self.lastConfig
	if interTime >= lastInterTime then
		interTime = lastInterTime
	end

	if not self.aniFlagArr[1] then
		obj:setVisible(false)
		self.scheduler[idx+1] = Scheduler.scheduleOnce((idx+1)*interTime, function( ... )
			if obj and  (not tolua.isnull(obj)) then
				obj:setVisible(true)
				obj:getTransition("t0"):play(function( ... )
				end);
			end
		end)
	end
end)

-- self.awardList2:setVirtualAndLoop()
self.awardList2:setVirtual()
self.awardList2:setItemRenderer(function(idx,obj)
	local reward 	= self.lastConfig2[idx+1]
	local itemCell  = obj:getChildAutoType("itemCell")
	local itemCellObj 	= BindManager.bindItemCell(itemCell)
	itemCellObj:setData(reward.code, reward.amount, reward.type)
	local interTime = maxInterTime/#self.lastConfig2
	if interTime >= lastInterTime then
		interTime = lastInterTime
	end

	if not self.aniFlagArr[2] then
		obj:setVisible(false)
		self.scheduler2[idx+1] = Scheduler.scheduleOnce((idx+1)*interTime, function( ... )
			if obj and  (not tolua.isnull(obj)) then
				obj:setVisible(true)
				obj:getTransition("t0"):play(function( ... )
				end);
			end
		end)
	end

end)

self.awardList:addEventListener(FUIEventType.Scroll,function ( ... )
	self.aniFlagArr[1] = true
end)
self.awardList2:addEventListener(FUIEventType.Scroll,function ( ... )
	self.aniFlagArr[2] = true
end)

-- self.awardList3:setVirtual()
-- self.awardList3:setItemRenderer(function(idx,obj)
-- 	local reward 	= self.lastConfig[idx+1]
-- 	local itemCell  = obj:getChildAutoType("itemCell")
-- 	local itemCellObj 	= BindManager.bindItemCell(itemCell)
-- 	itemCellObj:setData(reward.code, reward.amount, reward.type)
-- 	local interTime = maxInterTime/#self.lastConfig
-- 	if interTime >= lastInterTime then
-- 		interTime = lastInterTime
-- 	end
-- 	obj:setVisible(false)
-- 	self.scheduler[idx+1] = Scheduler.scheduleOnce((idx+1)*interTime, function( ... )
-- 		if obj and  (not tolua.isnull(obj)) then
-- 			obj:setVisible(true)
-- 			obj:getTransition("t0"):play(function( ... )
-- 			end);
-- 		end
-- 	end)
-- end)

-- self.awardList4:setVirtual()
-- self.awardList4:setItemRenderer(function(idx,obj)
-- 	local reward 	= self.lastConfig2[idx+1]
-- 	local itemCell  = obj:getChildAutoType("itemCell")
-- 	local itemCellObj 	= BindManager.bindItemCell(itemCell)
-- 	itemCellObj:setData(reward.code, reward.amount, reward.type)
-- 	local interTime = maxInterTime/#self.lastConfig2
-- 	if interTime >= lastInterTime then
-- 		interTime = lastInterTime
-- 	end
-- 	obj:setVisible(false)
-- 	self.scheduler2[idx+1] = Scheduler.scheduleOnce((idx+1)*interTime, function( ... )
-- 		if obj and  (not tolua.isnull(obj)) then
-- 			obj:setVisible(true)
-- 			obj:getTransition("t0"):play(function( ... )
-- 			end);
-- 		end
-- 	end)
-- end)


	--问号
	self.btn_rule:addClickListener(function( ... )
		local info={}
		info['title']=Desc["help_StrTitle187"]
		info['desc']=Desc["help_StrDesc187"]
		ViewManager.open("GetPublicHelpView",info) 
	end)
	
	--叹号
	self.btn_help2:addClickListener(function( ... )
		local txt =  ActATourGiftModel:getElfOneShowText()
		local info={}
		info['title']=Desc["help187RateTitle"]
		info['desc']= txt
		ViewManager.open("GetPublicHelpView",info) 
	end)
	
	--刷新剩余奖励
	self.updateBtn:addClickListener(function( ... )
		local params = {}
		params.activityId = ActATourGiftModel:getActivityId( )
		params.onSuccess = function (res )
		end
		RPCReq.Activity_ElfHis_Rest(params, params.onSuccess)
	end)
	
	--单抽
	self.btn_dan:addClickListener(function( ... )
		local func = function()
			--缓存大奖code
		    ActATourGiftModel:setTourTempCode()
			-- body
			local params = {}
			params.activityId = ActATourGiftModel:getActivityId( )
			params.num = 1
			params.onSuccess = function (res )
			end
			RPCReq.Activity_ElfHis_Luckydraw(params, params.onSuccess)
		end
		self:playAni(1,func)
	end)
	
	--十连
	self.btn_shi:addClickListener(function( ... )
		local func = function()
			--缓存大奖code
		    ActATourGiftModel:setTourTempCode()
			-- body
			local params = {}
			params.activityId = ActATourGiftModel:getActivityId( )
			params.num = 10
			params.onSuccess = function (res )
				
			end
			RPCReq.Activity_ElfHis_Luckydraw(params, params.onSuccess)
		end
		self:playAni(10,func)
	end)
	
	--跳过动画
	self.checkBox:addClickListener(function( ... )
		-- body
		self.aniFlag = not self.aniFlag
		ActATourGiftModel:setAniFlag(self.aniFlag )
	end)
	
	--加号
	self.jiaBtn:addClickListener(function( ... )
		-- body
		ViewManager.open("WishingWellView")
	end)
	
	--更换
	self.changeBtn:addClickListener(function( ... )
		-- body
		ViewManager.open("WishingWellView")
	end)
	
	-- RedManager.register("V_ACTIVITY_"..self.actType.."_hadFlag",self.changeBtn:getChildAutoType("img_red"));  
	-- RedManager.register("V_ACTIVITY_"..self.actType.."_hadFlag",self.jiaBtn:getChildAutoType("img_red"));  
	-- RedManager.register("V_ACTIVITY_"..self.actType.."_dan",self.btn_dan:getChildAutoType("img_red"));  
	RedManager.register("V_ACTIVITY_"..self.actType.."_shi",self.btn_shi:getChildAutoType("img_red"));  
end

function ActATourGiftView:_initEvent( ... )
	self:ActATourGiftView_refresh()
end

function ActATourGiftView:_refresh( ... )
	self:ActATourGiftView_refresh()
end


--播放动画
function ActATourGiftView:playAni( costNum,callfunc )
	
	local config =ActATourGiftModel:getOneDrawConfig(1)
	local cost = config.costItem
	local itemInfo = ItemConfiger.getInfoByCode(cost[1].code)
	local hadItemNum = PackModel:getItemsFromAllPackByCode(cost[1].code)
	if hadItemNum<costNum then
		RollTips.show(itemInfo.name..Desc.Act_tourText1)
		return
	end

	local func = function( ... )
		if self.aniFlag then
			callfunc()
			return
		end
		self.timeCount = 0
		self.view:getController("showAni"):setSelectedIndex(1)	
		self.mubu_1:setFillAmount(0.2)
		self.mubu_2:setFillAmount(0.2)
		
		local kaiFunc = function()
			if self.__aniTimerId then
				Scheduler.unschedule(self.__aniTimerId)
				self.__aniTimerId = false
			end
			self.__aniTimerId=Scheduler.schedule(function(time)
				self.timeCount=self.timeCount + time*2
				if self.timeCount>=1 then
					if tolua.isnull(self.view) then
						return
					end
					self.mubu_1:setFillAmount(1)
					self.mubu_2:setFillAmount(1)
					self.view:getController("showAni"):setSelectedIndex(0) 
					if callfunc then
						callfunc()
					end
					self.timeCount = 0
					if self.__aniTimerId then
						Scheduler.unschedule(self.__aniTimerId)
						self.__aniTimerId = false
					end
				else
					print(1,self.timeCount)
					self.mubu_1:setFillAmount(1-self.timeCount)
					self.mubu_2:setFillAmount(1-self.timeCount)
				end
			end,0.01)
		end

		local guanFunc = function()
			if self.__aniTimerId then
				Scheduler.unschedule(self.__aniTimerId)
				self.__aniTimerId = false
			end
			self.__aniTimerId=Scheduler.schedule(function(time)
				self.timeCount=self.timeCount + time*2
				if self.timeCount>=0.8 then
					if tolua.isnull(self.view) then
						return
					end
					self.mubu_1:setFillAmount(1)
					self.mubu_2:setFillAmount(1)
					self.timeCount = 0
					if self.__aniTimerId then
						Scheduler.unschedule(self.__aniTimerId)
						self.__aniTimerId = false
					end
	                kaiFunc()
				else
					self.mubu_1:setFillAmount(0.2+self.timeCount)
					self.mubu_2:setFillAmount(0.2+self.timeCount)
				end
			end,0.01)
		end

		guanFunc()
	
	end
	if not (self.serverData.wish and self.serverData.wish>0) then
		local info = {}
		info.text = Desc.ActTourGiftDes1
		info.type = "yes_no"
		info.onYes = func
		Alert.show(info);
	else
		func()
	end
end

function ActATourGiftView:ActATourGiftView_refresh( ... )
	self:updatePanel()
	self:updateActTimeShow()
end

function ActATourGiftView:packItem_change(_,params)
	local config =ActATourGiftModel:getOneDrawConfig(1)
	local code = config.costItem[1].code
	if params == code then
		self:updateItemCount()
	end
end

--不走红点组织的红点显示
function ActATourGiftView:ATourRed_panelCheck(_,param)
   if param[1] == 1 then
		self.jiaBtn:getChildAutoType("img_red"):setVisible(param[2])
		-- self.changeBtn:getChildAutoType("jiaBtn"):setVisible(param[2])
   end
   if param[1] == 2 then
	self.btn_dan:getChildAutoType("img_red"):setVisible(param[2])
end 
end

function ActATourGiftView:updatePanel()
	self.serverData = ActATourGiftModel:getData( )
	self:updateItemCount()

	self.checkBox:setSelected(self.aniFlag)
	--存在许愿道具
	if self.serverData.wish and self.serverData.wish>0 then
		self.hadSelCtrl:setSelectedIndex(1)
			--选中的大奖
		self.itemcellObj:setIsBig(true)
		self.itemcellObj:setAmountVisible(false)
		local itemData = ActATourGiftModel:getCodeById(self.serverData.wish)
		self.itemcellObj:setData(itemData.code, itemData.amount, itemData.type)
	else
		self.hadSelCtrl:setSelectedIndex(0)
		self.jiaBtn:getChildAutoType("img_red"):setVisible(false)
		local config = ActATourGiftModel:getOneChooseConfig(  )
		for i=1,#config do
			local hadNum = ActATourGiftModel:getLimitbyCode( config[i].id )
			local limit = config[i].limit
			if hadNum<limit then
				self.jiaBtn:getChildAutoType("img_red"):setVisible(true)
				break
			end
		end
		
	end


	--抽中
	if self.serverData.has then
		self.hadGetCtrl:setSelectedIndex(1)
	else
		self.hadGetCtrl:setSelectedIndex(0)
	end

	--剩余奖励
	self.lastConfig,self.lastConfig2 = ActATourGiftModel:getLastAwardShow(  )
	-- if #self.lastConfig>=7 then
	-- 	self.awardList:setVisible(true)
	-- 	self.awardList3:setVisible(false)
		self.awardList:setData(self.lastConfig)
	-- else
	-- 	self.awardList:setVisible(false)
	-- 	self.awardList3:setVisible(true)
	-- 	self.awardList3:setData(self.lastConfig)
	-- end
	
	-- if #self.lastConfig2>=7 then
	-- 	self.awardList2:setVisible(true)
	-- 	self.awardList4:setVisible(false)
		self.awardList2:setData(self.lastConfig2)
	-- else
	-- 	self.awardList2:setVisible(false)
	-- 	self.awardList4:setVisible(true)
	-- 	self.awardList4:setData(self.lastConfig2)
	-- end

	-- print(1,#self.lastConfig)
	-- print(1,#self.lastConfig2)
	-- print(1,#self.lastConfig)
	-- print(1,#self.lastConfig2)
	self.numLab:setVar("num",tostring(#self.lastConfig+#self.lastConfig2))
	self.numLab:flushVars()
	--单抽的消耗
	local config  = ActATourGiftModel:getOneDrawConfig(1)
	local cost = config.costItem[1]
	self.costItemObj1:setData(cost.type, cost.code, cost.amount, true, false, true,1)
	self:__setColorForCostItem(true, self.costItem_dan, cost.type, cost.code, cost.amount)
	
	local hadItemNum = PackModel:getItemsFromAllPackByCode(cost.code)
	if hadItemNum >=1 then
		self.btn_dan:getChildAutoType("img_red"):setVisible(true)
	else
		self.btn_dan:getChildAutoType("img_red"):setVisible(false)
	end

	--十连的消耗
	local config2  = ActATourGiftModel:getOneDrawConfig(10)
	local cost2 = config2.costItem[1]
	self.costItemObj2:setData(cost2.type, cost2.code, cost2.amount, true, false, true,1)
	self:__setColorForCostItem(true, self.costItem_shi, cost2.type, cost2.code, cost2.amount)
end

function ActATourGiftView:pack_item_change(_,data)
	local config2  = ActATourGiftModel:getOneDrawConfig(10)
	local cost2 = config2.costItem[1]
	if data[1].itemCode ==  cost2.code then
			--单抽的消耗
		local config  = ActATourGiftModel:getOneDrawConfig(1)
		local cost = config.costItem[1]
		-- self.costItemObj1:setData(cost.type, cost.code, cost.amount, true, false, true,1)
		self:__setColorForCostItem(true, self.costItem_dan, cost.type, cost.code, cost.amount)
		
		--十连的消耗
		local config2  = ActATourGiftModel:getOneDrawConfig(10)
		local cost2 = config2.costItem[1]
		-- self.costItemObj2:setData(cost2.type, cost2.code, cost2.amount, true, false, true,1)
		self:__setColorForCostItem(true, self.costItem_shi, cost2.type, cost2.code, cost2.amount)
	end
end

--更新活动时间
function ActATourGiftView:updateActTimeShow( ... )
	if self.__timerId then
		TimeLib.clearCountDown(self.__timerId)
	end
    local actid = ActATourGiftModel:getActivityId( )
	local status,timems = ActivityModel:getActStatusAndLastTime( actid)
	if status == 2 and timems == -1 then
		self.txt_countTimer:setText(Desc.activity_txt5)
		return
	end
	if status ==0 then
		self.txt_countTimer:setText(Desc.activity_txt13)
		return
	end

	if timems==0 then
		self.txt_countTimer:setText(Desc.activity_txt13)
		return
	end
	timems = timems/1000
	
	local function updateCountdownView(time)
		if time > 0 then
			local timeStr = TimeLib.GetTimeFormatDay(time,2)
			self.txt_countTimer:setText(timeStr)
		else
			self.txt_countTimer:setText(Desc.activity_txt18)
		end
	end
	updateCountdownView(timems)
	self.__timerId = TimeLib.newCountDown(timems, function(time)
		updateCountdownView(time)
	end, function()
		self.txt_countTimer:setText(Desc.activity_txt4) -- TODO
	end, false, false, false)
end

function ActATourGiftView:_exit()
	if self.__timerId then
		TimeLib.clearCountDown(self.__timerId)
	end
	if self.__aniTimerId then
		Scheduler.unschedule(self.__aniTimerId)
		self.__aniTimerId = false
	end
	for i,v in ipairs(self.scheduler) do
		if self.scheduler[i] then
			Scheduler.unschedule(self.scheduler[i])
	        self.scheduler[i] = false
		end
	end
	for i,v in ipairs(self.scheduler2) do
		if self.scheduler2[i] then
			Scheduler.unschedule(self.scheduler2[i])
	        self.scheduler2[i] = false
		end
	end
end

function ActATourGiftView:__setColorForCostItem(specific, costItem, type, code, amount)
	local hasNum = 0
	if type == CodeType.ITEM then
		hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(code)
	elseif type == CodeType.MONEY then
		hasNum = ModelManager.PlayerModel:getMoneyByType(code)
	end
	local colorController = costItem:getController("color")
	costItem:getChildAutoType("txt_num"):setText("x"..amount)
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

return ActATourGiftView