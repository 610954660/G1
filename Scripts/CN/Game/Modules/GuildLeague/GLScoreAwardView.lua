-- add by zn
-- 积分奖励

local GLScoreRankBaseView = require "Game.Modules.GuildLeague.GLScoreRankBaseView"
local GLScoreAwardView, Super = class("GLScoreAwardView", GLScoreRankBaseView)

function GLScoreAwardView:ctor()
    self._packName = "GuildLeague"
    self._compName = "GLScoreAwardView"
    -- self._rootDepth = LayerDepth.PopWindow
    self._openType = GameDef.RankType.GuildPvpMatchPlayer
end

function GLScoreAwardView:initBeforeReqData()
    local root = self
    local rootView = self.view
        root.list_item = rootView:getChildAutoType("list_item");
        root.selfRank = rootView:getChildAutoType("selfRank");
        root.txt_desc = rootView:getChildAutoType("txt_desc");
end

function GLScoreAwardView:updateRankData()
    GuildLeagueModel:getScoreRank(nil, handler(self, self.onSuccess))
end

function GLScoreAwardView:getConfByRank(rank)
    local baseInfo = GuildLeagueModel:getBaseInfo();
    local baseScore = baseInfo.score or 0;
    local matchInfo = GuildLeagueModel.selfGuildInfo or {};
    local matchScore = matchInfo.score or 0
    local score = GuildLeagueModel.winGuildId and baseScore or baseScore + matchScore--比赛结算了 直接拿分数计算就好 没结算时要用拥有的分数+本场已获得的分
    local guildRank = GuildLeagueModel:getRankByScore(score)
    local conf = DynamicConfigData.t_GLPointReward[guildRank];
    if (conf) then
        for _, d in ipairs(conf) do
            if (d.maxRank >= rank) then
                return d;
            end
        end
    end
    return false;
end

function GLScoreAwardView:updateItemSpec(obj, rank, data)
    local conf = self:getConfByRank(rank);
    local c1 = obj:getController("c1");
    local rank = obj:getChildAutoType("txt_rank");
    local rank1 = obj:getChildAutoType("txt_myRank");
    if (not data or not data.rank) then
        c1:setSelectedIndex(0);
    else
        rank:setText(data.rank);
        rank1:setText(data.rank);
        if data.rank >= 0 and data.rank < 4 then
            c1:setSelectedIndex(data.rank);
        else
            c1:setSelectedIndex(4);
        end
    end

    local award = conf and conf.pointReward or {};
    local list_item = obj:getChildAutoType("list_item");
    list_item:setItemRenderer(function(idx, obj)
        if (not obj.cell) then
            obj.cell = BindManager.bindItemCell(obj);
        end
        local a = award[idx + 1];
        obj.cell:setData(a.code, a.amount, a.type);
    end)
    list_item:setNumItems(#award)

    local extraData = (data and data.extraData) and data.extraData.guildPvpMatchPlayer or {};
    obj:getChildAutoType("txt_score"):setText(extraData.score or 0);
    obj:getChildAutoType("txt_star"):setText(extraData.starNum or 0);
end

return GLScoreAwardView