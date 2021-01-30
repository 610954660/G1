--[[
    author:zn
    time:2020-08-28 15:50:58
]]
local VoidlandModel = class("VoidlandModel", BaseModel)
local arrPos = {11, 12, 13, 21, 22, 23}
local posToIdx = {
    [11] = 1,
    [12] = 2,
    [13] = 3,
    [21] = 4,
    [22] = 5,
    [23] = 6
}

function VoidlandModel:ctor()
    self.modeType = false -- 1 单人  2 多人
    self.confByPoint = {} -- 配置表  根据关卡波数来 {modeType = { 关卡1= {波1 = conf1, 波2 = conf2}, ...}}
    self.landMap = false
    self:initConf()
    self.singleList = {} -- 单人模式队伍
    self.skillSelect = false -- 技能选择事件
    self.eventId = false -- 产生事件的id
    self.myHireArray = {} -- 我的派遣队列
    -- self.baseCombat = 0; -- 我的最高战力英雄的战力
    self.hireList = {} -- 可雇佣列表
    self.hireCount = 0 -- 雇佣统计
    -- self.singleCombat = 0 -- 单人模式队伍最高战力
    self.schedulerID = false
    self.rewardList = {}
    self.heroIndex = false -- 当前上阵英雄
    self.nextHeroIndex = false -- 下场上阵英雄
    self.curMapId = 1 -- 当前关卡id
    self.listSkillBag = {};
    self:initListeners()
    self.result = false; -- 战斗结果
    self.isFighting = false;
    self.needOutFight = false; -- 跨天跳出战斗
    self.isFirst = false; -- 首通
    self.selectWaitFlag = false;
    self.preHeroMap = {};
    self.clickStart = false;  -- 选择技能结果等待
    self.clickStartId = false;
    self.waitBattle = false  -- 战斗结果等待
    self.waitBattleId = false
end

function VoidlandModel:initConf()
    for i = 1, 2 do
        local conf = i == 1 and DynamicConfigData.t_SingleNode or DynamicConfigData.t_multipleNode
        self.confByPoint[i] = {}
        for _, c in ipairs(conf) do
            self.confByPoint[i][c.nodeId] = self.confByPoint[i][c.nodeId] or {}
            local tab = self.confByPoint[i][c.nodeId]
            tab[c.index] = c
        end
    end
end

function VoidlandModel:loginPlayerDataFinish()
    self:getVoidlandInfo()
end

function VoidlandModel:getVoidlandInfo()
    RPCReq.DreamLand_GetInfo({}, function(param)
            -- printTable(2233, "=============== VoidlandModel:getVoidlandInfo", param)
			if param.data.landMap then
				self.landMap = param.data.landMap
				self:checkRed()
				Dispatcher.dispatchEvent(EventType.Voidland_infoUpdate)
			end
    end)
end

function VoidlandModel:upVoidlandInfo(info, extraInfo)
    self.landMap[info.landType] = info
    self:checkRed()
    Dispatcher.dispatchEvent(EventType.Voidland_infoUpdate, extraInfo);
end

-- 今日开放模式
function VoidlandModel:todayMode()
    local dayInWeek = TimeLib.DayInWeek()
    local mode = dayInWeek % 2 == 1 and 1 or 2
    if (not self.modeType) then
        self.modeType = mode
    end
    return mode
end

-- 获取某一模式关卡配置
function VoidlandModel:getAllConfByPoint()
    return self.confByPoint[self.modeType]
end

function VoidlandModel:getAllWave(modeType)
    self:todayMode()
    modeType = modeType == nil and self.modeType or modeType
    local conf = modeType == 1 and DynamicConfigData.t_SingleNode or DynamicConfigData.t_multipleNode
    return #conf;
end

