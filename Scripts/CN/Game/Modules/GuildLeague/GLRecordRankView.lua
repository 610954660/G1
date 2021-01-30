-- add by zn
-- 本赛季统计

local GLScoreRankBaseView = require "Game.Modules.GuildLeague.GLScoreRankBaseView"
local GLRecordRankView = class("GLRecordRankView", GLScoreRankBaseView)

function GLRecordRankView:ctor()
    self._packName = "GuildLeague"
    self._compName = "GLRecordRankView"
    -- self._rootDepth = LayerDepth.PopWindow
    self._openType = GameDef.RankType.GuildPvpGuildPlayerScore
end

function GLRecordRankView:initBeforeReqData()
    local root = self
    local rootView = self.view
        root.rankIcon = rootView:getChildAutoType("rankIcon");
        root.txt_name = rootView:getChildAutoType("txt_name");-- 公会名
        root.txt_rankName = rootView:getChildAutoType("txt_rankName"); -- 最高段位名
        root.txt_star = rootView:getChildAutoType("txt_star");--最高星星
        root.txt_area = rootView:getChildAutoType("txt_area");--赛区
        root.txt_rank = rootView:getChildAutoType("txt_rank");--排名
        root.txt_normalCount = rootView:getChildAutoType("txt_normalCount");--常规胜场
        root.txt_normalRate = rootView:getChildAutoType("txt_normalRate");--常规胜率
        root.txt_legendCount = rootView:getChildAutoType("txt_legendCount");--传奇胜场
        root.txt_legendRate = rootView:getChildAutoType("txt_legendRate");--传奇胜率
        root.txt_winCount = rootView:getChildAutoType("txt_winCount");--常规连胜

    self:_refresh();
end

function GLRecordRankView:_refresh()
    -- self:updateRankData();
    local baseInfo = GuildLeagueModel:getBaseInfo();
    local guildInfo = GuildModel.guildList;
    self.txt_name:setText(guildInfo.name);
    local rankConf = DynamicConfigData.t_GLRank
    local curConf = rankConf[baseInfo.scoreRank]; -- GuildLeagueModel:getRankConfByScore(baseInfo.score);
    if (curConf) then
        -- 段位信息
        local iconUrl = PathConfiger.getRankLevelIcon(curConf.res);
        self.rankIcon:setIcon(iconUrl);
        -- self.txt_rankName:setText(curConf.rank)
        -- self.txt_star:setText(baseInfo.score);
    end
    -- self.txt_area:setText();
    local rankStr = (baseInfo.rank == nil or baseInfo.rank == 0) and Desc.Rank_notInRank or baseInfo.rank;
    self.txt_rank:setText(rankStr);
    self.txt_winCount:setText(baseInfo.maxConsecutive or 0); -- 连胜
    -- 比赛记录信息
    self.txt_normalCount:setText(baseInfo.winCount); -- 常规赛胜场
    if (baseInfo.totalCount == 0) then
        self.txt_normalRate:setText("0%");
    else
        self.txt_normalRate:setText(string.format("%d%%", math.ceil(baseInfo.winCount / baseInfo.totalCount) * 100)); -- 常规赛胜率
    end
    self.txt_legendCount:setText("0"); -- 传奇赛胜场
    self.txt_legendRate:setText("0%"); -- 传奇赛胜率
    local maxConf = rankConf[baseInfo.maxScoreRank];
    local maxRankLevel = maxConf == nil and Desc.HigherPvP_NoRankName or maxConf.rank;
    self.txt_rankName:setText(maxRankLevel);
    self.txt_star:setText(baseInfo.maxScore or 0);
    
    GuildLeagueModel:requestBaseInfo();
end

function GLRecordRankView:updateRankData()
    GuildLeagueModel:getScoreRank(nil, handler(self, self.onSuccess), self._openType)
end

function GLRecordRankView:updateItemSpec(obj, rank, info, isMine)
    local txt_star = obj:getChildAutoType("txt_star");
    local txt_score = obj:getChildAutoType("txt_score");
    local extraData = info.extraData and info.extraData.guildPvpGuildPlayer or {};
    txt_star:setText(extraData.starNum or 0);
    txt_score:setText(extraData.score or 0);
end

return GLRecordRankView