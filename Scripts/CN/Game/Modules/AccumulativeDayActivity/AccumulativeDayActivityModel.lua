local M = class("AccumulativeDayActivityModel", BaseModel)
local AccumulativeDayActivityConfiger = require "Game.ConfigReaders.AccumulativeDayActivityConfiger"
local band = bit.band
local lshift = bit.lshift

function M:ctor()
    self.__odmData = {}
end

function M:getOdmData()
    return self.__odmData or DT
end

function M:setOdmData(data)
    if not data then return end
    -- self.__odmData = data
    self.__odmData = data.pageMap or {}
    self:redCheck()
end

function M:getModuleId(pageIndex)
    if not self.__odmData then return end
    return self.__odmData[pageIndex].round
end


-- 获取奖励状态，0不可领取，1可领取，2已领取
-- pageIndex 礼包页签
function M:getRewardStatus(pageIndex,day)
    local currentAccumulativeDay = self:getCurrentAccumulativeDay(pageIndex)
    if day > currentAccumulativeDay then
        return 0
    end
    --
    local state = self.__odmData[pageIndex].state
    if band(state, lshift(1, day-1)) == 0 then
        return 1
    end
    --
    return 2
end

-- 当前累积的充值天数
function M:getCurrentAccumulativeDay(pageIndex)
    return self.__odmData[pageIndex].chargeDays
end

-- 上次充值积累时间
function M:getLastChangeTime(pageIndex)
    return self.__odmData[pageIndex].lastChangeTime or 0
end

-- 领取奖励
function M:getReward(day,pageIndex)
    RPCReq.Activity_AccumulativeDay_Recieve({
        id = day,
        pageIndex = pageIndex,
    })
end

-- TODO

-- 更新红点
function M:redCheck()
    GlobalUtil.delayCallOnce("AccumulativeDayActivityController:Activity_UpdateData",function()
		self:updateRed()
		Dispatcher.dispatchEvent(EventType.accumulative_day_activity_update)
	end, self, 0.1)
end

function M:updateRed()
    local pageData = AccumulativeDayActivityConfiger:getPageConfig(1)
    local keyArr1 = {}
    for i=1,TableUtil.GetTableLen(pageData) do
        local keyArr2 = {}
        local rewardData = AccumulativeDayActivityConfiger:getDayList(i)
        for j=1,TableUtil.GetTableLen(rewardData) do
            local data = rewardData[j]
            table.insert(keyArr2, "V_ACTIVITY_"..GameDef.ActivityType.AccumulativeDay..i .. data.day)
        end
        table.insert(keyArr1, "V_ACTIVITY_"..GameDef.ActivityType.AccumulativeDay..i)
        RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.AccumulativeDay .. i, keyArr2)
    end
    RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.AccumulativeDay, keyArr1)

	-- local show = false
	for i=1,TableUtil.GetTableLen(pageData) do
		local dayList = AccumulativeDayActivityConfiger:getDayList(i)
		for _, config in ipairs(dayList) do
            if AccumulativeDayActivityModel:getRewardStatus(i,config.day) == 1 then
                RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.AccumulativeDay..i .. config.day, true)
				-- show = true
                -- break
            else
                RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.AccumulativeDay..i .. config.day, false)
			end
		end
	end
end

return M
