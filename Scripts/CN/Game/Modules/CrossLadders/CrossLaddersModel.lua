--Date :2020-12-30
--Author : generated by FairyGUI
--Desc : 

local CrossLaddersModel = class("CrossLadders", BaseModel)
local TimeLib = require "Game.Utils.TimeLib"
local TimeUtil = require "Game.Utils.TimeUtil"

function CrossLaddersModel:ctor()
    self.ladderBaseInfo = {}    -- 基础信息
    self.challengeList  = {}    -- 挑战列表
    self.usedTimes      = 0     -- 已使用的免费次数
    self.buyTimes       = 0     -- 今日已购买次数
    self.recordInfo     = {}    -- 战斗记录数据
    self.likeInfo       = {}    -- 点赞数据
    self.result         = false -- 战斗结算结果
    self.allTeamInfo    = {}
    self.heroHouseInfo  = {}     -- 英雄殿信息
    self.myEndInfo      = {}
    self.otherEndInfo   = {}
    self.myOldRank      = false
    self.myNewRank      = false
    self.myRank         = false
    self.status         = false
    self.haveQualif     = false -- 判断有没有资格
    self.recordFightMs = false
    self.join   = false
    self.houseInfo      = {}
    self:initListeners()
end

function CrossLaddersModel:init()
end

function CrossLaddersModel:getHaveTimes()
    local tiems = DynamicConfigData.t_SkyLadder[1].freeTimes
    --tiems = tiems+self.buyTimes -self.usedTimes
    tiems = tiems - self.usedTimes
    if (not self.join)  or (not self:checkIsOpen()) then
        tiems = 0  
    end
    return tiems
end

-- 判断有没有 抵扣挑战次数的物品
function CrossLaddersModel:checkHaveFightItem()
    local conf = DynamicConfigData.t_SkyLadder[1]
    local ticketCode = conf.ticketCode
    local haveNum = PackModel:getItemsFromAllPackByCode(ticketCode) or 0

    return haveNum > 0
end


function CrossLaddersModel:noQualif()
    if (not self.haveQualif) then
        RollTips.show(Desc.CrossLadders_str16)
        return false
    end
    return true
end

function CrossLaddersModel:initSkyLadder_PlayerData(data)   
    self.haveQualif = data.join or false
    self.usedTimes  = data.usedTimes or 0
    self.buyTimes   = data.buyTimes or 0   
    self.myRank     = data.rank or false
    self.likeInfo   = data.likeList or {}
    self.join       = data.join or false
    local moduleIsOpen = (not ModuleUtil.getModuleOpenTips(ModuleId.CrossLadders.id))
    if moduleIsOpen then
        RPCReq.SkyLadder_GetHeroHouse({},function(params)
            self.houseInfo = params.data or {}
            printTable(8848,">>>self.houseInfo>>>",self.houseInfo)
            self:updateRed()
        end)
    end
end

function CrossLaddersModel:initSkyLadder_UpdateStatus(data)   
    self.status = data.status
    self:updateRed()
end


-- #获取天梯赛信息
-- SkyLadder_GetInfo 18225 {
-- 	request {	
-- 	}
-- 	response {
-- 		info			1:PSkyLadder_BaseInfo	#基础信息
-- 	}
-- }
-- #跨服天梯赛基础信息
-- .PSkyLadder_BaseInfo {
-- 	rank 			1:integer  # 排名
-- 	useTimes 		2:integer  # 已使用的次数
-- 	buyTimes 		3:integer  # 已购买次数
-- 	likeList		4:*LikeData(rank) # 点赞次数
-- }
-- .LikeData {
-- 	rank 			1:integer  # 排名
-- 	like 			2:boolean  # 是否点赞
-- }
function CrossLaddersModel:reqSkyLadder_GetInfo()
    local ll = 1
    local reqInfo = {

    }
    RPCReq.SkyLadder_GetInfo(reqInfo,function(params) 
        printTable(8849,">>>>SkyLadder_GetInfo>>主界面请求>>>",params)
        self.ladderBaseInfo = params.info or {}
        -- self.likeInfo = self.ladderBaseInfo.likeList or {}
        self:updateRed()
        Dispatcher.dispatchEvent(EventType.CrossLaddersMainView_refreshPanel)
    end)
