-- added by wyz 
-- 公会 魔灵山 boss挑战界面

local GuildMLSChallegeView = class("GuildMLSChallegeView",Window)

function GuildMLSChallegeView:ctor()
    self._packName = "GuildMagicLingShan"
    self._compName = "GuildMLSChallegeView"

    self.txt_rankTitle = false      -- 排行榜标题
    self.timerIconLoader = false    -- 倒计时icon
    self.txt_countTimer  = false    -- 剩余挑战时间
    self.numIconLoader   = false    -- 挑战人数icon
    self.txt_playerNum   = false    -- 挑战的人数
    self.btn_reward      = false    -- 查看奖励按钮
    self.list_rank       = false    -- 排行榜列表
    self.lihuiDisplay    = false    -- boss立绘
    self.list_skill      = false    -- boss技能信息列表
    self.txt_bossLv      = false    -- boss等级
    self.txt_playerAndBossName = false  -- 召唤boss的玩家名字
    self.progressBar     = false    -- boss血量条
    self.btn_fight       = false    -- 挑战按钮
    self.txt_myRank      = false    -- 我的排名
    self.txt_reward      = false    -- 排名奖励标题
    self.boxIconLoader   = false    -- 排名奖励icon
    self.txt_boxNum      = false    -- 排名奖励数量
    self.btn_cd          = false    -- 挑战cd
    self.btn_take        = false    -- 领取奖励按钮
    self.btn_haveReceive = false    -- 已领取奖励按钮
    self.btn_end         = false    -- 已结束按钮

    self.checkInRankCtrl = false    -- 判断上没上榜
    self.checkFightCtrl  = false    -- 判断挑战按钮的状态

    self.bossId          = false    -- bossId
    self.id              = false    -- 唯一id
    self.bossInfo        = {}       -- boss信息
    self.timer           = false
    self.cdTimer         = false
    self.powerInfo           = false

    self.rankData   = {}
    self.myRankData = {}
end

function GuildMLSChallegeView:_initUI()
    self.txt_rankTitle  = self.view:getChildAutoType("txt_rankTitle")
    self.timerIconLoader = self.view:getChildAutoType("timerIconLoader")
    self.txt_countTimer = self.view:getChildAutoType("txt_countTimer")
    self.numIconLoader  = self.view:getChildAutoType("numIconLoader")
    self.txt_playerNum  = self.view:getChildAutoType("txt_playerNum")
    self.btn_reward     = self.view:getChildAutoType("btn_reward")
    self.list_rank  = self.view:getChildAutoType("list_rank")
    self.lihuiDisplay   = self.view:getChildAutoType("lihuiDisplay")
    self.list_skill     = self.view:getChildAutoType("list_skill")
    self.txt_bossLv     = self.view:getChildAutoType("txt_bossLv")
    self.txt_playerAndBossName = self.view:getChildAutoType("txt_playerAndBossName")
    self.progressBar    = self.view:getChildAutoType("progressBar")
    self.btn_fight  = self.view:getChildAutoType("btn_fight")
    self.txt_myRank     = self.view:getChildAutoType("txt_myRank")
    self.txt_reward     = self.view:getChildAutoType("txt_reward")
    self.boxIconLoader  = self.view:getChildAutoType("boxIconLoader")
    self.txt_boxNum     = self.view:getChildAutoType("txt_boxNum")
    self.btn_cd     = self.view:getChildAutoType("btn_cd")
    self.btn_take   = self.view:getChildAutoType("btn_take")
    self.btn_haveReceive    = self.view:getChildAutoType("btn_haveReceive")
    self.btn_end    = self.view:getChildAutoType("btn_end")
    self.powerInfo = self.view:getChildAutoType("powerInfo")
    self.com_bosstitle = self.view:getChildAutoType("com_bosstitle") 

    self.checkInRankCtrl    = self.view:getController("checkInRankCtrl")
    self.checkFightCtrl     = self.view:getController("checkFightCtrl")

    self.bossId = self._args.bossId
    self.id = self._args.id
    self.rewardData     = {}
    self:setBg("guildMLS.jpg")
    self.btn_help       = self.view:getChildAutoType("btn_help")
    self.btn_help:removeClickListener()
    self.btn_help:addClickListener(function(...)
        local info={}
        info['title']=Desc["help_StrTitle_MLS"]
        info['desc']=Desc["help_StrDesc_MLS"]
        ViewManager.open("GetPublicHelpView",info) 
    end)
