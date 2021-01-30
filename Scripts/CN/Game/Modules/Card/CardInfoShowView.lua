---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: wangyang
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local FGUIUtil = require "Game.Utils.FGUIUtil"
local CardInfoShowView, Super = class("CardInfoShowView", Window)
local UpdateDescription = require "Configs.Handwork.UpdateDescription"
local SkillConfiger = require "Game.ConfigReaders.SkillConfiger"
local HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
local heroProperty = ModelManager.CardLibModel.heroProperty
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger"
local FashionConfiger = require "Game.ConfigReaders.FashionConfiger"

function CardInfoShowView:ctor()
    self._packName = "CardSystem"
    self._compName = "CardInfoShowView"
	
	--self.heroName = false
	self.lihuiDisplay = false
	self.arrowRight = false
    self.arrowLeft = false
    self.txt_power = false
    self.playerIcon = false
    self.dragArea   = false

    self._dragMoveX = 0
    self._dragStartX = 0
    self._lastPosX = 0 --拖动时上一次的点，用来计算方向
    self._dir = 1

    self.indexID = false
    self.categoryCardNum = false

    self.txt_name = false
    self.btn_showHero = false
    self.btn_back = false
    self.btn_lock = false
 	self.btn_fashion = false
 	self.btn_fashion_red = false
	self.CardCount = 0
	self.loader_career =  false
	self.txt_career =  false
	self.loader_category =  false
	
	self.heroShowCtrl = false
	
	self._cardcgInfo = false
	self.heroInfo = false
	self.soundId = false
	self._showMsgTimer =false
	self._showMsgTime = {3,5,8}
	self.lastShowUuid = false
end

function CardInfoShowView:_initUI()
	local viewRoot = self.view
	self.playerIcon = viewRoot:getChildAutoType("playerIcon")
	self.lihuiDisplay = BindManager.bindLihuiDisplay(self.playerIcon)
	

	--self.heroName = FGUIUtil.getChild(viewRoot, "heroName", "GTextField")
	 self.arrowRight = FGUIUtil.getChild(viewRoot, "_GButton$arrowRight", "GButton")
    self.arrowLeft = FGUIUtil.getChild(viewRoot, "_GButton$arrowLeft", "GButton")
    self.txt_power = viewRoot:getChildAutoType("txt_power")


    self.btn_showHero = viewRoot:getChildAutoType("btn_showHero")
    self.btn_back = viewRoot:getChildAutoType("btn_back")

  	self.heroShowCtrl= viewRoot:getController("heroShow")
    self.btn_Rune  = viewRoot:getChildAutoType("btn_Rune")
    self.btn_Rune:setVisible(false)
    self.btn_lock  = viewRoot:getChildAutoType("btn_lock")
    self.btn_fashion  = viewRoot:getChildAutoType("btn_fashion")
    self.btn_fashion_red = viewRoot:getChildAutoType("btn_fashion/img_red")
	self.loader_category = viewRoot:getChild("loader_category")
	self.loader_career = viewRoot:getChild("loader_career")
	self.txt_category = viewRoot:getChild("txt_category")
	self.txt_career = viewRoot:getChild("txt_career")
	
	self.txt_msg = viewRoot:getChild("txt_msg")
	self.hintMsg = viewRoot:getChild("hintMsg")
	
    self:initData()
    self:bindEvent()
    self:initTouchLihui()
    -- self:update_HeroRuneShow()
end


function CardInfoShowView:showMsg()
	local random = math.floor(math.random() * 3) + 1
	local time = self._showMsgTime[random]
	local info = ModelManager.CardLibModel.curCardStepInfo.heroDataConfiger
	if self.lastShowUuid == ModelManager.CardLibModel.curCardStepInfo.uuid then return end
	self.lastShowUuid = ModelManager.CardLibModel.curCardStepInfo.uuid
	if not info then return end
	local msg = info["tip"..random]
	--播放立绘的音效
	if self.soundId then
		SoundManager.stopSound(self.soundId)
	end
	if info.sound and #info.sound>0 then
		if info.sound[random] then
			self.soundId = SoundManager.playHeroSound(info.sound[random],false)
		end
	end
	
	self.txt_msg:setText(msg)
	self._isShowingMsg = true
	self.hintMsg:setVisible(true)
	if self._showMsgTimer then Scheduler.unschedule(self._showMsgTimer) end
	self._showMsgTimer  = Scheduler.schedule(function()
		if tolua.isnull(self.hintMsg) then return end
		self._isShowingMsg = false
		self.hintMsg:setVisible(false)
	end,time)
	
