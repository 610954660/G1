--added by wyang 公会大厅
local GuildBossView, Super = class("GuildBossView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
local ItemSkillCell = require "Game.UI.Global.ItemSkillCell"
function GuildBossView:ctor(...)
    self._packName = "Guild"
    self._compName = "GuildBossView"
    self._rootDepth = LayerDepth.Window
    -- self.img_di=false
    -- self.img_bg=false
    -- self.img_bossHead=false
    self.com_model = false
    self.btn_Left = false
    self.btn_rigth = false
    self.btn_rank = false
    self.bossInfo = false
    self.txt_bossname = false
    self.list_skill = false
    self.list_reward = false
    self.txt_count = false
    self.txt_limitcount = false
    self.txt_time = false
    self.timeContro = false
    self.btn_noOpen = false
    self.seleIdex = 1
end

-------------------常用------------------------
--UI初始化
function GuildBossView:_initUI(...)
    local viewRoot = self.view
    -- self.img_di = viewRoot:getChildAutoType("img_di")
    -- self.img_bg = viewRoot:getChildAutoType("img_bg")
    -- self.img_bossHead = viewRoot:getChildAutoType("img_bossHead")
    self.btn_rank = viewRoot:getChildAutoType("btn_rank")
    self.btn_ok = viewRoot:getChildAutoType("btn_ok")
    self.btn_sweep = viewRoot:getChildAutoType("btn_sweep")
    self.btn_noOpen = viewRoot:getChildAutoType("btn_noOpen")
    self.btn_Left = viewRoot:getChildAutoType("btn_Letf")
    self.btn_rigth = viewRoot:getChildAutoType("btn_rigth")
    self.com_model = viewRoot:getChildAutoType("com_model")
    self.com_model = self.com_model:displayObject()
    self.txt_bossname = viewRoot:getChildAutoType("txt_bossname")
    self.list_skill = viewRoot:getChildAutoType("list_skill")
    self.list_reward = viewRoot:getChildAutoType("list_reward")
    self.txt_count = viewRoot:getChildAutoType("txt_count")
    self.txt_limitcount = viewRoot:getChildAutoType("txt_limitcount")
    self.txt_time = viewRoot:getChildAutoType("txt_time")
    self.timeContro = viewRoot:getController("c1")
    self.btn_tanyuan = viewRoot:getChildAutoType("btn_tanyuan")
    self.com_bosstitle = self.view:getChildAutoType("com_bosstitle")
    self.bossInfo = GuildModel:getBossInfo()
    -- self:setBg(GuildModel:getBossViewdi());
    self.btn_Left:setVisible(self.seleIdex > 1)
    self.btn_rigth:setVisible(self.seleIdex < #self.bossInfo)
    local bossItem = self.bossInfo[1]
    local bossItem1 = self.bossInfo[2]
    local remainTimes, maxTimes = MaterialCopyModel:getRemainTumes(bossItem.bossType)
    local remainTimes1, maxTimes1 = MaterialCopyModel:getRemainTumes(bossItem1.bossType)
    local isOpen = GuildModel:getguildBossisOpen(bossItem1.bossType)
    if remainTimes <= 0 and isOpen and remainTimes1 > 0 then
        self.seleIdex=2
    else
        self.seleIdex=1
    end
    self.btn_Left:setVisible(self.seleIdex > 1)
    self.btn_rigth:setVisible(self.seleIdex < #self.bossInfo)
    self:showBossView(self.bossInfo[self.seleIdex])
    self:showSweepBtnGray()
end

function GuildBossView:showBossView(bossInfo)
	if not bossInfo then return end
    local bossid = bossInfo.bossId
    local arrowDesc = GuildModel:getGuildBossTitleArrow(bossInfo.bossType)
    local list_arrow = self.com_bosstitle:getChildAutoType("list_desc")
    list_arrow:setItemRenderer(
        function(idx, obj)
            local arrowItem = arrowDesc[idx + 1]
            obj:getChildAutoType("txt_attr"):setText(arrowItem.name)
            local c1 = obj:getController("c1")
            c1:setSelectedIndex(arrowItem.type - 1)
        end
    )
    list_arrow:setData(arrowDesc)

    local monsterInfo = DynamicConfigData.t_monster[bossid]
    if not monsterInfo then
        return
    end
    self.view:getChildAutoType("frame/fullScreen"):setIcon("UI/Guild/" .. bossInfo.bossBg)
    -- local monistarConfig=DynamicConfigData.t_monster[bossid];
    -- local iconId=monistarConfig.model
    -- self.img_bossHead:setURL(PathConfiger.getHeroOfMonsterIcon(bossid))
    local skeletonNode = SpineMnange.createSprineById(bossid)
    skeletonNode:setScaleX(-1)
    self.com_model:addChild(skeletonNode)
    skeletonNode:setAnimation(0, "stand", true)
    if self.skeletonNode then
        self.skeletonNode:removeFromParent()
    end
    self.skeletonNode = skeletonNode
    self.txt_bossname:setText(bossInfo.bossName)
    self:showCount(bossInfo.bossType)
    if self.seleIdex == 2 then
        local isOpen = GuildModel:getguildBossisOpen(bossInfo.bossType)
        if isOpen == true then
            self.timeContro:setSelectedIndex(2)
            local hour, second = GuildModel:getBossRemainTime(bossInfo.bossType)
            self.txt_time:setText(string.format(Desc.guild_checkStr9, hour, second))
        else
            self:showLimitBossCount()
            self.timeContro:setSelectedIndex(1)
        end
    else
        self.timeContro:setSelectedIndex(0)
    end
    self:showskill(monsterInfo.skill)
    self:showReward(bossInfo.preReward)
    self:showBtnRed()
end

function GuildBossView:showskill(skillArr)
    self.list_skill:setItemRenderer(
        function(index, obj)
            obj:removeClickListener(100)
            --池子里面原来的事件注销掉
            local skillId = skillArr[index + 1]
            -- printTable(1, skillId);
            local conf = DynamicConfigData.t_skill[skillId]
            local iconLoader = obj:getChildAutoType("iconLoader")
            iconLoader:setIcon(CardLibModel:getItemIconByskillId(conf.icon))
            obj:removeClickListener()
            obj:addClickListener(
                function()
                    if conf then
                        ViewManager.open("ItemTips", {codeType = CodeType.SKILL, id = skillId})
                    end
                end
            )
        end
    )
    self.list_skill:setNumItems(#skillArr)
end

function GuildBossView:showReward(curReward)
    self.list_reward:setItemRenderer(
        function(index, obj)
            obj:removeClickListener(100)
            --池子里面原来的事件注销掉
            local itemcell = BindManager.bindItemCell(obj)
            local award = curReward[index + 1]
            itemcell:setData(award.code, award.amount, award.type)
            itemcell:setFrameVisible(false)
            obj:addClickListener(
                function(...)
                    itemcell:onClickCell()
                end,
                100
            )
        end
    )
    self.list_reward:setNumItems(#curReward)
end

function GuildBossView:showCount(copyCode)
    local remainTimes, maxTimes = MaterialCopyModel:getRemainTumes(copyCode)
    self.txt_count:setText(string.format("%s: %s%s", Desc.guild_checkStr8, remainTimes, Desc.guild_checkStr11))
end

function GuildBossView:showLimitBossCount()
    local info = GuildModel.guildList
    local cost = GuildModel:getGuildBossOpencost()
    self.txt_limitcount:setText(string.format("%s/%s", info.activeScore, cost))
end

--事件初始化
function GuildBossView:_initEvent(...)
    local help = self.view:getChildAutoType("frame"):getChildAutoType("btn_help")
    help:removeClickListener()
    help:addClickListener(
        function(...)
            local info = {}
            info["title"] = Desc.help_StrTitle9
            info["desc"] = Desc.help_StrDesc9
            ViewManager.open("GetPublicHelpView", info)
        end
    )

    self.btn_sweep:addClickListener(
        function(...)
            local copyInfo = self.bossInfo[self.seleIdex]
            local tips = ModuleUtil.moduleOpen(ModuleId.GuildBossSweep.id, true)
            if tips == true then
                local remainTimes, maxTimes = MaterialCopyModel:getRemainTumes(copyInfo.bossType)
                if remainTimes > 0 then
                    local Hurt = GuildModel:getBossHurt(copyInfo.bossType)
                    if Hurt > 0 then
                        ModuleUtil.openModule(ModuleId.GuildBossSweep.id, true, {copyCode = copyInfo.bossType})
                    else
                        RollTips.show(Desc.CohesionReward_str27)
                    end
                else
                    RollTips.show(Desc.CohesionReward_str28)
                end
            end
        end
    )

    self.btn_Left:addClickListener(
        function(...)
            self.seleIdex = self.seleIdex - 1
            if  self.seleIdex<=0 then
                self.seleIdex=1
            end
            self:showBossView(self.bossInfo[self.seleIdex])
            self.btn_Left:setVisible(self.seleIdex > 1)
            self.btn_rigth:setVisible(self.seleIdex < #self.bossInfo)
            self:showSweepBtnGray()
        end
    )

    self.btn_rigth:addClickListener(
        function(...)
            self.seleIdex = self.seleIdex + 1
            if self.seleIdex>=#self.bossInfo then
                self.seleIdex=#self.bossInfo
            end
            self:showBossView(self.bossInfo[self.seleIdex])
            self.btn_Left:setVisible(self.seleIdex > 1)
            self.btn_rigth:setVisible(self.seleIdex < #self.bossInfo)
            self:showSweepBtnGray()
        end
    )
    self.btn_rank:addClickListener(
        function(...)
            --  ViewManager.open('GuildBossRankView')
            if self.seleIdex == 1 then
                local type = GameDef.RankType.GuildDailyBoss
                ViewManager.open("GuildBossRankView", {type = GameDef.RankType.GuildDailyBoss})
            elseif self.seleIdex == 2 then
                ViewManager.open("GuildBossRankView", {type = GameDef.RankType.GuildLimitBoss})
            end
        end
    )

    self.btn_tanyuan:addClickListener(
        function()
            ModuleUtil.openModule(ModuleId.Hero.id, true)
        end
    )

    self.btn_ok:addClickListener(
        function(...)
            --ViewManager.open('GuildBossSweepView')
            local copyInfo = self.bossInfo[self.seleIdex]
			if not copyInfo then return end
            RedManager.updateValue("V_Guild_BOSSITEM" .. copyInfo.bossType, false)
            MaterialCopyModel:setFirstLoginState(copyInfo.bossType)
            self:showBtnRed()
            local remainTimes, maxTimes = MaterialCopyModel:getRemainTumes(copyInfo.bossType)
            if remainTimes > 0 then
                local function battleHandler(eventName)
                    if eventName == "begin" then
                        GuildModel:challengeGuildBoss(copyInfo.bossType)
                    elseif eventName == "end" then
                        --  ViewManager.open('GuildBossEndLayerView')
                        local info = GuildModel.guildBossReward
                        ViewManager.open("ReWardView", {page = 3, type = 1, data = info, isWin = true})
                    end
                end
                local configType = GameDef.BattleArrayType.GuildDailyBoss
                if self.seleIdex == 2 then
                    configType = GameDef.BattleArrayType.GuildLimitBoss
                end
                Dispatcher.dispatchEvent(
                    EventType.battle_requestFunc,
                    battleHandler,
                    {fightID = copyInfo.fightId, configType = configType, bossType = copyInfo.bossType}
                )
            else
                RollTips.show(Desc.guild_checkStr5)
            end
        end
    )

    self.btn_noOpen:addClickListener(
        function(...)
            local copyInfo = self.bossInfo[self.seleIdex]
            RedManager.updateValue("V_Guild_BOSSITEM" .. copyInfo.bossType, false)
            MaterialCopyModel:setFirstLoginState(copyInfo.bossType)
            self:showBtnRed()
            local posTion = GuildModel.guildList.myGuildPosition
            local canOpen = GuildModel:getPostionOpenbossBtn(posTion)
            if canOpen == true then
                local info = {}
                info.text = Desc.guild_checkStr6
                info.type = "yes_no"
                info.mask = true
                info.onYes = function()
                    local copyInfo = self.bossInfo[self.seleIdex]
                    GuildModel:openGuildBoss(copyInfo.bossType)
                end
                Alert.show(info)
            else
                RollTips.show(Desc.guild_checkStr7)
            end
        end
    )
end

function GuildBossView:showBtnRed()
    local copyInfo = self.bossInfo[self.seleIdex]
    local red = RedManager.getTips("V_Guild_BOSSITEM" .. copyInfo.bossType)
    printTable(22, "bossdsayingde红点", red, copyInfo.bossType)
    if red == nil then
        red = false
    end
    local img_red = self.btn_ok:getChild("img_red")
    img_red:setVisible(red)

    local limitRightRed = RedManager.getTips("V_Guild_BOSSITEM" .. 501)
    if limitRightRed == nil then
        limitRightRed = false
    end
    local img_limitRightRed = self.btn_rigth:getChild("img_red")
    img_limitRightRed:setVisible(limitRightRed)
    local img_noOpenred = self.btn_noOpen:getChild("img_red")
    img_noOpenred:setVisible(limitRightRed)
end

function GuildBossView:showSweepBtnGray()
    local copyInfo = self.bossInfo[self.seleIdex]
    local remainTimes, maxTimes = MaterialCopyModel:getRemainTumes(copyInfo.bossType)
    if remainTimes > 0 then
        self.btn_sweep:setGrayed(false)
    else
        self.btn_sweep:setGrayed(true)
    end
end

function GuildBossView:guild_up_guildOpenBossSuc(_, data)
    printTable(22, "boss成功开启")
    self:showBossView(self.bossInfo[self.seleIdex])
end

function GuildBossView:materialCopy_updata(_, data)
    printTable(5, "点击扫荡1")
    self:showCount(data.type)
    self:showSweepBtnGray()
end

function GuildBossView:materialCopy_pass(_, copytype)
    printTable(5, "点击扫荡2")
    self:showCount(copytype)
    self:showSweepBtnGray()
end

function GuildBossView:materialCopy_addCopyNum(_, copytype)
    printTable(5, "增加次数2")
    self:showCount(copytype)
end

function GuildBossView:materialCopy_resetDay(_, copytype)
    printTable(5, "跨天重置2")
    self:showCount(copytype)
end

--添加红点
function GuildBossView:_addRed()
    local img_herored = self.btn_tanyuan:getChild("img_red")
    RedManager.register("M_Card", img_herored, ModuleId.Hero.id)
end

--initEvent后执行
function GuildBossView:_enter(...)
end

--页面退出时执行
function GuildBossView:_exit(...)
    self.seleIdex = 1
end

-------------------常用------------------------

return GuildBossView
