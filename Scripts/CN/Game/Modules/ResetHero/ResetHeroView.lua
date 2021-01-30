-- add by zn
-- 英雄回退

local ResetHeroView = class("ResetHeroView", Window)

function ResetHeroView:ctor()
    self._packName = "ResetHero"
    self._compName = "ResetHeroView"
    -- self._rootDepth = LayerDepth.PopWindow
    self.select = false;
    self.backInfo = false;
    self.costConf = false;
    ResetHeroModel.resetType = 1;
	self.minStar = {6,12,7}
	self.maxStar = {9,19,17}
	self.excludeStar = {9,12,15}
	self.config = false
end

function ResetHeroView:_initUI()
    local root = self
    local rootView = self.view
        root.btn_back1 = rootView:getChildAutoType("btn_back1");
        root.btn_back2 = rootView:getChildAutoType("btn_back2");
        root.btn_back3 = rootView:getChildAutoType("btn_back3");
        root.btn_add = rootView:getChildAutoType("btn_add");
        root.btn_ok = rootView:getChildAutoType("btn_ok");
        root.btn_change = rootView:getChildAutoType("btn_change");
        root.btn_help = rootView:getChildAutoType("btn_help");

        root.txt_typeDesc = rootView:getChildAutoType("txt_typeDesc");
        root.costItem = BindManager.bindCostItem(rootView:getChildAutoType("costItem"));
        root.card1 = BindManager.bindCardCell(rootView:getChildAutoType("card1"));
        root.card2 = BindManager.bindCardCell(rootView:getChildAutoType("card2"));
        root.list_item = rootView:getChildAutoType("list_item");

    self:setBg("resetHeroBg.jpg");
    if self._args.page == 1 then
        ResetHeroModel.resetType = 1;
        self.view:getController("c1"):setSelectedIndex(0)
        self.select = false;
        self:upResetView();
    else
        self.view:getController("c1"):setSelectedIndex(1)
        ResetHeroModel.resetType = 2;
        self.select = false;
        self:upResetView();
    end
end

function ResetHeroView:_initEvent()
    self.btn_back1:addClickListener(function ()
        if (ResetHeroModel.resetType == 1) then return end;
        ResetHeroModel.resetType = 1;
        self.select = false;
        self:upResetView();
    end)
    self.btn_back2:addClickListener(function ()
    if (ResetHeroModel.resetType == 2) then return end;
        ResetHeroModel.resetType = 2;
        self.select = false;
        self:upResetView();
    end)

	self.btn_back3:addClickListener(function ()
    if (ResetHeroModel.resetType == 3) then return end;
        ResetHeroModel.resetType = 3;
        self.select = false;
        self:upResetView();
    end)

    self.btn_add:addClickListener(function ()
        self:openChooseWin();
    end)
    self.btn_change:addClickListener(function ()
        self:openChooseWin();
    end)

    self.btn_ok:addClickListener(function ()
        self:checkOnBattle();
    end)
    self:upResetView();

    self.btn_help:addClickListener(function ()
        RollTips.showHelp(Desc.ResetHero_helpTitle, Desc.ResetHero_helpDesc);
    end)
end

function ResetHeroView: btnOkFunc()
    if (not PlayerModel:isCostEnough(self.config.cost, false)) then
        for _, cost in pairs(self.config.cost) do
            local hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(cost.code)
            if(hasNum >= cost.amount) then return true end
            local itemInfo = ItemConfiger.getInfoByCode(cost.code, GameDef.GameResType.Item)
            if #itemInfo.source == 0 then
                local itemName = itemInfo and itemInfo.name  or Desc.player_expStr5
                local tips = string.format(Desc.ResetHero_notEounghItem, itemName)
				--策划的奇葩需求 由于目前第二周的周礼包中增加了回退道具，所以在回退探员时，若道具不足，则直接跳转到每周礼包的界面。第一周不需要跳转，但描述改为：第二周开始可从每周礼包中可购买。
				local day = TimeLib.DifDate(ServerTimeModel:getOpenDateTime()*1000, ServerTimeModel:getServerTimeMS())
				if day < 7 then
					RollTips.show(tips)
				else
					RollTips.show(tips)
					ModuleUtil.openModule(ModuleId.WeeklyGiftBag.id)
				end
            else
                ViewManager.open("ItemNotEnoughView", cost)
            end
        end
        return;
    end
	local desc = Desc["ResetHero_sureTip"..ResetHeroModel.resetType]
	if ResetHeroModel.resetType== 3 then
		desc = string.format(desc, self.config.newStar)
	end
    local info = {
        text = desc,
        type = "yes_no",
        key = "resetHero",
    }
    info.onYes = function ()
        ResetHeroModel:resetHero(ResetHeroModel.resetType== 3 and 3 or 1, self.select);
    end
    Alert.show(info);
