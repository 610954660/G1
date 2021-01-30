-- added by wyz 
-- 精灵系统主页

local ElvesSystemBaseView,Super= class("ElvesSystemBaseView",MutiWindow)

function ElvesSystemBaseView:ctor()
    self._packName = "ElvesSystem"
    self._compName = "ElvesSystemBaseView"
    self._tabBarName    = "list_page"
    self._showParticle  = true

    self.list_page = false
    self.elvesInfo = false  -- 主界面信息，
    self.btn_total  = false  -- 总览按钮
    self.btn_assembly = false   -- 装配按钮
    self.btn_arrowLeft = false -- 左切换按钮
    self.btn_arrowRight = false -- 右切换按钮    
    self.list_elves     = false -- 精灵列表
    self.txt_elvesNum   = false -- 精灵个数
    self.list_elvesPage = false -- 精灵页签列表
    self.btn_help       = false
    self.btn_tips       = false
    self.elvesIndex     = 1     -- 精灵索引
    self.elvesPageIndex = 1     -- 精灵品质索引
    self.bannerIconLoader = false

    self.dragArea   = false
    self.lihuiDisplay = false
    self.playerIcon   = false
    self._dragMoveX = 0
    self._dragStartX = 0
    self._lastPosX = 0 --拖动时上一次的点，用来计算方向
    self._dir = 1
    self.curElvesNum = false
    self.allElvesNum = false
    self.elvesInfoData = false
    self.isFirst = false 
    self.helpTitle = false
    self.helpDec   = false
    self.summonBtnHelp = false
    self.btn_promote   = false  -- 提升按钮
    self.btn_skin = false   -- 皮肤
    self.txt_power =false
    self.Click      = false
    self.closeBtn  = false

	self.showMoneyTypeDefault = {
        {type = GameDef.ItemType.Normal, code = 10000066},
        {type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold}, 
        {type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond}
	}
	self.redArr = {
		"V_ELVES_ATTRIB",
		-- "V_ELVES_UPGRADE",
		"V_ELVES_UPSTAR",
        "V_ELVES_SUMMOM",
        "V_ELVES_BAG",
    }
    self:setMoneyType(self.showMoneyTypeDefault)
end

-- 待机动画
function ElvesSystemBaseView:playStand()
    -- 手臂待机动画
    local effect_changjing_stand = self.view:getChildAutoType("effect_changjing_stand")
    local x1 = effect_changjing_stand:getWidth() / 2;
    local y1 = effect_changjing_stand:getHeight() / 2;
    effect_changjing_stand:displayObject():removeAllChildren()
    SpineUtil.createSpineObj(effect_changjing_stand, cc.p(x1, y1), "stand", "Effect/UI", "jinglingzhaohuan_changjing", "jinglingzhaohuan_changjing", true);
end


