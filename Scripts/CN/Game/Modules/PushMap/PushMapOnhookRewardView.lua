--领取快速挂机
local PushMapOnhookRewardView, Super = class("PushMapOnhookRewardView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger"
local Point = require "Game.Common.Geom.Point"
function PushMapOnhookRewardView:ctor()
    self._packName = "PushMap"
    self._compName = "PushMapOnhookRewardView"
    self._rootDepth = LayerDepth.PopWindow
    self.calltimer = false
    --快速挂机
    self.Btn_free = false
    self.Btn_agglutination = false
    self.btn_gray = false
    self.txt_vip1 = false
    self.txt_vip2 = false
    self.times = false
    self.txt_reTimeDec = false
    self.gCtr = false
    self.activateCtrl = false
    self.QuickOnhookData = {}
    self.vip_goto = false
    self.agglutinationBind = false
    --快速挂机
    self.list_reward = false
    self.Btn_get = false
    self.serverRewardInfo = {}
    self.itemCount = 0
    self.eachTime = 0
    self.eachTime2 = 0
    self.itemIndex = 0
    self.itemIndex2 = 0
    self.catScheduler = false
    self.itemArr = {}
    self.calltimer2 = false

    self.carNode = false
    self.carNodePos = false
    self.catStatus = false
    self.catModel = false
    self.aniItemCount = 0
    self.flyFlag = false
    self.schaduleId = false
    
    self.curClientTime=false--给汉德缓存的
end

--检测距离
function PushMapOnhookRewardView:checkDistance()
    for i = 1, 8 do
        local pos = self.itemArr[i]:localToGlobal(Vector2.zero)
        local itemPos = cc.vertex2F(pos.x, pos.y)
        local lengh = Point.distance(self.carNodePos, itemPos)        
        if math.ceil(lengh) >= 140 and math.ceil(lengh) <= 152 and itemPos.x >= self.carNodePos.x then
            if  self.itemArr[i].flag then
                return 
            end
            self.itemArr[i].flag = true
            self.aniItemCount = self.aniItemCount + 1
            print(1,"当前播放动画的是",i)
            self.itemArr[i]:getTransition("t0"):play(
                function(...)
                    if not self.flyFlag then
                        self:changeAnimation(1)
                    end
                end
            )
            if self.aniItemCount == 8 then
                self.aniItemCount = 0
                if not self.flyFlag then
                    self:changeAnimation(4) --有爱心特效的吃
                end
                
            else
                if not self.flyFlag then
                    self:changeAnimation(5) --正常的吃
                end
            end
        end

        if lengh >= 150 and itemPos.x < self.carNodePos.x then
            self.itemArr[i].flag = false
            self.itemArr[i]:getChildAutoType("icon"):setScale(0.5, 0.5)
        end
    end
end

function PushMapOnhookRewardView:_initUI()
    self.serverRewardInfo = {}
    self.Btn_free = self.view:getChild("Btn_free")
    self.Btn_agglutination = self.view:getChild("Btn_agglutination")
    self.btn_gray = self.view:getChild("btn_gray")
    self.vip_goto = self.view:getChild("vip_goto")
    self.txt_vip1 = self.view:getChild("txt_vip1")
    self.txt_vip2 = self.view:getChild("txt_vip2")
    self.times = self.view:getChild("times")
    self.txt_reTimeDec = self.view:getChild("txt_reTimeDec")
    self.gCtr = self.view:getController("c1")
    self.activateCtrl = self.view:getController("activateCtrl")
    self.txt_time = self.view:getChild("txt_time")
    self.txt_timeMax = self.view:getChildAutoType("txt_timeMax")
    self.btn_tq = self.view:getChildAutoType("btn_tq")
    self.progressBar = self.view:getChildAutoType("progressBar")
    self.btn_help = self.view:getChildAutoType("btn_help")
    self.txt_newtequandesc = self.view:getChildAutoType("txt_newtequandesc")
    self.txt_timeMax:setText(
        string.format(Desc.pushmap_onhookmax, 12 + VipModel:getVipPrivilige(GameDef.VipPriviligeType.OnhookTime))
    )
    self.Btn_get = self.view:getChild("Btn_get")
    self.list_reward = self.view:getChildAutoType("list_reward")
    self.carNode = self.view:getChildAutoType("movecomp"):getChildAutoType("n54")
    local pos = self.carNode:localToGlobal(Vector2.zero)
    self.carNodePos = cc.vertex2F(pos.x, pos.y)
    printTable(1, self.carNodePos)
    self:changeModel(false)
    self:showView()
    local movecomp = self.view:getChildAutoType("movecomp")
    for i = 1, 8 do
        self.itemArr[i] = self.view:getChildAutoType("movecomp"):getChildAutoType("item" .. i)
    end
    self.view:displayObject():onUpdate(
        function(dt)
            self:checkDistance()
        end
    )
    if self.Btn_agglutination then
        self.agglutinationBind = BindManager.bindCostButton(self.Btn_agglutination)
    end
    self:PriviligeGift_upGiftData(false)
    local priviligeDesc= PriviligeGiftModel:getPriviligeDesc()
    self.txt_newtequandesc:setText(priviligeDesc)
end

--变成肥猫
function PushMapOnhookRewardView:changeModel(flag)
    if flag == self.catStatus and self.catModel then
        return
    end
    if tolua.isnull(self.view) then
        return
    end
    self.spineParent = self.view:getChildAutoType("movecomp"):getChildAutoType("spineParent")
    self.catStatus = flag
    if self.catModel then
        self.catModel:removeFromParent()
        self.catModel = false
    end
    if flag then
        -- self:changeAnimation(4)
        self.catModel =
            SpineUtil.createSpineObj(
            self.spineParent,
            vertex2(0, 0),
            "walk",
            "Spine/ui/pushMap",
            "P_mao",
            "P_mao",
            true
        )
        print(1, "变成肥猫模型")
    else
        -- self:changeAnimation(3)
        self.catModel =
            SpineUtil.createSpineObj(
            self.spineParent,
            vertex2(0, 0),
            "walk",
            "Spine/ui/pushMap",
            "S_mao",
            "S_mao",
            true
        )
        print(1, "变成瘦毛模型")
    end
end

--更换动作
function PushMapOnhookRewardView:changeAnimation(type)
    -- print(1, "changeAnimation")
    if not self.catModel then
        return
    end
    if tolua.isnull(self.view) then
        return
    end
    local spineParent_down = self.view:getChildAutoType("movecomp"):getChildAutoType("spineParent_down")
    local spineParent_up = self.view:getChildAutoType("movecomp"):getChildAutoType("spineParent_up")
    spineParent_down:displayObject():removeAllChildren()
    spineParent_up:displayObject():removeAllChildren()
    if type == 1 then
        self.catModel:setAnimation(0, "walk", true)
    elseif type == 2 then
        self.catModel:setAnimation(0, "run", true)
    elseif type == 3 then
        local fx_aixin_down =
            SpineUtil.createSpineObj(
            spineParent_down,
            vertex2(0, 0),
            "fx_chongci_down",
            "Spine/ui/pushMap",
            "jumao_texiao",
            "jumao_texiao",
            true
        )
        self.catModel:setAnimation(0, "fei", true)
        local fx_chongci_up =
            SpineUtil.createSpineObj(
            spineParent_up,
            vertex2(0, 0),
            "fx_chongci_up",
            "Spine/ui/pushMap",
            "jumao_texiao",
            "jumao_texiao",
            true
        )
    elseif type == 4 then   --有爱心特效的吃
        local fx_aixin_down =
            SpineUtil.createSpineObj(
            spineParent_down,
            vertex2(0, 0),
            "fx_aixin_down",
            "Spine/ui/pushMap",
            "jumao_texiao",
            "jumao_texiao",
            false
        )
        self.catModel:setAnimation(0, "walk", false)
        self.catModel:setAnimation(1, "walk_chi", false)
        local fx_aixin_up =
            SpineUtil.createSpineObj(
            spineParent_up,
            vertex2(0, 0),
            "fx_aixin_up",
            "Spine/ui/pushMap",
            "jumao_texiao",
            "jumao_texiao",
            false
        )
    elseif type == 5 then  --正常的吃
        self.catModel:setAnimation(0, "walk", false)
        self.catModel:setAnimation(1, "walk_chi", false)
    end
end

--让猫飞起来
function PushMapOnhookRewardView:makecatFly( ... )
   if tolua.isnull(self.view) then return end
   self:changeAnimation(3)
   self.flyFlag = true
   self.view:getChildAutoType("movecomp"):getTransition("t0"):setTimeScale(3)
   self.schaduleId =  Scheduler.scheduleOnce(5,function()
   self:backtoNormal()
end)
end

function PushMapOnhookRewardView:backtoNormal( ... )
    self:changeAnimation(1)
    self.flyFlag = false
    if not tolua.isnull(self.view) then
        self.view:getChildAutoType("movecomp"):getTransition("t0"):setTimeScale(1)
    end
end

function PushMapOnhookRewardView:showView()
    local serverInfo = PushMapModel.pushMaponHookInfo
    if next(serverInfo) == nil then
        return
    end
    self:showTextstr()
    self:showText(serverInfo.hangUpMax)
    self:showList(serverInfo)
end

function PushMapOnhookRewardView:showTextstr()
    local serverInfo = PushMapModel.pushMaponHookInfo
    if next(serverInfo) == nil then
        return
    end
    local cityId = PushMapModel.curOnhookInfo.chapterCity or 1
    local chapterId = PushMapModel.curOnhookInfo.chapterPoint or 1
    local pointId = PushMapModel.curOnhookInfo.chapterLevel or 1
    printTable(19, ">>>>>>>>>guanka", cityId, chapterId, pointId, serverInfo)
    local chapterInfo = DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId]
    if not chapterInfo then
        return
    end
    local configInfo = DynamicConfigData.t_chaptersPointFightFd[chapterInfo.fightfd]
    if not configInfo then
        return
    end
    -- OnhookReiki = 2, -- 挂机灵气收益加成
    -- OnhookGold = 3, -- 挂机金币收益
    -- OnhookExp = 4, -- 挂机经验收益
    local addxishu={}
    local addxishu1=VipModel:getVipPrivilige(GameDef.VipPriviligeType.OnhookGold)
    local addxishu2=VipModel:getVipPrivilige(GameDef.VipPriviligeType.OnhookReiki)
    local addxishu3=VipModel:getVipPrivilige(GameDef.VipPriviligeType.OnhookExp)
    table.insert( addxishu, addxishu1)
    table.insert( addxishu, addxishu2)
    table.insert( addxishu, addxishu3)
    for i = 1, 3, 1 do
        local imgKey = "img_" .. i
        local txtKey = "txt_" .. i
        local imgCell = self.view:getChild(imgKey)
        local txtCell = self.view:getChild(txtKey)
        local greward = configInfo.greward[i]
        local URL = ItemConfiger.getItemIconByCodeAndType(greward.type, greward.code)
        imgCell:setURL(URL)
        local colorAddStr=ColorUtil.formatColorString1(string.format("+%s",math.floor(greward.amount*addxishu[i]/100)),"#119717")
        txtCell:setText(math.floor(greward.amount)..colorAddStr .. "/分")
    end
