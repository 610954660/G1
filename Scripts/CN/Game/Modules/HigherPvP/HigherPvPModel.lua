-- add by zn
-- 高阶竞技场

local HigherPvPModel = class ("HigherPvPModel", BaseModel);

function HigherPvPModel: ctor()
    self.selfInfo = false;
    self.battleTeamType = 0; -- 0防守 1进攻 2世界擂台天擂台
    self.curTeamIdx = 1; -- 1 1v1   2 3v3   3 6v6
    -- self.ackTeam = false;
    -- self.defTeam = false;
    self.heroInTeamMap = {};  --最外层的key与self.battleTeamType对应 {[1] = {{15001 = {team=teamIdx, uuid=xxxx}}, {15002 = {team=teamIdx, uuid=xxxx}}}, [2] = {{15001 = {team=teamIdx, uuid=xxxx}}, {15002 = {team=teamIdx, uuid=xxxx}}}}
    self.allTeamInfo = false; -- {{arrayType=2001, array = {{seatId = 11, uuid = XXXX},}}, {arrayType=2001, array = {{seatId = 11, uuid = XXXX},}}}
    self.fightData = {}; -- 战报数据
    self.recordIdIdx = 1 -- 战斗数
    self.recordIds = false;
    self.schedulerID = false;
    self.challengeHistory = false;
    self:initListeners();

    self.isHistory = false;
    self.isFighting = false;
end

function HigherPvPModel:loginPlayerDataFinish()
    self:getRoleInfo();
    self:getHistoryList();
end

-- 获取玩家自身信息
function HigherPvPModel:getRoleInfo()
    self:initTeamInfo();
    RPCReq.HigherPvp_GetInfo({}, function (param)
        -- printTable(2233, "======= 高阶竞技场 ======", param.data);
        if (param and param.data) then
            if (self.selfInfo and self.selfInfo.rankIndex < param.data.rankIndex) then
                self:showUpRankView(self.selfInfo.rankIndex, param.data.rankIndex);
            end
            self.selfInfo = param.data;
            Dispatcher.dispatchEvent("HigherPvp_upSelfInfo", param.data);
            self:checkRed();
        end
    end)
end

-- 进入玩法保存一遍精灵阵容
function HigherPvPModel:saveElvesBattle(planIndex)
    if TableUtil.GetTableLen(ElvesSystemModel:getElvesEnterData(1)) == 0 and 
    TableUtil.GetTableLen(ElvesSystemModel:getElvesEnterData(2)) == 0 and 
    TableUtil.GetTableLen(ElvesSystemModel:getElvesEnterData(3)) == 0 then
        Dispatcher.dispatchEvent(EventType.ElvesAddTopView_refresh)
        return
    end
    local arrayType = GameDef.BattleArrayType.HigherPvpAckOne
    local saveElvesPlan = function(params)
        if not ModelManager.ElvesSystemModel.arrays[params.data.arrayType] then
            ModelManager.ElvesSystemModel.arrays[params.data.arrayType] = {}
        end
        table.insert(ModelManager.ElvesSystemModel.arrays[params.data.arrayType],params.data)
        -- 刷新界面
        local data = {
            arrayType = arrayType,
            planId    = planIndex,
        }
        ModelManager.ElvesSystemModel.planId[arrayType] = planIndex
        ModelManager.ElvesSystemModel:setMyElvesBattleReqInfo(arrayType,planIndex)
        Dispatcher.dispatchEvent(EventType.ElvesAddTopView_refresh)
    end
    local reqInfo = {
            arrayType = arrayType, -- 阵容类型
            planId    = planIndex, -- 方案id
        }
    RPCReq.Elf_SetArraysPalnId(reqInfo,function(params)
        saveElvesPlan(params)
    end)
    RPCReq.Elf_SetArraysPalnId({arrayType = GameDef.BattleArrayType.HigherPvpAckOne,planId = planIndex,},function(params)
    end)
    RPCReq.Elf_SetArraysPalnId({arrayType = GameDef.BattleArrayType.HigherPvpAckThree,planId = planIndex,},function(params)
    end)
    RPCReq.Elf_SetArraysPalnId({arrayType = GameDef.BattleArrayType.HigherPvpAckSix,planId = planIndex,},function(params)
    end)
    printTable(8848,">>>>>精灵>>>保存天境赛攻击阵容>>>>>")