end

-- #获取挑战列表
-- SkyLadder_GetChallengeList 14856 {
-- 	request {
-- 	}
-- 	response {
-- 		challengeList 	0:PSkyLadder_ChallengeList	#挑战列表
-- 	}	
-- }
-- .PSkyLadder_ChallengeList {
-- 	rankData 		1:*ChallengeData
-- 	myRankData		2:ChallengeData
-- }
-- .ChallengeData {
-- 	id				1:integer		#玩家id
-- 	name 			2:string  		#玩家名字
-- 	level 			3:integer 		#玩家等级
-- 	head 			4:integer		#头像
-- 	guildName 		5:string  		#公会名字
-- 	combat			6:integer		#战力
-- 	serverId		7:integer		#服务id
-- 	rank 			8:integer		#排名 部分排行榜有使用到
-- 	headBorder 		9:integer 		#头像框
-- }
function CrossLaddersModel:reqSkyLadder_GetChallengeList(isChallenge)
    local reqInfo = {

    }
    RPCReq.SkyLadder_GetChallengeList(reqInfo,function(params) 
        -- printTable(8849,">>>SkyLadder_GetChallengeList>>挑战列表>>>",params)
        self.challengeList = params.challengeList or {}
        self:updateRed()
        Dispatcher.dispatchEvent(EventType.CrossLaddersMainView_refreshPanel)
    end)
end


-- #开始挑战 占坑
-- SkyLadder_ChallengeStart 213 {
-- 	request {
-- 		playerId 		0:integer				#挑战的玩家id
-- 		rank 			1:integer 				#排名
-- 	}
	
-- 	response {
-- 		res 			0:boolean   			#是否成功
-- 	}
-- }
function CrossLaddersModel:reqSkyLadder_ChallengeStart(playerId,rank,otherEndInfo,myOldRank)
    local reqInfo = {
        playerId = playerId,
        rank = rank,
    }
    RPCReq.SkyLadder_ChallengeStart(reqInfo,function(params)  
        printTable(8848,">>>>params>>>SkyLadder_ChallengeStart>>",params)
        if params.res then
            self:reqSkyLadder_Challenge(playerId,rank)
            self.myOldRank = myOldRank
            self.otherEndInfo = otherEndInfo or {}
            self:updateRed()
            self:setCheckTips()
            ViewManager.close("FriendCheckView")
            ViewManager.close("CrossLaddersFightTipsView")
        end
    end)
end


-- #挑战
-- SkyLadder_Challenge 12800 {
-- 	request {
-- 		playerId 		0:integer				#挑战的玩家id
-- 		rank 			1:integer 				#排名
-- 	}
	
-- 	response {
-- 		usedTimes		1:integer				#已使用的免费次数
-- 	}
-- }
function CrossLaddersModel:reqSkyLadder_Challenge(playerId,rank)

    local reqInfo = {
        playerId = playerId,
        rank = rank,
    }
    local const = DynamicConfigData.t_HPvPConst[1];
   
        Dispatcher.dispatchEvent(EventType.battle_requestFunc,function(eventName)
            local figthData = {}
            if eventName == "begin" then
                RPCReq.SkyLadder_Challenge(reqInfo,function(params) 
                    self.usedTimes = params.usedTimes or 0
                    local res = params.res
                    local battleData    = FightManager.getBettleData(GameDef.BattleArrayType.SkyLadderAck)
                    self.result =  battleData.result
                    for k,v in pairs(res) do
                        if tonumber(PlayerModel.userid) == v.playerId then
                            self.myNewRank = v.rank
                        end
                    end
                    Dispatcher.dispatchEvent(EventType.CrossLaddersMainView_refreshPanel)
                end)
            end

            if eventName == "next" then
            end

            if eventName == "end" then
                self:reqSkyLadder_GetChallengeList()
                ViewManager.open("ReWardView",{page=13, isWin=self.result,gameType = GameDef.GamePlayType.SkyLadder,playType = GameDef.GamePlayType.SkyLadder})
            end
        end,{fightID=const.fightId,configType=GameDef.BattleArrayType.SkyLadderAck})