end

function GuildMLSChallegeView:_initEvent()
    GuildMLSModel:reqBossListInfo()
    -- 请求具体某个boss的信息
    ModelManager.GuildMLSModel:reqSingleBossInfo(self.id)
    -- self:GuildMLSChallege_refreshPanal()
end

function GuildMLSChallegeView:GuildMLSChallege_refreshPanal()
    self.bossInfo   = ModelManager.GuildMLSModel.singleBossInfo   -- 单个boss的信息
    -- printTable(8848,">>>>self.bossInfo>>>",self.bossInfo)
    if self.bossInfo.rewardMap then
        ModelManager.GuildMLSModel.rewardMap = self.bossInfo.rewardMap or {}
        self.rewardData = ModelManager.GuildMLSModel:sortBossReward()
    end
    self.txt_rankTitle:setText(Desc.GuildMLSMain_rankTitle)
    -- self.timerIconLoader:setURL()
    -- self.numIconLoader:setURL()
    self.txt_playerNum:setText(string.format(Desc.GuildMLSMain_challengePeople,self.bossInfo.challengeNum))

    -- print(8848,debug.traceback())
    -- boss血量
    local bossLv    = ModelManager.GuildMLSModel:getBossLvById(self.bossId)
    local bossName = ModelManager.GuildMLSModel:getBossNameById(self.bossInfo.confId)
    -- self.txt_bossLv:setText(bossLv) 
    self.txt_playerAndBossName:setText("LV." .. bossLv .. "  " ..  string.format(Desc.GuildMLSMain_playerNameAndBossName,self.bossInfo.ownerName,bossName))
    self.progressBar:setMax(self.bossInfo.maxHp)
    self.progressBar:setValue(self.bossInfo.hp)
    local pVal = self.progressBar:getChildAutoType("val")
    local pCount = self.progressBar:getChildAutoType("count")
    pVal:setText(MathUtil.toSectionStr(self.bossInfo.hp))
    pCount:setText(MathUtil.toSectionStr(self.bossInfo.maxHp))

    local arrowDesc= GuildMLSModel:getBossTitleArrow(self.bossId)
    local  list_arrow = self.com_bosstitle:getChildAutoType("list_desc") 
    list_arrow:setItemRenderer(function(idx,obj)
        local arrowItem = arrowDesc[idx+1]
        obj:getChildAutoType("txt_attr"):setText( arrowItem.name) 
        local c1= obj:getController("c1")
        c1:setSelectedIndex(arrowItem.type-1)
    end)
    list_arrow:setData(arrowDesc)
    -- boss技能信息
    local monsterId = ModelManager.GuildMLSModel:getMonsterIdByBossId(self.bossId)
    local skillInfo = DynamicConfigData.t_monster[monsterId].skill
    local modelId   = DynamicConfigData.t_monster[monsterId].model
    local category = DynamicConfigData.t_monster[monsterId].category
    local categoryLoader = self.view:getChildAutoType("categoryLoader")
    categoryLoader:setURL(PathConfiger.getCardSmallCategory(category))

    self.list_skill:setItemRenderer(function(idx,obj)
        local index     = idx + 1
        local skillId = skillInfo[index]
        local skillCell = BindManager.bindSkillCell(obj)
        skillCell:setData(skillId)
        -- skillCell:setJewelryData(skillId)
        local conf = DynamicConfigData.t_skill[skillId]
        obj:removeClickListener(11)
        obj:addClickListener(function ()
            if conf then
                ViewManager.open("ItemTips", {codeType = CodeType.SKILL, id = skillId,data = conf})
            end
        end,11)
    end)
    self.list_skill:setData(skillInfo)

    -- 立绘
    -- local lihuiDisplay = BindManager.bindLihuiDisplay(self.lihuiDisplay)
    -- lihuiDisplay:setData(modelId)

    local bossIconLoader = self.view:getChildAutoType("bossIconLoader")
    local size = ModelManager.GuildMLSModel:getBossSizeById(self.bossInfo.confId)
    bossIconLoader:setScale(-size,size)
    if bossIconLoader then
        bossIconLoader:displayObject():removeAllChildren()
    end
    SpineUtil.createModel(bossIconLoader, {x = 0, y =0}, "stand", modelId,true)

    -- 排行榜列表
    self.list_rank:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local data  = self.rankData[index]
        local c1Ctrl   = obj:getController("c1")    -- 排名控制
        local headItem = obj:getChildAutoType("headItem") -- 玩家头像
        local txt_playerName = obj:getChildAutoType("txt_playerName") -- 玩家名字
        local txt_totalHarmTitle = obj:getChildAutoType("txt_totalHarmTitle") -- 总伤害量标题
        local progressBar1   = obj:getChildAutoType("progressBar1") -- 总伤害量进度条
        local txt_onceHighTitle = obj:getChildAutoType("txt_onceHighTitle") -- 单次伤害标题
        local progressBar2  = obj:getChildAutoType("progressBar2")  -- 单次伤害量进度条
        local btn_data      = obj:getChildAutoType("btn_data")  -- 数据按钮
        local txt_times     = obj:getChildAutoType("txt_times") -- 挑战次数
        local txt_rank      = obj:getChildAutoType("txt_rank")  -- 排名（不在前三）
        
        c1Ctrl:setSelectedIndex(index <= 3 and index or 4)
        txt_rank:setText(index)
        headItem = BindManager.bindPlayerCell(headItem)
        headItem:setHead(data.head, data.level, data.id)
        
        txt_playerName:setText(data.name)
        txt_totalHarmTitle:setText(Desc.GuildMLSMain_totalHarmTitle)
        progressBar1:setMax(self.bossInfo.maxHp)
        progressBar1:setValue(data.value)
        local pVal1 = progressBar1:getChildAutoType("val")
        
        local modVal1 = data.value/self.bossInfo.maxHp
        if modVal1 < 0.01 and modVal1 ~= 0 then
            modVal1 = 0.01
        end
        
        pVal1:setText(string.format(Desc.GuildMLSMain_totalHarmRank,MathUtil.toSectionStr(data.value),string.format("%.2f",modVal1)*100))
        -- print(8848,">>>math.floor(data.value/self.bossInfo.maxHp)>>>data.value>>self.bossInfo.maxHp",math.ceil(data.value/self.bossInfo.maxHp),data.value,self.bossInfo.maxHp)

        local onceHightHurt = data.exParam.param1
        local pVal2 = progressBar2:getChildAutoType("val")
        txt_onceHighTitle:setText(Desc.GuildMLSMain_onceHighTitle)
        progressBar2:setMax(self.bossInfo.maxHp)
        progressBar2:setValue(onceHightHurt)
        local modVal2 = onceHightHurt/self.bossInfo.maxHp
        if modVal2 < 0.01 and modVal2 ~= 0  then
            modVal2 = 0.01
        end
        pVal2:setText(string.format(Desc.GuildMLSMain_totalHarmRank,MathUtil.toSectionStr(onceHightHurt),string.format("%.2f",modVal2)*100))

        local count = data.exParam.param2
        txt_times:setText(string.format(Desc.GuildMLSMain_count,count))

        btn_data:removeClickListener(11)
        btn_data:addClickListener(function(context)
            context:stopPropagation()--阻止事件冒泡
            ModelManager.BattleModel:requestBattleRecord(data.battleId)
        end,11)

        obj:removeClickListener(11)
        obj:addClickListener(function(context)
            context:stopPropagation()--阻止事件冒泡
            ViewManager.open("ViewPlayerView",{playerId = data.id})
        end,11)
    end)
    local reqInfo = {
        rankType = GameDef.RankType.EvilMountainBoss,
        collectionId = self.bossInfo.id,
    }
    -- printTable(8848,">>>>reqInfo>>>",reqInfo)
    RPCReq.Rank_GetRankData(reqInfo,function(params)
        -- printTable(8848,">>>>>请求排行榜数据>>>>>",params)
        self.rankData = params.rankData or {}
        self.myRankData = params.myRankData or {}
        ModelManager.GuildMLSModel.rankBossId = self.bossInfo.id
        if tolua.isnull(self.view) then return end
        self.list_rank:setData(self.rankData)  
        local inRank = false
        local myRank = false
        local myId = tonumber(ModelManager.PlayerModel.userid)
        for k,v in pairs(self.rankData) do
            if myId == v.id then
                inRank = true
                myRank = k
                break
            end
        end
        self.checkInRankCtrl:setSelectedIndex(inRank and 1 or 0)
        if inRank then  -- 在榜上
            local num = ModelManager.GuildMLSModel:getRankRewardNum(bossLv,myRank)
            self.txt_myRank:setText(string.format(Desc.GuildMLSMain_inRank,myRank))
            self.txt_boxNum:setText("x" .. num)
        else
            self.txt_myRank:setText(Desc.GuildMLSMain_noRank)
        end
            -- 领取奖励按钮
        self.btn_take:removeClickListener(11)
        self.btn_take:addClickListener(function()
            -- ViewManager.open("")
            ViewManager.open("GuildMLSTakeRewardView",{id = self.bossInfo.id,rewardData = self.rewardData,bossInfo = self.bossInfo,myRank = myRank})
        end,11)
    end)

    self.txt_reward:setText(Desc.GuildMLSMain_rankRewardTitle)
    local url       = ItemConfiger.getItemIconByCode(10002026, CodeType.ITEM)


    self.boxIconLoader:setURL(url)

    -- 查看奖励按钮
    self.btn_reward:removeClickListener(11)
    self.btn_reward:addClickListener(function()
        ViewManager.open("GuildMLSRwardTipsView",{bossLv = bossLv})
    end,11)

    -- 挑战按钮
    local allEnergy = ModelManager.GuildMLSModel.allEnergy
    if allEnergy < self.bossInfo.energy then
        self.btn_fight:getChildAutoType("cost"):setColor({r=244,g=54,b=54})
    else
        self.btn_fight:getChildAutoType("cost"):setColor({r=101,g=72,b=0})
    end

    ModelManager.GuildMLSModel.curBossHp = self.bossInfo.hp
    self.btn_fight:removeClickListener(11)
    self.btn_fight:getChildAutoType("cost"):setText(self.bossInfo.energy)
    self.btn_fight:addClickListener(function()
        local reqInfo = {
            id = self.id,
        }
        RPCReq.EvilMountain_BossInfoReq(reqInfo,function(params)
            if params.bossInfo and params.bossInfo.hp == 0 then
                RollTips.show(Desc.GuildMLSMain_bossDeath)
                GuildMLSModel.singleBossInfo = params.bossInfo or {}
                GuildMLSModel:redCheck()
                GuildMLSModel:reqBossListInfo()
                Dispatcher.dispatchEvent(EventType.GuildMLSChallege_refreshPanal)
                return
            end
            if allEnergy < self.bossInfo.energy then
                RollTips.show(Desc.GuildMLSMain_noEnergy)
                self.btn_fight:getChildAutoType("cost"):setColor({r=244,g=54,b=54})
                return
            else
                self.btn_fight:getChildAutoType("cost"):setColor({r=101,g=72,b=0})
            end
            local fightId   = GuildMLSModel:getFightIdById(self.bossId)
            local gameType  = GuildMLSModel:getBattleAarryTypeById(self.bossInfo.confId) -- GameDef.BattleArrayType.EvilMountain
            --print(8848,">>>>fightId>>>gameType>>>>",fightId,gameType)
            
            -- ModelManager.GuildMLSModel.curBossHp = self.bossInfo.hp
            -- ModelManager.GuildMLSModel.bossMaxHp = self.bossInfo.maxHp
            Dispatcher.dispatchEvent(EventType.battle_requestFunc,function(eventName)
                local figthData = {}
                if self.timer then
                    Scheduler.unschedule(self.timer)
                    self.timer = false
                end
                if self.cdTimer then
                    Scheduler.unschedule(self.cdTimer)
                    self.cdTimer = false
                end
                if ModelManager.GuildMLSModel.powerTimer then
                    Scheduler.unschedule(ModelManager.GuildMLSModel.powerTimer)
                    ModelManager.GuildMLSModel.powerTimer = false
                end
                if eventName == "begin" then
                    local reqInfo = {
                        id = self.bossInfo.id,
                    }
                    RPCReq.EvilMountain_ChallengeReq(reqInfo,function(params)
                        -- printTable(8848,">>>挑战>>>",params)
                        ModelManager.GuildMLSModel:setSettleEndInfo(params)
                    end)
                end
    
                if eventName == "next" then
                end
    
                if eventName == "end" then
                    ViewManager.open("ReWardView",{page=7, isWin=true})
                    ModelManager.GuildMLSModel:reqSingleBossInfo(self.id)   -- 重新请求数据
                    ModelManager.GuildMLSModel:reqBossListInfo()
                end
            end,{fightID=fightId,configType=gameType})
        end)
    end,11)

    -- 挑战cd
    self.btn_cd:removeClickListener(11)
    self.btn_cd:addClickListener(function()
        RollTips.show(Desc.GuildMLSMain_cdTips)
    end,11)
    
    -- self.checkFightCtrl:setSelectedIndex(0)
    -- if (self.bossInfo.rewardState == 0) or (not self.bossInfo.rewardState and self.bossInfo.hp ~= 0) then
    --     self.checkFightCtrl:setSelectedIndex(1)     -- 可挑战
    -- elseif (self.bossInfo.rewardState == 1) then     -- 可领取奖励
    --     self.checkFightCtrl:setSelectedIndex(2)
    -- elseif (self.bossInfo.rewardState == 2) then    -- 已领取奖励
    --     self.checkFightCtrl:setSelectedIndex(3)
    -- elseif self.bossInfo.hp == 0 then
    --     self.checkFightCtrl:setSelectedIndex(4)
    -- end
    self:refreshCheckFight()

    local battleStamp = self.bossInfo.battleStamp
    local serverTime = ModelManager.ServerTimeModel:getServerTimeMS()
    if self.bossInfo.rewardState == 1 then 
        self.checkFightCtrl:setSelectedIndex(2)    -- 有奖励领 直接显示领取奖励
    elseif self.bossInfo.hp == 0 then
        self.checkFightCtrl:setSelectedIndex(4)
    elseif (serverTime < self.bossInfo.challengeStamp) then   -- 挑战cd
        if self.bossInfo.battleStamp then
            -- 挑战还没结束 显示cd 
            if self.cdTimer then
                Scheduler.unschedule(self.cdTimer)
                self.cdTimer = false
            end
            self:countTimerCD(battleStamp)
        end
    end
    if self.timer then
        Scheduler.unschedule(self.timer)
        self.timer = false
    end
    self:countTimer(self.bossInfo.challengeStamp)


    -- 已领取按钮
    self.btn_haveReceive:removeClickListener(11)
    self.btn_haveReceive:addClickListener(function()
    end,11)

    -- 已结束按钮
    self.btn_end:removeClickListener(11)
    self.btn_end:addClickListener(function()
    end,11)

    self:initEnergyRecover()