end

-- 获取挑战列表
function HigherPvPModel:getChallengeList()
    RPCReq.HigherPvp_GetChallengeList({}, function (param)
        -- printTable(2233, "======== 挑战列表 ========", param.challengeList);
        Dispatcher.dispatchEvent("HigherPvp_upChallengeList", param.challengeList);
    end)
end

function HigherPvPModel:getHistoryList()
    RPCReq.HigherPvp_GetBattleRecordInfo({}, function (param)
        param.data = param.data or {};
        for idx, d in pairs(param.data) do
            d.idx = idx;
        end
        TableUtil.sortByMap(param.data, {{key = "fightMs", asc = true}});
        self.challengeHistory = param.data;
        Dispatcher.dispatchEvent("HigherPvp_upHistoryList", param.data);
        self:checkHistoryRed();
        -- printTable(2233, "======= 历史记录 =======", param.data);
    end)
end

-- 购买门票
function HigherPvPModel:buyTicket()
    local cost = self:getBuyCost();
    if (cost and PlayerModel:isCostEnough(cost, true)) then
        RPCReq.HigherPvp_Buy({}, function (param)
            printTable(2233, "========= 买票结果 =========", param);
            if (self.selfInfo) then
                self.selfInfo.buyTimes = param.buyTimes + 1;
            end
        end)
    end
end

function HigherPvPModel:getPlayerArray(playerId, serverId, gamePlayType)
    local info = {
        playerId = playerId,
        serverId = serverId or LoginModel:getUnitServerId(),
        gamePlayType = gamePlayType
    }
    RPCReq.Battle_QueryPlayerGamePlayInfo(info, function (param)
        Dispatcher.dispatchEvent("HigherPvP_teamInfo", param);
    end)
end

function HigherPvPModel: getRankAward(rankId)
    RPCReq.HigherPvp_RecvRankReward({rankIndex = rankId}, function (param)
        printTable(2233, "----- 段位奖励领取结果 -----", param);
        self.selfInfo.recvRecords = param.data;
        Dispatcher.dispatchEvent("HigherPvp_upRankReward");
        self:checkRewardRed();
    end)
end

function HigherPvPModel:addFightData(data)
    table.insert(self.fightData, data.battleData);
end

function HigherPvPModel:clearFightData()
    self.fightData = {};
    self.recordIdIdx = 1;
end

