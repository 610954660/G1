--added by wyang 公会大厅
local GuildMallView, Super = class("GuildMallView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
function GuildMallView:ctor(...)
    self._packName = "Guild"
    self._compName = "GuildMallView"
    self._rootDepth = LayerDepth.Window
    self.frame = false
    self.btn_main = false
    self.btn_shop = false
    self.btn_boss = false
    self.btn_open = false
    self.btn_science = false
    self.btn_augur = false
    self.img_redGuild1 = false
    self.img_redGuild2 = false
    self.img_redGuild5 = false
    self.calltimer = false
    self.btn_magicLS = false
    self.checkMLSCtrl = false
    self.skeletonNode={}
end

-------------------常用------------------------
--UI初始化
function GuildMallView:_initUI(...)
    self.frame = self.view:getChildAutoType("frame")
    self.btn_main = self.view:getChildAutoType("btn_main")
    self.btn_shop = self.view:getChildAutoType("btn_shop")
    self.btn_boss = self.view:getChildAutoType("btn_boss")
    self.btn_ghhourse = self.view:getChildAutoType("btn_ghhourse")
    -- self.btn_open = self.view:getChildAutoType("btn_open")
    self.btn_science = self.view:getChildAutoType("btn_science")
    self.btn_augur = self.view:getChildAutoType("btn_augur")
    self.btn_league = self.view:getChildAutoType("btn_league")
    self.img_redGuild1 = self.view:getChildAutoType("img_redGuild1")
    self.img_redGuild2 = self.view:getChildAutoType("img_redGuild2")
    self.img_redGuild3 = self.view:getChildAutoType("img_redGuild3")
    self.img_redGuild4 = self.view:getChildAutoType("img_redGuild4")
    self.img_redGuild5 = self.view:getChildAutoType("img_redGuild5")
    self.img_redGuild6 = self.view:getChildAutoType("img_redGuild6")
    self.img_redGuildcylf = self.view:getChildAutoType("img_redGuildcylf")
    --	self.guildList= FGUIUtil.getChild(self.view,"list_guild","GList")
    --	self.ctrl1 = self.view:getController("c1")
    --	self.guildList:setVirtual()
    self.frame:getChildAutoType("fullScreen"):setIcon("UI/Guild/gonghuiBg.jpg")
    self.typeCtrl = self.view:getController("typeCtrl")
    self.btn_cylf = self.view:getChildAutoType("btn_cylf")
    self.txt_bossname = self.view:getChildAutoType("txt_bossname")
    self.txt_time = self.view:getChildAutoType("txt_time")
    self.bossLoader = self.view:getChildAutoType("bossLoader")

    self.btn_magicLS = self.view:getChildAutoType("btn_magicLS")
    self.jingShiLoader = self.view:getChildAutoType("jingShiLoader")
    self.txt_jingShiNum = self.view:getChildAutoType("txt_jingShiNum")


    self.img_cylf = self.view:getChildAutoType("img_cylf")
    self.img_ghzb = self.view:getChildAutoType("img_ghzb")
    self.img_ghls = self.view:getChildAutoType("img_ghls")
    self.img_ghsd = self.view:getChildAutoType("img_ghsd")
    self.img_ghbz = self.view:getChildAutoType("img_ghbz")
    self.img_ky = self.view:getChildAutoType("img_ky")
    self.img_slc = self.view:getChildAutoType("img_slc")
    self.img_qy = self.view:getChildAutoType("img_qy")
    self.img_mlsrs = self.view:getChildAutoType("img_mlsrs")

    self.checkMLSCtrl = self.view:getController("checkMLSCtrl")
    GuildModel:GetGuildMemberOperInfoReq()
    local MLSTips = ModuleUtil.moduleOpen(ModuleId.GuildMLS.id, false)
    local mlsKey = tostring(FileDataType.MLS_JUMPENTERFILM .. ModelManager.PlayerModel.userid)
    local mlsEnter = FileCacheManager.getBoolForKey(mlsKey, false)
    if MLSTips == true and mlsEnter == false then
        local function endfunc1(eventName)
        end
        -- ViewManager.open(
        --     "PushMapFilmView",
        --     {isShowGuochangyun = false, step = "XML1", _rootDepth = LayerDepth.PopWindow, endfunc = endfunc1}
        -- )
        Dispatcher.dispatchEvent(EventType.guide_open, {guideMode = 2, guideName = "molingshan"})
        local mlsKey1 = tostring(FileDataType.MLS_JUMPENTERFILM .. ModelManager.PlayerModel.userid)
        FileCacheManager.setBoolForKey(mlsKey1, true)
    end
    local info = GuildModel.guildList
    self.btn_main:setTitle(string.format("%s Lv.%s", "总部", info.level))
    local infoMap = GuildModel.guildList.memberMap or {}
    local onlineNum = 0
    for key, itemInfo in pairs(infoMap) do
        if itemInfo.onlineState == 1 then
            onlineNum = onlineNum + 1
        end
    end
    self.btn_main:getChildAutoType("txt_time"):setText(string.format("%s人在线", onlineNum))
end
--添加红点
function GuildMallView:_addRed(...)
    RedManager.register("V_Guild_PANDECT", self.img_redGuild1, ModuleId.Guild.id)
    RedManager.register("V_Guild_DIVINATION", self.img_redGuild2, ModuleId.Guild.id)
    RedManager.register("V_Guild_BOSSRED", self.img_redGuild3, ModuleId.Guild.id)
    RedManager.register("V_Guild_SKILL", self.img_redGuild4, ModuleId.Guild_Skill.id)
    RedManager.register("V_Guild_CYLF", self.img_redGuildcylf, ModuleId.Guild.id)
    RedManager.register("V_Guild_MLS", self.img_redGuild5, ModuleId.Guild.id)
    RedManager.register("V_Guild_League", self.img_redGuild6, ModuleId.Guild.id)

    --公会boss后台战斗标记点亮
    RedManager.register("V_GuildNormalBoss", self.view:getChildAutoType("image_battle"))
    SpineUtil.createBattleFlag(self.view:getChildAutoType("image_battle"))
    --次元裂缝后台战斗标记点亮
    RedManager.register("V_GuildWorlBoss", self.view:getChildAutoType("image_battle1"))
    SpineUtil.createBattleFlag(self.view:getChildAutoType("image_battle1"))
    --魔灵山后台战斗标记点亮
    RedManager.register("V_EvilMountain", self.view:getChildAutoType("image_battle3"))
    SpineUtil.createBattleFlag(self.view:getChildAutoType("image_battle3"))
    -- 公会联赛
    RedManager.register("V_GuildLeague", self.view:getChildAutoType("image_battle6"))
	
	--魔灵收容所
    RedManager.register("V_Guild_MLS_Summon", self.view:getChildAutoType("img_redGuild5"))
    SpineUtil.createBattleFlag(self.view:getChildAutoType("image_battle6"))
end

function GuildMallView:guild_cylf_update()
    print(1, "guild_cylf_update")
    print(1, "guild_cylf_update")
    --boss名称
    local tips = ModuleUtil.hasModuleOpen(ModuleId.GuildFissure.id)
    if tips then
        print(1, "次元裂缝开放")
        local data = GuildModel:getCylfMainData()
        self:checkCYLFTime(data.endStamp, data)
    else
        self.typeCtrl:setSelectedIndex(0)
    end
end

function GuildMallView:guild_mls_update()
    local tips = ModuleUtil.hasModuleOpen(ModuleId.GuildMLS.id)
    if tips then
        print(1, "魔灵山开放")
        self.checkMLSCtrl:setSelectedIndex(1)
    else
        self.checkMLSCtrl:setSelectedIndex(0)
    end
end

function GuildMallView:guild_league_update()
    local isOpen = ModuleUtil.hasModuleOpen(ModuleId.GuildLeague.id)
    local ctrl = self.view:getController("leagueCtrl")
    if (isOpen) then
        ctrl:setSelectedIndex(1)
    else
        ctrl:setSelectedIndex(0)
    end
end

-- 设置晶石图标和数量
function GuildMallView:initJingShi()
    local JinshiCfg = ModelManager.GuildMLSModel:getJingShiCfg()
    local url = ItemConfiger.getItemIconByCode(JinshiCfg.code, JinshiCfg.type, true)
    self.jingShiLoader:setURL(url)
    local evilStoneLimit = DynamicConfigData.t_EvilConst[1].evilStoneLimit -- 魔晶石储存上限
    local haveNum = ModelManager.PackModel:getItemsFromAllPackByCode(JinshiCfg.code) -- 拥有的魔晶石的数量
    if haveNum >= evilStoneLimit then
        self.txt_jingShiNum:setText(string.format(Desc.GuildMLSMain_jinshiTxt1, haveNum, evilStoneLimit))
    elseif haveNum > 0 and haveNum < evilStoneLimit then
        self.txt_jingShiNum:setText(string.format(Desc.GuildMLSMain_jinshiTxt2, haveNum, evilStoneLimit))
    elseif haveNum == 0 then
        self.txt_jingShiNum:setText(string.format(Desc.GuildMLSMain_jinshiTxt3, haveNum, evilStoneLimit))
    end
end

function GuildMallView:pack_special_change()
    self:initJingShi()
end

function GuildMallView:Bag_UseItem()
    self:initJingShi()
end

function GuildMallView:player_levelUp(...)
    self:guild_cylf_update()
    self:guild_mls_update()
    self:guild_league_update()
end

function GuildMallView:checkCYLFTime(endtime, data)
    if not endtime then
        return
    end
    local serverTime = ServerTimeModel:getServerTime()
    local time = endtime - serverTime
    if time <= 0 then
        time = 0
    end
    print(1, "time", time)
    --备注  服务器让不要判断时间做入口限制
    -- if time>0 then
    --次元裂缝
    self.typeCtrl:setSelectedIndex(1)
    local bossConfig = GuildModel:getBossConfigById(data.bossId)
    -- self.txt_bossname:setText(bossConfig.bossName)
    self.bossLoader:setURL(PathConfiger.getBossHead(bossConfig.bossHead))
    if self.calltimer then
        TimeLib.clearCountDown(self.calltimer)
    end
    if time > 0 then
        self.txt_time:setText(TimeLib.GetTimeFormatDay(time, 1))
        local function onCountDown(time)
            if tolua.isnull(self.txt_time) then
                return
            end
            self.txt_time:setText(TimeLib.GetTimeFormatDay(time, 1))
        end
        local function onEnd(...)
        end
        self.calltimer = TimeLib.newCountDown(time, onCountDown, onEnd, false, false, false)
    else
        self.txt_time:setText(Desc.CohesionReward_str32)
    end

    -- else
    --     self.typeCtrl:setSelectedIndex(0)
    --     self.btn_cylf:removeClickListener(100)
    --     self.btn_cylf:addClickListener(
    --         function(...)
    --             RollTips.show("活动未开始")
    --         end
    --     ,100)
    -- end
end

function GuildMallView:isupLoadOpereReq(id)
    local moduleId=DynamicConfigData.t_GuildOperPos[id].moduleId 
    local tips1 = ModuleUtil.moduleOpen(moduleId,false)
    local tips2 = ModuleUtil.getModuleOpenTips(moduleId)
    if tips1==true and not tips2 then--前端开启了该功能
        GuildModel:reportGuildOper(id)
    end
end

--事件初始化
function GuildMallView:_initEvent(...)
    self.btn_main:addClickListener(
        function(...)
            self:isupLoadOpereReq(1)
            --		self.ctrl1:setSelectedIndex(self.ctrl1:getSelectedIndex() == 0 and 1 or 0)
            ViewManager.open("GuildMainView")
        end
    )
    self.img_ghzb:addClickListener(
        function(...)
            self:isupLoadOpereReq(1)
            ViewManager.open("GuildMainView")
        end
    )


    self.btn_shop:addClickListener(
        function(...)
            self:isupLoadOpereReq(3)
            ModuleUtil.openModule(ModuleId.Shop.id, true, {shopType = 4})
        end
    )

    self.img_ghsd:addClickListener(
        function(...)
            self:isupLoadOpereReq(3)
            ModuleUtil.openModule(ModuleId.Shop.id, true, {shopType = 4})
        end
    )

    self.btn_boss:addClickListener(
        function(...)
            self:isupLoadOpereReq(6)
            ViewManager.open("GuildBossView")
        end
    )
    self.img_slc:addClickListener(
        function(...)
            self:isupLoadOpereReq(6)
            ViewManager.open("GuildBossView")
        end
    )


    self.btn_ghhourse:addClickListener(
        function(...)
            self:isupLoadOpereReq(7)
            -- ViewManager.open("GuildHourseView")
            ModuleUtil.openModule(ModuleId.GuildHourse.id, true)
        end
    )

    self.img_ghbz:addClickListener(
        function(...)
            self:isupLoadOpereReq(7)
            -- ViewManager.open("GuildHourseView")
            ModuleUtil.openModule(ModuleId.GuildHourse.id, true)
        end
    )

    -- self.btn_open:addClickListener(
    --        function(...)
    --            --		self.ctrl1:setSelectedIndex(self.ctrl1:getSelectedIndex() == 0 and 1 or 0)
    --        end
    --    )

    self.btn_science:addClickListener(
        --技能
        function(...)
            self:isupLoadOpereReq(4)
            ViewManager.open("GuildskillsView")
        end
    )

    self.img_ky:addClickListener(
        --技能
        function(...)
            self:isupLoadOpereReq(4)
            ViewManager.open("GuildskillsView")
        end
    )

    self.btn_augur:addClickListener(
        function(...)
            self:isupLoadOpereReq(9)
            ViewManager.open("GuildDvinationView")
        end
    )

    self.img_qy:addClickListener(
        function(...)
            self:isupLoadOpereReq(9)
            ViewManager.open("GuildDvinationView")
        end
    )

    self.btn_cylf:removeClickListener(100)
    self.btn_cylf:addClickListener(
        function(...)
            self:isupLoadOpereReq(2)
            ModuleUtil.openModule(ModuleId.GuildFissure.id, true)
        end,
        100
    )

    self.img_cylf:addClickListener(
        function(...)
            self:isupLoadOpereReq(2)
            ModuleUtil.openModule(ModuleId.GuildFissure.id, true)
        end,
        100
    )

    self:guild_cylf_update()

    self.btn_magicLS:removeClickListener(111)
    self.btn_magicLS:addClickListener(
        function()
            self:isupLoadOpereReq(8)
            -- if not ModelManager.GuildMLSModel.firstIn then
            --     ModuleUtil.openModule(ModuleId.GuildMLS.id, true)
            --     -- local tips = ModuleUtil.hasModuleOpen(ModuleId.GuildMLS.id)
            --     -- if not tips then
            --     --     return
            --     -- end
            --     -- RPCReq.EvilMountain_OpenReq(
            --     --     {},
            --     --     function()
            --     --     end
            --     -- )
            -- else
            ModuleUtil.openModule(ModuleId.GuildMLS.id, true)
            -- end
        end,
        111
    )
    self.img_mlsrs:addClickListener(
        function()
            self:isupLoadOpereReq(8)
            -- if not ModelManager.GuildMLSModel.firstIn then
            --     ModuleUtil.openModule(ModuleId.GuildMLS.id, true)
            --     -- local tips = ModuleUtil.hasModuleOpen(ModuleId.GuildMLS.id)
            --     -- if not tips then
            --     --     return
            --     -- end
            --     -- RPCReq.EvilMountain_OpenReq(
            --     --     {},
            --     --     function()
            --     --     end
            --     -- )
            -- else
            ModuleUtil.openModule(ModuleId.GuildMLS.id, true)
            -- end
        end,
        111
    )


    self.btn_league:removeClickListener()
    self.btn_league:addClickListener(
        function()
            self:isupLoadOpereReq(5)
            local baseInfo = GuildLeagueModel:getBaseInfo()
            local actStatus = baseInfo.actStatus or 0
            local joinStatus = baseInfo.joinStatus or 0
            if (joinStatus == 1 and actStatus == GameDef.GuildPvpActStatus.Battle) then
                ViewManager.open("GuildLeagueFortView")
            else
                ModuleUtil.openModule(ModuleId.GuildLeague.id, true)
            end
        end
    )

    self.img_ghls:addClickListener(
        function()
            self:isupLoadOpereReq(5)
            local baseInfo = GuildLeagueModel:getBaseInfo()
            local actStatus = baseInfo.actStatus or 0
            local joinStatus = baseInfo.joinStatus or 0
            if (joinStatus == 1 and actStatus == GameDef.GuildPvpActStatus.Battle) then
                ViewManager.open("GuildLeagueFortView")
            else
                ModuleUtil.openModule(ModuleId.GuildLeague.id, true)
            end
        end
    )
    self:guild_league_update()
    self:guild_mls_update()
    self:initJingShi()

    --[[self.guildList:setItemRenderer(function(index,obj)
		local money = obj:getChildAutoType("money")
		money:setText("test")
		local itemcell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"));
		local itemData = ItemsUtil.createItemData({data = {code =10000015}})
		itemcell:setItemData(itemData)
			
		end)
	self.guildList:setData({1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4})	--]]
end

--initEvent后执行
function GuildMallView:guild_moduleshow_upData(...)
    local map = GuildModel.moduleOperInfo
    local GuildOperPos= DynamicConfigData.t_GuildOperPos
    for i = 1, #GuildOperPos, 1 do
        local arr=map[i] or{}
        local temp = {}
        for k, v in pairs(arr) do
            temp[#temp + 1] = v
        end
        TableUtil.sortByMap( temp , { {key="timeStamp",asc=true}} )
        local info=GuildOperPos[i]
        local limitNum=info.num
        for j = 1, limitNum, 1 do
            local disObj = self.view:getChildAutoType(string.format( "lihuiDisplay%s_%s",i,j))
            local playerInfo = temp[j]
            if playerInfo and disObj then
                disObj:setVisible(true)
                local skeletonNode = SpineMnange.createSprineById(playerInfo.showCode,nil,nil,nil,playerInfo.fashionCode)
                if not skeletonNode then
                    return
                end
                disObj:displayObject():addChild(skeletonNode)
                skeletonNode:setAnimation(0, "stand", true)
                skeletonNode:setScale(0.4,0.4)
                if not self.skeletonNode[i]  then
                    self.skeletonNode[i]={}
                end
                if self.skeletonNode[i][j] then
                    self.skeletonNode[i][j]:removeFromParent()
                end
                self.skeletonNode[i][j] = skeletonNode
            else
                disObj:setVisible(false)
            end
        end
    end
end

function GuildMallView:_enter(...)
end

--普通道具消息监听方法
--[[function GuildMallView:pack_item_change( ... )
	print(1,"pack_item_change")
--	self:updateItem(0)
end--]]
--页面退出时执行
function GuildMallView:_exit(...)
    --	self.itemcellArrs = {}
    print(1, "GuildMallView _exit")
    if self.calltimer then
        TimeLib.clearCountDown(self.calltimer)
    end
end

-------------------常用------------------------

return GuildMallView