end

function ResetHeroView: openChooseWin()
    local chooseUuids = {}
    local maxStar = self.maxStar[ResetHeroModel.resetType];
    local minStar = self.minStar[ResetHeroModel.resetType];
	local excludeStar = ResetHeroModel.resetType == 3 and self.excludeStar or {}
    local param = {
        noLock = true,
        noBattle = false,
        noHeroPalace = true,
        funcName = Desc.ResetHero_reset,
        minStar = minStar,
        minLevel = 1,
        caller = self,
        excludeUuids = chooseUuids,
        maxStar = maxStar,
		excludeStar = excludeStar
    }
    param.callback = function(self, cardInfo)
        self.select = cardInfo;
        self:upResetView();
    end
    ViewManager.open("ResetHeroChooseView", param)
end

function ResetHeroView: ResetHero_reset()
    self.select = false;
    self.backInfo = false;
    self:upResetView();
end

function ResetHeroView: upResetView()
    self.txt_typeDesc:setText(Desc["ResetHero_resetType"..ResetHeroModel.resetType]);
    local ctrl = self.view:getController("heroShow");
    if (not self.select) then
        ctrl:setSelectedIndex(0);
    else
        ctrl:setSelectedIndex(1);
        self.card1:setData(self.select);
        self:setBackInfo();
    end
end

function ResetHeroView:setBackInfo()
    if (self.select) then
        self.backInfo = {};
        for k, v in pairs(self.select) do
            self.backInfo[k] = v;
        end
        self.config = DynamicConfigData.t_BackstarCost[self.select.star];
		if self.config [2] then
			if ResetHeroModel.resetType == 3 then
				self.config = self.config[2]
			else
				self.config = self.config[1]
			end
		end
        self.backInfo.star = self.config.newStar;
        self.backInfo.level = 1;
        self.backInfo.stage = 0;
        self.card2:setData(self.backInfo);
        local cost = self.config.cost[1];
        self.costConf = cost;
		if cost.type == CodeType.MONEY then
			self.costItem:setData(cost.type, cost.code, cost.amount, true, false, false);
		else
			self.costItem:setData(cost.type, cost.code, cost.amount, false, false, false);
		end
        self:showBackRes();
    else
        self.backInfo = false;
    end
end

--[[function ResetHeroView:pack_item_change()
    if (self.costConf and self.costItem) then
        local hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(self.costConf.code);
        local needNum = self.costConf.amount;
        local color = hasNum >= needNum and "%s" or Desc.common_red;
        self.costItem.txt_num:setText(string.format(color, hasNum.."/"..needNum));
    end
end
--]]
function ResetHeroView:showBackRes()
    local allRes = self:getTotalBackRes();
    local tab = {}
    local conf = DynamicConfigData.t_item;
    for _, v in pairs(allRes) do
        local c = conf[v.code];
        if (v.type == GameDef.GameResType.Money) then
            c = conf[v.code + 2000];
        end
        v.color = c and c.color or 4;
        table.insert(tab, v);
    end
    TableUtil.sortByMap(tab, {{key= "type", asc=false}, {key= "color", asc=true}});
    self.list_item:setItemRenderer(function (idx, obj)
        local d = tab[idx + 1];
        --if (not obj.itemCell) then
         --   obj.itemCell = BindManager.bindItemCell(obj);
        --end
		local rewardCell = BindManager.bindRewardCell(obj)
		rewardCell:setData(d)
        --obj.itemCell:setData(d.code, d.amount, d.type);
    end)
    self.list_item:setNumItems(TableUtil.GetTableLen(allRes));
