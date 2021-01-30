--Date :2020-12-09
--Author : wyz
--Desc : 组队竞技

local CrossTeamPVPModel = class("CrossTeamPVP", BaseModel)

function CrossTeamPVPModel:ctor()
    self.time       = 60    -- 60s后自动开始战斗
    self.records    = {}    -- 录像数据
    self.nextAddTimesMs = 0 -- 下次刷新次数时间
    self.isLeadOfflineCanBattle  = false    -- 允许队员在队长离线时发起挑战
    self.isLeader   = false -- 是不是队长
    self.leaderId   = 0     -- 队长id
    self.canChallenge   = 0     -- 挑战次数
    self.activityEndMs  = 0     -- 结束时间

    self.crossTeamInfoByReason = {}     -- 所有数据 通过类型区分 1:打开界面 2:组队成功 3:队伍解散 4:更换队长
    self.teamHallInfo   = {}    -- 组队大厅数据 1:组队大厅推荐玩家 2：好友 3:被邀请列表 4:邀请列表
    self.isFighting     = false;
    self.matchInfo      = {}    -- 匹配得到的信息
    self.defenderNum    = 0
    self:initListeners()
    self.interfaceType  = 1
    self.adjustInfo     = {}  -- 挑整阵容界面信息
    self.isFirstPrep    = false -- 第一次进入备战
    self.battleResultInfo = {} -- 战斗返回的数据
    self.fightData  = {}
    self.recordIdIdx = 1
    self.recordIds  = {}
    self.fightIndex = 0
    self.interfaceTypeFlag = true
    self.rankInfo   = {}    -- 排行榜数据
    self.status     = false -- 比赛状态
    self.maxNum     = DynamicConfigData.t_limit[GameDef.GamePlayType.WorldTeamArena].maxTimes
    self.limitNum   = 0
    self.restTimes  = DynamicConfigData.t_WorldTeamArenaConst[1].restTimes
    self.isSeach    = false     --判断是不是搜索
    self.isEnd = false
    self.mvpHero = false
end

function CrossTeamPVPModel:init()

end

function CrossTeamPVPModel:initLimit(limit)
	if limit and limit.daily then
		local data = limit.daily[GameDef.GamePlayType.WorldTeamArena]
		if data then
			self.limitNum = data.times
		end
	end
end

function CrossTeamPVPModel:addLimitNum(val)
	self.limitNum = self.limitNum + val
	Dispatcher.dispatchEvent("CrossTeamPVPMainView_refreshPanel")
end
function CrossTeamPVPModel:setLimitNum(num)
	self.limitNum = num
	Dispatcher.dispatchEvent("CrossTeamPVPMainView_refreshPanel")
end

function CrossTeamPVPModel:getResidueNum()
	local residue = self.maxNum - self.limitNum
	if residue < 0 then
		residue = 0
	end
	return residue
end

function CrossTeamPVPModel:setWorldTeamStatus(data)
    if data then
        self.activityEndMs  = data.endMs and (data.endMs) or 0
        self.status = data.status or GameDef.WorldTeamArenaStatusType.END
        -- if self.status ~= GameDef.WorldTeamArenaStatusType.END or self.status ~= GameDef.WorldTeamArenaStatusType.RESET then
        --     self.isEnd = false
        -- end
        if (self.status == GameDef.WorldTeamArenaStatusType.OPEN) or (self.status == GameDef.WorldTeamArenaStatusType.PREPARE) then
            print(8848,"(((()))))))>>>>>>>>>>>>>>********")
            self.isEnd = false
        end

        local requseInfo = {
            fightId	= 1070000,
            playerId = tonumber(PlayerModel.userid),
            gamePlay = GameDef.BattleArrayType.WorldTeamArena,
        }
        local function success(data)
            local array = data.array or {}
            if TableUtil.GetTableLen(array) > 0 then
                self:reqGetPlayerInfo()
                Dispatcher.dispatchEvent(EventType.CrossTeamPVPMainView_refreshPanel)
            end
        end
        RPCReq.Battle_GetOpponentBattleArray(requseInfo,success)
        Dispatcher.dispatchEvent(EventType.CrossTabView_refresh)
    end
end

