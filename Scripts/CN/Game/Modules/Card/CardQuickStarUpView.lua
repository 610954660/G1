---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: 快捷升星界面
-- Date: 2020-10-15 17:48:22
---------------------------------------------------------------------

local CardQuickStarUpView = class("CardQuickStarUpView", Window)

function CardQuickStarUpView:ctor()
	self._packName = "CardSystem"
	self._compName = "CardQuickStarUpView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
	self.btn_putall = false -- 一键放入按钮
	self.btn_starup = false -- 确认/升星按钮

	self.item1 = false -- 升星材料1
	self.item2 = false -- 升星材料2
	self.item3 = false -- 升星材料3
	self.item4 = false -- 升星结果

	self.cardItem1 = false
	self.cardItem2 = false
	self.cardItem3 = false
	self.cardItem4 = false

	self.costItem = false
	self.cost_big = false
	self.frame_ = false
	self.txt_cost = false
end

function CardQuickStarUpView:_initUI()
	local viewRoot = self.view

	self.btn_putall = viewRoot:getChildAutoType("btn_putall")
	self.btn_starup = viewRoot:getChildAutoType("btn_starup")
	self.txt_desc = viewRoot:getChildAutoType("txt_desc")
	self.txt_cost = viewRoot:getChildAutoType("txt_cost")
	self.txt_desc:setText(Desc.card_chooseDesc)

	self.spine = viewRoot:getChildAutoType("spine")

	self.skeletonNode = SpineUtil.createSpineObj(self.spine,vertex2(0,0), "tanyuanshengxing", "Spine/ui/heroUpLevel", "tanyuanshengxing_texiao", "tanyuanshengxing_texiao",false,true)
	self.skeletonNode:setVisible(false)

	self.btn_putall:addClickListener(function()
		self:onClickPutAll()
	end)
	self.btn_starup:addClickListener(function()
		self:onClickStarUp()
	end)

	self.costItem = BindManager.bindCostItem(viewRoot:getChildAutoType("costItem"))
	self.cost_big = viewRoot:getChildAutoType("cost_big")
	self.frame_ = viewRoot:getChildAutoType("frame")
	-- 设置消耗
	self:setCost()

	self.heroInfo = ModelManager.CardLibModel.quickCardStarUpInfo
	-- printTable(1, "heroInfo", self.heroInfo)
	local heroItem = self.heroInfo
	local heroId = heroItem.code
	local temp, cost = ModelManager.CardLibModel:getUpStarMaterials(heroItem.code, heroItem.star)

	-- 升星材料显示
	for i = 1, 4 do
		local itemName = string.format("item%d", i)
		self[itemName] = viewRoot:getChildAutoType(itemName)
		local cardItemName = string.format("cardItem%d", i)
		self[cardItemName] = BindManager.bindCardCell(self[itemName]:getChild("cardItem"))
	end

	-- 添加点击事件
	for i = 1, 3 do
		local itemName = string.format("item%d", i)
		self[itemName]:removeClickListener() --池子里面原来的事件注销掉
        self[itemName]:addClickListener(
            function(context)
                local materials = temp[i]
				local chooseList = ModelManager.CardLibModel:getStarCanChooseInfo(materials, heroItem.heroDataConfiger, i, true)
				local limitNum = materials.num
				ViewManager.close("CardDetailsUpStarChoose")
                ViewManager.open("CardDetailsUpStarChoose", {type = materials.type, chooseList = chooseList, num =limitNum, pos = i, bQuickStarUp = true, star = materials.star})
            end
        )
	end

	self:updateView(temp)
end

-- 快速升星选择材料更新
function CardQuickStarUpView:quickStarUp_chooseChange(_, data)
	local heroItem = ModelManager.CardLibModel.quickCardStarUpInfo
	local temp, cost = ModelManager.CardLibModel:getUpStarMaterials(heroItem.code, heroItem.star)
	for i = 1, 3 do
		local materials = temp[i]
		local itemName = string.format("item%d", i)
		local txtnum = FGUIUtil.getChild(self[itemName], "txt_num", "GTextField")
	    local num = ModelManager.CardLibModel:getQuickStarUpMaterialsNum(i)
	    txtnum:setText(string.format("%s/%s", num, materials.num))
	end
end

