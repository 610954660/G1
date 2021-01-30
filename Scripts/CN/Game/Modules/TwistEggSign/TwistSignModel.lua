local HeroConfiger = require "Game.ConfigReaders.HeroConfiger";
local TwistSignModel = class("TwistSignModel",BaseModel)

function TwistSignModel:ctor()
	self.moduleId = 1
	self.actType = GameDef.ActivityType.EveryDaySign
	self.data = {}
end


--获取对应的模块ID
function TwistSignModel:getModuleId()
  local moduleId = 1
  local actData = ModelManager.ActivityModel:getActityByType(self.actType)
  moduleId = actData and actData.showContent.moduleId or 1
  return moduleId
end

function TwistSignModel:getActivityId( )
	local viewData = ActivityModel:getActityByType( self.actType )
	return viewData.id
end

--设置数据
function TwistSignModel:setData( data )
	self.data = data
	if not self.data.dayIndex then
       self.data.dayIndex = 1
	end
	self.moduleId  = self:getModuleId()
	Dispatcher.dispatchEvent(EventType.TwistEggSignView_refresh,data)
end

function TwistSignModel:getData( ... )
	return  self.data
end

function TwistSignModel:getShowConfig(  )
	return DynamicConfigData.t_CapsuleToysSign[self:getModuleId()]
end

--红点检测
function TwistSignModel:checkRedot()
	RedManager.updateValue("V_ACTIVITY_"..self.actType,false)
	GlobalUtil.delayCallOnce("TwistSignModel:checkRedot", function ()
	local rewardData  = DynamicConfigData.t_CapsuleToysSign[self:getModuleId()]
	for i = 1,#rewardData do
		if self.data.dayIndex == i and self.data.recvRecords and (not self.data.recvRecords[i])  then
			RedManager.updateValue("V_ACTIVITY_"..self.actType,true)
			break
		end
	end
	end, self, 0.5)
end
	
	
	
return TwistSignModel