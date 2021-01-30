---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: 升星选择材料界面
-- Date: 2020-01-11 17:15:22
-- Desc: 升星材料选择界面脚本不通用，这里分出来做，界面依旧用那个界面
---------------------------------------------------------------------
local CardSegmentChoseView,Super = class("CardSegmentChoseView", Window)
function CardSegmentChoseView:ctor()
    self._packName = "CardSystem"
	self._compName = "cardUpstarChoose"
	self._rootDepth = LayerDepth.PopWindow
	--GList
	self.listchoose=false--卡牌阶级图片显示
	--GButton
	self.btnstarchoose=false
	--GTextField
	self.txtseleNum=false
    self.txt_desc=false
    
	-- 分类按钮
	for i = 0, 5 do
		local btnName = string.format("btn_c%d", i)
		self[btnName] = false
	end
	
	self._limitNum = 0  -- 最大选择数量
    self._materials = self._args.materials or {}; -- 需要的材料，结构 {star = 5, num = 1, hero = 15001, type = 1};
    self._type = self._materials.type or 1; -- 消耗材料的类型  1 本卡牌id  2 本种族  3 无规则限制  4 特殊要求
    self.star = self._materials.star or 5-- 升星需要的材料等级
    self.callback = self._args.callback; -- 确认选择的回调
    self.caller = self._args.callbackCaller;
    self.selectedArr = self._args.selected or {}; -- 当前界面的选中
    self._excludeUuid = self._args.exclude or {}; -- 排除的uuid
    self.category = 0 
    self._heroInfo = self._args.heroInfo or {};
	-- ModelManager.CardLibModel.bOpenCardChooseView = true
end    

function CardSegmentChoseView:_initUI()
	--ModelManager.CardLibModel:clearupStarInfo()
	local viewRoot = self.view
	self.txtseleNum=viewRoot:getChild("txt_seleNum")
	self.txt_desc=viewRoot:getChild("txt_desc")
	self.btnstarchoose=viewRoot:getChildAutoType("btn_starchoose")
	self.listchoose=FGUIUtil.getChild(viewRoot,"list_choose","GList")
	-- 分类按钮
	for i = 0, 5 do
		local btnName = string.format("btn_c%d", i)
		self[btnName] = viewRoot:getChild(btnName)
	end
    
	self._limitNum = self._materials.num
	local num = #self.selectedArr
	self:setTextNum(num);
    self.txt_desc:setText(Desc.card_chooseDesc)
    
    self:CardQuickStarUpView_close();
end


function CardSegmentChoseView:CardQuickStarUpView_close()
    local materials = self._args.materials
    local heroInfo = self._heroInfo;
    self.chooseList = CardLibModel:getStarCanChooseInfo20Segment(materials, heroInfo, self._excludeUuid);
	local chooseList = {}
	for k, v in ipairs(self.chooseList) do -- self.chooseList不保存快捷合成选项
		table.insert(chooseList, v)
	end
	if self._type == 3 and self.star == 5 then -- 当需要5星材料时，增加快捷合成选项
		local hInfo = CardLibModel:getQuickStarUpChooseByCategoryAndStar(0, 5)
		if hInfo then
			for k, v in ipairs(hInfo) do
				table.insert(chooseList, 1, v)
			end
		end
	end

	self:showChooseList(chooseList);
end


--绑定事件
function CardSegmentChoseView:_initEvent()
	self.btnstarchoose:addClickListener(function (context)
		if (self.callback) then
			if (self.callbackCaller) then
				self.callback(self.callbackCaller, self.selectedArr)
			else
				self.callback(self.selectedArr)
			end
		end
		ViewManager.close('CardSegmentChoseView');
	end)
	-- 分类按钮
	for i = 0, 5 do
		local btnName = string.format("btn_c%d", i)
		self[btnName]:addClickListener(function()
			if self._type == 1 or self._type == 2 then
				if i ~= self._heroInfo.category then
					RollTips.show(Desc.card_canNotChoose)
				end
				return
			end
			self:classifyByCategory(i)
		end)
	end
end

function CardSegmentChoseView:setTextNum(num)
	local limit= self._limitNum;
	self.txtseleNum:setText(string.format("%s/%s", num, limit));
end

