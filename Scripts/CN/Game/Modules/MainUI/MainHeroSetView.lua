--added by xhd 主界面view
local MainHeroSetView = class("MainHeroSetView",Window)
local MoneyType = GameDef.MoneyType
local MainAdBoard = require "Game.Modules.MainUI.MainAdBoard"
local MainMsgBoard = require "Game.Modules.MainUI.MainMsgBoard"
local FashionConfiger = require "Game.ConfigReaders.FashionConfiger"

function MainHeroSetView:ctor()
    self._packName = "MainHeroSet"
	self._compName = "MainHeroSetView"
	self._rootDepth = LayerDepth.PopWindow
	self._isFullScreen = true
	self._showParticle = true
	self.playerIcon = false
	self.fashionPanel = false
	self.btn_fashion = false
	self.bg_fashion = false
	self.btn_arrow = false
	self.skinList = false
    self.loader_category = false
    self.loader_career = false
    self.btn_ok = false
    self.txt_name = false
    self.list_hero = false
	
	self._showHeroList = false
	self._selectedIndex = 0
	self.skeletonNode = false
	self.fashionList = {} --该英雄的皮肤列表
	self.fashionId = false --时装id
	self.heroFashionList = {} --保存英雄对应用的皮肤
	self.isShow = false --是否展开时装列表
end