function ElvesSystemBaseView:_initUI()
    self.list_page = self.view:getChildAutoType("list_page")
    self.elvesInfo = self.view:getChildAutoType("elvesInfo")
    self.btn_total = self.view:getChildAutoType("btn_total")
    self.btn_assembly   = self.elvesInfo:getChildAutoType("btn_assembly")
    self.btn_arrowLeft  = self.elvesInfo:getChildAutoType("btn_arrowLeft")
    self.btn_arrowRight = self.elvesInfo:getChildAutoType("btn_arrowRight")
    self.list_elves     = self.elvesInfo:getChildAutoType("list_elves")
    self.txt_elvesNum   = self.elvesInfo:getChildAutoType("txt_elvesNum")
    self.list_elvesPage = self.elvesInfo:getChildAutoType("list_elvesPage")
    self.playerIcon     = self.elvesInfo:getChildAutoType("lihuiDisplay")
    self.btn_promote    = self.view:getChildAutoType("btn_promote")
    self.txt_power      = self.elvesInfo:getChildAutoType("txt_power")
    self.btn_help       = self.view:getChildAutoType("frame"):getChildAutoType("btn_help")
    self.lihuiDisplay   = BindManager.bindLihuiDisplay(self.playerIcon)
    self.bannerIconLoader = self.elvesInfo:getChildAutoType("bannerIconLoader")
    -- self.lihuiDisplay.view:getChildAutoType("dragArea"):setTouchable(false)
    self.btn_skin       = self.view:getChildAutoType("btn_skin")
    self.elfModel       = self.elvesInfo:getChildAutoType("elfModel")
    self.Click          = self.view:getChildAutoType("Click")
    self.closeBtn          = self.view:getChildAutoType("closeBtn")
    self.closeBtn:addClickListener(function() 
        ViewManager.close("ElvesSystemBaseView") 
    end)
	self.btn_tips      = self.view:getChildAutoType("frame"):getChildAutoType("btn_tips")
	self.btn_tips:removeClickListener()
    self.btn_tips:addClickListener(function(...)
        self:showHelpPanel()
    end)

    self.btn_help:removeClickListener()
    self.btn_help:addClickListener(function(...)
        if self._preIndex ~= 2 then
            local info={}
            info['title']=Desc["help_StrTitle"..ModuleId.Elves_Attribute.id]
            info['desc']=Desc["help_StrDesc"..ModuleId.Elves_Attribute.id]
            ViewManager.open("GetPublicHelpView",info) 
        else
            ViewManager.open("ElvesSummonHelpView")
        end
    end)

    
    self.btn_promote:removeClickListener(11)
    self.btn_promote:addClickListener(function()
        ViewManager.open("ElvesPromoteView")
    end,11)
	
	local isFirstOpen = FileCacheManager.getStringForKey("ElvesHelpOpen"..(ModelManager.PlayerModel.userid or ""), "0", nil,true)
	if isFirstOpen == "0" then
		Scheduler.scheduleOnce(0.5, function()
			if tolua.isnull(self.view) then return end
			self:showHelpPanel()
			FileCacheManager.setStringForKey("ElvesHelpOpen"..(ModelManager.PlayerModel.userid or ""), "1", nil,true)
		end)
    end
    
    self:playStand()
end

function ElvesSystemBaseView:showHelpPanel()
	local btnPos = self.btn_tips:getPosition()
	RollTips.showPicHelp("UI/ElvesSystem/Elves_help.png", btnPos)
end

function ElvesSystemBaseView:onViewControllerChanged()
    Super.onViewControllerChanged(self)
    -- self.helpDec = ModuleId.Elves_Attribute.id + self._preIndex
    -- self.helpTitle = ModuleId.Elves_Attribute.id + self._preIndex
    self.elvesInfo:setVisible(self._preIndex < 2)
    self.btn_promote:setVisible(self._preIndex == 0)
    ModelManager.ElvesSystemModel.pageIndex = self._preIndex
    -- if self._preIndex == 5 then
    --     self:setBg("equipforgeBg.jpg")
    -- elseif self._preIndex ~= 3 then
    if (self._preIndex == 3) or (self._preIndex == 4)  then
        self:setBg("equipforgeBg.jpg")
    else
        self:setBg("elvesSummonBg2.jpg")
    end
    if self._preIndex ~= 3 then
        ViewManager.close("ItemTipsBagView")
    end

    if not self.isFirst then 
        self:refreshPanal()
        self:initTouchLihui()
        self.isFirst = true
    else
        self:switchViewEvent()
    end

    
    self:ElvesSystemBaseView_refreshPanal()
end