-- 进主界面的时候获取主界面面相关的所有信息
function CrossTeamPVPModel:initMainData(data)
    if data then
        if not self.crossTeamInfoByReason then
            self.crossTeamInfoByReason = {}
        end
        if not self.crossTeamInfoByReason[data.reason] then
            self.crossTeamInfoByReason[data.reason] = {}
        end
        self.crossTeamInfoByReason[data.reason] = data or {}
        if data.reason == GameDef.WorldTeamArenaReasonType.TeamSuc then -- 组队成功
            self.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open] = data or {}
            RollTips.show(Desc.CrossTeamPVP_teamSuc)
            ViewManager.close("CrossTeamPVPInviteView")
            ViewManager.close("CrossTeamPVPTeamHallView")
        elseif data.reason == GameDef.WorldTeamArenaReasonType.Dismiss then -- 队伍解散
            self.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open] = data or {}
            RollTips.show(Desc.CrossTeamPVP_dismiss)
        elseif data.reason == GameDef.WorldTeamArenaReasonType.ChangeLead then -- 更换队长
            self.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open] = data or {}
        elseif data.reason == GameDef.WorldTeamArenaReasonType.LeaderOnLine then -- 队长上线
            self.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open] = data or {}
            RollTips.show(Desc.CrossTeamPVP_leaderOnLine)
            ViewManager.close("CrossTeamPVPMatchView")
            ViewManager.close("CrossTeamPVPSquadSortView")
            ViewManager.close("CrossTeamFightAnimateView")
            ViewManager.close("CrossTeamPVPAddTopView")
        elseif data.reason == GameDef.WorldTeamArenaReasonType.LeaderOffline then -- 队长下线
            self.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open] = data or {}
        elseif data.reason == GameDef.WorldTeamArenaReasonType.Open then
            self.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open] = data or {}
        end
        local myId    = tonumber(PlayerModel.userid)
        local members = self.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open].members or {}
        self.restTimes      = members[myId].restTimes or self.restTimes
        self:updateRed()
        local flagNum = 0
        for k,v in pairs(members) do
            -- print(8848,">>>>>>看看有没有死循环>>>>>")
            flagNum = flagNum + 1
            local requseInfo = {
                playerId = v.playerId,
                serverId = v.serverId,
                arrayType = GameDef.GamePlayType.WorldTeamArena,
            }
            local function success(data)
                v.totalCombat = data.totalCombat
                if flagNum == TableUtil.GetTableLen(members) then
                    Dispatcher.dispatchEvent(EventType.CrossTabView_refresh)
                    Dispatcher.dispatchEvent(EventType.CrossTeamPVPMainView_refreshPanel)
                    Dispatcher.dispatchEvent(EventType.CrossTeamPVPRankView_refreshPanel)
                    Dispatcher.dispatchEvent(EventType.CrossTeamPVPTeamHallView_refreshPanel)
                    Dispatcher.dispatchEvent(EventType.CrossTeamPVPInviteView_refreshPanel)
                end
            end
            RPCReq.Battle_GetPlayerArrayTotalCombat(requseInfo,success)
        end
    end
end

-- 组队大厅数据
function CrossTeamPVPModel:initTeamHallData(data)   
    if data and data.type and data.type ~= 0 then
        if not self.teamHallInfo[data.type] then
            self.teamHallInfo[data.type] = {}
        end
        self.teamHallInfo[data.type] = data
        if self.isSeach and (data.type == GameDef.WorldTeamArenaPlayerListType.Hall) then
            if TableUtil.GetTableLen(self.teamHallInfo[data.type].list) == 0 then
                RollTips.show(Desc.CrossTeamPVP_str3)
            end
            self.isSeach = false
        end

        if self.teamHallInfo then
            for ik,iv in pairs(self.teamHallInfo) do
                local flagNum = 0
                if iv.list then
                    if TableUtil.GetTableLen(iv.list) == 0 then
                        Dispatcher.dispatchEvent(EventType.CrossTeamPVPTeamHallView_refreshPanel)
                        Dispatcher.dispatchEvent(EventType.CrossTeamPVPInviteView_refreshPanel)
                        self:updateRed()
                    end
                    for k,v in pairs(iv.list) do
                        print(8848,">>>>>>看看有没有死循环>>>>>")
                        flagNum = flagNum + 1
                        local requseInfo = {
                            playerId = v.playerId,
                            serverId = v.serverId,
                            arrayType = GameDef.GamePlayType.WorldTeamArena,
                        }
                        local function success(data)
                            v.totalCombat = data.totalCombat
                            if flagNum == TableUtil.GetTableLen(iv.list) then
                                Dispatcher.dispatchEvent(EventType.CrossTeamPVPTeamHallView_refreshPanel)
                                Dispatcher.dispatchEvent(EventType.CrossTeamPVPInviteView_refreshPanel)
                                self:updateRed()
                            end
                        end
                        RPCReq.Battle_GetPlayerArrayTotalCombat(requseInfo,success)
                    end
                end
            end
        end

    end
