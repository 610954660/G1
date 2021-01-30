local SevenDayActivityController = require("Game.Modules.SevenDayActivity.SevenDayActivityController")
local C = class("AdventureDiaryController", SevenDayActivityController)
local AdventureDiaryConfiger = require("Game.ConfigReaders.AdventureDiaryConfiger")

local ActivityType = GameDef.ActivityType

function C:_activityType()
    return ActivityType.RiskDiary
end

function C:_configer()
    return AdventureDiaryConfiger.new()
end

function C:_model()
    return AdventureDiaryModel
end

-- TODO

return C