end

-- #购买门票
-- SkyLadder_Buy 30028 {
-- 	request {
-- 		num 			0:integer			#门票数		
-- 	}
-- 	response {
-- 		buyTimes		1:integer			#今日已购买次数
-- 	}
-- }
function CrossLaddersModel:reqSkyLadder_Buy(num)
    local reqInfo = {
        num = num, 
    }
    RPCReq.SkyLadder_Buy(reqInfo,function(params)
        self.buyTimes = params.buyTimes or 0
        self:updateRed()
        Dispatcher.dispatchEvent(EventType.CrossLaddersMainView_refreshPanel)
    end)
end

-- #获取天梯赛记录信息
-- SkyLadder_GetBattleRecordInfo 947 {
-- 	request {
-- 	}
-- 	response {
-- 		data 			1:*PSkyLadder_RecordInfo  	#记录信息
-- 	}
-- }
-- #记录信息
-- .PSkyLadder_RecordInfo {
-- 	fightMs 		1:integer				#时间戳
-- 	enemyId			2:integer				#敌方玩家id
-- 	name 			3:string				#玩家名字
-- 	level 			4:integer				#玩家等级
-- 	head			5:integer				#玩家头像
-- 	oldRank			6:integer
-- 	newRank 		7:integer
-- 	recordId		8:integer
-- 	combat			9:integer				#战斗力
-- 	isAttack     	10:boolean  			#是否是进攻方
-- 	headBorder		11:integer				#头像框
-- 	serverId		12:integer				#区服id
-- }

function CrossLaddersModel:reqSkyLadder_GetBattleRecordInfo()
    local reqInfo = {

    }
    RPCReq.SkyLadder_GetBattleRecordInfo(reqInfo,function(params) 
        self.recordInfo = params.data or {}
        self:updateRed()
        printTable(8849,">>>self.recordInfo>> 战斗记录数据 >>",self.recordInfo)
        Dispatcher.dispatchEvent(EventType.CrossLaddersRecordView_refreshPanel)
    end)
end

-- #点赞
-- SkyLadder_Like 277 {
-- 	request {
-- 		rank 			1:integer	#排名
-- 	}
-- 	response {
-- 		totalLike 		1:integer			#被点赞总次数
-- 		likeList		2:*LikeData(rank)	#已点赞的玩家id列表
-- 	}
-- }
-- .LikeData {
-- 	rank 			1:integer  # 排名
-- 	like 			2:boolean  # 是否点赞
-- }
function CrossLaddersModel:reqSkyLadder_Like(rank,playerId)
    local reqInfo = {
        rank = rank,
    }
    RPCReq.SkyLadder_Like(reqInfo,function(params)
        printTable(8849,">>>self.likeInfo>>SkyLadder_Like>>点赞数据",params)
        self.likeInfo = params.likeList or {}
        for k,v in pairs(self.heroHouseInfo) do
            if v.playerId == playerId then
                self.heroHouseInfo[k].totalLike = params.totalLike
                Dispatcher.dispatchEvent(EventType.CrossLaddersHeroHouseView_refreshPanel)
                break
            end
        end
        self:updateRed()
    end)
end

-- # 获取英雄殿信息
-- SkyLadder_GetHeroHouse 3397 {
-- 	request {
-- 	}
-- 	response {
-- 		data		1:*HeroHouseData(rank)
-- 	}
-- }

