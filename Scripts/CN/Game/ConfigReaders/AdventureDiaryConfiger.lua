local NewSevenDayConfiger = require("Game.ConfigReaders.NewSevenDayConfiger")
local M = class("AdventureDiaryConfiger", NewSevenDayConfiger)

function M:_model()
    return AdventureDiaryModel
end

function M:_getTaskInfoConfig()
    return DynamicConfigData.t_RiskDiaryTaskInfo
end

function M:_getTaskLibraryConfig()
    return DynamicConfigData.t_RiskDiaryTaskLibrary
end

function M:_getTaskConfig()
    return DynamicConfigData.t_RiskDiaryTask
end

function M:_getGiftConfig()
    return DynamicConfigData.t_RiskDiaryGift
end

function M:_getPointRewardConfig()
    return DynamicConfigData.t_RiskDiaryPointReward
end

return M