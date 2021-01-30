--Date :2020-12-24
--Author : generated by FairyGUI
--Desc : 

local FullsrGiftView,Super = class("FullsrGiftView", Window)

function FullsrGiftView:ctor()
	--LuaLog("FullsrGiftView ctor")
	self._packName = "FullsrGift"
	self._compName = "FullsrGiftView"
	self._rootDepth = LayerDepth.PopWindow
	self.giftId=1
	self.giftData=0
	
	self.moduleId=1
	--self._args.moduleId
end

function FullsrGiftView:_initEvent( )
	
end

function FullsrGiftView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:FullsrGift.FullsrGiftView
	self.txt_countTimer = viewNode:getChildAutoType('$txt_countTimer')--GTextField
	self.bgLoader = viewNode:getChildAutoType('bgLoader')--GLoader
	self.blacmask = viewNode:getChildAutoType('blacmask')--GLabel
	self.bottomBoard = viewNode:getChildAutoType('bottomBoard')--GLoader
	self.box1 = viewNode:getChildAutoType('box1')--GLoader
	self.box2 = viewNode:getChildAutoType('box2')--GLoader
	self.btn_buy = viewNode:getChildAutoType('btn_buy')--GButton
	self.btn_help = viewNode:getChildAutoType('btn_help')--GButton
	self.buyFont = viewNode:getChildAutoType('buyFont')--GLoader
	self.buyProgress = viewNode:getChildAutoType('buyProgress')--GTextField
	self.c1 = viewNode:getController('c1')--Controller
	self.closeButton = viewNode:getChildAutoType('closeButton')--GButton
	self.commonList = viewNode:getChildAutoType('commonList')--GList
	self.giftBuyList = viewNode:getChildAutoType('giftBuyList')--GList
	self.itemCircle = viewNode:getChildAutoType('itemCircle')--GLoader
	self.itemFrame1 = viewNode:getChildAutoType('itemFrame1')--GLoader
	self.itemFrane2 = viewNode:getChildAutoType('itemFrane2')--GLoader
	self.leftTree = viewNode:getChildAutoType('leftTree')--GLoader
	self.list_sortType = viewNode:getChildAutoType('list_sortType')--GList
	self.luxuryList = viewNode:getChildAutoType('luxuryList')--GList
	self.module = viewNode:getController('module')--Controller
	self.preViewComp = viewNode:getChildAutoType('preViewComp')--preViewComp
		self.preViewComp.preFrame = viewNode:getChildAutoType('preViewComp/preFrame')--GImage
		self.preViewComp.preViewList = viewNode:getChildAutoType('preViewComp/preViewList')--GList
	self.progressBar = viewNode:getChildAutoType('progressBar')--G1ProgressBar4
		self.progressBar.icon = viewNode:getChildAutoType('progressBar/icon')--GLoader
	self.rect = viewNode:getChildAutoType('rect')--GGroup
	self.scoreRewardList = viewNode:getChildAutoType('scoreRewardList')--GList
	self.titleFont = viewNode:getChildAutoType('titleFont')--GLoader
	self.titleflow = viewNode:getChildAutoType('titleflow')--GLoader
	self.type128 = viewNode:getChildAutoType('type128')--GGroup
	self.type129 = viewNode:getChildAutoType('type129')--GGroup
	--{autoFieldsEnd}:FullsrGift.FullsrGiftView
	--Do not modify above code-------------
end

function FullsrGiftView:_initListener( )
	
	self.list_sortType:setSelectedIndex(0)
	self.list_sortType:regUnscrollItemClick(function (i)
			self.giftId=i+1
			self:setActiveData()
	end)
	
	for i=0,self.list_sortType:getNumItems()-1 do
		local giftDatas=FullsrGiftModel:getFullsrGiftDataCfg()
		--printTable(5656,giftDatas,"giftDatas")
		local giftId=i+1
		local giftData=giftDatas[giftId]
		local pageItem=self.list_sortType:getChildAt(i)
		pageItem:getController("module"):setSelectedPage("module"..self.moduleId)
		if giftData then		
			pageItem:getChildAutoType("title_module"..self.moduleId):setText(giftData.price..DescAuto[118])
		end
		RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.ServerGroupBuy.."_"..giftId, pageItem:getChild("img_red"))
		
	end
	
	self.btn_buy:addClickListener(function()
			local giftData=self.giftData
			ModelManager.RechargeModel:directBuy(giftData.price, GameDef.StatFuncType.SFT_ServerGroupBuy,self.giftId, giftData.name,nil, giftData.showName1)
	end)
	self.btn_help:removeClickListener()
	self.btn_help:addClickListener(function()
			RollTips.showHelp(Desc.help_StrTitle235, Desc.help_StrDesc235)
	end,111)
	self.view:addClickListener(function ()
			self.preViewComp:setVisible(false)
	end)



