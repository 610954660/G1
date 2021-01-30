--关卡
local DelegateConfiger = require "Game.ConfigReaders.DelegateConfiger"
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local ItemCell = require "Game.UI.Global.ItemCell"
local PushMapCheckPointView, Super = class("PushMapCheckPointView", Window)
function PushMapCheckPointView:ctor(...)
    self._packName = "PushMap"
    self._compName = "PushMapCheckPointView"
    self._rootDepth = LayerDepth.Window
    --self._waitBattle = true
    self.curPoint = 1
    self.Btn_chapter = false
    self.list_guanka = false
    self.Btn_reward = false
    self.btn_onhookBox = false
    self.btn_left = false
    self.btn_right = false
    self.btn_ChapterReward = false
    self.txt_chatparDesc = false
    self.txt_city = false
    self.txt_chatperId = false
    self.txt_chatperId1 = false
    self.txt_chatperId2 = false
    self.curChapter = false
    self.btn_task = false
    self.btn_targetReward = false
    self.btn_help = false
    self.btn_entrustTask = false
    self.animationList = false
    self.animationSaiJingbi = false
    self._updateTimeId = false
    self._updateTimeId1 = false
    self._updateTimeId2 = false
    self.dutyAnima = false
    self.guochangyun = false
    self.bossAnima = {}
    self.GoodsItemAnima = {}
    self.VIPAnima = {}
    self.CurrentNeedAnima = {} 
    self.CurrentBossNeedAnima = {} 
    self.nextDianjiAnima = false
    self.isSpanChapter = false
	
	self._showParticle=true
	self._action="xuehua_guangqia"
	
    --是否跨越章节城市
    self.isSpancity = false
    --是否城市
end

-------------------常用------------------------
--UI初始化
function PushMapCheckPointView:_initUI(...)
    self.btn_help = self.view:getChild("btn_help")
    self.Btn_chapter = self.view:getChild("Btn_chapter")
    self.list_guanka = self.view:getChild("list_guanka")
    self.Btn_reward = self.view:getChild("Btn_reward")
    self.btn_onhookBox = self.view:getChild("btn_onhookBox")
    self.btn_left = self.view:getChild("btn_left")
    self.btn_right = self.view:getChild("btn_right")
    self.btn_bag = self.view:getChild("btn_bag")
    self.btn_tanyuan = self.view:getChild("btn_tanyuan")
    self.btn_ChapterReward = self.view:getChild("btn_ChapterReward")
    self.btn_task = self.view:getChild("btn_task")
    self.btn_targetReward = self.view:getChild("btn_targetReward")
    self.btn_entrustTask = self.view:getChild("btn_entrustTask")
    self.txt_chatparDesc = self.view:getChild("txt_chatparDesc")
    self.txt_city = self.view:getChild("txt_city")
    self.txt_chatperId = self.view:getChild("txt_chatperId")
    self.txt_chatperId1 = self.view:getChild("txt_chatperId1")
    self.txt_chatperId2 = self.view:getChild("txt_chatperId2")
    self.img_animation = self.view:getChild("img_animation")
    self.group_view = self.view:getChild("group_view")
    self.PostionContr = self.view:getController("c2")
    self.img_mofangred = self.view:getChild("img_mofangred")
    self.com_nextguanka = self.view:getChild("com_nextguanka")
    self.txt_mofangtime = self.view:getChild("txt_mofangtime")
    self.com_onhooktishi = self.view:getChild("com_onhooktishi")
    self.com_firstChong = self.view:getChild("com_firstChong") --首充按钮
    self.btn_jumpEnter = self.view:getChild("btn_jumpEnter") --跳过布阵
    self.btn_quickThreeStar = self.view:getChild("btn_quickThreeStar") --前往3星
    self.duty = self.view:getChild("com_duty")
	self.btn_powerPlant = self.view:getChild("btn_powerPlant")
    --self.list_guanka:setSize(display.width,display.height)
    --self.list_guanka:setPosition(-(display.width - self.view:getWidth())/2, 65)
    -- self.img_bg:setURL("Bg/pusMapPointbg.jpg")
    PushMapModel:loginsetjumpEnterState()
    --  self:setBg("pusMapPointbg.jpg")
    -- if self._args and self._args.hasAni == true then
        self:showYunAnim()
    -- else
    --     self.group_view:setVisible(true)
    -- end
    PushMapModel:setShowCohesionView(false)
    --不显示章节横条动画
    local cityId = PushMapModel.pushMaponHookInfo.chapterCity
    local chapterId = PushMapModel.pushMaponHookInfo.chapterPoint
    if not cityId then
        cityId = 1
    end
    if not chapterId then
        chapterId = 1
    end
    printTable(12, "............asdfwe", self._args, cityId, chapterId)
    if self._args.cityId and self._args.chapterId then
        cityId = self._args.cityId
        chapterId = self._args.chapterId
    else
        local info = {cityId = cityId, chapterId = chapterId}
        self._args = info
    end
    PushMapModel:getOldBattleData(cityId)
    local chaptersInfo = DynamicConfigData.t_chaptersPoint[cityId][chapterId]
    if chaptersInfo == nil then
        return
    end
    self.curChapter = chapterId
    PushMapModel:setChapterRewardViewParameter(cityId, chapterId)
    self.btn_jumpEnter:setSelected(not PushMapModel.jumpEnterState)
    PushMapModel:getHangUpState()
    PushMapModel:showPushmapmofangText(self.txt_mofangtime, 1)
    self:showEntrustTaskBtn()
    --委托任务
    self:showFirstChongzhi()
    --首充按钮
    self:updateDutyShow()
    --职级
    self:jixingBtnDesc()
    self:tongguanBtnDesc()
    self:upChapterRewardRed()
    self:showCheckPointView(chaptersInfo, 1)
    self:showBtnChange()
    self:showBoxAnimation()
    self:shownextGuankaComp()
    --GuideModel:checkGuideActivate({{name="yuanhang",id=ModuleId.Delegate.id}})
end

function PushMapCheckPointView:showEntrustTaskBtn()
    local tips = ModuleUtil.moduleOpen(ModuleId.Delegate.id, false)
    if tips == true then --前端开启了该功能
        self.PostionContr:setSelectedIndex(0)
        self.btn_entrustTask:setVisible(true)
    else
        self.PostionContr:setSelectedIndex(1)
        self.btn_entrustTask:setVisible(false)
    end
end

