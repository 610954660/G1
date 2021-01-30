---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: ljj
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local FGUIUtil = require "Game.Utils.FGUIUtil"
local CardInfoDetailView, Super = class("CardInfoDetailView", Window)
local UpdateDescription = require "Configs.Handwork.UpdateDescription"
local SkillConfiger = require "Game.ConfigReaders.SkillConfiger"
local HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
local heroProperty = ModelManager.CardLibModel.heroProperty
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger"
function CardInfoDetailView:ctor()
    self._packName = "CardSystem"
    self._compName = "CardInfoDetailView"
	self._isFullScreen = false
	
	self.pageCtrl = false
	 --卡牌阶级图片显示
    self.cardAttrNameList = false --卡牌升级属性名
    self.cardInfoList = false --卡牌信息组合列表
    self.skillList = false --技能列表
   --self.skillList1 = false --被动技能列表
    --self.starsList = false --卡牌星级别的列表
    self.editorList = false --人物加点列表
	
	self.addpointview = false
    self.upGrade = false
    self.upStep = false
    self.heroLevel = false
    self.levelSplit = false
    self.heroLevelMax = false
    --卡牌升级等级

	self.costBar =  false
    --升级升阶消耗
    self.matPoint = false
    --self.skillList1 = false
    self.cardInfoList = false
    self.cardStepList = false
    self.editorList =  false
    self.groupUpgrade =  false
    self.txt_inHeroPalace =  false
	self.loader_category =  false
	self.loader_career =  false
	
	self.txt_creer =  false
	self.btn_reset =  false
	self.btn_archive =  false
	self.btn_gift =  false
	self.btn_attrEx =  false
	self.btn_lock =  false
	self.showResetCtrl = false

	--self.showBtnHelp = false
	self.txt_step = false
	self.txt_name = false
	self.txt_category = false
	self.cardStar = false
	self.txt_career =  false
	self.list_quality =  false
	
	self.allotLists = {} --分配点数
	
	self.levelUp = false --升级面板
	
	self.upgradeCost = false
	self.stepUpCost = false   --升阶消耗
	self.quickUpgradeLv = 1 --快捷升级等级数
	self.heroQuality = false
	
	self.uuid = 0
	--self.cardStepUp = false --升阶面板
	self.longTouchTimer = false
end

