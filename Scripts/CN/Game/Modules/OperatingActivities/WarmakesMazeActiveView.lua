--Name : WarmakesMazeActiveView.lua
--Author : generated by FairyGUI
--Date : 2020-5-29
--Desc : 临界战令系统

local WarmakesMazeActiveView, Super = class("WarmakesMazeActiveView", Window)
function WarmakesMazeActiveView:ctor()
    self._packName = "OperatingActivities"
    self._compName = "WarmakesActiveView"
    self.viewIndexTag = GameDef.ActivityType.MazeWarOrder
    self.calltimer = false
    self.img_title = false
    self.btn_zhanling1 = false
    self.btn_zhanling2 = false
    self.starInfo = {}
    self.indexTag = 2
    self.isLeft = 0
    self.isFirst = true
    self.index = 0
end

function WarmakesMazeActiveView:_initVM()
    local vmRoot = self
    local viewNode = self.view
    ---Do not modify following code--------
    --{vmFields}:OperatingActivities.WarmakesMazeActiveView

    --{vmFieldsEnd}:OperatingActivities.WarmakesMazeActiveView
    --Do not modify above code-------------
end

function WarmakesMazeActiveView:setActType(actType)
    self.viewIndexTag = actType
    self.img_title:setURL(PathConfiger.getWarmakesActiveTitle(self.viewIndexTag))
    self.btn_zhanling1:getChildAutoType("btn_icon"):setURL(PathConfiger.getWarmakesActiveFrame(self.viewIndexTag, 1))
    self.btn_zhanling1:getChildAutoType("btn_touxiang"):setURL(PathConfiger.getWarmakesActiveIcon(self.viewIndexTag, 1))
    self.btn_zhanling2:getChildAutoType("btn_icon"):setURL(PathConfiger.getWarmakesActiveFrame(self.viewIndexTag, 2))
    self.btn_zhanling2:getChildAutoType("btn_touxiang"):setURL(PathConfiger.getWarmakesActiveIcon(self.viewIndexTag, 2))
    self:showRewardList()
    self:showActiveTime()
    self:showTextLv()
    self:showZhanlingBtn()
    self:scorllItem()
    self:showscorllItem()
end

function WarmakesMazeActiveView:_initUI()
    self:_initVM()
    local viewNode = self.view
    self.txt_level = viewNode:getChildAutoType("$txt_level")
    self.txt_countdown = viewNode:getChildAutoType("$txt_countdown")
    self.txt_desc = viewNode:getChildAutoType("$txt_desc")
    self.btn_taskenter = viewNode:getChildAutoType("$btn_taskenter")
    self.list_reward = viewNode:getChildAutoType("$list_reward")
    self.bar_exp = viewNode:getChildAutoType("$bar_exp")
    self.btn_buy = viewNode:getChildAutoType("$btn_buy")
    self.com_scorll = viewNode:getChildAutoType("$com_scorll")
    self.btn_help = viewNode:getChildAutoType("$btn_help")
    self.img_title = viewNode:getChildAutoType("img_title")
    self.btn_zhanling1 = viewNode:getChildAutoType("$btn_zhanling1")
    self.btn_zhanling2 = viewNode:getChildAutoType("$btn_zhanling2")
    self.txt_name = viewNode:getChildAutoType("txt_name")
    self.txt_taskDesc = viewNode:getChildAutoType("txt_taskDesc")
end

function WarmakesMazeActiveView:scorllItem()
    local configInfo = DynamicConfigData.t_BpJlActiveUp
    local type = OperatingActivitiesModel:getWarmakesElfActiveRealType(self.viewIndexTag)
    local configreward = configInfo[type]
    if not configreward then
        return
    end
    -- self.list_reward:setDraggable(true)
    self.list_reward:removeEventListener(FUIEventType.Scroll, 100)
    self.list_reward:addEventListener(
        FUIEventType.Scroll,
        function(context)
            local itemPos = self.list_reward:getChildAt(0):getWidth()
            local x = self.list_reward:getScrollPane():getPosX()
            if x < (itemPos * 4) then
                self.indexTag = 2
                self:showscorllItem()
            elseif x >= (itemPos * 4) and x < itemPos * 9 then
                self.indexTag = 3
                self:showscorllItem()
            elseif x >= itemPos * 9 then
                self.indexTag = 3 + math.floor(((x - (itemPos * 4)) / (itemPos * 5)))
                if self.indexTag >= #configreward / 5 then
                    self.indexTag = #configreward / 5
                end
                self:showscorllItem()
            end
            printTable(150, "得到数据jjjjjjj", x, x / itemPos, x - (itemPos * 9), self.indexTag)
        end,
        100
    )
