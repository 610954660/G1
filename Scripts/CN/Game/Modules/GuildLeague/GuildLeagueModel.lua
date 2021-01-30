-- add by zn
-- 公会联赛

local GuildLeagueModel = class("GuildLeagueModel", BaseModel)

function GuildLeagueModel:ctor()
    self.challengeNum = 0;
    self.baseInfo = false;
    self.matchLog = {};
    self.boxInfos = {};

    self.selfGuildInfo = {};
    self.enemyGuildInfo = {};
    self.selfPlayerInfos = {};
    self.enemyPlayerInfos = {};
    -- self.initRedMap = false;
    self.fastEnter = true; -- 主界面快速入口标识 本次登录一次
    self.haveQualif = false; -- 自己是否有参赛资格
    self.winGuildId = false; -- 结算阶段胜利公会的id;
    self:initListeners()
end

function GuildLeagueModel:guild_add_evet()
    if (GuildModel.guildHave and ModuleUtil.hasModuleOpen(ModuleId.GuildLeague.id)) then
        self:requestBaseInfo();
        self:requestMatchInfo();
        self:getBoxInfo();
    end
end

function GuildLeagueModel:guild_exit_evet()
    self.haveQualif = false;
    Dispatcher.dispatchEvent("GuildLeague_baseInfoUpdate");
    Dispatcher.dispatchEvent("GuildLeague_guildInfoUpdate");
    self:checkRed();
end

function GuildLeagueModel:setGuildInfo(guildInfo)
    -- self.guildInfo = guildInfo;
    guildInfo = guildInfo or {}
    local selfGuildId = self.baseInfo and self.baseInfo.guildId or 0
    for id, data in pairs(guildInfo) do
        if (id == selfGuildId) then
            self.selfGuildInfo = data;
            if (data.playerInfo) then
                self.haveQualif = false;
                self.selfPlayerInfos = data.playerInfo;
                for playerId in pairs(data.playerInfo) do
                    if (playerId == tonumber(PlayerModel.userid)) then
                        self.haveQualif = true;
                        break;
                    end
                end
            else
                self.selfGuildInfo.playerInfo = self.selfPlayerInfos
            end
            
        else
            self.enemyGuildInfo = data;
            if (data.playerInfo) then
                self.enemyPlayerInfos = data.playerInfo;
            else
                self.enemyGuildInfo.playerInfo = self.selfPlayerInfos
            end
        end
    end
    Dispatcher.dispatchEvent("GuildLeague_guildInfoUpdate");
end

function GuildLeagueModel:s2cRefreshData(param)
    local baseInfo = self.baseInfo or {};
    local selfGuildId = baseInfo.guildId or 0;
    local guildInfo = param.guildInfo or {};
    local playerInfo = param.guidInfo or {};
    for guildId, data in pairs(guildInfo) do
        local info = false
        if (guildId == selfGuildId) then
            info = self.selfGuildInfo
            -- baseInfo.score = data.score;
            baseInfo.combat = data.combat;
            baseInfo.beatNum = data.beatNum;
        else
            info = self.enemyGuildInfo
        end
        info.beatNum = data.beatNum;
        info.combat = data.combat;
        info.score = data.score;
    end
    for playId, data in pairs(playerInfo) do
        local info = false;
        if (data.guildId == selfGuildId) then
            info = self.selfPlayerInfos[playId]
        else
            info = self.enemyPlayerInfos[playId]
        end
        info.beatNum = data.beatNum;
        info.health = data.health;
    end
    self:checkRed()
    Dispatcher.dispatchEvent("GuildLeague_baseInfoUpdate");
    Dispatcher.dispatchEvent("GuildLeague_guildInfoUpdate");
end

-- 基础信息
function GuildLeagueModel:requestBaseInfo()
    RPCReq.Guild_GuildPvpBaseInfoReq({}, function(param)
        param.scoreRank = self:getRankByScore(param.baseInfo.score)
        self.baseInfo = param.baseInfo;
        self:checkRed()
        Dispatcher.dispatchEvent("GuildLeague_baseInfoUpdate");
    end)
end

-- 基础信息
function GuildLeagueModel:getBaseInfo()
    return self.baseInfo or {};
end