end

-- 开始战斗 返回的战斗数据
function CrossTeamPVPModel:initBattleResult(data)
    if data then
        -- printTable(8848,">>>>>>>initBattleResult>>>>>>开始战斗返回的数据>>>>>",data)
        self.battleResultInfo = data
        ViewManager.close("CrossTeamPVPSquadSortView")
        ViewManager.close("CrossTeamFightAnimateView")
        self:battleBegin()
    end
end



-- #打开界面的时候获取数据
-- WorldTeamArena_GetPlayerInfo 32263 {          
--     request {

--     }
-- }
function CrossTeamPVPModel:reqGetPlayerInfo()
    if  (self.status ==  GameDef.WorldTeamArenaStatusType.END) or (self.status ==  GameDef.WorldTeamArenaStatusType.RESET )then
        Dispatcher.dispatchEvent(EventType.CrossTeamPVPMainView_refreshPanel)
        return
    end
    local reqInfo = {

    }
    RPCReq.WorldTeamArena_GetPlayerInfo(reqInfo)
end

-- #获取录像数据
-- WorldTeamArena_GetRecordInfos 19047 {  
--     request {

--     }
--     response {
--        records      1:*WorldTeamArena_RecordInfo
--     }
-- }

-- .WorldTeamArena_RecordInfo {
--     myScore         1:integer              #当前玩家在那时候的分数
--     myAddScore      2:integer
--     myRank          3:integer
--     myAddRank       4:integer
--     left            5:WorldTeamArena_RecordTeamInfo
--     right           6:WorldTeamArena_RecordTeamInfo
--     fightMs         7:integer
--     recordIds       8:*string
-- }

-- .WorldTeamArena_RecordTeamInfo {
--     name            1:string               #队伍名字
--     totalFight      2:integer              #总战力
--     isWin           3:boolean
--     members         4:*WorldTeamArena_RecordTeamMemberInfo
-- }

-- .WorldTeamArena_RecordTeamMemberInfo {
--     playerId        1:integer               #玩家id
--     serverId        2:integer               #服务器id
--     level           3:integer
--     head            4:string
-- }
function CrossTeamPVPModel:reqGetRecordInfos()
    local reqInfo = {
    
    }
    RPCReq.WorldTeamArena_GetRecordInfos(reqInfo,function(params)  
        -- printTable(8848,">>>WorldTeamArena_GetRecordInfos>>>请求战斗记录>>",params)
        self.records = params.records or {}
        Dispatcher.dispatchEvent(EventType.CrossTeamPVPRecordOutView_refreshPanel)
    end)
end

-- #获取列表
-- WorldTeamArena_GetPlayerListByType 5350 {
--     request {
--        type         1:integer   #1:组队大厅推荐玩家 2：好友
--     }
-- }
function CrossTeamPVPModel:reqGetPlayerListByType(reqType)
    local reqInfo = {
        type = reqType,
    }
    RPCReq.WorldTeamArena_GetPlayerListByType(reqInfo,function(params) 
    end)
end

-- #搜索玩家
-- WorldTeamArena_Search 11483 {
--     request {
--        name         1:string    #通过名字搜索
--     }
-- }
function CrossTeamPVPModel:reqSearch(name)
    local reqInfo = {
        name = name,         
    }
    RPCReq.WorldTeamArena_Search(reqInfo,function(params)
        
    end)
end

