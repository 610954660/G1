--Date :2020-12-09
--Author : generated by FairyGUI
--Desc : 

local HeroFettersModel = class("HeroFetters", BaseModel)

function HeroFettersModel:ctor()
	self.serverData = {}
	local isShow = FileCacheManager.getBoolForKey("HeroFettersFirst"..PlayerModel.userid,false)
	if not isShow then
		RedManager.updateValue("V_HeroFettersFirst",true)
		FileCacheManager.setBoolForKey("HeroFettersFirst"..PlayerModel.userid,true)
	else
		RedManager.updateValue("V_HeroFettersFirst",false)
	end
end

function HeroFettersModel:init()

end
function HeroFettersModel:getSeverData()
	return self.serverData
end
function HeroFettersModel:setSeverData(data)
	if data and data.fetterGroup then
		self.serverData = data.fetterGroup
	end
	local group = {}
	for key,value in pairs(self.serverData) do
		RedManager.updateValue("V_HeroFettersReward"..value.groupId,false)
		local config = DynamicConfigData.t_HeroFetter[value.groupId]
		if config then
			local max = table.nums(config.fetterGroup)
			for k,v in pairs(value.condition) do
				if v.curNum >= max and v.hasGotReward == false then
					RedManager.updateValue("V_HeroFettersReward"..value.groupId,true)
				end
			end
			table.insert(group,"V_HeroFettersReward"..value.groupId)
		end
	end
	RedManager.addMap("V_HeroFettersReward", group)
	Dispatcher.dispatchEvent("refresh_HeroFettersShow")
end
return HeroFettersModel