function GuildLeagueModel:requestMatchInfo()
    RPCReq.Guild_GuildPvpMatchInfoReq({}, function(param)
        local matchInfo = param.matchInfo or {};
        self.challengeNum = matchInfo.challengeNum or false;
        self.winGuildId = matchInfo.winnerId or false;
        self:setGuildInfo(matchInfo.guildInfo);
        self:checkRed()
    end)
end

-- 剩余挑战次数
function GuildLeagueModel:getLeaveBattleCount()
    return self.challengeNum or 0;
end

-- 本次比赛追击对方公会次数 1 自己公会  2 敌方公会
function GuildLeagueModel:getTotalChase(type)
    type = not type and 1 or type;
    return type == 2 and self.enemyGuildInfo.beatNum or self.selfGuildInfo.beatNum;
end

-- 获取自己公会参赛玩家数据
function GuildLeagueModel:getSelfGuildPlayerInfo()
    return self.selfPlayerInfos or {};
end

-- 获取敌方公会参赛玩家数据
function GuildLeagueModel:getEnemyGuildPlayerInfo()
    return self.enemyPlayerInfos or {};
end

-- 根据星数获取段位配置
function GuildLeagueModel:getRankByScore(score)
    score = score or 0;
    local conf = DynamicConfigData.t_GLRank;
    for idx = 0, #conf + 1 do
        local c = conf[idx];
        if (c and score <= c.max) then
            return idx;
        end
    end
    return 0;
end

function GuildLeagueModel:getPlayerDefInfo(playerId, guildId)
    local info = {
        playerId = playerId,
        guildId = guildId
    }
    RPCReq.Guild_GuildPvpPlayerDefRecordReq(info, function(param)
        local info = param.recordInfo or {};
        Dispatcher.dispatchEvent("GuildLeague_playerDefInfo", playerId, info);
    end)
end

-- 获取比赛日志
function GuildLeagueModel:getMatchLog()
    RPCReq.Guild_GuildPvpBattleRecordInfoReq({}, function(param)
        self.matchLog = param.recordInfo or {};
        Dispatcher.dispatchEvent("GuildLeague_matchLogUpdate");
    end)
end

-- 赛区公会排行
function GuildLeagueModel:requesMatchAreaRankData(ranktype)
    RPCReq.Rank_GetGuildPvpGroupRankData({
        rankType = ranktype
    }, function(param)
        Dispatcher.dispatchEvent("GuileLeague_MatchAreaRank", param);
    end)
end

-- 全服公会排行
-- function GuildLeagueModel:requesAllSeverRankData()
--     Scheduler.scheduleNextFrame(function()
--         Dispatcher.dispatchEvent("GuileLeague_AllSeverRank", {rankData = {}});
--     end)
-- end

function GuildLeagueModel:getBoxInfo()
    RPCReq.Guild_GuildPvpGiftBoxInfoReq({}, function(param)
        self.boxInfos = param.boxInfo or {};
        self:checkRed()
        Dispatcher.dispatchEvent("GuildLeague_boxInfoUpdate");
    end)
end

function GuildLeagueModel:getScoreRank(guildId, cb, rankType)
    if (not guildId) then
        guildId = self.baseInfo and self.baseInfo.guildId or 0
    end
    rankType = rankType and rankType or GameDef.RankType.GuildPvpMatchPlayer;
    local extraInfo = {
        guildId = guildId,
        rankType = rankType,
    }
    if (tonumber(guildId) == 0) then
        if (cb) then cb({}) end;
        Dispatcher.dispatchEvent("GuildLeague_scoreRankUpdate", {}, extraInfo);
        return;
    end
    local info = {
        rankType = rankType,
        param = guildId
    }
    RPCReq.Rank_GetRankData(info, function(param)
        if (cb) then cb(param, extraInfo) end
        Dispatcher.dispatchEvent("GuildLeague_scoreRankUpdate", param, extraInfo);
    end)
end

-- 领取宝箱奖励
function GuildLeagueModel:getBoxAward(idx)
    local info = {
        boxIndex = idx,
    }
    RPCReq.Guild_GuildPvpGiftBoxRewardReq(info, function(param)
        -- for _, d in ipairs(self.boxInfos.recordMap) do
        --     if (d.boxIndex == idx) then
        --         d.rewardList = param.rewardList;
        --         break;
        --     end
        -- end
        -- Dispatcher.dispatchEvent("GuildLeague_boxInfoUpdate");
        if (param.rewardList) then
            local data = {
                show = 1,
                reward = param.rewardList
            }
            ViewManager.open("AwardShowView",data);
        end
        self:getBoxInfo();
    end)