end

-- 计算所有返回资源
function ResetHeroView:getTotalBackRes()
	local getHero = {}
	local getItem = {}
	local allRes = {}
	local getItemMap = {}
	
	local addHero = function(heroId, star)
		table.insert(getHero, {type = 4, heroId = heroId, heroStar = star, level = 1})
		table.insert(allRes, {type = 4, heroId = heroId, heroStar = star, level = 1})
	end
	
	local addItem = function(item)
		if not getItemMap[item.code] then
			getItemMap[item.code] = {code = item.code, type = item.type, amount = item.amount}
			table.insert(getItem, getItemMap[item.code])
			table.insert(allRes, getItemMap[item.code])
		else
			getItemMap[item.code].amount = getItemMap[item.code].amount + item.amount
		end
	end
	
    --local allRes = {};
    -- 等级
    local levelConf = DynamicConfigData.t_heroLevel;
    local curLv = self.select.level;
    for i = 2, curLv do
        local c = levelConf[i];
        addItem({code = c.code1, type = c.type1, amount = c.amount1})
		addItem({code = c.code2, type = c.type2, amount = c.amount2})
    end

    -- 阶级
    local stageConf= DynamicConfigData.t_heroStage;
    local curStage = self.select.stage
    for i = 1, curStage do
        local c = stageConf[i];
        for _, v in ipairs(c.costList) do
            addItem(v)
        end
    end
    -- 星级
    local heroCode = self.select.code;
    local info= DynamicConfigData.t_hero;
	local starRuleId= info[heroCode].starRule;
    local category = info[heroCode].category;
	local baseStar = info[heroCode].heroStar;
	local starInfo=DynamicConfigData.t_heroStar;
    local starData=starInfo[starRuleId];
    local curStar = self.select.star - 1;
    local backStar = self.backInfo.star;
    local backStarConf = DynamicConfigData.t_BackstarItem;
    for i = backStar, curStar do
        local c = starData[i];
        if (c) then
            -- 本体消耗
            if (#c.self > 0) then
				--addHero({type = 4, code = heroCode, star =backStar})
                for k, selfInfo in pairs(c.self) do
					for i = 1,selfInfo.num do
						addHero(heroCode, selfInfo.star)
					end
                end
            end
            -- 同阵容消耗 
            if (#c.faction > 0) then
                for k, facInfo in pairs(c.faction) do
                    local d = backStarConf[category][facInfo.star]
                    local resCode = d and d.id or false;
                    if (resCode) then
						--for i = 1,facInfo.num do
							--addHero(resCode, facInfo.star)
							addItem({code = resCode, type = 3, amount = facInfo.num})
						--end
                    end
                end
            end
            -- 通用消耗
            if (#c.free > 0) then
                for k, free in pairs(c.free) do
                    local d = backStarConf[0][free.star]
                    local resCode = d and d.id or false;
                    if (resCode) then
						--for i = 1,free.num do
							--addHero(resCode, free.star)
							addItem({code = resCode, type = 3, amount = free.num})
						--end
                    end
                end
            end
            -- 其他消耗
            for _, v in ipairs(c.material) do
                addItem(v)
            end
        end
    end

    return allRes,getHero,getItem;
end

function ResetHeroView:checkOnBattle(cb)
    local battle = ModelManager.BattleModel:getArrayInfo()
    local hasBattle = false
    if battle then
        hasBattle = battle.array
    end
    if hasBattle and self.select and hasBattle[self.select.uuid] ~= nil then
        local uuid = self.select.uuid;
        local arrayType = ModelManager.BattleModel:getArrayTypes(uuid)
        local battleFunName = Desc["common_arrayType"..arrayType[1]]
        
        local info = {}
        --info.text = string.format(Desc.card_resetIsInBattle, battleFunName, self.funcStr )
		info.text = Desc.card_isInBattle
        info.type = "yes_no"
        info.align = "center"
        info.mask = true
        info.onYes = function()
            for _, arrType in pairs(arrayType) do
                ModelManager.CardLibModel:doQuitBattle(arrType, uuid);
            end
        end
        Alert.show(info)
    else
        self:btnOkFunc();
    end
end

return ResetHeroView