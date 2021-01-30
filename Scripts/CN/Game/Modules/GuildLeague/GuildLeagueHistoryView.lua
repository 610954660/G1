-- add by zn
-- 防守记录

local GuildLeagueHistoryView = class("GuildLeagueHistoryView", Window)

function GuildLeagueHistoryView:ctor()
    self._packName = "GuildLeague"
    self._compName = "GuildLeagueHistoryView"
    self._rootDepth = LayerDepth.PopWindow
    self.data = self._args.baseInfo;
    self.defData = self._args.defData;
    self.teamArr = self._args.teamArr;
end

function GuildLeagueHistoryView:_initUI()
    local root = self
    local rootView = self.view
        root.txt_combat = rootView:getChildAutoType("txt_combat");
        root.list_hero = rootView:getChildAutoType("list_hero");
        root.list_history = rootView:getChildAutoType("list_history");
        
    self.list_history:setVirtual()

    self.txt_combat:setText(StringUtil.transValue(self.data.combat));

    if (self.teamArr) then
        self:upTeamList(self.teamArr);
    else
        self:showTeamList()
    end

    if (self.defData) then
        self:showDefHistory();
    else
        GuildLeagueModel:getPlayerDefInfo(self.data.playerId, self.data.guildId)
    end
end

-- 阵容列表
function GuildLeagueHistoryView:showTeamList()
    if (self.data.playerId > 0) then
        local playerId = self.data.playerId;
        local guildInfo = GuildLeagueModel.enemyGuildInfo;
        local serverId = guildInfo.serverId or LoginModel:getUnitServerId();
        local info = {
            playerId = playerId,
            serverId = serverId,
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

function GuildLeagueHistoryView:upTeamList(teamInfo)
    local c2 = self.view:getController("c1");
    local combat = 0;
    for _, d in pairs(teamInfo) do
        combat = combat + d.combat;
    end
    c2:setSelectedIndex(#teamInfo > 0 and 1 or 0);

    self.list_hero:setItemRenderer(function(idx, obj)
        local d = teamInfo[idx + 1];
        if (not obj.cell) then
            obj.cell = BindManager.bindHeroCell(obj)
        end
        obj.cell:setData(d, true);
    end)
    self.list_hero:setNumItems(#teamInfo)
    self.txt_combat:setText(StringUtil.transValue(combat));
end

function GuildLeagueHistoryView:GuildLeague_playerDefInfo(_, playerId, defInfo)
    if (playerId == self.data.playerId) then
        self.defData = defInfo;
    else
        self.defData = false;
    end
    self:showDefHistory();
end

function GuildLeagueHistoryView:showDefHistory()
    local historyData = self.defData;
    local c2 = self.view:getController("c2");
    c2:setSelectedIndex(#historyData > 0 and 1 or 0);
    self.list_history:setItemRenderer(function(idx, obj)
        local d = historyData[idx + 1];
        local c1 = obj:getController("c1");
        c1:setSelectedIndex(d.isWin and 1 or 0);
        local str = d.isWin and Desc.GL_defFail or Desc.GL_defSuc;
        obj:getChildAutoType("txt_result"):setText(str);
        obj:getChildAutoType("txt_name"):setText(d.name);
        local time = TimeLib.msToString(d.timeStamp);
        obj:getChildAutoType("txt_time"):setText(time);
        obj:getChildAutoType("txt_diff"):setText(string.format(Desc.GL_str0, d.star));
        -- 阵容
        local list = obj:getChildAutoType("list_team");
        local team = {};
        local combat = 0
        for _, tInfo in pairs(d.heroInfoMap) do
            combat = combat + tInfo.combat;
            table.insert(team, tInfo);
        end
        obj:getChildAutoType("txt_combat"):setText(StringUtil.transValue(combat));
        list:setItemRenderer(function(idx1, obj1)
            local dd = team[idx1 + 1];
            if (not obj1.cell) then
                obj1.cell = BindManager.bindHeroCell(obj1)
            end
            obj1.cell:setData(dd, true);
        end)
        list:setNumItems(#team);
        -- 按钮
        local btn = obj:getChildAutoType("btn_video");
        btn:removeClickListener();
        btn:addClickListener(function()
            BattleModel:requestBattleRecord(d.recordId);
        end)
    end)
    self.list_history:setNumItems(#historyData);
end

return GuildLeagueHistoryView