--升星预览
local CardUpstarPreview, Super = class("CardUpstarPreview", Window)
function CardUpstarPreview:ctor(arg)
    self._packName = "CardSystem"
	self._compName = "CardUpstarPreview"
	self._rootDepth = LayerDepth.PopWindow
    self.cardItem = false
    self.txt_cardName = false
    self.txt_maxstarDesc = false
    self.list_card = false
    self.title = false
    self.txtDesc = false
    self._cardInfo = {}
end

function CardUpstarPreview:_initUI()
    local viewRoot = self.view
    self.cardItem = viewRoot:getChild("cardItem")
    self.txt_cardName = viewRoot:getChild("txt_cardName")
    self.txt_maxstarDesc = viewRoot:getChild("txt_maxstarDesc")
    self.list_card = viewRoot:getChild("list_card")
    local heroInfo = ModelManager.CardLibModel.curCardStepInfo
    local cardItem = BindManager.bindHeroCell(self.cardItem)
	cardItem:setBaseData(heroInfo)
	local configInfo=DynamicConfigData.t_hero[heroInfo.code]
	self.txt_cardName:setText(configInfo.heroName)
	--self._capSceneSprite = true
    self:showListInfo()
end

function CardUpstarPreview:showListInfo()
    local heroInfo = ModelManager.CardLibModel.curCardStepInfo
	local star = heroInfo.star
	local info = DynamicConfigData.t_hero
	local starRuleId = info[heroInfo.code].starRule
	local starInfo = DynamicConfigData.t_heroStar
	local starData = starInfo[starRuleId]
    local temp = {}
    local minStar = 1
    for key, value in pairs(starData) do
        if key >= minStar then
            minStar = key
        end
        if key >= star then
            temp[#temp + 1] = key
        end
    end
    local function cmp(a, b)
        return a < b
    end
    table.sort(temp, cmp)
    self.txt_maxstarDesc:setText(string.format(Desc.card_maxStarUpTo, minStar + 1))
    self.list_card:setItemRenderer(
        function(index, obj)
            local needStar = temp[index + 1]
            local txt_name = obj:getChild("txt_name")
            local cardStar1 = obj:getChild("cardStar1")
            local txt_pointNumber = obj:getChild("txt_pointNumber")
            local txt_levelNumber = obj:getChild("txt_levelNumber")
			local cardStar = BindManager.bindCardStar(cardStar1)
			
			txt_levelNumber:setText(ModelManager.CardLibModel:getHeroCardStarlv(needStar + 1))
			local info  = DynamicConfigData.t_heroStarPoint[needStar + 1]
			if info then
				--txt_pointNumber:setVisible(true)
				txt_pointNumber:setText("+"..info.attrPoint)
			else
				--txt_pointNumber:setVisible(false)
				txt_pointNumber:setText("+"..0)
			end
			cardStar:setData(needStar +1)
            txt_name:setText(string.format(Desc.card_starUpTo, needStar +1))
			local materialstemp, cost = ModelManager.CardLibModel:getUpStarMaterials(heroInfo.code, needStar)
			if not materialstemp then
				return
			end
            local list_materials = obj:getChild("list_materials")
            list_materials:setItemRenderer(
                function(materialsindex, obj)
                    obj:getController("c1"):setSelectedIndex(1)
                    local materials = materialstemp[materialsindex + 1]
                    self:showSelfItem1(materials.type, obj, materials, heroInfo, materialsindex + 1)
                end
            )
            list_materials:setNumItems(#materialstemp)
        end
    )
    self.list_card:setNumItems(#temp)
end

function CardUpstarPreview:showSelfItem1(type, obj, materials, heroItem, pos)
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
    -- --材料不足的要变灰
    -- local material = ModelManager.CardLibModel:getStarCanChooseInfo(materials, heroItem, pos)
    -- if #material < materials.num then
    --     cardItem:setGrayed(false, true)
    --     cardItem:setGrayed(true, true)
    -- else
    --     cardItem:setGrayed(false, true)
    -- end
    local txtnum = FGUIUtil.getChild(obj, "txt_num", "GTextField")
    --local num = ModelManager.CardLibModel:getStarMaterialsNum(pos)
    txtnum:setText(materials.num)
end

function CardUpstarPreview:_initEvent(...)
end

--initUI执行之前
function CardUpstarPreview:_enter(...)
end

--页面退出时执行
function CardUpstarPreview:_exit(...)
    print(1, "CardUpstarPreview _exit")
end

return CardUpstarPreview
