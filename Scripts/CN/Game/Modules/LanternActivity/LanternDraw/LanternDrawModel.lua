local HeroConfiger = require "Game.ConfigReaders.HeroConfiger";
local LanternDrawModel = class("LanternDrawModel",BaseModel)

function LanternDrawModel:ctor()
	self.recvRecords = false
	self.drawCount = 0
	self.moduleId = 1
	self.redInited = false
	self.costCode = 10000072
	self.lastModuleId = 0
	self.maxTimes = 0   
end


function LanternDrawModel:getModuleId()
  local moduleId = 1
  local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.LanternDraw)
  moduleId = actData and actData.showContent.moduleId or 1
  -- printTable(8848,">>actData>>",actData)
  return moduleId
end


function LanternDrawModel:initRedMap()
	self.moduleId = self:getModuleId()
	if not self.redInited or self.moduleId ~= self.lastModuleId then
		local rewardData  = DynamicConfigData.t_LanternTime[self.moduleId]
		local redMap = {}
		for i = 1,5 do
			local data1 = rewardData[i]
			table.insert(redMap, "V_LANTERN_DRAW_"..data1.time)
			if self.maxTimes < data1.time then
				self.maxTimes = data1.time
			end
		end
		RedManager.addMap("V_LANTERN_DRAW_REWARD", redMap)
		self.redInited = true
		self.lastModuleId = self.moduleId
	end
end


function LanternDrawModel:getMaxTimes()
	return self.maxTimes 
end

function LanternDrawModel:redCheck()
	GlobalUtil.delayCallOnce("LanternDrawModel:redCheck", function ()
		local rewardData  = DynamicConfigData.t_LanternTime[self.moduleId]
		for i = 1,5 do
			local data1 = rewardData[i]
			local canGet = self.drawCount >= data1.time
			local hasGet = ModelManager.LanternDrawModel.recvRecords and ModelManager.LanternDrawModel.recvRecords[i] ~= nil
			RedManager.updateValue("V_LANTERN_DRAW_"..data1.time, canGet and not hasGet )
		end
		
		local cost_one = DynamicConfigData.t_LanternDraw[self.moduleId][1].costItem
		local cost_ten = DynamicConfigData.t_LanternDraw[self.moduleId][2].costItem
		
		RedManager.updateValue("V_LANTERN_DRAW".."_ONE", ModelManager.PlayerModel:isCostEnough(cost_one, false))
		RedManager.updateValue("V_LANTERN_DRAW".."_TEN", ModelManager.PlayerModel:isCostEnough(cost_ten, false))
		end, self, 0.5)
	end
	
	
	
	return LanternDrawModel