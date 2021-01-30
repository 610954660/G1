
-- added by wyz
-- 公会 魔灵山主界面

local GuildMLSMainView = class("GuildMLSMainView",Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器

function GuildMLSMainView:ctor()
    self._packName = "GuildMagicLingShan"
    self._compName = "GuildMLSMainView"


    self.txt_noBossTips = false  -- 没有boss的时候提示文本
    self.descInfo       = false  -- 魔灵山描述文本
    self.txt_rewardTipsTitle = false -- 奖励预览标题
    self.list_showReward     = false -- 奖励列表
    self.txt_tipsDec         = false -- 晶石获取提示文本
    self.costIconLoader      = false -- 晶石图标
    self.txt_propNum         = false -- 晶石数量
    self.btn_summon          = false -- 召唤按钮 挑转到召唤界面
    self.firstIconLoader     = false -- 晶石大图标（首次进入魔灵山）
    self.relationLoader      = false -- 同公会的标志图标
    self.txt_challengeDec    = false -- 挑战同公会伤害加成描述文本
    self.btn_onlyGuild       = false -- 只看同公会按钮
    self.btn_refresh         = false -- 刷新按钮
    self.list_boss           = false -- boss列表

    self.checkBossCtrl       = false -- 判断有没有boss 
    self.checkFistInCtrl     = false -- 判断是不是首次进入

    self.leftInfo            = false

    self.onlyType            = 1  -- 0 只看同公会boss  1 看所有boss
    self.timer               = {}   -- 定时器

    self.powerInfo           = false
    self.aniSchedule         = false
end

function GuildMLSMainView:_initUI()
    self.leftInfo       = self.view:getChildAutoType("leftInfo")
    self.txt_noBossTips = self.view:getChildAutoType("txt_noBossTips")
    self.descInfo       = self.leftInfo:getChildAutoType("descInfo")
    self.txt_rewardTipsTitle = self.leftInfo:getChildAutoType("txt_rewardTipsTitle")
    self.list_showReward     = self.leftInfo:getChildAutoType("list_showReward")
    self.txt_tipsDec    = self.leftInfo:getChildAutoType("txt_tipsDec")
    self.costIconLoader     = self.leftInfo:getChildAutoType("costIconLoader")
    self.txt_propNum    = self.leftInfo:getChildAutoType("txt_propNum")
    self.btn_summon     = self.leftInfo:getChildAutoType("btn_summon")
    self.firstIconLoader    = self.leftInfo:getChildAutoType("firstIconLoader")
    self.relationLoader     = self.view:getChildAutoType("relationLoader")
    self.txt_challengeDec   = self.view:getChildAutoType("txt_challengeDec")
    self.btn_onlyGuild  = self.view:getChildAutoType("btn_onlyGuild")
    self.btn_refresh    = self.view:getChildAutoType("btn_refresh")
    self.list_boss      = self.view:getChildAutoType("list_boss")
    self.powerInfo = self.view:getChildAutoType("powerInfo")
    self.checkBossCtrl  = self.view:getController("checkBossCtrl")
    self.checkFistInCtrl    = self.leftInfo:getController("checkFistInCtrl")
    self:setBg("guildMLS.jpg")

    self.btn_help       = self.view:getChildAutoType("btn_help")
    self.btn_help:removeClickListener()
    self.btn_help:addClickListener(function(...)
        local info={}
        info['title']=Desc["help_StrTitle_MLS"]
        info['desc']=Desc["help_StrDesc_MLS"]
        ViewManager.open("GetPublicHelpView",info) 
    end)
	
	GuildMLSModel.hasOpenMLS = true
	RedManager.updateValue("V_Guild_MLS_Summon",false)
end


function GuildMLSMainView:_initEvent()
    if not ModelManager.GuildMLSModel.firstIn then
        local tips = ModuleUtil.hasModuleOpen(ModuleId.GuildMLS.id)
        if not tips then
            return
        end
        RPCReq.EvilMountain_OpenReq({},function()
        end)
    end
    self:initDescInfo()


    -- self:GuildMLSMain_refreshPanal()
    ModelManager.GuildMLSModel:reqBossListInfo()
end


function GuildMLSMainView:GuildMLSMain_refreshPanal()
    if tolua.isnull(self.view) then return end
    self.onlyType = FileCacheManager.getIntForKey("GuildMLSMain_onlyType",1)
    -- printTable(8848,">>.self.onlyType>>>",self.onlyType)
    -- 召唤按钮
    local img_red = self.btn_summon:getChildAutoType("img_red")
    RedManager.register("V_Guild_MLS_Summon", img_red)
    self.btn_summon:removeClickListener(11)
    self.btn_summon:addClickListener(function()
        local JinshiCfg = ModelManager.GuildMLSModel:getJingShiCfg()
        local haveNum  = ModelManager.PackModel:getItemsFromAllPackByCode(JinshiCfg.code) -- 拥有的魔晶石的数量
        if haveNum == 0 then
            RollTips.show(Desc.GuildMLSMain_clickJSTips)
            return
        end
        -- 跳转到召唤界面
        ViewManager.open("GuildMLSSummonBossView")
    end,11)

    -- 只看公会按钮
    self.btn_onlyGuild:removeClickListener(11)
    self.btn_onlyGuild:getController("button"):setSelectedIndex(self.onlyType == 0 and 1 or 0)
    self.btn_onlyGuild:addClickListener(function()
        self.onlyType = self.onlyType == 1 and 0 or 1
        self.btn_onlyGuild:getController("button"):setSelectedIndex(self.onlyType == 0 and 1 or 0)
        FileCacheManager.setIntForKey("GuildMLSMain_onlyType",self.onlyType)
        for k,v in pairs(self.timer) do
            if v then
                Scheduler.unschedule(v)
            end
        end
        self.timer = {}
        -- 刷新boss列表
        self:initBossList()
    end,11)

    -- 刷新按钮
    self.btn_refresh:removeClickListener(11)
    self.btn_refresh:addClickListener(function()
        -- 重新请求协议
        ModelManager.GuildMLSModel:reqBossListInfo()
    end,11)


    self:playFirstInAnimation()
    self:initShowRewardList()
    self:initJingShi()
    self:initBossList()
    self:initEnergyRecover()
end

-- 第一次进入魔灵山 播放动画 --领取魔灵山奖励
function GuildMLSMainView:playFirstInAnimation()
    local firstIn = ModelManager.GuildMLSModel.openReward
    self.checkFistInCtrl:setSelectedIndex(not firstIn and 1 or 0)
    if not firstIn then
        local playT1 = function()
            if not tolua.isnull(self.view) then
                self.leftInfo:getTransition("t1"):play(function() 
                end)
            end
        end
        local effectLoader = self.leftInfo:getChildAutoType("effectLoader")
        local x1 = effectLoader:getWidth() / 2;
        local y1 = effectLoader:getHeight() / 2;
        effectLoader:displayObject():removeAllChildren()
        local spine = SpineUtil.createSpineObj(effectLoader, cc.p(x1, y1), "mojingshi_texiao", "Effect/UI", "molingshan_texiao", "molingshan_texiao", true);

        if self.aniSchedule then
            Scheduler.unschedule(self.aniSchedule)
            self.aniSchedule = false
        end
        
        self.aniSchedule =   Scheduler.schedule(playT1,1.5)
        self.firstIconLoader:removeClickListener(11)
        self.firstIconLoader:setTouchable(true)
        self.firstIconLoader:addClickListener(function()
            -- self.leftInfo:getTransition("t1"):stop()
            effectLoader:displayObject():removeAllChildren()
            spine = false
            Scheduler.unschedule(self.aniSchedule)
            self.aniSchedule = false
            self.firstIconLoader:setTouchable(false)
            self.leftInfo:getTransition("t0"):play(function()
                self.checkFistInCtrl:setSelectedIndex(0)
                RPCReq.EvilMountain_GetOpenRewardReq({},function(params)
                --     -- printTable(8848,">>>params>> 开启魔灵山>>>",params)
                    ModelManager.GuildMLSModel.openReward = true
                end)
            end)
        end,11)
    end
end

-- 设置描述文本信息
function GuildMLSMainView:initDescInfo()
    local guildUrl          = PathConfiger.getRelationIcon(2) 
    self.relationLoader:setURL(guildUrl)

    self.txt_noBossTips:setText(Desc.GuildMLSMain_noBossTips)
    local txt_mlsDec = self.descInfo:getChildAutoType("title")
    txt_mlsDec:setText(Desc.GuildMLSMain_tipsDec1)
    self.txt_tipsDec:setText(Desc.GuildMLSMain_tipsDec2)
    self.txt_rewardTipsTitle:setText(Desc.GuildMLSMain_rewardTipsTitle)
    self.txt_challengeDec:setText(Desc.GuildMLSMain_challengeDec)
    local txt_onlyGuild = self.btn_onlyGuild:getChildAutoType("title")
    txt_onlyGuild:setText(Desc.GuildMLSMain_onlyGuild)
end

-- 设置展示奖励列表
function GuildMLSMainView:initShowRewardList()
    local rewardData = DynamicConfigData.t_EvilConst[1].rewardPre
    -- printTable(8848,">>>rewardData>>",rewardData)
    self.list_showReward:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local itemCell = BindManager.bindItemCell(obj)
        local reward = rewardData[index]
        itemCell:setData(reward.code,reward.amount,reward.type)
    end)
    self.list_showReward:setData(rewardData)