-- .HeroHouseData {
-- 	playerId		1:integer		#玩家id
-- 	name 			2:string  		#玩家名字
-- 	level 			3:integer 		#玩家等级
-- 	head 			4:integer		#头像
-- 	guildName 		5:string  		#公会名字
-- 	combat			6:integer		#战力
-- 	serverId		7:integer		#服务id
-- 	rank 			8:integer		#排名 
-- 	headBorder 		9:integer 		#头像框
-- 	heroOpertion  	10:integer 		#板娘
-- 	fashionCode		11:integer 		#时装
-- 	totalLike 		12:integer 		#总点赞次数
-- }
function CrossLaddersModel:reqSkyLadder_GetHeroHouse()
    local reqInfo = {

    }
    RPCReq.SkyLadder_GetHeroHouse(reqInfo,function(params)
        printTable(8848,">>>英雄殿>>>SkyLadder_GetHeroHouse>>",params)
        self.heroHouseInfo = params.data or {}
        self:updateRed()
        Dispatcher.dispatchEvent(EventType.CrossLaddersHeroHouseView_refreshPanel)
    end)
end

-- #快速挑战
-- SkyLadder_ChallengeOneKey 13298 {
-- 	request {
-- 		playerId 		0:integer				#挑战的玩家id
-- 		rank 			1:integer 				#排名
-- 	}

-- 	response {
-- 		usedTimes		1:integer				#已使用的免费次数
-- 		res 			2:*FightRes   			#战斗结果
-- 	}
-- }

function CrossLaddersModel:reqSkyLadder_ChallengeOneKey(playerId,rank)
    local reqInfo = {
        playerId = playerId,
        rank = rank,       
    }
    RPCReq.SkyLadder_ChallengeOneKey(reqInfo,function(params) 
        self.usedTimes = params.usedTimes or 0
        self:updateRed()
        Dispatcher.dispatchEvent(EventType.CrossLaddersMainView_refreshPanel)
    end)
end 

-- 获取比自己低一个排名的玩家信息
function CrossLaddersModel:getNextRankInfo()
    local rankInfo = self.challengeList
	local rankData = rankInfo.rankData or {}
	local myRankData = rankInfo.myRankData or {}
	local myId = tonumber(PlayerModel.userid)
	local haveMe = false
	for k,v in pairs(rankData) do
		if v.id == myId then
			haveMe = true
			break
		end
	end
	if not haveMe and myRankData.id then
		table.insert(rankData,myRankData)
		table.sort(rankData,function(a,b) 
			return a.rank < b.rank
		end)
	else
		for k,v in pairs(rankData) do
			if v.id == myId then
				rankData[k] = myRankData
				break
			end
		end
    end
    
    for i=1,#rankData do
        local data = rankData[i] 
        if data.id == myId then
            if rankData[i+1] then
                return rankData[i+1]
            else
                return rankData[i-1]
            end
        end
    end
end




function CrossLaddersModel:isCrossLaddersPvpType(configType)
    return configType==GameDef.BattleArrayType.SkyLadderAck
end


function CrossLaddersModel:getArrayByType(configType)
    return self.allTeamInfo[configType]
end

function CrossLaddersModel:initTeamInfo(playerId,serverId)
    self.allTeamInfo = {}
    local const = DynamicConfigData.t_HPvPConst[1];
    local requseInfo={
        fightId	= const.fightId,
        playerId= playerId,
        gamePlay= GameDef.BattleArrayType.SkyLadderDef, -- SkyLadderDef
        serverId= serverId,
    }
    self.allTeamInfo[GameDef.BattleArrayType.SkyLadderAck] = {
        arrayType = GameDef.BattleArrayType.SkyLadderDef,
        array={},
        heroInfos={},
        combat = 0,
    }
    local function success(data)
        if (data.array) then
            for uuid, d in pairs(data.array) do
                local heroInfo = CardLibModel:getHeroByUid(d.uuid);
                if (heroInfo) then
                    self.allTeamInfo[GameDef.BattleArrayType.SkyLadderAck].array[uuid] = d;
                end
            end
        end
        if data.heroInfos then
             self.allTeamInfo[GameDef.BattleArrayType.SkyLadderAck].heroInfos = data.heroInfos
             local combat = 0
             for k,v in pairs(data.heroInfos) do
                if v.combat then
                    combat = v.combat + combat
                end
             end
             self.allTeamInfo[GameDef.BattleArrayType.SkyLadderAck].combat = combat
        end
        -- if data.combat then
        --     self.allTeamInfo[GameDef.BattleArrayType.SkyLadderAck].combat = data.combat
        -- end
    end
    RPCReq.Battle_GetOpponentBattleArray(requseInfo,success)
