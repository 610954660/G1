---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: 升星选择材料界面
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local CardDetailsUpStarChoose,Super = class("CardDetailsUpStarChoose", Window)
function CardDetailsUpStarChoose:ctor()
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
	
	self._limitNum = 0
	self._pos = self._args.pos or self._args.pos or 1

	self._type = self._args.type
	self._bQuickStarUp = self._args.bQuickStarUp or false
	
	self._heroInfo = self._args.heroInfo or ModelManager.CardLibModel.curCardStepInfo

	self.star = self._args.star -- 升星需要的材料等级
	-- 分类按钮
	for i = 1, 6 do
		local btnName = string.format("btn_c%d", i)
		self[btnName] = false
	end

	self.category = 0

	ModelManager.CardLibModel.bOpenCardChooseView = true
end    

function CardDetailsUpStarChoose:_initUI()
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
	local heroInfo= self._heroInfo
	local chooseList = self._args.chooseList
	self:bindEvent()
	self._bQuickStarUp = self._args.bQuickStarUp or false -- 是否从快捷升星界面打开
	if self._bQuickStarUp then
		chooseList = self._args.chooseList
	else
		local info = DynamicConfigData.t_hero
    	local heroItem = info[heroInfo.heroId]
    	local temp, cost = ModelManager.CardLibModel:getUpStarMaterials(heroInfo.code, heroInfo.star)
		local materials = temp[self._args.pos]
		chooseList = ModelManager.CardLibModel:getStarCanChooseInfo(materials, heroItem, self._args.pos, self._bQuickStarUp, heroInfo)
	end
	self.chooseList = chooseList
	chooseList = {}
	for k, v in ipairs(self.chooseList) do -- self.chooseList不保存快捷合成选项
		table.insert(chooseList, v)
	end
	-- if self._type == 3 and self.star == 5 then -- 当需要5星材料时，增加快捷合成选项
	-- 	local hInfo = CardLibModel:getOneQuickStarUpChooseByCategoryAndStar(0, 5)
	-- 	if hInfo then
	-- 		table.insert(chooseList, 1, hInfo)
	-- 	end
	-- end
	if self._type == 3 and self.star == 5 then -- 当需要5星材料时，增加快捷合成选项
		local hInfo = CardLibModel:getQuickStarUpChooseByCategoryAndStar(0, 5)
		if hInfo then
			for k, v in ipairs(hInfo) do
				table.insert(chooseList, 1, v)
			end
		end
	end
	self._limitNum = self._args.num
	--local num=	self._args.num;
	local num = 0
	if self._bQuickStarUp then
		num = ModelManager.CardLibModel:getQuickStarUpMaterialsNum(self._pos)
	else
		num = ModelManager.CardLibModel:getStarMaterialsNum(self._pos)
	end
	self:setTextNum(num);
	self.txt_desc:setText(Desc.card_chooseDesc)

	self:showChooseList(chooseList);
end


--绑定事件
function CardDetailsUpStarChoose:bindEvent()
	self.btnstarchoose:addClickListener(function (context)
		ViewManager.close('CardDetailsUpStarChoose');
		--Dispatcher.dispatchEvent(EventType.cardView_starUpChoose);
	end)
	-- 分类按钮
	for i = 0, 5 do
		local btnName = string.format("btn_c%d", i)
		self[btnName]:addClickListener(function()
			if self._type == 1 or self._type == 2 then
				if i ~= self._heroInfo.heroDataConfiger.category then
					RollTips.show(Desc.card_canNotChoose)
				end
				return
			end
			self:classifyByCategory(i)
		end)
	end
end

function CardDetailsUpStarChoose:setTextNum(num)
	local limit= self._limitNum;
	printTable(5,'已选择：',limit,num)
	self.txtseleNum:setText(string.format("%s/%s", num, limit));
end

