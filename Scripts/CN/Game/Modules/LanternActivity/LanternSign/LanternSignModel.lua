local HeroConfiger = require "Game.ConfigReaders.HeroConfiger";
local LanternSignModel = class("LanternSignModel",BaseModel)

function LanternSignModel:ctor()
	self.moduleId = 1
	self.actType = GameDef.ActivityType.LanternEveryDaySign
	self.data = {}
end


--获取对应的模块ID
function LanternSignModel:getModuleId()
  local moduleId = 1
  local actData = ModelManager.ActivityModel:getActityByType(self.actType)
  moduleId = actData and actData.showContent.moduleId or 1
  return moduleId
end

function LanternSignModel:getActivityId( )
	local viewData = ActivityModel:getActityByType( self.actType )
	return viewData.id
end

--设置数据
function LanternSignModel:setData( data )
	self.data = data
	if not self.data.dayIndex then
       self.data.dayIndex = 1
	end
	self.moduleId  = self:getModuleId()
	Dispatcher.dispatchEvent(EventType.LanternSignView_refresh,data)
end

function LanternSignModel:getData( ... )
	return  self.data
end

function LanternSignModel:getShowConfig(  )
	return DynamicConfigData.t_LanternSign[self:getModuleId()]
end

--红点检测
function LanternSignModel:checkRedot()
	RedManager.updateValue("V_ACTIVITY_"..self.actType,false)
	GlobalUtil.delayCallOnce("LanternSignModel:checkRedot", function ()
	local rewardData  = DynamicConfigData.t_LanternSign[self:getModuleId()]
	for i = 1,#rewardData do
		if self.data.dayIndex == i and self.data.recvRecords and (not self.data.recvRecords[i])  then
			RedManager.updateValue("V_ACTIVITY_"..self.actType,true)
			break
		end
	end
	end, self, 0.5)
end
	
	
	
return LanternSignModel