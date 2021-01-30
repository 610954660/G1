-- added by wyz 
-- 公会 魔灵召唤界面

local GuildMLSSummonBossView = class("GuildMLSSummonBossView",Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器

function GuildMLSSummonBossView:ctor()
    self._packName = "GuildMagicLingShan"
    self._compName = "GuildMLSSummonBossView"

    self.btn_checkLeft  = false      -- 左切换按钮
    self.btn_checkRight = false      -- 右切换按钮
    self.bossIconLoader = false      -- boss图片
    self.txt_bossName   = false      -- boss名字
    self.btn_add        = false      -- 增加难度按钮
    self.btn_sub        = false      -- 降低难度按钮
    self.txt_bossLv     = false      -- boss等级
    self.progressBar    = false      -- 进度条(boss血量)
    self.txt_atk        = false      -- boss基础攻击力
    self.txt_pDef        = false      -- boss物理防御
    self.txt_mDef       = false      -- 法防
    self.txt_summonTitle = false     -- 召唤奖励标题
    self.txt_skillInfo  = false      -- 技能预览
    self.list_skill     = false      -- 技能列表
    self.list_reward    = false      -- 奖励列表
    self.btn_summon     = false      -- 召唤按钮
    self.txt_consume    = false      -- 消耗
    self.consumeIconLoader = false   -- 魔晶石图标
    self.txt_consumeNum = false      -- 魔晶石数量
    self.costItem       = false      -- 消耗金币数量

    self.pBossIndex     = 1          -- boss索引 
    self.allBossNum     = false      -- boss总数量
    self.bossSummonMaxLv      = false      -- 当前可召唤boss的最大等级  
    self.bossLv         = false      -- boss等级   
    self.lihuiDisplay   = false    
    self.powerInfo           = false
    self.powerTimer          = false 
end

function GuildMLSSummonBossView:_initUI()
    self.btn_checkLeft  = self.view:getChildAutoType("btn_checkLeft")
    self.btn_checkRight = self.view:getChildAutoType("btn_checkRight")
    self.bossIconLoader = self.view:getChildAutoType("bossIconLoader")
    self.txt_bossName   = self.view:getChildAutoType("txt_bossName")
    self.btn_add    = self.view:getChildAutoType("btn_add")
    self.btn_sub    = self.view:getChildAutoType("btn_sub")
    self.txt_bossLv     = self.view:getChildAutoType("txt_bossLv")
    self.progressBar    = self.view:getChildAutoType("progressBar")
    self.txt_atk    = self.view:getChildAutoType("txt_atk")
    self.txt_pDef    = self.view:getChildAutoType("txt_pDef")
    self.txt_mDef    = self.view:getChildAutoType("txt_mDef")

    self.txt_summonTitle    = self.view:getChildAutoType("txt_summonTitle")
    self.txt_skillInfo  = self.view:getChildAutoType("txt_skillInfo")
    self.list_skill     = self.view:getChildAutoType("list_skill")
    self.list_reward    = self.view:getChildAutoType("list_reward")
    self.btn_summon     = self.view:getChildAutoType("btn_summon")
    self.txt_consume    = self.view:getChildAutoType("txt_consume")
    self.consumeIconLoader  = self.view:getChildAutoType("consumeIconLoader")
    self.txt_consumeNum     = self.view:getChildAutoType("txt_consumeNum")
    self.costItem   = self.view:getChildAutoType("costItem")
    self.powerInfo   = self.view:getChildAutoType("powerInfo")

    self.lihuiDisplay = self.view:getChildAutoType("lihuiDisplay")
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

function GuildMLSSummonBossView:_initEvent()
    self:GuildMLSSummonBoss_refreshPanal()
end

function GuildMLSSummonBossView:initLihui(modelId)
    -- local lihuiDisplay = BindManager.bindLihuiDisplay(self.lihuiDisplay)
    -- lihuiDisplay:setData(modelId)
    local bossInfo = ModelManager.GuildMLSModel:getSummonBossInfo(self.pBossIndex)
    local size = bossInfo[self.bossLv].size
    if self.bossIconLoader then
        self.bossIconLoader:setScale(size,size)
        self.bossIconLoader:displayObject():removeAllChildren()
    end
    SpineUtil.createModel(self.bossIconLoader, {x = 0, y =0}, "stand", modelId,true)
	

end

function GuildMLSSummonBossView:GuildMLSSummonBoss_refreshPanal()
    local bossInfo = ModelManager.GuildMLSModel:getSummonBossInfo(self.pBossIndex)
    self.bossSummonMaxLv = ModelManager.GuildMLSModel.maxBossLevel 
    if self.bossSummonMaxLv > TableUtil.GetTableLen(bossInfo) then
        self.bossLv    = TableUtil.GetTableLen(bossInfo)
        self.bossSummonMaxLv = TableUtil.GetTableLen(bossInfo)
    else
        self.bossLv = self.bossSummonMaxLv
    end
    self.allBossNum = TableUtil.GetTableLen(DynamicConfigData.t_EvilBossSummon)

    self.btn_checkLeft:setVisible(self.pBossIndex ~= 1 and true or false)
    self.btn_checkRight:setVisible(self.pBossIndex ~= self.allBossNum and true or false)

    self.btn_checkLeft:removeClickListener(11)
    self.btn_checkLeft:addClickListener(function()
        if self.pBossIndex == 1 then return end
        if self.pBossIndex ~= 1 then
            self.pBossIndex = self.pBossIndex - 1
        end
        self.btn_checkLeft:setVisible(self.pBossIndex ~= 1 and true or false)
        self.btn_checkRight:setVisible(self.pBossIndex ~= self.allBossNum and true or false)
        self:initPanal()
    end,11)

    self.btn_checkRight:removeClickListener(11)
    self.btn_checkRight:addClickListener(function()
        if self.pBossIndex == self.allBossNum then return end
        if self.pBossIndex ~= self.allBossNum then
            self.pBossIndex = self.pBossIndex + 1
        end
        self.btn_checkLeft:setVisible(self.pBossIndex ~= 1 and true or false)
        self.btn_checkRight:setVisible(self.pBossIndex ~= self.allBossNum and true or false)
        self:initPanal()
    end,11)
    self:initEnergyRecover()
    self:initPanal()
end


function GuildMLSSummonBossView:initPanal()
    local bossInfo = ModelManager.GuildMLSModel:getSummonBossInfo(self.pBossIndex)
    printTable(8848,">>>self.bossLv.>>",self.bossLv)
    local maxBossLv = ModelManager.GuildMLSModel:getBossMaxLvById(bossInfo[self.bossLv].bossId)
    local monsterId = ModelManager.GuildMLSModel:getMonsterIdByBossId(bossInfo[self.bossLv].bossId)
    local modelId   = DynamicConfigData.t_monster[monsterId].model
    self:initLihui(modelId)

    self.btn_add:setGrayed((self.bossLv == maxBossLv))
    self.btn_add:setTouchable((self.bossLv ~= maxBossLv))
    self.btn_add:removeClickListener(11)
    self.btn_add:addClickListener(function()
        if self.bossLv + 1 > self.bossSummonMaxLv  and self.bossSummonMaxLv < maxBossLv then
            RollTips.show(Desc.GuildMLSMain_noSummonBossTips)
            return 
        end

        if self.bossLv == self.bossSummonMaxLv then 
            return
        else
            self.bossLv = self.bossLv + 1
        end
        self:initPanal()
        self.btn_add:setGrayed((self.bossLv == maxBossLv))
        self.btn_add:setTouchable((self.bossLv ~= maxBossLv))
    end,11)

    self.btn_sub:setGrayed((self.bossLv == 1))
    self.btn_sub:setTouchable((self.bossLv ~= 1))
    self.btn_sub:removeClickListener(11)
    self.btn_sub:addClickListener(function()
        if self.bossLv == 1 then
            return
        else
            self.bossLv = self.bossLv - 1
        end
        self:initPanal()
        self.btn_sub:setGrayed((self.bossLv == 1))
        self.btn_sub:setTouchable((self.bossLv ~= 1))
    end,11)

    -- boss基础信息
    -- printTable(8848,">>>bossInfo>>>",bossInfo)
    -- print(8848,">>>self.bossLv")
    local attribute = bossInfo[self.bossLv].attribute[1]
    -- self.bossIconLoader:setURL()
    self.txt_bossName:setText(bossInfo[self.bossLv].name)
    self.txt_bossLv:setText("Lv." .. self.bossLv)
    self.progressBar:setMax(attribute.hp)
    self.progressBar:setValue(attribute.hp)
    local pVal      = self.progressBar:getChildAutoType("val")
    local pCount    = self.progressBar:getChildAutoType("count")
    pVal:setText(MathUtil.toSectionStr(attribute.hp))
    pCount:setText(MathUtil.toSectionStr(attribute.hp))
    self.txt_atk:setText(string.format(Desc.GuildMLSMain_bossAtk,attribute.atk))
    self.txt_pDef:setText(string.format(Desc.GuildMLSMain_bosspDef,attribute.pDef))
    self.txt_mDef:setText(string.format(Desc.GuildMLSMain_bossmDef,attribute.mDef))

    -- boss技能
    local monsterId = bossInfo[self.bossLv].monsterId
    local skillInfo = DynamicConfigData.t_monster[monsterId].skill
    self.txt_skillInfo:setText(Desc.GuildMLSMain_skillInfo)
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

    -- 击败可得奖励
    self.txt_summonTitle:setText(Desc.GuildMLSMain_summonTitle)
    local rewardData = bossInfo[self.bossLv].openRewardPre
    self.list_reward:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local itemCell = BindManager.bindItemCell(obj)
        local reward = rewardData[index]
        itemCell:setData(reward.code,reward.amount,reward.type)
    end)
    self.list_reward:setData(rewardData)

    -- 召唤消耗道具
    self.txt_consume:setText(Desc.GuildMLSMain_consume)
    local openCost  = bossInfo[self.bossLv].openCost
    local JinshiCfg = ModelManager.GuildMLSModel:getJingShiCfg()
    local url 			= ItemConfiger.getItemIconByCode(JinshiCfg.code, JinshiCfg.type, true)
    self.consumeIconLoader:setURL(url)
    local evilStoneLimit    = openCost[1].amount
    local haveNum  = ModelManager.PackModel:getItemsFromAllPackByCode(JinshiCfg.code) -- 拥有的魔晶石的数量
    if haveNum >= evilStoneLimit then
        self.txt_consumeNum:setText(string.format(Desc.GuildMLSMain_jinshiTxt1,haveNum,evilStoneLimit))
    elseif haveNum > 0 and haveNum < evilStoneLimit then
        self.txt_consumeNum:setText(string.format(Desc.GuildMLSMain_jinshiTxt2,haveNum,evilStoneLimit))
    elseif haveNum == 0 then
        self.txt_consumeNum:setText(string.format(Desc.GuildMLSMain_jinshiTxt3,haveNum,evilStoneLimit))
    end

    -- local costData = openCost[2]
    -- local costItem = BindManager.bindCostItem(self.costItem)
    -- costItem:setData(costData.type,costData.code,costData.amount,true)

    -- 召唤按钮
    self.btn_summon:removeClickListener(11)
    self.btn_summon:addClickListener(function()
        local reqInfo = {
            confId = bossInfo[self.bossLv].bossId,
        }
        RPCReq.EvilMountain_SummonReq(reqInfo,function(params)
            print(8848,">>>EvilMountain_SummonReq>>boss召唤成功>>>",bossInfo[self.bossLv].name)
            -- 发送事件 刷新主界面
            RollTips.show(Desc.GuildMLSMain_summonSuccess)
            printTable(8848,">>>>params>>>",params)
            -- Dispatcher.dispatchEvent(EventType.GuildMLSMain_refreshPanal)
            ModelManager.GuildMLSModel:reqBossListInfo()
            ViewManager.close("GuildMLSSummonBossView")
        end)
    end,11)