end


function CardInfoShowView:_refresh()
	self.indexID = ModelManager.CardLibModel:getCarIndex()
    self:setDetailsById(self.indexID)
end

--改变骨骼显示的动画
function CardInfoShowView:changeHeroShow(heroId,fashionId)
	self.lihuiDisplay:setData(heroId,nil,nil,fashionId)
end

function CardInfoShowView:initTouchLihui()
    self.dragArea = self.playerIcon:getChildAutoType("dragArea")
    self.playerIcon:setTouchable(true)
    
    self.dragArea:setDraggable(true)
    self.dragArea:addEventListener(FUIEventType.DragStart,function(context)
        print(999,"CardInfoShowView DragStart")
        self._dragMoveX = 0
        self._dragStartX = self.dragArea:getPosition().x
        self._lastPosX = 0
    end);

    self.dragArea:addEventListener(FUIEventType.DragMove,function(context)
        self._dragMoveX = self.dragArea:getPosition().x
        self._lastPosX = self._dragMoveX
    end);

    self.dragArea:addEventListener(FUIEventType.DragEnd,function(context)
        print(999,"CardInfoShowView DeagEnd")
        self._dir = self._dragStartX - self._lastPosX
        self._dragMoveX = 0 
        self.dragArea:setPosition(-276,-224)
        
    
        if self._dir >= 20 then  -- 右
            self:moveRight()
        elseif self._dir <= -20 then  -- 左
            self:moveLeft()
        end
    end);
end

function CardInfoShowView:moveRight()
	self.indexID = ModelManager.CardLibModel:getCarIndex()
	local cardInfos = ModelManager.CardLibModel:getHeroInfoToIndex()
	self.CardCount = #ModelManager.CardLibModel:getHeroInfoToIndex()
	if self.indexID < self.CardCount then
		self.indexID = self.indexID + 1
		self:changeIndex(cardInfos[self.indexID])
		self:updateBtns()
	end
end

function CardInfoShowView:moveLeft()
	self.indexID = ModelManager.CardLibModel:getCarIndex()
	local cardInfos = ModelManager.CardLibModel:getHeroInfoToIndex()
	self.CardCount = #ModelManager.CardLibModel:getHeroInfoToIndex()
	if self.indexID > 1 then
		self.indexID = self.indexID - 1
		self:changeIndex(cardInfos[self.indexID])
		self:updateBtns()
	end
end

function CardInfoShowView:updateBtns()
	self.arrowLeft:setVisible(self.indexID > 1)
    self.arrowRight:setVisible(self.indexID < self.CardCount)
end

--绑定事件
function CardInfoShowView:bindEvent()
    self.indexID = ModelManager.CardLibModel:getCarIndex()
    self.categoryCardNum = ModelManager.CardLibModel:getCategoryCardNumber(ModelManager.CardLibModel.cardBagCategory)
    self:setDetailsById(self.indexID)
	
	  self.arrowLeft:addClickListener(
        function(context)
            self:moveLeft()
        end
    )
	
	self.loader_category:addClickListener(
        function(context)
           ViewManager.open("BattleRaceView")
        end
    )
	
	self.loader_career:addClickListener(
        function(context)
            --printTable(5, self.heroInfo, "帮助")
			--if(self.heroInfo) then
				--local desc = ModelManager.CardLibModel:parstrStr(self.heroInfo.heroDataConfiger.characterization)
				--RollTips.showHelp("", desc)
			--end
        end
    )
	
	
    self.arrowRight:addClickListener(
        function(context)
			self:moveRight()
        end
    )
    
	
	
	local descrrBtn = self.view:getChild("btn_descrepiton")
    descrrBtn:addClickListener(
        function(context)
            local desc = ModelManager.CardLibModel:parstrStr(self.heroInfo.heroDataConfiger.description)
			RollTips.showHelp(Desc.card_DetailsStr, desc)
        end
    )

	self.btn_showHero:addClickListener(
        function(context)
           self.heroShowCtrl:setSelectedIndex(1)
			Dispatcher.dispatchEvent(EventType.cardView_hideUI, true)
        end
    )

	self.btn_back:addClickListener(
        function(context)
           self.heroShowCtrl:setSelectedIndex(0)
			Dispatcher.dispatchEvent(EventType.cardView_hideUI, false)
        end
    )
	
	self.btn_lock:addClickListener(function(context)
		local isLock = not self.heroInfo.locked
		self.btn_lock:setSelected(isLock)
		ModelManager.CardLibModel:setIsLock({self.heroInfo.uuid},isLock)
	end,99)

	self.btn_fashion:addClickListener(function(context)
		ModuleUtil.openModule(ModuleId.Fashion.id,true,{heroList = self:getHeroHaveFashionList(), heroId = self.heroId, heroUid = self.heroInfo.uuid})
	end)
