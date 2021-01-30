
local UpgradeActivityController = class("UpgradeActivityController", Controller);

function UpgradeActivityController: Activity_UpdateData(_, param)
    if param.type == GameDef.ActivityType.FastUpLevel then
        UpgradeActivityModel:upData(param.fastUpLevel.recvList);
        local d = ActivityModel.actData;
        for _, data in pairs(d) do
            if data.type == GameDef.ActivityType.FastUpLevel then
                UpgradeActivityModel.endMs = data.realEndMs;
            end
        end
    end
end

-- function UpgradeActivityController: Activity_FastUpLevel_RecvReward(param)
--     LuaLogE("--------- 限时升级活动 -------");
--     printTable(1, param);
-- end

return UpgradeActivityController;