-- #邀请玩家
-- WorldTeamArena_Invite 6713 {   
--     request {
--         targetPlayerId   1:integer
--         targetServerId   2:integer
--     }
-- }
function CrossTeamPVPModel:reqInvite(playerId,serverId)
    local reqInfo = {
        targetPlayerId = playerId,
        targetServerId = serverId,
    }
    RPCReq.WorldTeamArena_Invite(reqInfo,function(params) 
    
    end)
end

-- #答应邀请
-- WorldTeamArena_AcceptInvite 15227 {   
--     request {
--         targetPlayerId   1:integer
--         targetServerId   2:integer
--         isAccept         3:boolean #true 答应 false 拒绝 
--     }
-- }
function CrossTeamPVPModel:reqAcceptInvite(playerId,serverId,isAccept)
    local reqInfo = {
        targetPlayerId = playerId,
        targetServerId = serverId,
        isAccept       = isAccept,
    }
    -- printTable(8848,">>>WorldTeamArena_AcceptInvite>>>",reqInfo)
    RPCReq.WorldTeamArena_AcceptInvite(reqInfo,function(params) 
    
    end)
end

-- #离开队伍
-- WorldTeamArena_LeaveTeam 18224 {
--     request {

--     }
-- }
function CrossTeamPVPModel:reqLeaveTeam()
    local reqInfo = {}
    RPCReq.WorldTeamArena_LeaveTeam(reqInfo,function(params) 
    
    end)
end

-- #变换队长
-- WorldTeamArena_ChangeLeader 22177 {
--     request {

--     }
-- }
function CrossTeamPVPModel:reqChangeLeader()
    local reqInfo = {

    }
    RPCReq.WorldTeamArena_ChangeLeader(reqInfo,function(params) 
    
    end)
end

-- #设置
-- WorldTeamArena_OnSetLeadOfflineCanBattle 7028 {
--     request {

--     }
-- }
function CrossTeamPVPModel:reqOnSetLeadOfflineCanBattle()
    local reqInfo = {

    }
    RPCReq.WorldTeamArena_OnSetLeadOfflineCanBattle(reqInfo,function(params) 
    
    end)
end

-- #匹配
-- WorldTeamArena_Match 4015 {  
--     request {
      
--     }
--     response {
--         attacker  1:*WorldTeamArena_PlayerInfo
--         defender  2:*WorldTeamArena_PlayerInfo
--         endMs     3:integer
--     }
-- }
function CrossTeamPVPModel:reqMatch()
    local reqInfo = {
    }
    RPCReq.WorldTeamArena_Match(reqInfo,function(params) 
        -- printTable(8848,">>>组队竞技匹配成功>>>WorldTeamArena_Match>>>",params)
        self.matchInfo = params or {}
        Dispatcher.dispatchEvent(EventType.CrossTeamFightAnimateView_refreshPanel)
    end)
end

-- #调整
-- WorldTeamArena_Adjust 2670 {  
--     request {
--        format   1:*WorldTeamArena_PosToPlayerId(pos)
--     }
--     response {
--        attacker  1:*WorldTeamArena_BattleData(pos)
--        defender  2:*WorldTeamArena_BattleData(pos)
--        endMs     3:integer
--     }
-- }

-- .WorldTeamArena_PosToPlayerId {
--     pos           1:integer        
--     playerId      2:integer 
--     serverId      3:integer
-- }

-- .WorldTeamArena_BattleData {
--     pos           1:integer        
--     playerId      2:integer
--     serverId      3:integer
--     name          4:string
--     array         5:*BattleHeroInfo     #阵容数据
-- }
-- .BattleHeroInfo {
--     code                1:integer               #英雄id
--     level               2:integer               #等级
--     id                  3:integer               #位置
--     star                4:integer               #星级
--     type                5:integer               #类型 1英雄 2怪物,3秘武 4 精灵
--     maxHp               6:integer               #最大血
--     hp                  7:integer               #当前血量
--     rage                8:integer               #怒气
--     uuid                9:string                #英雄uuid
--     combat              10:integer              #战力
--     isHide			   11:boolean			   #是否隐藏阵容
-- }
function CrossTeamPVPModel:reqAdjust(data)
    local reqInfo = {
        format = data,
    }
    RPCReq.WorldTeamArena_Adjust(reqInfo,function(params) 
        -- printTable(8848,">>>阵容调整>>>WorldTeamArena_Adjust>>>",params)
        self.adjustInfo = params or {}
        Dispatcher.dispatchEvent(EventType.CrossTeamPVPSquadSortView_refreshPanel)
    end)
