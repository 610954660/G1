---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: ljj
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local CardInfoStarUpView, Super = class("CardInfoStarUpView", Window)
function CardInfoStarUpView:ctor()
    self._packName = "CardSystem"
    self._compName = "CardInfoStarUpView"
	self._isFullScreen = false
	self.cardStar1 = false
    self.cardStar2 = false
    self.txtlevel = false
    self.txt_desc = false
    self.txtNextlevel = false
    self.txtAttrdian = false
    self.txt_attrdianNum = false
    self.txtNextattrdian = false
    self.txtCost = false
    self.sendUpStar = false
    self.starCloseButton = false
    self.listMaterials = false
	self.btn_matPoint = false
	
	self.heroId = false
	self.uuid = 0
	self.heroInfo = false
	self._cardcgInfo = false
	self.viewCtrl = false
	self.canUpCtrl = false
	self.txt_tips = false
	
	self.skillNumCtrl = false
	self.skillCtrl = false
	self.txt_skillLv0 = false
	self.txt_skillLv1 = false
	self.txt_skillLv2 = false
	self.skillCell0 = false
	self.skillCell1 = false
	self.skillCell2 = false
	
	self._upStarTips = ""
	
	
	self.costBar = false
end

function CardInfoStarUpView:_initUI()
	ModelManager.CardLibModel:clearupStarInfo()
	local upStarView = self.view
    local cardStar1 = upStarView:getChildAutoType("cardStar1")
    local cardStar2 = upStarView:getChildAutoType("cardStar2")
	self.cardStar1 = BindManager.bindCardStar(cardStar1)
	self.cardStar2 = BindManager.bindCardStar(cardStar2)
    self.txtlevel = upStarView:getChildAutoType("txt_level")
    self.txt_desc = upStarView:getChildAutoType("txt_desc")
    self.txtNextlevel = upStarView:getChildAutoType("txt_nextlevel")
    self.txtAttrdian = upStarView:getChildAutoType("txt_attrdian")
    self.txt_attrdianNum = upStarView:getChildAutoType("txt_attrdianNum")
    self.txtNextattrdian = upStarView:getChildAutoType("txt_nextattrdian")
    self.sendUpStar = upStarView:getChildAutoType("btn_star")
    self.starCloseButton = upStarView:getChildAutoType("starCloseButton")
    self.listMaterials = upStarView:getChildAutoType("list_materials")
    self.btn_matPoint = upStarView:getChildAutoType("btn_matPoint")
    self.viewCtrl = upStarView:getController("c1")
    self.canUpCtrl = upStarView:getController("canUp")
    self.btn_upStarPreHelp = upStarView:getChildAutoType("btn_upStarPreHelp")
    self.txt_tips1 = upStarView:getChildAutoType("txt_tips1")
	
	self.skillCtrl = self.view:getController("skill")
	self.skillNumCtrl = self.view:getController("skillNum")
	self.txt_skillLv0 = self.view:getChildAutoType("txt_skillLv0")
	self.txt_skillLv1 = self.view:getChildAutoType("txt_skillLv1")
	self.txt_skillLv2 = self.view:getChildAutoType("txt_skillLv2")
	self.skillCell0 = self.view:getChildAutoType("skillCell0")
	self.skillCell1 = self.view:getChildAutoType("skillCell1")
	self.skillCell2 = self.view:getChildAutoType("skillCell2")
	self.skillCell0 = BindManager.bindSkillCell(self.skillCell0)
	self.skillCell1 = BindManager.bindSkillCell(self.skillCell1)
	self.skillCell2 = BindManager.bindSkillCell(self.skillCell2)

    self.costBar = BindManager.bindCostBar(upStarView:getChildAutoType("costBar"))
    self.txt_tips = upStarView:getChildAutoType("txt_tips");
    -- 20星界面
        self.btn_matPoint20 = upStarView:getChildAutoType("btn_matPoint1");
        self.btn_help20 = upStarView:getChildAutoType("btn_upStar20Help");
        self.btn_help20:setVisible(false);
        for i = 1, 4 do
            self["star_"..i] = upStarView:getChildAutoType("star"..i);
            self["starLine_"..i] = upStarView:getChildAutoType("starLine_"..i);
        end
        self.heroCell20 = BindManager.bindCardCell(upStarView:getChildAutoType("heroCell20"));
        self.btn_preview20 = upStarView:getChildAutoType("btn_preview20");
        self.btn_upstar20 = upStarView:getChildAutoType("btn_upstar20");
    -- 20星界面 end
    
	self.sendUpStar:addClickListener(
        function(context)
			if self._upStarTips ~= "" then
				RollTips.show(self._upStarTips)
				return
			end
            local heroInfo = ModelManager.CardLibModel.curCardStepInfo
            print(5, heroInfo.uuid, "升星")
            local uidList = {}
            local starItem = {}
            local temp = ModelManager.CardLibModel.curCardStarUpChoose
            for k, value in pairs(temp) do
                for ke, uid in pairs(value) do
                    if (uid.uuid) then
                        table.insert(uidList, uid.uuid);
                    else
                        if (not starItem[uid.code]) then
                            starItem[uid.code] = {code = uid.code, num = uid.amount};
                        else
                            starItem[uid.code].num = starItem[uid.code].num + uid.amount
                        end
                    end
                end
            end
			
			local curStage = heroInfo.stage
			local nextStage = heroInfo.stage
			local curStar = heroInfo.star
			local nextStar = heroInfo.star + 1
			if DynamicConfigData.t_StarStage[heroInfo.star + 1] then
				nextStage = DynamicConfigData.t_StarStage[heroInfo.star + 1].heroStage
				if DynamicConfigData.t_StarStage[heroInfo.star] then
					curStage = DynamicConfigData.t_StarStage[heroInfo.star].heroStage
				else
					curStage = nextStage - 1
				end
			end
	
			local curAllAttr= ModelManager.CardLibModel:getCardAllAttrInfo(heroInfo,heroInfo.level,curStage, curStar);
			local nextAllAttr= ModelManager.CardLibModel:getCardAllAttrInfo(heroInfo,heroInfo.level,nextStage, nextStar);
			local attrs = heroInfo.attrs
            ModelManager.CardLibModel:heroStarLevelUp(heroInfo.uuid, uidList, starItem, false,curStage, nextStage)
        end
    )

	self.btn_matPoint:addClickListener(
        function(context)
			ViewManager.open("MatchPointView", ModelManager.CardLibModel.curCardStepInfo)
        end
    )
    
    self.btn_matPoint20:addClickListener(
        function(context)
			ViewManager.open("MatchPointView", ModelManager.CardLibModel.curCardStepInfo)
        end
    )
    self.btn_help20:addClickListener(function()
        local info = {
            title = Desc["help_StrTitle"..ModuleId.CardStarUp20.id] or "",
            desc = Desc["help_StrDesc"..ModuleId.CardStarUp20.id] or "",
        }
        ViewManager.open("GetPublicHelpView",info) 
    end)

    self.btn_upstar20:addClickListener(function()
        local heroInfo = ModelManager.CardLibModel.curCardStepInfo;
        CardLibModel:heroStarSegmentLevelUpFinish(heroInfo.uuid);
    end)

    -- 加成预览
    self.btn_preview20:addClickListener(function()
        ViewManager.open("CardSegmentView", {hero = ModelManager.CardLibModel.curCardStepInfo})
    end)

	self._cardcgInfo = ModelManager.CardLibModel:getHeroInfoToIndex()
	--local indexID = ModelManager.CardLibModel:getCarIndex()
    --local categoryCardNum = ModelManager.CardLibModel.categoryCardNum
    --self:setDetailsById(indexID)
    self:updateInfo()
    self:upBtnUpStar20();
