
local HeroConfiger = require "Game.ConfigReaders.HeroConfiger";
local EquipTargetModel = class("EquipTargetModel",BaseModel)

function EquipTargetModel:ctor()
    self.EquipTargetData = {}
    self.giftData = {}
    self.pageIndex = 1
    self.jump = false -- 界面跳转
end

function EquipTargetModel:initData(data)
    if data and data.records then
        self.EquipTargetData = data.records or {}
    end
    --self:setEquipTargetDataCfg()
    Dispatcher.dispatchEvent(EventType.EquipTargetView_refreshPanal)
    self:redCheck()
end

function EquipTargetModel:getEquipTargetData()
    return self.EquipTargetData
end

function EquipTargetModel:redCheck()
	GlobalUtil.delayCallOnce("EquipTargetModel:redCheck",function()
		self:updateRed()
	end, self, 0.1)
end

function EquipTargetModel:initDataCfg()
    if TableUtil.GetTableLen(self.giftData) == 0 then
		local moduleId = ActivityModel:getModuleIdByActivityType( GameDef.ActivityType.EquipMission )
        self.giftData = DynamicConfigData.t_EquipMissionActivity[moduleId]
    end
 

    for i = 1,TableUtil.GetTableLen(self.giftData) do
        for k,v in pairs(self.giftData[i]) do
            v.acc   = 0
            if self.EquipTargetData and self.EquipTargetData[v.id] then
                v.acc   = self.EquipTargetData[v.id].acc or 0
                if (self.EquipTargetData[v.id].finish) then
                  if (not self.EquipTargetData[v.id].got) then
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
        end
    end
    -- printTable(8848,">>>self.giftData[i]>>",self.giftData[1])
end

function EquipTargetModel:getEquipTargetDataCfg()
	self:initDataCfg()
    local tempData = {}
    -- for i = 1,TableUtil.GetTableLen(self.giftData) do
    --     local keys ={
	-- 		{key = "state",asc = false},
	-- 		{key = "id",asc = false},
    --     }
    --     TableUtil.sortByMap(self.giftData[i], keys)
    -- end
    for i =1,TableUtil.GetTableLen(self.giftData) do
        if not tempData[i] then tempData[i]={} end
        for k,v in pairs(self.giftData[i]) do
            table.insert(tempData[i],v)
        end
    end
    for i = 1,TableUtil.GetTableLen(tempData) do
        local keys ={
			{key = "state",asc = false},
			{key = "id",asc = false},
        }
        TableUtil.sortByMap(tempData[i], keys)
    end
    -- printTable(8848,">>tempData>>",tempData)
    return tempData
end

function EquipTargetModel:updateRed()
	self:initDataCfg()
    local keyArr1 = {}
	local moduleId = ActivityModel:getModuleIdByActivityType( GameDef.ActivityType.EquipMission )
    local giftData = DynamicConfigData.t_EquipMissionActivity[moduleId]
    for i = 1,TableUtil.GetTableLen(giftData) do
        local keyArr2 = {}
        for k,v in pairs(giftData[i]) do
            table.insert(keyArr2, "V_ACTIVITY_"..GameDef.ActivityType.EquipMission.. i .. v.id)
        end
        table.insert(keyArr1, "V_ACTIVITY_"..GameDef.ActivityType.EquipMission .. i)
		RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.EquipMission .. i, keyArr2)
    end
    RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.EquipMission, keyArr1)

    for i = 1,TableUtil.GetTableLen(giftData) do
        for k,v in pairs(giftData[i]) do
            if (self.EquipTargetData[v.id]) and (self.EquipTargetData[v.id].finish) and (not self.EquipTargetData[v.id].got) then
                RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.EquipMission.. i .. v.id, true)
            else
                RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.EquipMission.. i .. v.id, false)
            end
        end
    end
end

function EquipTargetModel:getEquipTargetOpenId(moduleId)
    local openId = false
    if moduleId == 144 then
        openId = 140
    end
    return openId
end

return EquipTargetModel