function CardQuickStarUpView:updateView(temp)
	local heroItem = ModelManager.CardLibModel.quickCardStarUpInfo
	local temp, cost = ModelManager.CardLibModel:getUpStarMaterials(heroItem.code, heroItem.star)
	if not temp then return end
	-- 升星材料显示
	local category = 0
	for i = 1, 3 do
		local itemName = string.format("item%d", i)	
		local materials = temp[i]
		local cardData = {heroStar = materials.star, heroId = heroItem.heroId}
		if i == 1 then
			local cardItem = self.cardItem1
			cardItem:setData(cardData, true)
			cardItem:setShowCategory(true)
		elseif i == 2 then
			local cardItem = self.cardItem2
			cardItem:setData(cardData, true)
			cardItem:setIcon(PathConfiger.getItemIcon(40000013))
			cardItem:setShowCategory(true)
		elseif i == 3 then
			local cardItem = self.cardItem3
			cardItem:setData(cardData, true)
			cardItem:setIcon(PathConfiger.getItemIcon(40000013))
			cardItem:setShowCategory(false)
		end
		local ctrl = self[itemName]:getController("c1")
		ctrl:setSelectedIndex(1)
		local txtnum = FGUIUtil.getChild(self[itemName], "txt_num", "GTextField")
	    local num = ModelManager.CardLibModel:getQuickStarUpMaterialsNum(i)
	    txtnum:setText(string.format("%s/%s", num, materials.num))
	end

	-- 合成后的卡牌
	local cardData = {heroStar = heroItem.star + 1, heroId = heroItem.heroId, level = heroItem.level}
	self.cardItem4:setData(cardData, true)
	self.cardItem4:setShowCategory(true)
end

-- 一键放入按钮点击回调
function CardQuickStarUpView:onClickPutAll()
	ModelManager.CardLibModel:clearupQuickStarUpInfo()

	local bCanStarUp = true -- 是否拥有足够材料升星

	local heroItem = ModelManager.CardLibModel.quickCardStarUpInfo
	local uuid = heroItem.uuid
	local temp, cost = ModelManager.CardLibModel:getUpStarMaterials(heroItem.code, heroItem.star) -- 需要的材料
	if not temp then return end
	for i = 1, 3 do
		local cardS = ModelManager.CardLibModel:getStarCanChooseInfo(temp[i], heroItem.heroDataConfiger, i, true) -- 可选列表
		if i == 1 then -- 本体
			TableUtil.sortByMap(cardS, {{key="level", asc = false}, {key="combat", asc = false}}) -- 从低等级、低战力开始选
			local addNum = 0
			local info = {};
			for _,hero in ipairs(cardS) do
				if not hero.locked and hero.star == temp[i].star and hero.uuid ~= uuid and  #(BattleModel:getArrayTypes(hero.uuid)) == 0 and not ModelManager.HeroPalaceModel:isInHeroPalace(hero.uuid) then
					addNum = addNum + 1
					table.insert(info, hero)
					if addNum >= temp[i].num then
						break
					end
				end
            end
            if addNum < temp[i].num then
            	bCanStarUp = false
            end
            if (info) then
                ModelManager.CardLibModel:addQuickCardStarUpChoose(i, info)
            end
		elseif i == 2 then -- 同阵营同星级，优先选择同卡数量多的，然后是等级低的且未上阵
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
                return #a > #b
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
                if not hero.locked and hero.star == temp[i].star and hero.uuid ~= uuid and #(BattleModel:getArrayTypes(hero.uuid)) == 0 and not ModelManager.HeroPalaceModel:isInHeroPalace(hero.uuid) then -- 未上阵、未锁定
                    addNum = addNum + 1
                    table.insert(info, hero)
                    if addNum >= temp[i].num then
                        break
                    end
                end
            end
            if addNum < temp[i].num then
            	bCanStarUp = false
            end
            if (info) then
                ModelManager.CardLibModel:addQuickCardStarUpChoose(i, info);
            end
		elseif i == 3 then
			TableUtil.sortByMap(cardS, {{key="level", asc = false}, {key="combat", asc = false}}) -- 从低等级、低战力开始选
			local addNum = 0
			local info = {};
			for _,hero in ipairs(cardS) do
				if not hero.locked and hero.uuid ~= uuid and #(BattleModel:getArrayTypes(hero.uuid)) == 0 and not ModelManager.HeroPalaceModel:isInHeroPalace(hero.uuid) then
					addNum = addNum + 1
					table.insert(info, hero)
					if addNum >= temp[i].num then
						break
					end
				end
            end
            if addNum < temp[i].num then
            	bCanStarUp = false
            end
            if (info) then
                ModelManager.CardLibModel:addQuickCardStarUpChoose(i, info)
            end
		end
	end
	Dispatcher.dispatchEvent("quickStarUp_chooseChange")
	if not bCanStarUp then
		RollTips.show(Desc.card_notEnoughAgent)
	end
