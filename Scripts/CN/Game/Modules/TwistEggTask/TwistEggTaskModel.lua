
local TwistEggTaskModel = class("TwistEggTaskModel",BaseModel)

function TwistEggTaskModel:ctor()
    self.taskState = {}
end

function TwistEggTaskModel:initData(data)
    self.taskState = data.records or {}
    self:updateRed()
    Dispatcher.dispatchEvent(EventType.TwistEggTask_refreshPanal)
end

function TwistEggTaskModel:updateStateFinishAndAcc(data)
    if data then
        if not self.taskState[data.recordId] then
            self.taskState[data.recordId]= {}
        end
        if data.finish then
            self.taskState[data.recordId].finish = data.finish
        end
        if data.acc then
            self.taskState[data.recordId].acc = data.acc
        end
    end
    self:updateRed()
    Dispatcher.dispatchEvent(EventType.TwistEggTask_refreshPanal)
end

function TwistEggTaskModel:updateStateGot(data)
    if data then
        if not self.taskState[data.recordId] then
            self.taskState[data.recordId]= {}
        end
        if data.got then
            self.taskState[data.recordId].got = data.got
        end
    end
    self:updateRed()
    Dispatcher.dispatchEvent(EventType.TwistEggTask_refreshPanal)
end

function TwistEggTaskModel:getModuleId()
	local moduleId = 1
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.GashaponTask)
	moduleId = actData and actData.showContent.moduleId or 1
	-- printTable(8848,">>actData>>",actData)
	return moduleId
end

-- 总任务进度数据（单独一条）
function TwistEggTaskModel:getAllTaskData()
    local moduleId = self:getModuleId()
    local taskData = DynamicConfigData.t_CapsuleToysMission[moduleId]
    -- 添加任务完成情况
    for k,v in pairs(taskData) do
        local data = self.taskState[v.id]
        v.acc = 0
        v.state = 1  -- 0 可领取 1 前往 2 已领取
        if data then
            v.acc = data.acc or 0
            if data.finish then
                v.state = (not data.got) and 0 or 2
            end
        end
        if v.id == 1 then
            return v
        end
    end
end

-- 任务列表数据（id为1的单独拿出来）
function TwistEggTaskModel:getTaskData()
    local moduleId = self:getModuleId()
    local taskData = DynamicConfigData.t_CapsuleToysMission[moduleId]
    local tempData = {}
    -- 添加任务完成情况
    for k,v in pairs(taskData) do
        local data = self.taskState[v.id]
        v.acc = 0
        v.state = 1  -- 0 可领取 1 前往 2 已领取
        if data then
            v.acc = data.acc or 0
            if data.finish then
                v.state = (not data.got) and 0 or 2
            end
        end
        if v.id ~= 1 then
            table.insert(tempData,v)
        end
    end
    local keys ={
        {key = "state",asc = false},
        {key = "id",asc = false},
    }
    TableUtil.sortByMap(tempData, keys)
    return tempData or {}
end

function TwistEggTaskModel:updateRed()
    local taskData = self:getTaskData()
    local toltalTaskData = self:getAllTaskData()
    local keyArr = {}
    for k,v in pairs(taskData) do
        table.insert(keyArr, "V_ACTIVITY_"..GameDef.ActivityType.GashaponTask..v.id)
    end
    table.insert(keyArr, "V_ACTIVITY_"..GameDef.ActivityType.GashaponTask..toltalTaskData.id)
    RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.GashaponTask, keyArr)
    for k,v in pairs(taskData) do
        RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.GashaponTask.. v.id, v.state == 0)
    end
    RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.GashaponTask.. toltalTaskData.id, toltalTaskData.state == 0)
end


return TwistEggTaskModel