end

function PushMapOnhookRewardView:showText(hangUpMax)
    -- local hstr = math.floor(hangUpMax/(60*60))
    -- local mstr = math.floor(hangUpMax/60)%60
    -- local sstr = math.floor(hangUpMax%60)
    local onhookTime = 12 * 60 * 60 + VipModel:getVipPrivilige(GameDef.VipPriviligeType.OnhookTime) * 3600
    self.txt_time:setText(TimeLib.formatTime(hangUpMax, true, false))
    self.progressBar:setValue(hangUpMax)
    self.progressBar:setMax(onhookTime)
    self:updateActivateCtrl()
    if hangUpMax / onhookTime >= 0.25 then
        print(1, "达到1/4？", math.ceil(hangUpMax / onhookTime), hangUpMax, onhookTime)
        self:changeModel(true)
    else
        self:changeModel(false)
    end
    self.curClientTime=hangUpMax
    local function onCountDown(time)
        if tolua.isnull(self.view) then
            return
        end
        if time >= onhookTime then
            time = onhookTime
        end
        self.progressBar:setValue(time)
        self.progressBar:setMax(onhookTime)
        if time / onhookTime >= 0.25 then
            print(1, "达到1/4？", math.ceil(time / onhookTime))
            self:changeModel(true)
        else
            self:changeModel(false)
        end
        self.curClientTime=time
        self.txt_time:setText(TimeLib.formatTime(time, true, false))
    end
    local function onEnd(...)
    end
    if self.calltimer then
        TimeLib.clearCountDown(self.calltimer)
    end
    self.calltimer = TimeLib.newCountDown(hangUpMax, onCountDown, onEnd, false, true, false)
