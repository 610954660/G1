local HeroUpStarView, Super = class("HeroUpStarView", Window)
function HeroUpStarView:ctor()
    self._packName = "DetectiveAgency"
    self._compName = "HeroUpStarView"
	self.__reloadPacket = true
	self.cardStar1 = false
    self.cardStar2 = false
    self.txtlevel = false
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
	self.costItem = false
	self.heroItemList = {}
	self.categoryIndex = 0
	self.categoryItems = {}
end

function HeroUpStarView:_initUI()
	
	ModelManager.CardLibModel:clearupStarInfo()
	local upStarView = self.view
    local cardStar1 = upStarView:getChildAutoType("cardStar1")
    local cardStar2 = upStarView:getChildAutoType("cardStar2")
	self.cardStar1 = BindManager.bindCardStar(cardStar1)
	self.cardStar2 = BindManager.bindCardStar(cardStar2)
    self.txtlevel = upStarView:getChildAutoType("txt_level")
    self.txtNextlevel = upStarView:getChildAutoType("txt_nextlevel")
    self.txtAttrdian = upStarView:getChildAutoType("txt_attrdian")
    self.txt_attrdianNum = upStarView:getChildAutoType("txt_attrdianNum")
    self.txtNextattrdian = upStarView:getChildAutoType("txt_nextattrdian")
    self.sendUpStar = upStarView:getChildAutoType("btn_star")
    self.starCloseButton = upStarView:getChildAutoType("starCloseButton")
    self.listMaterials = upStarView:getChildAutoType("list_materials")
    self.btn_matPoint = upStarView:getChildAutoType("btn_matPoint")
    self.viewCtrl = upStarView:getController("levelState")
    self.btn_upStarPreHelp = upStarView:getChildAutoType("btn_upStarPreHelp")
    self.costItem = BindManager.bindCostBar(upStarView:getChildAutoType("costItem"))
	self.heroGlist = upStarView:getChildAutoType("heroList")
	self.heroGlist:setItemRenderer(handler(self,self.heroGlistHandle))
	self.heroPanel = self.view:getChildAutoType("heroPanel")
	self.maxStr = self.view:getChildAutoType("maxStr")
	self.frame = self.view:getChildAutoType("frame")
	self.closeBtn = self.frame:getChildAutoType("closeButton")
	self.combatStr = self.view:getChildAutoType("txt_power")
	self.playerIcon = self.view:getChildAutoType("playerIcon")
	self.cardItem = self.view:getChildAutoType("cardItem")
	self.bg = self.view:getChildAutoType("bg")
	self.bg:setIcon(PathConfiger.getBg("HeroUpBg.jpg"))

	self.playerIcon = self.playerIcon:displayObject()
	self.txt_category = upStarView:getChildAutoType("txt_category")
    self.loader_category = upStarView:getChildAutoType("loader_category")
    self.txt_career = upStarView:getChildAutoType("txt_career")
    self.loader_career = upStarView:getChildAutoType("loader_career")


	self.help_btn = self.view:getChildAutoType("help_btn")
	self.help_btn:addClickListener(function()
		local info={}
	    info['title']=Desc["HeroUpStarTitle"]
	    info['desc']=Desc["HeroUpStarDesc"]
	    ViewManager.open("GetPublicHelpView",info) 
	end)
	for i = 1,4 do
		self["topBtn"..i] = self.view:getChildAutoType("topBtn"..i)
		self["topBtn"..i]:getController("select"):setSelectedIndex(0)
		self["topBtn"..i]:addClickListener(function()
			for j = 1,4 do
				self["topBtn"..j]:getController("select"):setSelectedIndex(0)
			end
			self["topBtn"..i]:getController("select"):setSelectedIndex(1)
			self.starIndex = i
			self:onSelectSortRule()
		end)
	end
	self["topBtn1"]:getController("select"):setSelectedIndex(1)
	self.name = self.view:getChildAutoType("name_txt")
	self.closeBtn:addClickListener(function()
		self:closeView()
	end)
	self.sendUpStar:addClickListener(
        function(context)
            local heroInfo = self.curHeroInfo
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
			--local curAllAttr= ModelManager.CardLibModel:getCardAllAttrInfo(heroInfo,heroInfo.level,curStage,curStar);
			--local nextAllAttr= ModelManager.CardLibModel:getCardAllAttrInfo(heroInfo,heroInfo.level,nextStage,nextStar);
			--local attrs = heroInfo.attrs
            ModelManager.CardLibModel:heroStarLevelUp(heroInfo.uuid, uidList, starItem,false,curStar,nextStar)
        end
    )
	
	self.categoryList = self.view:getChildAutoType("categoryList")
	self.categoryList:setItemRenderer(function (index,item)
		item:setIcon(PathConfiger.getCardSmallCategory(index))
		item:setSelected(false)
		item:addEventListener(FUIEventType.Click,function (context)
			self.categoryIndex = index
			self:onSelectSortRule()
			for key,value in pairs(self.categoryItems) do
				value:setSelected(false)
			end
			item:setSelected(true)
		end,101)
		table.insert(self.categoryItems,item)
	end)
	self.categoryList:setNumItems(6)
	self.categoryItems[1]:setSelected(true)
	self.curHeroInfo = false
	self.btn_matPoint:addClickListener(
        function(context)
			ViewManager.open("MatchPointView", self.curHeroInfo)
        end
    )
	self.heroGlist:setVirtual()
	self.categoryIndex = 0
	self.starIndex = 1
	self:onSelectSortRule()
