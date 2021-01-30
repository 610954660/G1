local M = {}

function M:getSloganText()
    local moduleId = DelegateActivityModel:getModuleId()
    return DynamicConfigData.t_DelegateActivity[moduleId].desc
end

function M:getCurrentConfig()
    local moduleId = DelegateActivityModel:getModuleId()
    return DynamicConfigData.t_DelegateActivityReward[moduleId] or DT
end

function M:getTaskConfig(taskId)
    return self:getCurrentConfig()[taskId]
end

return M
