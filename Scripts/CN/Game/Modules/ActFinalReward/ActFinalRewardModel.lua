local HeroConfiger = require "Game.ConfigReaders.HeroConfiger";
local ActFinalRewardModel = class("ActFinalRewardModel",BaseModel)
--最终赏活动
function ActFinalRewardModel:ctor()
	self.moduleId = 1
	self.actType = GameDef.ActivityType.ElfFinal
	self.data = {}
end


--获取对应的模块ID
function ActFinalRewardModel:getModuleId()
  local moduleId = 1
  local actData = ModelManager.ActivityModel:getActityByType(self.actType)
  moduleId = actData and actData.showContent.moduleId or 1
  return moduleId
end

function ActFinalRewardModel:getActivityId( )
	local viewData = ActivityModel:getActityByType( self.actType )
	if viewData then
		return viewData.id
	end
	return nil
end

--设置数据
function ActFinalRewardModel:setData( data )
	self.data = data
	self.moduleId  = self:getModuleId()
	Dispatcher.dispatchEvent(EventType.ActFinalRewardView_refresh)
end

--收集次数
function ActFinalRewardModel:getDataCollect(  )
	return self.data.collect
end

--获取显示模型ID
function ActFinalRewardModel:getModelId(  )
	-- local model = 0
	local jlID = DynamicConfigData.t_ElfShow[self.moduleId].jlID
	-- if DynamicConfigData.t_ElfMain[jlID] and DynamicConfigData.t_ElfMain[jlID][1] then
	-- 	model = DynamicConfigData.t_ElfMain[jlID][1].resource
	-- end
return jlID,DynamicConfigData.t_ElfShow[self.moduleId].offsetx,DynamicConfigData.t_ElfShow[self.moduleId].offsety,DynamicConfigData.t_ElfShow[self.moduleId].scale
end

--获取碎片需要数量
function ActFinalRewardModel:getSuipianNum(  )
	local elfId = 0
	local amount = 0
	if DynamicConfigData.t_ElfShow[self.moduleId] then
		elfId = DynamicConfigData.t_ElfShow[self.moduleId].elfID
	end
	if DynamicConfigData.t_ElfShow[self.moduleId] then
		amount = DynamicConfigData.t_ElfShow[self.moduleId].number
	end
	-- if DynamicConfigData.t_ElfCombine[elfId] then
	-- 	amount = DynamicConfigData.t_ElfCombine[elfId].amount
	-- end
	return amount
end

--已领取宝箱
function ActFinalRewardModel:getDataReceive(  )
	return self.data.receive
end

function ActFinalRewardModel:getActiVal( code )
	if not self.data.collect then return 0 end
	printTable(1,self.data.collect)
	for k,v in pairs(self.data.collect) do
		if self.data.collect[code] then
			return self.data.collect[code].time
		end
	end
	return 0
end

function ActFinalRewardModel:getShowConfig(  )
	return DynamicConfigData.t_ElfLast[self.moduleId]
end

function ActFinalRewardModel:getMaxActVal()
	local config =  DynamicConfigData.t_ElfLast[self.moduleId]
	return config[4].time
end

function ActFinalRewardModel:getAllActVal()
	local config =  DynamicConfigData.t_ElfLast[self.moduleId]
	local arr = {config[1].time,config[2].time,config[3].time,config[4].time}
	return arr
end

--红点检测
function ActFinalRewardModel:checkRedot()
	RedManager.updateValue("V_ACTIVITY_"..self.actType,false)
	GlobalUtil.delayCallOnce("ActFinalRewardModel:checkRedot", function ()
	local config =  DynamicConfigData.t_ElfLast[self.moduleId]
	for i=1,4 do
		local receive =  self:getDataReceive(  )
		local time = self:getActiVal(config[i].item)
		local actid = self:getActivityId( )

		if (not TableUtil.Exist(receive,config[i].id)) and time and time>=config[i].time then --次数达到
			RedManager.updateValue("V_ACTIVITY_"..self.actType,true)
			break
		end
	end
	end, self, 0.5)
end
	
	
	
return ActFinalRewardModel