-- added by wyz
-- 精灵皮肤

local ElvesSkinView = class("ElvesSkinView",Window)

function ElvesSkinView:ctor()
    self._packName = "ElvesSystem"
    self._compName = "ElvesSkinView"
    
    self.txt_battleTitle = false    -- 战斗预览标题
    self.elfModel        = false    -- 精灵模型
    self.list_skin       = false    -- 皮肤列表
    self.list_attr       = false    -- 属性列表
    self.btn_travel      = false    -- 前往获取
    self.btn_use         = false    -- 使用按钮
    self.txt_skinDec     = false    -- 皮肤描述
    self.txt_skinName    = false    -- 皮肤名字
    self.elfId           = false    --- 精灵id
    self.flagFirstIn     = false    -- 标记是不是第一次进界面  第一次进默认选中第一个皮肤
    self.btn_set         = false    -- 设置皮肤
    self.skinEffectNode  = false    -- 技能预览
    self.skinData = {}
    self.btn_help       = false
    self.elvesIndex     = false
    self.data           = false
    self.txt_attrTitle  = false
    self.allData        = {}

    self.playIcon   = false
    self.dragArea   = false
    self._dragMoveX = 0
    self._dragStartX = 0
    self._lastPosX = 0 --拖动时上一次的点，用来计算方向
    self._dir = 1
    self.allElvesNum = 0
    self.seletedFahionIndex = 1 --选中皮肤列表id
    self.btn_arrowLeft = false
    self.btn_arrowRight = false
end

function ElvesSkinView:_initUI()
    self.txt_battleTitle = self.view:getChildAutoType("txt_battleTitle")
    self.elfModel        = self.view:getChildAutoType("elfModel")
    self.list_skin       = self.view:getChildAutoType("skinList/list_skin")
    self.list_attr       = self.view:getChildAutoType("list_attr")
    self.btn_travel      = self.view:getChildAutoType("btn_travel")
    self.btn_use         = self.view:getChildAutoType("btn_use")
    self.txt_skinDec     = self.view:getChildAutoType("txt_skinDec")
    self.txt_skinName    = self.view:getChildAutoType("txt_skinName")
    self.btn_set         = self.view:getChildAutoType("btn_set")
    self.skinEffectNode  = self.view:getChildAutoType("skinEffectNode")
    self.btn_help        = self.view:getChildAutoType("btn_help")
    self.playerIcon      = self.view:getChildAutoType("lihuiDisplay")
    self.btn_arrowLeft  = self.view:getChildAutoType("btn_arrowLeft")
    self.btn_arrowRight = self.view:getChildAutoType("btn_arrowRight")
    self.txt_attrTitle  = self.view:getChildAutoType("txt_attrTitle")
    self.txt_attrTitle:setText(Desc.ElvesSystem_str7)

    self:setBg("heroshareBg.jpg")
    self.btn_help:removeClickListener()
    self.btn_help:addClickListener(function(...)
        local info={}
        info['title']=Desc["help_StrTitleElvesSkin"]
        info['desc']=Desc["help_StrDescElvesSkin"]
        ViewManager.open("GetPublicHelpView",info) 
    end)

    self.elvesIndex      = self._args.elvesIndex
    self.allData         = self._args.allData
    self.elfId           = self.allData[self.elvesIndex].elfId
    self.allElvesNum     = TableUtil.GetTableLen(self.allData)
end

-- 右切换按钮
function ElvesSkinView:switchRight()
    self.btn_arrowRight:setVisible(self.elvesIndex < self.allElvesNum)
    self.btn_arrowRight:removeClickListener(888)
    self.btn_arrowRight:addClickListener(function()
       if self.elvesIndex < self.allElvesNum then 
           self.elvesIndex = self.elvesIndex + 1
       else
           return
       end
       self.elfId           = self.allData[self.elvesIndex].elfId
       self.btn_arrowLeft:setVisible(self.elvesIndex > 1)
       self.btn_arrowRight:setVisible(self.elvesIndex < self.allElvesNum)
       self:refreshPanal()
    end,888)
end

--  左切换按钮
function ElvesSkinView:switchLeft()
    self.btn_arrowLeft:setVisible(self.elvesIndex > 1)
    self.btn_arrowLeft:removeClickListener(888)
    self.btn_arrowLeft:addClickListener(function()
        if self.elvesIndex > 1 then 
            self.elvesIndex = self.elvesIndex - 1
        else
            return 
        end
        self.elfId           = self.allData[self.elvesIndex].elfId
        self.btn_arrowRight:setVisible(self.elvesIndex < self.allElvesNum)
        self.btn_arrowLeft:setVisible(self.elvesIndex > 1)
        self:refreshPanal()
    end,888)
end

