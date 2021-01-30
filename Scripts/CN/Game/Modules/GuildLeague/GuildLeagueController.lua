

local GuildLeagueController = class("GuildLeagueController", Controller)

function GuildLeagueController:Guild_GuildPvpPlayerInfoUpdateNotify(_, param)
    GuildLeagueModel:s2cRefreshData(param);
end
--[[
    actStatus           1:integer       #比赛阶段(比赛已开始有效)(当前比赛流程)
    statusEndStamp      2:integer       #比赛阶段结束时间戳
    nextActStamp        3:integer       #未开始和已结束时(下一场比赛时间戳)
    joinStatus          4:integer       #本公会参与状态
    isJoin              5:boolean       #本人是否有参与本场比赛
    defArrayStatus      6:boolean       #防守阵容状态(是否已设置本场防守阵容, 参与状态为true有效)
    challengeNum        7:integer       #挑战次数(是否存在挑战次数)
    giftStatus          8:boolean       #是否有礼包可领取
]]
function GuildLeagueController:Guild_GuildPvpStatusNotify(_, param)
    if (GuildLeagueModel.baseInfo) then
        local baseinfo = GuildLeagueModel.baseInfo;
        baseinfo.actStatus = param.actStatus or baseinfo.actStatus;
        baseinfo.statusEndStamp = param.statusEndStamp or baseinfo.statusEndStamp;
        baseinfo.nextActStamp = param.nextActStamp or baseinfo.nextActStamp;
        baseinfo.joinStatus = param.joinStatus or baseinfo.joinStatus;
    end
    GuildLeagueModel.haveQualif = param.isJoin or GuildLeagueModel.haveQualif;
    GuildLeagueModel.challengeNum = param.challengeNum or GuildLeagueModel.challengeNum
    GuildLeagueModel.boxInfos = GuildLeagueModel.boxInfos or {}
    GuildLeagueModel.boxInfos.rewardStatus = param.giftStatus and 1 or 0
    Dispatcher.dispatchEvent("GuildLeague_baseInfoUpdate");
    Dispatcher.dispatchEvent("GuildLeague_guildInfoUpdate");
    GuildLeagueModel:checkRed();
end

function GuildLeagueController:Guild_GuildPvpMatchResultNotify(_, param)
    if (param and param.guildInfo) then
        GuildLeagueModel:setGuildInfo(param.guildInfo)
    end
    GuildLeagueModel.winGuildId = param.winnerId or false;
    Dispatcher.dispatchEvent("GuildLeague_guildInfoUpdate");
end

return GuildLeagueController