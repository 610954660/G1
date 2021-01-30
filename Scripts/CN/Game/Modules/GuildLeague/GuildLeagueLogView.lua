-- add by zn
-- 联赛日志

local GuildLeagueLogView = class("GuildLeagueLogView", Window)

function GuildLeagueLogView:ctor()
    self._packName = "GuildLeague"
    self._compName = "GuildLeagueLogView"
    self._rootDepth = LayerDepth.PopWindow
end

function GuildLeagueLogView:_initUI()
    local root = self
    local rootView = self.view
        root.list_log = rootView:getChildAutoType("list_log");
        self.list_log:setVirtual()

    GuildLeagueModel:getMatchLog();
end

function GuildLeagueLogView:GuildLeague_matchLogUpdate()
    local baseInfo = GuildLeagueModel:getBaseInfo();
    local selfGuildId = baseInfo.guildId;
    local logData = GuildLeagueModel.matchLog;
    local c1 = self.view:getController("c1");
    if (not logData or not next(logData)) then
        c1:setSelectedIndex(0);
        return;
    else
        c1:setSelectedIndex(1);
    end
    table.sort(logData, function(a, b)
        return a.timeStamp > b.timeStamp;
    end)
    local arr = {};
    for _, d in ipairs(logData) do
        if (d.star > 0) then
            table.insert(arr, d)
        end
    end
    self.list_log:setItemRenderer(function(idx, obj)
        local log = arr[idx + 1];
        local c1 = obj:getController("c1");
        local isSelfGuild = log.guildId == selfGuildId
        c1:setSelectedIndex(isSelfGuild and 0 or 1);
        local time = TimeLib.msToString(log.timeStamp);
        obj:getChildAutoType("txt_time"):setText(time);
        local starStr = "";
        for i = 1, log.star do
            starStr = starStr..Desc.GL_matchLogStar
        end
        local modelStr = isSelfGuild and Desc.GL_matchLog0 or Desc.GL_matchLog1
        local guildName = isSelfGuild and GuildLeagueModel.selfGuildInfo.guildName or GuildLeagueModel.enemyGuildInfo.guildName
        local str = string.format(modelStr, log.attackName, log.defName, starStr, log.score, guildName, Desc.GL_matchLogStar ,log.guildStarNum)
        obj:getChildAutoType("txt_desc"):setText(str);
    end)
    self.list_log:setNumItems(#arr)
end

return GuildLeagueLogView