-- 左右切换按钮
function ElvesSkinView:initSwitchBtn()
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
        -- self.list_elves:setSelectedIndex(self.elvesIndex - 1)
        self.btn_arrowRight:setVisible(self.elvesIndex < self.allElvesNum)
        self.btn_arrowLeft:setVisible(self.elvesIndex > 1)
        self.elfId           = self.allData[self.elvesIndex].elfId
        self:refreshPanal()
    end);
end

function ElvesSkinView:_initEvent()
    self:ElvesSkin_refreshPanal()
end

function ElvesSkinView:ElvesSkin_refreshPanal()
    self:initSwitchBtn()
    self:switchLeft()
    self:switchRight()
    self:refreshPanal()
end

function ElvesSkinView:refreshPanal()
    self:setSkinList()
end

-- 设置皮肤列表
function ElvesSkinView:setSkinList()
    self.skinData = {}
    self.skinData = ElvesSystemModel:getElvesSkinData(self.elfId)
    self.list_skin:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local data  = self.skinData[index]
        local icon  = obj:getChildAutoType("icon")
        local bg    = obj:getChildAutoType("bg")
        local haveCtrl  = obj:getController("haveCtrl")
        local skinCtrl  = obj:getController("skinCtrl")
        if index == 1 or index == TableUtil.GetTableLen(self.skinData) then
            obj:setVisible(false)
        else
            obj:setVisible(true)
        end

        local showSkinId = data.elfId
        if data.skinId == 1 then
            local havElf = ElvesSystemModel:isHaveElvesById(data.elfId)
            haveCtrl:setSelectedIndex(havElf and 1 or 0)
            skinCtrl:setSelectedIndex(1)
        else
            local haveSkin = ElvesSystemModel:checkSkinById(data.skinId)
            haveCtrl:setSelectedIndex(haveSkin and 1 or 0)
            skinCtrl:setSelectedIndex(data.color)
            showSkinId = data.skinId
        end
        icon:setURL(string.format("icon/ElfSkin/%s.png",showSkinId))
        obj:removeClickListener(6)
        obj:addClickListener(
            function()
                self.seletedFahionIndex = index
                local scrollIndex = self.list_skin:getSelectedIndex()+1
                self.list_skin:scrollToView(scrollIndex-2,true,true)
                self:doSpecialEffect(true);
            end,6)

        -- self:setElfIcon(data.model,data,icon)
    end)
    -- self.list_skin:setVirtualAndLoop()
    self.list_skin:setData(self.skinData)
    -- self.list_skin:setNumItems(1)

    -- self.list_skin:addEventListener(FUIEventType.Click, function(  )
	-- 	print(8848,"Click list_skin")
	-- end);
	self.list_skin:addEventListener(FUIEventType.Scroll, function(  )
		self:doSpecialEffect(false);
	end);
	self.list_skin:addEventListener(FUIEventType.ScrollEnd, function(  )
		self:doSpecialEffect(true);
    end);

    Scheduler.scheduleNextFrame(function()
        self:doSpecialEffect(true);
    end)
end

function ElvesSkinView:doSpecialEffect(isEnd)
    if tolua.isnull(self.list_skin) then return end
    local  midX = self.list_skin:getScrollPane():getPosX() + self.list_skin:getViewWidth() / 2;
    local cnt = self.list_skin:numChildren();
    for  i = 0,cnt-1 do 
        local obj = self.list_skin:getChildAt(i);
        local t_dist = midX - obj:getX() - obj:getWidth() / 2;
        local dist = math.abs(t_dist);
        local ss = (1-math.abs((1.0*dist / 2100)))
        -- obj:getChildAutoType("icon"):setScale(ss, ss);
        -- obj:getChildAutoType("bg"):setScale(ss, ss);
        -- obj:getChildAutoType("tagLoader"):setScale(ss, ss);
        -- obj:getChildAutoType("mask"):setScale(ss, ss);
        
        obj:setScale(ss,ss)
        if dist > obj:getWidth()-2 then --no intersection (不在中间的)
           
        else
            local index = self.list_skin:childIndexToItemIndex(i) + 1
            if index == 0 then 
                index = TableUtil.GetTableLen(self.skinData - 1)
            end
            if isEnd then
                print(8848,">>>index>>>",index)
                self.seletedFahionIndex = index
                -- printTable(8848,">>>self.skinData>>>",self.skinData)
                local attrCtrl = self.view:getController("attrCtrl")
                local skinCtrl = self.view:getController("skinCtrl")
                -- local skinData = ElvesSystemModel:getElvesSkinData(self.elfId)
                local data = self.skinData[index]
                self:setElfModel(data.model,data)
                self:setSkinDesc(data.skinDesc)
                self:setSkinName(data.name)
                if data.skinId == 1 then
                    attrCtrl:setSelectedIndex(0)
                    local elfData  = ModelManager.ElvesSystemModel:getElvesDataById(data.elfId)
                    self:setSkillShow(elfData.skillId,elfData,data.skinId)
                else
                    attrCtrl:setSelectedIndex(1)
                    self:setSkillShow(data.skillId,data,data.skinId)
                    self:setAttrList(data.elfId,data.skinId)
                end
                self:setBtnEvent(data.skinId,data)
            end
        end
    end
