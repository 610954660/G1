-- add by zn
-- 赛季荣誉榜

local GLScoreRankBaseView = require "Game.Modules.GuildLeague.GLScoreRankBaseView"
local GuildLeagueHonorView = class("GuildLeagueHonorView", GLScoreRankBaseView)

function GuildLeagueHonorView:ctor()
    self._packName = "GuildLeague"
    self._compName = "GuildLeagueHonorView"
    self._rootDepth = LayerDepth.PopWindow
    self.guildIdMap = {}
end

function GuildLeagueHonorView:initBeforeReqData()
    local guildId = GuildLeagueModel:getBaseInfo().guildId or 0
    local guildId2 = GuildLeagueModel.enemyGuildInfo.guildId or 0
    self.guildIdMap = {guildId, guildId2};
    self.list_type:setSelectedIndex(0);
    self.list_type:addClickListener(function()
        self:updateRankData();
    end)
end

function GuildLeagueHonorView:updateRankData()
    local curSelected = self.list_type:getSelectedIndex();
    local guildId = self.guildIdMap[curSelected + 1];
    GuildLeagueModel:getScoreRank(guildId, handler(self, self.onSuccess))
end

function GuildLeagueHonorView:updateItemSpec(obj, rank, info, isMine)
    local txt_star = obj:getChildAutoType("txt_star");
    local txt_score = obj:getChildAutoType("txt_score");
    local extraData = (info and info.extraData) and info.extraData.guildPvpMatchPlayer or {};
    txt_star:setText(extraData.starNum or 0);
    txt_score:setText(extraData.score or 0);
    obj:removeClickListener(100)
    obj:addClickListener(function(...)
        local id = isMine and PlayerModel.userid or info.id;
        ViewManager.open("ViewPlayerView",{playerId = id, rank = rank, serverId = info.serverId})
    end, 100)
end

return GuildLeagueHonorView