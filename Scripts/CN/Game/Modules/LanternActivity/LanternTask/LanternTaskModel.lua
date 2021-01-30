
local LanternTaskModel = class("LanternTaskModel",BaseModel)

function LanternTaskModel:ctor()
    self.taskState = {}
end

function LanternTaskModel:initData(data)
    self.taskState = data.records or {}
    self:updateRed()
    Dispatcher.dispatchEvent(EventType.LanternTask_refreshPanal)
end

function LanternTaskModel:updateStateFinishAndAcc(data)
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
    Dispatcher.dispatchEvent(EventType.LanternTask_refreshPanal)
end

function LanternTaskModel:updateStateGot(data)
    if data then
        if not self.taskState[data.recordId] then
            self.taskState[data.recordId]= {}
        end
        if data.got then
            self.taskState[data.recordId].got = data.got
        end
    end
    self:updateRed()
    Dispatcher.dispatchEvent(EventType.LanternTask_refreshPanal)
end

function LanternTaskModel:getModuleId()
	local moduleId = 1
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.LanternTask)
	moduleId = actData and actData.showContent.moduleId or 1
	return moduleId
end

-- 总任务进度数据（单独一条）
function LanternTaskModel:getAllTaskData()
    local moduleId = self:getModuleId()
    local taskData = DynamicConfigData.t_LanternMission[moduleId]
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
function LanternTaskModel:getTaskData()
    local moduleId = self:getModuleId()
    local taskData = DynamicConfigData.t_LanternMission[moduleId]
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

function LanternTaskModel:updateRed()
    local taskData = self:getTaskData()
    local toltalTaskData = self:getAllTaskData()
    local keyArr = {}
    for k,v in pairs(taskData) do
        table.insert(keyArr, "V_ACTIVITY_"..GameDef.ActivityType.LanternTask..v.id)
    end
    table.insert(keyArr, "V_ACTIVITY_"..GameDef.ActivityType.LanternTask..toltalTaskData.id)
    RedManager.addMap("V_ACTIVITY_"..GameDef.ActivityType.LanternTask, keyArr)
    for k,v in pairs(taskData) do
        RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.LanternTask.. v.id, v.state == 0)
    end
    RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.LanternTask.. toltalTaskData.id, toltalTaskData.state == 0)
end


return LanternTaskModel
