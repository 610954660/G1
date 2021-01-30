local BaseModel = require "Game.FMVC.Core.BaseModel"
local WeekCardModel = class("WeekCardModel", BaseModel)


function WeekCardModel:ctor()
	self.weekCardData = {}
	self.endTime 	= false
end


function WeekCardModel:initData(data)
	do return end
	self.weekCardData = {}
	self.weekCardData = data
	-- printTable(8848,"self.weekCardData",self.weekCardData )
	-- if self:isState() then
	-- 	ActivityModel:speDeleteSeverData(GameDef.ActivityType.AccWeekCard)
	-- 	ViewManager.close("WeekCardView")
	-- 	return
	-- end
	self:upDateRed()
	Dispatcher.dispatchEvent(EventType.WeekCardView_refreshPanel)
end

function WeekCardModel:isState()
	if #self.weekCardData>0 then
		-- printTable(8848,">>>self.weekCardData 执行到了>>>")
		for k,v in pairs(self.weekCardData) do
			if v ~= 2 then
				return false
			end
		end
		return true
	end
end

function WeekCardModel:initEndTime(data)
	self.endTime = data.realEndMs
end

function WeekCardModel:getEndTime()
 	return self.endTime
end

function WeekCardModel:getWeekCardData()
	return self.weekCardData
end

function WeekCardModel:upDateRed()
	local weekCardData = {}
	weekCardData = self:getWeekCardData()
	local rewardData = DynamicConfigData.t_WeekCardReward[1]
	if not rewardData then return end
	local isShowRed = false
	local isCloseActivity = 0
	if #weekCardData < 1 then
		isShowRed = false
	else
		weekCardData 	= weekCardData[1]
		local isBuy 	= weekCardData.isBuy
		local state 	= {}
		state = weekCardData.state  		-- 奖励领取状态
		local day 		= weekCardData.id
		for i = 1,#state do
			local data = state[i]
			if data == 1 then
				isShowRed = true
			end
			if data == 2 then
				isCloseActivity = isCloseActivity + 1
			end
		end

		if isCloseActivity == 7 then
			-- self:closeActivity()
		end
	end



	-- 活动开启时 如果没打开过页面，显示主页红点
	local dayStr = DateUtil.getOppostieDays()
	local isShow = FileCacheManager.getBoolForKey("WeekCardView_isShow" .. dayStr,false)
	RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.AccWeekCard, not isShow or isShowRed)
end

-- 关闭活动
function WeekCardModel:closeActivity()
	print(8848,">>>>>>>>>>>>>>>>>closeActivity>>>>>>>")

	 ActivityModel:speDeleteSeverData(GameDef.ActivityType.AccWeekCard)  
end

return WeekCardModel