end

-- #开始战斗
-- WorldTeamArena_Battle 10256 {  
--     request {
		
--     }
-- }
function CrossTeamPVPModel:reqBattle()
    print(8848,">>>>开始战斗>>>")
    local reqInfo = {

    }
    RPCReq.WorldTeamArena_Battle(reqInfo,function(params)  
        
    end)
end

function CrossTeamPVPModel:getPercentRange(rank, totalNum)
	if not rank then return 0 end
	local config = DynamicConfigData.t_WorldTeamAreanRankToReward
	local playerNum = 0
	for _,v in ipairs(config) do
		local sector = math.ceil((v.max - v.min)*totalNum/10000)
		playerNum = playerNum + sector
		if rank <=  playerNum then
			return v.max/100
		end
	end
	return 100
end

-- #获取排行榜
-- WorldTeamArena_GetRanks 25840 {  
--     request {
        
--     }
--     response {
--        rankDatas  1:*WorldTeamArena_PlayerInfo
--     }
-- }
function CrossTeamPVPModel:reqGetRanks(number,func)
    local reqInfo = {

    }
    RPCReq.WorldTeamArena_GetRanks(reqInfo,function(params1)
		local totalNum = params1.totalNum
        self.rankInfo = params1.rankDatas or {}
        if not number then
            number = #self.rankInfo
        end
        for i=1,number do
            local data = self.rankInfo[i]
            if data then
                data.percent = self:getPercentRange(data.rank, totalNum)
                local requseInfo = {
                    playerId = data.playerId,
                    serverId = data.serverId,
                    arrayType = GameDef.GamePlayType.WorldTeamArena,
                }
                if number < 4 then
                    local function success(params2)
                        data.totalCombat = params2.totalCombat
                        Dispatcher.dispatchEvent(EventType.CrossTeamPVPMainView_refreshPanel)
                    end
                    RPCReq.Battle_GetPlayerArrayTotalCombat(requseInfo,success)
                end
            end
        end
        if func then
            func()
        end
    end)
end

-- 获取比赛状态
-- WorldTeamArena_GetCurMatchStatus 25339 {  
--     request {
--     }
--     response {
--        status     1:integer
--     }
-- }
function CrossTeamPVPModel:reqGetCurMatchStatus()
end



-- 判断自己在不在排行榜内
function CrossTeamPVPModel:getMyRankInfo() 
    local myRankInfo = {}
    local inRank = false
    local playerId = tonumber(PlayerModel.userid) 
    for k,v in pairs(self.rankInfo) do
        if playerId == v.playerId then
            return v,true,k
        end
    end
    return myRankInfo,inRank
end

-- 通过玩家id获取排名
function CrossTeamPVPModel:getRankByPlayerId(playerId) 
    for k,v in pairs(self.rankInfo) do
        if playerId == v.playerId then
            return k
        end
    end
    return false
end



-- function CrossTeamPVPModel:loginPlayerDataFinish()
-- 	self:getDefTemp()
-- end

function CrossTeamPVPModel:getDefTemp()
    local requseInfo = {
        fightId	= 1070000,
        playerId = tonumber(PlayerModel.userid),
        gamePlay = GameDef.BattleArrayType.WorldTeamArena,
    }
    local tips = ModuleUtil.getModuleOpenTips(ModuleId.CrossTeamPVP.id)
    local function success(data)
        local array = data.array or {}
        self.defenderNum = TableUtil.GetTableLen(array)
        -- print(8848,">>>>>CrossTeamPVPModel.defenderNum>>>>",self.defenderNum)
        if self.defenderNum == 0 and (not tips) then
            -- RollTips.show(Desc.CrossTeamPVP_noPreArray)
            local const = DynamicConfigData.t_arena[1]
            local function battleHandler(eventName)
                if eventName == "begin" then
                end
            end
            local args = {
                fightID= const.fightId,
                configType = GameDef.BattleArrayType.WorldTeamArena,
                interfaceType = 1, -- 1从主界面进入布阵 2从排序界面进入布阵
                isFirstPrep  = true, 
            }
            Dispatcher.dispatchEvent(EventType.battle_requestFunc,battleHandler,args)
            return
        else
            self.isFirstPrep = false
            ModuleUtil.openModule(ModuleId.CrossTeamPVP.id, true);
		end
    end
    RPCReq.Battle_GetOpponentBattleArray(requseInfo,success)
