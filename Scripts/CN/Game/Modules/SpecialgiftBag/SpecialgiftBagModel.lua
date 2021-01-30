local HeroConfiger = require "Game.ConfigReaders.HeroConfiger";
local SpecialgiftBagModel = class("SpecialgiftBagModel",BaseModel)

function SpecialgiftBagModel:ctor()
	self.SpecialgiftBagActiveInfo = {}
	self.redFlag = {}
end

function SpecialgiftBagModel:setSpecialgiftBagActiveInfo(activityType, info)
    if info.gift then
        self.SpecialgiftBagActiveInfo[activityType] = info.gift
    else
        self.SpecialgiftBagActiveInfo[activityType] = {}
    end
    self:SpecialgiftBagred(activityType)
end

function SpecialgiftBagModel:getSpecialgiftBagActiveInfo(activityType)
    if self.SpecialgiftBagActiveInfo[activityType] then
        return self.SpecialgiftBagActiveInfo[activityType]
    else
        return {}
    end
end

function SpecialgiftBagModel:SpecialgiftBagred(activityType) --ÌØ»ÝÀñ°üºìµã
    GlobalUtil.delayCallOnce(
        "OperatingActivitiesModel:SpecialgiftBagred",
        function()
            self:updateSpecialgiftBagRed(activityType)
        end,
        self,
        0.1
    )
end

function SpecialgiftBagModel:updateSpecialgiftBagRed(activityType)
   --[[ local dayStr = DateUtil.getOppostieDays()
    local isShow = FileCacheManager.getBoolForKey("SpecialgiftBagView_isShow"..activityType.."_".. dayStr, false)
    RedManager.updateValue("V_ACTIVITY_" .. activityType, (not isShow))--]]
	
	local activeInfo = ModelManager.ActivityModel:getActityByType(activityType)
	if activeInfo and activeInfo.showContent and activeInfo.showContent.data then
        local giftData = activeInfo.showContent.data
		if giftData then
			if not self.redFlag[activityType] then
				self.redFlag[activityType] = true
				local keyArr = {}
				for k,v in pairs(giftData) do
					if v.price == 0 then
						table.insert(keyArr, "V_ACTIVITY_"..activityType..v.id)
						break
					end
				end
				RedManager.addMap("V_ACTIVITY_"..activityType, keyArr)
			end
			
			local lingquList = self:getSpecialgiftBagActiveInfo(activityType)

			for k,v in pairs(giftData) do
				if v.price == 0  then
					local linquCount = lingquList and lingquList[v.id] and lingquList[v.id].times or 0
					RedManager.updateValue("V_ACTIVITY_"..activityType..v.id , v.times > linquCount)
					break
				end
			end
		end
	end
end


return SpecialgiftBagModel