
-- added by zn
-- 转盘配置读取器

local TurnTableConfiger = {}

-- poolID 奖池id  idx 奖池位置 
function TurnTableConfiger.getTableAwards(poolID)
    if (not poolID) then
        -- LuaLogE("奖池id为空");
        return;
    end
    -- LuaLogE("奖池id", poolID);
    local conf = DynamicConfigData.t_TurnTableRewardPool;
    if not conf then
        conf = require "Configs.Generate.t_TurnTableRewardPool";
    end
    local list = {}
    for key in ipairs(conf[poolID]) do
        table.insert(list, conf[poolID][key]["rewardList"][1]);
    end
    return list;
end

-- 获取某种转盘的配置 -1 普通转盘 2 高级转盘
function TurnTableConfiger.getTableInfoByType(tableType)
    local conf = DynamicConfigData.t_TurnTableType;
    if not conf then 
        conf = require "Configs.Generate.t_TurnTableType";
    end
    return conf[tableType]
end

-- 获取宝箱奖励配置 
function TurnTableConfiger.getScoreBoxListByType(tableType)
    local conf = DynamicConfigData.t_TurnTablePointItem;
    local list = {}
    for key in ipairs(conf[tableType]) do
        table.insert(list, conf[tableType][key]);
    end
    return list;
end

return TurnTableConfiger