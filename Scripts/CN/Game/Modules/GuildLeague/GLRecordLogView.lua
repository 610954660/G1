-- add by zn
-- 对战记录

local GLRecordLogView = class("GLRecordLogView", Window)

function GLRecordLogView:ctor()
    self._packName = "GuildLeague"
    self._compName = "GLRecordLogView"
    -- self._rootDepth = LayerDepth.PopWindow
end

function GLRecordLogView:_initUI()
    local root = self
    local rootView = self.view
        root.list_log = rootView:getChildAutoType("list_log");
    GuildLeagueModel:getRecordInfo()
end

function GLRecordLogView:GuildLeague_recordInfoUpdate(_, data)
    local c1 = self.view:getController("c1");
    if (not data or not next(data)) then
        c1:setSelectedIndex(0);
        return;
    else
        c1:setSelectedIndex(1);
    end
    table.sort(data, function(a, b)
        return a.timeStamp > b.timeStamp;
    end)
    self.list_log:setVirtual()
    self.list_log:setItemRenderer(function(idx, obj)
        local d = data[idx + 1];
        local teamInfo = {};
        local time = TimeLib.msToString(d.timeStamp);
        obj:getChildAutoType("txt_time"):setText(time);
        for _, m in pairs(d.guildRecord) do
            if (m.guildId == GuildLeagueModel.selfGuildInfo.guildId) then
                table.insert(teamInfo, 1, m);
            else
                table.insert(teamInfo, m);
            end
        end
        local RankConf = DynamicConfigData.t_GLRank
        local c1 = obj:getController("c1");
        for i = 1, #teamInfo do
            local tInfo = teamInfo[i];
            local scoreRank = GuildLeagueModel:getRankByScore(tInfo.score)
            local rConf = RankConf[scoreRank];
            if tInfo.isWinner then
                c1:setSelectedIndex(i - 1);
            end
            local rankIcon = obj:getChildAutoType("RankIcon"..i);
            local txt_guildName = obj:getChildAutoType("txt_GuildName"..i);
            local txt_rankName = obj:getChildAutoType("txt_RankName"..i);
            local txt_combat = obj:getChildAutoType("txt_Combat"..i);
            local txt_rank = obj:getChildAutoType("txt_Rank"..i);
            local txt_star = obj:getChildAutoType("txt_Star"..i);
            
            if (rConf) then
                rankIcon:setIcon(PathConfiger.getRankLevelIcon(rConf.res))
                txt_rankName:setText(rConf.rank);
            else
                rankIcon:setIcon("");
                txt_rankName:setText(Desc.HigherPvP_NoRankName)
            end
            
            -- local serverInfo = LoginModel:getServerInfoByServerId(tInfo.serverId) or {};
            local name = tInfo.serverId and string.format("[S.%s] %s", tInfo.serverId, tInfo.guildName) or tInfo.guildName
            txt_guildName:setText(name);
            txt_combat:setText(StringUtil.transValue(tInfo.combat or 0));
            local imgRank = tInfo.rankChange >= 0 and Desc.GL_arrowUp or Desc.GL_arrowDown;
            if (tInfo.rankChange == 0) then
                imgRank = ""
            end
            local imgscore = tInfo.scoreChange >= 0 and Desc.GL_arrowUp or Desc.GL_arrowDown;
            if (tInfo.scoreChange == 0) then
                imgscore = ""
            end
            txt_rank:setText(string.format("%s(%s%s)", tInfo.rank, imgRank, math.abs(tInfo.rankChange)));
            txt_star:setText(string.format("%s(%s%s)", tInfo.score, imgscore, math.abs(tInfo.scoreChange)));
        end
    end)
    self.list_log:setNumItems(#data)
end

return GLRecordLogView