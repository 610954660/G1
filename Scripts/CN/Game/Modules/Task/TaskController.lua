--added by xhd
--任务控制器
local TaskController = class("TaskController",Controller)
local gamePlayType1 = GameDef.GamePlayType.TaskMain
local gamePlayType2 = GameDef.GamePlayType.TaskDaily
local gamePlayType3 = GameDef.GamePlayType.TaskWeekly
function TaskController:init()
end

--等级更新监听
function TaskController:onLevel_change(  )
	self:checkRedDot()
end

--红点检测
function TaskController:checkRedDot( ... )
	local taskData = ModelManager.TaskModel:getTaskData()
	if not taskData then
		return
	end

	local t = {}
    for recordId, data in pairs(taskData) do
        local c_achieveConfigs = AchieveConfiger.getAchieveIdConfig(recordId)
        local showRedDot = false
        for k, v in ipairs(c_achieveConfigs) do
            if Cache.achieveCache:getRewardStatus(achieveId, v.seq) == 1 then
                showRedDot = true
                break
            end
        end
        local tabIndex = c_achieveConfigs[1].tabIndex
        local indexInTab = c_achieveConfigs[1].indexInTab

        local tt = t[tabIndex]
        if not tt then
            tt = {}
            t[tabIndex] = tt
        end
        tt[indexInTab] = tt[indexInTab] or showRedDot
    end
end

--服务器协议监听  完成状态 更新
function TaskController:Record_SyncProgress( _,params )
	-- printTable(1,"Record_SyncProgress",params)
    --if params.gamePlayType == GameDef.GamePlayType.TaskAchieve then
		--if params.finish then
			----printTable(5656,"Record_SyncProgress",params)
		--end
    --end
	ModelManager.TaskModel:updateProgress(params.gamePlayType,params)
end

--服务器协议监听 领取状态 更新
function TaskController:Record_SyncRewardStatus( _,params )
    -- print(1,"Record_SyncRewardStatus")
    -- printTable(1,params)
	ModelManager.TaskModel:updateRewardStatus(params.gamePlayType,params)
end
--服务器协议监听 更新指定活跃度数据
function TaskController:ActiveScore_UpdateData( _,params )
   -- print(5656,"ActiveScore_UpdateData")
    -- printTable(1,params)
    ModelManager.TaskModel:updateActivScore(params.dataMap)
end



--凌晨时更新日常周常任务进度
function TaskController:Task_UpdateTaskCategoryData( _,params )
    --print(5656,"Task_UpdateTaskCategoryData")
    -- printTable(1,params)
    ModelManager.TaskModel:updateActivTaskCategoryData(params.taskData)
end
return TaskController