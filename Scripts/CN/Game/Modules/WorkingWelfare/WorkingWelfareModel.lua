local M = class("WorkingWelfareModel", BaseModel)
local WorkingWelfareConfiger = require "Game.ConfigReaders.WorkingWelfareConfiger"

local band = bit.band
local lshift = bit.lshift

function M:ctor()
    self.__odmData = false
end

function M:getOdmData()
    return self.__odmData or DT
end

function M:setOdmData(data)
    self.__odmData = data
end

function M:getModuleId()
    return self.__odmData.moduleId
end

function M:getCurrentDayOfWeek()
    -- TimeLib.getWeekDay()
    return self.__odmData.dayIndex
end

function M:getReward(dayOfWeek)
    RPCReq.Activity_WorkingWelfare_GetReward({
        id = dayOfWeek,
    })
end

-- 获取奖励领取状态，0：未领取，1：已领取
function M:getRewardStatus(dayOfWeek)
    local rewardState = self.__odmData.rewardState or DT
    local workingState = rewardState[dayOfWeek] or DT
    if workingState.state then
        return 1
    end
    return 0
end


function M:checkReddot()
    local show = false
    --
    local nowDayOfWeek = self:getCurrentDayOfWeek()
    local config = WorkingWelfareConfiger:getCurrentConfig()
    for index = 1, #config.week do
        local dayOfWeek = config.week[index]
        local got = self:getRewardStatus(dayOfWeek) == 1
        if dayOfWeek == nowDayOfWeek and not got then
            show = true
            break
        end
    end
    --
    --show = show or (not self:todayHaveOpenedOnce())
    --
    RedManager.updateValue(string.format("V_ACTIVITY_%d", GameDef.ActivityType.WorkingWelfare), show)
end
-- TODO

return M