function PushMapCheckPointView:shownextGuankaComp()
    local City, chapter, curLevel = PushMapModel:getCurCityAndrChapterAndLevel()
    local state = false
    if not self._args or not self._args.cityId or not self.curChapter then
        return
    end
    if self._args.cityId < City or self.curChapter < chapter then
        state = true
    end
    printTable(32, "最大的商颠颠地阿杜你22222", City, chapter, curLevel, self._args.cityId, self.curChapter)
    local ci = self.com_nextguanka:getController("c1")
    local img_ani = self.com_nextguanka:getChildAutoType("img_ani")
    local txt_guankaid = self.com_nextguanka:getChildAutoType("txt_guankaid")
    if state == true then
        ci:setSelectedIndex(1)
        txt_guankaid:setText(string.format("%s-%s-%s", City, chapter, curLevel))
    else
        ci:setSelectedIndex(0)
        if not self.nextDianjiAnima then
            self.nextDianjiAnima = PushMapModel:getNextBtnAnim(img_ani)
        end
    end

    self.com_nextguanka:removeClickListener(100)
    self.com_nextguanka:addClickListener(
        function(...)
            if state == true then --最新关卡
                -- local itemType= PushMapModel:getPointType(City,chapter,curLevel);
                -- if itemType==3 then
                --     local function endfunc()
                --      PushMapModel:Battle(City,chapter,curLevel,itemType)
                --     end
                --     ViewManager.open("PushMapFilmView",{step =storyId[1],endfunc=endfunc})
                -- else
                --     ViewManager.open('PushMapInvestigationView',{cityId=City,chapterId=chapter,pointId=curLevel})
                -- end
                self._args.cityId = City
                self.curChapter = chapter
                self.curPoint = curLevel
                printTable(32, "最大的商颠颠地阿杜你", City, chapter, curLevel)
                if PushMapModel.jumpEnterState == true then --跳过
                    PushMapModel:PushMapQuickEnter(City, chapter, curLevel)
                else
                    ViewManager.open(
                        "PushMapInvestigationView",
                        {cityId = City, chapterId = chapter, pointId = curLevel}
                    )
                end
            else --下一关卡关卡
                -- local itemType= PushMapModel:getPointType(City,chapter,curLevel);
                -- if itemType==3 then
                --     local function endfunc()
                --      PushMapModel:Battle(City,chapter,curLevel,itemType)
                --     end
                --     ViewManager.open("PushMapFilmView",{step =storyId[1],endfunc=endfunc})
                -- else
                --     ViewManager.open('PushMapInvestigationView',{cityId=City,chapterId=chapter,pointId=curLevel})
                -- end
                local curMaxPoint = PushMapModel:getCurPointIndex(self._args.cityId, self.curChapter)
                -- PushMapModel:PushMapQuickEnter(self._args.cityId,self.curChapter,curMaxPoint)
                local City = self._args.cityId
                local chapter = self.curChapter
                local curLevel = curMaxPoint
                self.curPoint = curMaxPoint
                printTable(32, "最大的商颠颠地阿杜你11111", City, chapter, curLevel)
                if PushMapModel.jumpEnterState == true then --跳过
                    PushMapModel:PushMapQuickEnter(City, chapter, curLevel)
                else
                    ViewManager.open(
                        "PushMapInvestigationView",
                        {cityId = City, chapterId = chapter, pointId = curLevel}
                    )
                end
            end
        end,
        100
    )
end

function PushMapCheckPointView:jixingBtnDesc()
    local desc = PushMapModel:getChapterRewardbtnDesc(self._args.cityId, self.curChapter)
    local txt_desc = self.btn_ChapterReward:getChildAutoType("txt_desc")
    txt_desc:setText(desc)
end

function PushMapCheckPointView:tongguanBtnDesc()
    local desc = PushMapModel:gettongguanRewardbtnDesc()
    local txt_desc = self.btn_targetReward:getChildAutoType("txt_desc")
    txt_desc:setText(desc)
end

function PushMapCheckPointView:showYunAnim()
    self.group_view:setVisible(false)
    if not self.guochangyun then
        self.guochangyun =
            SpineUtil.createSpineObj(
            self.img_animation,
            {x = 0, y = 0},
            "animation",
            "Effect/UI",
            "Ef_guochangyun",
            "Ef_guochangyun",
            false
        )
    end
    self.guochangyun:setCompleteListener(
        function(name)
            printTable(21, "sdafdsaf111111111", name)
        end
    )
    self._updateTimeId =
        Scheduler.scheduleOnce(
        0.5,
        function()
            self._updateTimeId = false
            self.group_view:setVisible(true)
        end
    )
end

function PushMapCheckPointView:showchatperOpenAnimation() --章节开启动画
    ViewManager.open("PushMapChpterpassView",{ctr=0})
    Scheduler.scheduleOnce(
        1.2,
        function()
                ViewManager.close("PushMapChpterpassView")
                PushMapModel:setShowCohesionView(false)
        end
    )
end

function PushMapCheckPointView:showchatperPassAnimation() --章节通过动画
    ViewManager.open("PushMapChpterpassView",{ctr=1})
            if tolua.isnull(self.group_view) then
                return
            end
            if not tolua.isnull(self.group_view) then
                self.group_view:setVisible(false)
            end
            if not self.guochangyun then
                self.guochangyun =
                    SpineUtil.createSpineObj(
                    self.img_animation,
                    {x = 0, y = 0},
                    "animation",
                    "Effect/UI",
                    "Ef_guochangyun",
                    "Ef_guochangyun",
                    false
                )
            end
            self.guochangyun:setAnimation(0, "animation", false)
            self.guochangyun:setCompleteListener(
                function(name)
                end
            )
            self._updateTimeId1 =
                Scheduler.scheduleOnce(
                0.8,
                function()
                    ViewManager.close("PushMapChpterpassView")
                    self:showchatperOpenAnimation()
                    self._updateTimeId1 = false
                    self.group_view:setVisible(true)
                end
            )
   
end

function PushMapCheckPointView:showCityOpenAnimation() --城市开启动画
    self.group_view:setVisible(false)
    if not self.guochangyun then
        self.guochangyun =
            SpineUtil.createSpineObj(
            self.img_animation,
            {x = 0, y = 0},
            "animation",
            "Effect/UI",
            "Ef_guochangyun",
            "Ef_guochangyun",
            false
        )
    end
    self.guochangyun:setAnimation(0, "animation", false)
    self.guochangyun:setCompleteListener(
        function(name)
            printTable(21, "sdafdsaf111111111", name)
        end
    )
    self._updateTimeId2 =
        Scheduler.scheduleOnce(
        0.8,
        function()
            ViewManager.open("PushMapCityPassView",{cityId=self._args.cityId})
            Scheduler.scheduleOnce(
                1.2,
                function()
                    ViewManager.close("PushMapCityPassView")
                    PushMapModel:setShowCohesionView(false)
                end
            )
            self._updateTimeId2 = false
            self.group_view:setVisible(true)
        end
    )
end

