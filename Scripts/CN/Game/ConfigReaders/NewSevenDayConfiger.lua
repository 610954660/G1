local M = class("NewSevenDayConfiger")

function M:_model()
    return SevenDayActivityModel
end

function M:_getTaskInfoConfig()
    return DynamicConfigData.t_NewSevenDayTaskInfo
end

function M:_getTaskLibraryConfig()
    return DynamicConfigData.t_NewSevenDayTaskLibrary
end

function M:_getTaskConfig()
    return DynamicConfigData.t_NewSevenDayTask
end

function M:_getGiftConfig()
    return DynamicConfigData.t_NewSevenDayGift
end

function M:_getPointRewardConfig()
    return DynamicConfigData.t_NewSevenDayPointReward
end

--
function M:getTitleList(day)
    local moduleId = self:_model():getOdmData().moduleId
    if not moduleId then
        return DT
    end
    --
    local configs = self:_getTaskInfoConfig()
    --
    configs = configs[moduleId] or DT
    if not day then
        return configs
    end
    --
    configs = configs[day] or DT
    return configs
end

--
function M:getTaskList(libraryId)
    if not libraryId then
        return DT
    end
    --
    local configs = self:_getTaskLibraryConfig()
    --
    configs = configs[libraryId] or DT
    --
    local taskList = {}
    for _, config in pairs(configs) do
        table.insert(taskList, config)
    end
    table.sort(taskList, function(left, right)
        local leftStatus = self:_model():getTaskStatus(left.taskId)
        local rightStatus = self:_model():getTaskStatus(right.taskId)

        -- 可领取的在前
        local leftCanGet = leftStatus == 1
        local rightCanGet = rightStatus == 1
        if leftCanGet ~= rightCanGet then
            return leftCanGet
        end

        -- 已领取的在后
        local leftGot = leftStatus == 2
        local rightGot = rightStatus == 2
        if leftGot ~= rightGot then
            return not leftGot
        end
        -- 任务Id小的在前
        return left.taskId < right.taskId
    end)

    return taskList
end

--
function M:getTaskDetail(taskId)
    if not taskId then
        return DT
    end
    --
    local configs = self:_getTaskConfig()
    return configs[taskId] or DT
end

--
function M:getShopGoodsList(day)
    local moduleId = self:_model():getOdmData().moduleId
    if not moduleId or not day then
        return DT
    end
    --
    local configs = self:_getGiftConfig()
    configs = configs[moduleId] or DT
    configs = configs[day] or DT
    --
    local goodsList = {}
    for _, goods in ipairs(configs) do
        table.insert(goodsList, goods)
    end
    table.sort(goodsList, function(left, right)
        -- 仍有购买次数的在前
        local remainingBuyTimes, _ = self:_model():getGoodsRemainingBuyTimesAndMaxBuyTimes(day, left.id)
        local leftCanBuy = remainingBuyTimes > 0
        remainingBuyTimes, _ = self:_model():getGoodsRemainingBuyTimesAndMaxBuyTimes(day, right.id)
        local rightCanBuy = remainingBuyTimes > 0
        if leftCanBuy ~= rightCanBuy then
           return leftCanBuy
        end
        -- sortKey小的在前
        return left.sortKey < right.sortKey
    end)
    return goodsList
end

function M:getShopGoods(day, id)
    local moduleId = self:_model():getOdmData().moduleId
    if not moduleId or not day or not id then
        return DT
    end

    local configs = self:_getGiftConfig()
    configs = configs[moduleId] or DT
    configs = configs[day] or DT
    return configs[id] or DT
end

--
function M:getPointRewardList()
    local moduleId = self:_model():getOdmData().moduleId
    if not moduleId then
        return DT
    end
    --
    local configs = self:_getPointRewardConfig()
    configs = configs[moduleId] or DT
    local rewardList = {}
    for _, reward in ipairs(configs) do
        table.insert(rewardList, reward)
    end
    table.sort(rewardList, function(left, right)
        return left.index < right.index
    end)
    return rewardList
end

return M