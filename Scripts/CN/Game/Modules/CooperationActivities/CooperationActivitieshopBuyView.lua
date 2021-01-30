-- added by wyz
-- 商城购买物品提示窗口

local CooperationActivitieshopBuyView = class("CooperationActivitieshopBuyView", Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器

function CooperationActivitieshopBuyView:ctor(args)
    self._packName = "CooperationActivities"
    self._compName = "CooperationActivitieshopBuyView"
    self._rootDepth = LayerDepth.PopWindow
    self.itemCell = false -- 展示的物品
    self.txt_itemName = false -- 展示的物品名字
    self.costItem1 = false -- 购买物品消耗的货币
    self.costItem2 = false -- 售价
    self.txt_buyTime = false -- 可购买的次数
    self.btn_ok = false -- 确定按钮
    self.data = {} -- 传进来的数据
    self.buyTime = false -- 可购买的次数
    self.activeTag = args.activityType or GameDef.ActivityType.WorkTogetherExchange
    self.btn_sub = false -- 减少按钮
    self.btn_add = false -- 增加按钮
    self.btn_max = false -- 最大购买数量按钮
    self.txt_num = false -- 数量展示 默认为1
end

function CooperationActivitieshopBuyView:_initUI()
    self.itemCell = self.view:getChildAutoType("itemCell")
    self.txt_itemName = self.view:getChildAutoType("txt_itemName")
    self.costItem1 = self.view:getChildAutoType("costItem1")
    self.costItem2 = self.view:getChildAutoType("costItem2")
    self.txt_buyTime = self.view:getChildAutoType("txt_buyTime")
    self.btn_ok = self.view:getChildAutoType("btn_ok")

    self.btn_add = self.view:getChildAutoType("btn_add")
    self.btn_sub = self.view:getChildAutoType("btn_sub")
    self.btn_max = self.view:getChildAutoType("btn_max")
    self.btn_min = self.view:getChildAutoType("btn_min")
    self.txt_num = self.view:getChildAutoType("txt_num")
    self.buyTimeCtrl = self.view:getController("buyTimeCtrl")

    self.data = self._args
    self:CooperationActivitieshopBuyView_upDate()
end

function CooperationActivitieshopBuyView:_initEvent()
end

function CooperationActivitieshopBuyView:CooperationActivitieshopBuyView_upDate()
    local showData = self.data.showData
    local buyTime = self.data.buyTime
    local getRes = showData.getRes -- 展示的物品信息
    local costRes = showData.costRes -- 消耗的物品信息
    local timesCtrl = self.view:getController("timesCtrl")
    timesCtrl:setSelectedIndex(buyTime == -1 and 1 or 0)
    local itemCell = BindManager.bindItemCell(self.itemCell)
    itemCell:setData(getRes.code, getRes.amout, getRes.type)
    itemCell:setIsBig(true)
    itemCell:setNoFrame(true)
    self.itemCell:setScale(2, 2)
    -- 物品信息介绍
    self.txt_itemName:setText(ItemConfiger.getItemNameByCode(getRes.code))

    local itemData = DynamicConfigData.t_item
    if not itemData then
        return
    end
    itemData = itemData[getRes.code]
    if not itemData then
        return
    end
    local txt_propDec = self.view:getChildAutoType("txt_propDec"):getChildAutoType("title")
    txt_propDec:setText(itemData.descStr)

    -- 消耗的物品
    local costItem1 = BindManager.bindCostItem(self.costItem1)
    costItem1:setData(costRes.type, costRes.code, costRes.amount, true)

    local iconLoader = self.view:getChildAutoType("iconLoader")
    local url = ItemConfiger.getItemIconByCode(costRes.code, costRes.type, true)
    local txt_price = self.view:getChildAutoType("txt_price")
    txt_price:setText(costRes.amount)
    iconLoader:setURL(url)

    -- 购买次数
    self.txt_buyTime:setText(string.format(Desc.shop_buyTime, buyTime))

    -- 名字列表
    local list_name = self.view:getChildAutoType("list_name")
    list_name:setItemRenderer(
        function(idx, obj)
            local title = obj:getChildAutoType("title")
            title:setText(string.format("%s x%s", ItemConfiger.getItemNameByCode(getRes.code), getRes.amount))
        end
    )
    list_name:setNumItems(1)

    -- 批量购买
    self.buyTimeCtrl:setSelectedIndex(buyTime > 1 and 1 or 0)
    local buyNum = 1 -- 购买数量

    local haveMoney = 0
    if costRes.type == 3 then
        haveMoney = ModelManager.PackModel:getItemsFromAllPackByCode(costRes.code)
    else
        haveMoney = PlayerModel:getMoneyByType(costRes.code)
    end
    self.btn_max:removeClickListener(888)
    self.btn_max:addClickListener(
        function()
            local needMoney = buyTime * costRes.amount
            if haveMoney >= needMoney then
                buyNum = buyTime
            else
                buyNum = math.floor(haveMoney / costRes.amount)
                if buyNum == 0 then
                    buyNum = 1
                end
            end
            costItem1:setData(costRes.type, costRes.code, costRes.amount * buyNum, true)
            self.txt_num:setText(buyNum)
        end,
        888
    )

    self.btn_sub:removeClickListener(888)
    self.btn_sub:addClickListener(
        function()
            if buyNum > 1 then
                buyNum = buyNum - 1
            end
            costItem1:setData(costRes.type, costRes.code, costRes.amount * buyNum, true)
            self.txt_num:setText(buyNum)
        end,
        888
    )

    self.btn_add:removeClickListener(888)
    self.btn_add:addClickListener(
        function()
            if buyNum < buyTime then
                buyNum = buyNum + 1
            end
            costItem1:setData(costRes.type, costRes.code, costRes.amount * buyNum, true)
            self.txt_num:setText(buyNum)
        end,
        888
    )

    self.btn_min:removeClickListener(888)
    self.btn_min:addClickListener(
        function()
            buyNum = 1
            costItem1:setData(costRes.type, costRes.code, costRes.amount * buyNum, true)
            self.txt_num:setText(buyNum)
        end,
        888
    )

    -- 折扣
    local dazhe = self.view:getChildAutoType("dazhe")
    local txt_zhekou = self.view:getChildAutoType("txt_zhekou")
    txt_zhekou:setVisible(false)
    dazhe:setVisible(false)
    -- -- 购买次数小于1 购买按钮置灰
    if buyTime < 1 then
        self.btn_ok:getChildAutoType("n32"):setGrayed(true)
        self.btn_ok:setTouchable(false)
    end

    -- print(8848,"haveMoney>>>>>>>>",haveMoney,">>>>>amount>>>>>>>>>",costRes.amount)
    self.btn_ok:removeClickListener(888)
    self.btn_ok:addClickListener(
        function()
            if
                not PlayerModel:isCostEnough(
                    {{type = costRes.type, code = costRes.code, amount = costRes.amount * buyNum}}
                )
             then
                -- RollTips.show("消耗不足")
                return
            end
			if self.activeTag == GameDef.ActivityType.GodMarket then
				GodMarketModel:buyItem(self.activeTag, showData.id,buyNum)
			else
				CooperationActivitiesModel:WorkTogetherExchange(self.activeTag, showData.id,buyNum)
			end
            
            ViewManager.close("CooperationActivitieshopBuyView")
        end,
        888
    )

    -- 背包中物品数量
    local hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(getRes.code)
	if getRes.type == CodeType.MONEY then
		hasNum = PlayerModel:getMoneyByType(getRes.code)
	else
		hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(getRes.code)
	end
    local txt_haveNum = self.view:getChildAutoType("txt_haveNum")
    txt_haveNum:setText(Desc.shop_haveDec .. ":" .. StringUtil.transValue(hasNum))

    -- 特性书要展示英雄
    local heroCtrl = self.view:getController("heroCtrl")
    if (showData.shopType == 11) then
        heroCtrl:setSelectedIndex(1)
        CardLibModel:setCardsByCategory(0)
        local heroMap = CardLibModel:getHeroInfoToIndex(true, 2)
        local skillId = showData.getRes[1].code - 10004000
        local heroCodeMap = {}
        local codeList = {}
        local suggestPassive = DynamicConfigData.t_SuggestPassive
        local heroConf = DynamicConfigData.t_hero
        for _, hero in pairs(heroMap) do
            local suggestList = {}
            local hConf = heroConf[hero.code]
            local suggestId = hConf.suggestpassive
            -- 高级特性技能推荐
            for _, id in ipairs(suggestPassive[suggestId].passivecombin) do
                suggestList[id] = true
            end
            for _, id in ipairs(hConf.passiveSkill) do
                suggestList[id] = true
            end
            local learnedMap = {}
            if (hero.newPassiveSkill) then
                for id, info in pairs(hero.newPassiveSkill) do
                    if (info.skillId and info.skillId > 0) then
                        learnedMap[info.skillId] = true
                    end
                end
            end
            if
                (hero and hero.star > 3 and (not heroCodeMap[hero.code]) and
                    (suggestList[skillId] and (not learnedMap[skillId])))
             then
                heroCodeMap[hero.code] = hero
                table.insert(codeList, hero.code)
            end
        end
    end
end

function CooperationActivitieshopBuyView:buyResult(args, obj, buyNum)
    if tolua.isnull(obj) then
        return
    end
    local c1 = obj:getController("c1")
    if args.ret == 0 then
        local showData = self.data.showData
        local getRes = showData.getRes[1]
        RollTips.show(Desc.shop_success:format(ItemConfiger.getItemNameByCode(getRes.code), getRes.amount * buyNum))
        self.data.buyTime = args.buyTime
        local buyTime = self.data.buyTime
        c1:setSelectedIndex(buyTime < 1 and 0 or 1)

        for k, v in pairs(ShopModel.shopList[showData.shopType].list) do
            if args.id == v.id then
                v.buyTime = buyTime
                break
            end
        end
        ShopModel:upDateRed(showData.shopType)
        Dispatcher.dispatchEvent(EventType.shop_refreshItem)
    else
        --Alert.show(Desc.shop_success)
    end
end

return CooperationActivitieshopBuyView