-- [子类重写] 初始化UI方法
function MainHeroSetView:_initUI( ... )  
	local viewRoot = self.view
	self:setBg("heroReset.jpg")
	local playerIcon = viewRoot:getChildAutoType("playerIcon")
	self.playerIcon = BindManager.bindLihuiDisplay(playerIcon)
	self.playerIcon:setStatic(MainUIModel:isLihuiStatic())
	self.fashionPanel = viewRoot:getChildAutoType('fashionPanel')
	self.fashionPanel:setVisible(false)
	self.btn_fashion = viewRoot:getChildAutoType('btn_fashion')
	self.bg_fashion = viewRoot:getChildAutoType('bg_fashion')
	self.btn_arrow = viewRoot:getChildAutoType('btn_arrow')
	self.skinList = viewRoot:getChildAutoType('list_skin')--GList
    self.loader_category = viewRoot:getChildAutoType("loader_category")
    self.loader_career = viewRoot:getChildAutoType("loader_career")
	self.txt_category_career=viewRoot:getChildAutoType("txt_category_career")
    self.btn_ok = viewRoot:getChildAutoType("btn_ok")
    self.txt_name = viewRoot:getChildAutoType("txt_name")
    self.list_hero = viewRoot:getChildAutoType("list_hero")
	self.btn_movement=viewRoot:getChildAutoType("btn_movement")
	local data = json.decode(FileCacheManager.getStringForKey("Hero_Fashion_List", "", nil, true))
	for _,v in ipairs(data) do
		self.heroFashionList[v.heroId] = v.fashionId
	end
	self.list_hero:setItemRenderer(
        function(index, obj)
			local data = self._showHeroList[index + 1]
			local iconLoader = obj:getChild("iconCom"):getChild("iconLoader")
			--如果有时装并且时装未过期，设置时装的半身像
			local fashionId = self.heroFashionList[data.heroId]
			local isHave = ModelManager.PackModel:getFashionBag():getIsHaveFashion(fashionId)
			local fashionCode = ModelManager.HandbookModel.fashionCode
			if fashionId and isHave then 
				iconLoader:setURL(PathConfiger.getHeroCardex(data.heroId,fashionId))
			elseif fashionCode then 
				iconLoader:setURL(PathConfiger.getHeroCardex(data.heroId,fashionCode))
			else
				iconLoader:setURL(PathConfiger.getHeroCardex(data.heroId))
			end
			local c1 = obj:getController("c1")
			local isGot = ModelManager.CardLibModel:isHeroGot(data.heroId)
			c1:setSelectedIndex(isGot and 0 or 1)
			iconLoader:setGrayed(not isGot)
			local fashionIcon = obj:getChildAutoType("fashionIcon")
			local haveFashion = FashionConfiger.getAllFashionInfoByHeroId(data.heroId)
			if haveFashion then 
				fashionIcon:setVisible(true)
			else
				fashionIcon:setVisible(false)
			end
			obj:removeClickListener(100)
			obj:addClickListener(
				function()
					self._selectedIndex = index
					self:updateChoose()
				end)
		end
	)
	
	self.btn_ok:addClickListener(
		function()
		local data = self._showHeroList[self._selectedIndex + 1]
		if not  ModelManager.CardLibModel:isHeroGot(data.heroId) then
			RollTips.show(Desc.card_heroNotGet)
		else
			local fashionData = ModelManager.PackModel:getFashionBag():getIsHaveFashion(self.fashionId)
			local fashionInfo = FashionConfiger.getFashionInfoByFashionId(self.fashionId) 
			if not fashionData and (fashionInfo and fashionInfo.label ~= -1) then 
				RollTips.show(Desc.FashionView_NotGet)
			else
				local itemUUid = fashionData and fashionData:getUuid() or nil
				local function successFunc()
					self.heroFashionList[data.heroId] = self.fashionId
					local info = {}
					for k,v in pairs(self.heroFashionList) do
						table.insert(info,{heroId = k, fashionId = v})
					end
					FileCacheManager.setStringForKey("Hero_Fashion_List",json.encode(info),nil,true) --保存本地，卡牌要显示已聘用的皮肤
					self.list_hero:setNumItems(#self._showHeroList)
					self.playerIcon:setData(data.heroId,nil,nil,self.fashionId)
				end
				ModelManager.HandbookModel:setMainHero(data.heroId,itemUUid,self.fashionId,successFunc)
				--self:closeView()
		        RollTips.show(Desc.player_renamecode9)
			end
		end
	end)

	self.btn_fashion:addClickListener(function ()
		self.isShow = not self.isShow 
		self:setFashionPanel(self.isShow)
	end)
	
	self.btn_arrow:addClickListener(function ()
		self.isShow = not self.isShow 
		self:setFashionPanel(self.isShow)
	end)
	
	self._showHeroList = {}

	for _,config in pairs(DynamicConfigData.t_hero) do
		if config.exhibit == 1 then
			local info = {heroId = config.heroId, star = config.heroStar, category = config.category}
			info["isGot"] = ModelManager.CardLibModel:isHeroGot(config.heroId) and 1 or 0
			table.insert(self._showHeroList, info)
		end
	end
	TableUtil.sortByMap(self._showHeroList, {{key="isGot", asc = true},{key="star", asc = true},{key="category", asc = false} })
	self.list_hero:setNumItems(#self._showHeroList)
	self.list_hero:setSelectedIndex(self._selectedIndex)
	self:updateChoose()
	self:moveTitleToTop()
	

	self.btn_movement:setSelected(not MainUIModel:isLihuiStatic())
	self.btn_movement:addClickListener(function ()
			MainUIModel:setLihuiState(not self.btn_movement:isSelected())
			Dispatcher.dispatchEvent(EventType.set_lihuiPos_state,{static=not self.btn_movement:isSelected()})
	end)
	
	--self.txt_category:setText(Desc["card_category"..HeroInfo.category])
	--self.txt_career:setText(Desc["common_creer"..HeroInfo.professional])
end

function MainHeroSetView:setFashionPanel(isShow)
	if isShow then 
		self.btn_arrow:setRotation(180)
		self:setSkinList()
		self.skinList:resizeToFit(TableUtil.GetTableLen(self.fashionList))
	else
		self.btn_arrow:setRotation(0)
		self.skinList:setNumItems(0)
		self.skinList:resizeToFit(0)
	end
end

function MainHeroSetView:setSkinList()
	self.skinList:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local data  = self.fashionList[index]
        local icon  = obj:getChildAutoType("icon")
       	icon:setURL(PathConfiger.getHeroCard(data.heroCode,data.code))
       	if data.label ~= -1 then 
	       	local isHave = ModelManager.PackModel:getFashionBag():getIsHaveFashion(data.code)
	       	icon:setGrayed(not isHave)
        else
	       	icon:setGrayed(false)
        end
  --       local fashionId = self.heroFashionList[data.heroCode]
  --       local button  = obj:getController("button")

		-- if fashionId and fashionId == data.code then
		-- 	button:setSelectedIndex(1)
		-- end
       	obj:removeClickListener(6)
   		obj:addClickListener(function()
            self.fashionId = data.code
			self.playerIcon:setData(data.heroCode,nil,nil,self.fashionId)
			if data.label ~= -1 then 
	      	 	local isHave = ModelManager.PackModel:getFashionBag():getIsHaveFashion(data.code)
	      	 	if not isHave then 
		      	 	local jump = data.jump
			    	if jump ~= "" then 
				    	local itemInfo = ItemConfiger.getInfoByCode(jump)
						local itemData = ItemsUtil.createItemData({data = {type = itemInfo.type, code = itemInfo.code, amount = 1}})
						ViewManager.open("ItemTips", {codeType = itemInfo.type, id = itemInfo.code, data = itemData})
					end
				end
	       	end
	    end,6)
    end)
    self.skinList:setData(self.fashionList)
    local num = false
    for i,v in ipairs(self.fashionList) do --先遍历有没有穿戴时装
    	local fashionId = self.heroFashionList[v.heroCode]
    	if not fashionId then 
    		fashionId = ModelManager.HandbookModel.fashionCode
    	end
    	local isHave = ModelManager.PackModel:getFashionBag():getIsHaveFashion(fashionId)
    	if (fashionId == v.code) and isHave then 
    		num = i - 1
    		break
    	end
    end
    if not num then 
    	for i,v in ipairs(self.fashionList) do --没有穿戴时装选择默认
			if v.label == -1 then 
				num = i - 1
				break
			end
    	end
    end
    num = num or 0 --避免报错
    self.skinList:setSelectedIndex(num)
end

function MainHeroSetView:set_lihuiPos_state(_,args)
	self.playerIcon:setStatic(args.static)
end


function MainHeroSetView:updateChoose()
	local data = self._showHeroList[self._selectedIndex + 1]
	local config = DynamicConfigData.t_hero[data.heroId]
	self.txt_name:setText(config.heroName)
	self.loader_category:setURL(PathConfiger.getCardCategory(config.category))
	self.loader_career:setURL(PathConfiger.getCardProfessional(config.professional))
	if self.skeletonNode then 
		self.skeletonNode:removeFromParent()
		self.skeletonNode = false
	end
	self.txt_category_career:setText(Desc["card_category"..config.category].." · "..Desc["common_creer"..config.professional])
	--设置时装
	local fashionId = self.heroFashionList[data.heroId]
	local isHave = ModelManager.PackModel:getFashionBag():getIsHaveFashion(fashionId)
	local fashionCode = ModelManager.HandbookModel.fashionCode
	local heroOpertion = ModelManager.HandbookModel.heroOpertion
	if fashionId and isHave then 
		self.playerIcon:setData(data.heroId,nil,nil,fashionId)
	elseif fashionCode then
		self.playerIcon:setData(data.heroId,nil,nil,fashionCode)
	else
		self.playerIcon:setData(data.heroId)
	end
	if heroOpertion == data.heroId then --已聘用皮肤，但换了新设备
		self.fashionId = fashionCode
	else
		self.fashionId = fashionId or false
	end
	local fashionInfo = FashionConfiger.getAllFashionInfoByHeroId(data.heroId)
	if fashionInfo then 
		self.fashionPanel:setVisible(true)
		self.fashionList = FashionConfiger.getAllFashionInfoByHeroId(data.heroId)
		self:setFashionPanel(false)
	else
		self.fashionPanel:setVisible(false)
	end
	-- self.txt_career:setText(Desc["common_creer"..HeroInfo.professional])
end

return MainHeroSetView