end

-- 设置属性列表
function ElvesSkinView:setAttrList(elfId,skinId)
    local attrData = ElvesSystemModel:getElvesBaseAttr(elfId,skinId)
    local special  = false
    self.list_attr:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local data  = attrData[index]
        local title = obj:getChildAutoType("title")
        if data.type <= 6 then
            title:setText(data.name .." " ..data.value)
        -- elseif not special then 
        --     special = true
        else
            title:setText(data.desc)
        end
    end)
    self.list_attr:setData(attrData)
end

-- 设置精灵模型
function ElvesSkinView:setElfModel(modelId,skinData)
    -- local data = self._args.data
    local data = self.allData[self.elvesIndex]
    local size = false
    local resource = false
    if skinData.skinId == 1 then    -- 使用默认皮肤
        resource = data.resource
        size    = data.size
        self.elfModel:setScale(size,size)
    else
        size    = skinData.size
        resource = skinData.resource
        self.elfModel:setScale(size,size)
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

-- 设置精灵模型
function ElvesSkinView:setElfIcon(modelId,skinData,node)
    -- local data = self._args.data
    local data = self.allData[self.elvesIndex]
    local size = false
    local resource = false
    if skinData.skinId == 1 then    -- 使用默认皮肤
        size    = data.size
        resource = data.resource
        node:setScale(size,size)
    else
        size    = skinData.size
        resource = skinData.resource
        node:setScale(size,size)
    end
    node:setScale(1,1)
    if node then
        node:displayObject():removeAllChildren()
    end
    local skeletonNode = SpineUtil.createModel(node, {x = node:getWidth()/2, y=5}, "stand", false,false,resource)
    if skeletonNode then
        skeletonNode:pause()
    end
    Scheduler.scheduleNextFrame(function()
        if skeletonNode then
            skeletonNode:pause()
        end
    end)
end

-- function 

-- 设置技能预览
function ElvesSkinView:setSkillShow(skillId,data,skinId)
    self.skinEffectNode:removeClickListener(11)
    local icon = self.skinEffectNode:getChildAutoType("icon")
    icon:setURL("Map/100024.jpg")
    self.skinEffectNode:addClickListener(function()
        ViewManager.open("ElvesSkinSkillPreView",{skillId = skillId,data = data,skinId = skinId})
    end,11)
end


-- 设置按钮
function ElvesSkinView:setBtnEvent(skinId,skinData)
    local elfData  = ModelManager.ElvesSystemModel:getElvesDataById(skinData.elfId)
    local activate =  false
    
    local skinCost = false
    local hasNum = 0 
    if skinId ~= 1 then
        activate = ElvesSystemModel:checkSkinById(skinId)     -- 判断有没有激活
        skinCost = skinData.costItem[1]
        hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(skinCost.code) or 0
    else
        activate = 1
    end

    local skinCtrl = self.view:getController("skinCtrl")     -- 0 没拥有皮肤,1 拥有皮肤没激活, 2 拥有皮肤已激活
    if elfData.skinId == skinId then  
        skinCtrl:setSelectedIndex(3)    -- 当前在使用的皮肤
    elseif activate then 
        skinCtrl:setSelectedIndex(2) -- 已激活
    elseif hasNum > 0 then
        skinCtrl:setSelectedIndex(1) -- 拥有皮肤没激活
    else
        skinCtrl:setSelectedIndex(0) -- 拥有皮肤已激活
    end
    
    self.btn_use:removeClickListener(11)    -- 激活
    self.btn_use:addClickListener(function()
        -- 如果没有精灵弹提示
        -- if elfData.have == 0 then
        --     RollTips.show(Desc.ElvesSystem_noElves)
        --     return
        -- end
        local pack  = PackModel:getNormalBag()
        local _itemData = pack:getItemsByCode(skinCost.code)
        local _data = _itemData[1].__data
        ElvesSystemModel:reqElfAchieveSkin(_data.uuid,skinId,self.elfId)
    end,11)

    self.btn_travel:removeClickListener(11)
    self.btn_travel:addClickListener(function()
        local actData = ModelManager.ActivityModel:getActityByType(skinData.type)
        if not actData then
            RollTips.show(Desc.ElvesSystem_noActivity)
            return
        end
        ModuleUtil.openModule(skinData.jump)
    end,11)

    self.btn_set:removeClickListener(11)
    self.btn_set:addClickListener(function()
        ElvesSystemModel:reqElfSetSkin(elfData.uuid,skinId ,self.elfId)
    end,11)
end

-- 设置精灵皮肤的描述
function ElvesSkinView:setSkinDesc(desc)
    self.txt_skinDec:setText( desc or "")
end

-- 设置精灵皮肤的名字
function ElvesSkinView:setSkinName(name)
    self.txt_skinName:setText(name)
end





return ElvesSkinView