function ElvesSystemBaseView:initTouchLihui()
    self.dragArea = self.playerIcon:getChildAutoType("dragArea")
    self.playerIcon:setTouchable(true)
    
    self.dragArea:setDraggable(true)
    self.dragArea:addEventListener(FUIEventType.DragStart,function(context)
        self._dragMoveX = 0
        self._dragStartX = self.dragArea:getPosition().x
        self._lastPosX = 0
    end);

    self.dragArea:addEventListener(FUIEventType.DragMove,function(context)
        self._dragMoveX = self.dragArea:getPosition().x
        self._lastPosX = self._dragMoveX
    end);

    self.dragArea:addEventListener(FUIEventType.DragEnd,function(context)
        self._dir = self._dragStartX - self._lastPosX
        self._dragMoveX = 0 
        self.dragArea:setPosition(-276,-224)
        
        if self._dir >= 20 then  -- 右
            if self.elvesIndex < self.allElvesNum then 
                self.elvesIndex = self.elvesIndex + 1
            else
                return 
            end
        elseif self._dir <= -20 then  -- 左
            if self.elvesIndex > 1 then 
                self.elvesIndex = self.elvesIndex - 1
            else
                return 
            end
        end
        self.list_elves:setSelectedIndex(self.elvesIndex - 1)
        self.btn_arrowRight:setVisible(self.elvesIndex < self.allElvesNum)
        self.btn_arrowLeft:setVisible(self.elvesIndex > 1)
        self:switchViewEvent()
    end);
end

--改变骨骼显示的动画
function ElvesSystemBaseView:changeHeroShow(elvesId,fashionId)
	self.lihuiDisplay:setData(elvesId,nil,nil,fashionId)
end

-- 设置精灵模型
function ElvesSystemBaseView:setElfModel()
    local data = self.elvesInfoData[self.elvesIndex]
    self.txt_power:setText(StringUtil.transValue(data.power))
    if not data then return end
    local size = false
    local modelId = false
    local resource = false
    if data.skinId == 1 then    -- 使用默认皮肤
        -- modelId = data.model
        resource = data.resource
        size    = data.size
        if self.elfModel then
            self.elfModel:setScale(size,size)
        end
    else
        local skinInfo = ElvesSystemModel:getElvesSkinInfoById(data.elfId,data.skinId)
        -- modelId = skinInfo.model
        resource = skinInfo.resource
        size    = skinInfo.size
        if self.elfModel then
            self.elfModel:setScale(size,size)
        end
    end
    if self.elfModel then
        self.elfModel:displayObject():removeAllChildren()
    end
    local skeletonNode = SpineUtil.createModel(self.elfModel, {x = 0, y =0}, "stand", false,false,resource)

    if data.have == 1 then
        skeletonNode:setColor({r=255,g=255,b=255})
        -- skeletonNode:pause()
    else
        skeletonNode:setColor({r=100,g=100,b=100})
        -- skeletonNode:pause()
    end
end

-- 设置精灵图片
function ElvesSystemBaseView:setElfPic(elvesIndex)
    local data = self.elvesInfoData[elvesIndex]
    self.bannerIconLoader:setURL("Elf/"..data.elfId..".png")
end

function ElvesSystemBaseView:ElvesSystemBaseView_setPage(_,params)
    -- printTable(8848,"params")
    self:_setPage(params.page)
end

