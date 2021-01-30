-- This is an automatically generated class by FairyGUI.


local ActGodsPrayModel = class("TwistRune", BaseModel)

function ActGodsPrayModel:ctor()

	self.RuneActiveData = {}
	self.giftData = {}
	self.prayCount = 2  --第几次抽奖
	self.rewardId=1--奖品Id
	self.rewardData=false
	
	
	
end


function ActGodsPrayModel:initData(data)
	if data and data.godsPray then
		self.RuneActiveData = data.godsPray.getRewardPool or {}
	end
	
	self.prayCount=table.nums(self.RuneActiveData)+1
	printTable(5656,"data 神灵祈愿数据")
	self:setRuneActiveDataCfg()
	
	if data.fromLogin then
		Dispatcher.dispatchEvent(EventType.TwistRuneView_refresh)
	end
	self:redCheck()
end



function ActGodsPrayModel:getCostData()
   return DynamicConfigData.t_GodsLotteryCost[self.prayCount]
end


function ActGodsPrayModel:getFormulaDesc()
	local acConfig=ActivityModel:getActityByType(GameDef.ActivityType.GodsPray)
	local moduleId= acConfig.showContent.moduleId or 1	
	return DynamicConfigData.t_GodsLotteryProbability[moduleId].desc
end


function ActGodsPrayModel:redCheck()
	GlobalUtil.delayCallOnce("EquipTargetModel:redCheck",function()
			self:updateRed()
	end, self, 0.1)
end



function ActGodsPrayModel:setRuneActiveDataCfg()
	if TableUtil.GetTableLen(self.giftData) == 0 then
		self.giftData = DynamicConfigData.t_GodsLotteryDrop
	end
	local keyArr1 = {}
	printTable(5656,self.giftData,"self.giftData")
	for i, v in pairs(self.giftData) do
		--local keyArr2 = {}
		v.state=0
        if self.RuneActiveData[v.id] then
			v.state=2
		end

		table.insert(keyArr1, "V_ACTIVITY_"..GameDef.ActivityType.GodsPray.."_".. i)
		--RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.RuneMission .. i, keyArr2)
	end
	RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.GodsPray, keyArr1)
	
	
end


function ActGodsPrayModel:getRuneActiveDataCfg()
	local keysValus = {}
	for k, v in pairs(self.giftData) do
		table.insert(keysValus,k)
	end

	table.sort(keysValus,function (a,b)
			return a<b
	end)
	return self.giftData,keysValus
end



function ActGodsPrayModel:showReward()
	self.rewardData=PlayerModel:get_awardData(GameDef.GamePlayType.ActivityGodsPray) 
	printTable(5656,self.rewardData,"showReward")
	if self.rewardData and self.rewardData.reward then
		RollTips.showReward(self.rewardData.reward)
		PlayerModel:set_awardData({type=GameDef.GamePlayType.ActivityGodsPray})
		self.rewardData=false
	end
end




function ActGodsPrayModel:updateRed()
	--local _cost = self:getCostData()
	--local num= PlayerModel:getMoneyByType(GameDef.MoneyType.GodsPrayCoin)
	RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.GodsPray,self:checkMoneyE())
end


--检查货币是否充足
function ActGodsPrayModel:checkMoneyE()
	local _cost = self:getCostData()
	if _cost then 		
		local num= PlayerModel:getMoneyByType(GameDef.MoneyType.GodsPrayCoin)
		return num>=_cost.costItem[1].amount
    else
		return false
	end

end


function ActGodsPrayModel:godsPray_Luckydraw(finished)
	

	local acConfig=ActivityModel:getActityByType(GameDef.ActivityType.GodsPray)	
	local params = {
		activityId=acConfig.id	
	}
	params.onSuccess = function (data )
		self.rewardId=data.rewardId
		print(5656,"抽奖返回"..self.rewardId)
		if finished then
			finished()
		end
	end

	RPCReq.Activity_GodsPray_Luckydraw(params, params.onSuccess)
end






function ActGodsPrayModel:getTaskData(moduleId, type)
	return  DynamicConfigData.t_runeMissionActivity[moduleId][type]
end









return ActGodsPrayModel