end

-- 我的排名
function CrossLaddersModel:getMyRank()
    
end

-- 设置入口数据
function CrossLaddersModel:getMainSubInfo(fun)
    local conf = DynamicConfigData.t_SkyLadder[1]
    local ServerTime    = ServerTimeModel:getServerTime()
    local data      = {}
    local today     = TimeLib.getWeekDay()
    local weekTimes = TimeLib.nextWeekBeginTime()  -- 周末24:00的时间戳 S
    local startMs   = conf.startMs 
    local endMs     = conf.endMs
    local preTime   = 86400*7 - startMs
    local openMs    =   weekTimes - preTime
    local closeMs   =   weekTimes - (86400*7 - endMs)
    local entranceTitle = ""

    local reqInfo = {

    }
    local serverTime = ServerTimeModel:getServerTime()
    local myId  = tonumber(PlayerModel.userid)
    entranceTitle = Desc.CrossLadders_str17
    if today < 6 then
        data.seasonTime = openMs - serverTime
        entranceTitle = Desc.CrossLadders_str18
    elseif today == 6 then
        data.seasonTime = closeMs - serverTime
    elseif today == 7 then
        if serverTime < closeMs then
            data.seasonTime = closeMs - serverTime
        else
            if serverTime <= weekTimes then
                entranceTitle = Desc.CrossLadders_str18
                data.seasonTime = (weekTimes + startMs) - serverTime
            end
        end
    end


    data.dayTimes = self:getHaveTimes()
    data.rank    =  self.myRank or Desc.Rank_notInRank
    data.red     = "V_CROSSLADDERS"
    data.moduleId = ModuleId.CrossLadders.id
    data.entranceTitle = entranceTitle
    
    fun(data)
end


function CrossLaddersModel:updateRed()
    self:updateHaveTimes()
    self:updateHeroHouseRed()
end

-- 判断在没在活动开启阶段
function CrossLaddersModel:checkIsOpen()
    local conf = DynamicConfigData.t_SkyLadder[1]
    local open = true
    local ServerTime    = ServerTimeModel:getServerTime()
    local today     = TimeLib.getWeekDay()
    local weekTimes = TimeLib.nextWeekBeginTime()  -- 周末24:00的时间戳 S
    local startMs   = conf.startMs 
    local endMs     = conf.endMs
    local preTime   = 86400*7 - startMs
    local openMs    =   weekTimes - preTime
    local closeMs   =   weekTimes - (86400*7 - endMs)
    local serverTime = ServerTimeModel:getServerTime()
    if today < 6 then
        open = false
    elseif today == 6 then
    elseif today == 7 then
        if serverTime < closeMs then
        else
            if serverTime <= weekTimes then
                open = false
            end
        end
    end
    return open
end


-- 判断有没有次数并且在开启阶段
function CrossLaddersModel:updateHaveTimes()
    local haveTimes = self:getHaveTimes()  --判断有没有次数有次数直接显示红点
    haveTimes = haveTimes>0
    local conf = DynamicConfigData.t_SkyLadder[1]
    local ServerTime    = ServerTimeModel:getServerTime()
    local data      = {}
    local today     = TimeLib.getWeekDay()
    local weekTimes = TimeLib.nextWeekBeginTime()  -- 周末24:00的时间戳 S
    local startMs   = conf.startMs 
    local endMs     = conf.endMs
    local preTime   = 86400*7 - startMs
    local openMs    =   weekTimes - preTime
    local closeMs   =   weekTimes - (86400*7 - endMs)
    local serverTime = ServerTimeModel:getServerTime()
    if today < 6 then
        haveTimes = false
    elseif today == 6 then
    elseif today == 7 then
        if serverTime < closeMs then
        else
            if serverTime <= weekTimes then
                haveTimes = false
            end
        end
    end

    RedManager.updateValue("V_CROSSLADDERS_HAVETIMES",haveTimes and self.join)    