function PushMapCheckPointView:showBoxAnimation()
    local curstate = PushMapModel:getCurBoxAnimationState()
    if tolua.isnull(self.btn_onhookBox) then
        return
    end
    if not self.animationList then
        self.animationList =
            SpineUtil.createSpineObj(
            self.btn_onhookBox:getChild("icon"),
            {x = 70, y = 50},
            "",
            "Effect/UI",
            "emaoxingdong",
            "emaoxingdong",
            true
        )
    end
    if curstate == 1 then
        self.com_onhooktishi:setVisible(false)
        -- self.img_mofangred:setPosition(652-152,548-30)
        self.animationList:setAnimation(0, "animation1", true)
    elseif curstate == 2 then
        self.com_onhooktishi:setVisible(false)
        --   self.img_mofangred:setPosition(652-152,548-30)
        self.animationList:setAnimation(0, "animation2", true)
    elseif curstate == 3 then
        -- self.img_mofangred:setPosition(652-152,538-30)
        self.animationList:setAnimation(0, "animation3", true)
        local serverInfo = PushMapModel.pushMaponHookInfo
        if not serverInfo then
            self.com_onhooktishi:setVisible(false)
            return
        end
        local curTime = serverInfo.hangUpMax
        if curTime >= 12 * 60 * 60 then
            self.com_onhooktishi:setVisible(true)
        else
            self.com_onhooktishi:setVisible(false)
        end
    end
    if not tolua.isnull(self.animationList) then
        if PushMapModel.jingbiRunState[2] == true then
            self.animationList:setAnimation(1, "jinbi_sa", false)
            PushMapModel.jingbiRunState[2] = false
        end
    end
    -- local str= PushMapModel:getCurBoxTransition()
    -- local transition =self.view:getTransition(str);
    -- transition:stop();
    -- transition:playReverse();
    -- local labelTime=  transition:getLabelTime('scale4')
    -- local labelTime1=  transition:getLabelTime('scale5')
    -- transition:play(1,0,labelTime,labelTime1,function ()
    -- 	--self:showEff()
    -- end)
    --    self:showEff(str);
end

-- function PushMapCheckPointView:showEff(str)
--     local transition =self.view:getTransition(str);
--     transition:stop();
--     transition:playReverse();
--     transition:play(function ()
-- 		self:showEff(str)
--     end)
-- end
function PushMapCheckPointView:pushMap_jingbisa2()
    self:showBoxAnimation()
end

function PushMapCheckPointView:showBtnChange()
    self.txt_chatperId:setText(self.curChapter .. "章")
    self.txt_chatperId1:setText(self.curChapter - 1)
    self.txt_chatperId2:setText(self.curChapter + 1)

    local max = DelegateConfiger.getMaxPointByLevel(tonumber(PlayerModel.level))
    local prog = self.btn_entrustTask:getChild("bar_plan")
    prog:setMax(max)
    self:money_change()
end

