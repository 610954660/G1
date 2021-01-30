local BaseModel = require "Game.FMVC.Core.BaseModel"
local GuildMLSModel = class("GuildMLSModel", BaseModel)

function GuildMLSModel:ctor()
    self.firstIn    = false  -- 判断是不是第一次进魔灵山
    self.allEnergy  = 0      -- 所拥有的精力
    self.maxBossLevel = 1    -- 已召唤并击败的boss最高等级

    self.bossListInfo   = {}     -- boss列表信息
    self.singleBossInfo = {}     -- 单个boss的信息
    self.summonBossInfo = {}     -- 召唤的boss的信息
    self.challengeBossInfo = {}  -- 挑战的boss的信息
    self.settleEndInfo   = {}     -- 结算界面信息
    self.rankBossId      = false    -- 记录当前战斗的bossId
    self.recoverStamp    = false   -- 精力恢复的时间倒计时
    self.purchaseCount   = false    -- 今天购买精力的次数
    self.bossRewardInfo  = {}       -- boss奖励信息
    self.rewardMap       = {}       -- 奖励信息
    self.powerTimer      = false    -- 体力定时器
    self.openReward      = false    -- 魔灵山开启奖励领取状态
    self.timerText = {}
    self.nowTime = 0
    self.bossMaxHp = false
    self.curBossHp = false
	
    self.hasOpenMLS = false   --是否打开过魔灵石（打开过就不显示红点了）
    self:initListeners()
end

function GuildMLSModel:getBossTitleArrow(bossId)
        local arr={}
        local configInfo= DynamicConfigData.t_EvilBossPara[bossId]
        if configInfo  then
            arr=  configInfo.tag
        end
        return arr
end

-- #魔灵山玩家数据
-- .EvilMountain_PlayerInfo {
--     openState                1:integer       #开启状态 (判断是不是第一次进魔灵山)
--     energy                  2:integer       #精力 走货币系统
--     maxBossLevel             3:integer       #已召唤并击败的boss最高等级
--     recoverStamp            4:integer       #上一次精力恢复时间戳, 下一次的根据策划配置自己计算展示吧, 这个数值只在当前精力少于上限值时才有效
--     purchaseCount           5:integer       #今天购买精力的次数
-- }
function GuildMLSModel:playerData(data)
    -- printTable(8848,">>>魔灵山的数据>>>",data)
	if not data then return end
    self.firstIn    = data.openState == 1
    self.allEnergy  = data.energy or 0
    self.maxBossLevel = data.maxBossLevel + 1
    self.recoverStamp = data.recoverStamp 
    self.purchaseCount = data.purchaseCount
    self.openReward = data.openReward == 1
    self:redCheck()
    Dispatcher.dispatchEvent(EventType.GuildMLSMain_refreshPanal)
    Dispatcher.dispatchEvent(EventType.GuildMLSChallege_refreshPanal)
    Dispatcher.dispatchEvent(EventType.GuildMLSSummonBoss_refreshPanal)
end


--#请求所有boss列表信息
-- .EvilMountain_BossInfo {
--     id                      1:integer       #boss唯一编号
--     confId                  2:integer       #boss配置id
--     openStamp               3:integer       #召唤时间戳
--     endStamp                4:integer       #结束时间戳(指Boss消失)
--     challengeStamp          5:integer       #挑战结束时间戳(boss死亡或者挑战时间结束后, 不可再挑战)
--     challengeNum            6:integer       #当前挑战人数
--     energy                  7:integer       #挑战所需消耗精力
--     maxHp                   8:integer       #最大血量  这2个可以考虑读配置表
--     hp                      9:integer       #当前剩余血量
--                       10:integer      #召唤者id
--     ownerName               11:string       #召唤者名称
--     ownerLevel              12:integer      #召唤者等级
--     ownerType               13:integer      #boss归属类型 0或者nil,公会会员召唤, 1好友召唤
--     maxDamage               14:integer      #我的最高伤害 nil则默认为0
--     battleRecord            15:string       #战斗记录
--     battleCount             16:integer      #已挑战次数 nil则默认为0
--     battleStamp             17:integer      #上一次挑战时间戳
--     rewardState             18:integer      #奖励状态  0或者nil 无可领取奖励, 1可领取奖励, 2已领取奖励
--     rewardMap               19:*EvilMountain_BossReward(type)     #奖励列表信息, 玩家领取后会被清理, 只在可领取奖励状态才会下发此信息, 用于表现
-- }
function GuildMLSModel:reqBossListInfo()
    local reqInfo = {}
    RPCReq.EvilMountain_BossListReq(reqInfo,function(params)
        self.bossListInfo = params.bossList or {}
        -- printTable(8848,">>>请求boss列表信息>>>>",self.bossListInfo)
        -- 发送事件 刷新boss列表
        self:redCheck()
        Dispatcher.dispatchEvent(EventType.GuildMLSMain_refreshPanal)
    end)