end


-- 获取开启时间
function CrossTeamPVPModel:getOpenTime()
    local moduleInfo = DynamicConfigData.t_module[ModuleId.CrossTeamPVP.id]
    local conditions = moduleInfo.condition 
    local openDay  = 1  -- 开服第几天开启
    local offsetTime = 0 
    for k,v in pairs(conditions) do
        if v.type == 4 then
            openDay = v.val or 1
            break
        end
    end

    local serverDay = ServerTimeModel:getOpenDay() + 1 -- 当前开服天数
    if (openDay - serverDay) > 0 then
        offsetTime = (openDay - serverDay) * 86400
    end
    return offsetTime
end

-- 组队大厅移除某个玩家
function CrossTeamPVPModel:removePlayerByTypeAndId(reType,playerId)
    for k,v in pairs(self.teamHallInfo) do
        if v.type == reType then
            for o,p in pairs(v.list) do
                if playerId == p.playerId then
                    v.list[o] = nil
                    -- table.remove(v.list,o)
                    break
                end
            end
        end
    end
    if reType == GameDef.WorldTeamArenaPlayerListType.Hall or 
    reType == GameDef.WorldTeamArenaPlayerListType.Friend or 
    reType == GameDef.WorldTeamArenaPlayerListType.Invited then -- 组队大厅
        Dispatcher.dispatchEvent(EventType.CrossTeamPVPTeamHallView_refreshPanel)
    elseif reType == GameDef.WorldTeamArenaPlayerListType.BeInvited then -- 我被邀请界面
        Dispatcher.dispatchEvent(EventType.CrossTeamPVPInviteView_refreshPanel)
    end
end

-- WorldTeamArenaLevel 通过当前积分获取当前段位信息
function CrossTeamPVPModel:getCurDanInfoByIntegral(integral)
    local danCfg = DynamicConfigData.t_WorldTeamArenaLevel
    for k,v in pairs(danCfg) do
        if integral >= v.min and integral <= v.max then
            return v,danCfg[v.id-1]
        end
    end
    return {}
end

function CrossTeamPVPModel:Battle_BattleRecordData(_, param)
    if (self.isFighting == true) then
        self:addFightData(param);
        Dispatcher.dispatchEvent(EventType.Battle_replayRecord,{isRecord=false, battleData=param.battleData});
    end
end

function CrossTeamPVPModel:clearFightData()
    self.fightData = {};
    self.recordIdIdx = 1;
    self.interfaceType = 1
    self.fightIndex = 1
end


function CrossTeamPVPModel:addFightData(data)
    self:setMVPHero(data.battleData)
    table.insert(self.fightData, data.battleData);
    -- printTable(8848,">>>self.fightData>>>",self.fightData)
end

function CrossTeamPVPModel:isCrossTeamPvpType(arrayType)
    if arrayType == GameDef.BattleArrayType.WorldTeamArena then
        return true
    end
    return false
end