end
--local  midX = self.heroList:getScrollPane():getPosX() + self.heroList:getViewWidth() / 2;
--  printTable(30,"context111202",x, w,midX)
function WarmakesMazeActiveView:showscorllItem()
    if self.isFirst then
        self.indexTag = self.index / 5
        if self.indexTag <= 6 and self.indexTag >= 2 then
            self.indexTag = math.floor(self.indexTag)
        elseif self.indexTag < 2 then
            self.indexTag = 2
        end
        self.isFirst = false
    end
    printTable(8848, "得到数据jjjjjjj111111", self.indexTag)
    local configInfo = DynamicConfigData.t_BpJlActiveUp
    local type = OperatingActivitiesModel:getWarmakesElfActiveRealType(self.viewIndexTag)
    local configreward = configInfo[type]
    if not configreward then
        return
    end
    local obj = self.com_scorll
    local c3 = obj:getController("c3")
    local c4 = obj:getController("c4")
    c3:setSelectedIndex(1)
    c4:setSelectedIndex(1)
    local rewardItem = configreward[self.indexTag * 5]
    local reward = rewardItem.reward
    local payReward = rewardItem.payReward
    local limitLv = rewardItem.level
    local putonglingquLv = OperatingActivitiesModel.WarmakesElfActiveInfo[self.viewIndexTag].commonRewardLv or 0
    local teshulingquLv = OperatingActivitiesModel.WarmakesElfActiveInfo[self.viewIndexTag].seniorRewardLv or 0
    local txt_lv = obj:getChildAutoType("txt_lv")
    txt_lv:setText("Lv." .. limitLv)
    local img_red1 = obj:getChildAutoType("img_red1")
    local img_red2 = obj:getChildAutoType("img_red2")
    local img_zhezhao1 = obj:getChildAutoType("img_zhezhao1")
    local img_zhezhao2 = obj:getChildAutoType("img_zhezhao2")
    local putongstate = self:getRewardState(putonglingquLv, limitLv)
    local tesustate = self:getRewardState(teshulingquLv, limitLv)
    if putongstate == 1 then
        img_red1:setVisible(true)
    else
        img_red1:setVisible(false)
    end
    if putongstate == 3 then --不可领取
        img_zhezhao1:setVisible(false)
    else
        img_zhezhao1:setVisible(false)
    end
    if OperatingActivitiesModel.WarmakesElfActiveInfo[self.viewIndexTag].isSenior == false then
        img_zhezhao2:setVisible(false)
    else
        if tesustate == 3 then
            img_zhezhao2:setVisible(false)
        else
            img_zhezhao2:setVisible(false)
        end
    end
    if tesustate == 1 and OperatingActivitiesModel.WarmakesElfActiveInfo[self.viewIndexTag].isSenior == true then
        img_red2:setVisible(true)
    else
        img_red2:setVisible(false)
    end
    local list_putong = obj:getChildAutoType("list_putong")
    local list_tesu = obj:getChildAutoType("list_tesu")
    list_putong:setItemRenderer(
        function(rewardindex, rewardObj)
            local itemcell = BindManager.bindItemCell(rewardObj)
            local award = reward[rewardindex + 1]
            itemcell:setData(award.code, award.amount, award.type)
            if putongstate == 2 then --已领取
                itemcell:setIsHook(true)
            else
                itemcell:setIsHook(false)
            end
        end
    )
    list_putong:setNumItems(#reward)
    list_tesu:setItemRenderer(
        function(tesuindex, tesuObj)
            local tesuitemcell = BindManager.bindItemCell(tesuObj)
            local award = payReward[tesuindex + 1]
            tesuitemcell:setData(award.code, award.amount, award.type)
            if tesustate == 2 then --已领取
                tesuitemcell:setIsHook(true)
            else
                tesuitemcell:setIsHook(false)
            end
        end
    )
    list_tesu:setNumItems(#payReward)
    local gCtr1 = obj:getController("c1")
    local gCtr2 = obj:getController("c2")
    gCtr1:setSelectedIndex(0)
    gCtr2:setSelectedIndex(0)
end

function WarmakesMazeActiveView:showTextLv()
    local curLv, curexp, nextExp = OperatingActivitiesModel:getWarmakesElfActiveLvAndExp(self.viewIndexTag)
    self.txt_level:setText(curLv)
    local str = Desc.activity_txt19 .. curexp .. "/" .. nextExp
    self.txt_desc:setText(str)
    self.bar_exp:setMin(0)
    self.bar_exp:setMax(nextExp)
    self.bar_exp:setValue(curexp)
end

function WarmakesMazeActiveView:showActiveTime()
    local actData = ModelManager.ActivityModel:getActityByType(self.viewIndexTag)
    -- printTable(31,"活动倒计时》》》》》》》》》》》》》》",actData)
    if not actData then
        return
    end
    local id = OperatingActivitiesModel.WarmakesElfActiveInfo[self.viewIndexTag].id or 1
    local starTime = actData.realStartMs / 1000
    local curSerevrTime = ServerTimeModel:getServerTime()
    local lastTime = (id * 30 * 24 * 60 * 60) - (curSerevrTime - starTime)
    if lastTime <= 60 * 60 * 2 then
        printTable(32, "活动倒计时》》》》》》》》》》》》》》111")
        self.btn_buy:setVisible(false)
    end
    if lastTime == -1 then
        self.txt_countdown:setText(Desc.activity_txt5)
    else
        if lastTime > 0 then
            self.txt_countdown:setText(TimeLib.GetTimeFormatDay(lastTime, 2))
            local function onCountDown(time)
                if time <= 60 * 60 * 2 then
                    printTable(32, "活动倒计时》》》》》》》》》》》》》》222")
                    self.btn_buy:setVisible(false)
                end
                self.txt_countdown:setText(TimeLib.GetTimeFormatDay(time, 2))
            end
            local function onEnd(...)
                self.txt_countdown:setText(TimeLib.GetTimeFormatDay(0, 2))
            end
            if self.calltimer then
                TimeLib.clearCountDown(self.calltimer)
            end
            self.calltimer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
        else
            self.txt_countdown:setText(TimeLib.GetTimeFormatDay(0, 2))
        end
    end
end

function WarmakesMazeActiveView:showRewardList()
    local configInfo = DynamicConfigData.t_BpJlActiveUp
    local type = OperatingActivitiesModel:getWarmakesElfActiveRealType(self.viewIndexTag)
    local configreward = configInfo[type]
    if not configreward then
        return
    end
    self.list_reward:setVirtual()
    self.list_reward:setItemRenderer(
        function(index, obj)
            print(8848, ">>>>>>>>>>>>index+1>>>", index + 1)
            self.index = index + 1
            local rewardItem = configreward[index + 1]
            local reward = rewardItem.reward
            local payReward = rewardItem.payReward
            local limitLv = rewardItem.level
            local putonglingquLv = OperatingActivitiesModel.WarmakesElfActiveInfo[self.viewIndexTag].commonRewardLv or 0
            local teshulingquLv = OperatingActivitiesModel.WarmakesElfActiveInfo[self.viewIndexTag].seniorRewardLv or 0
            local txt_lv = obj:getChildAutoType("txt_lv")
            txt_lv:setText("Lv." .. limitLv)
            local img_red1 = obj:getChildAutoType("img_red1")
            local img_red2 = obj:getChildAutoType("img_red2")
            local img_zhezhao1 = obj:getChildAutoType("img_zhezhao1")
            local img_zhezhao2 = obj:getChildAutoType("img_zhezhao2")
            local putongstate = self:getRewardState(putonglingquLv, limitLv)
            local tesustate = self:getRewardState(teshulingquLv, limitLv)
            if putongstate == 1 then
                img_red1:setVisible(true)
            else
                img_red1:setVisible(false)
            end
            if putongstate == 3 then --不可领取
                img_zhezhao1:setVisible(true)
            else
                img_zhezhao1:setVisible(false)
            end
            if OperatingActivitiesModel.WarmakesElfActiveInfo[self.viewIndexTag].isSenior == false then
                img_zhezhao2:setVisible(true)
            else
                if tesustate == 3 then
                    img_zhezhao2:setVisible(true)
                else
                    img_zhezhao2:setVisible(false)
                end
            end
            if tesustate == 1 and OperatingActivitiesModel.WarmakesElfActiveInfo[self.viewIndexTag].isSenior == true then
                img_red2:setVisible(true)
            else
                img_red2:setVisible(false)
            end
            local list_putong = obj:getChildAutoType("list_putong")
            local list_tesu = obj:getChildAutoType("list_tesu")
            list_putong:setItemRenderer(
                function(rewardindex, rewardObj)
                    local itemcell = BindManager.bindItemCell(rewardObj)
                    local award = reward[rewardindex + 1]
                    itemcell:setData(award.code, award.amount, award.type)
                    if putongstate == 2 then --已领取
                        itemcell:setIsHook(true)
                    else
                        itemcell:setIsHook(false)
                    end
                end
            )
            list_putong:setNumItems(#reward)
            list_tesu:setItemRenderer(
                function(tesuindex, tesuObj)
                    local tesuitemcell = BindManager.bindItemCell(tesuObj)
                    local award = payReward[tesuindex + 1]
                    tesuitemcell:setData(award.code, award.amount, award.type)
                    if tesustate == 2 then --已领取
                        tesuitemcell:setIsHook(true)
                    else
                        tesuitemcell:setIsHook(false)
                    end
                end
            )
            list_tesu:setNumItems(#payReward)
            local gCtr1 = obj:getController("c1")
            local gCtr2 = obj:getController("c2")
            if putongstate == 1 then
                gCtr1:setSelectedIndex(1)
            else
                gCtr1:setSelectedIndex(0)
            end
            if tesustate == 1 and OperatingActivitiesModel.WarmakesElfActiveInfo[self.viewIndexTag].isSenior == true then
                gCtr2:setSelectedIndex(1)
            else
                gCtr2:setSelectedIndex(0)
            end

            local btn_get1 = obj:getChildAutoType("btn_get1")
            local btn_get2 = obj:getChildAutoType("btn_get2")
            btn_get1:removeClickListener(100)
            btn_get1:addClickListener(
                function(...)
                    OperatingActivitiesModel:ewWarOrder_GetReward(self.viewIndexTag)
                end,
                100
            )
            btn_get2:removeClickListener(100)
            btn_get2:addClickListener(
                function(...)
                    OperatingActivitiesModel:ewWarOrder_GetReward(self.viewIndexTag)
                end,
                100
            )
            local btn_touch1 = obj:getChildAutoType("btn_touch1")
            local btn_touch2 = obj:getChildAutoType("btn_touch2")
            btn_touch1:removeClickListener(100)
            btn_touch1:addClickListener(
                function(...)
                    if putongstate == 1 then --可领取
                        OperatingActivitiesModel:ewWarOrder_GetReward(self.viewIndexTag)
                    elseif putongstate == 2 then --已领取
                        RollTips.show(Desc.activity_txt9)
                    else
                        RollTips.show(Desc.activity_txt20)
                    end
                end,
                100
            )

            btn_touch2:removeClickListener(100)
            btn_touch2:addClickListener(
                function(...)
                    if tesustate == 1 then --可领取
                        OperatingActivitiesModel:ewWarOrder_GetReward(self.viewIndexTag)
                    elseif tesustate == 2 then --已领取
                        RollTips.show(Desc.activity_txt9)
                    else
                        RollTips.show(Desc.activity_txt20)
                    end
                end,
                100
            )
        end
    )
    self.list_reward:setNumItems(#configreward)
    local scorllIndex = self:getScrollIndex()
    print(8848, ">>>>>>>>>>>>>>>>>>>>scorllIndex>>>>>>>>>", scorllIndex)
    self.list_reward:scrollToView(scorllIndex, false, false)
    local isSenior = OperatingActivitiesModel.WarmakesElfActiveInfo[self.viewIndexTag].isSenior
    if isSenior == nil then
        isSenior = false
    end
    printTable(32, "活动倒计时》》》》》》》》》》》》》》333", isSenior)
    self.btn_buy:setVisible(not isSenior)
end

function WarmakesMazeActiveView:showZhanlingBtn()
    for i = 1, 2, 1 do
        local btnkey = "$btn_zhanling" .. i
        local btnObj = self.view:getChildAutoType(btnkey)
        local c1 = btnObj:getController("c1")
        local isSenior = OperatingActivitiesModel.WarmakesElfActiveInfo[self.viewIndexTag].isSenior
        if i == 2 then
            if isSenior == true then
                c1:setSelectedIndex(0)
            else
                c1:setSelectedIndex(1)
            end
        else
            c1:setSelectedIndex(0)
        end
    end
end

function WarmakesMazeActiveView:getRewardState(lingquLv, limitLv)
    local curLv, curexp, nextExp = OperatingActivitiesModel:getWarmakesElfActiveLvAndExp(self.viewIndexTag)
    printTable(31, "普通", limitLv, lingquLv, curLv)
    local state = 0
    if limitLv > lingquLv and curLv >= limitLv and curLv > lingquLv then --可领取
        state = 1
    else
        if limitLv <= lingquLv then --已领取
            state = 2
        elseif curLv < limitLv then --不可领取
            state = 3
        end
    end
    return state
end

function WarmakesMazeActiveView:getScrollIndex()
    local configInfo = DynamicConfigData.t_BpJlActiveUp
    local type = OperatingActivitiesModel:getWarmakesElfActiveRealType(self.viewIndexTag)
    local configreward = configInfo[type]
    if not configreward then
        return
    end

    local scorllIndex = 0
    for i = 1, #configreward do
        local rewardItem = configreward[i]
        local limitLv = rewardItem.level
        local putonglingquLv = OperatingActivitiesModel.WarmakesElfActiveInfo[self.viewIndexTag].commonRewardLv or 0
        local putongstate = self:getRewardState(putonglingquLv, limitLv)
        if putongstate == 2 then
            scorllIndex = i - 1
        else
            break
        end
    end
    return scorllIndex
end

function WarmakesMazeActiveView:_initEvent()
    local actData = ModelManager.ActivityModel:getActityByType(self.viewIndexTag)
    if not actData then
       return 
    end
    local openModelId = actData.showContent.moduleOpen or 77
    self.txt_name:setText(Desc["WarmakesActiveViewNameStr_"..openModelId])
    self.txt_taskDesc:setText(Desc["WarmakesActiveViewDesc_"..openModelId])
    self.btn_help:addClickListener(
        function(...)
            local info = {}
            info["title"] = Desc["help_StrTitle" .. openModelId]
            info["desc"] = Desc["help_StrDesc" .. openModelId]
            ViewManager.open("GetPublicHelpView", info)
        end
    )
    self.btn_buy:addClickListener(
        function(...)
            ViewManager.open("WarmakesElfPayInfoView", {actType = self.viewIndexTag})
        end,
        100
    )

    self.btn_taskenter:addClickListener(
        function(...)
            ModuleUtil.openModule(ModuleId.Maze.id,true)  
        end,
        100
    )
end

function WarmakesMazeActiveView:activity_update()
    self:showActiveTime()
    self:showTextLv()
    self:showRewardList()
    self:scorllItem()
    self:showscorllItem()
end

--事件初始化
function WarmakesMazeActiveView:activity_WarmakesElfActiveupdate(...)
    self:showTextLv()
    local configInfo = DynamicConfigData.t_BpJlActiveUp
    local type = OperatingActivitiesModel:getWarmakesElfActiveRealType(self.viewIndexTag)
    local configreward = configInfo[type]
    if not configreward then
        return
    end
    self.list_reward:setNumItems(#configreward)
    local isSenior = OperatingActivitiesModel.WarmakesElfActiveInfo[self.viewIndexTag].isSenior
    if isSenior == nil then
        isSenior = false
    end
    if isSenior then
        ViewManager.close("WarmakesElfPayInfoView")
    end
    printTable(32, "活动倒计时》》》》》》》》》》》》》》444", isSenior)
    self.btn_buy:setVisible(not isSenior)
    self:showZhanlingBtn()
    self:showscorllItem()
end

function WarmakesMazeActiveView:_exit(...)
    if self.calltimer then
        TimeLib.clearCountDown(self.calltimer)
    end
end

return WarmakesMazeActiveView
