local C = class("WorkingWelfareController", Controller)
--local AccumulativeDayActivityConfiger = require("Game.ConfigReaders.AccumulativeDayActivityConfiger")
local ActivityType = GameDef.ActivityType

function C:init()
    -- TODO
end

-- 服务端Odm数据下推回调
function C:Activity_UpdateData( _, params)
    if params.type ~= ActivityType.WorkingWelfare then
        return
    end

    -- 判断活动是否结束，结束的话将该活动入口删掉
    local activityBaseInfo = ActivityModel:getActityByType(params.type)
    if not activityBaseInfo then
        return
    end

    local workingWelfare = params.workingWelfare

    local show = (not params.endState) and workingWelfare.isOpen
    ActivityModel:showActivityEntrance(params.type, show)
    if not show then
        return
    end

    WorkingWelfareModel:setOdmData(workingWelfare)

    WorkingWelfareModel:checkReddot()
    Dispatcher.dispatchEvent(EventType.working_welfare_activity_update)
end


return C