end

function HeroUpStarView:upDataHeroList()
	if self.curHeroInfo then
		ModelManager.CardLibModel:setChooseUid(self.curHeroInfo.uuid)
		local skeletonNode = SpineMnange.createSprineById(self.curHeroInfo.heroId,true)
		skeletonNode:setAnimation(0, "stand", true);
		self.playerIcon:removeAllChildren()
		self.playerIcon:addChild(skeletonNode)
		self:updateInfo()
		self.heroPanel:setVisible(true)
		self.playerIcon:setVisible(true)
		self.maxStr:setVisible(true)
	else
		self.heroPanel:setVisible(false)
		self.playerIcon:setVisible(false)
	end
end

function HeroUpStarView:refrushGlistData()
	local StarRule = {{1,2,3,4,5},{2},{3,5},{1,4}}--升星规则
	local cardList = {}
	local list = {}
	for key,heroInfo in pairs(ModelManager.CardLibModel:getAllCards()) do
		local info = DynamicConfigData.t_hero
		local starRuleId = info[heroInfo.code].starRule
		local starInfo = DynamicConfigData.t_heroStar
		local starData = starInfo[starRuleId]
		local state = false
		local categoryState = false
		for key,value in pairs(StarRule[self.starIndex]) do
			if starRuleId == value then
				state = true
			end
		end
		if self.categoryIndex == heroInfo.heroDataConfiger.category or self.categoryIndex == 0 then
			categoryState = true
		end
		local cTab = cardList[tostring(heroInfo.heroId) .."_" ..tostring(heroInfo.star)]
		if heroInfo.star < 19 and categoryState and state and starData and starData[heroInfo.star] and (cTab == nil or heroInfo.level > cTab.level) then
			local temp,cost = ModelManager.CardLibModel:getUpStarMaterials(heroInfo.code, heroInfo.star)
			local num = 0
			local needNum = 0
			pcall(function()
				local info = DynamicConfigData.t_hero
				local heroItem = info[heroInfo.heroId]
				if temp then
					for key,value in pairs(temp) do
						num = num + value.num
					end
					local nlist = {}
					for key,v in pairs(temp) do
						local cardS = ModelManager.CardLibModel:getStarCanChooseInfo(v,heroItem,key,true,heroInfo) --ModelManager.CardLibModel:getCardByCategory(heroInfo.heroDataConfiger.category, {heroInfo.uuid}, temp.star, 1)
						nlist[key] = cardS
					end
					local newList = {}
					local nkey = {}
					for key,value in pairs(nlist) do
						if nkey[key] == nil then nkey[key] = 0 end
						for k,v in pairs(value) do
							if v.uuid then
								if newList[tostring(v.uuid) .. tostring(v.star)] == nil and nkey[key] < temp[key].num then
									newList[tostring(v.uuid) .. tostring(v.star)] = key
									nkey[key] = nkey[key] + 1
								end
							elseif v.type == GameDef.GameResType.Item and nkey[key] < temp[key].num then
								if newList[v.idx] == nil then
									newList[v.idx] = key
									nkey[key] = nkey[key] + 1
								end
							end
						end	
					end
					local numList = {}
					for key,value in pairs(newList) do
						if numList[value] == nil then
							numList[value] = {}
						end
						table.insert(numList[value],key)
					end
					for key,value in pairs(numList) do
						local val = 0
						for l,m in pairs(value) do
							val = val + 1
						end
						if val >= temp[key].num then
							val = temp[key].num
						end
						needNum = needNum + val
					end
	--				heroInfo.logList = numList
				end
			end)
			heroInfo.num = num 
			heroInfo.needNum = needNum
			cardList[tostring(heroInfo.heroId) .."_" ..tostring(heroInfo.star)] = heroInfo
		end
	end
	for key,value in pairs(cardList) do
		table.insert(list,value)
	end
	table.sort(list,function(a,b)
		if (a.needNum + 1) / (a.num + 1) == (b.needNum + 1) / (b.num + 1) then
			if a.star == b.star then
				return a.heroId < b.heroId 
			else
				return a.star < b.star
			end
		else
			return (a.needNum + 1) / (a.num + 1)> (b.needNum + 1) / (b.num + 1)
		end
	end)
	return list
