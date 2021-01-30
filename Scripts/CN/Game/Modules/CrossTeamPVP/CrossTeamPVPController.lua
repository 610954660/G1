--Date :2020-12-09
--Author : wyz
--Desc : 组队竞技

local CrossTeamPVPController = class("CrossTeamPVP",Controller)

function CrossTeamPVPController:init()
	
end

-- #前端收到这个就要刷新界面 1:打开界面 2:组队成功 3:队伍解散 4:更换队长
-- WorldTeamArena_RefreshInfo 20547 {
--     request {
--         info        1:WorldTeamArena_TeamInfo
--     }
-- }

-- .WorldTeamArena_TeamInfo{
--     reason                   1:integer      
--     nextAddTimesMs           2:integer       #下次刷新次数时间
--     isLeadOfflineCanBattle   3:boolean       #允许队员在队长离线时发起挑战
--     isLeader                 4:boolean
--     members                  5:*WorldTeamArena_PlayerInfo(playerId)
--     leaderId                 6:integer
--     canChallenge             7:integer
--     endMs                    8:integer
-- }

-- .WorldTeamArena_PlayerInfo {
--     playerId        1:integer               #玩家id
--     serverId        2:integer               #服务器id
--     fight           3:integer               #战力
--     score           4:integer               #分数
--     name            5:string                #名字
--     head            6:integer               #头像
--     level           7:integer               #等级
--     restTimes       8:integer               #剩余挑战次数
--     isLeader        9:boolean               #是否是队长
--     isOnline        10:boolean              #是否在线
--     rank            11:integer              #排行榜名词
--     hasTeam         12:boolean              #是否处于已组队状态
-- }
function CrossTeamPVPController:WorldTeamArena_RefreshInfo(_,params)  
    printTable(8848,">>>WorldTeamArena_RefreshInfo>>",params)
    CrossTeamPVPModel:initMainData(params.info)
end


-- WorldTeamArena_UpdatePlayerList 9870 {
--     request {
--         list        1:*WorldTeamArena_TypeToPlayerItem(type)
--     }
-- }

-- .WorldTeamArena_TypeToPlayerItem { 
--     type          1:integer  #1:组队大厅推荐玩家 2：好友 3:被邀请列表 4:邀请列表 5:攻击方 6：防守方
--     list          2:*WorldTeamArena_PlayerInfo(playerId)
-- }
-- 组队大厅的数据
function CrossTeamPVPController:WorldTeamArena_UpdatePlayerList(_,params)
    printTable(8848,">>>WorldTeamArena_UpdatePlayerList>>",params)
    CrossTeamPVPModel:initTeamHallData(params.list)
end

-- 战斗数据
-- WorldTeamArena_BattleResult 13267 {
--     request {
--         isWin        1:boolean
--         recordIds    2:*string
--         myScore      3:integer
--         addScore     4:integer
--         myRank       5:integer
--         addRank      6:integer
--     }
-- }
function CrossTeamPVPController:WorldTeamArena_BattleResult(_,data)
    printTable(8848,">>>WorldTeamArena_BattleResult>>",data)
    CrossTeamPVPModel:initBattleResult(data)
end


function CrossTeamPVPController:Limit_ConsumeTimes( _,data)
	if data.type == GameDef.GamePlayType.WorldTeamArena then
		CrossTeamPVPModel:addLimitNum(1)
	end
end
function CrossTeamPVPController:Limit_ResetInfos(_,data)
	CrossTeamPVPModel:setLimitNum(0)
end

-- 活动状态
-- WorldTeamArena_UpdateStatus 4785 {
--     request {
--        status     1:integer
--        endMs      2:integer
--     }
-- }
function CrossTeamPVPController:WorldTeamArena_UpdateStatus(_,data)
    printTable(8848,">>>.WorldTeamArena_UpdateStatus>>>活动状态>>",data)
    CrossTeamPVPModel:setWorldTeamStatus(data)
end

return CrossTeamPVPController