end

-- 挑战的冷却Cd
function GuildMLSChallegeView:countTimerCD(CDTimer)
    -- print(8848,">>>CDTimer>>>",CDTimer)
    local txt_timer = self.btn_cd:getChildAutoType("title")
    local battleCd =  ModelManager.GuildMLSModel:getBattleCd()
    local serverTime = ModelManager.ServerTimeModel:getServerTimeMS()
    CDTimer = math.floor(((CDTimer + battleCd) - serverTime)/1000)

    local nowTime = CDTimer
    if nowTime > 0 then
        self.checkFightCtrl:setSelectedIndex(0)
        local function onCountDown(dt)
            nowTime = nowTime - dt
            if not tolua.isnull(txt_timer) then
                txt_timer:setText(TimeLib.formatTime(math.floor(nowTime)))
            end
            if nowTime <= 0 then
                Scheduler.unschedule(self.cdTimer)
                self.cdTimer = false
                self.checkFightCtrl:setSelectedIndex(1)
                txt_timer:setText(Desc.GuildMLSMain_challengeEnd)
                self:GuildMLSChallege_refreshPanal()
            end
		end
        if not tolua.isnull(txt_timer) then
            txt_timer:setText(TimeLib.formatTime(tonumber(nowTime)))
        end
		self.cdTimer = Scheduler.schedule(function(dt)
            onCountDown(dt)
        end,0.1)
    else
        if self.cdTimer then
            Scheduler.unschedule(self.cdTimer)
            self.cdTimer = false
        end
        self:refreshCheckFight()
        txt_timer:setText(Desc.GuildMLSMain_challengeEnd)
    end