end

function CardInfoStarUpView:_initEvent()
    self.btn_upStarPreHelp:addClickListener(--升星预览
        function(context)
			ViewManager.open("CardUpstarPreview", {hero = ModelManager.CardLibModel.curCardStepInfo})
        end
    )
end

function CardInfoStarUpView:_refresh()
	--local indexID = ModelManager.CardLibModel:getCarIndex()
    --self:setDetailsById(indexID)
	self:updateInfo()
end

function CardInfoStarUpView:cardView_updateInfo(_, data)
	--local indexID = ModelManager.CardLibModel:getCarIndex()
    --self:setDetailsById(indexID)
	self:updateInfo(data)
end

function CardInfoStarUpView:cardView_starUpSuc(_, data)
    if data then
        printTable(5, "卡牌升星请求返回yfyf22", data)
        --ModelManager.CardLibModel.curCardStepInfo = data.hero
        
        --self:showStar()
       -- self:upStarInfo(data.hero)
	
	self:updateInfo(data)
    end
end

function CardInfoStarUpView:updateInfo(data)
	--print(5, index, self._cardcgInfo, "升级")
    local HeroInfo = ModelManager.CardLibModel.curCardStepInfo
    
    if not HeroInfo then
        return
    end
	
	
	--显示技能提升
	local curStage = HeroInfo.stage
	local nextStage = HeroInfo.stage
	
	if DynamicConfigData.t_StarStage[HeroInfo.star + 1] then
		nextStage = DynamicConfigData.t_StarStage[HeroInfo.star + 1].heroStage
		if DynamicConfigData.t_StarStage[HeroInfo.star] then
			curStage = DynamicConfigData.t_StarStage[HeroInfo.star].heroStage
		else
			curStage = nextStage - 1
		end
	end
	
	if nextStage > curStage then
		local heroLeveInfo=DynamicConfigData.t_heroStage[nextStage]--读表的数据
		local curLeveInfo=DynamicConfigData.t_heroStage[curStage]--读表的数据
		if heroLeveInfo==nil then
			heroLeveInfo=curLeveInfo;
		end
		
		local skillUpId
		local skillUpFrom = 0
		local skillUpTo = 0
		for i = 1,4,1 do
			skillUpFrom = curLeveInfo.skillLevel[i]
			skillUpTo = heroLeveInfo.skillLevel[i]
			if skillUpTo > skillUpFrom then
				skillUpId = HeroInfo.heroDataConfiger["skill"..i]
				break
			end
		end
		if skillUpId  and #skillUpId >= skillUpTo then
			self.skillCtrl:setSelectedIndex(1)
			
			if skillUpFrom == 0 then
				self.skillNumCtrl:setSelectedIndex(0)
				self.txt_skillLv0:setText("Lv."..skillUpTo)
				self.skillCell0:setData(skillUpId[skillUpTo], true, HeroInfo.heroDataConfiger.heroId)
			else
				self.skillNumCtrl:setSelectedIndex(1)
				self.txt_skillLv1:setText("Lv."..skillUpFrom)
				self.txt_skillLv2:setText("Lv."..skillUpTo)
				self.skillCell1:setData(skillUpId[skillUpFrom], true, HeroInfo.heroDataConfiger.heroId)
				self.skillCell2:setData(skillUpId[skillUpTo], true, HeroInfo.heroDataConfiger.heroId)
			end
			
		else
			self.skillCtrl:setSelectedIndex(0)
		end
	else
		self.skillCtrl:setSelectedIndex(0)
	end
	-----------------------------------------------------------------
	

    if data and data.heroUid and data.heroUid  == HeroInfo.uuid then
        ModelManager.CardLibModel:clearupStarInfo()
    end
    self.heroId = HeroInfo.heroId
    self.uuid = HeroInfo.uuid
	
    --ModelManager.CardLibModel.curCardStepInfo = HeroInfo
    --ModelManager.CardLibModel.__cardAttrAdd = HeroInfo.attrs
	RedManager.register("V_CardMatchPoint"..self.uuid, self.btn_matPoint:getChildAutoType("img_red"))
	RedManager.register("V_CardStarUp"..self.uuid, self.sendUpStar:getChildAutoType("img_red"))
    self:updateHeroInfo(HeroInfo)