end
function HeroUpStarView:onSelectSortRule(lastInfo)
	self.heroItemList = {}
	self._cardcgInfo = self:refrushGlistData()
	local index = 0
	for key,item in pairs(self.categoryItems) do
		RedManager.register("V_HERO_LVELEUP_CATEGORY"..index.. "_" .. self.starIndex,item:getChildAutoType("img_red"))
		index = index + 1
	end
	if not lastInfo then
		self.curHeroInfo = self._cardcgInfo[1] or false
		ModelManager.CardLibModel.curCardStepInfo = self.curHeroInfo
		self.heroGlist:scrollToView(0,false,false)
	else
		local index = 0
		for key,value in pairs(self._cardcgInfo) do
			if value.uuid == lastInfo.uuid then
				index = key
			end
		end
		if index == 0 then--升星之后英雄没了
			self.curHeroInfo = self._cardcgInfo[1] or false
			ModelManager.CardLibModel.curCardStepInfo = self.curHeroInfo
			self.heroGlist:scrollToView(1,false,false)
		else
			if index % 4 == 0 then
				index = index - 1
			end
			if index < 0 or index > table.nums(self._cardcgInfo) then
				index = 0
			end
			self.heroGlist:scrollToView(index,false,false)
		end
	end
	self.heroGlist:setData(self._cardcgInfo)
	self:upDataHeroList()
end
function HeroUpStarView:heroGlistHandle(index,obj)
	local dataInfo = self._cardcgInfo[index + 1]
	if not dataInfo then return end
	dataInfo.index = index + 1
	local obj1 = obj:getChildAutoType("playerCell")
	local heroCell = BindManager.bindHeroCell(obj1)
	local showData = {}
	showData.code = dataInfo.heroId
	showData.level = dataInfo.level
	showData.star = dataInfo.star
	showData.category = dataInfo.heroDataConfiger.category
	heroCell:setData(showData)
	obj:removeClickListener(99)
	obj:addClickListener(function()
		local info = DynamicConfigData.t_hero
		local starRuleId = info[dataInfo.code].starRule
		if self.curHeroInfo == dataInfo then return end
		for key,value in pairs(self.heroItemList) do
			value:getController("selected"):setSelectedIndex(0)
		end
		obj:getController("selected"):setSelectedIndex(1)
		self.curHeroInfo = dataInfo or false
		ModelManager.CardLibModel.curCardStepInfo = self.curHeroInfo
		self:upDataHeroList()
		self:updateInfo()
	end,99)
	obj:getController("selected"):setSelectedIndex(self.curHeroInfo == dataInfo and 1 or 0)
	self.heroItemList[dataInfo.uuid] = obj
	local progressBar = obj:getChildAutoType("progressBar")
	progressBar:setMax(dataInfo.num + 1)
	progressBar:setValue(dataInfo.needNum + 1)
	RedManager.register("V_HERO_LVELEUP"..dataInfo.uuid,obj:getChildAutoType("img_red"))
end
function HeroUpStarView:_initEvent()
    self.btn_upStarPreHelp:addClickListener(--升星预览
        function(context)
			ViewManager.open("CardUpstarPreview")
        end
    )