function CardInfoDetailView:_initUI()
    local viewRoot = self.view
	self.addpointview = viewRoot:getChild("addpointview")
    local matchPointView = viewRoot:getChild("matchPointView")
	
	self.pageCtrl = viewRoot:getController("pageCtrl")
    self.upGrade = viewRoot:getChildAutoType("upGrade")
    self.upStep = viewRoot:getChildAutoType("upStep")
    self.heroLevel = viewRoot:getChildAutoType("level")
    self.levelSplit = viewRoot:getChildAutoType("levelSplit")
    self.heroLevelMax = viewRoot:getChildAutoType("levelMax")
	self.txt_step = viewRoot:getChild("txt_step")
	self.levelUp = viewRoot:getChild("levelUp")
	self.groupUpgrade = viewRoot:getChild("groupUpgrade")
	self.txt_inHeroPalace = viewRoot:getChild("txt_inHeroPalace")
	self.txt_name = viewRoot:getChild("txt_name")
	self.txt_category = viewRoot:getChild("txt_category")
	self.loader_category = viewRoot:getChild("loader_category")
	self.loader_career = viewRoot:getChild("loader_career")

	local cardBtns = viewRoot:getChild("cardBtns")
	
	self.btn_reset = cardBtns:getChild("btn_reset")
	self.btn_archive = cardBtns:getChild("btn_archive")
	self.btn_gift = cardBtns:getChild("btn_gift")
	self.showResetCtrl = cardBtns:getController("showReset")
	self.btn_lock = cardBtns:getChild("btn_lock")

	self.btn_attrEx = viewRoot:getChild("btn_attrEx")
	
	self.txt_costName = viewRoot:getChild("txt_costName")
	
	
	

	local costBar = viewRoot:getChildAutoType("costBar")
	self.costBar = BindManager.bindCostBar(costBar)
	self.costBar:setDarkBg(true)

	local cardStar = viewRoot:getChildAutoType("cardStar")
	self.cardStar= BindManager.bindCardStar(cardStar)
	
	local heroQuality = viewRoot:getChildAutoType("heroQuality")
	self.heroQuality = BindManager.bindHeroQuality(heroQuality)

	--local cardStepUp = viewRoot:getChildAutoType("cardStepUp")
	--self.cardStepUp = CardInfoUpStep.new(cardStepUp)
    --升级升阶消耗
    self.matPoint = viewRoot:getChildAutoType("matPoint")
    self.skillList = FGUIUtil.getChild(viewRoot, "_GList$skills", "GList")
    --self.skillList1 = FGUIUtil.getChild(viewRoot, "_GList$skills1", "GList")
    self.cardInfoList = FGUIUtil.getChild(viewRoot, "_Glist$CardInfo", "GList")
    self.cardStepList = viewRoot:getChildAutoType("_Glist$CardStepInfo")
	self.txt_career = viewRoot:getChild("txt_career")
    --FGUIUtil.getChild(viewRoot,"_Glist$CardStepInfo","GList")

   
	--self.skillList = FGUIUtil.getChild(viewRoot, "_GList$skills", "GList")
    --self.skillList1 = FGUIUtil.getChild(viewRoot, "_GList$skills1", "GList")
    --self.cardInfoList = FGUIUtil.getChild(viewRoot, "_Glist$CardInfo", "GList")
    self.cardAttrNameList = FGUIUtil.getChild(viewRoot, "_Glist$baseInfoLabel", "GList")
    
	
	--self.showBtnHelp = viewRoot:getChildAutoType("btn_help")
	
	


    self:initData()
    self:bindEvent()
	
    self:setDetailsById()
end

--绑定事件
function CardInfoDetailView:bindEvent()
	
	self.upStep:addClickListener(
        function(context)
            print(5, self.heroInfo.uuid, "升阶")
            ViewManager.open("CardInfoStepUpView")
            
        end
    )
	
    self.btn_reset:addClickListener(
		function (...)
			ViewManager.open('HeroResetView', {cardInfo = ModelManager.CardLibModel.curCardStepInfo});
		end
	)

	self.btn_archive:addClickListener(
		function (...)
			ViewManager.open("HeroInfoView",{heroId = self.heroInfo.heroDataConfiger.heroId, cardInfo = self.heroInfo})
		end
	)

	self.btn_gift:addClickListener(
		function (...)
			ViewManager.open('HeroGiftView', {heroId = self.heroInfo.heroDataConfiger.heroId});
		end
	)
	
	 self.upGrade:addLongPressListener(function (context)
			if self.longTouchTimer then Scheduler.unschedule(self.longTouchTimer) end
			self.longTouchTimer =Scheduler.schedule(function()
				if self.upGrade:isVisible() then
					self.upGrade:dispatchEvent(FUIEventType.Click)	
				end
			end,0.25,0)
		end, 1,
		function (context)
			Scheduler.unschedule(self.longTouchTimer)
		end)
	
    self.upGrade:addClickListener(
        function(context)
            print(5, self.heroInfo.uuid, "升级")
			if self.upGrade:isVisible() then
				if ModelManager.PlayerModel:isCostEnough(self.upgradeCost) then
					ModelManager.CardLibModel:heroLevelUp(self.heroInfo.uuid, self.quickUpgradeLv )
				end
			end
        end
    )

    
    self.matPoint:addClickListener(
        function(context)
			print(1, "打开配点")
			ViewManager.open("MatchPointView", self.heroInfo)
        end
    )
	
	self.btn_attrEx:addClickListener(function(context)
		ViewManager.open("CardAttrView")
	end,99)
    
	
	self.btn_lock:addClickListener(function(context)
		local isLock = not self.heroInfo.locked
		self.btn_lock:setSelected(isLock)
		ModelManager.CardLibModel:setIsLock({self.heroInfo.uuid},isLock)
	end,99)