end

-- 设置晶石图标和数量
function GuildMLSMainView:initJingShi()
    local JinshiCfg = ModelManager.GuildMLSModel:getJingShiCfg()
    local url 			= ItemConfiger.getItemIconByCode(JinshiCfg.code, JinshiCfg.type, true)
    self.costIconLoader:setURL(url)
    self.firstIconLoader:setURL(url)
    local evilStoneLimit    = DynamicConfigData.t_EvilConst[1].evilStoneLimit   -- 魔晶石储存上限
    local haveNum  = ModelManager.PackModel:getItemsFromAllPackByCode(JinshiCfg.code) -- 拥有的魔晶石的数量
    if haveNum >= evilStoneLimit then
        self.txt_propNum:setText(string.format(Desc.GuildMLSMain_jinshiTxt1,haveNum,evilStoneLimit))
    elseif haveNum > 0 and haveNum < evilStoneLimit then
        self.txt_propNum:setText(string.format(Desc.GuildMLSMain_jinshiTxt2,haveNum,evilStoneLimit))
    elseif haveNum == 0 then
        self.txt_propNum:setText(string.format(Desc.GuildMLSMain_jinshiTxt3,haveNum,evilStoneLimit))
    end    
end

-- 设置boss列表信息
function GuildMLSMainView:initBossList()
    local bossInfo = ModelManager.GuildMLSModel:getGuildBossList(self.onlyType)
    -- printTable(8848,">>>bossInfo>>>",bossInfo)
    local bossNum  = TableUtil.GetTableLen(bossInfo)
    self.checkBossCtrl:setSelectedIndex(bossNum == 0 and 0 or 1)  -- 0 没有boss  1 有boss

    self.list_boss:setVirtual()
    self.list_boss:setItemRenderer(function(idx,obj)
        local index  = idx + 1
        -- print(8848,">>>>self.timer>>",obj:getName())
        local txt_oldIndex = obj:getChildAutoType("txt_oldIndex")   -- 用来记录定时器的名字
        -- local  oldIndex = txt_oldIndex:getText()
        -- if self.timer[tonumber(oldIndex)] then
        --    TimeLib.clearCountDown(self.timer[tonumber(oldIndex)])
        -- end

        -- txt_oldIndex:setText(index)
        if self.timer[txt_oldIndex] then
            Scheduler.unschedule(self.timer[txt_oldIndex])
            self.timer[txt_oldIndex] = false
        end

        local bossData  = bossInfo[index]
        local checkEndCtrl      = obj:getController("checkEndCtrl")       -- 判断是否已结束  0 没结束 ,1 已结束
        local checkBattleCtrl   = obj:getController("checkBattleCtrl")    -- 判断是否可挑战  0 可挑战 ,1 可领取,2 没奖励领
        local checkFightCtrl    = obj:getController("checkFightCtrl")     -- 判断是否打过    0 没打过 ,1 打过
        local btn_battle        = obj:getChildAutoType("btn_battle")      -- 挑战按钮
        local btn_take          = obj:getChildAutoType("btn_take")        -- 领取按钮
        local powerIconLoader   = obj:getChildAutoType("powerIconLoader") -- 体力图标
        local txt_powerNum      = obj:getChildAutoType("txt_powerNum")    -- 消耗的体力数量
        local txt_playerName    = obj:getChildAutoType("txt_playerName")  -- 玩家名字
        local txt_Lv            = obj:getChildAutoType("txt_Lv")          -- 召唤的等级
        local progressBar       = obj:getChildAutoType("progressBar")     -- 进度条（boss血量）
        local numIconLoader     = obj:getChildAutoType("numIconLoader")   -- 社交图标
        local txt_playerNum     = obj:getChildAutoType("txt_playerNum")   -- 有多少个人在挑战
        local timerIconLoader   = obj:getChildAutoType("timerIconLoader") -- 时钟图标
        local txt_countTimer    = obj:getChildAutoType("txt_countTimer")  -- 挑战boss剩余时间
        local bossIconLoader    = obj:getChildAutoType("bossIconLoader")  -- boss头像
        local relationLoader    = obj:getChildAutoType("relationLoader")  -- 同公会的标志
        local txt_bossLv        = obj:getChildAutoType("txt_bossLv")      -- 召唤的boss的等级
        
        local monsterId = ModelManager.GuildMLSModel:getMonsterIdByBossId(bossData.confId)
        local modelId   = DynamicConfigData.t_monster[monsterId].model
        local headId    = DynamicConfigData.t_AllResource[modelId].heroCard
        local headUrl   = PathConfiger.getHeroOfMonsterIcon(headId)
        bossIconLoader:setURL(headUrl)

        checkFightCtrl:setSelectedIndex(((not bossData.battleCount) or (bossData.battleCount == 0)) and 0 or 1 )

        local guildUrl          = PathConfiger.getRelationIcon(2) 
        relationLoader:setURL(guildUrl)
        relationLoader:setVisible((not bossData.ownerType or bossData.ownerType == 0 ))

        local bossLv            = ModelManager.GuildMLSModel:getBossLvById(bossData.confId)
        txt_bossLv:setText("Lv." .. bossLv)

        local val               = progressBar:getChildAutoType("val")
        local count             = progressBar:getChildAutoType("count")
        progressBar:setMax(bossData.maxHp)
        progressBar:setValue(bossData.hp)
        val:setText(MathUtil.toSectionStr(bossData.hp))
        count:setText(MathUtil.toSectionStr(bossData.maxHp))

        local serverTime = ModelManager.ServerTimeModel:getServerTimeMS()
        if bossData.rewardState == 1 then
            checkEndCtrl:setSelectedIndex(1)
            checkBattleCtrl:setSelectedIndex(1)  -- 可领取
            txt_countTimer:setText(Desc.GuildMLSMain_challengeEnd)
        else
            if bossData.hp == 0 then
                txt_countTimer:setText(Desc.GuildMLSMain_challengeEnd)
                checkEndCtrl:setSelectedIndex(1)
                checkBattleCtrl:setSelectedIndex(2) -- 没奖励
            elseif (serverTime < bossData.challengeStamp) then 
                    self:countTime(txt_countTimer,txt_oldIndex,bossData.challengeStamp,checkEndCtrl,checkBattleCtrl,bossData)
                -- 挑战还没结束 显示cd 
                checkEndCtrl:setSelectedIndex(0)
                checkBattleCtrl:setSelectedIndex(0)-- 可挑战
            else 
                txt_countTimer:setText(Desc.GuildMLSMain_challengeEnd)
                checkEndCtrl:setSelectedIndex(1)
                checkBattleCtrl:setSelectedIndex(2) -- 没奖励
            end
        end


        txt_powerNum:setText(bossData.energy)
        txt_playerName:setText(string.format(Desc.GuildMLSMain_summonPlayerName,bossData.ownerName))
        txt_Lv:setText("Lv." .. bossData.ownerLevel)
        txt_playerNum:setText(string.format(Desc.GuildMLSMain_challengePeople,bossData.challengeNum))
        
        
        btn_battle:removeClickListener(11)
        btn_battle:addClickListener(function()
            -- 跳转到挑战界面
            ViewManager.open("GuildMLSChallegeView",{bossId = bossData.confId,id = bossData.id})
        end,11)

        btn_take:removeClickListener(11)
        btn_take:addClickListener(function()
            -- ViewManager.open("GuildMLSTakeRewardView")
            ViewManager.open("GuildMLSChallegeView",{bossId = bossData.confId,id = bossData.id})
        end,11)

        obj:removeClickListener(11)
        obj:addClickListener(function(context)
            context:stopPropagation()--阻止事件冒泡
            ViewManager.open("GuildMLSChallegeView",{bossId = bossData.confId,id = bossData.id})
        end,11)


    end)
    self.list_boss:setData(bossInfo)