--设置卡牌属性名展示
function CardDetailsUpStarChoose:showChooseList(temp)
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
--		local name111 = obj:getChild("name111")
--		if temp[index+1] and temp[index+1].uuid then
--			name111:setText(temp[index+1].uuid)
--		end
		local ctrl = obj:getController("c2")
			if index == #temp then
				ctrl:setSelectedIndex(1)
				obj:removeClickListener()--池子里面原来的事件注销掉
				obj:addClickListener(function(context)
					--RollTips.show("显示去获取")
					--local str = ConstConfiger.getValueStrByKey("HeroResources")
					--if str then
					--	local source = json.decode(str)
					--	ViewManager.open("NotEnoughView", {source = source})
					--end
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
					-- cardItem:setGrayed(true, false)
					-- cardItem.view:getController("grayCtrl"):setSelectedIndex(1)
					-- cardItem.view:getChild("cardStar"):setGrayed(true)
				else -- 普通选项
					ctrl:setSelectedIndex(0)
					cardItem:setData(heroItem, true)
					cardItem:showMask(false)
					-- cardItem.view:getChild("cardStar"):setGrayed(false)
					-- cardItem.view:getController("grayCtrl"):setSelectedIndex(0)
				end

				local ctrl = obj:getChild("cardItem"):getController("c1")
				local isLock = heroItem.locked
				local heroPalace = heroItem.uuid and ModelManager.HeroPalaceModel:isInHeroPalace(heroItem.uuid) or false
				if isLock then
					ctrl:setSelectedIndex(7)
				elseif heroPalace then
					ctrl:setSelectedIndex(6)
				else
					local choos = false
					if self._bQuickStarUp then
						choos = ModelManager.CardLibModel:isQuickCardStarUpChoose(self._pos, heroItem)
					else
						choos = ModelManager.CardLibModel:isCurCardStarUpChoose(self._pos, heroItem)
					end
					if choos then
						ctrl:setSelectedIndex(2)
					else
						ctrl:setSelectedIndex(0)
					end
				end
					
			
				local txtnum= FGUIUtil.getChild(obj,"txt_num","GTextField")
				txtnum:setVisible(false);


				obj:removeClickListener()--池子里面原来的事件注销掉
				if self.star == 5 and not self._bQuickStarUp and bHasQuickUp and quickUpIndexies[index+1] == true then -- 快捷合成选项
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
						--self:setChoose(obj,materials);
						local isLock = materials.locked
						if isLock then
							RollTips.show(Desc.card_isInLock)
							return
						end
						
						local heroPalace = materials.uuid and ModelManager.HeroPalaceModel:isInHeroPalace(materials.uuid) or false
						if heroPalace then
							RollTips.show(Desc.card_isInHeroPalace1)
							return
						end
						
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
							local pos=self._pos
							local limitCount=self._limitNum
							local num1 = 0;
							
							-- local temp=ModelManager.CardLibModel.curCardStarUpChoose[pos]or {};
							if self._bQuickStarUp then
								num1 = ModelManager.CardLibModel:getQuickStarUpMaterialsNum(pos);
								local uuid = materials.uuid or materials.code;
								local uid = ModelManager.CardLibModel:isQuickCardStarUpChoose(pos, materials)--temp[uuid];
								if not uid then
									if num1>=limitCount then
										RollTips.show(Desc.card_DetailsStr12);
									else
										ModelManager.CardLibModel:addQuickCardStarUpChoose(pos, {materials});
										--seleImg:setVisible(true);
										cardItem:setSelected(true)
									end
								else
									ModelManager.CardLibModel:removeQuickCardStarUpChoose(pos, materials);
									cardItem:setSelected(false)
									--seleImg:setVisible(false);
								end
								-- ModelManager.CardLibModel.curCardStarUpChoose[pos]=temp;
								-- printTable(5,'>>>>>>>>>>>',ModelManager.CardLibModel.curCardStarUpChoose,pos)
								local num=	ModelManager.CardLibModel:getQuickStarUpMaterialsNum(pos);
								self:setTextNum(num);
							else
								num1 = ModelManager.CardLibModel:getStarMaterialsNum(pos);
								local uuid = materials.uuid or materials.code;
								local uid = ModelManager.CardLibModel:isCurCardStarUpChoose(pos, materials)--temp[uuid];
								if not uid then
									if num1>=limitCount then
										RollTips.show(Desc.card_DetailsStr12);
									else
										ModelManager.CardLibModel:addCurCardStarUpChoose(pos, {materials});
										--seleImg:setVisible(true);
										cardItem:setSelected(true)
									end
								else
									ModelManager.CardLibModel:removeCurCardStarUpChoose(pos, materials);
									cardItem:setSelected(false)
									--seleImg:setVisible(false);
								end
								-- ModelManager.CardLibModel.curCardStarUpChoose[pos]=temp;
								printTable(5,'>>>>>>>>>>>',ModelManager.CardLibModel.curCardStarUpChoose,pos)
								local num=	ModelManager.CardLibModel:getStarMaterialsNum(pos);
								self:setTextNum(num);
							end
						end

					end)
				end
			end
			--self:showChooseItem(obj,temp[index+1])
		end
	)
	self.listchoose:setNumItems(#temp + 1);
end



function CardDetailsUpStarChoose:setChoose(obj,materials)
	local pos=self._pos
	local num1=	ModelManager.CardLibModel:getStarMaterialsNum(pos);
	local limitCount=self._args[1].num;
		local seleImg= obj:getChild('n17');
		local temp=ModelManager.CardLibModel.curCardStarUpChoose[pos]or {};
		local uid =temp[materials.uuid];
		if uid==nil then
			if num1>=limitCount then
				RollTips.show(Desc.card_DetailsStr12);
				else
				temp[materials.uuid]=materials.uuid;
				seleImg:setVisible(true);
			end
		else
			temp[materials.uuid]=nil;
			seleImg:setVisible(false);
		end
		ModelManager.CardLibModel.curCardStarUpChoose[pos]=temp;
		printTable(5,'>>>>>>>>>>>',ModelManager.CardLibModel.curCardStarUpChoose,pos)
		local num=	ModelManager.CardLibModel:getStarMaterialsNum(pos);
		self:setTextNum(num);
	
end

function CardDetailsUpStarChoose:quickStarUp_suc(_, data)
	local heroInfo= self._heroInfo;
	if not self._bQuickStarUp then
		local heroInfo = self._heroInfo
		local info = DynamicConfigData.t_hero
    	local heroItem = info[heroInfo.heroId]
    	local temp, cost = ModelManager.CardLibModel:getUpStarMaterials(heroInfo.code, heroInfo.star)
		local materials = temp[self._args.pos]
		local chooseList = ModelManager.CardLibModel:getStarCanChooseInfo(materials, heroItem, self._args.pos, self._bQuickStarUp, heroInfo)
		self.chooseList = chooseList
		if self._type == 3 and self.star == 5 then -- 当需要5星材料时，增加快捷合成选项
			chooseList = {} -- self.chooseList不保存快捷合成选项
			for k, v in ipairs(self.chooseList) do
				table.insert(chooseList, v)
			end
			self:classifyByCategory(self.category)
		else
			self:showChooseList(chooseList)
		end
		local num = ModelManager.CardLibModel:getStarMaterialsNum(self._pos)
		self:setTextNum(num)
	end
end

function CardDetailsUpStarChoose:classifyByCategory(category)
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
	-- if self._type == 3 and self.star == 5 then -- 当需要5星材料时，增加快捷合成选项
	-- 	local hInfo = CardLibModel:getOneQuickStarUpChooseByCategoryAndStar(category, 5)
	-- 	if hInfo then
	-- 		table.insert(chooseList, 1, hInfo)
	-- 	end
	-- end
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

function CardDetailsUpStarChoose:_exit()
	if self._bQuickStarUp then -- 是否从快捷升星界面打开
		Dispatcher.dispatchEvent(EventType.quickStarUp_chooseChange);
	else
		if ModelManager.CardLibModel then ModelManager.CardLibModel:clearQuickCardStarUpMap() end -- 清除快捷升星英雄记录
		Dispatcher.dispatchEvent(EventType.cardView_starUpChoose);
	end
	if ModelManager.CardLibModel then ModelManager.CardLibModel.bOpenCardChooseView = false end
end


function CardDetailsUpStarChoose:_enter()

end

return CardDetailsUpStarChoose