function HigherPvPModel:getBuyCost()
    local constConf = DynamicConfigData.t_HPvPConst[1];
    if (constConf) then
        local costType = constConf.ticketCostType[1];
        local costList = constConf.ticketCost;
        local buyCostIndex = math.min(self.selfInfo.buyTimes + 1, #costList);
        local cost = costList[buyCostIndex];
        return {code = costType.code, type = costType.type, amount= cost};
    end
    return nil;
end

-- 检查英雄是否同类上阵
function HigherPvPModel: checkHeroInTeam(heroCode)
    local team = self:getTeamInfo();

    if (team[heroCode..""]) then
        return team[heroCode..""].team;
    end
    return false;
end

function HigherPvPModel:checkHeroInTeamByUid(heroUuid)
    local team = self:getTeamInfo();
    for _, info in pairs(team) do
        if (info.uuid == heroUuid) then
            return info.team;
        end
    end
    return false;
end

-- 位置信息变化  一定是交换位置
function HigherPvPModel:SeatItem_seatInfoUpdate()
    local seats = BattleModel:getSeatInfos();
    local teamTpye = self:getBattleTeamType()[self.curTeamIdx];
    local array = self.allTeamInfo[teamTpye].array;
    for uuid, d in pairs(array) do
        for _, seat in ipairs(seats) do
            if (seat.uuid == uuid) then
                d.id = seat.seatId;
                -- return;
            end
        end
    end
end 


function HigherPvPModel: setHeroToTeam(seatId, heroInfo, oldHeroInfo)
    for i = 0, 2 do
        if not self.heroInTeamMap[i] then
            self.heroInTeamMap[i] = {}
        end
    end
    local team = self:getTeamInfo();
    local teamType = self:getBattleTeamType()[self.curTeamIdx];
    if (heroInfo) then
        team[heroInfo.code..""] = {
            team = self.curTeamIdx,
            uuid = heroInfo.uuid,
        }
        self.allTeamInfo[teamType].array[heroInfo.uuid] = {
            uuid = heroInfo.uuid,
            id = seatId,
        }
    end
    if (oldHeroInfo) then
        team[oldHeroInfo.code..""] = nil;
        self.allTeamInfo[teamType].array[oldHeroInfo.uuid] = nil;
    end
    self:checkTeamHasEmpty();
    -- printTable(2233, "+++++++++++++++ 设置上阵", self.allTeamInfo);
end

function HigherPvPModel: initTeamInfo()
    self.allTeamInfo = {};
    for i = 0, 2 do
        -- if not self.heroInTeamMap[i] then
            self.heroInTeamMap[i] = {}
        -- end
    end
    -- 同步防守阵容
    self.battleTeamType = 0
    local defTypes = self:getBattleTeamType();
    local defTeam = self.heroInTeamMap[0];
    for _, v in ipairs(defTypes) do
        local const = DynamicConfigData.t_HPvPConst[1];
        local requseInfo={
            fightId	= const.fightId,
            playerId= 0,
            gamePlay= v
        }
        self.allTeamInfo[v] = {
            arrayType = v,
            array={},
        }
        local function success(data)
            -- printTable(2233, "HigherPvPModel: initTeamInfo", data.array);
            if (data.array) then
                for uuid, d in pairs(data.array) do
                    local heroInfo = CardLibModel:getHeroByUid(d.uuid);
                    if (heroInfo) then
                        defTeam[heroInfo.code..""] = {
                            team = requseInfo.gamePlay % 1000 + 1,
                            uuid = heroInfo.uuid
                        }
                        self.allTeamInfo[v].array[uuid] = d;
                    end
                end
            end
        end
        RPCReq.Battle_GetOpponentBattleArray(requseInfo,success)
    end
    -- 同步进攻阵容
    self.battleTeamType = 1
    local ackTypes = self:getBattleTeamType();
    local ackTeam = self.heroInTeamMap[1];
    for _, v in ipairs(ackTypes) do
        local requseInfo={
            fightId	= 0,
            playerId= -1,
            gamePlay= v
        }
        self.allTeamInfo[v] = {
            arrayType = v,
            array={},
        }
        local function success(data)
            -- printTable(2233, "HigherPvPModel: initTeamInfo", data.array);
            if (data.array) then
                for uuid, d in pairs(data.array) do
                    local heroInfo = CardLibModel:getHeroByUid(d.uuid);
                    if (heroInfo) then
                        ackTeam[heroInfo.code..""] = {
                            team = requseInfo.gamePlay % 1000 + 1,
                            uuid = heroInfo.uuid
                        }
                        self.allTeamInfo[v].array[uuid] = d;
                    end
                end
            end
        end
        RPCReq.Battle_GetOpponentBattleArray(requseInfo,success)
    end
    -- 世界擂台赛
    self.battleTeamType = 2
    local arrTypes = self:getBattleTeamType()
    local wTeam = self.heroInTeamMap[2];
    for _, v in ipairs(arrTypes) do
        local const = DynamicConfigData.t_HPvPConst[1];
        local requseInfo={
            fightId	= 0,
            playerId= -1,
            gamePlay= v
        }
        self.allTeamInfo[v] = {
            arrayType = v,
            array={},
        }
        local function success(data)
            -- printTable(2233, "HigherPvPModel: initTeamInfo", data.array);
            if (data.array) then
                for uuid, d in pairs(data.array) do
                    local heroInfo = CardLibModel:getHeroByUid(d.uuid);
                    if (heroInfo) then
                        wTeam[heroInfo.code..""] = {
                            team = requseInfo.gamePlay % 1000,
                            uuid = heroInfo.uuid
                        }
                        self.allTeamInfo[v].array[uuid] = d;
                    end
                end
            end
        end
        RPCReq.Battle_GetOpponentBattleArray(requseInfo,success)
    end
end

function HigherPvPModel:checkTeamHasEmpty()
    local arrayType = self:getBattleTeamType();
    for type, data in pairs(self.allTeamInfo) do
        if (type == arrayType[1]) then
            RedManager.updateValue("HigherPvp_teamEmpty1", TableUtil.GetTableLen(data.array) < 1);
            -- printTable(2233, "HigherPvp_teamEmpty1", data.array, TableUtil.GetTableLen(data.array) < 1)
        elseif (type == arrayType[2]) then
            RedManager.updateValue("HigherPvp_teamEmpty2", TableUtil.GetTableLen(data.array) < 3);
            -- printTable(2233, "HigherPvp_teamEmpty2", data.array, TableUtil.GetTableLen(data.array) < 2)
        elseif (type == arrayType[3]) then
            RedManager.updateValue("HigherPvp_teamEmpty3", TableUtil.GetTableLen(data.array) < 6);
            -- printTable(2233, "HigherPvp_teamEmpty3", data.array, TableUtil.GetTableLen(data.array) < 3)
        end
    end
end

function HigherPvPModel:getAllBattleCombat()
    self.battleTeamType = 1
    local arrayType = self:getBattleTeamType();
    CardLibModel:setCardsByCategory(0);
    local combat = 0;
    for _, type in pairs(arrayType) do
        local array = self.allTeamInfo[type].array or {};
        for _, info in pairs(array) do
            local uuid = info.uuid or "";
            local hero = CardLibModel:getHeroByUid(uuid);
            if (hero.combat) then
                combat = combat + hero.combat;
            end
        end
    end
    return combat
end

function HigherPvPModel: getTeamInfo()
    return self.heroInTeamMap[self.battleTeamType] or {}
end

function HigherPvPModel: getArrayByType(type)
    return self.allTeamInfo[type];
end

function HigherPvPModel: saveTeamInfo(arrayType, cb)
    local teamCheck = self:battleCheckTeam();
    if (teamCheck) then
        Dispatcher.dispatchEvent("HigherPvP_changeTeam", teamCheck);
        return;
    end
    local typeArr = self:getBattleTeamType();
    local allArr = {}
    for _, v in ipairs(typeArr) do
        table.insert(allArr, self:getArrayByType(v));
    end

    local gamePlayType = GameDef.GamePlayType.HigherPvp;
    if (WorldHighPvpModel:isWoroldHighPvpArrayType(arrayType)) then
        gamePlayType = GameDef.GamePlayType.WorldSkyPvp
    elseif (CrossPVPModel:isCrossPVPType(arrayType)) then
        gamePlayType = GameDef.GamePlayType.HorizonPvp
    elseif (CrossArenaPVPModel:isCrossPVPType(arrayType)) then
        gamePlayType = GameDef.GamePlayType.CrossArena
    end
    local info = {
        arrays = allArr,
        gamePlayType = gamePlayType
    }
    RPCReq.Battle_UpdateArrayMap(info, function (param)
        if (param) then
            for _, v in ipairs(typeArr) do
                BattleModel.__arrayInfos[v] = self:getArrayByType(v);
            end
            if (cb) then cb() end;
        end
    end)
end

-- 开始前检查队伍是否满足要求
-- @return 数字为第几队没有上阵
function HigherPvPModel: battleCheckTeam(tips)
    tips = tips == nil and true or tips;
    local team = self:getTeamInfo()
    if (team) then
        for i = 1, 3 do
            local flag = false;
            for _, info in pairs(team) do
                if (info.team == i) then
                    flag = true;
                    break;
                end
            end
            if (not flag) then
                if (tips) then RollTips.show(Desc.HigherPvP_emptyTeam); end;
                return i;
            end
        end
    else
        return 1;
    end
    return false;
end

-- 获取胜利时可增加的分数
function HigherPvPModel: getScoreAddByWin(selfScore, otherScore)
    local conf = DynamicConfigData.t_HPvPScore;
    selfScore = math.max(selfScore, 1);
    local offset = selfScore / otherScore * 10000;
    for _, c in pairs(conf) do
        if (offset > c.min and offset <= c.max) then
            return c.attackWin
        end
    end
    return 0;
end

-- 获取段位名称
function HigherPvPModel:getRankName(index)
    local conf = DynamicConfigData.t_HPvPRank[index];
    if (conf) then
        return conf.rank;
    end
    return nil;
end

-- 获取当前段位  
-- @param score 段位分 rankIndex 段位排名
function HigherPvPModel:getRank(score, rankIndex)
    local conf = DynamicConfigData.t_HPvPRank;
    local rank1Conf = conf[1];
    local rankMaxConf = conf[#conf];
    local const = DynamicConfigData.t_HPvPConst[1];
    local firstRank = const.firstRankNum;
    if (score < rank1Conf.min) then
        return 0;
    elseif (score >= rankMaxConf.min and rankIndex > 0) then
        if (rankIndex <= firstRank) then
            return #conf;
        else
            return #conf - 1;
        end
    else
        for idx, c in ipairs(conf) do
            if (score >= c.min and score <= c.max) then
                return idx
            end
        end
    end
end

function HigherPvPModel: getBattleTeamType()
    if (self.battleTeamType == 0) then
        return {
            GameDef.BattleArrayType.HigherPvpDefOne,
            GameDef.BattleArrayType.HigherPvpDefThree,
            GameDef.BattleArrayType.HigherPvpDefSix,
        }
    elseif (self.battleTeamType == 1) then
        return {
            GameDef.BattleArrayType.HigherPvpAckOne,
            GameDef.BattleArrayType.HigherPvpAckThree,
            GameDef.BattleArrayType.HigherPvpAckSix,
        }
    elseif self.battleTeamType == 2 then
        return WorldHighPvpModel:getArrayType()
    end
end


function HigherPvPModel:judgType(configType)
    return configType==GameDef.BattleArrayType.HigherPvpAckOne
	or configType==GameDef.BattleArrayType.HigherPvpAckThree
	or configType==GameDef.BattleArrayType.HigherPvpAckSix
end


function HigherPvPModel: isHigherPvpType(configType)
    return configType==GameDef.BattleArrayType.HigherPvpAckOne
	or configType==GameDef.BattleArrayType.HigherPvpAckThree
    or configType==GameDef.BattleArrayType.HigherPvpAckSix
    or configType==GameDef.BattleArrayType.HigherPvpDefOne
	or configType==GameDef.BattleArrayType.HigherPvpDefThree
	or configType==GameDef.BattleArrayType.HigherPvpDefSix
end

--------------------------- 段位奖励

function HigherPvPModel: getRankReward()
    local confArr = DynamicConfigData.t_HPvPReward;
    if (confArr) then
        local records = self.selfInfo.recvRecords;
        local data = {};
        for id, conf in ipairs(confArr) do
            local info = {
                id = id
            }
            if (records and records[id]) then
                if (records[id].recvState) then
                    info.state = 2;
                else
                    info.state = 0;
                end
            else
                info.state = 1;
            end
            table.insert(data, info);
        end
        TableUtil.sortByMap(data, {{key = "state", asc = true}, {key = "id", asc = false}});
        return data;
    end
    return {};
end

function HigherPvPModel:updateSelfInfo(data)
    for key, v in pairs(data) do
        if (key == "rankIndex" and self.selfInfo[key] and v > self.selfInfo[key]) then
            self:showUpRankView(self.selfInfo[key], v);
        end
        self.selfInfo[key] = v;
    end
end

function HigherPvPModel:showUpRankView(oldRank, newRank)
    Scheduler.unschedule(self.schedulerID)
	self.schedulerID = Scheduler.schedule(function()
        if ViewManager.getView("BattleBeginView") then return end
        if ViewManager.getView("ReWardView") then return end
        if ViewManager.getView("AwardShowView") then return end
        if ViewManager.getView("AwardView") then return end
        if ViewManager.getView("UpgradeView") then return end
        if PlayerModel:get_awardData() then return end
        if ViewManager.getView("HigherPvPResultView") then return end
        ViewManager.open("HigherPvPUpRankView", {oldRank = oldRank, curRank = newRank});
        Scheduler.unschedule(self.schedulerID)
        self.schedulerID = false;
	end,0.2)
end

function HigherPvPModel:checkRed()
    local tips = ModuleUtil.getModuleOpenTips(ModuleId.HigherPvP.id)
    if (tips) then
        return;
    end
    local info = self.selfInfo
    local endTime = TimeLib.nextWeekBeginTime()
    local offset = TimeLib.getOffsetTime(endTime)
    if (info) then
        RedManager.updateValue("V_HIGHERPVP_BEGIN", info.leftTimes > 0 and offset > 7200);
    end
    self:checkRewardRed();
    local def = FileCacheManager.getBoolForKey("HigherPvp_def", false);
    RedManager.updateValue("V_HIGHERPVP_DEF", not def);
    self:checkHistoryRed();
end

function HigherPvPModel:checkRewardRed()
    RedManager.updateValue("V_HIGHERPVP_REWARD", false);
    if (self.selfInfo and self.selfInfo.recvRecords) then
        for _, d in pairs(self.selfInfo.recvRecords) do
            if (d.recvState) then
                RedManager.updateValue("V_HIGHERPVP_REWARD", true);
                break;
            end
        end
    end
end

function HigherPvPModel:checkHistoryRed()
    local lastTime = FileCacheManager.getStringForKey("HigherPvp_history", "0");
    print(2233, "HigherPvp_history", tonumber(lastTime));
    if (self.challengeHistory and #self.challengeHistory > 0) then
        if (self.challengeHistory[1].fightMs < tonumber(lastTime)) then
            RedManager.updateValue("V_HIGHERPVP_HISTORY", false);
            return;
        end
        for i = #self.challengeHistory, 1, -1 do
            local history = self.challengeHistory[i];
            if (history.isAttack == false and history.fightMs > tonumber(lastTime)) then
                RedManager.updateValue("V_HIGHERPVP_HISTORY", true);
                return;
            end
        end
        RedManager.updateValue("V_HIGHERPVP_HISTORY", false);
    end
end

-- 开始挑战
function HigherPvPModel: battleBegin(playerId, playerName, revengeIdx)
    self.battleTeamType = 1;

    local recordIds = {}; -- 回放id列表
    local recordIdIdx = 1; -- 应该播放的录像位置
    local recordIdCount = 3; -- 录像总数
    local fightResult = false;
    local awardList = false;
    self:clearFightData();
    self.recordIds = {};
    self.recordIdIdx = 1;
	
	local skipBattle=PataModel:checkSkipArray(GameDef.BattleArrayType.HigherPvpAckOne) --是否跳过战斗
	

    local battleCall = function (param)
        printTable(2233, "---- HigherPvPMatchView: battleBegin 备战界面 ---", param);
        -- 点击开始战斗
        if (param == 'begin') then
            self.isFighting = true;
            local callenInfo = {
                enemyId= playerId
            }
            if (revengeIdx) then
                callenInfo.revengeIndex = revengeIdx;
            end
            -- printTable(2233, "---- 挑战信息 -------", callenInfo);
            RPCReq.HigherPvp_Challenge(callenInfo, function (backparam)
                -- printTable(2233, "==== 战斗结果 ====", backparam);
                local data = backparam.data;
                recordIds = data.recordIds or {};
                self.recordIds = recordIds;
                recordIdCount = #recordIds;
                fightResult = data;
                awardList = data.rewards or {};
                -- 播放战斗动画
                local recordId = recordIds[recordIdIdx] and recordIds[recordIdIdx].recordId or -1
                local info = {
                    recordId     = recordId,
		            gamePlayType = GameDef.GamePlayType.HigherPvp
                }
                -- printTable(2233,info)
                if info.recordId ~= -1 then
					BattleModel:requestBattleRecord(recordId,nil,GameDef.GamePlayType.HigherPvp)
						
                else
                    printTable(2233, "======= 服务器数据错误 ======", backparam);
                end
                recordIdIdx = recordIdIdx + 1;
                self:updateSelfInfo(data.myInfo);
                self:checkRed();
                Dispatcher.dispatchEvent("HigherPvp_upSelfInfo", data.myInfo);
            end)
        elseif (param == 'next') then
            print(2233, "-------- 下一场战斗播放 -----");
            -- 还有战斗
            self.recordIdIdx = self.recordIdIdx + 1;
            if (recordIdIdx <= recordIdCount) then
                local info = {
                    recordId     = recordIds[recordIdIdx].recordId,
                    gamePlayType = GameDef.GamePlayType.HigherPvp
                }
				BattleModel:requestBattleRecord(info.recordId,nil,GameDef.GamePlayType.HigherPvp)
                recordIdIdx = recordIdIdx + 1;
            else
                Dispatcher.dispatchEvent("battle_end", {arrayType = GameDef.BattleArrayType.HigherPvpAckOne});
            end
            
        elseif (param == "end") then
            print(2233, "====== 战斗结束 ========");
            if (recordIdIdx <= recordIdCount) then
                self:clearFightData();
            end
            local info = {
                isWin = fightResult.isWin, 
                ackName = PlayerModel.username,
                defName = playerName, 
                ackAddScore = fightResult.addScore, 
                defAddScore = fightResult.adddefScore,
                otherId = playerId,
            }
            ViewManager.open("HigherPvPResultView", info);
            ViewManager.close("HigherPvPMatchView");
            ViewManager.close("HigherPvPHistoryView");
            if (awardList and #awardList > 0) then
                local data = {
                    show = 1,
                    reward = awardList
                }
                ViewManager.open("AwardShowView",data);
            end
            self.isHistory = false;
            self.isFighting = false;
        elseif (param == "cancel") then
            self:initTeamInfo();
        end
    end
    local const = DynamicConfigData.t_HPvPConst[1];
    local args = {
        fightID= const.fightId,
        configType= GameDef.BattleArrayType.HigherPvpAckOne,
        playerId= playerId,
		skipBattle=skipBattle
    }
    Dispatcher.dispatchEvent(EventType.battle_requestFunc, battleCall, args);
end

function HigherPvPModel:Battle_BattleRecordData(_, param)
    -- printTable(2233, "回放战报数据下发", param);
    -- if (ViewManager.isShow("HigherPvPMatchView") 
    --     or (ViewManager.isShow("HigherPvPHistoryView") and not ViewManager.isShow("HigherPvPResultView"))) then
    if (self.isFighting == true) then
        self:addFightData(param);
        Dispatcher.dispatchEvent(EventType.Battle_replayRecord,{isRecord=false, battleData=param.battleData});
    end
end

function HigherPvPModel:checkSkip()
    if (self.recordIdIdx == 3 and self.fightData and self.fightData[1] and self.fightData[2]) then
        return self.fightData[1].result and self.fightData[2].result;
    end
    return false;
end

function HigherPvPModel:getRobotInfo(playerId, rankIndex)
    local conf = DynamicConfigData.t_HPvPRobot[playerId]
    local data = false
    if (conf) then
        -- 基本信息
        local baseInfo = {
            head = conf.head,
            level = conf.level,
            name = conf.name,
            playerId = playerId,
            score = conf.score,
            sex = conf.sex,
        }
        if (rankIndex) then
            baseInfo.rankIndex = rankIndex
            baseInfo.rankLevel = self:getRank(conf.score, rankIndex)
        else
            baseInfo.rankLevel = self:getRank(conf.score, 0)
        end
        -- 队伍信息
        local arrayInfo = {};
        local fightConf = DynamicConfigData.t_fight
        for _, fightId in pairs(conf.fightId) do
            local c = fightConf[fightId];
            if (c) then
                local combat = c.monstercombat
                local heroInfos = {}
                for _, posIndex in pairs(c.monsterStand) do
                    local d = {
                        code = c["monsterId"..posIndex],
                        level = c["level"..posIndex],
                        star = c["star"..posIndex],
                        type = 2
                    }
                    if posIndex < 4 then
                        d.id = 10 + posIndex
                    elseif posIndex < 7 then
                        d.id = 20 + posIndex - 3
                    else
                        d.id = 30 + posIndex - 6
                    end
                    table.insert(heroInfos, d);
                end
                local info = {
                    combat = combat,
                    heroInfos = heroInfos,
                    arrayType = fightId
                }
                table.insert(arrayInfo, info)
            end
        end
        data = {
            playerInfo = baseInfo,
            arrayInfo = arrayInfo
        }
    end
    return data
end

return HigherPvPModel;