end

-- 设置消耗
function CardQuickStarUpView:setCost()
	local heroInfo = ModelManager.CardLibModel.quickCardStarUpInfo
	local info = DynamicConfigData.t_hero
    local starRuleId = info[heroInfo.code].starRule
    local starInfo = DynamicConfigData.t_heroStar
    local starData = starInfo[starRuleId]
    if not starData then
        return
    end
    local starItem = starData[heroInfo.star]
    if not starItem then
        return
    end
	self.costItem:setData(CodeType.MONEY, 1, starItem.material[1].amount, false)

	-- 居中self.cost_big
	local pos = self.cost_big:getPosition()
	local size = self.cost_big:getSize()
	local txt_pos = self.txt_cost:getPosition()
	local costItem_pos = self.costItem.view:getPosition()
	local costItem_size = self.costItem.view:getSize()
	size.width = costItem_pos.x + costItem_size.width - txt_pos.x
	local frame_size = self.frame_:getSize()
	local mid_pos = Vector2(frame_size.width / 2, 0)
	mid_pos = self.frame_:localToGlobal(mid_pos)
	mid_pos = self.cost_big:getParent():globalToLocal(mid_pos)
	self.cost_big:setPosition(mid_pos.x - size.width / 2, pos.y)
end

-- 确认按钮点击回调
function CardQuickStarUpView:onClickStarUp()
	local bCanStarUp = true -- 是否拥有足够材料升星

	local heroItem = ModelManager.CardLibModel.quickCardStarUpInfo
	local temp, cost = ModelManager.CardLibModel:getUpStarMaterials(heroItem.code, heroItem.star)
	for i = 1, 3 do
		local materials = temp[i]
	    local num = ModelManager.CardLibModel:getQuickStarUpMaterialsNum(i)
	    if num < materials.num then
	    	bCanStarUp = false
	    	break
	    end
	end

	if not bCanStarUp then
		RollTips.show(Desc.card_notEnoughAgent)
		return
	end
	-- 请求升星
    local heroInfo = ModelManager.CardLibModel.quickCardStarUpInfo
    local uidList = {}
    local starItem = {}
    local temp = ModelManager.CardLibModel.quickCardStarUpChoose
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
	self.skeletonNode:setVisible(true)
	self.skeletonNode:setAnimation(0,"tanyuanshengxing",false)
	self.skeletonNode:setCompleteListener(function(name)
		if name == "tanyuanshengxing" then
			self.skeletonNode:setVisible(false)
			 ModelManager.CardLibModel:heroStarLevelUp(heroInfo.uuid, uidList, starItem, true,heroItem.star, heroItem.star + 1)
		end
	end)
end

function CardQuickStarUpView:_exit()
	-- Dispatcher.dispatchEvent(EventType.cardView_starUpChoose);

	if ModelManager.CardLibModel.bOpenCardChooseView == false then
		Scheduler.scheduleNextFrame(function()
		-- 打开之前的升星材料选择界面
			local index = ModelManager.CardLibModel.lastCurCardStarUpSelectIndex
			local heroInfo = ModelManager.CardLibModel.curCardStepInfo
			local temp = ModelManager.CardLibModel:getUpStarMaterials(heroInfo.code, heroInfo.star)
			local heroId = heroInfo.code
			local info = DynamicConfigData.t_hero
		    local heroItem = info[heroId]
		    local materials = temp[index]
			local chooseList = ModelManager.CardLibModel:getStarCanChooseInfo(materials, heroItem, index, true)
			local limitNum = materials.num
		    -- ModelManager.CardLibModel.lastCurCardStarUpSelectIndex = index
		    ViewManager.close("CardDetailsUpStarChoose")
		    ViewManager.open("CardDetailsUpStarChoose", {type = materials.type, chooseList = chooseList, num = limitNum, pos = index, bQuickStarUp = true, star = materials.star})
		end)
	end
	Dispatcher.dispatchEvent("CardQuickStarUpView_close");
end


function CardQuickStarUpView:_enter()

end

return CardQuickStarUpView