-- add by zn
-- 圣器系统

local HallowSysModel = class("HallowSysModel", BaseModel)

function HallowSysModel:ctor()
    self:initListeners()
    self.sysInfo = false; -- 系统信息
    self.baseSeatLv = 0; -- 基座等级
    self.hallowMap = {}; -- 圣器表
    self.initRedMap = false; 
end

function HallowSysModel:public_enterGame()
    self:getSysInfo(false);
end

-- 获取系统信息
function HallowSysModel:getSysInfo(needExtraInfo)
    local info = {
        isOpen = needExtraInfo
    }
    RPCReq.Hallow_GetInfo(info, function (param)
        self.sysInfo = param.data;
        self.baseSeatLv = self.sysInfo.hallowBaseLevel;
        self.hallowMap = self.sysInfo.hallowTypeMap;
        -- if (param.isShow) then
        --     ViewManager.open("HallowPointView");
        -- end
        self:checkRed()
        Dispatcher.dispatchEvent(EventType.Hallow_sysInfoUpdate, param.data, param.isShow);
    end)
end

-- 获取基座的当前等级和下级配置
function HallowSysModel:getBaseSeatConf(curLv)
    curLv = curLv or self.baseSeatLv;
    local curConf = false;
    local nextConf = false;
    local conf = DynamicConfigData.t_HallowStandard;
    if (curLv ~= 0) then
        curConf = conf[curLv]
    end
    if (curLv + 1 <= #conf) then
        nextConf = conf[curLv + 1];
    end
    return curConf, nextConf;
end

-- 升级基座
function HallowSysModel:upBaseSeat()
    -- 消耗材料判断
    local curConf, nextConf = self:getBaseSeatConf();
    if (not nextConf) then return end;
    if (self.sysInfo.point < nextConf.lvUpCost) then
        -- ViewManager.open("ItemNotEnoughView", {type = CodeType.MONEY, code = 17, amount=0})
        RollTips.show(Desc.Hallow_notEnoughPoint);
        return;
    end

    RPCReq.Hallow_UpBaseLevel({}, function (param)
        print(2233, "================ 基座升级");
        self.sysInfo = param.data;
        self.baseSeatLv = self.sysInfo.hallowBaseLevel;
        self.hallowMap = self.sysInfo.hallowTypeMap;
        Dispatcher.dispatchEvent(EventType.Hallow_sysInfoUpdate, param.data);
        if (param.addCombat) then
            RollTips.showAddFightPoint(param.addCombat)
        end
        self:checkRed()
    end)
end

-- 升级圣器
function HallowSysModel:upHallow(hallowType, cb)
    -- 消耗材料判断
    if (not self.hallowMap[hallowType]) then return end
    local lv = self.hallowMap[hallowType].level;
    local conf = DynamicConfigData.t_HallowLevel[hallowType][lv];
    if (not conf or not PlayerModel:isCostEnough(conf.lvUpCost, true)) then
        return
    end

    local info = {
        hallowType = hallowType
    }
    RPCReq.Hallow_UpLevel(info, function (param)
        print(2233, "================= 圣器升级");
        self.sysInfo = param.data;
        self.baseSeatLv = self.sysInfo.hallowBaseLevel;
        self.hallowMap = self.sysInfo.hallowTypeMap;
        Dispatcher.dispatchEvent(EventType.Hallow_sysInfoUpdate, param.data);
        if (param.addCombat) then
            RollTips.showAddFightPoint(param.addCombat)
        end
        if (cb) then
            cb()
        end
        self:checkSkillUnlock(hallowType);
        self:checkRed()
    end)
end

function HallowSysModel:checkCanUp(hallowType, needTips)
    if (not self.hallowMap[hallowType]) then return end
    local lv = self.hallowMap[hallowType].level;
    local conf = DynamicConfigData.t_HallowUpLimit[lv];
    if (not conf) then return true end
    local otherLimit = conf.levelRequest;
    for type, info in pairs(self.hallowMap) do
        if (info.level < otherLimit) then
            if (needTips) then
                RollTips.show(string.format(Desc.Hallow_copydesc13, otherLimit));
            end
            return false;
        end
    end
    return true;
end

function HallowSysModel:checkSkillUnlock(hallowType)
    local hallowLv = self.hallowMap[hallowType].level;
    local preLv = math.max(hallowLv - 1, 1)
    local conf = DynamicConfigData.t_HallowLevel[hallowType];
    if (hallowLv ~= preLv) then
        local curSkill = conf[hallowLv].skill;
        local preSkill = conf[preLv].skill;
        for i = 1, #curSkill do
            if (preSkill[i] == 0 and curSkill[i] ~= 0) then
                ViewManager.open("HallowSkillUnlockView", {skillId = curSkill[i]});
                break;
            end
        end
    end
end


function HallowSysModel:checkRed()
    if (self.hallowMap and #self.hallowMap > 0) then
        local len = #self.hallowMap;
        if (not self.initRedMap) then
            local map = {};
            for i = 1, len do 
                table.insert(map, "V_HALLOW_"..i);
            end
            RedManager.addMap("V_HALLOW", map);
        end
        local hallowConf = DynamicConfigData.t_HallowLevel
        local maxLv = 0;
        for i = 1, len do
            local cLen = #hallowConf[i];
            local lv = self.hallowMap[i].level;
            if (lv ~= cLen) then
                maxLv = math.max(maxLv, lv);
            end
        end
        
		
	
        local baseConf = self:getBaseSeatConf();
        for i = 1, len do
            local lv = self.hallowMap[i].level;
			
			local allReachLv = true --其他圣器是否已经升到相应等级了
			local conf = DynamicConfigData.t_HallowUpLimit[lv];
			if conf then
				local otherLimit = conf.levelRequest;
				for type, info in pairs(self.hallowMap) do
					if (info.level < otherLimit) then
						allReachLv = false 
						break
					end
				end
			end
		
            local flag = false;
            if (lv == maxLv) then
                -- 消耗材料判断
                local conf = hallowConf[i][lv];
                if (conf and PlayerModel:isCostEnough(conf.lvUpCost, false)) then
                    flag = true;
                end
            end
            RedManager.updateValue("V_HALLOW_"..i, allReachLv and flag);
        end
    end
end

function HallowSysModel:getSkillOpenLv(skillId, hallowType)
    local conf = DynamicConfigData.t_HallowLevel[hallowType];
    for _, c in ipairs(conf) do
        local skills = c.skill
        for _, id in ipairs(skills) do
            if (id == skillId) then
                return c.level
            end
        end
    end
    return 0;
end

function HallowSysModel:pack_item_change(_,data)
	GlobalUtil.delayCallOnce("HallowSysModel:pack_item_change", self.checkRed, self, 0.2);
end

return HallowSysModel