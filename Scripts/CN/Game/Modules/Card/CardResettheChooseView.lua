---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: ljj
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local CardResettheChooseView, Super = class("CardResettheChooseView", Window)

function CardResettheChooseView:ctor(args)
    self._packName = "CardSystem"
    self._compName = "cardUpstarChoose"
    self._rootDepth = LayerDepth.PopWindow
    self._curCode = false
    self._needMaxNum = false
end

function CardResettheChooseView:_initUI()
    local viewRoot = self.view
    self.btnstarchoose = viewRoot:getChildAutoType("btn_starchoose")
	self.listchoose = viewRoot:getChildAutoType("list_choose")
	self.txt_seleNum = viewRoot:getChildAutoType("txt_seleNum")
	local btns_category = viewRoot:getChildAutoType("btns_category")
    btns_category:setVisible(false)

    self._curCode = self._args.code
    self._needMaxNum = self._args.cardNum
    self:showCardList()
    self:showNumText()
end

function CardResettheChooseView:showCardList()
    local temp = CardLibModel:getCardResetmateriChooseList(self._curCode)
    self.listchoose:setVirtual()
    self.listchoose:setItemRenderer(
        function(index, obj)
            local ctrl = obj:getController("c2")
            if index == #temp then
                ctrl:setSelectedIndex(1)
                obj:removeClickListener()
                --池子里面原来的事件注销掉
                obj:addClickListener(
                    function(context)
                        ModuleUtil.openModule(ModuleId.GetCard_Senior.id)
                    end
                )
            else --=========================================== showChooseList
                local heroItem = temp[index + 1]
                local cardItem = BindManager.bindCardCell(obj:getChild("cardItem"))
                cardItem:setCardNameVis(true)
                ctrl:setSelectedIndex(0)
                cardItem:setData(heroItem, true)
                cardItem:showMask(false)

                local ctrl = obj:getChild("cardItem"):getController("c1")
                local isLock = heroItem.locked
                local heroPalace = heroItem.uuid and ModelManager.HeroPalaceModel:isInHeroPalace(heroItem.uuid) or false
                if isLock then
                    ctrl:setSelectedIndex(7)
                elseif heroPalace then
                    ctrl:setSelectedIndex(6)
                else
                    local choos = false
                    local chooseArr = CardLibModel:getCardResetmateriChoose()
                    choos = chooseArr[heroItem.uuid]
                    if choos then
                        ctrl:setSelectedIndex(2)
                    else
                        ctrl:setSelectedIndex(0)
                    end
                end
                local txtnum = obj:getChildAutoType("txt_num")
                txtnum:setVisible(false)
                obj:removeClickListener()
                --池子里面原来的事件注销掉
                obj:addClickListener(
                    function(context)
                        local materials = temp[index + 1]
                        local isLock = materials.locked
                        if isLock then
                            RollTips.show(Desc.card_isInLock)
                            return
                        end

                        local heroPalace =
                            materials.uuid and ModelManager.HeroPalaceModel:isInHeroPalace(materials.uuid) or false
                        if heroPalace then
                            RollTips.show(DescAuto[48]) -- [48]="探员处于共生殿中，需先离开共生殿才可置换"
                            return
                        end

                        local arrayTypes = BattleModel:getArrayTypes(materials.uuid)
                        if #arrayTypes > 0 then
                            local funNameStr = ""
                            for i, v in ipairs(arrayTypes) do
                                local battleFunName = Desc["common_arrayType" .. v]
                                if funNameStr == "" then
                                    if battleFunName then
                                        funNameStr = battleFunName
                                    end
                                else
                                    if i > 3 then
                                        funNameStr = funNameStr .. "" .. Desc.card_funNameMoreThen3
                                        break
                                    else
                                        if battleFunName then
                                            funNameStr = funNameStr .. ", " .. battleFunName
                                        end
                                    end
                                end
                            end

                            local info = {}
                            --info.text = string.format(Desc.card_quitBattle, funNameStr, self.funcStr)
							info.text = Desc.card_isInBattle
                            info.type = "yes_no"
                            info.mask = true
                            info.onYes = function()
                                for _, v in ipairs(arrayTypes) do
                                    ModelManager.CardLibModel:doQuitBattle(v, materials.uuid)
                                end
                            end
                            Alert.show(info)
                        else
                            local limitCount = self._needMaxNum
                            local num1 = 0
                            num1 = CardLibModel:getCardResetmateriChooseNum()
                            local cardData =CardLibModel.cardResetmateriChoose[materials.uuid]
                            if not cardData then
                                if num1 >= limitCount then
                                    RollTips.show(Desc.card_DetailsStr12)
                                else
                                    local synonym= CardLibModel:getCardResetmateriisSameName(materials)--是否是同种卡牌
                                    if not synonym then
                                        RollTips.show(DescAuto[49]) -- [49]="无法选择不一样的材料探员"
                                        cardItem:setSelected(false)
                                    else
                                        CardLibModel:setCardResetmateriChoose(materials.uuid,materials)
                                        cardItem:setSelected(true)
                                    end
                                end
                            else
								CardLibModel.cardResetmateriChoose[materials.uuid]=nil
                                cardItem:setSelected(false)
                            end
                            self:showNumText()
                        end
                    end
                )
            end
        end
    )
    self.listchoose:setNumItems(#temp + 1)
end

function CardResettheChooseView:showNumText(...)
    local curNum = CardLibModel:getCardResetmateriChooseNum()
    self.txt_seleNum:setText(string.format("%s/%s", curNum, self._needMaxNum))
end

function CardResettheChooseView:_initEvent()
    self.btnstarchoose:addClickListener(
        function(context)
            self:closeView()
            Dispatcher.dispatchEvent(EventType.cardView_ResetTheChooseUp); 
        end
    )
end

function CardResettheChooseView:_enter()
end
function CardResettheChooseView:_exit()
    Dispatcher.dispatchEvent(EventType.cardView_ResetTheChooseUp); 
end

return CardResettheChooseView
