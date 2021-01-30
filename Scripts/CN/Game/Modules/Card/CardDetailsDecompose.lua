---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by:卡牌分解
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local FGUIUtil = require "Game.Utils.FGUIUtil"
local CardDetailsDecompose, Super = class("CardDetailsDecompose", Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local ModelManager = require "Game.Managers.ModelManager"
local ItemCell = require "Game.UI.Global.ItemCell"
function CardDetailsDecompose:ctor()
    self._packName = "CardSystem"
    self._compName = "CardDecompose"
    self._btnSeleTag = 1
    self._curIdex = 0
    self._cardSetting = false
    self.cardCtro = false
    self.cardCtro1 = false
    self._cardLabelList = false
    self._listCard = false
    self._listDebris = false
    self._listreward = false
    self.tempInfo = false
    self.tempDebrisInfo = false
	self.txt_heroNum = false
	self.txt_maxNum = false
    self._AddNum = 1
end

function CardDetailsDecompose:_initUI()
	--self:setBg("handbook_hero.jpg")
    local viewRoot = self.view
    self._cardSetting = viewRoot:getChild("btn_setting")
    self.cardCtro = viewRoot:getController("c1")
    self.cardCtro1 = viewRoot:getController("c2")
--    self._cardLabelList = viewRoot:getChild("categoryList")
    self._listCard = viewRoot:getChild("list_card")
	self.txt_heroNum = viewRoot:getChildAutoType("txt_heroNum")
	self.txt_maxNum = viewRoot:getChildAutoType("txt_maxNum")
    
    self._listDebris = viewRoot:getChild("list_debris")
    
    self._listreward = viewRoot:getChild("list_reward")
    self:setCardsByCategory(0)
	
	
   --[[ self._cardLabelList:regUnscrollItemClick(
        function(index, obj)
            self._curIdex = index
            self:setCardsByCategory(index)
        end
    )--]]
	
	local categoryChoose = viewRoot:getChild("categoryChoose")
	for i = 0,5,1 do 
		local btn = categoryChoose:getChild("category"..i)
		btn:addClickListener(function ()
			self:setCardsByCategory(i)
		end)
	end
	self:setCardsByCategory(0)
	--self._cardLabelList:setSelectedIndex(0)
    self.cardCtro:setSelectedIndex(0)
    self:bindEvent()
	self:showTextNum()
end


function CardDetailsDecompose:setCardsByCategory(Category)
    ModelManager.CardLibModel:setCardDecom(Category)
    self.tempInfo = ModelManager.CardLibModel:getCardDecom()
    self:setCardList()
end

--绑定事件
function CardDetailsDecompose:setCardList()
    local battle = ModelManager.BattleModel:getArrayInfo()
    local hasBattle = false
    if battle then
        hasBattle = battle.array
    end
		
	self._listCard:setVirtual()
    self._listCard:setItemRenderer(
        function(index, obj)
			obj = obj:getChild("cardItem")
            obj:removeClickListener(100)
            --池子里面原来的事件注销掉
            obj:addClickListener(
                function(context)
                    local cardItem = self.tempInfo[index + 1]
                    self:setChoose(obj, cardItem)
                end,
                100
            )
			
			local cardcell = BindManager.bindCardCell(obj)
			cardcell:setCardNameVis(true)
			cardcell:setData(self.tempInfo[index + 1], true)
            local skillIcon = FGUIUtil.getChild(obj, "img_icon", "GLoader")
            
            local chooseCtr = obj:getController("c1")
            local temp = ModelManager.CardLibModel.cardDecomPoseDataChoose
			local isLock = self.tempInfo[index + 1].locked
			local heroPalace = ModelManager.HeroPalaceModel:isInHeroPalace(self.tempInfo[index + 1].uuid)
			if isLock then
				chooseCtr:setSelectedIndex(7)
			elseif heroPalace then
				chooseCtr:setSelectedIndex(6)
			elseif hasBattle and hasBattle[self.tempInfo[index + 1].uuid] ~= nil then
                chooseCtr:setSelectedIndex(4) 
			elseif self.tempInfo[index + 1].star > 5 then
                chooseCtr:setSelectedIndex(1)
			elseif temp[self.tempInfo[index + 1].uuid] ~= nil then
                chooseCtr:setSelectedIndex(2)
            else
                chooseCtr:setSelectedIndex(1)
            end
        end
    )
    self._listCard:setNumItems(#self.tempInfo)
end

function CardDetailsDecompose:setChoose(obj, materials)
    local battle = ModelManager.BattleModel:getArrayInfo()
    local hasBattle = false
    if battle then
        hasBattle = battle.array
    end
    local chooseCtr = obj:getController("c1")
    local temp = ModelManager.CardLibModel.cardDecomPoseDataChoose
    local uid = temp[materials.uuid]
	local isLock = materials.locked
	local heroPalace = ModelManager.HeroPalaceModel:isInHeroPalace(materials.uuid)
	if isLock then
		RollTips.show(Desc.card_isInLock)
		return
	end

	if heroPalace then
		RollTips.show(Desc.card_isInHeroPalace2)
		return
	end
	
    if hasBattle and hasBattle[materials.uuid] ~= nil then
        --RollTips.show(Desc.card_canNotUseBattleHero)
        chooseCtr:setSelectedIndex(4)
		local arrayType = ModelManager.BattleModel:getArrayType(materials.uuid)
		local battleFunName = Desc["common_arrayType"..arrayType]
		
		local info = {}
		--info.text = string.format(Desc.card_decomposeIsInBattle,battleFunName, self.funcStr )
		info.text = Desc.card_isInBattle
		info.type = "yes_no"
		--info.align = "left"
		info.mask = true
		info.onYes = function()
			ModelManager.CardLibModel:doQuitBattle(arrayType, materials.uuid, function()
				self:setCardList()
			end)
		end
		Alert.show(info)
        return
    end

    if materials.star > 5 then
        RollTips.show(Desc.card_canNotUseHeroLv6)
        chooseCtr:setSelectedIndex(1)
        return
    end

    if uid == nil then
        temp[materials.uuid] = materials.star
        chooseCtr:setSelectedIndex(2)
    else
        temp[materials.uuid] = nil
        chooseCtr:setSelectedIndex(1)
    end
    printTable(8, ">>>>>>>>打印的", temp)
    ModelManager.CardLibModel.cardDecomPoseDataChoose = temp
    self:showMaterials()
end

function CardDetailsDecompose:showMaterials()
    local list = ModelManager.CardLibModel.cardDecomPoseDataChoose
	local getHero = {}
	local getItem = {}
	local getItemMap = {}
	
	local addHero = function(heroId, star)
		table.insert(getHero, {heroId = heroId, heroStar = star, level = 1})
	end
	
	local addItem = function(type, code, amount)
		if not getItemMap[code] then
			getItemMap[code] = {type = type, code = code, amount = amount}
			table.insert(getItem, getItemMap[code])
		else
			getItemMap[code].amount = getItemMap[code].amount + amount
		end
		
	end
	
	for uuid, value in pairs(list) do
		local hero = ModelManager.CardLibModel:getHeroByUid(uuid)
		for _,v in pairs(hero.equipmentMap) do
			addItem(CodeType.ITEM, v.code, 1)
		end
		
		for _,v in pairs(hero.jewelryMap) do
			if v.code then
				addItem(CodeType.ITEM, v.code, 1)
			end
		end
			
		local starInfo =DynamicConfigData.t_heroDecompose[hero.star]
		if starInfo and starInfo.outputMaterial then
			local outputMaterial = starInfo.outputMaterial
			for k, v in pairs(outputMaterial) do
				addItem(v.type,v.code, v.amount)
			end
			
			
	
			local levelInfo= DynamicConfigData.HeroLevelAccumulationConfig[hero.level]
			if levelInfo then
				for k, v in pairs(levelInfo.costList) do
					addItem(v.type,v.code, v.amount)
				end
			end
			
			local passiveSkill = hero.passiveSkill
			if passiveSkill then
				for _,v in pairs(passiveSkill) do
					local skillInfo = DynamicConfigData.t_passiveSkill[v.id]
					for _,cost in pairs(skillInfo.activeCost) do 
						addItem(cost.type, cost.code, cost.amount)
					end
					--[[for _,cost in pairs(skillInfo.activeMoneyCost) do 
						addItem(cost.type, cost.code, cost.amount)
					end--]]
				end
			end
		end
	end

	if #getItem > 0 then
		self.cardCtro1:setSelectedIndex(1)
        self:showReward(getItem)
    else
        self.cardCtro1:setSelectedIndex(0)
    end
end

--刷新第一个分解按钮界面
function CardDetailsDecompose:cardView_DecomposeSuc()
    printTable(8, "卡牌分解请求返回刷新1")
    ModelManager.CardLibModel:clearCardDecom()
    ModelManager.CardLibModel:setCardDecom(self._curIdex)
    self.tempInfo = ModelManager.CardLibModel:getCardDecom()
    self._listCard:setNumItems(#self.tempInfo)
	self:showDebrisMaterials()
end

--刷新第一个分解按钮界面
function CardDetailsDecompose:cardView_CardAddAndDeleInfo()
    printTable(8, "卡牌分解请求返回刷新2")
    ModelManager.CardLibModel:clearCardDecom()
    ModelManager.CardLibModel:setCardDecom(self._curIdex)
    self.tempInfo = ModelManager.CardLibModel:getCardDecom()
    self._listCard:setNumItems(#self.tempInfo)
end

--刷新第二个分解按钮界面
function CardDetailsDecompose:cardView_DecomposeDebrisSuc()
    printTable(8, "卡牌碎片分解请求返回刷新")
    ModelManager.CardLibModel:clearCardDecom()
    ModelManager.CardLibModel:setCardDecom(self._curIdex)
    self.tempDebrisInfo =ModelManager.CardLibModel:getCardDebrisDecomInfo()
    --self.tempDebrisInfo = ModelManager.PackModel:getHeroCompBag():sort_bagDatas()
    self._listDebris:setNumItems(#self.tempDebrisInfo)
end

--绑定事件
function CardDetailsDecompose:bindEvent()
    local viewRoot = self.view
    local heroDecom = viewRoot:getChild("btn_heroDecom")
    heroDecom:addClickListener(
        function(context)
            if self._btnSeleTag ~= 1 then
                self._btnSeleTag = 1
                ModelManager.CardLibModel:clearCardDecom()
                ModelManager.CardLibModel:setCardDecom(self._curIdex)
                self.tempInfo = ModelManager.CardLibModel:getCardDecom()
                self._listCard:setNumItems(#self.tempInfo)
                self.cardCtro:setSelectedIndex(0)
            end
        end
    )
    local debrisDecom = viewRoot:getChild("btn_debrisDecom")
    debrisDecom:addClickListener(
        function(context)
            if self._btnSeleTag ~= 2 then
                self._btnSeleTag = 2
                ModelManager.CardLibModel:clearCardDecom()
                self.cardCtro:setSelectedIndex(1)
                self._AddNum = 1
                self.tempDebrisInfo =ModelManager.CardLibModel:getCardDebrisDecomInfo()
                --self.tempDebrisInfo = ModelManager.PackModel:getHeroCompBag():sort_bagDatas()
                self:showDebrisList()
                self:showTextNum()
            end
        end
    )

    local btn_starchoose = viewRoot:getChild("btn_starchoose")
    btn_starchoose:addClickListener(
        function(context)
            ModelManager.CardLibModel:clearCardDecom()
            local count = 0
            local battle = ModelManager.BattleModel:getArrayInfo()
            local hasBattle = false
            if battle then
                hasBattle = battle.array
            end
            for key, value in pairs(self.tempInfo) do
                printTable(8, ">>>>>>>>>>???????", value.star, hasBattle[value.uuid])
                if value.star < 4 and hasBattle and hasBattle[value.uuid] == nil then
                    count = count + 1
                    if count <= 15 then
                        ModelManager.CardLibModel.cardDecomPoseDataChoose[value.uuid] = value.star
                    end
                end
            end
            self._listCard:setNumItems(#self.tempInfo)
            self:showMaterials()
        end
    )

    local btn_nostarchoose = viewRoot:getChild("btn_nostarchoose")
    btn_nostarchoose:addClickListener(
        function(context)
            ModelManager.CardLibModel:clearCardDecom()
            self._listCard:setNumItems(#self.tempInfo)
            self:showMaterials()
        end
    )

    local btn_sendDecom = viewRoot:getChild("btn_sendDecom")
    --卡牌分解
    btn_sendDecom:addClickListener(
        function(context)
            local uidList = {}
            local hasFiveStar=false
            local temp = ModelManager.CardLibModel.cardDecomPoseDataChoose
            for k, value in pairs(temp) do
                if value>=5  then
                    hasFiveStar=true
                end
                table.insert(uidList, k)
            end
            if hasFiveStar==true then
				local arg = {
					text = Desc.card_has5StarHero,
					type = "yes_no",
					input = true,
					onYes = function()
						ModelManager.CardLibModel:heroDecompose(uidList)
					end,
				}
				Alert.show(arg)
            else
                ModelManager.CardLibModel:heroDecompose(uidList)
            end
        end
    )

    local btn_sendDecom1 = viewRoot:getChild("btn_sendDecom1")
    --碎片分解
    btn_sendDecom1:addClickListener(
        function(context)
            local itemCode = false
            local itemType = false
            local resList = {}
            local temp = ModelManager.CardLibModel.cardDecomPoseDataChoose
            for k, value in pairs(temp) do
                local resInfo = {}
                local keyInfo = string.split(k, "_")
                itemCode = keyInfo[2]
                itemType = keyInfo[1]
                resInfo["type"] = itemType
                resInfo["code"] = itemCode
                resInfo["amount"] = self._AddNum
                table.insert(resList, resInfo)
            end
            if itemCode ~= false then
                ModelManager.CardLibModel:decomposeItem(resList)
            else
                RollTips.show(DescAuto[43]) -- [43]="没有选择物品"
            end
        end
    )

    local addpoint = self.view:getChild("addpoint")
    addpoint:addClickListener(
        function(...)
            self._AddNum = self._AddNum + 1
            local temp = ModelManager.CardLibModel.cardDecomPoseDataChoose
            local maxNum = 1
            for key, value in pairs(temp) do
                maxNum = value
            end
            if self._AddNum >= maxNum then
                self._AddNum = maxNum
                RollTips.show(DescAuto[44]) -- [44]="达到最大数量"
            end
            self:showTextNum()
            self:showDebrisMaterials()
        end
    )
    local subpoint = self.view:getChild("subpoint")
    subpoint:addClickListener(
        function(...)
            self._AddNum = self._AddNum - 1
            if self._AddNum <= 1 then
                self._AddNum = 1
                RollTips.show(DescAuto[45]) -- [45]="达到最小数量"
            end
            self:showTextNum()
            self:showDebrisMaterials()
        end
    )

    self._cardSetting:addClickListener(
        function(...)
            ViewManager.open("CardDecomposeSetting")
        end
    )
end

function CardDetailsDecompose:showTextNum()
    local num = self.view:getChild("txt_num")
    num:setText(self._AddNum .. "")
	
	local cardNumber=ModelManager.CardLibModel:getActivationCardNumber();
	local cardAllNumber= 200 + VipModel:getVipPrivilige(15);
	self.txt_heroNum:setText(cardNumber)
	self.txt_maxNum:setText("/"..cardAllNumber)
end

function CardDetailsDecompose:showDebrisList()
	self._listDebris:setVirtual()
    self._listDebris:setItemRenderer(
        function(index, obj)
            obj:removeClickListener(100)
            obj:addClickListener(
                function(context)
                    local debrisItem = self.tempDebrisInfo[index + 1]
                    local list = ModelManager.CardLibModel.cardDecomPoseDataChoose
                    if list[debrisItem.__itemInfo.type .. "_" .. debrisItem.__data.code] == nil then
                        self._AddNum = 1
                        ModelManager.CardLibModel:clearCardDecom()
                    end
                    self:setDebrisChoose(obj, debrisItem)
                end,
                100
            )
            local debrisItem = self.tempDebrisInfo[index + 1]
            printTable(8, ">?????>>>", debrisItem)
            local icon = obj:getChild("icon")
            local url = ItemConfiger.getItemIconByCode(debrisItem.icon)
            icon:setURL(url)
            local num = obj:getChild("n8")
            num:setText("*" .. debrisItem.__data.amount)
            local chooseCtr = obj:getController("button")
            chooseCtr:setSelectedIndex(0)
            self.cardCtro1:setSelectedIndex(0)
        end
    )
    self._listDebris:setNumItems(#self.tempDebrisInfo)
end

function CardDetailsDecompose:setDebrisChoose(obj, materials)
    local chooseCtr = obj:getController("button")
    local temp = ModelManager.CardLibModel.cardDecomPoseDataChoose
    local uid = temp[materials.__itemInfo.type .. "_" .. materials.__data.code]
    if uid == nil then
        chooseCtr:setSelectedIndex(1)
        temp[materials.__itemInfo.type .. "_" .. materials.__data.code] = materials.__data.amount
    else
        chooseCtr:setSelectedIndex(0)
        temp[materials.__itemInfo.type .. "_" .. materials.__data.code] = nil
    end
    printTable(8, "12313132123", temp)
    ModelManager.CardLibModel.cardDecomPoseDataChoose = temp
    self:showDebrisMaterials()
    self:showTextNum()
end

function CardDetailsDecompose:showDebrisMaterials()
    local list = ModelManager.CardLibModel.cardDecomPoseDataChoose
    local count = 0
    local itemId = 1
    for key, value in pairs(list) do
        count = count + 1
        local keyInfo = string.split(key, "_")
        itemId = tonumber(keyInfo[2])
        break
    end
    if count > 0 then
        self.cardCtro1:setSelectedIndex(1)
    else
        self.cardCtro1:setSelectedIndex(0)
    end
    local rewardInfo = {}
    local itemTotal = DynamicConfigData.t_item[itemId]
    if itemTotal and itemTotal.decompose then
        rewardInfo = clone(itemTotal.decompose)
        for k, v in pairs(rewardInfo) do
            local amount = rewardInfo[k].amount
            amount = amount * self._AddNum
            rewardInfo[k].amount = amount
        end
        self:showReward(rewardInfo)
    end
	
	
	
end

--绑定事件
function CardDetailsDecompose:showReward(curReward)
    self._listreward:setItemRenderer(
        function(index, obj)
            --obj:removeClickListener()
            --池子里面原来的事件注销掉
            local itemcell = BindManager.bindItemCell(obj)
            local itemData = ItemsUtil.createItemData({data = curReward[index + 1]})
            itemcell:setItemData(itemData)
        end
    )
    self._listreward:setNumItems(#curReward)
end

function CardDetailsDecompose:cardView_CardAddAndDeleInfo()
	self:showTextNum()
end

function CardDetailsDecompose:_enter()
end

function CardDetailsDecompose:_exit()
	if ModelManager.CardLibModel then
		ModelManager.CardLibModel:clearCardDecom()
	end
end

return CardDetailsDecompose
