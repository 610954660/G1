-- added by zn
-- 转盘配置读取器

local MoneyBuyGiftConfger = {};
local configs = {};

-- 根据id获取数据
function MoneyBuyGiftConfger.getDataByID(ID)
    MoneyBuyGiftConfger.initConf();
    return configs[ID];
end

function MoneyBuyGiftConfger.getAllConf()
    MoneyBuyGiftConfger.initConf();
    return configs;
end

function MoneyBuyGiftConfger.getConfCountByType(type)
    if (type == 1) then -- 每日
        return TableUtil.GetTableLen(DynamicConfigData.t_MBDayGift)
    elseif (type == 2) then -- 每周
        return TableUtil.GetTableLen(DynamicConfigData.t_MBWeekGift)
    elseif (type == 3) then -- 每月
        return TableUtil.GetTableLen(DynamicConfigData.t_MBMonthGift)
    elseif type == 4 then
        return TableUtil.getTableLen(DynamicConfigData.t_MBOnlyNewServerGift) -- 新服专享礼包
    end
    return 0;
end

function MoneyBuyGiftConfger.initConf()
    if (#configs == 0) then
        for k, v in pairs(DynamicConfigData.t_MBDayGift) do
            configs[k] = v;
        end
        for k, v in pairs(DynamicConfigData.t_MBWeekGift) do
            configs[k] = v;
        end
        for k, v in pairs(DynamicConfigData.t_MBMonthGift) do
            configs[k] = v;
        end
        for k, v in pairs(DynamicConfigData.t_MBOnlyNewServerGift) do -- 新服专享礼包
            configs[k] = v;
        end
    end
end

return MoneyBuyGiftConfger