end

function GuildMLSChallegeView:countTimer(challengeEndTime)
    if self.bossInfo.rewardState == 1 or self.bossInfo.hp == 0 then
        if self.timer then
			Scheduler.unschedule(self.timer)
        end
        -- self.checkFightCtrl:setSelectedIndex(4)
        self:refreshCheckFight()
        self.txt_countTimer:setText(Desc.GuildMLSMain_challengeEnd)
        return
    end
    local serverTime = ModelManager.ServerTimeModel:getServerTimeMS()
    challengeEndTime = math.floor((challengeEndTime - serverTime)/1000)
    local nowTime = challengeEndTime
    if nowTime > 0 then
        local function onCountDown(dt)
            nowTime = nowTime - dt
            if not tolua.isnull(self.txt_countTimer) then
                self.txt_countTimer:setText(TimeLib.formatTime(math.floor(nowTime)))
            end
            if nowTime <= 0 then
                Scheduler.unschedule(self.timer)
                self.timer = false
                self.checkFightCtrl:setSelectedIndex(4)     -- 已结束
                self.txt_countTimer:setText(Desc.GuildMLSMain_challengeEnd)
                ModelManager.GuildMLSModel:reqSingleBossInfo(self.id)
            end
        end

        if not tolua.isnull(self.txt_countTimer) then
            self.txt_countTimer:setText(TimeLib.formatTime(nowTime))
        end
        self.timer = Scheduler.schedule(function(dt)
            onCountDown(dt)
        end,0.1)
    else
        if not tolua.isnull(self.txt_countTimer) then
            -- self.checkFightCtrl:setSelectedIndex(4)
            self:refreshCheckFight(true)
            self.txt_countTimer:setText(Desc.GuildMLSMain_challengeEnd)
        end
    end
