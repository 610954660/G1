local GuildFissureView, Super = class("GuildFissureView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
function GuildFissureView:ctor()
    self._packName = "Guild"
    self._compName = "GuildFissureView"
    self._rootDepth = LayerDepth.Window
    self.bossData = {}
    self.calltimer =false
    self.rankConfig = false
    self.bossConfig = false
    self.skeletonNode = false
    self.rewardData = false
    self.btn_okluaObj = false
end

function GuildFissureView:_initVM( )
    local vmRoot = self
    local viewNode = self.view
    ---Do not modify following code--------
    --{vmFields}:LoginAward.LoginAwardView
        vmRoot.list_skill = viewNode:getChildAutoType("$list_skill")--list
        vmRoot.btn_rank = viewNode:getChildAutoType("$btn_rank")
        vmRoot.btn_targetreward = viewNode:getChildAutoType("$btn_targetreward")
        vmRoot.com_model = viewNode:getChildAutoType("$com_model")
        vmRoot.txt_bossname = viewNode:getChildAutoType("$txt_bossname")
        vmRoot.txt_layer = viewNode:getChildAutoType("$txt_layer")
        vmRoot.txt_time = viewNode:getChildAutoType("$txt_time")
        vmRoot.list_reward = viewNode:getChildAutoType("$list_reward")
        vmRoot.txt_count = viewNode:getChildAutoType("$txt_count")
        vmRoot.btn_ok = viewNode:getChildAutoType("$btn_ok")
        vmRoot.fightVal = viewNode:getChildAutoType("$fightVal")
        vmRoot.dwLoader = viewNode:getChildAutoType("$dwLoader")
        vmRoot.dwtxt = viewNode:getChildAutoType("$dwtxt")
        vmRoot.txt = viewNode:getChildAutoType("$txt")
    --{vmFieldsEnd}:LoginAward.LoginAwardView
    --Do not modify above code-------------
end

function GuildFissureView:_initUI( )
    self:_initVM()
    self.com_bosstitle = self.view:getChildAutoType("com_bosstitle") 
    self.btn_tanyuan = self.view:getChildAutoType("btn_tanyuan")
    self.typeCtrl = self.view:getController("typeCtrl")
    self.bossLoader = self.view:getChildAutoType("bossLoader")
    self.numCtrl = self.view:getController("numCtrl")
    self.btn_okluaObj  = BindManager.bindCostButton(self.btn_ok)
end

function GuildFissureView:_initEvent(...)
    self.btn_rank:addClickListener(
        function(...)
            ViewManager.open("GuildFissuseRankView")
        end
    )
    
    self.btn_tanyuan:addClickListener(
        function()
            ModuleUtil.openModule(ModuleId.Hero.id, true)
        end
    )

    self.btn_targetreward:addClickListener(
        function(...)
            ViewManager.open("GuildFissureTargetRewardView")
        end
    )
    local costArr = GuildModel:getCylfNumCount( )
    local cost = {{type=2,code=2,amount=costArr[1],},}
    printTable(1,cost)
    self.btn_okluaObj:setData(cost[1])
    --挑战按钮
    self.btn_ok:addClickListener(function( ... )
        if self.bossData  and self.bossData.challengeCount and self.bossData.challengeCount>0 then --有次数
            -- if self.bossData.challengeCount>0 then
                local function battleHandler(eventName)
                    if eventName == "begin" then
                        local params = {}
                        params.bossId = self.bossData.bossId
                        params.onSuccess = function (res )
                        printTable(1,"挑战Boss数据返回",res)
                        self.rewardData = {}
                        self.rewardData.damage = res.damage
                        self.rewardData.rankLevel = res.rankLevel
                        self.rewardData.nextRankDamage = res.nextRankDamage
                        self.rewardData.bossConfig = self.bossConfig
                        self.rewardData.rankNum = res.rankNum
                        GuildModel:setCylfResultData( self.rewardData )
                        GuildModel:setCylfMainJoin(  )
                    end
                    RPCReq.Guild_ChallengeWorldBossReq(params, params.onSuccess)
                    elseif eventName == "end" then
                      local info = GuildModel:getCylfResultData()
                      local function func( ... )
                        local data = GuildModel:getCylfBossDataTemp(  )
                        GuildModel:setCylfBossData( data )
                        if tolua.isnull(self.view) then return  end
                        self:updatePanel()
                      end
                      ViewManager.open("ReWardView",{page=5,type=1,data=info,isWin=true,closefuc = func})
                    end
                end
                local configType = GameDef.BattleArrayType.GuildDailyBoss
                Dispatcher.dispatchEvent(
                    EventType.battle_requestFunc,
                    battleHandler,
                    {fightID = self.bossConfig.fightId, configType = self.bossConfig.battleArray}
                )
            -- else
            --     RollTips.show(Desc.guild_checkStr5)
            -- end

        else --没有次数 购买次数
            local info = {}
            info.text = string.format(Desc.guild_checkStr38,costArr[1],costArr[2])

            info.type = "yes_no"
            info.cost = {cost[1]}
            info.onlyHasNum = true
            info.onYes = function()
                if ModelManager.PlayerModel:isCostEnough(cost, true) then
                    local params = {}
                    params.onSuccess = function (res )
                        GuildModel:setCylfDataCount( res.count )
                        if tolua.isnull(self.view) then return  end
                        self:showCount()
                    end
                    RPCReq.Guild_PurchaseWorldBossChallengeCount(params, params.onSuccess)
                end
            end
            
            Alert.show(info)
        end
    end)

    --请求获取公会跨服BOSS数据
    local params = {}
    params.onSuccess = function (res )
        local data = res.worldBossInfo
        GuildModel:setCylfBossData( data )
        if tolua.isnull(self.view) then return end
        self:updatePanel()
    end
    RPCReq.Guild_WorldBossInfoReq(params, params.onSuccess)
end

function GuildFissureView:guild_update_fissure( ... )
    if tolua.isnull(self.view) then return end
    self:updatePanel()
end

--更新页面信息
function GuildFissureView:updatePanel( ... )
    self.bossData = GuildModel:getCylfBossData( )
    self.bossConfig = GuildModel:getBossConfigById( self.bossData.bossId)
    local rankLevel = 1
    if self.bossData.rankLevel>0 then
       rankLevel = self.bossData.rankLevel
    end
    print(1,"self.bossData.levelId",self.bossData.levelId)
    print(1,"rankLevel",rankLevel)
    self.rankConfig = GuildModel:getBossRankConfigByIndexs(self.bossData.levelId,rankLevel )
    self:showBossView(self.bossConfig)

end

--显示Boss
function GuildFissureView:showBossView(bossInfo)
    local bossid = bossInfo.bossId
    local arrowDesc=GuildModel:getGuildcylfBossTitleArrow(self.bossData.bossId)
    local  list_arrow = self.com_bosstitle:getChildAutoType("list_desc") 
    list_arrow:setItemRenderer(function(idx,obj)
        local arrowItem = arrowDesc[idx+1]
        obj:getChildAutoType("txt_attr"):setText( arrowItem.name) 
        local c1= obj:getController("c1")
        c1:setSelectedIndex(arrowItem.type-1)
    end)
    list_arrow:setData(arrowDesc)
    local monsterInfo = DynamicConfigData.t_monster[bossid]
    if not monsterInfo then
        return
    end
    if tolua.isnull(self.view) then return end
    self.view:getChildAutoType("frame/fullScreen"):setIcon("UI/Guild/"..bossInfo.bossBg);
    if self.skeletonNode then
        self.skeletonNode:removeFromParent()
    end
    local skeletonNode = SpineMnange.createSprineById(bossid)
    skeletonNode:setScaleX(-1)
	skeletonNode:setPosition(bossInfo.pos[1], bossInfo.pos[2])
    self.com_model:displayObject():addChild(skeletonNode)
    skeletonNode:setAnimation(0, "stand", true)
    self.skeletonNode = skeletonNode
    --怪物名称
    self.txt_bossname:setText(bossInfo.bossName)
    local bossLevel = GuildModel:getWorldBossLevel( self.bossData.levelId )
    self.txt_layer:setText(string.format(Desc.guild_checkStr35,bossLevel))
    self.bossLoader:setURL(PathConfiger.getBossHead(self.bossConfig.bossHead))
    self:checkTime()

    self:showCount()
    
    self:showskill(monsterInfo.skill)

    local reward = self.rankConfig.reward
    self:showReward(reward)
    
    self:showFight()

    self:showBtnRed()
end

--倒计时
function GuildFissureView:checkTime( ... )
    
    local time = GuildModel:getLastTime()
    print(1,"time",time)
    if time>0 then
        if self.calltimer then
            TimeLib.clearCountDown(self.calltimer)
        end
        self.txt_time:setText(TimeLib.GetTimeFormatDay(time,1))
        local function onCountDown( time )
            if  tolua.isnull(self.txt_time) then
                return
            end
             self.txt_time:setText(TimeLib.GetTimeFormatDay(time,1))
        end
        local function onEnd( ... )
        end
        self.calltimer = TimeLib.newCountDown(time, onCountDown, onEnd, false, false,false)
    end
end


--红点显示
function GuildFissureView:showBtnRed()
    -- if self.bossData.challengeCount> 0 then
    --     local img_red= self.btn_ok:getChild('img_red')
    --     img_red:setVisible(true)
    --     RedManager.updateValue("V_Guild_CYLF",true)
    -- end
    local data = GuildModel:getCylfMainData()
    if not data.isJoin then
        local img_red= self.btn_ok:getChild('img_red')
        img_red:setVisible(true)
    end
end

function GuildFissureView:showCount()
    if self.bossData.challengeCount<=0 then
        self.numCtrl:setSelectedIndex(1)
        local costArr = GuildModel:getCylfNumCount( )
        local cost = {{type=2,code=2,amount=costArr[1],},}
        self.btn_okluaObj:setData(cost[1])
        self.btn_okluaObj:setCostCtrl(1)
    else
        self.numCtrl:setSelectedIndex(0)
        self.btn_okluaObj:setCostCtrl(0)
    end
    self.txt_count:setText(string.format(Desc.Guild_Text1,self.bossData.challengeCount))
end


--显示技能
function GuildFissureView:showskill(skillArr)
    self.list_skill:setItemRenderer(
        function(index, obj)
            obj:removeClickListener(100)
            local skillId = skillArr[index + 1]
            local conf = DynamicConfigData.t_skill[skillId];
            local iconLoader = obj:getChildAutoType("iconLoader")
            iconLoader:setIcon(CardLibModel:getItemIconByskillId(conf.icon));
            obj:removeClickListener();
            obj:addClickListener(function ()
                if conf then
                    ViewManager.open("ItemTips", {codeType = CodeType.SKILL, id = skillId})
                end
            end)
        end
    )
    self.list_skill:setNumItems(#skillArr)
end

--显示奖励
function GuildFissureView:showReward(curReward)
    self.list_reward:setItemRenderer(
        function(index, obj)
            obj:removeClickListener(100)
             --池子里面原来的事件注销掉
            local itemcell = BindManager.bindItemCell(obj)
            local itemData = ItemsUtil.createItemData({data = curReward[index + 1]})
            itemcell:setItemData(itemData)
            itemcell:setFrameVisible(false)
            obj:addClickListener(function( ... )
                itemcell:onClickCell()
            end,100)
        end
    )
    self.list_reward:setNumItems(#curReward)
end

--显示伤害值  是否上榜
function GuildFissureView:showFight( ... )
    if (not self.bossData.rankLevel) or self.bossData.rankLevel==0   then --未上榜
        self.fightVal:setText(0)
        self.typeCtrl:setSelectedIndex(0)
    else
        self.fightVal:setText(self.bossData.maxDamage)
        self.typeCtrl:setSelectedIndex(1)
        local url = PathConfiger.getBossDw(self.bossData.rankLevel)
        self.dwLoader:setURL(url)
        self.dwtxt:setText(self.rankConfig.rankName)
        local rankLevel = self.bossData.rankLevel
        if rankLevel==1 then
            rankLevel = 1
            local str = string.format(Desc.guild_checkStr36,self.bossData.rankNum)
            self.txt:setText(str)
        else --不是王者
           rankLevel = rankLevel - 1
           local nextRankConfig = GuildModel:getBossRankConfigByIndexs(self.bossData.levelId,rankLevel )
           local str = string.format(Desc.guild_checkStr37,self.bossData.nextRankDamage,nextRankConfig.rankName)
           self.txt:setText(str)
        end
    end
end

--添加红点
function GuildFissureView:_addRed()
    local img_herored = self.btn_tanyuan:getChild("img_red")
    RedManager.register("M_Card", img_herored, ModuleId.Hero.id)
end


function GuildFissureView:_exit()
    if self.calltimer then
        TimeLib.clearCountDown(self.calltimer)
    end
end

return GuildFissureView
