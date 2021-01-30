local M = {}

--
function M:getCurrentConfig()
    local moduleId = WorkingWelfareModel:getModuleId()
    return DynamicConfigData.t_HardWorkGift[moduleId]
end

return M