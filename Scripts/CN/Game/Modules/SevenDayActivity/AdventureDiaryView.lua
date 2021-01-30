local SevenDayActView = require("Game.Modules.SevenDayActivity.SevenDayActView")
local V, Super = class("AdventureDiaryView", SevenDayActView)
local AdventureDiaryConfiger = require("Game.ConfigReaders.AdventureDiaryConfiger")

local ActivityType = GameDef.ActivityType

function V:_activityType()
    return ActivityType.RiskDiary
end

function V:_configer()
    return AdventureDiaryConfiger.new()
end

function V:_model()
    return AdventureDiaryModel
end

function V:_bg()
    return "img_qirimubiao_bg.jpg"
end

function V:_hideLiHui()
    return false
end

-- TODO

return V