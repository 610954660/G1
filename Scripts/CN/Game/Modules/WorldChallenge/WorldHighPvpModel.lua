-- add by zn
-- 世界竞技场 天境赛模式

local WorldHighPvpModel = class("WorldHighPvpModel", BaseModel)

function WorldHighPvpModel:ctor()
    -- self:initListeners()
    self.WorldChallengeGuessRed = {}
    self.hasChageRed = false
    self.hasChange = false
    self.WorldChallengeActiveTime = {}
    self.playerMap = {}  -- 对战玩家信息
    self.WorldChallenInfo = {} -- 赛事信息
    self.guessInfo = {} --竞猜信息
    self.HonourInfo = {} --名人堂信息
    self.joinBattleInfo = {} --我的比赛信息
    -- self.WorldChallenFirstLogin={} --擂台赛首次登陆
    self.WorldChallenJingCaiRed = false --擂台赛竞猜红点
    self.guessIsRead = true
end

function WorldHighPvpModel:isActiveIng() --在活动中
    local map = self.WorldChallenInfo
    if not map or not map.stage then
        return false
    end
    if map.stage and map.stage ~= GameDef.WorldArenaStageType.End or map.stage ~= GameDef.WorldArenaStageType.Closed then
        return true
    end
    return false
end

--#获取跨服分组活动信息
function WorldHighPvpModel:getWorldChallengeInfo()
    local function success(data)
        -- printTable(2233, "getWorldChallengeInfo", data)
        if data and data.unitInfo then
            self:setWorldChallengeInfo(data.unitInfo)
        else
            self.WorldChallenInfo = {}
            self.guessInfo = {}
            self.playerMap = {}
            self.joinBattleInfo = {}
        end
        Dispatcher.dispatchEvent(EventType.worldChallenge_daojishishuaxing, {modeType = 1})
    end
    local info = {}
    RPCReq.WorldSkyPvp_GetUnitInfo(info, success)
end

-- End = 0,--结束阶段
-- 	Prepare = 1,--准备阶段可以竞猜和可以调整阵容
-- 	Wait = 2,--等待阶段可以竞猜不能调整阵容
-- 	Battle = 3,--战斗阶段不能竞猜和调整阵容
-- assignId                    1:integer       #跨服分组id
-- stage                       2:integer       #活动阶段
-- actState                    3:integer       #当前活动状态
-- nextBattleStamp             4:integer       #下一次战斗时间戳(如果活动状态是已结束或者是战斗状态, 则忽略吧)

-- promotionGroupInfo          5:*WorldArena_GroupInfo(groupId)    #晋级赛小组数据
-- finalsInfo                  6:WorldArena_MatchInfo              #决赛数据
-- battlePlayerInfo            7:*WorldArena_BattlePlayerInfo(playerId)    #对战玩家信息
-- guessInfo                   8:WorldArena_PlayerGuessInfo        #竞猜信息