end

function CardInfoDetailView:_refresh()
    self:setDetailsById()
end


function CardInfoDetailView:cardView_updateInfo(_, data)
    self:setDetailsById()
end

function CardInfoDetailView:cardView_levelUpSuc(_, data)
    printTable(69, "卡牌升级请求返回yfyf", data)
    if data then
        self:cardLevelAndStep(data.hero)
    end
end

function CardInfoDetailView:cardView_stepUpSuc(_, data)
    printTable(5, "卡牌阶级刷新列表", data)
	--self.levelUp:setVisible(true)
	--self.cardStepUp.view:setVisible(false)
    self:setCardStep(5, data.hero.stage)
    self:cardLevelAndStep(data.hero)
	self:setDetailsById()
   
    --[[local heroLeveInfo = DynamicConfigData.t_heroLevel[data.hero.level + 1] --读表的数据
    self.upGrade:setVisible(data.hero.stage <= heroLeveInfo.stageLimit)
    self.upStep:setVisible(heroLeveInfo.stageLimit > data.hero.stage)--]]
end

function CardInfoDetailView:setbtnGrey(obj, btnType, index)
    local isGrey = false
    if btnType == 1 and self.allotLists[index] == 0 then
        isGrey = true
    end
    if btnType == 2 and self.heroInfo.attrPointNum == self:getCurAddPointNum() then
        isGrey = true
    end
    if obj == nil then
    else
        obj:setGrayed(isGrey)
    end
end

--初始玩家卡牌信息
function CardInfoDetailView:initData()
    self._cardcgInfo = ModelManager.CardLibModel:getHeroInfoToIndex()
    self.CardCount = #self._cardcgInfo
end

--设置卡牌(英雄)详情
function CardInfoDetailView:setDetailsById()
    local HeroInfo = ModelManager.CardLibModel.curCardStepInfo
    if not HeroInfo then
        return
    end
    self.heroId = HeroInfo.heroId
    self.uuid = HeroInfo.uuid
	self:updateHeroInfo(HeroInfo)
	if CardLibModel:isActivateSegment(HeroInfo) then
		self.showResetCtrl:setSelectedIndex(0)
	else
		self.showResetCtrl:setSelectedIndex(1)
	end
end

--更新卡牌详情信息
function CardInfoDetailView:updateHeroInfo(HeroInfo)
    self.heroInfo = HeroInfo
	self.heroQuality:setData(HeroInfo.heroDataConfiger.quality)
    printTable(5, "卡牌升星请求返回yfyf33", HeroInfo)


    self:cardLevelAndStep(HeroInfo) --设置卡牌等级阶级
	
	self.loader_category:setURL(PathConfiger.getCardCategory(HeroInfo.heroDataConfiger.category))
	self.loader_career:setURL(PathConfiger.getCardProfessional(HeroInfo.heroDataConfiger.professional))
	
	
    self.txt_name:setText(HeroInfo.heroDataConfiger.heroName)
    self.txt_category:setText(Desc["card_category"..HeroInfo.heroDataConfiger.category])
	self.txt_career:setText(Desc["common_creer"..HeroInfo.heroDataConfiger.professional])
	self.showResetCtrl:setSelectedIndex(HeroInfo.level > 1 and 1 or 0)
	RedManager.register("V_CardUpgrade"..self.uuid, self.upGrade:getChildAutoType("img_red"))
	RedManager.register("V_CardStepUp"..self.uuid, self.upStep:getChildAutoType("img_red"))
	RedManager.register("V_CardMatchPoint"..self.uuid, self.matPoint:getChildAutoType("img_red"))
	self.btn_lock:setSelected(self.heroInfo.locked)
	
	
    --显示卡牌名字
    local ultSkill = HeroConfiger:getSkillListByStep(HeroInfo.stage, HeroInfo)
    --获取英雄的技能列表
    printTable(9, "卡牌技能属性id", ultSkill)
    self:setSkill(ultSkill, HeroInfo)
    --demo随机展示几个技能
    --self:changeHeroShow(HeroInfo.code)
    printTable(5, self.heroId .. " 未分配点数", HeroInfo.attrPointNum)
    self.matPoint:setVisible(true)
	
	self.cardStar:setData(HeroInfo.star)
