-- add by zn
-- 据点敌人信息查看

local GuildLeagueEnemyView = class("GuildLeagueEnemyView", Window)

function GuildLeagueEnemyView:ctor()
    self._packName = "GuildLeague"
    self._compName = "GuildLeagueEnemyView"
    self._rootDepth = LayerDepth.PopWindow
    self.data = self._args.data;
    self.idx = self._args.idx;
    self.defData = false;
    self.teamArr = false;
    self.isSelfTeam = false;
    local guildId = self.data.guildId;
    local baseInfo = GuildLeagueModel:getBaseInfo();
    local selfGuildId = baseInfo.guildId or 0;
    if (guildId == selfGuildId) then
        self.isSelfTeam = true;
    end

    local guildInfo = self.isSelfTeam and GuildLeagueModel.selfGuildInfo or GuildLeagueModel.enemyGuildInfo;
    self.serverId = guildInfo.serverId or LoginModel:getUnitServerId();
end

function GuildLeagueEnemyView:_initUI()
    local root = self
    local rootView = self.view
        root.starComp = rootView:getChildAutoType("starComp");

        root.txt_defCount = rootView:getChildAutoType("txt_defCount");
        root.txt_combat = rootView:getChildAutoType("txt_combat");
        root.txt_challenge = rootView:getChildAutoType("txt_challenge");

        root.btn_fight = rootView:getChildAutoType("btn_fight");
        root.btn_check = rootView:getChildAutoType("btn_check");

        root.txt_progress = rootView:getChildAutoType("txt_progress");

        root.list_challenge = rootView:getChildAutoType("list_challenge");
        root.list_attrAdd = rootView:getChildAutoType("list_attrAdd");
        root.list_team = rootView:getChildAutoType("list_team");
        root.list_item = rootView:getChildAutoType("list_item");

    local ctrl = rootView:getController("c3");
    ctrl:setSelectedIndex(self.isSelfTeam and 0 or 1);
    self:upInfo();
    self:upAwardPreview();
end

function GuildLeagueEnemyView:_initEvent()
    local constConf = DynamicConfigData.t_GLConst[1]
    local defMax = constConf.ruinFightTimes;
    self.btn_fight:addClickListener(function()
        local baseInfo = GuildLeagueModel:getBaseInfo();
        local actStatus = baseInfo.actStatus or 0;
        local beatNum = self.data.beatNum -- 被追击次数
        local isSelfGuild = baseInfo.guildId == self.data.guildId
        if (isSelfGuild) then
            RollTips.show(Desc.GL_challengTips2);
            return
        end
        if (actStatus ~= GameDef.GuildPvpActStatus.Battle) then
            RollTips.show(Desc.GL_str2);
            return;
        elseif (not GuildLeagueModel.haveQualif) then
            RollTips.show(Desc.GL_notQualif);
            return;
        end
        if (beatNum >= defMax) then
            RollTips.show(Desc.GL_challengTips3);
            return;
        end
        local levelCount = GuildLeagueModel:getLeaveBattleCount();
        if (levelCount == 0) then
            RollTips.show(Desc.GL_challengTips0);
        else
            self:enterBattle(0);
        end
    end)
    self.btn_check:addClickListener(function()
        ViewManager.open("GuildLeagueHistoryView", {baseInfo = self.data, defData = self.defData, teamArr = self.teamArr});
    end)
end

function GuildLeagueEnemyView:upInfo()
    local c1 = self.starComp:getController("c1");
    c1:setSelectedIndex(3 - self.data.health);
    local viewCtrl = self.view:getController("c1");
    viewCtrl:setSelectedIndex(self.data.health == 0 and 1 or 0);
    -- self.txt_combat:setText(StringUtil.transValue(self.data.combat));
    local levelCount = GuildLeagueModel:getLeaveBattleCount();
    if (GuildLeagueModel.haveQualif) then
        self.txt_challenge:setText(string.format(Desc.GL_challengeCount, levelCount));
    else
        self.txt_challenge:setText(string.format(Desc.GL_challengeCount, 0));
    end
    self:showTeamList();
    self:upAttrAddCount();
    self:upEnterList();
    GuildLeagueModel:getPlayerDefInfo(self.data.playerId, self.data.guildId)
end

-- 阵容列表
function GuildLeagueEnemyView:showTeamList()
    if (self.data.playerId > 0) then
        local playerId = self.data.playerId;
        -- local guildInfo = self.isSelfTeam and GuildLeagueModel.selfGuildInfo or GuildLeagueModel.enemyGuildInfo;
        -- local serverId = guildInfo.serverId or LoginModel:getUnitServerId();
        local info = {
            playerId = playerId,
            serverId = self.serverId,
            arrayType = GameDef.BattleArrayType.GuildPvpDef
        }
        RPCReq.Player_FindPlayer(info, function(param)
            if (param and param.playerInfo) then
                local arr = param.playerInfo.array;
                self:upTeamList(arr)
            end
        end)
    else -- 补位机器人
        local robotConf = DynamicConfigData.t_GLRobot[self.data.playerId];
        local fightId = robotConf and robotConf.fightId or false;
        if (fightId) then
            local fightConf = DynamicConfigData.t_fight[fightId];
            local standList = fightConf and fightConf.monsterStand or {};
            local teamInfo = {};
            for _, pos in ipairs(standList) do
                local d = {
                    code = fightConf["monsterId"..pos],
                    combat = fightConf["combat"..pos],
                    level = fightConf["level"..pos],
                    star = fightConf["star"..pos],
                    type = 2
                }
                table.insert(teamInfo, d)
            end
            self:upTeamList(teamInfo)
        end
    end