end

function PushMapOnhookRewardView:showList(serverInfo)
    if serverInfo.reward then
        for key, value in pairs(serverInfo.reward) do
            if value.code then
                local configInfo = ItemConfiger.getInfoByCode(value.code, value.type)
                value["color"] = 1
                if configInfo then
                    value["color"] = configInfo.color
                end
                table.insert(self.serverRewardInfo, value)
            end
        end
    end
    TableUtil.sortByMap(self.serverRewardInfo, {{key = "color", asc = true}})
    self.list_reward:setItemRenderer(
        function(index, obj)
            local itemcell = BindManager.bindItemCell(obj)
            local award = self.serverRewardInfo[index + 1]
            itemcell:setData(award.code, award.amount, award.type)
            itemcell:setFrameVisible(false)
            obj:removeClickListener(100)
            obj:addClickListener(
                function(...)
                    itemcell:onClickCell()
                end,
                100
            )
        end
    )
    local count = 0
    if next(self.serverRewardInfo) then
        count = #self.serverRewardInfo
    end
    printTable(10, ">>>>>>>>>>>?????", self.serverRewardInfo, count)
    self.list_reward:setNumItems(count)
end

function PushMapOnhookRewardView:pushMap_updateInfo(_, data)
    local serverInfo = PushMapModel.pushMaponHookInfo
    printTable(20, "??????????????", serverInfo)
    if next(serverInfo) == nil then
        return
    end
    
    self:showTextstr()
    self:showText(serverInfo.hangUpMax)
    self.serverRewardInfo = {}
    for key, value in pairs(serverInfo.reward) do
        if value.code then
            local configInfo = ItemConfiger.getInfoByCode(value.code, value.type)
            value["color"] = 1
            if configInfo then
                value["color"] = configInfo.color
            end
            table.insert(self.serverRewardInfo, value)
        end
    end
    TableUtil.sortByMap(self.serverRewardInfo, {{key = "color", asc = true}})
    local count = 0
    printTable(10, ">>>>>>>>>1111", serverInfo, self.serverRewardInfo)
    if next(self.serverRewardInfo) then
        count = #self.serverRewardInfo
    end
    self.list_reward:setNumItems(count)
