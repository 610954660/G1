--Date :2020-12-16
--Author : generated by FairyGUI
--Desc : 

local ActGodsPrayView,Super = class("ActGodsPrayView", Window)

function ActGodsPrayView:ctor()
	--LuaLog("ActGodsPrayView ctor")
	self._packName = "ActGodsPray"
	self._compName = "ActGodsPrayView"
	--self._rootDepth = LayerDepth.Window
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.GodsPray)
	self.moduleId = actData and actData.showContent.moduleId or 1
	self.beginPray=false
	self.rollTime=0
	self.allTime=0
	
	self.rollSpeed=0.08
	self.fadeSpeedTime=2  --多少秒后逐渐减速
	self.frameFadeVaule=0.3 --每帧减速多少
	
	
	self.chooseCtrs={}
	self.lastSelect=false
	self.beginfade=false
	
	self.beginIndex=1
	self.skipArray=false
	
end

function ActGodsPrayView:_initEvent( )
	
end

function ActGodsPrayView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:ActGodsPray.ActGodsPrayView
	self.txt_countTimer = viewNode:getChildAutoType('$txt_countTimer')--GTextField
	self.btn_Pray = viewNode:getChildAutoType('btn_Pray')--com_btn_Lv0Yellow_cost
		self.btn_Pray.cost_2 = viewNode:getChildAutoType('btn_Pray/cost')--GTextField
		self.btn_Pray.img_red = viewNode:getChildAutoType('btn_Pray/img_red')--GImage
	self.btn_formula = viewNode:getChildAutoType('btn_formula')--GButton
	self.btn_help = viewNode:getChildAutoType('btn_help')--GButton
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.i1 = viewNode:getChildAutoType('i1')--godPrayCell
		self.i1.itemCell = viewNode:getChildAutoType('i1/itemCell')--GButton
	self.i10 = viewNode:getChildAutoType('i10')--godPrayCell
		self.i10.itemCell = viewNode:getChildAutoType('i10/itemCell')--GButton
	self.i2 = viewNode:getChildAutoType('i2')--godPrayCell
		self.i2.itemCell = viewNode:getChildAutoType('i2/itemCell')--GButton
	self.i3 = viewNode:getChildAutoType('i3')--godPrayCell
		self.i3.itemCell = viewNode:getChildAutoType('i3/itemCell')--GButton
	self.i4 = viewNode:getChildAutoType('i4')--godPrayCell
		self.i4.itemCell = viewNode:getChildAutoType('i4/itemCell')--GButton
	self.i5 = viewNode:getChildAutoType('i5')--godPrayCell
		self.i5.itemCell = viewNode:getChildAutoType('i5/itemCell')--GButton
	self.i6 = viewNode:getChildAutoType('i6')--godPrayCell
		self.i6.itemCell = viewNode:getChildAutoType('i6/itemCell')--GButton
	self.i7 = viewNode:getChildAutoType('i7')--godPrayCell
		self.i7.itemCell = viewNode:getChildAutoType('i7/itemCell')--GButton
	self.i8 = viewNode:getChildAutoType('i8')--godPrayCell
		self.i8.itemCell = viewNode:getChildAutoType('i8/itemCell')--GButton
	self.i9 = viewNode:getChildAutoType('i9')--godPrayCell
		self.i9.itemCell = viewNode:getChildAutoType('i9/itemCell')--GButton
	self.moneyCom = viewNode:getChildAutoType('moneyCom')--com_money
		self.moneyCom.btn_add = viewNode:getChildAutoType('moneyCom/btn_add')--GButton
		self.moneyCom.iconLoader = viewNode:getChildAutoType('moneyCom/iconLoader')--GLoader
		self.moneyCom.txt_num = viewNode:getChildAutoType('moneyCom/txt_num')--GTextField
	self.skipToggle = viewNode:getChildAutoType('skipToggle')--GButton
	--{autoFieldsEnd}:ActGodsPray.ActGodsPrayView
	--Do not modify above code-------------
	
	self:setBg("godsPrayBg.jpg")
	
	
end

function ActGodsPrayView:_initListener( )
	
	self.btn_Pray:addClickListener(function()
		if self.beginPray then
				return 
		end
		
		if not ActGodsPrayModel:checkMoneyE() then
			self:showAcItemTip()
			return
		end
			
		ActGodsPrayModel:godsPray_Luckydraw(function ()
				if self.skipArray then
					self:showReward(0)
				else
					self.lastSelect=self.chooseCtrs[1].Ctr
					self.lastSelect:setSelectedIndex(1)
					self.beginPray=true	
				end
		end)		
	end)
	

	self.view:displayObject():onUpdate(function (dt)
			self:onUpdate(dt)
	end,0)
	
	self.skipToggle:addClickListener(function ()
			self.skipArray = self.skipToggle:isSelected()
			if self.skipArray then
				self:showReward(0)
			end
			PataModel:saveSkipArray(GameDef.ActivityType.GodsPray, self.skipArray)
	end)
	
	if PataModel:checkSkipArray(GameDef.ActivityType.GodsPray) then
		self.skipToggle:setSelected(true)
		self.skipArray =true
	end
	
	self.costItem=BindManager.bindCostItem(self.moneyCom)
	local config =DynamicConfigData.t_GodsLotteryCost[1]
	local costItem = config.costItem[1]
	self.costItem:setData(costItem.type,costItem.code,0,false,true,true,false,true)
	
	
	
	self.moneyCom.btn_add:addClickListener(function( ... )
		 self:showAcItemTip()
	end)
	
	self.btn_help:addClickListener(function()
			RollTips.showHelp(Desc.help_StrTitle230, Desc.help_StrDesc230)
	end,111)
	self.btn_formula:addClickListener(function()
		local config = DynamicConfigData.t_GodsLotteryProbability[self.moduleId]
		RollTips.showRateTips(config)
	end,112)
	