end

function GuildMLSModel:public_enterGame()
    -- print(8848,">>>GuildModel.guildHave>>>",GuildModel.guildHave)
    -- if GuildModel.guildHave then
    --     self:reqBossListInfo()
    -- end
end



--#请求具体单个boss详细信息
function GuildMLSModel:reqSingleBossInfo(id)
    local reqInfo = {
        id = id,
    }
    RPCReq.EvilMountain_BossInfoReq(reqInfo,function(params)
        -- print(8848,">>>请求bossId>>".. id ..">>的信息>>>>",params)
        self.singleBossInfo = params.bossInfo or {}
        -- 发送事件 刷新挑战boss界面的信息
        self:redCheck()
        Dispatcher.dispatchEvent(EventType.GuildMLSChallege_refreshPanal)
    end)
end

--#请求召唤boss的信息
function GuildMLSModel:reqSummonBossInfo(bossId)
    local reqInfo = {
        confId = bossId,
    }
    RPCReq.EvilMountain_SummonReq(reqInfo,function(params)
        -- print(8848,">>>请求召唤bossId为>>".. bossId ..">>的信息>>>>")
        self.summonBossInfo = params.bossInfo or {}
        self:redCheck()
        -- 发送事件 刷新挑战boss界面的信息
        -- Dispatcher.dispatchEvent(EventType.AAA)
    end)
end

--#请求挑战boss的信息
function GuildMLSModel:reqChallengeBossInfo(bossId)
    local reqInfo = {
        id = bossId,
    }
    RPCReq.EvilMountain_ChallengeReq(reqInfo,function(params)
        -- print(8848,">>>请求挑战的bossId为>>".. bossId ..">>的信息>>>>",params)
        self.challengeBossInfo = params.bossInfo or {}
        -- 发送事件 刷新挑战boss界面的信息
        -- Dispatcher.dispatchEvent(EventType.AAA)
    end)
end

--#领取boss奖励
function GuildMLSModel:reqBossRewardInfo(bossId)
    local reqInfo = {
        id = bossId,
    }
    -- printTable(8848,">>>reqInfo>>",reqInfo)
    RPCReq.EvilMountain_BossRewardReq(reqInfo,function(params)
        -- printTable(8848,">>>EvilMountain_BossRewardReq>>>请求到boss的奖励信息为>>",params)
        self.bossRewardInfo = params.rewardList or {}
        self:redCheck()
        Dispatcher.dispatchEvent(EventType.GuildMLSTakeReward_refreshPanal)
    end)
end



-- 奖励排序
function GuildMLSModel:sortBossReward()
    local rewardData = {}
    for k,v in pairs(self.rewardMap) do
        local rewardType = v.type
        if rewardType == GameDef.EvilMountainRewardType.Summon then -- 召唤奖励
            rewardType = 1
        elseif rewardType == GameDef.EvilMountainRewardType.Rank then -- 排名奖励
            rewardType = 2
        elseif rewardType == GameDef.EvilMountainRewardType.Fight then -- 讨伐奖励
            rewardType = 3
        elseif rewardType == GameDef.EvilMountainRewardType.Lucky then -- 幸运奖励
            rewardType = 4
        elseif rewardType == GameDef.EvilMountainRewardType.Work then   -- 努力奖励
            rewardType = 5
        end
        for o,p in pairs(v.boxList) do
            local boxType = p.boxType
            for m,n in pairs(p.rewardList) do
                n.rewardType = rewardType
                n.boxType = boxType
                if boxType == 0 then
                    n.showType = 0  -- 直接展示
                else
                    n.showType = 1  -- 先展示箱子
                end
                table.insert(rewardData,n)
            end
        end
    end

    local keys ={
        {key = "rewardType",asc = false},
        {key = "showType",asc = false},
    }
    TableUtil.sortByMap(rewardData, keys)
    return rewardData