end

function PushMapOnhookRewardView:update_ActivateCtrl( ... )
    if tolua.isnull(self.view) then return end
    self:updateActivateCtrl()
end

function PushMapOnhookRewardView:updateActivateCtrl( ... )
    local state1,remingTime1= PriviligeGiftModel:getPriviligeGiftById(1)--快速行动特权
    if (not state1) then
        if self.progressBar:getValue()/self.progressBar:getMax() >=1 then
            self.activateCtrl:setSelectedIndex(2)
        else
            self.activateCtrl:setSelectedIndex(1)
        end
    else
        if self.progressBar:getValue()/self.progressBar:getMax() >=1 then
            self.activateCtrl:setSelectedIndex(2)
        else
            self.activateCtrl:setSelectedIndex(0)
        end
    end
end

-- 更新免费次数
function PushMapOnhookRewardView:PriviligeGift_upGiftData(refreshData)
    local state1,remingTime1= PriviligeGiftModel:getPriviligeGiftById(1)--快速行动特权
    if (not state1) then
        -- if self.progressBar:getValue() >=1 then
        --     self.activateCtrl:setSelectedIndex(2)
        -- else
        --     self.activateCtrl:setSelectedIndex(1)
        -- end
        
        local conf = DynamicConfigData.t_Privilige[1]
        local free = conf and conf.count1+1 or 0
        local buy = conf and conf.count2 or 0
        self.txt_vip1:setText(free)
        self.txt_vip2:setText(buy)
        self.vip_goto:removeClickListener(222)
        self.vip_goto:addClickListener(
            function()
                ModuleUtil.openModule(ModuleId.PriviligeGiftView, true)
            end,
            222
        )
    else
        -- if self.progressBar:getValue() >=1 then
        --     self.activateCtrl:setSelectedIndex(2)
        -- else
        --     self.activateCtrl:setSelectedIndex(0)
        -- end
    end
    -- self:updateActivateCtrl()
    refreshData = refreshData == nil and refreshData or true
    if (refreshData) then
        RPCReq.Chapters_GetFastTimes(
            {},
            function(args)
                self.QuickOnhookData = args
                if tolua.isnull(self.view) then
                    return
                end
                self:upViewInfo()
            end
        )
    else
        self:upViewInfo()
    end
    local priviligeDesc= PriviligeGiftModel:getPriviligeDesc()
    self.txt_newtequandesc:setText(priviligeDesc)
