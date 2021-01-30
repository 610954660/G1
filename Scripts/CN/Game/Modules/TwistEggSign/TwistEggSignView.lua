-- added by xhd
-- 扭蛋活动之每日签到

local TimeLib = require "Game.Utils.TimeLib"
local TimeUtil = require "Game.Utils.TimeUtil"
local TwistEggSignView = class("TwistEggSignView",Window)

function TwistEggSignView:ctor()
	self._packName 	= "TwistEggSign"
	self._compName 	= "TwistEggSignView"

	self.timer 		 = false
	self.list_reward = false
	self.txt_countTimer = false
	self.banner 	 = false
	self.__timerId = false
	self.config = false
	self.serverData = false
end

function TwistEggSignView:_initUI()
	self.list_reward = self.view:getChildAutoType("list_reward")
	self.txt_countTimer = self.view:getChildAutoType("txt_countTimer")
	self.banner  		= self.view:getChildAutoType("banner")
	-- self.banner:setURL("UI/MonthlyGiftBag/img_meiyue_banner.png")
end


function TwistEggSignView:_initEvent()
	self:TwistEggSignView_refresh()
end

function TwistEggSignView:TwistEggSignView_refresh()
	self:updatePanel()
	self:updateActTimeShow()
end

function TwistEggSignView:updatePanel()
	self.list_reward:setItemRenderer(function(idx,obj)
		local index = idx + 1 
		local curConfig 	= self.config[index]
		local title = obj:getChildAutoType("title")
		local takeCtrl 		= obj:getController("takeCtrl")
		local txt_times 	= obj:getChildAutoType("txt_times")
		local btn_get 		= obj:getChildAutoType("btn_get")
		local list_reward 	= obj:getChildAutoType("list_reward")

		local rewardData 	= curConfig.reward
		title:setText(string.format(Desc.activity_txt27,index))

		list_reward:setItemRenderer(function(idx2,obj2)
			local reward 	= rewardData[idx2+1]
			local itemCell 	= BindManager.bindItemCell(obj2)
			itemCell:setData(reward.code, reward.amount, reward.type)
		end)
		list_reward:setData(rewardData)

		if self.serverData.dayIndex>index then --过期
			if self.serverData.recvRecords and self.serverData.recvRecords[index] then
				takeCtrl:setSelectedIndex(2)
			else
				takeCtrl:setSelectedIndex(3)
			end
		elseif self.serverData.dayIndex==index then --当天
			if self.serverData.recvRecords and self.serverData.recvRecords[index] and self.serverData.recvRecords[index].dayIndex == index then
				takeCtrl:setSelectedIndex(2)
			else
				takeCtrl:setSelectedIndex(1)
				btn_get:removeClickListener(888)
				btn_get:addClickListener(function()
					--领取
					local params = {}
					params.dayIndex = index
					params.activityId = TwistSignModel:getActivityId()
					params.onSuccess = function (res )
					end
					RPCReq.Activity_EveryDaySign_RecieveReward(params, params.onSuccess)
				end,888)
			end
			
		elseif self.serverData.dayIndex<index then --未到
			takeCtrl:setSelectedIndex(0)
		end

		
	end)
	self.config = TwistSignModel:getShowConfig()
	self.serverData = TwistSignModel:getData()
	printTable(1,self.serverData)
	self.list_reward:setData(self.config)
end

--更新活动时间
function TwistEggSignView:updateActTimeShow( ... )
	if self.__timerId then
		TimeLib.clearCountDown(self.__timerId)
	end
    local actid = TwistSignModel:getActivityId( )
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

function TwistEggSignView:_exit()
	if self.__timerId then
		TimeLib.clearCountDown(self.__timerId)
	end
end

return TwistEggSignView