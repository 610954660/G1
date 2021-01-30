
-- added by zn
-- 委托任务配置

local DelegateConfiger = {};

function DelegateConfiger.getConfByID(id)
    local conf = DynamicConfigData.t_Delegate;
    return conf[id];
end

function DelegateConfiger.getMaxPointByLevel(level)
    local conf = DynamicConfigData.t_Integration;
    for i = #conf, 1, -1 do
        if (level >= conf[i].roleLevel) then
            return conf[i].limit;
        end
    end
    return conf[1].limit;
end

return DelegateConfiger