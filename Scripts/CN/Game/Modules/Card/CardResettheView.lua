---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by:
-- Date: 卡牌转换
---------------------------------------------------------------------
local CardResettheView, Super = class("CardResettheView", Window)

function CardResettheView:ctor(args)
    self._packName = "CardSystem"
    self._compName = "CardResettheView"
    self._rootDepth = LayerDepth.PopWindow
    self.curcategory = 0
    self.curItem = false
end

function CardResettheView:_initUI()
    local viewRoot = self.view
    self.img_hero1 = viewRoot:getChild("img_hero1")
    self.img_hero2 = viewRoot:getChild("img_hero2")
    self.com_mater = viewRoot:getChild("com_mater")
    self.selectList = viewRoot:getChild("selectList")
    self.costItem1 = viewRoot:getChild("costItem1")
    self.costItem2 = viewRoot:getChild("costItem2")
    self.btn_zhihuan = viewRoot:getChild("btn_zhihuan")
    self.c1 = self.view:getController("c1") --有材料无材料
    self.c2 = viewRoot:getController("c2")
    self.c3 = self.com_mater:getController("c2") --有材料无材料
    self._materTextNum = self.com_mater:getChild("txt_num")

    local categoryChoose = viewRoot:getChild("categoryChoose")
    local category=  categoryChoose:getController("category")
    for i = 0, 5, 1 do
        local btn = categoryChoose:getChild("category" .. i)
        btn:addClickListener(
            function()
                self.curcategory = 1
                self:setCardsByCategory(i)
                category:setSelectedIndex(i)
            end
        )
    end
    self:setBg("heroResetBg.jpg")
    self:setCardsByCategory(0)
    category:setSelectedIndex(0)
    self:showHeroPic()
end

function CardResettheView:setCardsByCategory(Category)
    ModelManager.CardLibModel:setCardResetInfo(Category)
    self.tempInfo = ModelManager.CardLibModel:getCardResetInfo()
    local ctr = #self.tempInfo > 0 and 0 or 1
    self.c1:setSelectedIndex(ctr)
    self:setCardList()
end