end


-- 设置boss列表倒计时
function GuildMLSMainView:countTime(txt_countTimer,txt_oldIndex,challengeEndTime)
    local serverTime = ModelManager.ServerTimeModel:getServerTimeMS()
    challengeEndTime = math.floor((challengeEndTime - serverTime)/1000)
    local nowTime = challengeEndTime
    if nowTime > 0 then
        local function onCountDown(dt)
            nowTime = nowTime - dt
            if not tolua.isnull(txt_countTimer) then
                txt_countTimer:setText(TimeLib.formatTime(math.floor(nowTime)))
            end
            if nowTime <= 0 then
                Scheduler.unschedule(self.timer[txt_oldIndex])
                self.timer[txt_oldIndex] = false
                ModelManager.GuildMLSModel:reqBossListInfo()
            end
        end

        if not tolua.isnull(txt_countTimer) then
            txt_countTimer:setText(TimeLib.formatTime(math.floor(nowTime)))
        end

		self.timer[txt_oldIndex] = Scheduler.schedule(function(dt)
            onCountDown(dt)
        end,0.1)
    else
        if not tolua.isnull(txt_countTimer) then
            txt_countTimer:setText(Desc.GuildMLSMain_challengeEnd)
        end
    end
end

-- 设置体力
function GuildMLSMainView:initEnergyRecover()
    local icon = self.powerInfo:getChildAutoType("icon")
    local title = self.powerInfo:getChildAutoType("title")
    local btn_add = self.powerInfo:getChildAutoType("btn_add")
    local txt_countTimer = self.powerInfo:getChildAutoType("txt_countTimer")
    local allEnergy = false 
    local firstIn = ModelManager.GuildMLSModel.firstIn
    if not firstIn then
        allEnergy = ModelManager.GuildMLSModel:getEnergyLimitNum()
    else
        allEnergy = ModelManager.GuildMLSModel.allEnergy
    end
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
        ViewManager.open("GuildMLSPowerTipsView")
    end,11)
end

function GuildMLSMainView:_exit()
    for k,v in pairs(self.timer) do
        if v then
            Scheduler.unschedule(self.timer[k])
            self.timer[k] = false
        end
    end

    if ModelManager.GuildMLSModel and ModelManager.GuildMLSModel.powerTimer then
        Scheduler.unschedule(ModelManager.GuildMLSModel.powerTimer)
        ModelManager.GuildMLSModel.powerTimer = false
    end
    if self.aniSchedule then
        self.leftInfo:getTransition("t1"):stop()
        Scheduler.unschedule(self.aniSchedule)
        self.aniSchedule = false
    end
end



return GuildMLSMainView