end

function FullsrGiftView:_initUI( )
	self:_initVM()
	
	self.moduleId=FullsrGiftModel:getModuleId()
	self.module:setSelectedPage("module"..self.moduleId)
	
	self:_initListener()
	self:setActiveData()
	FullsrGiftModel:setActvieOpen(true)
	FullsrGiftModel:updateRed()
end


function FullsrGiftView:setActiveData()


	local giftDatas=FullsrGiftModel:getFullsrGiftDataCfg()
	--printTable(5656,giftDatas,"giftDatas")
	local giftData=giftDatas[self.giftId]
	
	self.giftData=giftData
	if not self.giftData then
		return
	end
	
	
	local rewards=giftData.rewards
	local giftBuyCount=0
	for i = 0, #rewards-1 do
		if i%2==0 then
			giftBuyCount=giftBuyCount+1
		end
	end

	local leftCount=#rewards
	printTable(5656,rewards,"rewards")
	local newIndex=0
	self.giftBuyList:setItemRenderer(function(index, obj)
			local rewardList=obj:getChildAutoType("rewardList")
			rewardList:setItemRenderer(function (index2,rewardObj)
					newIndex=newIndex+1
					local itemCell=BindManager.bindItemCell(rewardObj)
					local itemData = ItemsUtil.createItemData({data = rewards[newIndex]})
					--printTable(5656,rewards[index2+1],"rewards[index2+1]",".....")
					itemCell:setItemData(itemData)
					itemCell:setIsHook(giftData.hasBuy)
			end)

			if leftCount>2 then
				rewardList:setNumItems(2)
				leftCount=leftCount-2
			else
				rewardList:setNumItems(leftCount)
			end
		end)

	self.giftBuyList:setNumItems(giftBuyCount)
	
	local timesToFreeRewardId=giftData.timesToFreeRewardId
	local timesToPayRewardId=giftData.timesToPayRewardId
	
	if giftData.hasBuy then
		self.btn_buy:setTitle(Desc.GroupBuyGiftView_str108)
	else
		self.btn_buy:setTitle(string.format(Desc.WeekCard_price,giftData.price))
	end
	self.btn_buy:setTouchable(not giftData.hasBuy)
	self.buyProgress:setText(giftData.progress or 0)
	
	
	local rMax=timesToFreeRewardId[#timesToFreeRewardId].count

	--local fmax=8
	giftData.progress=giftData.progress or 0
	self.progressBar:setMax(rMax)
	self.progressBar:getController("module"):setSelectedPage(self.moduleId)
	local proCount=0
	local lengthCount=0
	
	local perLeng={}
	local perInex=0
	for k, v in pairs(timesToFreeRewardId) do
		if giftData.progress>=v.count then
			proCount=k
		end
		perInex=k
		perLeng[perInex]=v.count-lengthCount
		lengthCount=v.count
	end
	printTable(5656,perLeng,"perLeng",proCount,giftData.progress)
	local fProgress=0
	
	if proCount>0 and proCount<#timesToFreeRewardId then
		 local test=(giftData.progress-timesToFreeRewardId[proCount].count)/perLeng[proCount+1]*rMax*0.27
		 fProgress=(0.27*(proCount-1)+0.18)*rMax+test
	else
		 fProgress=giftData.progress
	end

   print(5656,fProgress)
	self.progressBar:setValue(fProgress or 0)
	self.scoreRewardList:setItemRenderer(function(index, obj)
			obj:setTitle(timesToFreeRewardId[index+1].count)
			
		    if giftData.freeState[index+1]~=0 then
				obj:getController("pro"):setSelectedPage("open")
			else
				obj:getController("pro"):setSelectedPage("close")
			end
			
	end)
	self.scoreRewardList:setNumItems(#timesToFreeRewardId)


	

	local function showPreReward(obj,rewardInfo)
		self.preViewComp:setVisible(true)
		self.preViewComp.preViewList:setItemRenderer(function (index,obj)
				local itemcellA = BindManager.bindItemCell(obj)
				local itemDataA = ItemsUtil.createItemData({data = rewardInfo[index+1]})
				itemcellA:setItemData(itemDataA)
			end)
		local clickPos=self.view:globalToLocal(obj:getParent():localToGlobal(obj:getPosition()))
		clickPos.x=clickPos.x+50
		clickPos.y=clickPos.y+100
		--print(086,clickPos.x)
		--local rewardLength=#rewardInfo*100
		--if clickPos.x>1280-(rewardLength+20)/2 then
			--clickPos.x=1280-(rewardLength+20)/2
		--end
		local rewardCount=#rewardInfo
		self.preViewComp:setWidth(100*rewardCount+(rewardCount-1)*20)
		--self.preViewComp.preFrame:setWidth(107*#rewardInfo)
		self.preViewComp:setPosition(clickPos.x,clickPos.y)
		self.preViewComp.preViewList:setData(rewardInfo)
	end
	
	self.commonList:setItemRenderer(function(index, obj)
			
            local itemCell=BindManager.bindItemCell(obj)			
		    local reward =DynamicConfigData.t_reward[timesToFreeRewardId[index+1].dropId];
		    if reward then
				local itemData = ItemsUtil.createItemData({data = reward.item1[1]})
				itemCell:setItemData(itemData)
			end
			itemCell:setClickable(false)
			
			itemCell:setReceiveFrame(giftData.freeState[index+1]==1)
			obj:getChildAutoType("img_red"):setVisible(giftData.freeState[index+1]==1)
			--if giftData.freeState[index+1]==1 then
	
			--end
			itemCell:setIsHook(giftData.freeState[index+1]==2)
			local params = {
				giftId		= self.giftId,  -- 1:integer #要领取的奖励对应的配置id
				rewardType  = 1, -- 2:integer #1：免费奖励 2：付费奖励
				progress    = timesToFreeRewardId[index+1].count,-- 3:boolean #领取是哪个进度的奖励
			}
			
			obj:addClickListener(function (context)	
					context:stopPropagation()--阻止事件冒泡	
					if giftData.freeState[index+1]==1 then
						FullsrGiftModel:serverGroupBuy(params)
					else
						showPreReward(obj,reward.item1)
					end
			end,26)
			
	end)
	
	self.commonList:setNumItems(#timesToFreeRewardId)

	self.luxuryList:setItemRenderer(function(index, obj)		
			local itemCell=BindManager.bindItemCell(obj)
			local reward =DynamicConfigData.t_reward[timesToPayRewardId[index+1].dropId];
			--printTable(5656,reward.item1,timesToPayRewardId[index+1].dropId)
			if reward then
				local itemData = ItemsUtil.createItemData({data = reward.item1[1]})
				itemCell:setItemData(itemData)
				--itemCell:setData(reward.code, reward.amount, reward.type)
			end
			itemCell:setClickable(false)
			itemCell:setReceiveFrame(giftData.payState[index+1]==1)
			obj:getChildAutoType("img_red"):setVisible(giftData.payState[index+1]==1)
			--if giftData.freeState[index+1]==2 then
				--itemCell:setIsHook(giftData.freeState[index+1]==2)
			--end
			itemCell:setIsHook(giftData.payState[index+1]==2)
			local params = {
				giftId		= self.giftId,  -- 1:integer #要领取的奖励对应的配置id
				rewardType  = 2, -- 2:integer #1：免费奖励 2：付费奖励
				progress    = timesToPayRewardId[index+1].count,-- 3:boolean #领取是哪个进度的奖励
			}

			
			obj:addClickListener(function (context)
					context:stopPropagation()--阻止事件冒泡
					if giftData.payState[index+1]==1 then
						FullsrGiftModel:serverGroupBuy(params)
					else
						showPreReward(obj,reward.item1)
					end
					
			end,27)		
	end)
	
	self.luxuryList:setNumItems(#timesToPayRewardId)
	
	self:updateCountTimer()
	
	
end


-- 倒计时
function FullsrGiftView:updateCountTimer()
	if self.isEnd then return end
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.ServerGroupBuy)
	--printTable(5656,"actData>>>>>>>",actData)
	-- do return end
	if not actData then return end
	local actId   = actData.id
	local status, addtime = ModelManager.ActivityModel:getActStatusAndLastTime(actId)
	if not addtime then return end

	--printTable(5656,"actData>>>>>>>",addtime)

	if status == 2 and addtime == -1 then
		self.isEnd = false
		self.txt_countTimer:setText(Desc.activity_txt5)
	else
		local lastTime = addtime / 1000
		if lastTime == -1 then
			self.txt_countTimer:setText(Desc.activity_txt5)
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
				end
			end
			if self.timer then
				TimeLib.clearCountDown(self.timer)
			end
			self.timer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
		end
	end
end


function FullsrGiftView:update_FullsrGiftData()
	--Scheduler.unschedule(self.timer)
	self:setActiveData()
end





function FullsrGiftView:_exit()
	Scheduler.unschedule(self.timer)
end






return FullsrGiftView