--设置卡牌属性名展示
function CardSegmentChoseView:showChooseList(temp)
	local quickUpChoice = {} -- 快捷升星选项
	local materialList = {} -- 替补材料列表
	local oldFourStarHero = {} -- 原4星探员列表，即通过快捷升星升到5星的探员
	local notRealFiveStarHero = {} -- 伪5星探员列表
	local otherHero = {} -- 其它探员列表
	local heroInfo = DynamicConfigData.t_hero
	for k, v in ipairs(temp) do
		if v.quickUp then -- 快捷升星选项
			table.insert(quickUpChoice, v)
		elseif not v. heroDataConfiger then -- 升星替补材料
			table.insert(materialList, v)
		else -- 探员
			if ModelManager.CardLibModel:isQuickCardStarUpHero(v.uuid) then
				table.insert(oldFourStarHero, v)
			elseif v.star == 5 and (heroInfo[v.heroId].starRule == 3 or heroInfo[v.heroId].starRule == 5) then -- 伪五星探员
				table.insert(notRealFiveStarHero, v)
			else
				table.insert(otherHero, v)
			end
		end
	end
	TableUtil.sortByMap(quickUpChoice, {{key="heroId", asc=false}, {key="combat", asc=false}})
	table.sort(materialList, function(a, b)
		return a.idx < b.idx
	end)
	table.sort(oldFourStarHero, function(a, b)
		return a.combat < b.combat
	end)
	table.sort(notRealFiveStarHero, function(a, b)
		return a.combat < b.combat
	end)
	TableUtil.sortByMap(otherHero, {{key="level",asc=false},{key="combat",asc=false},{key="heroId",asc=false}})
	temp = {}
	for k, v in ipairs(quickUpChoice) do
		table.insert(temp, v)
	end
	for k, v in ipairs(materialList) do
		-- printTable(1, v)
		table.insert(temp, v)
	end
	for k, v in ipairs(oldFourStarHero) do
		table.insert(temp, v)
	end
	for k, v in ipairs(notRealFiveStarHero) do
		table.insert(temp, v)
	end
	for k, v in ipairs(otherHero) do
		table.insert(temp, v)
	end

	self.listchoose:setVirtual()
	local bHasQuickUp = false
	local quickUpIndexies = {}
	for k, v in ipairs(temp) do
		if v.quickUp == true then
			bHasQuickUp = true
			v.quickUp = false
			quickUpIndexies[k] = true
		end
	end
	self.listchoose:setItemRenderer(function(index,obj)
		local ctrl = obj:getController("c2")
		if index == #temp then
			ctrl:setSelectedIndex(1)
			obj:removeClickListener()--池子里面原来的事件注销掉
			obj:addClickListener(function(context)
				ModuleUtil.openModule(ModuleId.GetCard_Senior.id)
			end)
		else  --=========================================== showChooseList
			-- ctrl:setSelectedIndex(0)
			local heroItem = temp[index+1]
			local cardItem = BindManager.bindCardCell(obj:getChild("cardItem"))
			cardItem:setCardNameVis(true)
			
			if self.star == 5 and not self._bQuickStarUp and bHasQuickUp and quickUpIndexies[index+1] == true then -- 快捷合成选项
				ctrl:setSelectedIndex(2)
				local cardData = {heroId = heroItem.heroId, heroStar = self.star, level = heroItem.level}
				cardItem:setData(cardData, true)
				cardItem:showMask(true)
			else -- 普通选项
				ctrl:setSelectedIndex(0)
				cardItem:setData(heroItem, true)
				cardItem:showMask(false)
			end

			local ctrl = obj:getChild("cardItem"):getController("c1")
			local isLock = heroItem.locked
			local heroPalace = heroItem.uuid and ModelManager.HeroPalaceModel:isInHeroPalace(heroItem.uuid) or false
			if isLock then
				ctrl:setSelectedIndex(7)
			elseif heroPalace then
				ctrl:setSelectedIndex(6)
			else
				cardItem:setSelected(self:isCurCardStarUpChoose(heroItem))
			end
			
		
			local txtnum= obj:getChildAutoType("txt_num");
			txtnum:setVisible(false);

			obj:removeClickListener()--池子里面原来的事件注销掉
			if self.star == 5 and bHasQuickUp and quickUpIndexies[index+1] == true then -- 快捷合成选项
				obj:addClickListener(function(context)
					local lastHeroInfo = ModelManager.CardLibModel.quickCardStarUpInfo
					if lastHeroInfo and lastHeroInfo.uuid ~= heroItem.uuid then
						ModelManager.CardLibModel:clearupQuickStarUpInfo()
					end
					ModelManager.CardLibModel.quickCardStarUpInfo = heroItem
					ViewManager.open("CardQuickStarUpView")
				end)
			else -- 普通选项
				obj:addClickListener(function(context)
					local materials=temp[index+1];
					local isLock = materials.locked
					if isLock then
						RollTips.show(Desc.card_isInLock)
						return
					end
					-- 是否在英雄谷
					local heroPalace = materials.uuid and ModelManager.HeroPalaceModel:isInHeroPalace(materials.uuid) or false
					if heroPalace then
						RollTips.show(Desc.card_isInHeroPalace1)
						return
					end
					-- 是否上阵
					local arrayTypes = BattleModel:getArrayTypes(materials.uuid)
					if #arrayTypes > 0 then
						local funNameStr = "" 
						for i,v in ipairs(arrayTypes) do
							local battleFunName = Desc["common_arrayType"..v]
							if funNameStr == "" then
								if battleFunName then funNameStr = battleFunName end
							else
								if i > 3 then
									funNameStr = funNameStr..""..Desc.card_funNameMoreThen3
									break
								else
									if battleFunName then  funNameStr = funNameStr..", "..battleFunName end
								end
							end
						end
						
						local info = {}
						--info.text = string.format(Desc.card_quitBattle,funNameStr, self.funcStr )
						info.text = Desc.card_isInBattle
						info.type = "yes_no"
						--info.align = "left"
						info.mask = true
						info.onYes = function()
							for _,v in ipairs(arrayTypes) do
								ModelManager.CardLibModel:doQuitBattle(v, materials.uuid)
							end
						end
						Alert.show(info)
					else
						-- 添加移除选择
						local limitCount=self._limitNum
						local num1 = TableUtil.GetTableLen(self.selectedArr);
						local uuid = materials.uuid or materials.code;
						local uid = self:isCurCardStarUpChoose(materials);
						if not uid then
							if num1>=limitCount then
								RollTips.show(Desc.card_DetailsStr12);
							else
								self:addCurCardStarUpChoose(materials);
								cardItem:setSelected(true)
							end
						else
							self:removeCurCardStarUpChoose(materials);
							cardItem:setSelected(false)
						end
						local num = TableUtil.GetTableLen(self.selectedArr);
						self:setTextNum(num);
					end

				end)
			end
		end
	end)
	self.listchoose:setNumItems(#temp + 1);
end

function CardSegmentChoseView:classifyByCategory(category)
	self.category = category
	local chooseList = {}
	if category == 0 then -- 全部
		for k, v in ipairs(self.chooseList) do -- self.chooseList不保存快捷合成选项
			table.insert(chooseList, v)
		end
	else
		for k, v in ipairs(self.chooseList) do
			if not v.heroDataConfiger then -- 替补材料
				if v.category == category then
					table.insert(chooseList, v)
				end
			elseif v.heroDataConfiger.category == category then
				table.insert(chooseList, v)
			end
		end
	end
	if self._type == 3 and self.star == 5 then -- 当需要5星材料时，增加快捷合成选项
		local hInfo = CardLibModel:getQuickStarUpChooseByCategoryAndStar(category, 5)
		if hInfo then
			for k, v in ipairs(hInfo) do
				table.insert(chooseList, 1, v)
			end
		end
	end
	self:showChooseList(chooseList)
end

-- function CardSegmentChoseView:getStarCanChooseInfo(materials, heroInfo)
-- 	local chooseList={};
-- 	local type = materials.type;
--     local star = materials.star;
	
-- 	local heroConf = DynamicConfigData.t_hero
-- 	local hasChooseList = self._excludeUuid
-- 	local category = heroConf[heroInfo.code].category;
-- 	local hasBattle = ModelManager.BattleModel:getArrayType(heroInfo.uuid);
	
-- 	local backConf = DynamicConfigData.t_BackstarItem;
--     local categoryInfo = CardLibModel.__heroInfos[tonumber(category)]
    
-- 	if type==1 then
-- 		for key, value in pairs(categoryInfo) do
-- 			if value.star==star and value.code==heroInfo.heroId and heroInfo.uuid ~=key and hasChooseList[key]==nil then
-- 				chooseList[#chooseList+1]=value	;
-- 			end 
-- 		end
-- 	elseif type==2 then
-- 		-- 可以使用相同种族和星级的替身
-- 		local replaceConf = backConf[category][star];
-- 		if (replaceConf) then
-- 			local replaceCount = (replaceConf and replaceConf.id) and ModelManager.PackModel:getItemsFromAllPackByCode(replaceConf.id) or 0;
-- 			local choosedCount = hasChooseList[replaceConf.id] or 0;
-- 			replaceCount = math.max(replaceCount - choosedCount, 0);
-- 			for i = 1, replaceCount do
-- 				chooseList[#chooseList+1]={code=replaceConf.id, type=GameDef.GameResType.Item, amount=1, category = category, star = star, idx = #chooseList+1};
-- 			end
-- 		end
-- 		-- 同种族英雄
-- 		for key1, value in pairs(categoryInfo) do
-- 			if value.star==star and heroInfo.uuid ~=key1 and hasChooseList[key1]==nil then
-- 				chooseList[#chooseList+1]=value	;
-- 			end 
-- 		end
-- 		if star == 5 then -- 需要5星卡牌时，增加快捷合成
-- 			-- 获取4星级同阵营中拥有足够合成材料的探员
-- 			local heros = {}
-- 			local heroIds = {} -- 同一个探员只显示一个
-- 			for key, value in pairs(categoryInfo) do
-- 				value.quickUp = false 
-- 				if value.star == 4 and hasChooseList[key] == nil then
-- 					local _materials = CardLibModel:getUpStarMaterials(value.code, value.star)
-- 					if CardLibModel:isMaterialEnough(_materials, value) and not heroIds[value.heroId] then -- 拥有足够合成材料
-- 						value.quickUp = true
-- 						table.insert(heros, value)
-- 						heroIds[value.heroId] = true
-- 					end
-- 				end
-- 			end
-- 			for k, v in ipairs(heros) do
-- 				table.insert(chooseList, 1, v)
-- 			end
-- 		end
-- 	elseif type==3 then
-- 		-- 替换材料
-- 		for m = 0, 5 do
-- 			local replaceConf = backConf[m][star];
-- 			if (replaceConf) then
-- 				local replaceCount = (replaceConf and replaceConf.id) and ModelManager.PackModel:getItemsFromAllPackByCode(replaceConf.id) or 0;
-- 				local choosedCount = hasChooseList[replaceConf.id] or 0;
-- 				replaceCount = math.max(replaceCount - choosedCount, 0);
-- 				for i = 1, replaceCount do
-- 					chooseList[#chooseList+1]={code=replaceConf.id, type=GameDef.GameResType.Item, amount=1, category = m, star = star, idx = #chooseList+1};
-- 				end
-- 			end
-- 		end
-- 		-- 英雄材料
-- 		categoryInfo = CardLibModel:getCardByCategory(0)
-- 		for key1, value in pairs(categoryInfo) do
-- 			if value.star==star and heroInfo.uuid ~=value.uuid and hasChooseList[value.uuid]==nil then
-- 				chooseList[#chooseList+1]=value	;
-- 			end 
-- 		end
-- 	end
-- 	return chooseList;
-- end

-- 检测是否是当前已经选择的升星材料
function CardSegmentChoseView:isCurCardStarUpChoose(data)
	for _, value in ipairs(self.selectedArr) do
		if (data.uuid) then
			if (data.uuid == value.uuid) then
				return true;
			end
		elseif (data.code and data.idx == value.idx) then
			return true
		end
	end
	return false;
end

-- 添加选择升星材料
function CardSegmentChoseView:addCurCardStarUpChoose(data)
	-- for _,v in ipairs(data) do
		if not (self:isCurCardStarUpChoose(data)) then
			table.insert(self.selectedArr, data);
			return true;
		end
		return false;
	-- end
end

-- 移除选择升星材料
function CardSegmentChoseView:removeCurCardStarUpChoose(data)
	local info = self.selectedArr;
	for idx, value in ipairs(info) do
		if (data.uuid) then
			if (data.uuid == value.uuid) then
				table.remove(info, idx);
				return true;
			end
		elseif (data.code and data.idx == value.idx) then
			table.remove(info, idx);
			return true;
		end
	end
	return false;
end

return CardSegmentChoseView