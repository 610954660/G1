--added by xhd
--任务配置读取器
local TaskConfiger = {}
local dict = {}
local dictShowConfig = {}
local dailyShowConfig = {}
local weekShowConfig = {}
local achievementConfig = {}
local worldTeamAreanConfig = {}

function TaskConfiger.getAllConfig()
	dict = DynamicConfigData.t_task
    if not dict then
        dict = require "Configs.Generate.t_task"
    end
    return dict
end

function TaskConfiger.getAllTaskGroupConfig()
	
    dict = DynamicConfigData.t_taskGroupMap
    if not dict then
        dict = require "Configs.Generate.t_taskGroupMap"
    end
    return dict
end

function TaskConfiger.getConfigById(recordId,id)
    local config = TaskConfiger.getAllConfig()
    if config[recordId] then
        for i,v in ipairs(config[recordId]) do
            if v.id == id then
                return v
            end
        end
    end
end

function TaskConfiger.getAllDailyConfig(  )
	dict = DynamicConfigData.t_taskDaily
    if not dict then
        dict = require "Configs.Generate.t_taskDaily"
    end
    return dict
end

function TaskConfiger.getAllWeekConfig(  )
	dict = DynamicConfigData.t_taskWeekly
    if not dict then
        dict = require "Configs.Generate.t_taskWeekly"
    end
    return dict
end

function TaskConfiger.getAllWorldTeamConfig(  )
	dict = DynamicConfigData.t_TaskWorldTeamArena
    if not dict then
        dict = require "Configs.Generate.t_TaskWorldTeamArena"
    end
    return dict
end

function TaskConfiger.getAllAchieveConfig(  )
	dict = DynamicConfigData.t_taskAchieve
	if not dict then
		dict = require "Configs.Generate.t_taskAchieve"
	end
	return dict
end


function TaskConfiger.getActiveScoreConfig( gamePlay )
	dict = DynamicConfigData.t_activeScoreReward
    if not dict then
        dict = require "Configs.Generate.t_activeScoreReward"
    end
    return dict[gamePlay]
end

function TaskConfiger.getActiConfig( gamePlay,index )
	local config = TaskConfiger.getActiveScoreConfig(gamePlay)
	return config[index]
end

--获取显示的任务列表
function TaskConfiger.getShowTable(category)
	if category ==GameDef.TaskCategory.Main then
		return dictShowConfig
	elseif category ==GameDef.TaskCategory.Achieve then
        return achievementConfig
	end
end

function TaskConfiger.getDailyShowTable( ... )
   return dailyShowConfig
end

function TaskConfiger.getWeekShowTable( ... )
   return weekShowConfig
end

function TaskConfiger.getAchievementTable( ... )
	return achievementConfig
end

function TaskConfiger.getWorldTeamAreanTable( ... )
	return worldTeamAreanConfig
end


function TaskConfiger.initShowConfig( ... )
	dictShowConfig = {}
end

function TaskConfiger.initDailyShowConfig( ... )
	dailyShowConfig = {}
end

function TaskConfiger.initWeekShowConfig( ... )
	weekShowConfig = {}
end


function TaskConfiger.initAchievementConfig( ... )
	achievementConfig = {}
end

function TaskConfiger.initWorldTeamAreanConfig( ... )
	worldTeamAreanConfig = {}
end


--获取当前等级对应显示的数据
function TaskConfiger.insertShowTable( v,category)
	
	if category ==GameDef.TaskCategory.Main then
		table.insert(dictShowConfig,v)
	elseif category ==GameDef.TaskCategory.Achieve then
        table.insert(achievementConfig,v)
	end

end

function TaskConfiger.insertDailyShowTable( v )
	table.insert(dailyShowConfig,v)
end

function TaskConfiger.insertWeekShowTable( v )
	table.insert(weekShowConfig,v)
end

function TaskConfiger.insertWorldTeamShowTable(v)
    table.insert(worldTeamAreanConfig,v)
end


return TaskConfiger