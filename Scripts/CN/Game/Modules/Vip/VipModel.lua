
-- added by zn
-- vip系统

local VipModel = class("VipModel", BaseModel);
local ModuleType = GameDef.ModuleType

function VipModel:ctor()
    self.level = -1;
    self.exp = 0;
    self.dataList = false;
    self.data = false;
    self.vipDailyMark = false;
    self.vipGiftMark = false;
    self.schedulerID = false;
    self:initListeners();
    self.costList = false;
end

function VipModel:Vip_AllData(_, param)
    self:initData(param.data)
end

function VipModel:initData(param)
   -- printTable(1, "-=-=-= vip数据更新 -=-=-=", param);
    if (self.level ~= param.vipLv) then
        local old = self.level;
        self.level = param.vipLv;
        if (old ~= -1) then -- 只要不是初始化等级产生的变化都弹升级
            self:openUpLevelView(old, param.vipLv);
			Dispatcher.dispatchEvent(EventType.module_check, ModuleType.Vip , param.vipLv)
			SDKUtil.recordRoleInfo(AgentConfiger.SDK_RECORD_VIP_UPDATE)  --上报信息给sdk
			Dispatcher.dispatchEvent("Vip_UpLevel");
        else
            Dispatcher.dispatchEvent("Vip_UpLevel");
        end
    end
    self.exp = param.vipExp;
    self.vipDailyMark = param.vipDailyMark or 0;
    self.vipGiftMark = param.vipGiftMark or 0;
    self:checkRedDot();
    Dispatcher.dispatchEvent("Vip_UpView");
end

-- 获取能显示的vip条目
function VipModel:getAllVipTab()
    local allConf = DynamicConfigData.t_Vip;
    local arr = {};
    for id,conf in ipairs(allConf) do
        if (conf.vipShow <= self.level) then
            table.insert(arr, conf);
        end
    end
    return arr;
end

-- 领取每日奖励
function VipModel:receiveDaily(level)
    level = level or self.level
    LuaLogE(DescAuto[347], level); -- [347]="领取VIP每日礼包"
    RPCReq.Vip_ReceiveDaily({level=level}, function (param)
        -- printTable(2233, "领取VIP每日礼包返回", param);
    end)
end

-- 领取等级礼包
function VipModel:receiveLevelGift(level)
    level = level or self.level
    if (level > self.level) then
        RollTips.show(Desc.vip_notEnoughLv);
        return;
    end
    LuaLogE(DescAuto[348], level); -- [348]="领取VIP等级礼包"
    RPCReq.Vip_ReceiveLevelGift({level=level}, function (param)
        -- printTable(2233, "领取VIP等级礼包返回", param);
    end)
end

-- 获取每日奖励/礼包状态
function VipModel:getMarkStatus(vipLv, markType)
    vipLv = vipLv or self.level;
    -- if (vipLv > self.level) then 
    --     return true;
    -- end
    markType = type(markType) == 'number' and markType or 1;
    local mark = false;
    if (markType == 1) then
        mark = self.vipDailyMark;
    elseif (markType == 2) then
        mark = self.vipGiftMark;
    end
    local flag = bit.band(mark, bit.lshift(1, vipLv - 1)) > 0;
    return flag;
end

-- 获取特权描述  vip界面展示
function VipModel:getPriviligeType(priviligeType, vipLevel)
    vipLevel = vipLevel or self.level;
    -- local vipConf = DynamicConfigData.t_Vip;
    local vipPriConf = DynamicConfigData.t_VipPriviligeType;
    local conf = vipPriConf[priviligeType][vipLevel];
    return conf;
    -- if (vipLevel <= self.level) then -- 已激活
    --     return str;
    -- else -- 未激活
    --     local preLv = math.max(vipLevel - 1, 1);
    --     local flag = false -- true 是次数改变
    --     for _, type in pairs(vipConf[preLv].vipType) do
    --         if (type == priviligeType) then
    --             flag = true;
    --             break;
    --         end
    --     end
    --     if (flag) then -- 次数改变
    --         local newEff = string.format(Desc.vip_unActivePrivilige, string.match(str, "+%d+"));
    --         local m = string.gsub(str, "+%d+", newEff, 1);
    --         return m
    --     else
    --         return string.format(Desc.vip_unActivePrivilige, str);
    --     end
    -- end
end

function VipModel:checkRedDot(level)
    local key = {};
    for i = 1, #(DynamicConfigData.t_Vip) do
        table.insert(key, "V_VIP_"..i);
        RedManager.updateValue("V_VIP_"..i, false);
    end
    RedManager.addMap("V_VIP", key);
    if (level) then -- 升级新的vip红点
        RedManager.updateValue("V_VIP_"..level, true);
    elseif (self.level > 0) then -- 每日礼包红点
        for i = 1, self.level do 
            local flag = self:getMarkStatus(i, 1);
            RedManager.updateValue("V_VIP_"..i, not flag);
        end
    end
end

-- 获取当前等级VIP特权
function VipModel:getVipPrivilige(priType)
    if (self.level == 0) then
        return 0;
    end
    local conf = DynamicConfigData.t_VipPriviligeType[priType];
    if (conf) then
        local count = conf[self.level].effect;
        if (count and count > 0) then
            return count;
        end
    end
    return 0;
end

function VipModel:openUpLevelView(oldLv, newLv)
    Scheduler.unschedule(self.schedulerID)
	self.schedulerID = Scheduler.schedule(function()
        if ViewManager.getView("BattleBeginView") then return end
        if ViewManager.getView("ReWardView") then return end
        if ViewManager.getView("AwardShowView") then return end
        if ViewManager.getView("AwardView") then return end
        if ViewManager.getView("UpgradeView") then return end
        if PlayerModel:get_awardData() then return end
        ViewManager.open("VipUpLevelView", {oldLv = oldLv, newLv = newLv});
        Scheduler.unschedule(self.schedulerID)
        self.schedulerID = false;
	end,0.2)
end

function VipModel:getTotalCost(lv)
    -- if (not self.costList) then
    --     self.costList = {}
    --     local conf = DynamicConfigData.t_Vip;
    --     for _, c in ipairs(conf) do
    --         table.insert(self.costList, c.vipExp)
    --     end
    -- end
    -- local num = 0
    -- for i = 1, lv do
    --     num = num + self.costList[i]
    -- end
    local conf = DynamicConfigData.t_Vip[lv];
    if (conf) then
        return conf.vipExp
    end
    return 0;
end

return VipModel;