-- 开始挑战
function CrossTeamPVPModel:battleBegin()
    local recordIds = {}; -- 回放id列表
    local recordIdIdx = 1; -- 应该播放的录像位置
    local recordIdCount = 3; -- 录像总数
    self:clearFightData();
    self.recordIds = self.battleResultInfo.recordIds or {}
    self.recordIdIdx = 1;

    local battleCall = function (param)
        -- 点击开始战斗
        if (param == 'begin') then
            self.isFighting = true;
            recordIds = self.recordIds
            recordIdCount = #recordIds;
            -- 播放战斗动画
            local recordId = recordIds[recordIdIdx] and recordIds[recordIdIdx] or -1
            local info = {
                recordId     = recordId,
                gamePlayType = GameDef.GamePlayType.WorldTeamArena
            }
            if info.recordId ~= -1 then
                BattleModel:requestBattleRecord(recordId,nil,GameDef.GamePlayType.WorldTeamArena)
            else
                printTable(8848, "======= 服务器数据错误 ======");
            end
            recordIdIdx = recordIdIdx + 1;
            self.fightIndex = 0
        elseif (param == 'next') then
            print(8848, "-------- 下一场战斗播放 -----");
            self.fightIndex = self.fightIndex + 1
            if recordIdIdx ~= 4 then
                local result = self.fightData[recordIdIdx-1].result
                local info = {
                    result = result,  -- 上一场战斗输赢
                    index = recordIdIdx-1, -- 上一场战斗索引
                    battleData = self.fightData, -- 战斗结果
                }
                Dispatcher.dispatchEvent(EventType.CrossTeamPVPAddTopView_refreshPanel,info)
            end
            -- 还有战斗
            self.recordIdIdx = self.recordIdIdx + 1;
            if (recordIdIdx <= recordIdCount) then
                local info = {
                    recordId     = recordIds[recordIdIdx],
                    gamePlayType = GameDef.GamePlayType.WorldTeamArena
                }
				BattleModel:requestBattleRecord(info.recordId,nil,GameDef.GamePlayType.WorldTeamArena)
                recordIdIdx = recordIdIdx + 1;
            else
                local result = self.fightData[recordIdIdx-1].result
                local info = {
                    result = result,  -- 上一场战斗输赢
                    index = 3, -- 上一场战斗索引
                    battleData = self.fightData, -- 战斗结果
                }
                Dispatcher.dispatchEvent(EventType.CrossTeamPVPAddTopView_refreshPanel,info)
                Dispatcher.dispatchEvent("battle_end", {arrayType = GameDef.BattleArrayType.WorldTeamArena});
            end
        elseif (param == "end") then
            print(8848, "====== 战斗结束 ========");
            if (recordIdIdx <= recordIdCount) then
                self:clearFightData();
            end
            ViewManager.open("ReWardView",{page=11, isWin=self.battleResultInfo.isWin,playType = GameDef.GamePlayType.WorldTeamArena})
            self.isFighting = false;
        elseif (param == "cancel") then

        end
    end
    local const = DynamicConfigData.t_HPvPConst[1];
    local args = {
        fightID= const.fightId,
        configType= GameDef.BattleArrayType.WorldTeamArena,
        skipArray = true,
    }
    Dispatcher.dispatchEvent(EventType.battle_requestFunc, battleCall, args);
end

-- 判断有没有人邀请我
function CrossTeamPVPModel:checkHaveInvited()
    if not self.teamHallInfo[GameDef.WorldTeamArenaPlayerListType.BeInvited] then
        self.teamHallInfo[GameDef.WorldTeamArenaPlayerListType.BeInvited] = {}
    end
    local initInfo = self.teamHallInfo[GameDef.WorldTeamArenaPlayerListType.BeInvited].list or {}
    if TableUtil.GetTableLen(initInfo) > 0 then
        return true
    end
    return false
end

-- 判断还能不能挑战
function CrossTeamPVPModel:checkCanChallenge()
    local mainInfo  = self.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open]
    local members   = mainInfo.members or {}
    local canFight  = true
    local leaderId  = mainInfo.leaderId
    local isOnline  = true
    for k,v in pairs(members) do
        if v.restTimes == 0 then
            canFight = false
        end
        if (v.playerId == leaderId) and (v.playerId ~= tonumber(PlayerModel.userid))  then
            isOnline = v.isOnline
        end
    end
    return canFight,TableUtil.GetTableLen(members),mainInfo.isLeader,(mainInfo.isLeadOfflineCanBattle and (not isOnline ))
end


-- 更新奖励红点
function CrossTeamPVPModel:updateRewardRed()
    local config = TaskModel:getAllShowTask( GameDef.TaskCategory.WorldTeamArena )
    local taskFlag = false
    for k,v in pairs(config) do
        local status = TaskModel:getRewardStatus(GameDef.TaskCategory.WorldTeamArena,v.recordId,v.seq)
        if status == 1 then
            taskFlag = true
            break
        end
    end
    RedManager.updateValue("V_CROSSTEAMPVP_REWARD",(taskFlag and (not self.isEnd)))
end