end
function HeroUpStarView:HeroTotems_AllTotemsInfo()
	self:_refresh()
end
function HeroUpStarView:_refresh()
	self:onSelectSortRule(self.curHeroInfo)
end

function HeroUpStarView:cardView_updateInfo(_, data)
--	self:onSelectSortRule(self.curHeroInfo)
end

function HeroUpStarView:cardView_starUpSuc(_, data)
--	self:onSelectSortRule(self.curHeroInfo)
end
function HeroUpStarView:updateInfo(data)
	ModelManager.CardLibModel:clearupStarInfo()
    local HeroInfo = self.curHeroInfo
    if not HeroInfo then
        return
    end
    if data and data.heroUid and data.heroUid  == HeroInfo.uuid then
        ModelManager.CardLibModel:clearupStarInfo()
    end
	if data and data.hero then
		self.heroItemList[data.hero.uuid]:setStar(data.hero.star)
	end
    self.heroId = HeroInfo.heroId
    self.uuid = HeroInfo.uuid
    self:updateHeroInfo(HeroInfo)
end

--更新卡牌详情信息
function HeroUpStarView:updateHeroInfo(HeroInfo)
    self.heroInfo = HeroInfo
    self:showStar()
end

--设置卡牌等级阶级信息
function HeroUpStarView:showStar()
    local heroInfo = self.curHeroInfo
    local limitLv = ModelManager.CardLibModel:getHeroCardStarlv(heroInfo.star)
    local nextlimitLv = ModelManager.CardLibModel:getHeroCardStarlv(heroInfo.star + 1)
    self.txtlevel:setText(limitLv)
    self.txtNextlevel:setText(nextlimitLv)
    local attrNum = heroInfo.attrPointNum
    self.txtAttrdian:setText(Desc.card_DetailsStr8)
    self.txt_attrdianNum:setText(attrNum)
   
    local cardItem = BindManager.bindCardCell(self.cardItem)
	local cardData = {heroStar = heroInfo.star, heroId = heroInfo.heroId}
	cardItem:setData(cardData, true)
	cardItem:setShowCategory(true)
	self.loader_category:setURL(PathConfiger.getCardCategoryColor(heroInfo.heroDataConfiger.category))
	self.loader_career:setURL(PathConfiger.getCardProfessional(heroInfo.heroDataConfiger.professional))
	self.name:setText(heroInfo.heroDataConfiger.heroName)
	self.combatStr:setText(StringUtil.transValue(heroInfo.combat))
    --设置卡牌的星级
	self.cardStar1:setData(heroInfo.star)
	self.cardStar2:setData(heroInfo.star + 1)

    local info = DynamicConfigData.t_hero
    local starRuleId = info[heroInfo.code].starRule
    local starInfo = DynamicConfigData.t_heroStar
    local starData = starInfo[starRuleId]
    if not starData then
--		self:onSelectSortRule()
		self.viewCtrl:setSelectedIndex(1)
        return -- body
    end
    local starItem = starData[heroInfo.star]
    if not starItem then
--		self:onSelectSortRule()
		self.viewCtrl:setSelectedIndex(1)
        return;
    end
	self.viewCtrl:setSelectedIndex(0)
	self.costItem:setData(starItem.material)
    local temp, cost = ModelManager.CardLibModel:getUpStarMaterials(heroInfo.code, heroInfo.star)
    if heroInfo.star == 4 then -- 4星升5星
        for index,v in ipairs(temp) do
            --当需要的材料是本尊时,默认选择等级低的，且未上阵
            if v.type == 1 then
                local cardS = ModelManager.CardLibModel:getStarCanChooseInfo(temp[index], heroInfo.heroDataConfiger, index, false) --ModelManager.CardLibModel:getCardByCategory(heroInfo.heroDataConfiger.category, {heroInfo.uuid}, temp.star, 1)
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
                local cardS = ModelManager.CardLibModel:getStarCanChooseInfo(temp[index], heroInfo.heroDataConfiger, index, false) --ModelManager.CardLibModel:getCardByCategory(heroInfo.heroDataConfiger.category, {heroInfo.uuid}, temp.star, 1)
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
                local cardS = ModelManager.CardLibModel:getStarCanChooseInfo(temp[index], heroInfo.heroDataConfiger, index, false) --ModelManager.CardLibModel:getCardByCategory(heroInfo.heroDataConfiger.category, {heroInfo.uuid}, temp.star, 1)
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
            end
        end
    else
    	for index,v in ipairs(temp) do
    		--当需要的材料是本尊时,有一个一级的，帮他选中了
    		if v.type == 1 then
    			local cardS = ModelManager.CardLibModel:getStarCanChooseInfo(temp[index], heroInfo.heroDataConfiger, index, false) --ModelManager.CardLibModel:getCardByCategory(heroInfo.heroDataConfiger.category, {heroInfo.uuid}, temp.star, 1)
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