-- #joinBattleInfo              *:WorldArena_JoinBattleInfo         #我的比赛信息
--ModelManager.PlayerModel.userid
function WorldHighPvpModel:setWorldChallengeInfo(info)
    self.WorldChallenInfo = {}
    self.guessInfo = {}
    self.playerMap = {}
    self.joinBattleInfo = {}
    for key, value in pairs(info.battlePlayerInfo) do
        if value.playerId <= 0 then
            local configInfo = DynamicConfigData.t_ArenaRobot[math.abs(value.playerId)]
            if configInfo then
                value.name = configInfo.name
                value.level = configInfo.level
                value.head = configInfo.head
                local fightConf = DynamicConfigData.t_fight[configInfo.fightId];
                if (fightConf) then
                    value.combat = fightConf.monstercombat;
                else
                    value.combat=0
                end
            end
        end
    end
    self.playerMap = info.battlePlayerInfo
    self.guessInfo = info.guessInfo
    if (self.guessInfo.recordList) then
        local recordList = self.guessInfo.recordList
        if recordList and recordList[#recordList] and recordList[#recordList].record then
            if recordList[#recordList].record.isRead == false then
                self.guessIsRead = false;
            end
        end
    end
    self.joinBattleInfo = info.joinBattleInfo or {}
    self:setHasMychallge()
    self.WorldChallenInfo["assignId"] = info.assignId
    self.WorldChallenInfo["stage"] = info.stage
    self.WorldChallenInfo["actState"] = info.actState
    self.WorldChallenInfo["nextBattleStamp"] = info.nextBattleStamp

    local promotionGroupInfo = info.promotionGroupInfo -- 小组赛数据
    local finalsInfo = info.finalsInfo -- 决赛数据
    if promotionGroupInfo then
        for key, value in pairs(promotionGroupInfo) do
            local groupId = value.groupId
            local itemInfo = value.matchInfo
            for k1, v1 in pairs(itemInfo.playerInfo) do
                local v1key = WorldChallengeModel:getPoskey(100, groupId, v1.pos)
                self.WorldChallenInfo[v1key] = v1
            end
            if itemInfo.battleInfo then
                for k2, v2 in pairs(itemInfo.battleInfo) do
                    local stage = v2.stage
                    for k3, v3 in pairs(v2.battlePosInfoMap) do
                        local pos = v3.pos
                        local v3key = WorldChallengeModel:getPoskey(stage, groupId, pos)
                        if v3 and v3.winner and v3.winner ~= 0 then
                            v3["playerId"] = v3.winner
                            self.WorldChallenInfo[v3key] = v3
                        end
                    end
                end
            end
        end
    end

    if finalsInfo then
        local groupId = 0
        local itemInfo = finalsInfo
        for k1, v1 in pairs(itemInfo.playerInfo) do
            local v1key = WorldChallengeModel:getPoskey(100, groupId, v1.pos)
            self.WorldChallenInfo[v1key] = v1
        end
        for k2, v2 in pairs(itemInfo.battleInfo) do
            local stage = v2.stage
            for k3, v3 in pairs(v2.battlePosInfoMap) do
                local pos = v3.pos
                local v3key = WorldChallengeModel:getPoskey(stage, groupId, pos)
                if v3 and v3.winner and v3.winner ~= 0 then
                    v3["playerId"] = v3.winner
                    self.WorldChallenInfo[v3key] = v3
                end
            end
        end
    end
end

-- 设置自己参赛情况
function WorldHighPvpModel:setHasMychallge()
    local has = false
    if next(self.joinBattleInfo) ~= nil then
        has = true
    end
    self.hasChange = has
end

function WorldHighPvpModel:getPlayerItem(groupId, itemKey)
    if not self.WorldChallenInfo then
        return 0
    end
    local infoKey = groupId .. "_" .. itemKey
    local itemInfo = self.WorldChallenInfo[infoKey]
    if not itemInfo then
        return 0
    end

    local tag = 0 --0空白
    local arr = string.split(itemKey, "_")
    local key = tonumber(arr[1])
    local pos = tonumber(arr[2])
    local nextKey = WorldChallengeModel:getNextKey(key, pos)
    local nextArr1 = {"2_1", "1_1", "0_1"}
    local nextArr2 = {"2_2", "1_1", "0_1"}
    local nextArr3 = {"2_3", "1_2", "0_1"}
    local nextArr4 = {"2_4", "1_2", "0_1"}
    local winner = 0
    if table.indexof(nextArr1, nextKey) ~= false then
        local pos=table.indexof(nextArr1, nextKey)
        winner = self:getPlayerWiner(groupId, nextArr1,pos)
    elseif table.indexof(nextArr2, nextKey) ~= false then
        local pos=table.indexof(nextArr2, nextKey)
        winner = self:getPlayerWiner(groupId, nextArr2,pos)
    elseif table.indexof(nextArr3, nextKey) ~= false then
        local pos=table.indexof(nextArr3, nextKey)
        winner = self:getPlayerWiner(groupId, nextArr3,pos)
    elseif table.indexof(nextArr4, nextKey) ~= false then
        local pos=table.indexof(nextArr4, nextKey)
        winner = self:getPlayerWiner(groupId, nextArr4,pos)
    end
    if winner~=0 and itemInfo.playerId~=winner then
        tag = 2
    else
        tag = 3
    end
    return tag
end


function WorldHighPvpModel:getPlayerWiner(groupId, nextArr1,pos)
    local winner = 0
    for i = 1, #nextArr1, 1 do
        if i>=pos then
            local nextinfoKey = groupId .. "_" .. nextArr1[i]
            local nextInfo = self.WorldChallenInfo[nextinfoKey]
            if nextInfo then
                winner = nextInfo.winner
            end
        end
    end
    return winner
end


function WorldHighPvpModel:getLineBarState(groupId, lineId)
    local arr = string.split(lineId, "_")
    local key = tonumber(arr[1])
    local pos = tonumber(arr[2])
    local oldKey = 1
    local oldPosshang = 1
    local oldPosXia = 2
    local isshuang = false
    local curKey = groupId .. "_" .. lineId
    if key == 2 then
        oldPosshang = pos * 2 - 1
        oldPosXia = pos * 2
        isshuang = true
    elseif key == 1 and pos >= 1 and pos <= 2 then
        oldPosshang = 1
        oldPosXia = 2
        curKey = groupId .. "_1_1"
    elseif key == 1 and pos >= 3 and pos <= 4 then
        oldPosshang = 3
        oldPosXia = 4
        curKey = groupId .. "_1_2"
    elseif key == 0 then
        oldPosshang = pos * 2 - 1
        oldPosXia = pos * 2
    end
    oldKey = key + 1
    local shangItemkey = groupId .. "_" .. oldKey .. "_" .. oldPosshang
    local xiaItemkey = groupId .. "_" .. oldKey .. "_" .. oldPosXia
    local curItem = self.WorldChallenInfo[curKey]
    if lineId == "1_2" then
    -- printTable(31, "111111111", curKey, shangItemkey, xiaItemkey, curItem)
    end
    local shangItem = self.WorldChallenInfo[shangItemkey]
    local xiaItem = self.WorldChallenInfo[xiaItemkey]
    if not curItem then
        return false
    end
    if isshuang and pos <= 2 then
        if curItem and shangItem and curItem.playerId == shangItem.playerId then
            return 1
        end
        if curItem and xiaItem and curItem.playerId == xiaItem.playerId then
            return 2
        end
    elseif isshuang and pos >= 2 and pos <= 4 then
        if curItem and shangItem and curItem.playerId == shangItem.playerId then
            return 2
        end
        if curItem and xiaItem and curItem.playerId == xiaItem.playerId then
            return 1
        end
    else
        if curItem and shangItem and curItem.playerId == shangItem.playerId and pos % 2 ~= 0 then
            return true
        end
        if curItem and xiaItem and curItem.playerId == xiaItem.playerId and pos % 2 == 0 then
            return true
        end
        if curItem and xiaItem and shangItem and key == 0 and pos == 1 then --最后一个
            return true
        end
    end
    return false
end

function WorldHighPvpModel:getHasOpen()
    local isOpen = true
    if self.WorldChallenInfo.actState and self.WorldChallenInfo.actState == 4 then
        isOpen = false
    end
    return isOpen
end

-- function WorldHighPvpModel:getChallengeIdex() --得到当前的分组
--     local index = self:getGuessinggroupId()
--     local indexTable = {}
--     index = math.min(6, math.max(1, index))
--     table.insert(indexTable, index)
--     table.insert(indexTable, index + 1)
--     table.insert(indexTable, index + 2)
--     return index, indexTable
-- end

function WorldHighPvpModel:hasGuessingResult() --得到竞猜记录
    if not self.guessInfo then
        return false, nil
    end

    if not self.guessInfo.recordList then
        return false, nil
    end
    local recordList = self.guessInfo.recordList
    if recordList and recordList[#recordList] and recordList[#recordList].record then
        if self.guessIsRead == false then
            return true, recordList[#recordList].record.result
        else
            return false, nil
        end
    end
    return false, nil
end

function WorldHighPvpModel:hashuifangRecordId(itemKey) --得到录像id
    local itemPosKey = itemKey
    local has = false
    local recordArr = {}
    local playerInfo = self.WorldChallenInfo[itemPosKey]
    if playerInfo and playerInfo.battleResult and playerInfo.battleResult[1] and playerInfo.battleResult[1].arrayResult then
        local list = {}
        for _, info in pairs(playerInfo.battleResult[1].arrayResult) do
            if (info.recordId) then
                has = true
                table.insert(list, info)
            end
        end
        recordArr = list
    end
    return has, recordArr
end

function WorldHighPvpModel:hasGuessingRecord() --得到竞猜记录
    if not self.guessInfo then
        return false
    end

    if not self.guessInfo.recordList then
        return false
    end
    if not self.guessInfo.recordList[#self.guessInfo.recordList] then
        return false
    end
    local recordList = self.guessInfo.recordList[#self.guessInfo.recordList]
    return recordList
end

function WorldHighPvpModel:getshangGuessingRecordId() --上一场竞猜战斗记录id
    if not self.guessInfo then
        return false
    end

    if not self.guessInfo.recordList then
        return false
    end
    if not self.guessInfo.recordList[#self.guessInfo.recordList] then
        return false
    end
    local recordList = self.guessInfo.recordList[#self.guessInfo.recordList]
    local guessInfo1 = recordList.record
    local pos = guessInfo1.pos
    local groupId = guessInfo1.groupId
    local stage = guessInfo1.stage
    local PlayerInfoKey = WorldChallengeModel:getPoskey(stage, groupId, pos)
    local has, recordArr = self:hashuifangRecordId(PlayerInfoKey)
    if has then
        return recordArr
    end
    return false
end

function WorldHighPvpModel:getGuessinggroupId() --得到竞猜分组
    local groupId = 0
    if self.guessInfo and self.guessInfo.guessInfo and self.guessInfo.guessInfo.guessInfo then
        groupId = self.guessInfo.guessInfo.guessInfo.groupId
    end
    return groupId
end

function WorldHighPvpModel:getGuessinggroupPos(clientGroupId, i) --得到竞猜玩家位置
    local pos = 0
    --printTable(31,"sssssssssssssssssssssss",self.guessInfo)
    if self.guessInfo and self.guessInfo.guessInfo and self.guessInfo.guessInfo.guessInfo then
        local jingcaiinfo = self.guessInfo.guessInfo.guessInfo
        --后端这命名是真的服了字段名权全一样
        local stage = jingcaiinfo.stage
        local groupId = jingcaiinfo.groupId
        local serverPos = jingcaiinfo.pos
        if clientGroupId == groupId then
            local itemKey = 3
            if stage == GameDef.WorldArenaStageType.PromotionRound6 then
                itemKey = 2
            elseif stage == GameDef.WorldArenaStageType.PromotionRound5 then
                itemKey = 1
            elseif stage == GameDef.WorldArenaStageType.PromotionRound4 then
                itemKey = 0
            elseif stage == GameDef.WorldArenaStageType.FinalRound3 then
                itemKey = 2
            elseif stage == GameDef.WorldArenaStageType.FinalRound2 then
                itemKey = 1
            elseif stage == GameDef.WorldArenaStageType.FinalRound1 then
                itemKey = 0
            end
            local oldKey = 1
            local oldPosshang = 1
            local oldPosXia = 2
            oldKey = itemKey + 1
            oldPosshang = serverPos * 2 - 1
            oldPosXia = serverPos * 2
            local curKey = groupId .. "_" .. itemKey .. "_" .. serverPos
            local shangItemkey = groupId .. "_" .. oldKey .. "_" .. oldPosshang
            local xiaItemkey = groupId .. "_" .. oldKey .. "_" .. oldPosXia
            local curItem = self.WorldChallenInfo[curKey]
            local shangItem = self.WorldChallenInfo[shangItemkey]
            local xiaItem = self.WorldChallenInfo[xiaItemkey]
            local jingcaiId = self:getGuessingPlayer()
            if shangItem and jingcaiId == shangItem.playerId then
                pos = oldKey .. "_" .. oldPosshang
            end
            if xiaItem and jingcaiId == xiaItem.playerId then
                pos = oldKey .. "_" .. oldPosXia
            end
        end
    end
    return pos
end

function WorldHighPvpModel:getGuessingPlayer() --得到竞猜玩家id
    local playerId = 0
    if self.guessInfo and self.guessInfo.guessInfo and self.guessInfo.guessInfo.guessInfo then
        playerId = self.guessInfo.guessInfo.guessInfo.playerId
    end
    return playerId
end

function WorldHighPvpModel:getGuessingTwoPlayer() --得到竞猜2个玩家
    return self.guessInfo.guessInfo.playerInfo
end

function WorldHighPvpModel:getGuessing() --得到竞猜信息
    return self.guessInfo.guessInfo
end

function WorldHighPvpModel:getCanGuessing() --0活动没开无法竞猜，1活动开了可以竞猜，2活动开了但已经在比赛中无法竞猜
    local can = 0
    local isActive = self:isActiveIng()
    local canGuess = self:isCanGuessIng()
    if isActive == false or not self.guessInfo.guessInfo then
        can = 0
    elseif isActive == true and canGuess == true then
        can = 1
    elseif isActive == true and canGuess == false then
        can = 2
    end
    return can
end

function WorldHighPvpModel:isCanBattleArray() --在比赛中可换阵容
    local isActive = self:isActiveIng()
    local map = self.WorldChallenInfo
    if not map or not map.actState then
        return false
    end
if isActive and map and map.actState and map.actState == GameDef.WorldArenaActStateType.Prepare then
        return true
    end
    return false
end


function WorldHighPvpModel:isCanGuessIng() --在比赛中可竞猜
    local isActive = self:isActiveIng()
    local map = self.WorldChallenInfo
    if not map or not map.actState then
        return false
    end
    if
        isActive and map and map.actState and map.actState == GameDef.WorldArenaActStateType.Prepare or
            map.actState == GameDef.WorldArenaActStateType.Wait
     then
        return true
    end
    return false
end

function WorldHighPvpModel:getcanChange() --自己是否参赛
    return self.hasChange
end

function WorldHighPvpModel:getOpponentInfo() --擂台赛对手数据
    local temp = {}
    if self.joinBattleInfo and self.joinBattleInfo.enemyInfo and self.joinBattleInfo.enemyInfo.playerInfo then
        temp = self.joinBattleInfo.enemyInfo.playerInfo
        temp["battleArrayInfo"] = self.joinBattleInfo.enemyInfo.battleArrayInfo
    end
    return temp
end

function WorldHighPvpModel:getMyopponentId() --擂台赛对手id
    local id = 0
    if self.joinBattleInfo and self.joinBattleInfo.enemyInfo and self.joinBattleInfo.enemyInfo.playerInfo then
        id = self.joinBattleInfo.enemyInfo.playerInfo.playerId
    end
    return id
end

function WorldHighPvpModel:isOpenGuanjunSai()
    local map = self.WorldChallenInfo
    if not map or not map.stage then
        return false
    end
    if
        map.stage and map.stage ~= GameDef.WorldArenaStageType.PromotionRound6 and
            map.stage ~= GameDef.WorldArenaStageType.PromotionRound5 and
            map.stage ~= GameDef.WorldArenaStageType.PromotionRound4
     then
        return true
    end
    return false
end

--#竞猜请求
function WorldHighPvpModel:GuessReq(stage, groupId, pos, supportId)
    local function success(data)
        if data.guessInfo then
            if not self.guessInfo.guessInfo then
                self.guessInfo.guessInfo = {}
            end
            self.guessInfo.guessInfo = data.guessInfo
        end
        self.WorldChallenJingCaiRed = false;
        RedManager.updateValue("V_WORLDCHALLENG_JINCAI", false)
        Dispatcher.dispatchEvent(EventType.worldChallenge_dianjijincai)
    end
    local info = {
        stage = stage, --1:integer
        groupId = groupId, --2:integer   #分组id
        pos = pos, --3:integer   #战斗编号
        supportId = supportId --4:integer   #投票的玩家id
    }
    printTable(16, "竞猜请求信息", info)
    RPCReq.WorldSkyPvp_GuessReq(info, success)
end

--#查看战斗记录
function WorldHighPvpModel:seeCombatlog(recordArr, PlayerInfoKey)
    local keys = string.split(PlayerInfoKey, "_");
    local groupId = keys[1]
    local pos1, pos2 = tonumber(keys[2]), tonumber(keys[3])
    local curPlayInfo = self.WorldChallenInfo[PlayerInfoKey];
    -- 前两位信息
    local pos1 = pos1 + 1
    local pos2_1 = pos2 * 2 - 1
    local pos2_2 = pos2_1 + 1
    local posInfoKey1 = string.format("%s_%d_%d", groupId, pos1, pos2_1)
    local posInfoKey2 = string.format("%s_%d_%d", groupId, pos1, pos2_2)
    local player1 = self.WorldChallenInfo[posInfoKey1]
    local player2 = self.WorldChallenInfo[posInfoKey2]
    local p1 = self.playerMap[player1.playerId]
    local p2 = player2 and self.playerMap[player2.playerId] or {}
    local info = {
        ackName = p1.name,
        defName = p2.name,
        isWin = player1.playerId == curPlayInfo.playerId,
        arrayType = 4005,--GameDef.BattleArrayType.WorldSkyPvpDefOne
        serverId=p1.serverId,
		gamePlayType=GameDef.GamePlayType.WorldSkyPvp
    }
	printTable(5656,info,"self._args.info")

    TableUtil.sortByMap(recordArr, {{key = "arrayType", asc = false}})
    HigherPvPModel.fightData = {}
    HigherPvPModel.recordIds = recordArr
    ViewManager.open("HigherPvPResultView", info)
end

--#查看名人堂
function WorldHighPvpModel:seeHalloffame()
    local function success(data)
        printTable(28, "查看名人堂返回", data)
        if data and data.honourInfo then
            self.HonourInfo = data.honourInfo
        end
        Dispatcher.dispatchEvent(EventType.worldChallenge_HonourInfoupdateInfo)
    end
    local info = {}
    RPCReq.WorldSkyPvp_GetHonourInfo(info, success)
end

--#获取当前分组指定玩家战斗阵容信息
function WorldHighPvpModel:getBattlePlayerInfo(playerId)
    local function success(data)
        if data and data.playerInfo then
            self.joinBattleInfo["enemyInfo"] = data.playerInfo
        end
        printTable(32, "获取当前分组指定玩家战斗阵容信息", data)
        Dispatcher.dispatchEvent(EventType.worldChallenge_dianjiwodebisaixiugaizhenrong)
    end
    local params = {
        playerId = playerId --1:integer       #玩家id
    }
    RPCReq.WorldSkyPvp_GetBattlePlayerInfo(params, success)
end

--#获取当前竞猜对阵玩家阵容信息
function WorldHighPvpModel:GetGuessInfo()
    local function success(data)
        printTable(150, "获取当前竞猜对阵玩家阵容信息", data)
        if data.guessInfo then
            if not self.guessInfo.guessInfo then
                self.guessInfo.guessInfo = {}
            end
            self.guessInfo.guessInfo = data.guessInfo
        end
        Dispatcher.dispatchEvent(EventType.worldChallenge_dianjijincai)
    end
    local params = {}
    RPCReq.WorldSkyPvp_GetGuessInfo(params, success)
end

--#获取当前竞猜对阵玩家阵容信息
function WorldHighPvpModel:setBattleArrayState()
    local function success(data)
    end
    local params = {}
    RPCReq.WorldSkyPvp_SetBattleArrayState(params, success)
end

function WorldHighPvpModel:isWoroldHighPvpArrayType(arrayType)
    return arrayType == GameDef.BattleArrayType.WorldSkyPvpDefOne
	or arrayType == GameDef.BattleArrayType.WorldSkyPvpDefThree
    or arrayType == GameDef.BattleArrayType.WorldSkyPvpDefSix
    or arrayType == 4005
end

function WorldHighPvpModel:getArrayTypeByIndex(index)
    if index == 1 then
        return GameDef.BattleArrayType.WorldSkyPvpDefOne
    elseif index == 2 then
        return GameDef.BattleArrayType.WorldSkyPvpDefThree
    elseif index == 3 then
        return GameDef.BattleArrayType.WorldSkyPvpDefSix
    end
end

function WorldHighPvpModel:getArrayType()
    return {
        GameDef.BattleArrayType.WorldSkyPvpDefOne,
        GameDef.BattleArrayType.WorldSkyPvpDefThree,
        GameDef.BattleArrayType.WorldSkyPvpDefSix
    }
end

-- 把我的比赛的敌人信息转化成战斗上阵用的数据结构
function WorldHighPvpModel:getGuessEnemyInfoToBattle(type)
    -- local guessInfo = self:getOpponentInfo()
    local enemyInfo = self:getOpponentInfo()--guessInfo.playerInfo[2]
    if (enemyInfo) then
        local array = enemyInfo.battleArrayInfo and enemyInfo.battleArrayInfo[type] or {}
        local combat = 0;
        local heroInfos = {}
        if (array.posInfo) then
            for _, info in pairs(array.posInfo) do
                local d = {
                    code = info.code,
                    combat = info.combat,
                    id = info.pos,
                    level = info.level,
                    star = info.star,
                    type = 2
                }
                combat = combat + d.combat
                table.insert(heroInfos, d)
            end
            return {
                combat = combat,
                heroInfos = heroInfos
            }
        end
    end
    return false
end

-- 进入玩法保存一遍精灵阵容
function WorldHighPvpModel:saveElvesBattle(planIndex)
    if TableUtil.GetTableLen(ElvesSystemModel:getElvesEnterData(1)) == 0 and 
    TableUtil.GetTableLen(ElvesSystemModel:getElvesEnterData(2)) == 0 and 
    TableUtil.GetTableLen(ElvesSystemModel:getElvesEnterData(3)) == 0 then
        Dispatcher.dispatchEvent(EventType.ElvesAddTopView_refresh)
        return
    end
    local arrayType = GameDef.BattleArrayType.WorldSkyPvpDefOne
    local reqInfo = {
            arrayType = arrayType, -- 阵容类型
            planId    = planIndex, -- 方案id
        }
    RPCReq.Elf_SetArraysPalnId(reqInfo,function(params)
        Dispatcher.dispatchEvent(EventType.ElvesAddTopView_refresh)
    end)
    RPCReq.Elf_SetArraysPalnId({arrayType = GameDef.BattleArrayType.WorldSkyPvpDefOne,planId = planIndex,},function(params)
    end)
    RPCReq.Elf_SetArraysPalnId({arrayType = GameDef.BattleArrayType.WorldSkyPvpDefThree,planId = planIndex,},function(params)
    end)
    RPCReq.Elf_SetArraysPalnId({arrayType = GameDef.BattleArrayType.WorldSkyPvpDefSix,planId = planIndex,},function(params)
    end)
    printTable(8848,">>>>>精灵>>>保存天境赛世界擂台赛防守阵容>>>>>")
end

return WorldHighPvpModel