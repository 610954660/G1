
local ElvesSystemController = class("ElvesSystemController",Controller)


-- 获取所有精灵 和方案配置
function ElvesSystemController:Elf_AllInfo(_,params)
    -- printTable(8848,"Elf_AllInfo>>>>>>>>",params)
    ModelManager.ElvesSystemModel:initElvesData(params)
end

-- 精灵数据更新 1 升级 2 升星 3 经验 4 添加
function ElvesSystemController:Elf_Update(_,params)
    -- printTable(8848,"Elf_Update>>>>>>>>",params)
    ModelManager.ElvesSystemModel:elvesUpdate(params)
end

function ElvesSystemController:Limit_ConsumeTimes( _,data)
    if data.type == GameDef.GamePlayType.Elf then
		ElvesSystemModel:addLimitNum(data.times or 1)
	end
end
function ElvesSystemController:Limit_ResetInfos(_,data)
    if type(data.limit) == "number" then
        ElvesSystemModel:setLimitNum(data.limit)
    end
end


return ElvesSystemController