end


-- 更新英雄殿红点 判断能不能点赞
function CrossLaddersModel:updateHeroHouseRed()
    local canLike = false
    
    for i=1,3 do
        local v = self.likeInfo[i] or false
        if not v or not v.like then
            if (TableUtil.GetTableLen(self.houseInfo) > 0) then
                canLike = true
                break
            end
        end
    end
    if (not canLike) and (TableUtil.GetTableLen(self.likeInfo) == 0) and (TableUtil.GetTableLen(self.houseInfo) > 0) then
        canLike = true
    end
    RedManager.updateValue("V_CROSSLADDERS_HEROHOUSE",canLike)   
end


-- 更新战斗记录红点
function CrossLaddersModel:updateRecordRed()

end

function CrossLaddersModel:checkRecord()
    local moduleIsOpen = (not ModuleUtil.getModuleOpenTips(ModuleId.CrossLadders.id))
    if moduleIsOpen then
        local reqInfo = {

        }
        RPCReq.SkyLadder_GetBattleRecordInfo(reqInfo,function(params) 
            self.recordInfo = params.data or {}
            for key,value in pairs(self.recordInfo) do
                if not value.isAttack and value.fightMs > self.recordFightMs then
                    self.recordFightMs = value.fightMs
                    RedManager.updateValue("V_CROSSLADDERS_RECORD",true)
                end
            end
        end)
    end
end

function CrossLaddersModel:setRecordFightMs()
	if RedManager.getTips("V_CROSSLADDERS_RECORD") then
		xpcall(function()
			FileCacheManager.setStringForKey("CROSSLADDERS_RECORD", tostring(self.recordFightMs), nil, false)
		end, __G__TRACKBACK__)
	end
end

-- 判断活动有没有开启
function CrossLaddersModel:checkOpenState()
    local openState = true
    local conf = DynamicConfigData.t_SkyLadder[1]
    local ServerTime    = ServerTimeModel:getServerTime()
    local data      = {}
    local today     = TimeLib.getWeekDay()
    local weekTimes = TimeLib.nextWeekBeginTime()  -- 周末24:00的时间戳 S
    local startMs   = conf.startMs 
    local endMs     = conf.endMs
    local preTime   = 86400*7 - startMs
    local openMs    =   weekTimes - preTime
    local closeMs   =   weekTimes - (86400*7 - endMs)
    local serverTime = ServerTimeModel:getServerTime()
    if today < 6 then
        openState = false
    elseif today == 6 then
    elseif today == 7 then
        if serverTime < closeMs then
        else
            if serverTime <= weekTimes then
                openState = false
            end
        end
    end
    return openState
end

function CrossLaddersModel:loginPlayerDataFinish()
    local openState = self:checkOpenState()
    if openState then
        self:checkRecord()
    end
    local data = FileCacheManager.getStringForKey("CROSSLADDERS_RECORD", "", nil, false)
	self.recordFightMs = 0
	if data ~= "" then
		self.recordFightMs = tonumber(data)
	end
end

-- 商城刷新按钮是否弹提示框  （保存状态)
function CrossLaddersModel:setCheckTips(index)
	local dayStr = DateUtil.getOppostieDays()
	index = index or FileCacheManager.getIntForKey("CrossLadders_isCheckTips" .. dayStr,0)
	FileCacheManager.setIntForKey("CrossLadders_isCheckTips" .. dayStr,index)
end


return CrossLaddersModel
