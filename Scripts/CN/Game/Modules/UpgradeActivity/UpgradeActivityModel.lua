
-- added by zn
-- 限时升级活动

local BaseModel = require "Game.FMVC.Core.BaseModel";
local UpgradeActivityModel = class("UpgradeActivityModel", BaseModel)

function UpgradeActivityModel:ctor()
    self.data = false;
    self.endMs = 0;
    self:initDataWithConf();
    self.soldCountList = false;
    self.timer = false;
end

function UpgradeActivityModel:loginPlayerDataFinish(data)
    local getFinish = function ()
        self:getServerRewardCount();
    end
    self.timer = Scheduler.schedule(getFinish, 30);
end

function UpgradeActivityModel:upData(data)
    for idx, sv in ipairs(self.data) do
        self.data[idx].state = 1;
        for k, v in pairs(data) do
            if (sv.id == v.id) then
                if (type(v.recvState) == 'boolean') then
                    self.data[idx].state = v.recvState and 0 or 3;
                    break;
                end
            end
        end
    end
    if (not self.soldCountList) then
        self:getServerRewardCount();
    end
    self:upFinished();
    self:checkRed();
    TableUtil.sortByMap(self.data, {{key="state", asc=false}, {key="id", asc=false}});
    Dispatcher.dispatchEvent(EventType.UpgradeActivity_upView);
end

-- state = 1 未达成 0 可领取 2 已领取
function UpgradeActivityModel: initDataWithConf()
    self.data = {};
    local conf = DynamicConfigData.t_ActiveLevelUp;
    for k, v in ipairs(conf) do
        self.data[v.id] = v;
        self.data[v.id].state = 1;
    end
end

function UpgradeActivityModel: getAward(id)
    local info = {
        id = id;
    }
    RPCReq.Activity_FastUpLevel_RecvReward(info);
end

function UpgradeActivityModel: getServerRewardCount()
    if (not ActivityModel:getActityByModuleId(ModuleId.UpgradeActivity.id)) then
        return;
    end
    RPCReq.Activity_FastUpLevel_GetFinishRoleCount({}, function (param)
        self.soldCountList = param.hasFinish;
        self:upFinished();
        self:checkRed();
        TableUtil.sortByMap(self.data, {{key="state", asc=false}, {key="id", asc=false}});
        Dispatcher.dispatchEvent(EventType.UpgradeActivity_upView);
    end)
end

function UpgradeActivityModel: checkRed()
    local actRed = false;
    for idx, sv in ipairs(self.data) do
        if (self.data[idx].state == 0) then
            RedManager.updateValue("V_UPGRADE_ACTIVITY_"..sv.id, true);
            actRed = true;
        else
            RedManager.updateValue("V_UPGRADE_ACTIVITY_"..sv.id, false);
        end
    end
    RedManager.updateValue("V_ACTIVITY_"..GameDef.ActivityType.FastUpLevel, actRed);
end

function UpgradeActivityModel: upFinished()
    if (self.soldCountList) then
        for _, sv in ipairs(self.data) do
            local hasFinish = self.soldCountList[sv.count];
            if (sv.state == 1 and hasFinish and hasFinish.hasFinishedAmount >= sv.getTime) then
                sv.state = 2;
            else
                local had = hasFinish and hasFinish.hasFinishedAmount or 0
                sv.leaveCount = math.max(sv.getTime - had, 0);
            end
        end
    end
end

return UpgradeActivityModel;