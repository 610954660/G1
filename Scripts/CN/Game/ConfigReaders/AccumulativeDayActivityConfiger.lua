local M = {}

--
function M:getCurrentConfig(pageIndex)
    local moduleId = AccumulativeDayActivityModel:getModuleId(pageIndex)
    return DynamicConfigData.t_AddRecharge[moduleId][pageIndex]
end

function M:getPageConfig(pageIndex)
    local moduleId = AccumulativeDayActivityModel:getModuleId(pageIndex)
    return DynamicConfigData.t_AddRecharge[moduleId]
end

-- 获取礼包配置
function M:getDayList(pageIndex)
    local moduleId = AccumulativeDayActivityModel:getModuleId(pageIndex)
    local dayList = DynamicConfigData.t_AddRechargeReward[moduleId][pageIndex]
    table.sort(dayList, function(left, right)
        local leftGot = AccumulativeDayActivityModel:getRewardStatus(pageIndex,left.day) == 2
        local rightGot = AccumulativeDayActivityModel:getRewardStatus(pageIndex,right.day) == 2
        if leftGot ~= rightGot then
            return not leftGot
        end
        return left.day < right.day
    end)
    return dayList
end

--
function M:getMaxDay(pageIndex)
    local moduleId = AccumulativeDayActivityModel:getModuleId(pageIndex)
    local configList = DynamicConfigData.t_AddRechargeReward[moduleId][pageIndex]
    return #configList
end

return M