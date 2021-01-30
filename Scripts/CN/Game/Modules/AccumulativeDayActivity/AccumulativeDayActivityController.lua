local C = class("AccumulativeDayActivityController", Controller)
local AccumulativeDayActivityConfiger = require("Game.ConfigReaders.AccumulativeDayActivityConfiger")
local ActivityType = GameDef.ActivityType

function C:init()
	-- TODO
end

-- 服务端Odm数据下推回调
function C:Activity_UpdateData( _, params)
	if params.type ~= GameDef.ActivityType.AccumulativeDay then
		return
	end

	-- 判断活动是否结束，结束的话将该活动入口删掉
	-- local activityBaseInfo = ActivityModel:getActityByType(params.type)
	-- if not activityBaseInfo then
	-- 	return
	-- end
	if params.endState then --如果是true 直接结束
		ActivityModel:speDeleteSeverData(params.type)
		return
	end
	AccumulativeDayActivityModel:setOdmData(params.accumulativeDay)
end


return C