end





function CardInfoDetailView:getCurAddPointNum()
    local addNum = 0
    for k, value in pairs(self.allotLists) do
        addNum = addNum + value
    end
    return addNum
end

function CardInfoDetailView:cardView_configurationPoint(_, data)
    printTable(5, "卡牌配点返回", data)
    if data then
        for let, key in pairs(data.hero.attrs) do
            if key.id<=6 then
                self.allotLists[key.id] = 0 --已经分配的点数列表
            end
        end
        --self:setCardMatPoint(data.hero)
        self:cardLevelAndStep(data.hero)
    end
end

function CardInfoDetailView:cardView_starUpSuc(_, data)
    if data then
        printTable(5, "卡牌升星请求返回yfyf22", data)
       self:setDetailsById()
    end
end


function CardInfoDetailView:cardView_CardAddAndDeleInfo(_, data)
    printTable(8, "卡牌属性更新")
   self:setDetailsById()
end


--设置技能列表的技能(分主动技能和被动技能)
function CardInfoDetailView:setSkill(ultSkill, heroInfo)
    self.skillList:setItemRenderer(
        function(index, obj)
            obj:removeClickListener(100)
            --池子里面原来的事件注销掉
            obj:addClickListener(
                function(context)
                    --点击查看技能详情
                    local skillInfo = false
					skillInfo = DynamicConfigData.t_skill[ultSkill[index + 1].skillId]
					if skillInfo then
						ViewManager.open("ItemTips", {codeType = CodeType.SKILL, id = ultSkill[index + 1].skillId, heroId = heroInfo.code, step = heroInfo.step, hero = heroInfo})
					end
                end,
                100
            )
			local skillCellObj = obj:getChild("skillCell")
			local skillCell = BindManager.bindSkillCell(skillCellObj)
			skillCell:setData(ultSkill[index + 1].skillId)
			local txt_level = obj:getChild("txt_level")
			txt_level:setText("Lv."..ultSkill[index + 1].level)
			local c1 = obj:getController("c1")
			local lockCtrl = skillCellObj:getController("lockCtrl")
			if ultSkill[index + 1].activeLevel > heroInfo.stage then
				c1:setSelectedIndex(1)
				lockCtrl:setSelectedIndex(1)
				local txt_active = obj:getChildAutoType("txt_active")
				txt_active:setText(string.format(Desc.card_activeStep, ultSkill[index + 1].activeLevel))
				skillCellObj:setGrayed(false)
				skillCellObj:setGrayed(true)
			else
				c1:setSelectedIndex(0)
				lockCtrl:setSelectedIndex(0)
				skillCellObj:setGrayed(false)
			end          
        end
    )
    self.skillList:setNumItems((#ultSkill))

    -- self.passiveSkill={};
    -- for key, value in pairs(heroInfo.passiveSkill) do
    --     table.insert( self.passiveSkill, value.id) 
    -- end

    -- for key, value in pairs(heroInfo.reservedSkill) do
    --     table.insert( self.passiveSkill, value.id) 
    -- end
end


--设置卡牌等级阶级信息
function CardInfoDetailView:cardLevelAndStep(HeroInfo)
    printTable(5, "卡牌升级返回数据", HeroInfo)
    
    --self.fightNum:setText(HeroInfo.combat)
    self.heroLevel:setText(HeroInfo.level)
    local heroLeveInfo = DynamicConfigData.t_heroLevel[HeroInfo.level + 1] --读表的数据
    local heroStageInfo = DynamicConfigData.t_heroStage[HeroInfo.stage + 1] --读表的数据
    --if not heroLeveInfo then
    --    heroLeveInfo = DynamicConfigData.t_heroLevel[HeroInfo.level] --读表的数据
   -- end
	local isInHeroPalace = ModelManager.HeroPalaceModel:isInGroupB(HeroInfo.uuid)
    local maxStep = #(DynamicConfigData.t_heroStage)
	
	
    self.upGrade:setGrayed(false) 
    --if not heroLeveInfo or (#heroLeveInfo.levelLimit > 0 and not ModelManager.HeroPalaceModel:isCanLvUp(heroLeveInfo.levelLimit[1],heroLeveInfo.levelLimit[2], HeroInfo.uuid)) then
    if not heroLeveInfo then
		--self.costBar:setVisible(false)
		--self.levelSplit:setVisible(false)
		--self.heroLevelMax:setVisible(false)
		-- local lv = HeroConfiger.getNextLevelLimit(HeroInfo.stage, HeroInfo.level);
		local baseLv = HeroConfiger.getNextLevelLimit(HeroInfo.stage, HeroInfo.level);
		local segmentAddLv = CardLibModel:getSegmentAddLvMax(HeroInfo);
		local str = baseLv + segmentAddLv;
		self.heroLevelMax:setText(str)
		--self.upGrade:setVisible(false)
		self.upGrade:setTitle(Desc.card_upgrade)
		self.upGrade:setVisible(true)
		self.upGrade:setGrayed(true)
		self.upGrade:setTouchable(false)
		self.upStep:setVisible(false)
		self.groupUpgrade:setVisible(false)
		self.costBar:setVisible(false)
		Dispatcher.dispatchEvent(EventType.cardView_setMoneyType, "upgrade")  --金钱条上面显示升级道具
		if isInHeroPalace then
			self.txt_inHeroPalace:setText(Desc.card_inHeroPalace)
		elseif not heroLeveInfo then
			self.txt_inHeroPalace:setText(Desc.card_DetailsStr6)
		else
			self.txt_inHeroPalace:setText(string.format(Desc.card_needPalaceLv, heroLeveInfo.levelLimit[2]))
		end
    else --and heroLeveInfo.stageLimit > HeroInfo.stage
		
		local showUpStep = HeroInfo.stage < 11 and heroLeveInfo.stageLimit > HeroInfo.stage and HeroInfo.stage < maxStep and not isInHeroPalace
		local showUpStar = HeroInfo.stage < 11 and showUpStep and heroStageInfo and heroStageInfo.StarLimit > HeroInfo.star and not isInHeroPalace
		self.upStep:setVisible(showUpStep)
		--local showUpgrade = HeroInfo.stage <= heroLeveInfo.stageLimit and not isInHeroPalace and not showUpStep and not showUpStar
		local showUpgrade = not isInHeroPalace and not showUpStep and not showUpStar and  HeroInfo.level < (HeroConfiger.getNextLevelLimit(HeroInfo.stage, HeroInfo.level) + CardLibModel:getSegmentAddLvMax(HeroInfo))
		if showUpStar then
			self.upGrade:setTitle(Desc.card_upgrade)
			self.upGrade:setVisible(true)
			self.upGrade:setGrayed(true)
			self.upGrade:setTouchable(false)
			self.costBar:setVisible(false)
			self.upStep:setVisible(false)
			--self.txt_inHeroPalace:setText(string.format(Desc.card_needStarUp,heroStageInfo.StarLimit))
		elseif showUpStep then
			self.upGrade:setTitle(Desc.card_upgrade)
			self.upGrade:setVisible(false)
			self.upGrade:setGrayed(false)
			self.upGrade:setTouchable(true)
			Dispatcher.dispatchEvent(EventType.cardView_setMoneyType, "stepUp")  --金钱条上面显示升阶道具
			self.txt_costName:setText(Desc.card_stepUpCost)
			self.costBar:setVisible(false)
			
			local heroLeveInfo=DynamicConfigData.t_heroStage[(HeroInfo.stage+1)]--读表的数据
			local curLeveInfo=DynamicConfigData.t_heroStage[(HeroInfo.stage)]--读表的数据
			if heroLeveInfo==nil then
				heroLeveInfo=curLeveInfo;
			end
	
			self.upgradeCost = heroLeveInfo.costList
			self.costBar:setData(self.upgradeCost, true)
		else
			self.upGrade:setVisible(true)
			self.upGrade:setTouchable(showUpgrade)
			self.upGrade:setGrayed(not showUpgrade)
			self.txt_costName:setText(Desc.card_upgradeCost)
			Dispatcher.dispatchEvent(EventType.cardView_setMoneyType, "upgrade")  --金钱条上面显示升级道具
			
			self.costBar:setVisible(showUpgrade)
			
			
			--这里计算出最多可以升多少级
			local upLvNum = 1
			local quickCost
			for i = 1,5,1 do 
				local toLv = HeroInfo.level + i
				if toLv > 60 then break end
				quickCost = HeroConfiger.getQuickUpgradeCost(HeroInfo.level, i) --获得升几级一共需要多少材料
				if not ModelManager.PlayerModel:isCostEnough(quickCost, false) then break end; --材料不够的
				local lvConfig = DynamicConfigData.t_heroLevel[toLv]
				--if not lvConfig or (#lvConfig.levelLimit > 0 and not ModelManager.HeroPalaceModel:isCanLvUp(lvConfig.levelLimit[1],lvConfig.levelLimit[2], HeroInfo.uuid)) then break end --英雄谷等级限制的
				if not lvConfig then break end --英雄谷等级限制的
				if lvConfig.stageLimit > HeroInfo.stage then break end --升阶升级限制的
				upLvNum = i
			end
			local quickCost = HeroConfiger.getQuickUpgradeCost(HeroInfo.level, upLvNum)
			if showUpgrade and upLvNum > 1 then
				self.upgradeCost = quickCost
				
				self.upGrade:setTitle(string.format(Desc.card_upgradeQuick, upLvNum))
				self.quickUpgradeLv = upLvNum
			else
				self.upgradeCost = {
					{type = heroLeveInfo.type1, code = heroLeveInfo.code1, amount = heroLeveInfo.amount1},
					{type = heroLeveInfo.type2, code = heroLeveInfo.code2, amount = heroLeveInfo.amount2},
				}
				self.upGrade:setTitle(Desc.card_upgrade)
				self.quickUpgradeLv = 1
			end
			self.costBar:setData(self.upgradeCost, true)
		end
		
		--self.levelSplit:setVisible(true)
		--self.heroLevelMax:setVisible(true)
		-- local str = ""
		-- if (heroLeveInfo) then
			local baseLv = HeroConfiger.getNextLevelLimit(HeroInfo.stage, HeroInfo.level);
			local segmentAddLv = CardLibModel:getSegmentAddLvMax(HeroInfo);
			local str = baseLv + segmentAddLv;
		-- else
		-- 	str = #DynamicConfigData.t_heroLevel;
		-- end
		self.heroLevelMax:setText(str)
		if isInHeroPalace and not showUpStep then
			self.txt_inHeroPalace:setText(Desc.card_inHeroPalace)	
			self.groupUpgrade:setVisible(false)
		elseif showUpStar then
			--如果是满星的，要显示"当前阶段已满级",否则显示要升星
			local hero = DynamicConfigData.t_hero[HeroInfo.code]
			local starRuleId = hero.starRule
			local starData = DynamicConfigData.t_heroStar[starRuleId]
			if not starData or not starData[HeroInfo.star] then
				self.txt_inHeroPalace:setText(Desc.card_needStarFull)
			else
				self.txt_inHeroPalace:setText(string.format(Desc.card_needStarUp, heroStageInfo.StarLimit))
			end
			
			self.groupUpgrade:setVisible(false)
		elseif showUpStep then
			self.txt_inHeroPalace:setText(Desc.card_needStepUp)
			local stageInfo = DynamicConfigData.t_heroStage[HeroInfo.stage + 1]
			self.upStep:setTouchable(true)
			self.upStep:setGrayed(false)
			if stageInfo and HeroInfo.star < stageInfo.StarLimit then
				self.txt_inHeroPalace:setText(string.format(Desc.card_StepUpStarLimit, stageInfo.StarLimit))
				self.upStep:setTouchable(false)
				self.upStep:setGrayed(true)
			end
		
			self.groupUpgrade:setVisible(true)
		else
			self.txt_inHeroPalace:setText(showUpgrade and "" or Desc.card_DetailsStr6)
			self.groupUpgrade:setVisible(true)
		end
    end
	

    self:setCardStep(5, HeroInfo.stage)
    local attrType = DynamicConfigData.t_hero[HeroInfo.code].attType
--    self:setCardAttrName(attrType, HeroInfo.attrs)
    self:setCardAttrValue(attrType, HeroInfo.attrs)
end

--设置卡牌属性名展示
function CardInfoDetailView:setCardAttrName(attrType, curAttr)
    local viewRoot = self.view
    local oldAttr = ModelManager.CardLibModel.curCardStepInfo.attrs   --__cardAttrAdd
    local isListVisble = false
    for key, cur in pairs(curAttr) do
        local oldValue = oldAttr[key]
        if cur.value - oldValue.value > 0 then
            isListVisble = true
            break
        end
    end
    self.cardAttrNameList:setVisible(isListVisble)
    if isListVisble then
        local t = viewRoot:getTransition("t1")
        t:playReverse()
        t:stop()
        printTable(5, "设置卡牌属性名展示>>>>>>>>", t)
        self.cardAttrNameList:setVisible(isListVisble)
        t:play(
            function(context)
                self.cardAttrNameList:setVisible(false)
            end
        )
    end
    self.cardAttrNameList:setItemRenderer(
        function(index, obj)
            obj:removeClickListener()
            --池子里面原来的事件注销掉
            local old = oldAttr[index + 1]
            local value = curAttr[index + 1]
            obj:setText(ModelManager.CardLibModel.cardAttrName[value.id] .. "+" .. (value.value - old.value))
        end
    )
    self.cardAttrNameList:setNumItems(#oldAttr)
end

--设置卡牌属性
function CardInfoDetailView:setCardAttrValue(att_type, curAttr)
    local reality = {}
    for key, value in pairs(curAttr) do
        if att_type == 1 and value.id ~= 4 and value.id<=6 then
            reality[#reality + 1] = value
        elseif att_type == 2 and value.id ~= 2 and value.id<=6 then
            reality[#reality + 1] = value
        end
    end
    printTable(8, ">>>>>>>>>>", curAttr)
    self.cardInfoList:setItemRenderer(
        function(index, obj)
            obj:removeClickListener()
            --池子里面原来的事件注销掉
            local value = reality[index + 1]
            local txt_attrName = obj:getChild("txt_attrName")
            local txt_cur = obj:getChild("txt_cur")
            --local img_arrow = obj:getChild("img_arrow")
            --local txt_next = obj:getChild("txt_next")
			local iconLoader = obj:getChildAutoType("loader_attrIcon")
			iconLoader:setURL(PathConfiger.getFightAttrIcon(value.id))
            txt_attrName:setText(ModelManager.CardLibModel.cardAttrName[value.id])
            txt_cur:setText(" " .. value.value)
            --txt_next:setText(" " .. value.value)
			--txt_next:setVisible(false)
        end
    )
    self.cardInfoList:setNumItems(#reality)
end

--设置卡牌阶级展示
function CardInfoDetailView:setCardStep(maxStep, curStep)

	self.txt_step:setText(curStep)--string.format(Desc.card_step, curStep))
end

function CardInfoDetailView:_exit()
    --ModelManager.CardLibModel:clearupStarInfo()
    if self.annimation then
        for k, value in pairs(self.annimation) do
            Scheduler.unschedule(value)
        end
    end
	if self.longTouchTimer then
		Scheduler.unschedule(self.longTouchTimer)
	end
end

function CardInfoDetailView:_enter()
end

return CardInfoDetailView