function ElvesSystemBaseView:refreshPanal()
    self.elvesIndex = ElvesSystemModel:getElvesIndex(self.elvesPageIndex,self.elvesIndex) or self.elvesIndex
    if self._args.elvesIndex then
        self.elvesIndex = self._args.elvesIndex
        self._args.elvesIndex = false
    end
    -- 属性总览按钮
    self.btn_total:removeClickListener(888)
    self.btn_total:addClickListener(function()
        ViewManager.open("ElvesAddattrView")
    end,888)

    -- 精灵方案按钮
    self.btn_assembly:removeClickListener(888)
    self.btn_assembly:addClickListener(function()
        ViewManager.open("ElvesPlanView")
    end,888)


    -- 精灵数量
    local allElvesCfg = DynamicConfigData.t_ElfMain
    self.allElvesNum = TableUtil.GetTableLen(allElvesCfg)
    self.curElvesNum = ModelManager.ElvesSystemModel:getHaveElvesNum()
    self.txt_elvesNum:setText(string.format(Desc.ElvesSystem_elvesList,self.curElvesNum,self.allElvesNum))

    -- 精灵页签列表
    if self._args.elvesPageIndex then
        self.elvesPageIndex = self._args.elvesPageIndex
        self._args.elvesPageIndex = false
    end
    self.list_elvesPage:setSelectedIndex(self.elvesPageIndex - 1)
    self.list_elvesPage:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local txt_quality = obj:getChildAutoType("txt_quality")
        txt_quality:setText(string.format(Desc["ElvesSystem_listPage"..(idx+1)]))
        local img_red = obj:getChildAutoType("img_red")
        if self._preIndex == 0 then
            img_red:setVisible(ElvesSystemModel:checkGradeRedByIndex(index))
        elseif self._preIndex == 1 then
            img_red:setVisible(ElvesSystemModel:checkStarRedById(index))
        else
            img_red:setVisible(false)
        end
    end)
    self.list_elvesPage:setNumItems(5)
    self.list_elvesPage:removeClickListener(888)
    self.list_elvesPage:addClickListener(function()
        local index = self.list_elvesPage:getSelectedIndex()
        local tipsData = ModelManager.ElvesSystemModel:getElvesInfoByType(index + 1)
        if TableUtil.GetTableLen(tipsData) == 0 then
            if not AgentConfiger.isAudit() then
                RollTips.show(Desc.ElvesSystem_moreRead)
            end
            self.list_elvesPage:setSelectedIndex(self.elvesPageIndex-1)
            return 
        end
        if self.elvesPageIndex == index + 1 then return end
        self.elvesPageIndex = index+1
        self.elvesInfoData = ModelManager.ElvesSystemModel:getElvesInfoByType(self.elvesPageIndex)
        self.list_elvesPage:setSelectedIndex(index)
        self.list_elves:setNumItems(TableUtil.GetTableLen(self.elvesInfoData))
        self.elvesIndex = 1
        self.allElvesNum = TableUtil.GetTableLen(self.elvesInfoData)
        self.btn_arrowRight:setVisible(self.elvesIndex < self.allElvesNum)
        self.btn_arrowLeft:setVisible(self.elvesIndex > 1)
        self.list_elves:setSelectedIndex(self.elvesIndex-1)
        self:switchViewEvent()
    end)

    -- 精灵列表
    self.elvesInfoData = ModelManager.ElvesSystemModel:getElvesInfoByType(self.elvesPageIndex)
    self.allElvesNum = TableUtil.GetTableLen(self.elvesInfoData)
    -- self.changeHeroShow(self.elvesInfoData[self.elvesIndex].elfId)
    -- self:setElfPic(self.elvesIndex)
    self:setElfModel()
    self.list_elves:setSelectedIndex(self.elvesIndex-1)
    self.list_elves:setItemRenderer(function(idx,obj)
        local data = self.elvesInfoData[idx+1]
        local iconLoader = obj:getChildAutoType("iconItem"):getChildAutoType("iconLoader")
        local url = ItemConfiger.getItemIconByCode(data.elfId)
        iconLoader:setURL(url)
        local iconBgCtrl = obj:getController("iconBgCtrl")
        local iconLoaderBg = obj:getChildAutoType("iconLoaderBg")
        iconBgCtrl:setSelectedIndex(data.color)
        local img_red = obj:getChildAutoType("img_red")
        if self._preIndex == 0 then
            img_red:setVisible(ElvesSystemModel:checkGradeRed(data.elfId))
        elseif self._preIndex == 1 then
            img_red:setVisible(ElvesSystemModel:checkStarRed(data.elfId))
        else
            img_red:setVisible(false)
        end


        if data.have > 0 then
            iconLoaderBg:setGrayed(false)
            iconLoader:setGrayed(false)
        else
            iconLoaderBg:setGrayed(true)
            iconLoader:setGrayed(true)
        end
    end)
    -- printTable(8848,"elvesInfo",elvesInfo)
    self.list_elves:setNumItems(TableUtil.GetTableLen(self.elvesInfoData))
    self.list_elves:removeClickListener(888)
    self.list_elves:addClickListener(function()
        local index = self.list_elves:getSelectedIndex()
        self.list_elves:setSelectedIndex(index)
        if self.elvesIndex == index + 1 then return end
        self.elvesIndex = index + 1
        self.btn_arrowRight:setVisible(self.elvesIndex < self.allElvesNum)
        self.btn_arrowLeft:setVisible(self.elvesIndex > 1)
        -- 精灵立绘
        -- self.changeHeroShow(data.elfId)
        self:switchViewEvent()
    end)
    self:switchViewEvent()
    self:switchRight()
    self:switchLeft()
