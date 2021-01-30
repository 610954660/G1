-- add by zn
-- 排行榜

-- local RankView = require "Game.Modules.Rank.RankView"
local GuildLeagueRankView = class("GuildLeagueRankView", Window)

function GuildLeagueRankView:ctor()
    self._packName = "GuildLeague"
    self._compName = "GuildLeagueRankView"
    self._rootDepth = LayerDepth.PopWindow
end

function GuildLeagueRankView:_initUI()
    local root = self
    local rootView = self.view
        root.list_type = rootView:getChildAutoType("list_type");
        root.list_rank = rootView:getChildAutoType("list_rank");
        root.myRankItem = rootView:getChildAutoType("myRankItem");
        self.list_rank:setVirtual()
    GuildLeagueModel:requesMatchAreaRankData(GameDef.RankType.GuildPvpGroupGuild)
    self.list_type:setSelectedIndex(0);
end

function GuildLeagueRankView:_initEvent()
    self.list_type:addClickListener(function()
        local index = self.list_type:getSelectedIndex();
        if (index == 0) then
            GuildLeagueModel:requesMatchAreaRankData(GameDef.RankType.GuildPvpGroupGuild)
        else
            GuildLeagueModel:requesMatchAreaRankData(GameDef.RankType.GuildPvpWorldGuild)
        end
    end)
end

function GuildLeagueRankView:GuileLeague_MatchAreaRank(_, param)
    local rankData = param.rankData or {};
    self:upRankData(rankData);
end

-- function GuildLeagueRankView:GuileLeague_AllSeverRank(_, param)
--     local rankData = param.rankData or {};
--     self:upRankData(rankData);
-- end

function GuildLeagueRankView:upRankData(rankData)
    local len = #rankData;
    local c1 = self.view:getController("c1");
    c1:setSelectedIndex(len == 0 and 0 or 1);
    local guildId = GuildLeagueModel:getBaseInfo().guildId or 0;
    local haveMe = false;
    table.sort(rankData, function(a, b)
        return a.rank < b.rank;
    end)
    self.list_rank:setItemRenderer(function(idx, obj)
        local rank = idx + 1
        local data = rankData[rank];
        self:upRankItem(obj, data, rank);
        if (guildId == data.guildId) then
            haveMe = true;
            self:upRankItem(self.myRankItem, data, rank, true);
        end
    end)
    self.list_rank:setNumItems(len)
    if (len > 0 and not haveMe) then
        self:upRankItem(self.myRankItem, {}, 0, true);
    end
end

function GuildLeagueRankView:upRankItem(obj, data, rank, isMe)
    local conf =DynamicConfigData.t_GLRank[data.scoreRank or 0];
    local baseInfo = GuildModel.guildList;
    -- local serverInfo = LoginModel:getServerInfoByServerId(data.serverId) or {};

    local guildIcon = obj:getChildAutoType("guildIcon"); -- 公会图标
    local txt_rank = obj:getChildAutoType("txt_rank");
    local txt_rank1 = obj:getChildAutoType("txt_myRank");
    local name = obj:getChildAutoType("txt_name"); -- 公会名
    local rankName = obj:getChildAutoType("txt_rankName"); 
    local txt_star = obj:getChildAutoType("txt_star");
    local txt_combat = obj:getChildAutoType("txt_combat");
    local rankIcon = obj:getChildAutoType("rankIcon");
    local c1 = obj:getController("c1");

    if (rank > 4) then
        c1:setSelectedIndex(4);
    else
        c1:setSelectedIndex(rank);
    end
    local iconStr = isMe and GuildModel:getGuildHead(baseInfo.icon) or GuildModel:getGuildHead(data.guildIcon)
    guildIcon:setURL(iconStr)
    txt_rank:setText(rank);
    txt_rank1:setText(rank);
    local guildName = isMe and baseInfo.name or data.guildName;
    local serverId = isMe and LoginModel:getUnitServerId() or data.serverId
    local str = serverId and string.format("[S.%s] %s", serverId, guildName) or guildName
    name:setText(str);
    if (conf) then
        rankName:setText(conf.rank);
        rankIcon:setIcon(PathConfiger.getRankLevelIcon(conf.res));
    end
    txt_star:setText(data.score or 0);
    local combat = data.combat or baseInfo.combat;
    if isMe then
        combat = 0;
        for _, member in pairs(baseInfo.memberMap) do
            combat = combat + member.combat;
        end
    end
    txt_combat:setText(":"..StringUtil.transValue(combat));
end

return GuildLeagueRankView