end

-- 插入boss
function GuildMLSModel:insertBoss(bossData)
    -- self.bossListInfo
    for k,v in pairs(bossData) do
        if v.updateType == 1 then
            local myId    = tonumber(ModelManager.PlayerModel.userid)
            local bossInfo = v.bossInfo
            local bossId  = v.bossId
            local ownerId = v.ownerId
            if myId ~= ownerId then
                self.bossListInfo[bossId] = {}
                self.bossListInfo[bossId] = bossInfo
            end
        end
    end
    self:redCheck()
    Dispatcher.dispatchEvent(EventType.GuildMLSMain_refreshPanal)
end



-- 筛选出同公会的boss列表   0 同公会boss  1 所有boss信息
function GuildMLSModel:getGuildBossList(onlyType)
    local bossList = {}
    local allBossList = {}
    
    for k,v in pairs(self.bossListInfo) do 
        --已结束且有奖可领>未结束>已结束且无奖可领								
        -- “已结束”的按最晚召唤的时间，放在最上层，早召唤的放在最底下 
        -- 还存活的”按照召唤时间，最早召唤的放在最上层，新召唤的放在最底下
        local serverTime = ModelManager.ServerTimeModel:getServerTimeMS()
        v.death = 1
        if serverTime < v.challengeStamp and v.hp ~= 0 then
            if (not v.rewardState) or (v.rewardState == 0) then 
                v.state = 1
            elseif v.rewardState == 1 then 
                v.state = 0
            else --已领取奖励
                v.state = 2 
            end
        else
            if v.rewardState == 1 then 
                v.state = 0
            elseif (v.rewardState == 2) or (not v.rewardState) then --已领取奖励
                v.state = 2  
            end
        end

        local myId = tonumber(ModelManager.PlayerModel.userid)
        if myId == v.ownerId then
            v.owener = 0
        else
            v.owener = 1 -- 别人的
        end
        table.insert(allBossList,v)
        if (not v.ownerType) or (v.ownerType == 0) or (v.battleCount and v.battleCount > 0) then
            table.insert(bossList,v)
        end
    end
    -- local keys ={
    --     {key = "state",asc = false},
    --     -- {key = "openStamp",asc = false},
    -- }
 
    local sortFunc = function(listData) 
        table.sort(listData, function(a, b)
            if (a.state == b.state) then
                 if(a.state == 2) then
                     return a.openStamp > b.openStamp
                 else
                     return a.openStamp < b.openStamp
                 end
            else
                 return a.state < b.state
            end
         end)
    end

    if onlyType == 0 then   -- 同公会 
        -- TableUtil.sortByMap(bossList, keys)
        sortFunc(bossList)
        return bossList
    else
        -- TableUtil.sortByMap(allBossList,keys)
        sortFunc(allBossList)
        return allBossList
    end
end


-- 获取魔晶石配置
function GuildMLSModel:getJingShiCfg()
    local openCost    = {
        code = 10000082,
        type = 2,
        amount = 1,
    }
    return openCost
end


-- 通过bossID获取boss等级
function GuildMLSModel:getBossLvById(bossId)
    local bossData = DynamicConfigData.t_EvilBossPara
    local bossLv   = bossData[bossId].difficulty
    return bossLv or 1
end

-- 通过bossId 获取fightId
function GuildMLSModel:getFightIdById(bossId)
    local bossData = DynamicConfigData.t_EvilBossPara
    local fightId  = bossData[bossId].fightId
    return fightId
end


-- 通过bossId 获取monsterId 
function GuildMLSModel:getMonsterIdByBossId(bossId)
    local bossData = DynamicConfigData.t_EvilBossPara
    local monsterId = bossData[bossId].monsterId
    return monsterId