-- 邀请我的红点
function CrossTeamPVPModel:updateInvitedRed()
    -- 先判断邀请列表有没有人邀请
    local haveInvited = self:checkHaveInvited()
    -- 再判断自己的队伍人数是否大于1 
    local mainInfo  = self.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open]
    local members   =   mainInfo.members or {}
    local membersNums = TableUtil.GetTableLen(members) > 1 
    if self.status == GameDef.WorldTeamArenaStatusType.END then
        haveInvited = false
    end
    RedManager.updateValue("V_CROSSTEAMPVP_INVITED",(haveInvited and (not membersNums) and (not self.isEnd )))
end

-- 是否可挑战红点
function CrossTeamPVPModel:updateFightRed()
    local mainInfo  = self.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open]
    local members   = mainInfo.members or {}
    local myId      = tonumber(PlayerModel.userid)
    local canFight  = false
    local restTimes = members[myId].restTimes or 0
    canFight = restTimes > 0
    if self.status == GameDef.WorldTeamArenaStatusType.END then
        canFight = false
    end
    RedManager.updateValue("V_CROSSTEAMPVP_FIGHT",(canFight and (not self.isEnd )))
end

function CrossTeamPVPModel:updateRed()
    self:updateRewardRed()
    self:updateInvitedRed()
    self:updateFightRed()
    GlobalUtil.delayCallOnce("CrossTeamPVPModel:redCheck",function()
        Dispatcher.dispatchEvent(EventType.CrossTeamPVPMainView_refreshPanel)
    end, self, 0.1)
end

function CrossTeamPVPModel:loginPlayerDataFinish()
    local requseInfo = {
        fightId	= 1070000,
        playerId = tonumber(PlayerModel.userid),
        gamePlay = GameDef.BattleArrayType.WorldTeamArena,
    }
    -- printTable(8848,">>>requseInfo>>",requseInfo)
    local function success(data)
        local array = data.array or {}
        -- printTable(8848,">>>>Battle_GetOpponentBattleArray>>>data>>")
        if TableUtil.GetTableLen(array) > 0 then
            -- printTable(8848,">>>Battle_GetOpponentBattleArray>>进来了")
            self:reqGetPlayerInfo()
        end
    end
    RPCReq.Battle_GetOpponentBattleArray(requseInfo,success)
    self:reqGetCurMatchStatus()
end


-- 设置入口数据
function CrossTeamPVPModel:getMainSubInfo(fun)
    local reqInfo = {

    }
    -- RPCReq.WorldTeamArena_GetCurMatchStatus(reqInfo,function(params)
    --     printTable(8848,">>>>WorldTeamArena_GetCurMatchStatus>>>比赛状态>>>",params)
    --     self.status = params.status or GameDef.WorldTeamArenaStatusType.END
        local myId  = tonumber(PlayerModel.userid)
        local members = self.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open] or {} 
        local myInfo = {}
        if members and members.members and members.members[myId] then
            myInfo = members.members[myId] or {}
        end
        local danInfo = self:getCurDanInfoByIntegral(myInfo.score or 0) 
        local danName = danInfo.name
        local danIcon = string.format("Icon/rank/%s.png", danInfo.icon)
    
        local ServerTime    = ServerTimeModel:getServerTime()
        local data = {}
        data.dayTimes = self.restTimes
        data.seasonTime = TimeLib.nextWeekBeginTime() - ServerTime--math.floor(activeEndTime/1000) - ServerTime 
        data.rank    = self:getRankByPlayerId(myId) or Desc.Rank_notInRank
        data.danName = danName
        data.danIcon = danIcon
        data.red     = "V_CROSSTEAMPVP"
        data.moduleId = ModuleId.CrossTeamPVP.id
    
        fun(data)
        Dispatcher.dispatchEvent(EventType.CrossTeamPVPMainView_refreshPanel)
    -- end)
end

function CrossTeamPVPModel:setMVPHero(battleData)
    if battleData then
        local groupInfo = battleData.groupInfo
        local myId = tonumber(PlayerModel.userid)  
        local haveMe = false
        for k,v in pairs(groupInfo) do
            if v.playerId == myId then
                haveMe = true
                break
            end
        end
        if haveMe then
            self.mvpHero = ModelManager.BattleModel:getMVPHero(1,battleData.battleObjSeq)
        end
    end
end

function CrossTeamPVPModel:getMVPHero()
    return self.mvpHero 
end


return CrossTeamPVPModel