-- 获取关卡配置信息  默认获取当前可挑战关卡配置信息
function VoidlandModel:getPointInfoById(id, modeType)
	if not self.landMap then return false end
    self:todayMode()
    modeType = modeType == nil and self.modeType or modeType
    local conf = modeType == 1 and DynamicConfigData.t_SingleNode or DynamicConfigData.t_multipleNode
    id = id == nil and self.landMap[modeType].id or id
    id = math.max(1, math.min(id, #conf));
    return conf[id]
end

-- 获取某种模式的数据信息
function VoidlandModel:getCurModeData(modeType)
	if not self.landMap then return false end
    self:todayMode()
    modeType = modeType == nil and self.modeType or modeType
    return self.landMap[modeType]
end

-- 是否是最后一波
function VoidlandModel:isFinalWave(id)
    local conf = self:getPointInfoById(id)
    local nextConf = self:getPointInfoById(id + 1)
    if (conf and (not nextConf or nextConf.nodeId ~= conf.nodeId)) then
        return true
    end
    return false
end

-- 获取最近的首通奖励信息
function VoidlandModel:getNearFirstAward(id, modeType)
    local landInfo = self:getCurModeData(modeType)
    local nearId = id or landInfo.maxId
    local nearData = false
    while (not nearData) do
        local info = self:getPointInfoById(nearId)
        if (self:isFinalWave(nearId) or (info.passReward and #info.passReward > 0)) then
            nearData = info
        else
            nearId = nearId + 1
        end
    end
    return nearData
end

-- 获取某一关的通过奖励信息
function VoidlandModel:getPassRewardByPoint(point, modeType)
    self:todayMode()
    modeType = modeType == nil and self.modeType or modeType
    local data = self.confByPoint[modeType][point]
    if (not data) then
        return false
    end
    local ward = {}
    for _, d in ipairs(data) do
        if (d.passReward and #d.passReward > 0) then
            table.insert(ward, {passReward = d.passReward[1], index = d.index, id = d.id})
        end
    end
    TableUtil.sortByMap(ward, {{key = "index", asc = false}})
    return ward
end

-- 首通奖励状态 1 可领 0 未达成 2 已领
function VoidlandModel:getPassRewardState(id, modeType)
    self:todayMode()
    modeType = modeType == nil and self.modeType or modeType
    local data = self.landMap[modeType]
    local maxId = data.maxId
    local history = data.rewardRecord[id]
    if history then
        return 2
    elseif (id <= maxId) then
        return 1
    end
    return 0
end

function VoidlandModel:getPassReward(id, modeType)
    self:todayMode()
    modeType = modeType == nil and self.modeType or modeType
    local info = {
        landType = modeType,
        id = id
    }
    RPCReq.DreamLand_RecvPassReward(
        info,
        function(param)
            printTable(2233, "========== 领取奖励", param)
            self:upVoidlandInfo(param.data, "award");
        end
    )
end

function VoidlandModel:getCurWave()
    local mapData = self:getCurModeData()
    local mapId = self.curMapId--math.max(mapData.id - 1, 1)
    local conf = self:getPointInfoById(mapId)
    return conf.index
end
-------------------------------------------------------------- 战斗部分

-- 是否是虚空玩法
function VoidlandModel:isVoidlandMode(battleArrayType)
    return battleArrayType == GameDef.BattleArrayType.DreamLandSingle or
        battleArrayType == GameDef.BattleArrayType.DreamLandMultiple
end

function VoidlandModel:getCurBattleType()
    if (self.modeType == 1) then
        return GameDef.BattleArrayType.DreamLandSingle
    elseif (self.modeType == 2) then
        return GameDef.BattleArrayType.DreamLandMultiple
    end
end

function VoidlandModel:upSingleList()
    self.singleList = self.landMap[self.modeType].singleMap or {}
    for idx, single in pairs(self.singleList) do
        if (single and single.uuid) then
            local hero = CardLibModel:getHeroByUid(single.uuid)
            if (hero) then
                single.code = hero.code
            else
                self.singleList[idx] = nil
            end
        end
    end
    -- self:refreashSingleCombat()
end

-- 单人模式队伍添加成员
function VoidlandModel:addSingleListArray(heroInfo)
    for i = 1, 3 do
        if (not self.singleList[i]) then
            self.singleList[i] = {
                uuid = heroInfo.uuid,
                code = heroInfo.code,
                index = i,
				fashionCode = heroInfo.fashionCode
            }
            Dispatcher.dispatchEvent(EventType.Voidland_upSingleList)
            return true
        end
    end
    return false
end

function VoidlandModel:removeSingleListArray(uuid)
    for i = 1, 3 do
        if (self.singleList[i] and self.singleList[i].uuid == uuid) then
            self.singleList[i] = false
            Dispatcher.dispatchEvent(EventType.Voidland_upSingleList)
            break
        end
    end
end

-- function VoidlandModel:refreashSingleCombat()
--     self.singleCombat = 0
--     for i = 1, 3 do
--         if (self.singleList[i]) then
--             local heroInfo = CardLibModel:getHeroByUid(self.singleList[i].uuid)
--             self.singleCombat = math.max(self.singleCombat, heroInfo.combat)
--         end
--     end
-- end

function VoidlandModel:getSingleListCount()
    local count = 0
    for i = 1, 3 do
        if (self.singleList[i]) then
            count = count + 1
        end
    end
    return count
end

function VoidlandModel:isInSingleList(uuid)
    for i = 1, 3 do
        if (self.singleList[i] and self.singleList[i].uuid == uuid) then
            return i
        end
    end
    return false
end

-- 是否有相同的英雄
function VoidlandModel:hasSameHeroInSingleList(heroInfo)
    for i = 1, 3 do
        if (self.singleList[i] and self.singleList[i].code == heroInfo.code) then
            return true
        end
    end
    return false
end

function VoidlandModel:saveSingleList()
    if (self.modeType ~= 1) then
        return;
    end
    local list = {}
    for i = 1, 3 do
        if (self.singleList[i]) then
            list[i] = self.singleList[i]
        end
    end
    -- self:refreashSingleCombat()
    RPCReq.DreamLand_SetSingleList(
        {singleMap = list},
        function(param)
            -- printTable(2233, "=======保存单人队列信息", param);
        end
    )
end

function VoidlandModel:setSelectSkill(skillIdx, cb)
    if (self.selectWaitFlag) then return end;
    self.selectWaitFlag = true;
    local info = {
        landType = self.modeType,
        index = skillIdx
    }
    printTable(2233, "======= 选择技能")
    RPCReq.DreamLand_Choice(info, function(param)
        printTable(2233, "===== 选择了技能结果");
        self:upVoidlandInfo(param.data)
        self.eventId = false;
        if (cb) then
            cb()
        end
        self.selectWaitFlag = false;
    end, function (err)
        self.eventId = false;
        printTable(2233, "======== 选择技能错误", err)
        if (cb) then
            cb()
        end
    end)
end

-- 跳过控制
function VoidlandModel:skipOpen(mid)
    local conf = self:getPointInfoById(self.curMapId)
    local canSkip = true
    local tips = nil
    if (mid == GameDef.BattleArrayType.DreamLandSingle) then
        CardLibModel:setCardsByCategory(0);
        local arr = CardLibModel:getHeroInfoToIndex(true, 3);
        local combat = #arr > 0 and arr[1].combat or 0
        if (conf.combat * 1.2 > combat) then
            tips = Desc.Voidland_notEnoughCombat
        end
    elseif mid == GameDef.BattleArrayType.DreamLandMultiple then
        local combat = CardLibModel:getFightVal();
        if (conf.combat * 1.2 > combat) then
            tips = Desc.Voidland_notEnoughCombat
        end
    end
    return canSkip, tips
end

---------------------------------------------------------------------- 战斗end

---------------------------------------------------------------------- 雇佣相关

-- 获取雇佣列表
function VoidlandModel:getHireList()
    RPCReq.DreamLand_GetHireHeroList(
        {},
        function(param)
            printTable(2233, "===== 雇佣列表", param.data)
            -- CardLibModel:setCardsByCategory(0);
            -- local list = CardLibModel:getHeroInfoToIndex(true, 3);
            -- self.baseCombat = list[1].combat;
            self.hireCount = 0
            self.hireList = {}
            for _, data in pairs(param.data) do
                if (data.isBan) then
                    data.state = 0
                elseif (data.isHire) then
                    data.state = 1
                    self.hireCount = self.hireCount + 1
                else
                    data.state = 2
                end
                table.insert(self.hireList, data)
            end
            TableUtil.sortByMap(self.hireList, {{key = "combat", asc = true}})
            Dispatcher.dispatchEvent(EventType.Voidland_upAssList)
        end
    )
end

-- 雇佣好友英雄
function VoidlandModel:hireFirend(friendId, uuid, idx)
    local info = {
        friendId = friendId,
        uuid = uuid
    }
    RPCReq.DreamLand_HireHero(
        info,
        function(param)
            printTable(2233, "======= 雇佣结果", param.data)
            RollTips.show(Desc.Voidland_assSuc)
            self.hireList[idx].isHire = true
            self.hireList[idx].state = 1
            self.hireCount = self.hireCount + 1
            Dispatcher.dispatchEvent(EventType.Voidland_upAssList)
        end
    )
end

-- 自己的外派列表
function VoidlandModel:getSelfPostHireList()
    RPCReq.DreamLand_GetPostArray(
        {},
        function(param)
            printTable(2233, "===== 外派列表", param)
            self.myHireArray = {}
            for _, data in pairs(param.data) do
                local idx = posToIdx[data.id]
                self.myHireArray[idx] = {
                    uuid = data.uuid,
                    id = data.id
                }
                if (data.isHire) then
                    self.myHireArray[idx].isHire = data.isHire
                end
            end
            Dispatcher.dispatchEvent(EventType.Voidland_upMyHire)
        end
    )
end

-- 添加外派英雄
function VoidlandModel:addMyHire(idx, uuid)
    self.myHireArray[idx] = {
        uuid = uuid,
        id = arrPos[idx]
    }
    Dispatcher.dispatchEvent(EventType.Voidland_upMyHire)
end

-- 移除外派英雄
function VoidlandModel:removeMyHire(idx)
    self.myHireArray[idx] = nil
    Dispatcher.dispatchEvent(EventType.Voidland_upMyHire)
end

-- 保存外派英雄
function VoidlandModel:saveSelfPostHire()
    -- if (TableUtil.GetTableLen(self.myHireArray) == 0) then
    --     return
    -- end
    local info = {
        -- arrayType = GameDef.BattleArrayType.DreamLandPost,
        array = self.myHireArray
    }
    -- ModelManager.BattleModel:requestBattleArrays(GameDef.BattleArrayType.DreamLandPost, self.myHireArray)
    RPCReq.DreamLand_UpdatePostArray(info, function(param)
        printTable(2233, "==== 保存外派阵容", param);
    end)
end

-- 我的所有英雄列表
function VoidlandModel:getMyHeroList(category)
    local exclude = {}
    for _, d in pairs(self.myHireArray) do
        table.insert(exclude, d.uuid)
    end
    return CardLibModel:getCardByCategory(category, exclude)
end

---------------------------------------------------------------------- 雇佣end

function VoidlandModel:getRankInfo()
    local param = {}
    param.rankType = self.modeType == 1 and GameDef.RankType.DreamLandSingle or GameDef.RankType.DreamLandMultiple
    RPCReq.Rank_GetRankData(
        param,
        function(data)
            Dispatcher.dispatchEvent(EventType.voidland_updateRank, data.rankData)
        end
    )
end

function VoidlandModel:player_levelUp()
    if (not FileCacheManager.getBoolForKey("Voidland_EnterLevelCheck", false)
        and not ModuleUtil.getModuleOpenTips(ModuleId.Voidland.id) ) then
        FileCacheManager.setBoolForKey("Voidland_EnterLevelCheck", true)
        if (self.schedulerID) then
            Scheduler.unschedule(self.schedulerID)
        end
        self.schedulerID = Scheduler.schedule(function()
            if ViewManager.getView("BattleBeginView") then
                return
            end
            if ViewManager.getView("ReWardView") then
                return
            end
            if ViewManager.getView("AwardShowView") then
                return
            end
            if ViewManager.getView("AwardView") then
                return
            end
            if ViewManager.getView("UpgradeView") then
                return
            end
            if PlayerModel:get_awardData() then
                return
            end
            if ViewManager.getView("VipUpLevelView") then
                return
            end
            ViewManager.open("VoidlandOpenView")
            Scheduler.unschedule(self.schedulerID)
            self.schedulerID = false
        end, 0.2)
    end
        
end

-- 玩法弹窗
function VoidlandModel:checkEnterWindow()
    if (not ModuleUtil.getModuleOpenTips(ModuleId.Voidland.id)) then
        local today = TimeLib.DayInWeek()
        local flag = FileCacheManager.getIntForKey("Voidland_EnterCheck", -1)
        if (flag == -1 or flag ~= today) then
            ViewManager.open("VoidlandOpenView")
            FileCacheManager.setIntForKey("Voidland_EnterCheck", today)
        end
    end
end

function VoidlandModel:checkRed()
    RedManager.addMap("V_VOIDLAND_AWARD", {"V_VOIDLAND_AWARDMODE_1", "V_VOIDLAND_AWARDMODE_2"})
    for modeType, data in ipairs(self.landMap) do
        local len = #self.confByPoint[modeType]
        local history = data.rewardRecord
        local flag = false
        for i = 1, len do
            local flag2 = false;
            local list = self:getPassRewardByPoint(i, modeType)
            for _, info in ipairs(list) do
                if (info.id <= data.maxId and not history[info.id]) then
                    flag = true
                    flag2 = true
                    break
                end
            end
            RedManager.updateValue("V_VOIDLAND_AWARD_"..modeType..i, flag2);
        end
        RedManager.updateValue("V_VOIDLAND_AWARDMODE_" .. modeType, flag)
    end
    self:showEnterRed();
end

-- 入口红点
function VoidlandModel:showEnterRed()
    local today = TimeLib.DayInWeek()
    local flag = FileCacheManager.getIntForKey("Voidland_EnterRed", -1)
    if (flag == -1 or flag ~= today) then
        RedManager.updateValue("V_VOIDLAND", true)
    else
        local base = RedManager.getTips("V_VOIDLAND_AWARD");
        RedManager.updateValue("V_VOIDLAND", base);
    end
end

-- 隐藏入口红点
function VoidlandModel:hideEnterRed()
    local today = TimeLib.DayInWeek()
    FileCacheManager.setIntForKey("Voidland_EnterRed", today)
    self:checkRed()
end

-- 跨天处理
function VoidlandModel:serverTime_crossDay()
    Dispatcher.dispatchEvent(EventType.Voidland_infoUpdate, "CrossDay")
    if (self.isFighting) then
        self.needOutFight = true;
    end
    -- if (ViewManager.getView("BattleBeginView")) then
    --     return;
    -- end
    -- RollTips.show(Desc.Voidland_crossDay);
end


-- ====================================================================== 战斗

function VoidlandModel:battleBegin()
    self:upSingleList();

    self.result = false;
    self.rewardList = {};
    self.skillSelect = false;
    self.eventId = false;
    self.heroIndex = false;
    self.isFighting = false;
    self.clickStart = false;
    self.needOutFight = false;

    local battleCall = function(eventType)
        if (eventType == "begin") then
            if (self.clickStart) then
                RollTips.show(Desc.Voidland_began)
                return;
            end
            self.clickStart = true;
            self.clickStartId = Scheduler.schedule(function ()
                self.clickStart = false;
                if (self.clickStartId) then
                    Scheduler.unschedule(self.clickStartId);
                    self.clickStartId = false;
                end
            end, 1.5, 1);
            self.isFighting = true;
            self:saveSingleList();
            self:checkSkillEvent();
            self.selectWaitFlag = false;
        elseif (eventType == "next") then
			print(2233,"next nextnextnextnext")
            -- local modeData = VoidlandModel:getCurModeData();
            -- local id = self.result and modeData.id - 1 or modeData.id;
            -- if (not self.result or VoidlandModel:isFinalWave(id)) then -- 最后一波
            local modeData = self:getCurModeData();
            if (not modeData.isStart) then
                Dispatcher.dispatchEvent("battle_end", {arrayType = self:getCurBattleType()});
                return;
            end
            self:checkSkillEvent();
        elseif (eventType == "end") then
            self.selectWaitFlag = false;
            self.isFighting = false;
            self.needOutFight = false;
            -- local modeData = VoidlandModel:getCurModeData();
            local id = self.curMapId --math.max(modeData.id - 1, 1)
            print(2233, "=====================战斗结束======", id);
            local info = {
                result = self.result,
                rewardList = self.rewardList,
                id = id,
                isFirst = self.isFirst,
            }
            ViewManager.open("ReWardView",{page=6, data=info, isWin=info.result})
        end
    end

    local args = {
        fightID= self:getPointInfoById().fightId,
        configType= self:getCurBattleType()
    }
    local modeData = self:getCurModeData();
    if (modeData.isStart) then
    -- 不是重头开始 就不用布阵
        BattleModel:setBattleConfig(args)
        Dispatcher.dispatchEvent("battle_setBattleFunc", battleCall,args);
        self:checkSkillEvent();
    else
        self.nextHeroIndex = 1;
        Dispatcher.dispatchEvent(EventType.battle_requestFunc, battleCall, args);
    end
end

-- 检测选技能事件
function VoidlandModel:checkSkillEvent()
    local eventId = self.eventId;
    local visible = nil
    local battleView = ViewManager.getView("BattleBeginView")--self.isVoidlandMode()
    if (battleView) then
        visible = battleView.view:isVisible()
    end
    local ty = BattleModel:getRunArrayType()
    local isBattling = self:isVoidlandMode(ty)
    if (not self.selectWaitFlag and eventId and isBattling and visible) then
        print(2233, "==== 进入了技能")
        if not ViewManager.isShow("VoidlandSkillView") then
            ViewManager.open("VoidlandSkillView");
        end
    else
        self:Voidland_battle();
    end
end

-- 战斗流程
function VoidlandModel:Voidland_battle()
    if self.waitBattle then
        return
    end
    print(2233, "==== 进入了战斗")
    self.waitBattle = true
    self.waitBattleId = Scheduler.schedule(function ()
        self.waitBattle = false;
        if (self.waitBattleId) then
            Scheduler.unschedule(self.waitBattleId);
            self.waitBattleId = false;
        end
    end, 3, 1)

    if (self.needOutFight) then
        Dispatcher.dispatchEvent("battle_end");
        return;
    end

    local info = {
        landType = self.modeType,
        id = self:getPointInfoById().id,
    }
    self:hideEnterRed();
	
    RPCReq.DreamLand_Start(info, function(arg)
        -- local eid = arg.data and arg.data.eventId or "false";
        -- printTable(2233, "============ 战斗开始i==========战斗结果"..tostring(arg.data.result).. "  技能  ".. eid.. " 关卡id  "..tostring(arg.data.info.id));

        self.isFighting = true;
        local data = arg.data;
        self.result = data.result;
        self.isFirst = data.isFirst or false;
        local modeData = self:getCurModeData();
        if (self.modeType == 1) then
            local singleIndex = modeData.singleIndex or false;
            self.heroIndex = self.nextHeroIndex and self.nextHeroIndex or singleIndex;
            self.nextHeroIndex = data.info.singleIndex or false;
            -- print(2233, "当前上阵=======", self.heroIndex);
            -- print(2233, "下场上阵=======", self.nextHeroIndex);
        end
        self.preHeroMap = modeData.heroMap or {};
        self.curMapId = modeData.id;
        self.listSkillBag = modeData.skillList; -- 已经选择的技能
        self.skillSelect = data.skillList or false; -- 回合结束可以选择的列表
        self.eventId = data.eventId or false;
        if (data.rewards and #data.rewards > 0) then
            for _, reward in ipairs(data.rewards) do
                if (not self.rewardList[reward.code]) then
                    self.rewardList[reward.code] = reward;
                else
                    self.rewardList[reward.code].amount = reward.amount + self.rewardList[reward.code].amount;
                end
            end
        end
        
        self:upVoidlandInfo(data.info);
        
        self.waitBattle = false;
        if (self.waitBattleId) then
            Scheduler.unschedule(self.waitBattleId);
            self.waitBattleId = false;
        end
    end,function (data)
        self.waitBattle = false;
        if (self.waitBattleId) then
            Scheduler.unschedule(self.waitBattleId);
            self.waitBattleId = false;
        end
		RollTips.showError(data)
	end)
end


function VoidlandModel:clear()
    if (self.clickStartId) then
        Scheduler.unschedule(self.clickStartId);
        self.clickStartId = false;
        self.clickStart = false;
    end
    if (self.waitBattleId) then
        Scheduler.unschedule(self.waitBattleId);
        self.waitBattleId = false;
        self.waitBattle = false;
    end
end


return VoidlandModel