end


function ActGodsPrayView:_initUI( )
	self:_initVM()
	self:_initListener()
	self:TwistRuneView_refresh()
	self:showReward(0)
    --self:updateItemCount()
end



function ActGodsPrayView:TwistRuneView_refresh()
	if self.lastSelect then
		self.lastSelect:setSelectedIndex(0)
		self.lastSelect=false
	end
	self.chooseCtrs={}
	local activeData,keys =  ActGodsPrayModel:getRuneActiveDataCfg()
    for i = 1, 10 do
		local itemObj=self["i"..i]
		
		local rewardData=activeData[i]
		local itemcell = BindManager.bindItemCell(itemObj.itemCell)
		local itemData = ItemsUtil.createItemData({data = rewardData.reward[1]})
		itemcell:setItemData(itemData)
		local cData={
			rewardId =i,
			Ctr=itemObj:getController("select")
		}
		if rewardData.state==2 then
			itemcell:setIsHook(true)
	    else
			itemcell:setIsHook(false)
			table.insert(self.chooseCtrs,cData)
		end
    end	
	self.costBtnCell=BindManager.bindCostButton(self.btn_Pray)
	
	self.costBtnCell:setAddX(true)
	self.costBtnCell:setCostCtrl(2)
	
	
	local _cost = ActGodsPrayModel:getCostData()
	if _cost then
		self.costBtnCell:setData(_cost.costItem[1])
		--ActGodsPrayModel:updateRed()
	else
		self.btn_Pray:setVisible(false)
	end
	self:updateCountTimer()
	
end


-- 倒计时
function ActGodsPrayView:updateCountTimer()
	if self.isEnd then return end
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.GodsPray)
	 printTable(5656,"actData>>>>>>>",actData)
	-- do return end
	if not actData then return end
	local actId   = actData.id
	local status, addtime = ModelManager.ActivityModel:getActStatusAndLastTime(actId)
	if not addtime then return end

	printTable(5656,"actData>>>>>>>",addtime)
	
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


--弹出活动商城购买界面
function ActGodsPrayView:showAcItemTip()
	local config =DynamicConfigData.t_GodsLotteryCost[1]
	local code = config.costItem[1].code
	local costItem = config.costItem[1]
	local itemInfo = ItemConfiger.getInfoByCode(code)
	local itemData = ItemsUtil.createItemData({data = {type = CodeType.ITEM, code = itemInfo.code, amount = 1}})
	ViewManager.open("ItemTips", {codeType = CodeType.ITEM, id = itemInfo.code, data = itemData})
end


function ActGodsPrayView:setNextSelect()
	if self.lastSelect then
		self.lastSelect:setSelectedIndex(0)
	end
	self.beginIndex=self.beginIndex+1
	if self.beginIndex>table.getn(self.chooseCtrs) then
		self.beginIndex=1
	end
	local chooseData=self.chooseCtrs[self.beginIndex]
	self.lastSelect=chooseData.Ctr
		
	
	if table.getn(self.chooseCtrs)==1 then
		self:showReward(0)
	end
	if self.beginfade and chooseData.rewardId==ActGodsPrayModel.rewardId  then
		self:showReward(0.3) 
	end
	if self.allTime>self.fadeSpeedTime then
		local fadeInex=self:getBeginfadeIndex()
		if fadeInex==self.beginIndex then
			self.beginfade=true
		end
	end
	self.lastSelect:setSelectedIndex(1)
end


function ActGodsPrayView:showReward(delay) 	
	self.beginPray=false
	self.rollSpeed=0.08
	self.rollTime=0
	self.allTime=0
	self.beginfade=false
	local rewardData=PlayerModel:get_awardData(GameDef.GamePlayType.ActivityGodsPray)
	if rewardData and rewardData.reward then
	   GlobalUtil.delayCall(function()end,function ()
				if tolua.isnull(self.view) then
					return 
				end
				ActGodsPrayModel:showReward()
				self:TwistRuneView_refresh()
	   end,delay,1)
	end
end




function ActGodsPrayView:onUpdate(dt)
	if self.beginPray then
		self.rollTime=self.rollTime+dt
		self.allTime=self.allTime+dt
		if self.rollTime>self.rollSpeed then
			self.rollTime=0
			self:setNextSelect()
			if self.beginfade then
				self.rollSpeed=self.rollSpeed+self.frameFadeVaule
			end
		end
	end
end


--奖励Id的前三个开始减速
function ActGodsPrayView:getBeginfadeIndex()
	
	local index=1
	for k, data in pairs(self.chooseCtrs) do
		if data.rewardId ==ActGodsPrayModel.rewardId then
			index=k
			break
		end
	end
    for i = 1, 2 do
		index=index-1
		if index==0 then
			index=table.getn(self.chooseCtrs)
		end
    end
	return index
end



function ActGodsPrayView:_exit()
	Scheduler.unschedule(self.timer)
end


return ActGodsPrayView