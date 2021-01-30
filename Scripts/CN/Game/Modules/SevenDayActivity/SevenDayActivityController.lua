local C = class("SevenDayActivityController", Controller)
local NewSevenDayConfiger = require("Game.ConfigReaders.NewSevenDayConfiger")
local ActivityType = GameDef.ActivityType

function C:_activityType()
	return ActivityType.SevenDayRecord
end

function C:_model()
	return SevenDayActivityModel
end

function C:_configer()
	return NewSevenDayConfiger.new()
end

function C:init()

end

-- update
function C:__update()
	local key = string.format("%s:__update", self.__cname)
	GlobalUtil.delayCallOnce(key, function()
		self:__checkReddot()
		Dispatcher.dispatchEvent(EventType.sevenday_activity_update, self:_activityType())
	end, self, 0.1)
end

-- 服务端Odm数据下推回调
function C:Activity_UpdateData( _, params)
	if params.type ~= self:_activityType() then
		return
	end
	-- 判断活动是否结束，结束的话将该活动入口删掉
	-- local activityBaseInfo = ModelManager.ActivityModel:getActityByType( params.type )
	-- if not activityBaseInfo then
	-- 	return
	-- end
	if params.endState then --如果是true 直接结束
		ModelManager.ActivityModel:speDeleteSeverData(params.type)
		return
	end
	--修改活动时间
	local startMs = params.sevenDayRecord.startDateStamp
	local endMs = params.sevenDayRecord.endDateStamp
	ModelManager.ActivityModel:updateSevenDayTime(params.type, startMs, endMs)

	--
	self:_model():setOdmData(params.sevenDayRecord)
	self:__update()
end

-- 玩家等级提升
function C:player_levelUp()
	if not ActivityModel:hasActivity(self:_activityType()) then
		return
	end
	self:__update()
end

-- 试炼塔通关
function C:sevenday_activity_tower_pass()
	if not ActivityModel:hasActivity(self:_activityType()) then
		return
	end
	self:__update()
end

function C:__checkReddot()
	-- 积分奖励领取红点  任务完成数状态
	local pointRewardList = self:_configer():getPointRewardList()
	for index, pointReward in ipairs(pointRewardList) do
		local show = self:_model():getPointRewardStatus(pointReward.index) == 1
		-- 更新红点状态
		RedManager.updateValue(string.format(
				"V_ACTIVITY_%d_POINTREWARD%d",
				self:_activityType(), index
		), show)
	end
	-- 任务奖励以及0元礼包领取红点
	for day = 1, 7 do
		local titleList = self:_configer():getTitleList(day)
		for titleIndex, title in ipairs(titleList) do
			if title.libraryId ~= 0 then
				local taskList = self:_configer():getTaskList(title.libraryId)
				local show = false
				for taskIndex, task in ipairs(taskList) do
					if self:_model():getTaskStatus(task.taskId) == 1 then
						show = true
						break
					end
				end
				if day>self:_model():getCurrentDay() then
					RedManager.updateValue(
						self:_model():getTaskTypeTabReddotKey(day, titleIndex),
						false)
				else
					RedManager.updateValue(
						self:_model():getTaskTypeTabReddotKey(day, titleIndex),
						show)
				end

			else
				local show = false
				local goodsList = self:_configer():getShopGoodsList(day)
				for _, goods in ipairs(goodsList) do
					if goods.sellPrice[1].amount == 0 then
						local remainingBuyTimes, _ = self:_model():getGoodsRemainingBuyTimesAndMaxBuyTimes(day, goods.id)
						if remainingBuyTimes > 0 then
							show = true
							break
						end
					end
				end
				if day>self:_model():getCurrentDay() then
					RedManager.updateValue(
						self:_model():getGoodsTypeTabReddotKey(day),
						false)
				else
					RedManager.updateValue(
						self:_model():getGoodsTypeTabReddotKey(day),
						show)
				end
			end
		end
	end
end

return C