function PushMapCheckPointView:showCheckPointView(chaptersInfo, isScorll) --isScorll 0为判断战斗是否胜利在滚动 1为滚动
    local chaptNum = #chaptersInfo
    local result = 10
    if chaptNum > 10 then
        result = chaptNum
    end
    printTable(11, "KKKKKKKKKKK", self._args.cityId, self.curChapter)
    local cityInfo = DynamicConfigData.t_chapters[self._args.cityId]
    local cityName = cityInfo[self.curChapter].cyname
    local chapterName = cityInfo[self.curChapter].cname
    self.txt_city:setText(cityName)
    self.txt_chatparDesc:setText(chapterName)
    local curMaxPoint = PushMapModel:getCurPointIndex(self._args.cityId, self.curChapter)
    --当前关卡
    self.list_guanka:setVirtual()
    self.list_guanka:setItemRenderer(
        function(index, obj)
            obj:setName(index) --用于新手引导
            obj:removeClickListener(5)
            local cityInfo = DynamicConfigData.t_chapters[self._args.cityId]
            local bgArr = cityInfo[self.curChapter].cidmapid
            for i = 1, #bgArr, 1 do
                local bgId=bgArr[i]
                local iconBg = obj:getChildAutoType("img_bg" .. i)
                iconBg:setURL(string.format("Icon/pushMap/pushMapCheckPointBg_%s.jpg",bgId ))
            end
            for i = 1, result, 1 do
                local itemName = "zj" .. i
                local lineName = "img_line" .. i
                local chaptItem = obj:getChild(itemName)
                local lineItem = obj:getChild(lineName)
                if chaptItem then
                    if lineItem then
                        if i >= chaptNum then
                            lineItem:setVisible(false)
                        else
                            lineItem:setVisible(true)
                        end
                    end
                    if i > chaptNum then
                        chaptItem:setVisible(false)
                    else
                        local chaptInfo = chaptersInfo[i]
                        local cityId = chaptInfo.city
                        local chapterId = chaptInfo.cid
                        local title = chaptItem:getChild("title")
                        local txt_bossguanka = chaptItem:getChild("txt_bossguanka")
                      
                        local c1 = chaptItem:getController("c1")
                        local c2 = chaptItem:getController("c2")
                        local c3 = chaptItem:getController("c3")
                        local c6 = chaptItem:getController("c6")

                        local zhiyin = chaptItem:getChild("zhiyin")
                      
                        local passGuanka = PushMapModel:getCurPassedPointIndex(cityId, chapterId)
                        local isPass = false
                        if i <= passGuanka then
                            isPass = true
                        end
                        local isBossGuanka = PushMapModel:getBossId(cityId, chapterId, i)
                        if not isBossGuanka then --普通关卡
                            title:setText(chaptInfo.sidname)
                            if i < curMaxPoint then--已通过
                                c3:setSelectedIndex(2)
                                self:showCurrentNeedAnim(chaptItem, cityId, chapterId, i, false)
                            elseif i == curMaxPoint then--当前
                                if isPass==true then
                                    c3:setSelectedIndex(2)
                                    self:showCurrentNeedAnim(chaptItem, cityId, chapterId, i, false)
                                else
                                    c3:setSelectedIndex(1)
                                    self:showCurrentNeedAnim(chaptItem, cityId, chapterId, i, true)
                                end
                            else
                                self:showCurrentNeedAnim(chaptItem, cityId, chapterId, i, false)
                                c3:setSelectedIndex(0)--没通过
                            end
                        else--boss关卡
                            txt_bossguanka:setText(chaptInfo.sidname)
                            if i < curMaxPoint then--已通过
                                c3:setSelectedIndex(5)
                                self:showCurrentBossNeedAnim(chaptItem, cityId, chapterId, i, false)
                            elseif i == curMaxPoint then
                                if isPass==true then
                                    c3:setSelectedIndex(5)
                                    self:showCurrentBossNeedAnim(chaptItem, cityId, chapterId, i, false)
                                else
                                    c3:setSelectedIndex(4)
                                    self:showCurrentBossNeedAnim(chaptItem, cityId, chapterId, i, true)
                                end
                            else
                                self:showCurrentBossNeedAnim(chaptItem, cityId, chapterId, i, false)
                                c3:setSelectedIndex(3)
                            end
                        end
                        self:showBossHead(chaptItem, cityId, chapterId, i, isPass)
                        local hasTagetReward = PushMapModel:getTargetRewardGuankaReward(cityId, chapterId, i)
                        local vipid = PushMapModel:getVipId(cityId, chapterId, i)
                        if not isBossGuanka then
                            if hasTagetReward==false and vipid==false then
                                c6:setSelectedIndex(0)
                            elseif  hasTagetReward~=false and vipid==false then  
                                c6:setSelectedIndex(1)
                            elseif hasTagetReward==false and vipid~=false then  
                                c6:setSelectedIndex(2)
                            else
                                c6:setSelectedIndex(3)
                            end
                        else
                            if hasTagetReward==false and vipid==false then
                                c6:setSelectedIndex(4)
                            elseif hasTagetReward~=false and vipid==false then  
                                c6:setSelectedIndex(5)
                            elseif hasTagetReward==false and vipid~=false then  
                                c6:setSelectedIndex(6)
                            else
                                c6:setSelectedIndex(7)
                            end
                        end
                        self:showVIPItem(chaptItem, cityId, chapterId, i, isPass)
                        self:showGoodsItem(chaptItem, cityId, chapterId, i, isPass)
                        if lineItem then
                            lineItem:setMin(0)
                            lineItem:setMax(100)
                            if i <= passGuanka then
                                if PushMapModel.isBarShowed==true and  PushMapModel.city==cityId and  PushMapModel.point==chapterId and i==PushMapModel.level then
                                    lineItem:setValue(0) 
                                else
                                    lineItem:setValue(100)
                                end
                                --lineItem:tweenValue(100, 1)
                            else
                                lineItem:setValue(0)
                            end
                        end
                        if PushMapModel:getTargetRewardGuankaId(cityId, chapterId, i) == 9 and 8 == passGuanka then
                            zhiyin:setVisible(true)
                            local scale1 = cc.ScaleTo:create(0.4, 0.7, 0.7)
                            local scale2 = cc.ScaleTo:create(0.4, 1, 1)
                            zhiyin:displayObject():stopAllActions()
                            zhiyin:displayObject():runAction(
                                cc.RepeatForever:create(cc.Sequence:create(scale1, scale2))
                            )
                        elseif PushMapModel:getTargetRewardGuankaId(cityId, chapterId, i) == 10 and 9 == passGuanka then
                            zhiyin:setVisible(true)
                            local scale1 = cc.ScaleTo:create(0.4, 0.7, 0.7)
                            local scale2 = cc.ScaleTo:create(0.4, 1, 1)
                            zhiyin:displayObject():stopAllActions()
                            zhiyin:displayObject():runAction(
                                cc.RepeatForever:create(cc.Sequence:create(scale1, scale2))
                            )
                        else
                            zhiyin:displayObject():stopAllActions()
                            zhiyin:setVisible(false)
                        end
                        local itemType = PushMapModel:getPointType(cityId, chapterId, chaptInfo.sid)
                        if itemType == 3 then
                            c2:setSelectedIndex(1)
                        else
                            c2:setSelectedIndex(0)
                        end
                        if passGuanka < i then
                            c1:setSelectedIndex(0)
                        else
                            local itemStar = PushMapModel:getPointStar(cityId, chapterId, chaptInfo.sid)
                            c1:setSelectedIndex(itemStar + 1)
                        end
                        -- if i == curMaxPoint then
                        --     local scale1 = cc.ScaleTo:create(0.5, 0.8, 0.8)
                        --     local scale2 = cc.ScaleTo:create(0.5, 1.2, 1.2)
                        --     img_cur:displayObject():stopAllActions()
                        --     img_cur:displayObject():runAction(
                        --         cc.RepeatForever:create(cc.Sequence:create(scale1, scale2))
                        --     )
                        -- else
                        --     img_cur:displayObject():stopAllActions()
                        -- end
                        local touchguangka = chaptItem:getChildAutoType("Btn_touch")
                        touchguangka:removeClickListener(5)
                        touchguangka:addClickListener(
                            function(context)
                                if i <= curMaxPoint then
                                    self:touchItem(chaptersInfo, i)
                                else
                                    RollTips.show(Desc.pushmap_str1)
                                end
                            end,
                            5
                        )
                    end
                end
            end
        end
    )
    self.list_guanka:setItemProvider(
        function(index)
            if chaptNum <= 10 then
                return "ui://PushMap/com_CheckPoint10"
            elseif chaptNum == 12 then
                return "ui://PushMap/com_CheckPoint12"
            elseif chaptNum == 15 then
                return "ui://PushMap/com_CheckPoint15"
            elseif chaptNum == 20 then
                return "ui://PushMap/com_CheckPoint20"
            end
            return "ui://PushMap/com_CheckPoint10"
        end
    )
    self.list_guanka:setNumItems(1)
    -- if #self.chatPrivateList > 6 then
    --     self.list_guanka:scrollToView(#self.chatPrivateList - 1, true, true)
    --     self.list_guanka:refreshVirtualList()
    -- end
    self:scrollItem(isScorll)
end

function PushMapCheckPointView:pushMap_showBarAnim()
    local cityId = self._args.cityId
    local chapterId = self.curChapter
    if  PushMapModel.city==cityId and   PushMapModel.point==chapterId and  PushMapModel.modulefirstPass==false then
        local com=self.list_guanka:getChildAt(0)
        local lineName = "img_line" .. 	PushMapModel.level 	
        local lineItem = com:getChild(lineName)
        if lineItem then
            lineItem:setMin(0)
            lineItem:setMax(100)
            lineItem:setValue(0)
            lineItem:tweenValue(100, 3)
        end
        PushMapModel.isBarShowed=false
    end
end

function PushMapCheckPointView:showGoodsItem(item, cityId, chapterId, pointId, isPass)
    local rewardcom = item:getChild("list_reward")
    local rewardList = rewardcom:getChildAutoType("list_reward")
    if tolua.isnull(rewardList) then
        return
    end
    local hasTagetReward = PushMapModel:getTargetRewardGuankaReward(cityId, chapterId, pointId)
    if hasTagetReward == false then
    else
        local img_ani = rewardcom:getChildAutoType("img_ani")
        rewardList:setItemRenderer(
            function(idx2, obj2)
                local itemcell = BindManager.bindItemCell(obj2)
                itemcell:setData(hasTagetReward.code, hasTagetReward.amount, hasTagetReward.type)
            end
        )
        rewardList:setNumItems(1)
        -- if not self.GoodsItemAnima[cityId .. "_" .. chapterId .. "_" .. pointId] then
        --     self.GoodsItemAnima[cityId .. "_" .. chapterId .. "_" .. pointId] = PushMapModel:getItemAnim(img_ani)
        -- end
        -- if isPass == true then
        --     if self.GoodsItemAnima[cityId .. "_" .. chapterId .. "_" .. pointId] then
        --         SpineUtil.clearEffect(self.GoodsItemAnima[cityId .. "_" .. chapterId .. "_" .. pointId])
        --     end
        -- end
    end
end

function PushMapCheckPointView:showCurrentBossNeedAnim(item, cityId, chapterId, pointId, isShow)
    local img_curBossani = item:getChild("img_curBossani")
    if isShow then
        if not self.CurrentBossNeedAnima[cityId .. "_" .. chapterId .. "_" .. pointId] then
            self.CurrentBossNeedAnima[cityId .. "_" .. chapterId .. "_" .. pointId] = PushMapModel:getCurrentBossNeedAnim(img_curBossani)
        end
    else
        if self.CurrentBossNeedAnima[cityId .. "_" .. chapterId .. "_" .. pointId] then
            SpineUtil.clearEffect(self.CurrentBossNeedAnima[cityId .. "_" .. chapterId .. "_" .. pointId])
        end
    end
end

function PushMapCheckPointView:showCurrentNeedAnim(item, cityId, chapterId, pointId, isShow)
    local img_curani = item:getChild("img_curani")
    if isShow then
        if not self.CurrentNeedAnima[cityId .. "_" .. chapterId .. "_" .. pointId] then
            self.CurrentNeedAnima[cityId .. "_" .. chapterId .. "_" .. pointId] = PushMapModel:getCurrentNeedAnim(img_curani)
        end
    else
        if self.CurrentNeedAnima[cityId .. "_" .. chapterId .. "_" .. pointId] then
            SpineUtil.clearEffect(self.CurrentNeedAnima[cityId .. "_" .. chapterId .. "_" .. pointId])
        end
    end
end

function PushMapCheckPointView:showBossHead(item, cityId, chapterId, pointId, isPass)
    -- local c6 = item:getController("c6")
    local bossIcon = item:getChildAutoType("com_boss"):getChildAutoType("img_boss")
    local img_ani = item:getChildAutoType("img_bossHeadani")
    local bossid = PushMapModel:getBossId(cityId, chapterId, pointId)
    if bossid then
        img_ani:setVisible(true)
        bossIcon:setURL(PathConfiger.getHeroOfMonsterIcon(bossid))
     --   c6:setSelectedIndex(1)
        if not self.bossAnima[cityId .. "_" .. chapterId .. "_" .. pointId] then
            self.bossAnima[cityId .. "_" .. chapterId .. "_" .. pointId] = PushMapModel:getBossAnim(img_ani)
        end
        if isPass == true then
            if self.bossAnima[cityId .. "_" .. chapterId .. "_" .. pointId] then
                SpineUtil.clearEffect(self.bossAnima[cityId .. "_" .. chapterId .. "_" .. pointId])
                img_ani:setVisible(false)
            end
        end
    else
        img_ani:setVisible(false)
    end
end

function PushMapCheckPointView:showVIPItem(item, cityId, chapterId, pointId, isPass)
    local bossIcon = item:getChildAutoType("com_VIP")
    local img_ani = bossIcon:getChildAutoType("img_ani")
    local vipid = PushMapModel:getVipId(cityId, chapterId, pointId)
    if vipid then
        if not self.VIPAnima[cityId .. "_" .. chapterId .. "_" .. pointId] then
            self.VIPAnima[cityId .. "_" .. chapterId .. "_" .. pointId] = PushMapModel:getVIPAnim(img_ani)
        end
        if isPass == true then
            if self.VIPAnima[cityId .. "_" .. chapterId .. "_" .. pointId] then
                SpineUtil.clearEffect(self.VIPAnima[cityId .. "_" .. chapterId .. "_" .. pointId])
            end
        end
    else
    end
    bossIcon:removeClickListener(5)
    bossIcon:addClickListener(
        function(context)
            local _itemData = ItemsUtil.createItemData({data = {code = 5001, type = 3}})
            ViewManager.open("ItemTips", {winType = 0, codeType = CodeType.ITEM, id = 5001, data = _itemData})
        end,
        5
    )
end

function PushMapCheckPointView:touchItem(chaptersInfo, index)
    self.curPoint = index
    local chaptInfo = chaptersInfo[index]
    local cityId = chaptInfo.city
    local chapterId = chaptInfo.cid
    local pointId = chaptInfo.sid
    local storyId = chaptInfo.storyid
    local itemType = PushMapModel:getPointType(cityId, chapterId, pointId)
    if itemType == 3 then
        local function endfunc()
            PushMapModel:Battle(cityId, chapterId, pointId, itemType)
        end
        ViewManager.open("PushMapFilmView", {step = storyId[1], endfunc = endfunc})
    else
        ViewManager.open("PushMapInvestigationView", {cityId = cityId, chapterId = chapterId, pointId = pointId})
    end
end

function PushMapCheckPointView:showFirstChongzhi() --首充按钮
    local isShowCom = ActivityModel:hasActivity(GameDef.ActivityType.FirstCharge)
    -- printTable(32,"11111112222222222223",isShowCom)
    if not tolua.isnull(self.com_firstChong) then
        self.com_firstChong:setVisible(isShowCom)
    end
end

function PushMapCheckPointView:updateDutyShow(...)
    if not self.duty then
        return
    end
    if not DutyModel.dutyData then
        return
    end
	
	self.btn_powerPlant:setVisible(ModuleUtil.hasModuleOpen(ModuleId.PowerPlant.id))
	
	if ModuleUtil.hasModuleOpen(ModuleId.PowerPlant.id) then
		PushMapModel:powerPlanGetInfo(function (data)
				if tolua.isnull(self.view) then
					return
				end
				--self.myInfo=data.myInfo
				local nodeInfo=data.nodeInfo
				self.btn_powerPlant:setTitle("异能计划·阶段"..nodeInfo.nodeId)
				local bossMaps={}
				for k, v in pairs(nodeInfo.bossMap) do
					table.insert(bossMaps,v)
				end
				local totalPoint=0
				local maxSuccessPt=0
				for i = 1, 3 do
					local bossInfo=bossMaps[i]
					local point=bossInfo.point
					totalPoint=totalPoint+point
					local levelInfo=DynamicConfigData.t_TalentProjectGame[nodeInfo.nodeId][bossInfo.bossId][i]
					maxSuccessPt=maxSuccessPt+levelInfo.successPt
				end
				local dutyPro=self.btn_powerPlant:getChild("dutyPro")
				local dutyProVal=self.btn_powerPlant:getChild("dutyProVal")
				local itemCellObj = self.btn_powerPlant:getChildAutoType("itemCell")
				local itemcell = BindManager.bindItemCell(itemCellObj, true)
				itemcell:setIcon(UIPackageManager.getUIURL(self._packName,"planEnterIcon"),true)
				itemcell:setAmountStr("")
				
				dutyProVal:setText("")
				dutyPro:setMax(maxSuccessPt)
				dutyPro:setValue(totalPoint)
				dutyPro:setTitleType(0)
				
				printTable(5656,data,"hasModuleOpen")
		end)
	end
	
	self.btn_powerPlant:addClickListener(
		function(...)
			--ViewManager.open("PowerPlanView")
			ModuleUtil.openModule(ModuleId.PowerPlant, true)
		end,
	12)
	
	
    local flag = ModuleUtil.hasModuleOpen(51)
    if flag then
        self.duty:getController("showDutyCtrl"):setSelectedIndex(1)
        local dutyTitle = self.duty:getChildAutoType("title")
        local dutyProVal = self.duty:getChildAutoType("dutyProVal")
        local itemCellObj = self.duty:getChildAutoType("itemCell")
        local itemNum = self.duty:getChildAutoType("itemNum")
        local dutyPro = self.duty:getChildAutoType("dutyPro")
       -- local lightNode = self.duty:getChildAutoType("n63")
        local btn_duty = self.duty:getChildAutoType("btn_duty")
       -- local effectLoader = self.duty:getChildAutoType("effectLoader")
        -- if not self.dutyAnima then
        --     self.dutyAnima =
        --         SpineUtil.createSpineObj(
        --         effectLoader,
        --         vertex2(0, -5),
        --         "tongyongyuankuang_chong",
        --         "Spine/ui/duty",
        --         "efx_tongyongyuankuang",
        --         "efx_tongyongyuankuang",
        --         true
        --     )
        --     self.dutyAnima:setScale(0.75,0.75)
        -- end
        btn_duty:removeClickListener(11)
        btn_duty:addClickListener(
            function(...)
                ModuleUtil.openModule(ModuleId.Duty, false)
            end,
            11
        )
		
        local showItem, doneTask, taskCount, des
        local curDutyIndex = DutyModel:getCurDutyIndex()
        local allConfig = DutyModel:getAllDutyConfig()
        if curDutyIndex == #allConfig then --最后一级
            showItem, doneTask, taskCount, des = DutyModel:getLastMainUIShowNeed()
        else
            showItem, doneTask, taskCount, des = DutyModel:getMainUIShowNeed()
        end
        -- printTable(1,showItem,doneTask,taskCount,des)
        dutyTitle:setText(des)
        dutyProVal:setText(tostring(math.ceil(doneTask / taskCount * 100)) .. "%")
        --dutyPro:setFillAmount(doneTask / taskCount)
        dutyPro:getChild("title"):setVisible(false)
        dutyPro:setMax(taskCount)
        dutyPro:setValue(doneTask)
        local beginPosx = 96
        local maxPosx = 234
        -- if doneTask / taskCount > 0.15 then
        --     lightNode:setVisible(true)
        --     lightNode:setX(beginPosx + (maxPosx - beginPosx) * doneTask / taskCount)
        -- else
        --     lightNode:setVisible(false)
        -- end
        -- local itemcell = BindManager.bindItemCell(itemCellObj)
        -- local award = showItem[1]
        -- itemcell:setData(award.code, award.amount, award.type)
        local itemcell = BindManager.bindItemCell(itemCellObj, true)
        local itemData = ItemsUtil.createItemData({data = showItem[1]})
        itemcell:setAmountVisible(false)
        itemcell:setItemData(itemData)
        itemcell:setSplitCtrl(0)
        if showItem[1].amount > 1 then --小于1不要数量
            itemNum:setVisible(true)
            itemNum:setText(itemData:getItemAmount())
        else
            itemNum:setVisible(false)
        end
    else
        self.duty:getController("showDutyCtrl"):setSelectedIndex(0)
    end
end

--UI初始化
function PushMapCheckPointView:_initEvent(...)
    self.btn_help:removeClickListener()
    self.btn_help:addClickListener(
        function(...)
            local info = {}
            info["title"] = Desc.help_StrTitle1
            info["desc"] = Desc.help_StrDesc1
            ViewManager.open("GetPublicHelpView", info)
        end
    )
    self.Btn_chapter:addClickListener(
        function(...)
            local cityId = self._args.cityId
            ViewManager.open("PushMapChaptersView", {cityId = cityId})
            ViewManager.close("PushMapCheckPointView")
        end
    )

    self.btn_ChapterReward:addClickListener(
        function(...)
            local cityId, chapterId = PushMapModel:getchapterRewardViewParameter()
            ViewManager.open("PushMapChapterRewardView", {cityId, chapterId})
        end
    )

    self.btn_task:addClickListener(
        function(...)
            -- ViewManager.open("TaskView")
            ModuleUtil.openModule(ModuleId.Task.id, true)
        end
    )

    self.btn_targetReward:addClickListener(
        --目标奖励
        function(...)
            --ViewManager.open("PushMapTargetRewardView")
            ModuleUtil.openModule(ModuleId.PushMapTargetReward.id)
        end
    )

    self.btn_left:addClickListener(
        function(...)
            self.curChapter = self.curChapter - 1
            if self.curChapter <= 1 then
                self.curChapter = 1
            end
            local cityId = self._args.cityId
            local chapterId = self.curChapter
            local chaptersInfo = DynamicConfigData.t_chaptersPoint[cityId][chapterId]
            if not chaptersInfo then
                return
            end
            PushMapModel:setChapterRewardViewParameter(cityId, chapterId)
            self:showCheckPointView(chaptersInfo, 1)
            self:showBtnChange()
            self:upChapterRewardRed()
            self:jixingBtnDesc()
            self:shownextGuankaComp()
        end
    )

    self.btn_right:addClickListener(
        function(...)
            local cityId = self._args.cityId
            local maxChapter = PushMapModel:getCurChapterIndex(cityId)
            self.curChapter = self.curChapter + 1
            if self.curChapter > maxChapter then
                self.curChapter = maxChapter
                RollTips.show(Desc.pushmap_str2)
            end
            printTable(18, "sdafadsfsadfads", cityId, maxChapter, self.curChapter)
            local chapterId = self.curChapter
            local chaptersInfo = DynamicConfigData.t_chaptersPoint[cityId][chapterId]
            if not chaptersInfo then
                return
            end
            PushMapModel:setChapterRewardViewParameter(cityId, chapterId)
            self:showCheckPointView(chaptersInfo, 1)
            self:showBtnChange()
            self:upChapterRewardRed()
            self:jixingBtnDesc()
            self:shownextGuankaComp()
        end
    )
    --使用spine点击
    -- local function callBack(node)
    --     PushMapModel:getHangUpState()
    --     ViewManager.open('PushMapOnhookRewardView')
    -- end
    -- GlobalUtil.createLayerTouchEvent( self.animationList,callBack,false )
    self.btn_onhookBox:addClickListener(
        function(...)
            PushMapModel:getHangUpState()
            ViewManager.open("PushMapOnhookRewardView")
        end
    )
    self.btn_entrustTask:addClickListener(
        function()
           ModuleUtil.openModule(ModuleId.Delegate.id)
        end
    )

    self.btn_bag:addClickListener(
        function()
            ModuleUtil.openModule(ModuleId.Bag.id, true)
        end
    )

    self.btn_tanyuan:addClickListener(
        function()
            -- ViewManager.open("CardBagView")--打开卡牌库
            ModuleUtil.openModule(ModuleId.Hero.id, true)
        end
    )

    self.com_firstChong:addClickListener(
        function()
            ModuleUtil.openModule(ModuleId.FirstCharge.id, true)
            --打开首充
        end
    )

    self.btn_jumpEnter:addClickListener(
        function()
            PushMapModel:setjumpEnterState()
            --跳过布阵
        end
    )

    if not tolua.isnull(self.btn_quickThreeStar) then
        self.btn_quickThreeStar:addClickListener(
            function()
                --挑战未3星的关卡
                local City, chapter, curLevel = PushMapModel:getlessthanThreeStar()
                if City == 0 then
                    RollTips.show("你已三星通关")
                else
                    self._args.cityId = City
                    self.curChapter = chapter
                    self.curPoint = curLevel
                    self:shownextGuankaComp()
                    printTable(155, "最大的商颠颠地阿杜你", City, chapter, curLevel)
                    if PushMapModel.jumpEnterState == true then --跳过
                        PushMapModel:PushMapQuickEnter(City, chapter, curLevel)
                    else
                        ViewManager.open(
                            "PushMapInvestigationView",
                            {cityId = City, chapterId = chapter, pointId = curLevel}
                        )
                    end
                end
            end
        )
    end

    local effect = self.com_firstChong:getChildAutoType("effect")
    local animation = false
    if not animation then
        animation =
            SpineUtil.createSpineObj(
            effect,
            vertex2(effect:getWidth() / 2, effect:getHeight() / 2),
            "zhencha_vip",
            "Effect/UI",
            "efx_zhencha_2",
            "efx_zhencha",
            true
        )
    end
end

function PushMapCheckPointView:scrollItem(type)
    -- printTraceback()
    local curMaxPoint = PushMapModel:getCurPassedPointIndex(self._args.cityId, self.curChapter)
    --当前关卡
    printTable(21, "当前打印的书舒适111", curMaxPoint)
    if curMaxPoint == 0 then
        curMaxPoint = 1
    end
    local com = self.list_guanka:getChildAt(0)
    local itemName = "zj" .. curMaxPoint
    local chaptItem = com:getChild(itemName)
    -- local from= chaptItem:localToGlobal(Vector2.zero)
    --printTable(26,">>>>>>>>>",chaptItem,curMaxPoint,self.list_guanka:getScrollPane():getContentSize().width,chaptItem:getPosition().x-500)
    if type == 1 then
        if chaptItem then
            if chaptItem:getPosition().x - 500 < 500 then
                self.list_guanka:getScrollPane():scrollLeft()
            else
                self.list_guanka:getScrollPane():setPosX(0, true)
                self.list_guanka:getScrollPane():setPosX(chaptItem:getPosition().x - 500, true)
            end
        end
    else
        --     local function  listener()
        --     end
        --    -- Scheduler.scheduleNextFrame(listener)
        --     Scheduler.schedule(listener, 1, 1)
        -- printTable(21,"当前打印的书舒适",curMaxPoint,chaptItem:getPosition())
        if chaptItem then
            local roundId = PushMapModel.modulefirstPass
            printTable(29, "当前打印的书舒适111", curMaxPoint, roundId)
            if roundId == false or self.isSpanChapter == true or self.isSpancity == true then
                if chaptItem:getPosition().x - 500 < 500 then
                    self.list_guanka:getScrollPane():scrollLeft()
                else
                    self.list_guanka:getScrollPane():setPosX(0, true)
                    self.list_guanka:getScrollPane():setPosX(chaptItem:getPosition().x - 500, true)
                end
            end
        end
    end
end

function PushMapCheckPointView:pushMap_updatePointInfo(...)
    SpineUtil.clearEffect(self.CurrentBossNeedAnima)   
    SpineUtil.clearEffect(self.CurrentNeedAnima)  
    SpineUtil.clearEffect(self.bossAnima)
    SpineUtil.clearEffect(self.VIPAnima)
    SpineUtil.clearEffect(self.GoodsItemAnima)
    if not self._args or not self._args.cityId or not self.curChapter then
        return
    end
    local curMaxPoint = PushMapModel:getCurPassedPointIndex(self._args.cityId, self.curChapter)
    --当前关卡
    local cityId = self._args.cityId
    local chapterId = self.curChapter
    local chaptersInfo = DynamicConfigData.t_chaptersPoint[cityId][chapterId]
    printTable(32, "最大的商颠颠地阿杜你3333333", self._args.cityId, self.curChapter, curMaxPoint)
    if not chaptersInfo then
        return
    end
    self.curChapter = chapterId
    local allCityNum = #(DynamicConfigData.t_chapters)
    local allChapter = DynamicConfigData.t_chapters[cityId]
    local maxCityNum = #(DynamicConfigData.t_chapters)
    local MaxChapterNum = DynamicConfigData.t_chapters[maxCityNum]
    local maxPointNum = DynamicConfigData.t_chaptersPoint[maxCityNum][#MaxChapterNum]
    if self.curPoint == #maxPointNum and chapterId == #MaxChapterNum and maxCityNum == cityId then
        printTable(31, "刷新界面关卡>>>>>>>>>>>>>>>>>>22", self.curPoint, #maxPointNum, chapterId, #MaxChapterNum, maxCityNum)
    else
        if self.curPoint == #chaptersInfo and curMaxPoint >= #chaptersInfo then
            self.list_guanka:getScrollPane():scrollLeft()
            self.curChapter = chapterId + 1
            self.isSpanChapter = true
            --printTable(1,'刷新界面关卡>>>>>>>>>>>>>>>>>>12')
            if self.curChapter > #allChapter then
                self.isSpancity = true
                self.curChapter = 1
                cityId = cityId + 1
                if cityId >= allCityNum then
                    cityId = allCityNum
                end
                self._args.cityId = cityId
                self.curPoint = 1
            else
                self:scrollItem(0)
            end
        end
        printTable(31, "刷新界面关卡>>>>>>>>>>>>>>>>>>13", self.curPoint, #chaptersInfo, curMaxPoint)
        printTable(31, "刷新界面关卡>>>>>>>>>>>>>>>>>>115", self.isSpanChapter, self.isSpancity)
        chaptersInfo = DynamicConfigData.t_chaptersPoint[cityId][self.curChapter]
    end
    if not chaptersInfo then
        return
    end
    printTable(32, "最大的商颠颠地阿杜你4444", self._args.cityId, self.curChapter)
    PushMapModel:setChapterRewardViewParameter(cityId, self.curChapter)
    self:showCheckPointView(chaptersInfo, 0)
    self:showBtnChange()
    self:shownextGuankaComp()
end

--刷新章节奖励
function PushMapCheckPointView:pushMap_chapterRewardRecord(...)
    self:upChapterRewardRed()
end
function PushMapCheckPointView:pushMap_upChapterRewardRed(...)
    self:upChapterRewardRed()
end

function PushMapCheckPointView:upChapterRewardRed()
    local cityId = self._args.cityId
    if cityId == nil then
        cityId = 1
    end
    local chapterId = self.curChapter
    local mapConfig = DynamicConfigData.t_chapters[cityId]
    if not mapConfig then
        mapConfig = {}
    end
    local max = #(mapConfig)
    if tolua.isnull(self.btn_left) then
        return
    end
    local letfRed = self.btn_left:getChildAutoType("img_red")
    local rightRed = self.btn_right:getChildAutoType("img_red")
    if self.curChapter == 1 then
        self.btn_left:setVisible(false)
        self.txt_chatperId1:setVisible(false)
        letfRed:setVisible(false)
    else
        local letf = PushMapModel:getPushMapchapterRed(cityId, chapterId - 1)
        letfRed:setVisible(letf)
        self.btn_left:setVisible(true)
        self.txt_chatperId1:setVisible(true)
    end
    if self.curChapter == max then
        self.btn_right:setVisible(false)
        self.txt_chatperId2:setVisible(false)
        rightRed:setVisible(false)
    else
        local rigth = PushMapModel:getPushMapchapterRed(cityId, chapterId + 1)
        rightRed:setVisible(rigth)
        self.btn_right:setVisible(true)
        self.txt_chatperId2:setVisible(true)
    end

    local hasRed = PushMapModel:getPushMapchapterRed(cityId, chapterId)
    local imgred = self.btn_ChapterReward:getChildAutoType("img_red")
    imgred:setVisible(hasRed)
end

function PushMapCheckPointView:pushMap_figthendInfo(...)
    printTable(31, "战斗是大范德萨发士大夫撒打发士大夫")
    --printTable(151,"wwwwwwwwwwwwww",self.bossAnima)
    PushMapModel:showQuickOnhookReward(PushMapModel.city, PushMapModel.point, PushMapModel.level)
    if self.isSpanChapter == true and self.isSpancity == false then
        PushMapModel:setShowCohesionView(true)
        self.isSpanChapter = false
        self:showchatperPassAnimation()
    elseif self.isSpanChapter == true and self.isSpancity == true then
        self.isSpanChapter = false
        self.isSpancity = false
        self:showCityOpenAnimation()
        PushMapModel:setShowCohesionView(true)
    else
        if not tolua.isnull(self.group_view) then
            PushMapModel:setShowCohesionView(false)
            self.group_view:setVisible(true)
        end
    end
    self:jixingBtnDesc()
    self:tongguanBtnDesc()
    self:showFirstChongzhi()
    --首充
end

function PushMapCheckPointView:pushMap_updateInfo(_, data)
    self:showBoxAnimation()
    PushMapModel:showPushmapmofangText(self.txt_mofangtime, 1)
    --     for i = 0, 4, 1 do
    --         local key='t'..i
    --         local transitionkey =self.view:getTransition(key);
    --         transitionkey:stop();
    --         transitionkey:playReverse();
    --     end
    --     local str= PushMapModel:getCurBoxTransition()
    --     printTable(9,'刷新挂机宝箱表现',str)
    --     local transition =self.view:getTransition(str);
    --     transition:stop();
    --     transition:playReverse();
    --    self:showEff(str);
end

function PushMapCheckPointView:pushMap_upTargetRewardRed(...)
    self:tongguanBtnDesc()
end

function PushMapCheckPointView:pushMap_shownextGuankaComp(...)
    self:shownextGuankaComp()
end

function PushMapCheckPointView:player_levelUp(...)
    self:updateDutyShow()
    --职级
end

function PushMapCheckPointView:update_MainDutyShow(...)
    self:updateDutyShow()
    --职级
end

function PushMapCheckPointView:Activity_UpdateData(...)
    self:showFirstChongzhi()
    --首充
end

function PushMapCheckPointView:money_change()
    local have = ModelManager.PlayerModel:getMoneyByType(9)
    local max =DelegateConfiger.getMaxPointByLevel(tonumber(PlayerModel.level))
    if not tolua.isnull(self.btn_entrustTask) then
        self.btn_entrustTask:setTitle(have.."/"..max)
        local prog = self.btn_entrustTask:getChild("bar_plan")
        prog:getChild("title"):setVisible(false)
        prog:setValue(have)
        prog:setMax(max)
    end
end
--添加红点
function PushMapCheckPointView:_addRed()
    RedManager.register("M_DUTY", self.duty:getChildAutoType("img_red"))
    RedManager.register("V_DELEGATE", self.btn_entrustTask:getChild("img_red"))
    local img_red = self.btn_task:getChild("img_red")
    RedManager.register("M_BTN_TASK", img_red, ModuleId.PushMap.id)
    local img_herored = self.btn_tanyuan:getChild("img_red")
    RedManager.register("M_Card", img_herored, ModuleId.Hero.id)
    local img_bagred = self.btn_bag:getChild("img_red")
    RedManager.register("M_BTN_BAG", img_bagred, ModuleId.Bag.id)
    local img_targetRewarded = self.btn_targetReward:getChild("img_red")
    local red = RedManager.getTips("V_CHAPTERTARGETREWARDRED")
    RedManager.register("V_CHAPTERTARGETREWARDRED", img_targetRewarded, ModuleId.PushMap.id)
    RedManager.register("V_PUSHMAPMOFANGRED", self.img_mofangred)
    local img_firstChong = self.com_firstChong:getChild("img_red")
    RedManager.register("V_ACTIVITY_" .. GameDef.ActivityType.FirstCharge, img_firstChong)
    local img_chapterandcityRed = self.Btn_chapter:getChild("img_red")
    RedManager.register("V_CHAPTERREWARDRED", img_chapterandcityRed, ModuleId.PushMap.id)
end

--initEvent后执行
function PushMapCheckPointView:_enter(...)
end

--页面退出时执行
function PushMapCheckPointView:_exit(...)
    SpineUtil.clearEffect(self.CurrentBossNeedAnima)     
    SpineUtil.clearEffect(self.CurrentNeedAnima)   
    SpineUtil.clearEffect(self.animationList) --猫
    SpineUtil.clearEffect(self.animationSaiJingbi) --撒金币
    SpineUtil.clearEffect(self.nextDianjiAnima)
    SpineUtil.clearEffect(self.bossAnima)
    SpineUtil.clearEffect(self.VIPAnima)
    SpineUtil.clearEffect(self.GoodsItemAnima)
    SpineUtil.clearEffect(self.guochangyun)
    SpineUtil.clearEffect(self.dutyAnima)
    if PushMapModel.showPushmapmofangTime[1] then
        TimeLib.clearCountDown(PushMapModel.showPushmapmofangTime[1])
    end
    Scheduler.unschedule(self._updateTimeId)
    if self._updateTimeId1 then
        Scheduler.unschedule(self._updateTimeId1)
    end
    if self._updateTimeId2 then
        Scheduler.unschedule(self._updateTimeId2)
    end
    ViewManager.close("PushMapChpterpassView")
    ViewManager.close("PushMapCityPassView")
end

-------------------常用------------------------

return PushMapCheckPointView