end

-- 通过bossId 获取boss名字
function GuildMLSModel:getBossNameById(bossId)
    local bossData = DynamicConfigData.t_EvilBossPara
    local name = bossData[bossId].name
    return name
end

-- 通过bossId 获取阵容类型
function GuildMLSModel:getBattleAarryTypeById(bossId)
    local bossData = DynamicConfigData.t_EvilBossPara
    local battleAarryType = bossData[bossId].battleAarryType
    return battleAarryType
end

-- 获取通过bossid 获取boss大小 
function GuildMLSModel:getBossSizeById(bossId)
    local bossData = DynamicConfigData.t_EvilBossPara
    local size = bossData[bossId].size
    return size
end

-- 通过bossId获取boss的最大等级
function GuildMLSModel:getBossMaxLvById(bossId)
    local bossData = DynamicConfigData.t_EvilBossLv
    for k,v in pairs(bossData) do
        for o,p in pairs(v) do
            if bossId == p.bossId then
                return TableUtil.GetTableLen(v)
            end
        end
    end
end

-- 获取召唤的boss的信息
function GuildMLSModel:getSummonBossInfo(pBossIndex)
    local bossInfo = DynamicConfigData.t_EvilBossSummon
    return bossInfo[pBossIndex]
end

-- 获取挑战冷却Cd
function GuildMLSModel:getBattleCd()
    local EvilConst = DynamicConfigData.t_EvilConst[1]
    local battleCd  = EvilConst.battleCd
    return battleCd * 1000
end

-- 获取精力回复时间
function GuildMLSModel:getEnergyRecover()
    local EvilConst = DynamicConfigData.t_EvilConst[1]
    local energyRecover  = EvilConst.energyRecover
    return energyRecover * 1000
end

-- 根据boss等级获取排行奖励列表
function GuildMLSModel:getRankRewardInfoByLv(bossLv)
    local rankRwardInfo = DynamicConfigData.t_EvilRankReward
    return rankRwardInfo[bossLv]
end

-- 根据排行获取对应奖励的箱子
function GuildMLSModel:getRankRewardNum(bossLv,rank)
    local rankRwardInfo = self:getRankRewardInfoByLv(bossLv)
    local find = false
    for k,v in pairs(rankRwardInfo) do
        local min = v.min
        local max = v.max
        if rank >=min and rank<= max then
            return v.num
        end
        if max == -1 then
            find = v.num
        end
    end
    return find
end

-- 设置结算界面信息
function GuildMLSModel:setSettleEndInfo(data)
    self.settleEndInfo = data or {}
end

-- 获取结算界面信息
function GuildMLSModel:gettleEndInfo()
    return self.settleEndInfo
end