end

--获取拥有时装的英雄列表
function CardInfoShowView:getHeroHaveFashionList()
	local fashionList = {}
	local heroInfo = ModelManager.CardLibModel:getHeroInfoToIndex()
	for _,v in ipairs(heroInfo) do
		local fashionInfo = FashionConfiger.getAllFashionInfoByHeroId(v.heroId)
		if fashionInfo then 
			table.insert(fashionList,v)
		end
	end
	return fashionList
end

--初始玩家卡牌信息
function CardInfoShowView:initData()
    self._cardcgInfo = ModelManager.CardLibModel:getHeroInfoToIndex()
	self.CardCount = #self._cardcgInfo
end

-- function CardInfoShowView:update_HeroRuneShow(  )
--    local info = ModelManager.CardLibModel.curCardStepInfo
--    local heroInfo = ModelManager.CardLibModel:getHeroByUid(info.uuid)
--    self.btn_Rune:removeClickListener(11)
--    if heroInfo.level >=ConstConfiger.getValueByKey("RuneAttrHeroLevel") and PlayerModel.level>=ConstConfiger.getValueByKey("RunePageRoleLevel") then
--       if heroInfo.runePageId and heroInfo.runePageId > 0 then
--          local data = ModelManager.RuneSystemModel:getRunePagesById(heroInfo.runePageId)
--          local allLevel = ModelManager.RuneSystemModel:getRuleAllLevel( heroInfo.runePageId )
--          -- self.btn_Rune:getChildAutoType("level"):setText(allLevel)
--          self.btn_Rune:setGrayed(false)
--          self.btn_Rune:setVisible(true)
--          if data and data.name~="" then
--             self.btn_Rune:getChildAutoType("title"):setText(data.name)
--          else
--             self.btn_Rune:getChildAutoType("title"):setText("符文1")
--          end
--       end
--       self.btn_Rune:addClickListener(function ( ... )
--           ViewManager.open("RuneSelectView",{runeId=heroInfo.runePageId,herouuid = info.uuid})
--       end,11)
--    else
--       -- self.btn_Rune:getChildAutoType("level"):setText("0")
--       self.btn_Rune:setGrayed(true)
--       self.btn_Rune:setVisible(false)
--       self.btn_Rune:getChildAutoType("title"):setText("未配置符文")
--       self.btn_Rune:addClickListener(function ( ... )
--          RollTips.show("达到100级的英雄才可以选择符文。")
--       end,11)
--    end
-- end

--点左右按钮切换
function CardInfoShowView:changeIndex(heroInfo)
	if not heroInfo then return end
	ModelManager.CardLibModel:clearupStarInfo()
    self.heroId = heroInfo.heroId
	ModelManager.CardLibModel.curCardStepInfo = heroInfo
	ModelManager.CardLibModel:setChooseUid(heroInfo.uuid)
	Dispatcher.dispatchEvent(EventType.cardView_updateInfo)
	self:setDetailsById()
end

function CardInfoShowView:cardView_updateInfo()
	self:_refresh()