end

function GuildLeagueModel:getRecordInfo()
    RPCReq.Guild_GuildPvpGuildBattleRecordReq({}, function(param)
        Dispatcher.dispatchEvent("GuildLeague_recordInfoUpdate", param.recordList or {});
    end)
end

function GuildLeagueModel:enterBattle(playerId, serverId ,diff, guildId)
    local baseInfo = self:getBaseInfo();
    if (baseInfo.guildId == guildId) then
        RollTips.show(Desc.GL_challengTips2);
        return
    end
    local reward = {};
    local battleResult = false;
    local battleCall = function (param)
        if (param == "begin") then
            local info = {
                playerId = playerId,
                star = diff
            }
            RPCReq.Guild_GuildPvpChallengeReq(info, function(res)
                reward = res.rewardList;
                battleResult = res.result;
            end)
        elseif (param == "end") then
            local info = {
                data = {reward = reward},
                isWin = battleResult,
                page = 4,
                type = 1,
                -- showNoReward = true,
            }
            ViewManager.open("ReWardView", info)
            self:requestMatchInfo()
        end
    end
    local fightId = DynamicConfigData.t_GLConst[1].fightId
    local args = {
        fightID = fightId,
        configType= GameDef.BattleArrayType.GuildPvpAttack,
        playerId = playerId,
        serverId = serverId
    }
    Dispatcher.dispatchEvent(EventType.battle_requestFunc, battleCall, args);
end

-- 红点
-- 1. 比赛阶段，玩家有挑战资格且有挑战次数，公会、公会联赛入口icon有红点提示
-- 2. 布阵阶段，玩家有防守资格，且本次比赛未调整过布阵时，公会、公会联赛入口icon、我的防守icon有红点提示，点击后不再提示红点
-- 3. 玩家有未领取的宝箱时，公会、公会联赛入口icon、奖励按钮有红点提示，点击奖励按钮优先打开宝箱奖励界面
function GuildLeagueModel:checkRed()
    local checkFunc = function()
        -- if (not self.initRedMap) then
        --     local map = {
        --         "V_GuildLeague_challenge",
        --         "V_GuildLeague_def",
        --         "V_GuildLeague_award",
        --         "V_GLOL_enter",
        --     }
        --     RedManager.addMap("V_Guild_League", map);
        -- end
        local actStatus = self:getBaseInfo().actStatus or 0;
        local nextSeasonStamp = self:getBaseInfo().nextActStamp or 0;
        -- 1
        if (GuildModel.guildHave and actStatus == GameDef.GuildPvpActStatus.Battle and self:getLeaveBattleCount() > 0) then
            RedManager.updateValue("V_GuildLeague_challenge", true);
        else
            RedManager.updateValue("V_GuildLeague_challenge", false);
        end
        -- 2
        RedManager.updateValue("V_GuildLeague_def", false);
        if (GuildModel.guildHave and self.haveQualif and actStatus == GameDef.GuildPvpActStatus.Prepare) then
            local str = FileCacheManager.getStringForKey("GUildLeague_Def", "0")
            if (tostring(nextSeasonStamp) ~= str) then
                RedManager.updateValue("V_GuildLeague_def", true);
            end
        end
        -- 3
        RedManager.updateValue("V_GuildLeague_award", GuildModel.guildHave and self.boxInfos.rewardStatus == 1);
    end
    GlobalUtil.delayCallOnce("GuildLeague:checkRedDot", checkFunc, self, 0.2)
end

function GuildLeagueModel:haveChallengeTime()
    local baseInfo = self.baseInfo or {};
    local actStatus = baseInfo.actStatus or 0;
    local joinStatus = baseInfo.joinStatus or 0;
    local challengeNum = self:getLeaveBattleCount();
    if (GuildModel.guildHave and self.haveQualif and joinStatus == 1 and actStatus == GameDef.GuildPvpActStatus.Battle and challengeNum > 0) then
        return true;
    end
    return false;
end

return GuildLeagueModel