end

-- 右切换按钮
function ElvesSystemBaseView:switchRight()
    self.btn_arrowRight:setVisible(self.elvesIndex < self.allElvesNum)
    self.btn_arrowRight:removeClickListener(888)
    self.btn_arrowRight:addClickListener(function()
       if self.elvesIndex < self.allElvesNum then 
           self.elvesIndex = self.elvesIndex + 1
       else
           return
       end
       self.btn_arrowLeft:setVisible(self.elvesIndex > 1)
       self.btn_arrowRight:setVisible(self.elvesIndex < self.allElvesNum)
       self.list_elves:setSelectedIndex(self.elvesIndex - 1)
       self:switchViewEvent()
    end,888)
end

--  左切换按钮
function ElvesSystemBaseView:switchLeft()
    self.btn_arrowLeft:setVisible(self.elvesIndex > 1)
    self.btn_arrowLeft:removeClickListener(888)
    self.btn_arrowLeft:addClickListener(function()
        if self.elvesIndex > 1 then 
            self.elvesIndex = self.elvesIndex - 1
        else
            return 
        end
        self.list_elves:setSelectedIndex(self.elvesIndex - 1)
        self.btn_arrowRight:setVisible(self.elvesIndex < self.allElvesNum)
        self.btn_arrowLeft:setVisible(self.elvesIndex > 1)
        self:switchViewEvent()
    end,888)
end

function ElvesSystemBaseView:ElvesSystemBaseView_refreshPanal()
    self:refreshPanal()
    local img_promoteRed = self.btn_promote:getChildAutoType("img_red")
    img_promoteRed:setVisible(ElvesSystemModel:checkPromoteRed())
end

function ElvesSystemBaseView:switchViewEvent()
   -- print(8848,">>>>>>>>>self._preIndex>>>>>>>",self._preIndex)
--    self:setElfPic(self.elvesIndex)
    self:setElfModel()
    if self._preIndex == 0 then
        Dispatcher.dispatchEvent(EventType.ElvesAttributeView_refreshPanal,{data=self.elvesInfoData[self.elvesIndex],elvesIndex = self.elvesIndex,elvesPageIndex=self.elvesPageIndex})
    -- elseif self._preIndex == 1 then
    --     Dispatcher.dispatchEvent(EventType.ElvesUpgradeView_refreshPanal,{data=self.elvesInfoData[self.elvesIndex],elvesIndex = self.elvesIndex})
    elseif self._preIndex == 1 then
        Dispatcher.dispatchEvent(EventType.ElvesUpstarView_refreshPanal,{data=self.elvesInfoData[self.elvesIndex],elvesIndex = self.elvesIndex,elvesPageIndex=self.elvesPageIndex})
    elseif self._preIndex == 2 then
        Dispatcher.dispatchEvent(EventType.ElvesSummonView_refreshPanal,{data=self.elvesInfoData[self.elvesIndex],elvesIndex = self.elvesIndex,elvesPageIndex=self.elvesPageIndex})
    elseif self._preIndex == 3 then
    elseif self._preIndex == 4 then
        Dispatcher.dispatchEvent(EventType.ElvesPlanView_refreshPanal)
    end
    
    self.btn_skin:removeClickListener(11)
    self.btn_skin:addClickListener(function()
        ViewManager.open("ElvesSkinView",{
            allData = self.elvesInfoData,
            data = self.elvesInfoData[self.elvesIndex],
            -- elfId = self.elvesInfoData[self.elvesIndex].elfId,
            -- skinId = self.elvesInfoData[self.elvesIndex].skinId,
            elvesIndex = self.elvesIndex
        })
    end,11)
end


function ElvesSystemBaseView:_exit()
	Scheduler.scheduleNextFrame(function()
		ViewManager.close("ItemTipsBagView")
	end)
end



return ElvesSystemBaseView