end

function CardInfoShowView:equipment_refresheq()
	self:_refresh()
end

function CardInfoShowView:Jewelry_updateWear()
    self:_refresh()
end

--设置卡牌(英雄)详情
function CardInfoShowView:setDetailsById(index)
    print(5, index, self._cardcgInfo, "升级")
	self.indexID = ModelManager.CardLibModel:getCarIndex()
	local cardInfos = ModelManager.CardLibModel:getHeroInfoToIndex()
	self.CardCount = #ModelManager.CardLibModel:getHeroInfoToIndex()
	
	self.heroInfo  = ModelManager.CardLibModel.curCardStepInfo
    if not self.heroInfo then
        return
    end
    self.heroId = self.heroInfo.heroId
    self:updateHeroInfo(self.heroInfo)
	self:updateBtns()
	self:showMsg()
end

--更新卡牌详情信息
function CardInfoShowView:updateHeroInfo(HeroInfo)
	
	
	--self.txt_name:setText(HeroInfo.heroDataConfiger.heroName)
	
	self.loader_category:setURL(PathConfiger.getCardCategory(HeroInfo.heroDataConfiger.category))
	self.loader_career:setURL(PathConfiger.getCardProfessional(HeroInfo.heroDataConfiger.professional))
    self.txt_category:setText(Desc["card_category"..HeroInfo.heroDataConfiger.category])
	self.txt_career:setText(Desc["common_creer"..HeroInfo.heroDataConfiger.professional])
	
	self.btn_lock:setSelected(self.heroInfo.locked)
	self.heroInfo = HeroInfo
	local info = DynamicConfigData.t_hero
    local heroItem = info[HeroInfo.code]
	self.txt_power:setText(StringUtil.transValue(HeroInfo.combat))
	local fashionId = HeroInfo.fashion and HeroInfo.fashion.code or false
	if fashionId then 
		self:changeHeroShow(HeroInfo.code,fashionId)
	else
		self:changeHeroShow(HeroInfo.code)
	end
	--是否显示时装按钮
	 local haveFashion = FashionConfiger.getAllFashionInfoByHeroId(HeroInfo.heroId)
	 if haveFashion then 
	 	self.btn_fashion:setVisible(true)
	 else
	 	self.btn_fashion:setVisible(false)
	 end
	RedManager.register("V_FASHION"..HeroInfo.code, self.btn_fashion_red)
	-- self:update_HeroRuneShow()
end

function CardInfoShowView:cardView_starUpSuc(_, data)
    if data then
		--printTable(1, "卡牌升星请求返回yfyf22", data)
		local hero = data.hero
        ModelManager.CardLibModel:clearupStarInfo()
        self.txt_power:setText(StringUtil.transValue(hero.combat))
    end
end

function CardInfoShowView:cardView_levelUpSuc(_, data)
	self.indexID= ModelManager.CardLibModel:getCarIndex()
    self:setDetailsById(self.indexID)
end

function CardInfoShowView:cardView_CardAddAndDeleInfo(_, data)
    --printTable(1, "cardView_CardAddAndDeleInfo 卡牌属性更新")
    local info= ModelManager.CardLibModel.curCardStepInfo;
    local HeroInfo= CardLibModel:getHeroByUid(info.uuid)
    self.txt_power:setText(StringUtil.transValue(HeroInfo.combat))
    self.heroInfo=HeroInfo;
    self:updateHeroInfo(HeroInfo)
end

--英雄升级100级符文更新
-- function CardInfoShowView:Hero_RuneUpdateInfo(_,params)
--    local info= ModelManager.CardLibModel.curCardStepInfo;
--    if info.uuid==params.uuid then
--     CardLibModel:setHeroRunePageByUid(params.uuid,params.id)
--     self:update_HeroRuneShow()
--    end
-- end

function CardInfoShowView:_exit()
	if self.soundId then
		SoundManager.stopSound(self.soundId)
	end
    if self.annimation then
        for k, value in pairs(self.annimation) do
            Scheduler.unschedule(value)
        end
    end
	self.lastShowUuid = false
end

function CardInfoShowView:_enter()
end

return CardInfoShowView