end

--更新卡牌详情信息
function CardInfoStarUpView:updateHeroInfo(HeroInfo)
    self.heroInfo = HeroInfo
  
    self:showStar()

end

--设置卡牌等级阶级信息
function CardInfoStarUpView:showStar()
	
	
    local heroInfo = ModelManager.CardLibModel.curCardStepInfo
    local limitLv = ModelManager.CardLibModel:getHeroCardStarlv(heroInfo.star)
    local nextlimitLv = ModelManager.CardLibModel:getHeroCardStarlv(heroInfo.star + 1)
    printTable(5, "卡牌升星请求返回yfyfaaaaa1", limitLv, nextlimitLv)
    
    self.txtlevel:setText(limitLv)
    self.txtNextlevel:setText(nextlimitLv)
    local attrNum = heroInfo.attrPointNum
    self.txtAttrdian:setText(Desc.card_DetailsStr8)
    self.txt_attrdianNum:setText(attrNum)
	self.txt_tips:setText("")
	self.sendUpStar:setTouchable(true)
  
   
    --设置卡牌的星级
	self.cardStar1:setData(heroInfo.star)
	self.cardStar2:setData(heroInfo.star + 1)

    local info = DynamicConfigData.t_hero
    local starRuleId = info[heroInfo.code].starRule
    local starInfo = DynamicConfigData.t_heroStar
    local segmentConf = DynamicConfigData.t_HeroSegment
    local starData = starInfo[starRuleId]
    if (heroInfo.star >= 19 and segmentConf[heroInfo.star]) then
        local conf = DynamicConfigData.t_module[ModuleId.CardStarUp20.id];
        local limit = conf.condition or {};
        local str = "";
        for _, info in ipairs(limit) do
            if (info.type == 1) then
                local s = string.format(Desc.card_segmentStr4, info.val);
                if (PlayerModel.level < info.val) then
                    if (str == "") then
                        str = s
                    else
                        str = str..Desc.card_upStarLimitConn..s
                    end
                end
            end
            if (info.type == 14) then
                local centerLv = ModelManager.HeroPalaceModel.crystal or 0;
				local level = ModelManager.HeroPalaceModel:getLevel()
                if (level < info.val and centerLv < info.val) then
                    local s = string.format(Desc.card_upStarLimitHeroPalace, info.val);
                    if (str == "") then
                        str = s
                    else
                        str = str..Desc.card_upStarLimitConn..s
                    end
                end
            end
        end
        local tips = str ~= "" and str..Desc.card_segmentOpen or false
        if (tips) then
            self.txt_tips1:setText(tips);
            self.viewCtrl:setSelectedIndex(1);
        else
            self:showStar20View();
            self.viewCtrl:setSelectedIndex(2);
        end
        return;
    end
	
    if not starData then
        self.txt_tips1:setText(Desc.card_maxStar);
		self.viewCtrl:setSelectedIndex(1)
        return -- body
    end
    local starItem = starData[heroInfo.star]
	--local nextStarItem = starData[heroInfo.star]
    if not starItem then
        self.txt_tips1:setText(Desc.card_maxStar);
		self.viewCtrl:setSelectedIndex(1)
        return;
    end
	
	local upstarLimit = starItem and starItem.upstarLimit
	self._upStarTips = ""
	if upstarLimit and #upstarLimit > 0 then
		for _,v in pairs(upstarLimit) do
			if v.type == 1 then
				if heroInfo.level < v.num then
					self.canUpCtrl:setSelectedIndex(0)
					if self._upStarTips == "" then
						self._upStarTips = string.format(Desc.card_upStarLimitLevel, v.num)
					else
						self._upStarTips = self._upStarTips..Desc.card_upStarLimitConn..string.format(Desc.card_upStarLimitLevel, v.num)
					end
				end
			elseif v.type == 2 then
				if ModelManager.HeroPalaceModel:getLevel() < v.num then
					self.canUpCtrl:setSelectedIndex(0)
					if self._upStarTips == "" then
						self._upStarTips = string.format(Desc.card_upStarLimitHeroPalace, v.num)	
					else
						self._upStarTips = self._upStarTips..Desc.card_upStarLimitConn..string.format(Desc.card_upStarLimitHeroPalace, v.num)
					end
				end
			elseif v.type == 3 then
				if not ModelManager.CardLibModel:isStarHeroEnough(v.num, v.num2) then
					self.canUpCtrl:setSelectedIndex(0)
					if self._upStarTips == "" then
						self._upStarTips = string.format(Desc.card_needStarHero, v.num2,v.num)	
					else
						self._upStarTips = self._upStarTips..Desc.card_upStarLimitConn..string.format(Desc.card_needStarHero, v.num2,v.num)
					end
				end
			end
		end		
	end
	if self._upStarTips ~= "" then
		self.canUpCtrl:setSelectedIndex(0)
		--self.sendUpStar:setGrayed(true)
		self.sendUpStar:getController("button"):setSelectedIndex(2)
		self.sendUpStar:setTouchable(false)
		self.txt_tips:setText(self._upStarTips)
	else
		self.canUpCtrl:setSelectedIndex(1)
		self.sendUpStar:getController("button"):setSelectedIndex(0)
		self.sendUpStar:setTouchable(true)
		--self.sendUpStar:setGrayed(false)
	end
	
	
	self.txt_desc:setText(starItem.describe)
	self.viewCtrl:setSelectedIndex(0)
	self.costBar:setData(starItem.material)
    printTable(5, "卡牌升星请求返回yfyf", heroInfo)
    local temp, cost = ModelManager.CardLibModel:getUpStarMaterials(heroInfo.code, heroInfo.star)
    if heroInfo.star == 4 then -- 4星升5星
        for index,v in ipairs(temp) do
            --当需要的材料是本尊时,默认选择等级低的，且未上阵
            if v.type == 1 then
                local cardS = ModelManager.CardLibModel:getStarCanChooseInfo(temp[index], heroInfo.heroDataConfiger, index) --ModelManager.CardLibModel:getCardByCategory(heroInfo.heroDataConfiger.category, {heroInfo.uuid}, temp.star, 1)
                local addNum = 0
                local info = {};
                local heroList = {}
                for _, hero in pairs(cardS) do
                    table.insert(heroList, hero)
                end
                table.sort(heroList, function(a, b)
                    return a.level < b.level
                end)
                for _, hero in ipairs(heroList) do
                    if not hero.locked and hero.star == v.star and #(BattleModel:getArrayTypes(hero.uuid)) == 0 and not ModelManager.HeroPalaceModel:isInHeroPalace(hero.uuid) then -- 未上阵、未锁定
                        addNum = addNum + 1
                        table.insert(info, hero)
                        if addNum >= v.num then
                            break
                        end
                    end
                end
                if (info) then
                    ModelManager.CardLibModel:addCurCardStarUpChoose(index, info);
                end
            elseif v.type == 2 then -- 当需要的材料是同阵营4星时，优先选择同卡数量少的，然后是等级低的且未上阵
                local cardS = ModelManager.CardLibModel:getStarCanChooseInfo(temp[index], heroInfo.heroDataConfiger, index) --ModelManager.CardLibModel:getCardByCategory(heroInfo.heroDataConfiger.category, {heroInfo.uuid}, temp.star, 1)
                local addNum = 0
                local info = {};
                local heroIdMap = {}
                for _, hero in pairs(cardS) do
                    local heroId = hero.heroId
                    if not heroIdMap[heroId] then
                        heroIdMap[heroId] = {}
                    end
                    table.insert(heroIdMap[heroId], hero)
                end
                local tempHeroList = {}
                for _, list in pairs(heroIdMap) do
                    table.insert(tempHeroList, list)
                end
                table.sort(tempHeroList, function(a, b)
                    if #a == #b then
                        local totalLevel_a = 0
                        local totalLevel_b = 0
                        for _, hero in pairs(a) do
                            totalLevel_a = totalLevel_a + hero.level
                        end
                        for _, hero in pairs(b) do
                            totalLevel_b = totalLevel_b + hero.level
                        end
                        return totalLevel_a < totalLevel_b
                    end
                    return #a < #b
                end)
                local heroList = {}
                for _, list in ipairs(tempHeroList) do
                    table.sort(list, function(a, b)
                        return a.level < b.level
                    end)
                    for k, hero in ipairs(list) do
                        table.insert(heroList, hero)
                    end
                end
                -- for _, hero in ipairs(heroList) do
                --     LuaLogE("index:2  ".."heroId:"..hero.heroId.."  star:"..hero.star)
                -- end
                for _, hero in ipairs(heroList) do
                    if not hero.locked and hero.star == v.star and #(BattleModel:getArrayTypes(hero.uuid)) == 0 and not ModelManager.HeroPalaceModel:isInHeroPalace(hero.uuid) then -- 未上阵、未锁定
                        addNum = addNum + 1
                        table.insert(info, hero)
                        if addNum >= v.num then
                            break
                        end
                    end
                end
                if (info) then
                    ModelManager.CardLibModel:addCurCardStarUpChoose(index, info);
                end
            elseif v.type == 3 then --  当需要的材料是同阵营3星时，默认按照等级低的开始选，未上阵的
                local cardS = ModelManager.CardLibModel:getStarCanChooseInfo(temp[index], heroInfo.heroDataConfiger, index) --ModelManager.CardLibModel:getCardByCategory(heroInfo.heroDataConfiger.category, {heroInfo.uuid}, temp.star, 1)
                local addNum = 0
                local info = {};
                local heroList = {}
                for _, hero in pairs(cardS) do
                    table.insert(heroList, hero)
                end
                table.sort(heroList, function(a, b)
                    return a.level < b.level
                end)
                -- for _, hero in ipairs(heroList) do
                --     LuaLogE("index:3  ".."heroId:"..hero.heroId.."  level:"..hero.level)
                -- end
                for _, hero in ipairs(heroList) do
                    if not hero.locked and hero.star == v.star and #(BattleModel:getArrayTypes(hero.uuid)) == 0 and not ModelManager.HeroPalaceModel:isInHeroPalace(hero.uuid) then -- 未上阵、未锁定
                        addNum = addNum + 1
                        table.insert(info, hero)
                        if addNum >= v.num then
                            break
                        end
                    end
                end
                if (info) then
                    ModelManager.CardLibModel:addCurCardStarUpChoose(index, info);
                end
            end
        end
    else
    	for index,v in ipairs(temp) do
    		--当需要的材料是本尊时,有一个一级的，帮他选中了
    		if v.type == 1 then
    			local cardS = ModelManager.CardLibModel:getStarCanChooseInfo(temp[index], heroInfo.heroDataConfiger, index) --ModelManager.CardLibModel:getCardByCategory(heroInfo.heroDataConfiger.category, {heroInfo.uuid}, temp.star, 1)
    			local addNum = 0
    			local info = {};
    			for _,hero in ipairs(cardS) do
    				if not hero.locked and hero.star == v.star and hero.level == 1 and  #(BattleModel:getArrayTypes(hero.uuid)) == 0 and not ModelManager.HeroPalaceModel:isInHeroPalace(hero.uuid) then
    					addNum = addNum + 1
    					table.insert(info, hero)
    					if addNum >= v.num then
    						break
    					end
    				end
                end
                if (info) then
                    ModelManager.CardLibModel:addCurCardStarUpChoose(index, info);
                end
    		end
    	end
    end
    self:setUpStarMaterials(temp, heroInfo.code)