end 

-- 设置体力
function GuildMLSSummonBossView:initEnergyRecover()
    local icon = self.powerInfo:getChildAutoType("icon")
    local title = self.powerInfo:getChildAutoType("title")
    local btn_add = self.powerInfo:getChildAutoType("btn_add")
    local txt_countTimer = self.powerInfo:getChildAutoType("txt_countTimer")
    local allEnergy = ModelManager.GuildMLSModel.allEnergy
    title:setText(allEnergy)
    local energyLimit = ModelManager.GuildMLSModel:getEnergyLimitNum()
    if allEnergy < energyLimit then
        txt_countTimer:setVisible(true)
        -- self:countTimeEnergy(txt_countTimer)
        -- if ModelManager.GuildMLSModel.powerTimer then
        --     TimeLib.clearCountDown(ModelManager.GuildMLSModel.powerTimer)
        -- end
        ModelManager.GuildMLSModel:initEnergyRecoverTimer(txt_countTimer)
    else
        txt_countTimer:setVisible(false)
    end
    btn_add:removeClickListener(11)
    btn_add:addClickListener(function()
        ViewManager.open("GuildMLSPowerTipsView")
    end,11)
end

function GuildMLSSummonBossView:countTimeEnergy(txt_countTimer)
    local serverTime = ModelManager.ServerTimeModel:getServerTimeMS()
    local recoverStamp = ModelManager.GuildMLSModel.recoverStamp
    local countTime = ModelManager.GuildMLSModel:getEnergyRecover()
    countTime = ((countTime + recoverStamp) - serverTime)/1000
    txt_countTimer:setText(TimeLib.formatTime(countTime))
    local function onCountDown( time )
        txt_countTimer:setText(TimeLib.formatTime(time))
    end
    local function onEnd( ... )
        -- self:countTimeEnergy(txt_countTimer)
        -- 如果达到上限
        -- txt_countTimer:setText(Desc.GuildMLSMain_challengeEnd)
        if self.powerTimer then
            TimeLib.clearCountDown(self.powerTimer)
        end
    end
    if self.powerTimer then
        TimeLib.clearCountDown(self.powerTimer)
    end
    self.powerTimer = TimeLib.newCountDown(countTime, onCountDown, onEnd, false, false,false)
end

function GuildMLSSummonBossView:_exit()
    if self.powerTimer then
        TimeLib.clearCountDown(self.powerTimer)
    end
end



return GuildMLSSummonBossView