function HeroUpStarView:cardView_starUpChoose(_, data)
    local heroInfo = self.curHeroInfo
    local temp, cost = ModelManager.CardLibModel:getUpStarMaterials(heroInfo.code, heroInfo.star)
    self:setUpStarMaterials(temp, heroInfo.code)
end

--设置卡牌属性名展示
function HeroUpStarView:setUpStarMaterials(temp, heroId)
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
					local chooseList = ModelManager.CardLibModel:getStarCanChooseInfo(materials, heroItem, index + 1, false)
					local limitNum = materials.num
                    ModelManager.CardLibModel.lastCurCardStarUpSelectIndex = index + 1
                    ViewManager.open("CardDetailsUpStarChoose", {heroInfo = self.curHeroInfo, type = materials.type, chooseList = chooseList, num =limitNum, pos = index + 1, bQuickStarUp = false, star = materials.star})
                end
            )
            local materials = temp[index + 1]
            self:showSelfItem1(materials.type, obj, materials, heroItem, index + 1)
        end
    )
    self.listMaterials:setNumItems(#temp)
end

function HeroUpStarView:showSelfItem1(type, obj, materials, heroItem, pos)
	local cardItem = BindManager.bindCardCell(obj:getChild("cardItem"))
	local txt_name = obj:getChildAutoType("txt_name")
	--type 1同样角色  2 同阵营同星级  3、
	local category = 0
	if type == 1 then
		local cardData = {heroStar = materials.star, heroId = heroItem.heroId}
		category = heroItem.category
		cardItem:setData(cardData, true)
		cardItem:setShowCategory(true)
		txt_name:setText(materials.star..Desc.HeroUpStarDesc1..heroItem.heroName)
	elseif type == 2 then
		local cardData = {heroStar = materials.star, heroId = heroItem.heroId}
		category = heroItem.category
		cardItem:setData(cardData, true)
		cardItem:setIcon(PathConfiger.getItemIcon(40000013))
		cardItem:setShowCategory(true)
		txt_name:setText(materials.star..Desc.HeroUpStarDesc1..Desc["card_category"..category]..Desc.HeroUpStarDesc3)
	elseif type == 3 then
		local cardData = {heroStar = materials.star, heroId = heroItem.heroId}
		category = 0
		cardItem:setData(cardData, true)
		cardItem:setIcon(PathConfiger.getItemIcon(40000013))
		cardItem:setShowCategory(false)
		txt_name:setText(materials.star..Desc.HeroUpStarDesc2)
	end
	--材料不足的要变灰
	local material = ModelManager.CardLibModel:getStarCanChooseInfo(materials, heroItem, pos,false)-- ModelManager.CardLibModel:getCardByCategory(category, {self.curHeroInfo.uuid}, materials.star, materials.level)
	if #material < materials.num then
		cardItem:setGrayed(false, true)
		cardItem:setGrayed(true, true)
	else
		cardItem:setGrayed(false, true)
	end

    --放了卡牌图片
    local txtnum = FGUIUtil.getChild(obj, "txt_num", "GTextField")
    local num = ModelManager.CardLibModel:getStarMaterialsNum(pos)
    txtnum:setText(string.format("%s/%s", num, materials.num))
end

function HeroUpStarView:_exit()
	if ModelManager.CardLibModel then
		ModelManager.CardLibModel:clearupStarInfo()
	end
end
function HeroUpStarView:CardStarUpSuccessView_Close()
	if self.viewCtrl:getSelectedIndex() == 1 then
		self:onSelectSortRule()
	else
		self:onSelectSortRule(self.curHeroInfo)
	end
end
function HeroUpStarView:_enter()
end

return HeroUpStarView
