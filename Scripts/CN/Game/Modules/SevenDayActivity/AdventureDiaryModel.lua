local SevenDayActivityModel = require("Game.Modules.SevenDayActivity.SevenDayActivityModel")
local M = class("AdventureDiaryModel", SevenDayActivityModel)
local AdventureDiaryConfiger = require("Game.ConfigReaders.AdventureDiaryConfiger")

local ActivityType = GameDef.ActivityType

function M:_activityType()
    return ActivityType.RiskDiary
end

function M:_configer()
    return AdventureDiaryConfiger.new()
end

-- TODO

return M