end

function PushMapOnhookRewardView:show_gameReward()
	self:PriviligeGift_upGiftData(false)
end


--UI初始化
function PushMapOnhookRewardView:_initEvent(...)
    self.btn_help:removeClickListener()
    self.btn_help:addClickListener(
        function(...)
            local info = {}
            info["title"] = Desc["help_StrTitleKSXD"]
            info["desc"] = Desc["help_StrDescKSXD"]
            ViewManager.open("GetPublicHelpView", info)
        end
    )

    self.Btn_get:addClickListener(
        function(...)
            PlayerModel:setTempExp()
            local amount = 0
            for key, value in pairs(self.serverRewardInfo) do
                if value.type == 2 and value.code == 9 then
                    amount = value.amount
                end
            end
            local max = DelegateModel:beyondPointMax(amount)
            if max == false then
                PushMapModel:setPushmapRewardGuajiCache(self.curClientTime) 
                -- PlayerModel:setTempExp()
                PushMapModel:receiveHangUpReward()
                -- ViewManager.close("PushMapOnhookRewardView")
            else
                local info = {}
                info.text = "本次奖励领取将导致委托积分超出上限值" .. max .. "超出上限值的部分，将无法获得，请问要直接领取吗"
                info.type = "yes_no"
                info.mask = true
                info.yesText = "直接领取"
                info.noText = "前往委托"
                info.onYes = function()
                    PushMapModel:setPushmapRewardGuajiCache(self.curClientTime) 
                    -- PlayerModel:setTempExp()
                    PushMapModel:receiveHangUpReward()
                    -- ViewManager.close("PushMapOnhookRewardView")
                end
                info.onNo = function()
                    ModuleUtil.openModule(ModuleId.Delegate, true)
                end
                Alert.show(info)
            end
        end
    )

    self.btn_tq:addClickListener(
        function()
            ModuleUtil.openModule(ModuleId.PriviligeGiftView.id)
        end
    )

    self.Btn_agglutination:addClickListener(
        function(...)
            PlayerModel:setTempExp()
            local configRewardInfo = self:getReward()
            local amount = 0
            for key, value in pairs(configRewardInfo) do
                if value.type == 2 and value.code == 9 then
                    amount = value.amount
                end
            end
            printTable(16, ">>>>>sdfwe", amount)
            local max = DelegateModel:beyondPointMax(amount * 120)
            if max == false then
                PushMapModel:FastBattle(nil,nil,nil,function(flag)
                    if flag then
                        PushMapModel:setPushmapRewardGuajiCache(2*3600) 
                        self:makecatFly()
                    end
                end)
                -- self:closeView()
            else
                local info = {}
                info.text = string.format(Desc.pushmap_str3, max)
                info.type = "yes_no"
                info.mask = true
                info.yesText = Desc.pushmap_str4
                info.noText = Desc.pushmap_str5
                info.onYes = function()
                    PushMapModel:FastBattle(nil,nil,nil,function(flag)
                        if flag then
                            PushMapModel:setPushmapRewardGuajiCache(2*3600) 
                            self:makecatFly()
                        end
                    end)
                    -- self:closeView()
                end
                info.onNo = function()
                    ModuleUtil.openModule(ModuleId.Delegate, true)
                end
                Alert.show(info)
            end
        end
    )
    self.Btn_free:addClickListener(
        function(...)
            PlayerModel:setTempExp()
            local configRewardInfo = self:getReward()
            local amount = 0
            for key, value in pairs(configRewardInfo) do
                if value.type == 2 and value.code == 9 then
                    amount = value.amount
                end
            end
            local max = DelegateModel:beyondPointMax(amount * 120)
            if max == false then
                PushMapModel:FastBattle(nil,nil,nil,function(flag)
                    if flag then
                        PushMapModel:setPushmapRewardGuajiCache(2*3600) 
                        self:makecatFly()
                    end
                end)
                -- self:closeView()
            else
                local info = {}
                info.text = string.format(Desc.pushmap_str3, max)
                info.type = "yes_no"
                info.mask = true
                info.yesText = Desc.pushmap_str4
                info.noText = Desc.pushmap_str5
                info.onYes = function()
                    PushMapModel:FastBattle(nil,nil,nil,function(flag)
                        if flag then
                            PushMapModel:setPushmapRewardGuajiCache(2*3600) 
                            -- PlayerModel:setTempExp()
                            self:makecatFly()
                        end
                    end)
                    -- self:closeView()
                end
                info.onNo = function()
                    ModuleUtil.openModule(ModuleId.Delegate, true)
                end
                Alert.show(info)
            end
        end
    )

    self.btn_gray:addClickListener(
        function(...)
            local state1,remingTime1= PriviligeGiftModel:getPriviligeGiftById(1)--快速行动特权
            if (not state1) then
                ModuleUtil.openModule(ModuleId.PriviligeGiftView)
            else
                ModuleUtil.openModule(ModuleId.Vip.id)
            end
        end
    )