-- 获取购买体力消耗的钻石
function GuildMLSModel:getPowerMoney()
    local buyEnergyCost = DynamicConfigData.t_EvilConst[1].buyEnergyCost
    return buyEnergyCost[self.purchaseCount+1] or buyEnergyCost[#buyEnergyCost]
end

-- 一次购买获得的精力
function GuildMLSModel:getBuyEnergyNum()
    local buyEnergyNum = DynamicConfigData.t_EvilConst[1].buyEnergyNum
    return buyEnergyNum
end

-- 获取最大体力限制
function GuildMLSModel:getEnergyLimitNum()
    local energyLimit = DynamicConfigData.t_EvilConst[1].energyLimit
    return energyLimit
end

function GuildMLSModel:redCheck()
    -- do return end
	GlobalUtil.delayCallOnce("GuildMLSModel:redCheck",function()
		self:updateRed()
	end, self, 0.1)
end

-- 更新红点
function GuildMLSModel:updateRed()
    local keyArr = {}
    table.insert(keyArr,"V_Guild_MLS_Summon")
    RedManager.addMap("V_Guild_MLS", keyArr)
    local haveMJS   = self:checkHaveMJS()
    local enough    = self:checkEnergyEnough()
    local haveReward = self:checkHaveReward()
    RedManager.updateValue("V_Guild_MLS_Summon",haveMJS and not self.hasOpenMLS)
    RedManager.updateValue("V_Guild_MLS",enough or haveReward or haveMJS)
    -- V_Guild_MLS_Summon
    -- V_Guild_MLS
end

-- 判断魔晶石是否大于零
function GuildMLSModel:checkHaveMJS()
    local JinshiCfg = self:getJingShiCfg()
    local haveNum  = ModelManager.PackModel:getItemsFromAllPackByCode(JinshiCfg.code) -- 拥有的魔晶石的数量
    return haveNum > 0 and true or false
end

function GuildMLSModel:pack_item_change()
    self:redCheck()
end

function GuildMLSModel:player_levelUp()
    local tips = ModuleUtil.hasModuleOpen(ModuleId.GuildMLS.id)
    if tips  and GuildModel.guildHave then
        self:reqBossListInfo()
    end 
end

function GuildMLSModel:guild_add_evet()
    local tips = ModuleUtil.hasModuleOpen(ModuleId.GuildMLS.id)
    print(8848,">>> GuildModel.guildHave>>>tips>>", GuildModel.guildHave,tips)
    if tips and  GuildModel.guildHave then
        self:reqBossListInfo()
    end 
end

-- 判断精力是否足够
function GuildMLSModel:checkEnergyEnough()
    local onlyType = FileCacheManager.getIntForKey("GuildMLSMain_onlyType",1)
    local bossList = {}
    bossList = self:getGuildBossList(onlyType)
    if not bossList then
        return
    end
    local enough = false
    if not self.firstIn then
        self.allEnergy = 100
    end
    -- self.allEnergy
    for k,v in pairs(bossList) do
        local serverTime = ModelManager.ServerTimeModel:getServerTimeMS()
        local battleCount = v.battleCount or 0
        local energy = v.energy
        if self.allEnergy >= energy and battleCount == 0  and serverTime < v.challengeStamp and v.hp > 0 then
            enough = true
            break
        end
    end
    return enough
end

-- 判断是否有奖励可领
function GuildMLSModel:checkHaveReward()
    local onlyType = FileCacheManager.getIntForKey("GuildMLSMain_onlyType",1)
    local bossList = {}
    bossList = self:getGuildBossList(onlyType)
    if not bossList then return end
    local haveReward = false
    for k,v in pairs(bossList) do
        if v.rewardState and v.rewardState == 1 then
            haveReward = true
            break
        end
    end
    return haveReward
end

-- 体力定时器
function GuildMLSModel:initEnergyRecoverTimer(txt_countTimer)
    self.timerText[txt_countTimer] = 1
    txt_countTimer:setText(TimeLib.formatTime(self.nowTime))
    -- if not self.powerTimer then
    if self.powerTimer then
        Scheduler.unschedule(self.powerTimer)
        self.powerTimer = false
    end
        self:startEnergyRecoverTimer()
    -- end
end

function GuildMLSModel:startEnergyRecoverTimer()
    local serverTime = ModelManager.ServerTimeModel:getServerTimeMS()
    local recoverStamp = ModelManager.GuildMLSModel.recoverStamp
    local countTime =  ModelManager.GuildMLSModel:getEnergyRecover()
    local endTime = math.floor((serverTime + countTime)/1000)
    countTime = math.floor(((countTime + recoverStamp) - serverTime)/1000)
    -- self.nowTime = countTime
    -- txt_countTimer:setText(TimeLib.formatTime(countTime))
    local function updateAllText(countTime)
        for key,v in pairs(self.timerText) do
            if not tolua.isnull(key) then
                key:setText(TimeLib.formatTime(math.floor(countTime)))
            else
                self.timerText[key] = nil
            end
        end
    end
    local function onCountDown( dt )
        countTime = countTime - dt
        updateAllText(countTime)
        if countTime <= 0 then
            Scheduler.unschedule(self.powerTimer)
            self.powerTimer = false
        end
    end

    updateAllText(countTime)
    self.powerTimer = Scheduler.schedule(function(dt)
		onCountDown(dt)
    end,0.1)
end

function GuildMLSModel:getBossMaxHp()

end




return GuildMLSModel