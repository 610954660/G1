---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: ljj
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local MaterialCopyView, Super = class("MaterialCopyView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
function MaterialCopyView:ctor()
    self._packName = "MaterialCopy"
    self._compName = "MaterialCopyView"
    --GList
    self.listcopy = false
    --卡牌阶级图片显示
    self.listdiffBg = false
    self.txtcopynum = false
    self.curItem = false
    --self._waitBattle = true
    self.cur_type = 0 --当前选择的类型
    --GButton
    --GTextField

    --按钮上的红点数据
    -- self.redTypes = {
    --     {redType = "", moduleId = ModuleId.Copy_Aura.id},
    --     {redType = "", moduleId = ModuleId.Copy_Gold.id},
    --     {redType = "", moduleId = ModuleId.Copy_Equip.id},
    --     {redType = "", moduleId = ModuleId.Copy_Hero.id},
    --     {redType = "", moduleId = ModuleId.Copy_Screct.id},
    --     {redType = "", moduleId = ModuleId.Copy_Jewelry.id},
    --     {redType = "", moduleId = ModuleId.Copy_Rune.id}
    -- }
end

function MaterialCopyView:_initUI()
    local viewRoot = self.view
    self.listdiffBg = FGUIUtil.getChild(viewRoot, "list_diffBg", "GList")
    self.listcopy = FGUIUtil.getChild(viewRoot, "list_copy", "GList")
    self.txtcopynum = FGUIUtil.getChild(viewRoot, "txt_copynum", "GTextField")

    local btnHelp = self.view:getChildAutoType("btn_help")
    btnHelp:addClickListener(
        function()
            local info = {}
            info["title"] = Desc.help_StrTitle3
            info["desc"] = Desc.help_StrDesc3
            ViewManager.open("GetPublicHelpView", info)
        end
    )
    self:showCopyList()
end

function MaterialCopyView:showCopyList()
    local copyList = ModelManager.MaterialCopyModel:getMeterialCopyInfo()
    printTable(152, "23333333333", copyList)
    --local count= ModelManager.MaterialCopyModel:getMaterialMaxNum()
    local confs = {}
    for i = 1, #copyList, 1 do
        local copy = DynamicConfigData.t_copy
        local co = copy[copyList[i]]
        local tips1 = ModuleUtil.moduleOpen(co[1].moduleId,false)
        local tips2 = ModuleUtil.getModuleOpenTips(co[1].moduleId)
        if tips1==true and not tips2 then--前端开启了该功能
            table.insert(confs, copyList[i])
        end
    end
    self:setCopyList(confs, #confs)
end

function MaterialCopyView:setCopyList(copyList, count)
    self.listcopy:setItemRenderer(
        function(index, obj)
            --obj:removeClickListener()--池子里面原来的事件注销掉
            obj:addClickListener(
                function(context)
                    local copy = DynamicConfigData.t_copy
                    local copyCode = copyList[index + 1]
                    local co = copy[copyCode]
                    if ModuleUtil.moduleOpen(co[1].moduleId, true) then
                        self.cur_type = index
                        if ModelManager.PlayerModel.level < co[1].openCondt[1].value then
                            RollTips.show(co[1].openCondt[1].value .. Desc.MaterialCopyView_str88)
                            if self.curItem then
                                self.curItem:setSelected(true)
                            end
                            obj:setSelected(false)
                        else
                            self.curItem = obj
                            self:showCopyBg(co)
                        end
                    else
                        self.listcopy:setSelectedIndex(self.cur_type)
                    end
                end
            )
            local copyCode = copyList[index + 1]
            obj:setName("listcopy" .. copyCode)
            local copyData = DynamicConfigData.t_copy
            local copyInfo = copyData[copyCode]

            obj:setTitle(string.format("%s", copyInfo[1].copyName))
            if ModelManager.PlayerModel.level < copyInfo[1].openCondt[1].value then
                obj:setGrayed(true)
            else
                obj:setGrayed(false)
            end
            local hasRed = MaterialCopyModel:getAllCopyRed(copyCode)
            local imgred = obj:getChildAutoType("img_red")
            RedManager.register("V_COPY" .. copyCode, imgred, copyInfo[1].moduleId)
            -- --[[if ModelManager.PlayerModel.level>= copyInfo[1].openCondt[1].value and hasRed==true then
            -- 	--imgred:setVisible(true)
            -- else
            -- 	--imgred:setVisible(false)
            -- end--]]
            if copyInfo[1].moduleId == self._args.moduleId then
                self.curItem = obj
                obj:setSelected(true)
                self:showCopyBg(copyInfo)
            elseif self._args.moduleId == ModuleId.Copy.id then
                if index == 0 then
                    self.curItem = obj
                    obj:setSelected(true)
                    self:showCopyBg(copyInfo)
                else
                    obj:setSelected(false)
                end
            else
                obj:setSelected(false)
            end
        end
    )
    self.listcopy:setNumItems(count)
end

local function setClickListenerFor(view, listener)
    view:removeClickListener(0)
    view:addClickListener(listener, 0)
end

function MaterialCopyView:updateOneKeyFinish(currentCopyCode)
    local config = DynamicConfigData.t_limit[currentCopyCode]
    --
    local remainingFreeTimes, _ = self:getRemainTumes(currentCopyCode)
    --
    local topUp = 0
    local copyList = ModelManager.MaterialCopyModel:getCopyInfo(currentCopyCode)
    if copyList and copyList.dailyInfo and copyList.dailyInfo.topup then
        topUp = copyList.dailyInfo.topup
    end
    local remainingTimes = config.topupMax + VipModel:getVipPrivilige(GameDef.VipPriviligeType.MaterialCount) - topUp
    --
    local difficulty
    local playFigth = PataModel:getPataFloor(2000) 
    if playFigth == nil then
        playFigth = 0
    end
    for _, copyConfig in ipairs(DynamicConfigData.t_copy[currentCopyCode]) do
        local limitFigth = 0
        for _, limit in pairs(copyConfig.openCondt) do
            if limit.type == 2 then
                limitFigth = limit.value
            elseif limit.type == 3 then
                limitFigth = limit.value
            end
        end
        if
            playFigth >= limitFigth and
                MaterialCopyModel:getDiffItemIsPass(copyConfig.gamePlayType, copyConfig.difficulty) == true
         then
            difficulty = copyConfig.difficulty
        else
            break
        end
    end

    --
    local btnOneKeyFinish = self.view:getChildAutoType("btnOneKeyFinish")
    if difficulty and remainingFreeTimes + remainingTimes > 0 then
        btnOneKeyFinish:setGrayed(false)
        btnOneKeyFinish:setTouchable(true)
        local price = config.topupConsume[1].amount * remainingTimes
        setClickListenerFor(
            btnOneKeyFinish,
            function()
                -- 本次一键扫荡包含2次免费扫荡和*次钻石扫荡，共消耗钻石***，是否确认执行一键扫荡。
                Alert.show(
                    {
                        text = string.format(Desc.materialCopy_str1, remainingFreeTimes, remainingTimes, price),
                        title = Desc.materialCopy_str2,
                        yesText = Desc.materialCopy_str3,
                        noText = Desc.materialCopy_str4,
                        type = "yes_no",
                        mask = true,
                        onYes = function()
                            RPCReq.Copy_OneKeyFinish(
                                {
                                    gamePlayType = currentCopyCode,
                                    difficulty = difficulty
                                },
                                function(response)
                                    --if response.ret then
                                    --	-- TODO
                                    --end
                                    if self.view and not tolua.isnull(self.view) then
                                        self:updateOneKeyFinish(currentCopyCode)
                                    end
                                end
                            )
                        end
                    }
                )
            end
        )
    else
        btnOneKeyFinish:setGrayed(true)
        btnOneKeyFinish:setTouchable(false)
    end
end

function MaterialCopyView:showCopyBg(data)
    --
    self:updateOneKeyFinish(data[1].gamePlayType)

    local titleBg = self.view:getChild("img_titleBg")
    titleBg:setURL(string.format("%s%s.jpg", "Icon/matariCopy/materiCopytitle_", data[1].gamePlayType))
    --local copyItem,pos= ModelManager.MaterialCopyModel:getCurCopyItem(data);
    local pos = ModelManager.MaterialCopyModel:getCurCopyItem1(data)
    self.listdiffBg:setItemRenderer(
        function(index, obj)
            obj:removeClickListener()
            --池子里面原来的事件注销掉
            local reward = data[index + 1].gameRes
            self:setCurReward(obj, reward)
            local img_diff = obj:getChild("img_diff")
            img_diff:setURL(
                string.format("%s%s.png", "Icon/matariCopy/", "diffdi_" .. math.ceil(data[index + 1].difficulty / 2))
            )
            local img_diff1 = obj:getChild("img_diff1")
            img_diff1:setURL(string.format("%s%s.png", "Icon/matariCopy/", "diff_" .. data[index + 1].difficulty))
            local playFigth = PataModel:getPataFloor(2000) --ModelManager.CardLibModel:getFightVal()
            local limitFigth = 0
            for k, limit in pairs(data[index + 1].openCondt) do
                if limit.type == 2 then
                    limitFigth = limit.value
                elseif limit.type == 3 then
                    limitFigth = limit.value
                end
            end

            local txtfight = obj:getChild("txt_fight")
            local isOpen = false
            local sdf =
                MaterialCopyModel:getDiffItemIsPass(data[index + 1].gamePlayType, data[index + 1].difficulty - 1)
            if
                playFigth > limitFigth and
                    MaterialCopyModel:getDiffItemIsPass(data[index + 1].gamePlayType, data[index + 1].difficulty - 1) ==
                        true
             then
                isOpen = true
            end
            printTable(21, "打印的舒适护士户数是", sdf)
            txtfight:setVisible(playFigth <= limitFigth)
           -- txtfight:setText(Desc.materialCopy_str5 .. limitFigth .. Desc.materialCopy_str6)
           txtfight:setText(string.format(Desc.materialCopy_str12,limitFigth))
            self:showBtnState(obj, data[index + 1], isOpen)
        end
    )
    self.listdiffBg:setVirtual()
    self:showCount(data[1].gamePlayType)
    self.listdiffBg:setNumItems(#data)
    printTable(5, "inyyyy", pos)
    self.listdiffBg:scrollToView(pos - 1, true, true)
    self.listdiffBg:refreshVirtualList()
end

function MaterialCopyView:showCount(copyType)
    local remainTimes, maxTimes = self:getRemainTumes(copyType)
    self.txtcopynum:setText(string.format("%s: [color=#66FF00]%s[/color]", Desc.materialCopy_str7, remainTimes))
    --[[if 2-copyList.dailyInfo.times<=0 then
		self.txtcopynum:setColor('#FF0000')
	else
		self.txtcopynum:setColor('#394847')
	end]]
end

--获取上限次数和剩余次数
function MaterialCopyView:getRemainTumes(copyType)
    local copyList = ModelManager.MaterialCopyModel:getCopyInfo(copyType)
    local copyNum = 0
    if copyList and copyList.dailyInfo and copyList.dailyInfo.times then
        copyNum = copyList.dailyInfo.times
    end
    local topUp = 0
    if copyList and copyList.dailyInfo and copyList.dailyInfo.topup then
        topUp = copyList.dailyInfo.topup
    end
    local copyData = DynamicConfigData.t_limit
    if not copyData then
        return
    end
    local maxTimes = copyData[copyType].maxTimes or 0
    local remainTimes = maxTimes + topUp - copyNum
    if remainTimes < 0 then
        remainTimes = 0
    end
    return remainTimes, maxTimes
end

function MaterialCopyView:showBtnState(obj, info, isOpen)
    local btnenter = obj:getChild("btn_enter")
    local btnsweep = obj:getChild("btn_sweep")
    local btn_sweepIcon = obj:getChild("btn_sweepIcon")
    local btngray = obj:getChild("btn_gray")
    local btnCtr = btngray:getController("button")
    btnCtr:setSelectedIndex(3)
    local gCtr = obj:getController("c1")
    local gCtr2 = obj:getController("c2") --扫荡
    local playFigth = PataModel:getPataFloor(2000) --ModelManager.CardLibModel:getFightVal()
    local limitFigth = 0
    for k, limit in pairs(info.openCondt) do
        if limit.type == 2 then
            limitFigth = limit.value
        elseif limit.type == 3 then
            limitFigth = limit.value
        end
    end
    local enterImg = btnenter:getChildAutoType("img_red")
    if not isOpen then
        enterImg:setVisible(false)
        gCtr:setSelectedIndex(1)
        btngray:removeClickListener(100)
        --池子里面原来的事件注销掉
        btngray:addClickListener(
            function(context)
                if MaterialCopyModel:getDiffItemIsPass(info.gamePlayType, info.difficulty - 1) == true then
                    if limitFigth >= playFigth then
                        ModuleUtil.openModule(ModuleId.Tower.id,true)
                        local tips1 = ModuleUtil.moduleOpen(ModuleId.Tower.id,false)
                        local tips2 = ModuleUtil.getModuleOpenTips(ModuleId.Tower.id)
                        if tips1==true and not tips2 then--前端开启了该功能
                            ViewManager.close("MaterialCopyView")
                        end
                    end
                else
                    RollTips.show(Desc.materialCopy_str9)
                end
            end,
            100
        )
    else
        local copyList = ModelManager.MaterialCopyModel:getCopyInfo(info.gamePlayType)
        printTable(4, "扫荡按钮显示", info, copyList)
        local isPass = false
        if copyList and copyList.diffPass ~= nil then
            isPass = copyList.diffPass.difficultyInfo[info.difficulty]
        end
        if isPass and isPass.passed == true then
            --printTable(5,'扫荡按钮显示')
            gCtr:setSelectedIndex(2)

            local remainTimes, maxTimes = self:getRemainTumes(info.gamePlayType)
            if remainTimes > 0 then
                gCtr2:setSelectedIndex(0)
            else
                gCtr2:setSelectedIndex(1)
            end
        else
            --printTable(5,'进入按钮显示')
            gCtr:setSelectedIndex(0)
        end
        local dayStr = DateUtil.getOppostieDays()
        local isShow =
            FileCacheManager.getBoolForKey(
            "MaterialCopyViewEnterBtn_isShow" .. info.gamePlayType .. info.difficulty .. dayStr,
            false
        )
        if not isShow then
            enterImg:setVisible(true)
        else
            enterImg:setVisible(false)
        end
        -- local goldUrl = ItemConfiger.getItemIconByCode(2,2)
        -- btn_sweepIcon:getChildAutoType("icon"):setURL(goldUrl)
        local sweepIconObj = BindManager.bindCostButton(btn_sweepIcon)
        sweepIconObj:setCostCtrl(1)
        local limitData = DynamicConfigData.t_limit
        local cost = {{type = 2, code = 2, amount = limitData[info.gamePlayType].topupConsume[1].amount}}
        sweepIconObj:setData(cost[1])
        btnenter:removeClickListener(100)
        --池子里面原来的事件注销掉
        btnsweep:removeClickListener(100)
        --池子里面原来的事件注销掉
        btn_sweepIcon:removeClickListener(100)
        --池子里面原来的事件注销掉
        btnenter:addClickListener(
            function(context)
                --SoundManager.playSound(1,false)
                if isOpen then
                    local dayStr = DateUtil.getOppostieDays()
                    FileCacheManager.setBoolForKey(
                        "MaterialCopyViewEnterBtn_isShow" .. info.gamePlayType .. info.difficulty .. dayStr,
                        true
                    )
                    enterImg:setVisible(false)
                    MaterialCopyModel:materCopyRed()
                    print(5, "进入>>>>33", info)
                    local function battleHandler(eventName)
                        if eventName == "begin" then
                            ModelManager.MaterialCopyModel:enterMeteriCopy(info.gamePlayType, info.difficulty)
                        elseif eventName == "end" then
                            ModelManager.MaterialCopyModel:fightCopyEnd()
                        -- if ModelManager.MaterialCopyModel.__curCopyIsWin==false then
                        -- 	ViewManager.open("MateriCopyEndLayer")
                        -- end
                        end
                    end
                    local copyConfig = DynamicConfigData.t_copy[info.gamePlayType]
                    local fightId = copyConfig[info.difficulty].fightId
                    Dispatcher.dispatchEvent(
                        EventType.battle_requestFunc,
                        battleHandler,
                        {fightID = fightId, configType = GameDef.BattleArrayType.Copy}
                    )
                else
                   -- RollTips.show(Desc.materialCopy_str8)
                   ModuleUtil.openModule(ModuleId.Tower.id,true)
                   local tips1 = ModuleUtil.moduleOpen(ModuleId.Tower.id,false)
                   local tips2 = ModuleUtil.getModuleOpenTips(ModuleId.Tower.id)
                   if tips1==true and not tips2 then--前端开启了该功能
                    ViewManager.close("MaterialCopyView")
                   end
                end
            end,
            100
        )
        btnsweep:addClickListener(
            function(context)
                --SoundManager.playSound(1,false)
                printTable(5, "点击扫荡>>>>>>>", info.gamePlayType)
                local remainTimes, maxTimes = self:getRemainTumes(info.gamePlayType)
                if remainTimes > 0 then
                    ModelManager.MaterialCopyModel:sweepCopy(info.gamePlayType, info.difficulty, 1)
                else
                    self:showBuyView(info.gamePlayType, info.difficulty)
                end
            end,
            100
        )
        btn_sweepIcon:addClickListener(
            function(context)
                printTable(5, "点击扫荡>>>>>>>", info.gamePlayType)
                self:showBuyView(info.gamePlayType, info.difficulty)
            end,
            100
        )
    end
end

function MaterialCopyView:showBuyView(copyType, difficulty)
    local remainTimes, maxTimes = self:getRemainTumes(copyType)
    local copyData = DynamicConfigData.t_limit
    local topUp = 0
    local copyList = ModelManager.MaterialCopyModel:getCopyInfo(copyType)
    if copyList and copyList.dailyInfo and copyList.dailyInfo.topup then
        topUp = copyList.dailyInfo.topup
    end
    if
        remainTimes == 0 and
            (topUp < copyData[copyType].topupMax + VipModel:getVipPrivilige(GameDef.VipPriviligeType.MaterialCount))
     then
        local info = {}
        info.text = string.format(Desc.materialCopy_str10, copyData[copyType].topupConsume[1].amount)
        info.title = Desc.materialCopy_str11
        info.yesText = Desc.materialCopy_str3
        info.noText = Desc.materialCopy_str4
        info.okText = "okText"
        info.noClose = "yes"
        info.type = "yes_no"
        info.mask = true
        info.onClose = function()
            print(5, "noClose")
        end
        info.onYes = function()
            print(5, "onYes")
            local isEnough =
                PlayerModel:checkCostEnough(
                {type = 2, code = 2, amount = copyData[copyType].topupConsume[1].amount},
                false
            )
            if isEnough then
                ModelManager.MaterialCopyModel:spendForTopup(copyType, 1)
                ModelManager.MaterialCopyModel:sweepCopy(copyType, difficulty, 1)
            else
                RollTips.show(Desc.MaterialCopyView_str89)
            end
        end
        info.onNo = function()
            print(5, "onNo")
        end
        Alert.show(info)
    elseif
        remainTimes == 0 and
            topUp >= (copyData[copyType].topupMax + VipModel:getVipPrivilige(GameDef.VipPriviligeType.MaterialCount))
     then
        --RollTips.show("不能增加次数上限了")
        local addCountVip = 0
        local vip = math.max(VipModel.level, 1)
        if vip >= 1 and vip <= 5 then
            addCountVip = 6
            RollTips.show(string.format( Desc.MaterialCopyView_str90,addCountVip))
        elseif vip >= 6 and vip <= 7 then
            addCountVip = 8
            RollTips.show(string.format( Desc.MaterialCopyView_str90,addCountVip))
        elseif vip >= 8 and vip <= 9 then
            addCountVip = 10
            RollTips.show(string.format( Desc.MaterialCopyView_str90,addCountVip))
        else
            RollTips.show(Desc.MaterialCopyView_str91)
        end
    end
end

function MaterialCopyView:upListRed(copyCode)
    MaterialCopyModel:materCopyRed()
    local obj = self.listcopy:getChildAutoType("listcopy" .. copyCode)
    if obj then
        local hasRed = MaterialCopyModel:getAllCopyRed(copyCode)
        local copyData = DynamicConfigData.t_copy
        local copyInfo = copyData[copyCode]
        local imgred = obj:getChildAutoType("img_red")
        if ModelManager.PlayerModel.level >= copyInfo[1].openCondt[1].value and hasRed == true then
            imgred:setVisible(true)
        else
            imgred:setVisible(false)
        end
    end
end

function MaterialCopyView:materialCopy_updata(_, data)
    printTable(5, "点击扫荡1")
    local copyInfo = DynamicConfigData.t_copy
    local diffInfo = copyInfo[data.type]
    self:upListRed(data.type)
    if diffInfo then
        self.listdiffBg:setNumItems(#diffInfo)
        self:showCount(data.type)
        self:updateOneKeyFinish(data.type)
    end
end

function MaterialCopyView:materialCopy_pass(_, copytype)
    printTable(5, "点击扫荡2")
    local copyInfo = DynamicConfigData.t_copy
    local diffInfo = copyInfo[copytype]
    self:upListRed(copytype)
    if diffInfo then
        self.listdiffBg:setNumItems(#diffInfo)
        self:showCount(copytype)
        self:updateOneKeyFinish(copytype)
    end
end

function MaterialCopyView:materialCopy_addCopyNum(_, copytype)
    printTable(5, "增加次数2")
    local copyInfo = DynamicConfigData.t_copy
    local diffInfo = copyInfo[copytype]
    self:upListRed(copytype)
    if diffInfo then
        self.listdiffBg:setNumItems(#diffInfo)
        self:showCount(copytype)
        self:updateOneKeyFinish(copytype)
    end
end

function MaterialCopyView:materialCopy_resetDay(_, copytype)
    printTable(5, "跨天重置2")
    local copyInfo = DynamicConfigData.t_copy
    local diffInfo = copyInfo[copytype]
    self:upListRed(copytype)
    if diffInfo then
        self.listdiffBg:setNumItems(#diffInfo)
        self:showCount(copytype)
        self:updateOneKeyFinish(copytype)
    end
end

--设置副本奖励
function MaterialCopyView:setCurReward(obj, curReward)
    --printTable(5,">>>>>>yfyfyfyf00",curReward)
    local listreward = obj:getChild("list_reward")
    listreward:setItemRenderer(
        function(index, obj)
            --obj:removeClickListener()--池子里面原来的事件注销掉
            --local num= obj:getChild('txt_num')
            --local icon= obj:getChild('iconLoader')
            --printTable(5,'<<<><><>',curReward,curReward[index+1],curReward[index+1].code)
            --local url = ItemConfiger:getItemIconByCode(curReward[index+1].code)
            local itemcell = BindManager.bindItemCell(obj)
            local award = curReward[index + 1]
            itemcell:setData(award.code, award.amount, award.type)
            --icon:setURL(url);
            --num:setText(curReward[index+1].amount..'');
        end
    )
    listreward:setNumItems(#curReward)
end

function MaterialCopyView:_enter()
end

return MaterialCopyView