end

function PushMapOnhookRewardView:getReward()
    local greward = {}
    local cityId = PushMapModel.curOnhookInfo.chapterCity or 1
    local chapterId = PushMapModel.curOnhookInfo.chapterPoint or 1
    local pointId = PushMapModel.curOnhookInfo.chapterLevel or 1
    local chapterInfo = DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId]
    if not chapterInfo then
        return greward
    end
    local configInfo = DynamicConfigData.t_chaptersPointFightFd[chapterInfo.fightfd]
    if not configInfo then
        return greward
    end
    greward = configInfo.greward
    return greward
end

function PushMapOnhookRewardView:upViewInfo()
    local gCtr = self.gCtr
    local isFree = self.QuickOnhookData.usrFreeTimes - self.QuickOnhookData.freeTimes -- 免费次数
    local isNoFree = self.QuickOnhookData.usrPayTimes - self.QuickOnhookData.payTimes -- 付费次数
    isFree = isFree > 0 and isFree or 0
    isNoFree = isNoFree > 0 and isNoFree or 0
    if isFree > 0 then
        gCtr:setSelectedIndex(0)
        self.txt_reTimeDec:setText(Desc.PushMapQuickOnhook_reTimeFreeDec)
        self.times:setText(isFree)
    elseif isNoFree > 0 then
        gCtr:setSelectedIndex(1)
        self.txt_reTimeDec:setText(Desc.PushMapQuickOnhook_reTimeNoFreeDec)
        self.times:setText(isNoFree)
        local conf = DynamicConfigData.t_chapterSpeed
        local times = math.min(self.QuickOnhookData.payTimes + 1, #conf)
        local config = conf[times]
        local _cost = {type = CodeType.MONEY, code = 2, amount = config.diamonds}
        if self.agglutinationBind then
            self.agglutinationBind:setData(_cost)
            self.agglutinationBind:setCostCtrl(2)
        end
    else
        gCtr:setSelectedIndex(2)
        self.times:setText(isNoFree)
    end
end

--添加红点
function PushMapOnhookRewardView:_addRed()
    RedManager.register("V_PUSHMAPMOFANGRED", self.Btn_free:getChild("img_red"))
end

function PushMapOnhookRewardView:_exit()
    if self.calltimer then
        TimeLib.clearCountDown(self.calltimer)
    end
    if self.calltimer2 then
        TimeLib.clearCountDown(self.calltimer2)
    end
    if self.schaduleId then
        Scheduler.unschedule(self.schaduleId)
    end
end

return PushMapOnhookRewardView