end

function GuildLeagueEnemyView: upTeamList(teamInfo)
    self.teamArr = teamInfo;
    local c2 = self.view:getController("c2");
    local combat = 0;
    for _, d in pairs(teamInfo) do
        combat = combat + d.combat;
    end
    c2:setSelectedIndex(#teamInfo > 0 and 1 or 0);
    self.list_team:setItemRenderer(function(idx, obj)
        local d = teamInfo[idx + 1];
        if (not obj.cell) then
            obj.cell = BindManager.bindHeroCell(obj)
        end
        obj.cell:setData(d, true);
    end)
    self.list_team:setNumItems(#teamInfo)
    
    self.txt_combat:setText(StringUtil.transValue(combat));
end

-- 防守次数
function GuildLeagueEnemyView:GuildLeague_playerDefInfo(_, playerId, defInfo)
    local sucCount = 0;
    if (playerId == self.data.playerId) then
        self.defData = defInfo;
        for _, d in pairs(defInfo) do
            if (not d.isWin) then
                sucCount = sucCount + 1;
            end
        end
    end
    self.txt_defCount:setText(string.format(Desc.GL_defSucCount, sucCount));
end

-- 增益加成
function GuildLeagueEnemyView:upAttrAddCount()
    local constConf = DynamicConfigData.t_GLConst[1];
    local totalCount = constConf.overlay;
    local cur = GuildLeagueModel:getTotalChase();
    self.txt_progress:setText(string.format("%s/%s", cur, totalCount));
    local info = {};
    local valueConf = constConf.buffPara;
    for i, str in ipairs(constConf.buffDec) do
        local v = valueConf[i];
        local d = {
            title = str,
            type = v.type,
            val = v.value
        }
        table.insert(info, d)
    end
    self.list_attrAdd:setItemRenderer(function(idx, obj)
        local d = info[idx + 1];
        obj:getChildAutoType("title"):setText(d.title);
        local curValue = d.val * cur;
        curValue = d.type == 2 and curValue.."%" or curValue;
        obj:getChildAutoType("cur"):setText(curValue)

        local c1 = obj:getController("c1");
        c1:setSelectedIndex(cur == totalCount and 1 or 0);
        local nextValue = d.val * (cur + 1);
        nextValue = d.type == 2 and nextValue.."%" or nextValue;
        obj:getChildAutoType("next"):setText(nextValue)
    end)
    self.list_attrAdd:setNumItems(#info)
    local levelCount = GuildLeagueModel:getLeaveBattleCount(); -- 自己剩余挑战次数
    local baseInfo = GuildLeagueModel:getBaseInfo();
    local isSelfGuild = baseInfo.guildId == self.data.guildId
    self.btn_fight:setGrayed(isSelfGuild or levelCount <= 0);
end

-- 奖励预览
function GuildLeagueEnemyView:upAwardPreview()
    local conf = DynamicConfigData.t_GLFightReward[self.idx];
    if (conf) then
        local award = conf.winReward or {};
        self.list_item:setItemRenderer(function(idx, obj)
            local a = award[idx + 1];
            if (not obj.cell) then
                obj.cell = BindManager.bindItemCell(obj)
            end
            obj.cell:setData(a.code, a.amount, a.type);
        end)
        self.list_item:setNumItems(#award)
    else
        self.list_item:setNumItems(0)
    end
end

-- 挑战入口
function GuildLeagueEnemyView:upEnterList()
    local constConf = DynamicConfigData.t_GLConst[1];
    local diffList = constConf.difficultyRate;
    local pointConf = DynamicConfigData.t_GLFightReward[self.idx];
    local baseInfo = GuildLeagueModel:getBaseInfo();
    local isSelfGuild = baseInfo.guildId == self.data.guildId
    self.list_challenge:setItemRenderer(function(idx, obj)
        local diff = idx + 1
        local difRate = diffList[diff] / 100;
        local add = pointConf and pointConf.point[diff] or 0;
        obj:getChildAutoType("txt_diff"):setText(string.format(Desc.GL_challengeRate, difRate, add));
        local list_star = obj:getChildAutoType("list_star");
        list_star:setNumItems(diff);
        -- obj:getChildAutoType("txt_add"):setText(string.format(Desc.GL_challengeScoreAdd, add));
        local btn = obj:getChildAutoType("btn_fight");
        local levelCount = GuildLeagueModel:getLeaveBattleCount();
        local health = self.data.health
        btn:setGrayed(isSelfGuild or (levelCount <= 0 or diff > health));
        btn:removeClickListener();
        btn:addClickListener(function()
            if (isSelfGuild) then
                RollTips.show(Desc.GL_challengTips2);
                return
            end
            local actStatus = baseInfo.actStatus or 0;
            if (actStatus ~= GameDef.GuildPvpActStatus.Battle) then
                RollTips.show(Desc.GL_str2);
                return;
            elseif (not GuildLeagueModel.haveQualif) then
                RollTips.show(Desc.GL_notQualif);
                return;
            end

            if (levelCount == 0) then
                RollTips.show(Desc.GL_challengTips0);
            elseif diff > health then
                RollTips.show(Desc.GL_challengTips1);
            else
                self:enterBattle(diff);
            end
        end)
    end)
    self.list_challenge:setNumItems(#diffList)
end

-- 战斗 0 表示追击
function GuildLeagueEnemyView:enterBattle(diff)
    local playerId = self.data.playerId;
    local guildId = self.data.guildId;
    local serverId = self.serverId
    GuildLeagueModel:enterBattle(playerId, serverId, diff, guildId)
    self:closeView();
end

return GuildLeagueEnemyView