end

function GuildMLSChallegeView:refreshCheckFight(challengeEnd)
    if (self.bossInfo.rewardState == 1) then     -- 可领取奖励
        self.checkFightCtrl:setSelectedIndex(2)
    elseif (self.bossInfo.rewardState == 2) then    -- 已领取奖励
        self.checkFightCtrl:setSelectedIndex(3)
    elseif self.bossInfo.hp == 0 or challengeEnd then
        self.checkFightCtrl:setSelectedIndex(4)
    elseif (self.bossInfo.rewardState == 0) or (not self.bossInfo.rewardState and self.bossInfo.hp ~= 0) then
        self.checkFightCtrl:setSelectedIndex(1)     -- 可挑战
    end
end

-- 设置体力
function GuildMLSChallegeView:initEnergyRecover()
    local icon = self.powerInfo:getChildAutoType("icon")
    local title = self.powerInfo:getChildAutoType("title")
    local btn_add = self.powerInfo:getChildAutoType("btn_add")
    local txt_countTimer = self.powerInfo:getChildAutoType("txt_countTimer")
    local allEnergy = ModelManager.GuildMLSModel.allEnergy
    title:setText(allEnergy)
    local energyLimit = ModelManager.GuildMLSModel:getEnergyLimitNum()
    if allEnergy < energyLimit then
        txt_countTimer:setVisible(true)
        ModelManager.GuildMLSModel:initEnergyRecoverTimer(txt_countTimer)
    else
        txt_countTimer:setVisible(false)
    end
    btn_add:removeClickListener(11)
    btn_add:addClickListener(function()
        ViewManager.open("GuildMLSPowerTipsView",{id = self.bossInfo.id})
    end,11)
end


function GuildMLSChallegeView:_exit()
    if self.timer then
        Scheduler.unschedule(self.timer)
        self.timer = false
    end
    if self.cdTimer then
        Scheduler.unschedule(self.cdTimer)
        self.cdTimer = false
    end
end


return GuildMLSChallegeView