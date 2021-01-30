-- added by wyz
-- 周卡

local WeekCardView 	= class("WeekCardView",Window)
local ItemConfiger 	= require "Game.ConfigReaders.ItemConfiger" 

function WeekCardView:ctor()
	self._packName 	= "WeekCard"
	self._compName	= "WeekCardView" 

	self.txt_countTime 	= false 	-- 倒计时文本
	self.btn_buy 		= false 	-- 购买按钮
	self.list_reward	= false 	-- 奖励列表
	self.txt_rebackPrice = false 	-- 返利文本
	self.isBuy 	 		= false 	-- 是否购买
	self.lastday 		= false 	-- 最后一天的领取状态
	self.timer = false
	self._rootDepth = LayerDepth.PopWindow
end

function WeekCardView:_initUI()
	self.txt_rebackPrice = self.view:getChildAutoType("txt_rebackPrice")
	self.txt_countTime 	 = self.view:getChildAutoType("txt_countTime")
	self.btn_buy 		 = self.view:getChildAutoType("btn_buy")
	self.list_reward 	 = self.view:getChildAutoType("list_reward")
end

function WeekCardView:_initEvent()
	self:WeekCardView_refreshPanel()
end


function WeekCardView:WeekCardView_refreshPanel()
	local dayStr = DateUtil.getOppostieDays()
	FileCacheManager.setBoolForKey("WeekCardView_isShow"..dayStr, true)
	WeekCardModel:upDateRed()
	
	local weekCardData  = WeekCardModel:getWeekCardData()
	local weekCardInfo = DynamicConfigData.t_WeekCard[1]
	local rewardData = DynamicConfigData.t_WeekCardReward[1]
	if not weekCardInfo then return end
	self.txt_rebackPrice:setText(weekCardInfo.discount .. "%")

	local state = {}
	if #weekCardData>0 then
		self.isBuy = weekCardData[weekCardInfo.moduleId].isBuy
		state = weekCardData[weekCardInfo.moduleId].state
	end

	local isShowState = false
	for i = 1,7 do 
		local txt_state = self.view:getChildAutoType("txt_state")
		local obj = self.view:getChildAutoType(string.format("item_%s",i))
		local index = i
 		local data = rewardData[index]
 		local takeState = 0 	-- 领取状态 0 未领取 1 可领取 2 已领取
 		takeState = state[index] or 0

 		local itemCell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
 		local reward = data.reward[1]
		itemCell:setData(reward.code,reward.amount,reward.type)
		itemCell.txtNum:setVisible(false)
		
		local txt_num = obj:getChildAutoType("txt_num")
		txt_num:setText("x"..reward.amount)

 		local txt_day = obj:getChildAutoType("txt_day")
 		txt_day:setText(data.day)

 		local border = obj:getChildAutoType("border")
 		-- border:setURL()

 		local txt_name = obj:getChildAutoType("txt_name")
 		txt_name:setText(ItemConfiger.getItemNameByCode(reward.code))

		local takeCtrl = obj:getController("takeCtrl")
		 
 		itemCell:setIsHook(takeState == 2 and true or false)
		
		if takeState == 0 then
			takeCtrl:setSelectedIndex(2)
		elseif takeState == 1 then
			takeCtrl:setSelectedIndex(1)
		elseif takeState == 2 then
			takeCtrl:setSelectedIndex(0)
		end

 		if (#weekCardData>0) and (index == weekCardData[weekCardInfo.moduleId].id) and (self.isBuy) then

 			if weekCardData[weekCardInfo.moduleId].id == 7 then
 				if takeState == 2 then
 					self.lastday = true
 				end
 			end
 			obj:getChildAutoType("itemCell"):setTouchable(takeState == 1 and false or true)
 		else
 			obj:getChildAutoType("itemCell"):setTouchable(true)
 		end

 		-- if self.isBuy and (index  == (weekCardData[weekCardInfo.moduleId].id + 1)) then
		-- 	takeCtrl:setSelectedIndex(0)
		-- end

		if self.isBuy and (index  == (weekCardData[weekCardInfo.moduleId].id)) and takeState == 2  then
			isShowState = true
		end

		txt_state:setVisible(isShowState)
		
		obj:removeClickListener(888)
		obj:addClickListener(function()
			local info = {
				type = weekCardInfo.moduleId,
				id 	 = index,
			}
			RPCReq.GamePlay_Modules_WeekCard_GetWeekCardReward(info,function(params)
				if tolua.isnull(self.view) then return end
				printTable(8848,">>>params>>>",params)
				local close = self:openState()
				if self.isBuy and close then
					ViewManager.close("WeekCardView")
					return
				end
				self:WeekCardView_refreshPanel()
			end)
		end,888)
	end


	local buyCtrl = self.view:getController("buyCtrl")
	buyCtrl:setSelectedIndex(self.isBuy and 1 or 0)
	self.btn_buy:setVisible(not self.isBuy)
	self.btn_buy:getChildAutoType("title"):setText(string.format(Desc.WeekCard_price,weekCardInfo.price))
	self.btn_buy:removeClickListener(888)
	self.btn_buy:addClickListener(function()
		local info = {
			type = 1,
		}
		ModelManager.RechargeModel:directBuy(weekCardInfo.price, GameDef.StatFuncType.SFT_WeekCard, weekCardInfo.moduleId, Desc.WeekCard_name, nil,weekCardInfo.showName1)
	end,888)
	self:countTime()
end

function WeekCardView:openState()
	local close = true
	local weekCardInfo = DynamicConfigData.t_WeekCard[1]
	local weekCardData  = WeekCardModel:getWeekCardData()
	local state = {}
	state = weekCardData[weekCardInfo.moduleId].state
	printTable(8848,">>>state>>>",state)
	if state and #state == 7 then 
		for k,v in pairs(state) do
			if v ~= 2 then 
				close = false
				break
			end
		end
	end
	return close
end


function WeekCardView:countTime()
	local serverTime = ServerTimeModel:getServerTimeMS()
	local lastTime = WeekCardModel:getEndTime()
    lastTime = (lastTime-serverTime)/1000
    -- print(8848,"lastTime",lastTime)
	if not lastTime then lastTime = -1 end
    local stateCtrl = self.view:getController("stateCtrl")
	if lastTime ~= -1 then
		if lastTime >0 then
			stateCtrl:setSelectedIndex(0)
	    	self.txt_countTime:setText(TimeLib.GetTimeFormatDay(lastTime,2))
		    local function onCountDown( time )
		    	self.txt_countTime:setText(TimeLib.GetTimeFormatDay(time,2))
		    end
		    local function onEnd( ... )
		    	stateCtrl:setSelectedIndex(1)
				self.txt_countTime:setVisible(false)
				local close = self:openState()
		    	if not self.isBuy then
					WeekCardModel:closeActivity()
					ViewManager.close("WeekCardView")
		    	elseif self.lastday  and close then
		    		WeekCardModel:closeActivity()
		    	end
		    end
		    if self.timer then
		    	TimeLib.clearCountDown(self.timer)
		    end
		    self.timer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false,false)
	    else
	    	stateCtrl:setSelectedIndex(1)
			self.txt_countTime:setVisible(false)
			local close = self:openState()
	    	if not self.isBuy then
	    		WeekCardModel:closeActivity()
	    	elseif self.lastday and close then
	    		WeekCardModel:closeActivity()
	    	end
	    end
	end
end


function WeekCardView:_exit()
	if self.timer then
		TimeLib.clearCountDown(self.timer)
	end
end


return WeekCardView