--绑定事件
function CardResettheView:setCardList()
    local battle = ModelManager.BattleModel:getArrayInfo()
    local hasBattle = false
    if battle then
        hasBattle = battle.array
    end
    self.selectList:setVirtual()
    self.selectList:setItemRenderer(
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
            local chooseCtr = obj:getController("c1")
            local temp = CardLibModel:getCardResetChooseA()
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
    self.selectList:setNumItems(#self.tempInfo)
end

function CardResettheView:setChoose(obj, materials)
    local battle = ModelManager.BattleModel:getArrayInfo()
    local hasBattle = false
    if battle then
        hasBattle = battle.array
    end
    local chooseCtr = obj:getController("c1")

    local isLock = materials.locked
    local heroPalace = ModelManager.HeroPalaceModel:isInHeroPalace(materials.uuid)
    if isLock then
        RollTips.show(Desc.card_isInLock)
        return
    end

    if heroPalace then
        RollTips.show(DescAuto[50]) -- [50]="共生殿升级状态不可置换"
        return
    end
    if hasBattle and hasBattle[materials.uuid] ~= nil then
        chooseCtr:setSelectedIndex(4)
        local arrayType = ModelManager.BattleModel:getArrayType(materials.uuid)
        local battleFunName = Desc["common_arrayType" .. arrayType]
        local info = {}
        --info.text = string.format(Desc.card_decomposeIsInBattle, battleFunName, self.funcStr)
		info.text = Desc.card_isInBattle
        info.type = "yes_no"
        info.mask = true
        info.onYes = function()
            ModelManager.CardLibModel:doQuitBattle(
                arrayType,
                materials.uuid,
                function()
                    self:setCardList()
                end
            )
        end
        Alert.show(info)
        return
    end
    local temp = CardLibModel:getCardResetChooseA()
    if temp and temp.uuid ~= materials.uuid then
            CardLibModel:clearCardResetChooseA()
            CardLibModel:clearCardResetmateriChoose()
            if self.curItem then
                self.curItem:getController("c1"):setSelectedIndex(1)
            end
            temp = CardLibModel:getCardResetChooseA()
    end
    self.curItem = obj
    if temp == false then
        temp = materials
        chooseCtr:setSelectedIndex(2)
    else
        temp = false
        chooseCtr:setSelectedIndex(1)
    end
    ModelManager.CardLibModel.cardResetChooseA = temp
    self:showHeroPic()
end

function CardResettheView:showHeroPic()
    local heroinfo = ModelManager.CardLibModel.cardResetChooseA
     --有卡牌A
    if heroinfo then
        local curNum = CardLibModel:getCardResetmateriChooseNum()
        if curNum > 0 then --有选择材料
            local materInfo = CardLibModel:getCarResetmateriChooseItemInfo()
            local materobj = self.com_mater:getChild("cardItem")
            local cardcell = BindManager.bindCardCell(materobj)
            cardcell:setCardNameVis(false)
            cardcell:setData(materInfo, true)
            cardcell:setLevel(false)
            local carB = {}
            for key, value in pairs(materInfo) do
                carB[key] = value
                if key == "star" then
                    carB[key] = heroinfo.star
                elseif key == "step" then
                    carB[key] = heroinfo.step
                elseif key == "level" then
                    carB[key] = heroinfo.level
                end
            end
            local hero2 = BindManager.bindCardCell(self.img_hero2)
            hero2:setData(carB)
            self.c2:setSelectedIndex(2)
            self.c3:setSelectedIndex(0)
        else
            self.c2:setSelectedIndex(1)
            self.c3:setSelectedIndex(2)
        end
        local heroA = BindManager.bindCardCell(self.img_hero1)
        heroA:setData(heroinfo)
        local cardNum = DynamicConfigData.t_HighStarExchange[heroinfo.star].cardNum
        local color = "#6AFF60"
        if curNum < cardNum then
            color = "#F43636"
        end
        self._materTextNum:setText(ColorUtil.formatColorString1(string.format("%s/%s", curNum, cardNum), color))
        local cost = DynamicConfigData.t_HighStarExchange[heroinfo.star].exchangeCost
        for i = 1, #cost, 1 do
            local costItem = cost[i]
            -- 消耗的物品
            local costItem1 = BindManager.bindCostItem(self["costItem" .. i])
            costItem1:setData(costItem.type, costItem.code, costItem.amount, true)
        end
    else
        self.c3:setSelectedIndex(1)
        self.c2:setSelectedIndex(0)
     --无卡牌A
    end
end

function CardResettheView:_initEvent()
    self.com_mater:addClickListener(
        function(...)
            local heroinfo = ModelManager.CardLibModel.cardResetChooseA
            if heroinfo then
                local code = heroinfo.code
                local cardNum = DynamicConfigData.t_HighStarExchange[heroinfo.star].cardNum
                ViewManager.open("CardResettheChooseView", {code = code, cardNum = cardNum})
            else
                RollTips.show(DescAuto[51]) -- [51]="请先放置置换卡牌"
            end
        end
    )

    self.btn_zhihuan:addClickListener(
        function(...)
            local heroinfo = ModelManager.CardLibModel.cardResetChooseA
            if heroinfo then
                local chooseArr = CardLibModel:getCardResetmateriChoose()
                local cailiaoArr = {}
                for key, value in pairs(chooseArr) do
                    cailiaoArr[#cailiaoArr + 1] = key
                end
                CardLibModel:HeroChangeStartChange(heroinfo.uuid, cailiaoArr)
            else
                RollTips.show(DescAuto[52]) -- [52]="请选择置换探员材料"
            end
        end
    )
end

function CardResettheView:cardView_ResetTheViewClear()
    CardLibModel:clearCardResetAllData()
    self:setCardsByCategory(self.curcategory)
    self:showHeroPic()
end

function CardResettheView:cardView_ResetTheChooseUp()
    self:showHeroPic()
end

function CardResettheView:_exit()
    self.curcategory = 1
    CardLibModel:clearCardResetAllData()
end

return CardResettheView
