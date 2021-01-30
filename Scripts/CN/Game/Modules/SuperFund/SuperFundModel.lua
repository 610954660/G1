
local SuperFundModel = class("SuperFundModel",BaseModel)


function SuperFundModel:ctor()
	self.superData = {} 	-- 基金列表数据
	self.timer = {}
	self.redAddMap = false
end


function SuperFundModel:initData(data)
	self.superData = data.records or {}
	self:upDateTimer()
	self:upDateRed()
	Dispatcher.dispatchEvent(EventType.SuperFundView_refreshPanel)
end

function SuperFundModel:getAllData()
 	return self.superData
end

function SuperFundModel:getAccDay()

end

-- 红点刷新
function SuperFundModel:upDateRed()
	local superData = self:getAllData()
	if not self.redAddMap then
		local keyArr = {}
		for i=1,#superData do
			table.insert(keyArr,"V_ACTIVITY_"..GameDef.ActivityType.AccSuperFund..i)
		end
		RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.AccSuperFund,keyArr)
		self.redAddMap = true
	end
	local mainFlag = {}

	-- 根据奖励状态更新页签
	for i = 1,#superData do
		local rewardAllData = {} 
		rewardAllData = i == 1 and DynamicConfigData.t_SuperMoneyOne or DynamicConfigData.t_SuperMoneyTwo
		mainFlag[i] = false
		local recvList 	= superData[i].recvList or {} 		-- 奖励领取状态
		local isBuy 	= superData[i].isBuy  		-- 是否已购买基金
		local period 	= superData[i].id 	  		-- 第几期
		local dayCount  = superData[i].dayCount  	-- 累计天数

		local rewardData = rewardAllData[period] 	-- 对应基金的奖励
		if  not rewardData then
			return
		end		
		for j = 1 ,#rewardData do
			local data = rewardData[j]
			if not recvList[data.day] and isBuy and data.day <= dayCount then
				mainFlag[i] = true
				RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.AccSuperFund..i, true)
				break
			else
				RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.AccSuperFund..i, false)
			end
		end
	end

	 local isShowRed = false
	 for i = 1,#mainFlag do
	 	if mainFlag[i] then
 	 		isShowRed = true
 	 		break
	 	end
	 end

	-- -- 活动开启时 如果没打开过页面，显示主页红点
	-- local dayStr = DateUtil.getOppostieDays()
	-- local isShow = FileCacheManager.getBoolForKey("SuperFundView_isShow" .. dayStr,false)
	RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.AccSuperFund, isShowRed)-- not isShow or isShowRed)
end

-- 记录时间重新请求基金信息
function SuperFundModel:upDateTimer()
	local superData = self.superData
	for i = 1,#superData do
		self.timer[i] = false
		local data = superData[i]
		if data.index == 30 then
			local function docallback()
				local ServerTime = ServerTimeModel:getServerTime()  	-- 当前服务器时间
				local endTime    = math.floor(data.endTime/1000) 		-- 这一期结束时间
				local time 		 = endTime - ServerTime 				
				LuaLogE(">>>>>>>>>>>> self.timer[i] >>>>>>>> " ..i ..">>>>".. time)
				if time <= 0 then
					RPCReq.SuperFund_SendInfo({})
					if self.timer[i] then
						Scheduler.unschedule(self.timer[i])
						self.timer[i] = false
					end
				end
			end
			self.timer[i]=Scheduler.schedule(docallback, 1)
		end
	end

	-- for i = 1,#superData do
	-- 	if self.timer[i] then
	-- 		Scheduler.unschedule(self.timer[i])
	-- 		self.timer[i] = false
	-- 	end
	-- end
end


return SuperFundModel