end

function CardInfoStarUpView:cardView_starUpChoose(_, data)
    local heroInfo = ModelManager.CardLibModel.curCardStepInfo
    local temp, cost = ModelManager.CardLibModel:getUpStarMaterials(heroInfo.code, heroInfo.star)
    self:setUpStarMaterials(temp, heroInfo.code)
end

--设置卡牌属性名展示
function CardInfoStarUpView:setUpStarMaterials(temp, heroId)
    local info = DynamicConfigData.t_hero
    local heroItem = info[heroId]
    self.listMaterials:setItemRenderer(
        function(index, obj)
			obj:getController("c1"):setSelectedIndex(1)
            obj:removeClickListener()
            --池子里面原来的事件注销掉
            obj:addClickListener(
                function(context)
                    local materials = temp[index + 1]
					local chooseList = ModelManager.CardLibModel:getStarCanChooseInfo(materials, heroItem, index + 1)
					local limitNum = materials.num
                    ModelManager.CardLibModel.lastCurCardStarUpSelectIndex = index + 1
                    ViewManager.open("CardDetailsUpStarChoose", {type = materials.type, chooseList = chooseList, num =limitNum, pos = index + 1, bQuickStarUp = false, star = materials.star})
                end
            )
            local materials = temp[index + 1]
            -- if materials.type == 1 then
                self:showSelfItem1(materials.type, obj, materials, heroItem, index + 1)
            --[[elseif materials.type == 2 then
                self:showSelfItem1(obj, materials, heroItem, index + 1)
            elseif materials.type == 3 then
            elseif materials.type == 4 then
            end--]]
        end
    )
    self.listMaterials:setNumItems(#temp)
end

function CardInfoStarUpView:showSelfItem1(type, obj, materials, heroItem, pos)
	local cardItem = BindManager.bindCardCell(obj:getChild("cardItem"))
	
	--type 1同样角色  2 同阵营同星级  3、
	local category = 0
	if type == 1 then
		local cardData = {heroStar = materials.star, heroId = heroItem.heroId}
		category = heroItem.category
		cardItem:setData(cardData, true)
		cardItem:setShowCategory(true)
	elseif type == 2 then
		local cardData = {heroStar = materials.star, heroId = heroItem.heroId}
		category = heroItem.category
		cardItem:setData(cardData, true)
		cardItem:setIcon(PathConfiger.getItemIcon(40000013))
		cardItem:setShowCategory(true)
	elseif type == 3 then
		local cardData = {heroStar = materials.star, heroId = heroItem.heroId}
		category = 0
		cardItem:setData(cardData, true)
		cardItem:setIcon(PathConfiger.getItemIcon(40000013))
		cardItem:setShowCategory(false)
	end
	--材料不足的要变灰
	local material = ModelManager.CardLibModel:getStarCanChooseInfo(materials, heroItem, pos)-- ModelManager.CardLibModel:getCardByCategory(category, {ModelManager.CardLibModel.curCardStepInfo.uuid}, materials.star, materials.level)
	if #material < materials.num then
		cardItem:setGrayed(false, true)
		cardItem:setGrayed(true, true)
	else
		cardItem:setGrayed(false, true)
	end

    --放了卡牌图片
    local txtnum = FGUIUtil.getChild(obj, "txt_num", "GTextField")
    -- local temp = ModelManager.CardLibModel.curCardStarUpChoose[pos]
    -- printTable(5, ">>>>>>>>>>>", temp)
    local num = ModelManager.CardLibModel:getStarMaterialsNum(pos)
    txtnum:setText(string.format("%s/%s", num, materials.num))
    --local gCtr2 = obj:getController("c2")
end

function CardInfoStarUpView:_exit()
    --ModelManager.CardLibModel:clearupStarInfo()
	if ModelManager.CardLibModel then
		ModelManager.CardLibModel:clearupStarInfo()
	end
end

function CardInfoStarUpView:_enter()
end

-- 20星界面
function CardInfoStarUpView:showStar20View()
    local heroInfo = ModelManager.CardLibModel.curCardStepInfo;
    local showInfo = {
        heroId = heroInfo.code,
        heroStar = 20,
        stage = 11
    }
    self.heroCell20:setData(showInfo, true)
    self.heroCell20:setLevel(false)
    local starSegment = heroInfo.starSegment and heroInfo.starSegment[heroInfo.star] or false
    local segment = starSegment and starSegment.starSegment or {};
    for i = 1, 4 do
        local starItem = self["star_"..i];
        local starLine = self["starLine_"..i];
        local s = segment[i] and segment[i].isActivate or false;
        local ctrl = starItem:getController("c1");
        local red = RedManager.getTips("V_CardStarUp_"..heroInfo.uuid.."_"..i);
        local img = starItem:getChildAutoType("img_red");
        RedManager.register("V_CardStarUp_"..heroInfo.uuid.."_"..i, starItem:getChildAutoType("img_red"));
        if (s) then
            ctrl:setSelectedIndex(1);
            starLine:setVisible(true);
        else
            ctrl:setSelectedIndex(0);
            starLine:setVisible(false);
        end
        starItem:removeClickListener();
        starItem:addClickListener(function()
            ViewManager.open("CardSegmentPreView", {hero = ModelManager.CardLibModel.curCardStepInfo, index = i});
        end)
    end
end

function CardInfoStarUpView:upBtnUpStar20()
    local heroInfo = ModelManager.CardLibModel.curCardStepInfo;
    local starSegment = heroInfo.starSegment and heroInfo.starSegment[heroInfo.star] or false
    local segment = starSegment and starSegment.starSegment or {};
    local flag = true;
    for i = 1, 4 do
        flag = segment[i] and segment[i].isActivate or false;
        if (not flag) then
            break;
        end
    end
    self.btn_upstar20:setGrayed(not flag);
    self.btn_upstar20:setTouchable(flag);
end

function CardInfoStarUpView:cardStarSegmentLevelUp_suc()
    self:showStar20View();
    self:upBtnUpStar20();
end

return CardInfoStarUpView
