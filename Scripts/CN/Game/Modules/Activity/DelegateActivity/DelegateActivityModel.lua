local M = class("DelegateActivityModel", BaseModel)
local DelegateActivityConfiger = require "Game.ConfigReaders.DelegateActivityConfiger"

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
    if self.__odmData and self.__odmData.moduleId then
        return self.__odmData.moduleId
    end
end

-- 已完成的委托次数
function M:getCompletedTimes()
    return self.__odmData.times
end

-- 任务状态
-- 0：已完成但未领取奖励，1：未完成，2：奖励已领取
function M:getTaskStatus(taskId)
    local completedTimes = self:getCompletedTimes()
    local config = DelegateActivityConfiger:getTaskConfig(taskId)
    if completedTimes < config.times then
        return 1
    end

    if not self.__odmData.state then
        return 0
    end

    if band(self.__odmData.state, lshift(1, taskId-1)) == 0 then
        return 0
    else
        return 2
    end
end

-- 获取奖励列表
function M:getTaskList()
    local config = DelegateActivityConfiger:getCurrentConfig()
    local rewardList = {}
    for _, task in pairs(config) do
        table.insert(rewardList, task)
    end
    table.sort(rewardList, function(left, right)
        local leftStatus = self:getTaskStatus(left.id)
        local rightStatus = self:getTaskStatus(right.id)
        --
        if leftStatus ~= rightStatus then
            return leftStatus < rightStatus
        end
        --
        return left.id < right.id
    end)
    return rewardList
end

-- 领取奖励
function M:getTaskReward(taskId)
    RPCReq.Activity_DelegateContend_Reward({
        index = taskId
    })
end

-- 今日已打开过一次
function M:todayHaveOpenedOnce(bool)
    local key = string.format("DelegateActivity%d", GameDef.ActivityType.DelegateContend)

    if bool then
        FileCacheManager.setIntForKey(key, TimeLib.getTotalDays())
        return
    end

    local days = FileCacheManager.getIntForKey(key, 0)
    if TimeLib.getTotalDays() > days then
        return false
    end
    return true
end

function M:checkReddot()
    local show = false
    --
    local tasks = DelegateActivityConfiger:getCurrentConfig()
    for id, _ in ipairs(tasks) do
        if self:getTaskStatus(id) == 0 then
            show = true
            break
        end
    end
    --
    show = show or (not self:todayHaveOpenedOnce())
    --
    RedManager.updateValue(string.format("V_ACTIVITY_%d", GameDef.ActivityType.DelegateContend), show)
end

--

return M
