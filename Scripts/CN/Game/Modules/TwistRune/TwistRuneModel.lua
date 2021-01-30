-- This is an automatically generated class by FairyGUI.


local TwistRuneModel = class("TwistRune", BaseModel)

function TwistRuneModel:ctor()

	self.RuneActiveData = {}
	self.giftData = {}
	self.pageIndex = 1
	self.jump = false -- 界面跳转
	
end


function TwistRuneModel:initData(data)
	if data and data.records then
		self.RuneActiveData = data.records or {}
	end
	self:setRuneActiveDataCfg()
	Dispatcher.dispatchEvent(EventType.TwistRuneView_refresh)
	self:redCheck()
end


function TwistRuneModel:getRuneActiveData(pageIndex)

	local pageData=self.giftData[pageIndex]
	
	printTable(5656,pageData)
  
	
	

	local keys ={
		{key = "state",asc = false},
		{key = "id",asc = false},
	}
	TableUtil.sortByMap(pageData, keys)
	
	return pageData
end


function TwistRuneModel:redCheck()
	GlobalUtil.delayCallOnce("EquipTargetModel:redCheck",function()
			self:updateRed()
		end, self, 0.1)
end



function TwistRuneModel:setRuneActiveDataCfg()
	if TableUtil.GetTableLen(self.giftData) == 0 then
		local moduleId = ActivityModel:getModuleIdByActivityType( GameDef.ActivityType.RuneMission )
		self.giftData = DynamicConfigData.t_runeMissionActivity[moduleId]
	end
	local keyArr1 = {}
	for i, v in pairs(self.giftData) do
		--local keyArr2 = {}
		for k,v in pairs(self.giftData[i]) do
			v.acc   = 0
			if self.RuneActiveData and self.RuneActiveData[v.id] then
				v.acc   = self.RuneActiveData[v.id].acc or 0
				if (self.RuneActiveData[v.id].finish) then
					if (not self.RuneActiveData[v.id].got) then
						v.state = 0
					else
						v.state = 2
					end
				else
					v.state = 1
				end
			else
				v.state = 1
			end
		  --table.insert(keyArr2, "V_ACTIVITY_"..GameDef.ActivityType.RuneMission.. i .. v.id)
		end
		table.insert(keyArr1, "V_ACTIVITY_"..GameDef.ActivityType.RuneMission .. i)
		--RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.RuneMission .. i, keyArr2)
	end
	RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.RuneMission, keyArr1)
	
end


function TwistRuneModel:getRuneActiveDataCfg()
	local keysValus = {}
	for k, v in pairs(self.giftData) do
         table.insert(keysValus,k)
	end
	
	table.sort(keysValus,function (a,b)
			return a<b
	end)
	return self.giftData,keysValus
end




function TwistRuneModel:updateRed()
    local haveReward=false
	if self.giftData then
		for i, v in pairs(self.giftData) do
			local pageRed=false
			for k,v in pairs(self.giftData[i]) do
				v.acc   = 0
				if self.RuneActiveData and self.RuneActiveData[v.id] then
					v.acc   = self.RuneActiveData[v.id].acc or 0
					if (self.RuneActiveData[v.id].finish) then
						if (not self.RuneActiveData[v.id].got) then
							pageRed=true
							haveReward=true
						end

					end

				end
			end
			RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.RuneMission..i, pageRed)
		end
	end
	RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.RuneMission, haveReward)
end




function TwistRuneModel:getTaskData(moduleId, type)
	return  DynamicConfigData.t_runeMissionActivity[moduleId][type]
end









return TwistRuneModel
