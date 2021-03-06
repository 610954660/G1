--Name : GetTyChangeView.lua
--Author : generated by FairyGUI
--Date : 2020-7-29
--Desc : 

local GetTyChangeView,Super = class("GetTyChangeView", Window)
local  HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
function GetTyChangeView:ctor()
	--LuaLog("GetTyChangeView ctor")
	self._packName = "GetCards"
	self._compName = "GetTyChangeView"
	--self._rootDepth = LayerDepth.Window
	self.listCellArr = {}
	self.heroData = false
	self.curLeftData = false
	self.curClickUuid = false
	self.btn_category = {}
	self.lihuiDisplayLeft = false
	self.lihuiDisplayRight = false
	self.rightHeroData= false
	self.btn_zhObj = false
end

function GetTyChangeView:_initEvent( )
	self.list:setVirtual();
	self.list:setItemRenderer(function(idx, obj)
			self.listCellArr[idx+1] = obj
			self:upHeroListItem(idx, obj);
	end)
	
	--转换
	self.btn_zh:addClickListener(function ()
		-- printTable(1,self.curLeftData)
		if self.curLeftData then
			--看是否锁定
			if self.curLeftData.locked then
				RollTips.show(Desc.GetCard_Text12)
				return
			end
			local params = {}
			params.heroUuid = self.curLeftData.uuid
			params.onSuccess = function (res )
				-- printTable(1,"服务器转换返回数据",res)
				if not res.toHeroId then
					if self.curLeftData and self.curLeftData.uuid then
						--local allCard = ModelManager.HeroPalaceModel:getChooseUuids()
						if HeroPalaceModel:isInHeroPalaceABGroup(self.curLeftData.uuid) then
							RollTips.show(Desc.GetCard_Text13)
						end
					end
					return
				end
				if res.heroUuid and res.heroUuid ~="" and res.heroUuid ~=0 then
					local data = CardLibModel:getHeroByUid(res.heroUuid)
					if data then
						self.curLeftData = data
					end
				end
					
				if res.toHeroId and res.toHeroId ~="" and res.toHeroId ~=0 then
					local heroConfig = HeroConfiger.getHeroInfoByID(res.toHeroId)
					-- printTable(1,heroConfig)
					print(1,self.rightHeroData)
					self.rightHeroData = heroConfig
				end
				if tolua.isnull(self.view) then return end	
				self:updateRightPanel()
			end
			RPCReq.HeroLottery_HeroTransform(params, params.onSuccess)
		end
	end)
	
	self.btn_save:addClickListener(function()
		if self.curLeftData.locked then
			RollTips.show(DescAuto[119]) -- [119]="该探员需要解锁后才可进行保存"
			return
		end
		local params = {}
		params.heroUuid = self.curLeftData.uuid
		params.onSuccess = function (res )
        --    printTable(1,"保存转换",res)
			if res.uuid and res.uuid ~="" and res.uuid ~=0 then
				local heroName = self.curLeftData.heroDataConfiger.heroName
				local heroData = CardLibModel:getHeroByUid(res.uuid)
				local heroName2 = heroData.heroDataConfiger.heroName
				local str = string.format(Desc.GetCard_Text14,heroName,heroName2)
				RollTips.show(str)
				self.curLeftData = false
				self.curClickUuid = false
				GetCardsModel:setTyChangeUuid( 0 )
				local category = GetCardsModel:getTyChangeCatogery(  )
				self:changeCategory(category)
			end
			if res.code ~="" and res.code ~=0 then
				self.rightHeroData = false
				ViewManager.open("GetHeroCardShowView",{data = {type=4,code=res.code,acount=1}})
			end
			if tolua.isnull(self.view) then return end
			self:updatePanel()
		end
		RPCReq.HeroLottery_SaveHeroTransform(params, params.onSuccess)
	end)
	
	self.btn_cancel:addClickListener(function()
        local params = {}
		params.heroUuid = self.curLeftData.uuid
		params.onSuccess = function (res )
        --    printTable(1,"取消成功",res)
			-- if res.uuid and res.uuid ~="" and res.uuid ~=0 then
			-- 	self.curLeftData = false
			-- end
			-- if res.code ~="" and res.code ~=0 then
			-- 	self.rightHeroData = false
			-- 	ViewManager.open("GetHeroCardShowView",{data = {type=4,code=res.code,acount=1}})
			-- end
			self.rightHeroData = false
			if tolua.isnull(self.view) then return end
			self:updatePanel()
		end
		RPCReq.HeroLottery_RemoveHeroTransform(params, params.onSuccess)
	end)

	self.btn_zhObj = BindManager.bindCostButton(self.btn_zh)
	self.btn_zh:getChildAutoType("icon"):setScale(0.7,0.7)
    


    local  uuid = GetCardsModel:getTyChangeUuid( )
    if uuid~=0 then
    	self.curClickUuid = uuid
    end

    local category = GetCardsModel:getTyChangeCatogery(  )
	self.btn_category[category]:setSelected(true);
	self:changeCategory(category);

    if self.curClickUuid then
        --获取服务器数据
		local params = {}
		params.heroUuid = self.curClickUuid
		params.onSuccess = function (res )
			-- printTable(1,"获取服务器数据",res)
			if res.heroUuid and res.heroUuid ~="" and res.heroUuid ~=0 then
				local data = CardLibModel:getHeroByUid(res.heroUuid)
				if data then
					self.curLeftData = data
				end
			end
			if res.toHeroId ~="" and res.toHeroId ~=0 then
				local heroConfig = HeroConfiger.getHeroInfoByID(res.toHeroId)
				self.rightHeroData = heroConfig
			end
			if tolua.isnull(self.view) then return end
			self:updatePanel()
		end
		RPCReq.HeroLottery_GetHeroTransform(params, params.onSuccess)
    else
    	self:updatePanel()
    end
    
end

-- 改变种族 -0 全 1 仙 魔 兽 人 械
function GetTyChangeView:changeCategory(idx)
    self.heroData = {}
	local temp =  CardLibModel:getCardByCategory(idx, nil, 4, nil,true)
	--local allCard = ModelManager.HeroPalaceModel:getChooseUuids()
	if idx==0 then
		for k,v in ipairs(temp) do
			if v.heroDataConfiger.category>=3 and v.star>=4 and v.star<=5 then

				if not HeroPalaceModel:isInHeroPalaceABGroup(v.uuid) then
					table.insert(self.heroData,v)
				end
			end
		end
	else
		for k,v in ipairs(temp) do
			if  v.star>=4 and v.star<=5 then
				if not HeroPalaceModel:isInHeroPalaceABGroup(v.uuid) then
					table.insert(self.heroData,v)
				end
			end
		end
	end
	table.sort(self.heroData,function(a,b)
		local num1 = 5
		local trueFive = a.heroDataConfiger.trueFive
		local star = a.heroDataConfiger.heroStar
		if trueFive == 1 and star == 5 then
			num1 = 1
		elseif trueFive == 2 and star == 5 then
			num1 = 2
		elseif trueFive == 0 and star == 5 then
			num1 = 3
		elseif trueFive == 0 and a.star == 5 then
			num1 = 4
		else
			num1 = 5
		end
		
		local num2 = 4
		local trueFive = b.heroDataConfiger.trueFive 
		local star = b.heroDataConfiger.heroStar
		if trueFive == 1 and star == 5 then
			num2 = 1
		elseif trueFive == 2 and star == 5 then
			num2 = 2
		elseif trueFive == 0 and star == 5 then
			num2 = 3
		elseif trueFive == 0 and b.star == 5 then
		    num2 = 4
		else
			num2 = 5
		end
		
		--排序 真5>假5>4星
		if num1 == num2 then
			if a.heroDataConfiger.heroStar ==  b.heroDataConfiger.heroStar then
				return a.heroDataConfiger.heroId >b.heroDataConfiger.heroId
			else
				return a.heroDataConfiger.heroStar >  b.heroDataConfiger.heroStar
			end
		else
			return num1 < num2
		end
	end)
	self.list:setData(self.heroData)
	-- self.list:resizeToFit(#self.heroData)
	GetCardsModel:setTyChangeCatogery(idx)
end

function GetTyChangeView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:GetCards.GetTyChangeView
		vmRoot.btn_cancel = viewNode:getChildAutoType("$btn_cancel")--Button
		vmRoot.leftNode = viewNode:getChildAutoType("$leftNode")--
		vmRoot.btn_save = viewNode:getChildAutoType("$btn_save")--Button
		vmRoot.list = viewNode:getChildAutoType("$list")--list
		vmRoot.categoryChoose = viewNode:getChildAutoType("$categoryChoose")--
		vmRoot.btn_zh = viewNode:getChildAutoType("$btn_zh")--Button
		vmRoot.rightNode = viewNode:getChildAutoType("$rightNode")--
	--{vmFieldsEnd}:GetCards.GetTyChangeView
	--Do not modify above code-------------
end

function GetTyChangeView:set_lihuiPos_Event(_,params)
	if not params then
		self.canshuNode:setVisible(true)
		return
	end
	local posx = self.canshuNode:getChildAutoType("posx")
	local posy = self.canshuNode:getChildAutoType("posy")
	local scale = self.canshuNode:getChildAutoType("scale")
	local pz_posx = self.canshuNode:getChildAutoType("pz_posx")
	local pz_posy = self.canshuNode:getChildAutoType("pz_posy")
	scale:setText(0.38)
	posx:setText(params.pos.x)
	posy:setText(params.pos.y)
	pz_posx:setText(params.pos.x-269)
	pz_posy:setText(params.pos.y-170)
end


function GetTyChangeView:_initUI( )
	self:_initVM()
	self.canshuNode = self.view:getChildAutoType("n111")
	if LoginModel:isTestAgent() then
		self.canshuNode:setDraggable(true)
	else
		self.canshuNode:setVisible(false)
	end


	self:setBg("ty_changebg.jpg")
	self.spineNodeLeft = self.leftNode:getChildAutoType("lihuiDisplay")
	--self.lihuiDisplayLeft = BindManager.bindLihuiDisplay(self.spineNodeLeft)
	
	
	self.spineNodeRight = self.rightNode:getChildAutoType("lihuiDisplay")
	self.lihuiDisplayLeft = BindManager.bindLihuiDisplay(self.spineNodeLeft)
	self.lihuiDisplayRight = BindManager.bindLihuiDisplay(self.spineNodeRight)
	self.lihuiDisplayLeft:setCanEditPos()
	self.lihuiDisplayRight:setCanEditPos()
	-- self.lihuiDisplayRight.view:setScale(0.38,0.38)

	self.rightCtrl = self.view:getController("rightCtrl")
	self.showMoneyType = {
		{type = GameDef.ItemType.Item, code = 10000064},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold}, 
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond}
	} --显示的货币类型，从左到右排列
	self.moneyComp = self.view:getChild("moneyComp") 
    self.moneyBar = BindManager.bindMoneyBar(self.moneyComp)
    self.moneyBar:setData(self.showMoneyType)

	-- 种族选择
	for idx = 0, 5 do
		self.btn_category[idx] = self.categoryChoose:getChildAutoType("category"..idx);
	end
	
	-- 种族切页
	for idx = 0, 5 do
		self.btn_category[idx]:addClickListener(function()
			self:changeCategory(idx);
		end)
	end
end


function GetTyChangeView:upHeroListItem(idx, obj)
	local data = self.heroData[idx + 1];
	local ctrl = obj:getController("c1");
	if (not obj.lua_sript) then
		obj.lua_sript = BindManager.bindCardCell(obj);
	end
	obj.lua_sript:setData(data, true);
	ctrl:setSelectedIndex(0);
	if data.locked then
		ctrl:setSelectedIndex(7);
	else
		-- print(1,self.curClickUuid)
		if self.curClickUuid then
			if data.uuid ==self.curClickUuid   then
				self:updateListCell()
				self:updateLeftPanel()
				ctrl:setSelectedIndex(2);
			end
		end
	end
	
	obj:removeClickListener(22);
	obj:addClickListener(function()
		if ctrl:getSelectedIndex()==7 then
			RollTips.show(Desc.GetCard_Text15)
			return
		end
		if data.uuid == self.curClickUuid then
			return
		end
		self.curClickUuid = data.uuid
		GetCardsModel:setTyChangeUuid(self.curClickUuid)
		self:requestAddHero()
		self:updateListCell()
		ctrl:setSelectedIndex(2);
	end,22)

end

function GetTyChangeView:updateListCell( ... )
	for k,v in pairs(self.listCellArr) do
		local ctrl = v:getController("c1");
		if ctrl:getSelectedIndex()~=7 then
			ctrl:setSelectedIndex(0);
		end
		
	end
end



function GetTyChangeView:requestAddHero()
	if self.curClickUuid then
		local params = {}
		params.heroUuid = self.curClickUuid
		params.onSuccess = function (res )
			-- printTable(1,"获取服务器数据1111",res)
			if (not res.heroUuid) or res.heroUuid==""  then
				local params2 = {}
				params2.heroUuid = self.curClickUuid
				params2.onSuccess = function (res2 )
					-- printTable(1,"服务器 添加特异转换",res2)
					if res2.heroUuid and res2.heroUuid ~="" and res2.heroUuid ~=0 then
						local data = CardLibModel:getHeroByUid(res2.heroUuid)
						if data then
							self.curLeftData = data
						end
					end

					if res.toHeroId ~="" and res.toHeroId ~=0 then
						local heroConfig = HeroConfiger.getHeroInfoByID(res.toHeroId)
						self.rightHeroData = heroConfig
					else
						self.rightHeroData = false
					end
					if tolua.isnull(self.view) then return end
					self:updatePanel()
				end
				RPCReq.HeroLottery_AddHeroTransform(params2, params2.onSuccess)
			else
				if res.heroUuid and res.heroUuid ~="" and res.heroUuid ~=0 then
					local data = CardLibModel:getHeroByUid(res.heroUuid)
					if data then
						self.curLeftData = data
					end
				end
				if res.toHeroId ~="" and res.toHeroId ~=0 then
					local heroConfig = HeroConfiger.getHeroInfoByID(res.toHeroId)
					self.rightHeroData = heroConfig
				else
					self.rightHeroData = false
				end
				if tolua.isnull(self.view) then return end
				self:updatePanel()
			end
		end
		RPCReq.HeroLottery_GetHeroTransform(params, params.onSuccess)
	end
end

--更新整个页面
function GetTyChangeView:updatePanel()
	self:updateLeftPanel()
	self:updateRightPanel()
end

--更新左边
function GetTyChangeView:updateLeftPanel()
	local leftShowCtrl = self.leftNode:getController("showCtrl")
	-- local txt_level = self.leftNode:getChildAutoType("txt_level")
	local txt_name = self.leftNode:getChildAutoType("txt_name")
	local img_category = self.leftNode:getChildAutoType("img_category")
	local cardStar = self.leftNode:getChildAutoType("cardStar")
	cardStar = BindManager.bindCardStar(cardStar)
	local loader_career = self.leftNode:getChildAutoType("loader_career")

	if self.curLeftData then
		leftShowCtrl:setSelectedIndex(2)
		-- txt_level:setText(self.curLeftData.level)
		img_category:setURL(PathConfiger.getCardCategory(self.curLeftData.heroDataConfiger.category))
		cardStar:setData(self.curLeftData.star)
		txt_name:setText(self.curLeftData.heroDataConfiger.heroName)
		loader_career:setURL(PathConfiger.getCardProfessionalWhite(self.curLeftData.heroDataConfiger.professional))
		local pos = GetCardsModel:getOffsetById( self.curLeftData.code )
		-- printTable(1,"pos",pos)
		self.lihuiDisplayLeft:setPosition(269,170)
		local fashionId = self.curLeftData.fashion and self.curLeftData.fashion.code
		self.lihuiDisplayLeft:setData(self.curLeftData.code, nil,nil,fashionId)
		if pos then
			self.lihuiDisplayLeft:setPosition(269+pos.x,170+pos.y)
		end

	else
		self.lihuiDisplayLeft:setPosition(269,170)
		self.lihuiDisplayLeft:setData(0)
		leftShowCtrl:setSelectedIndex(0)
	end
end

--更新右边
function GetTyChangeView:updateRightPanel()
	local rightShowCtrl = self.rightNode:getController("showCtrl")
	local leftRightCtrl = self.rightNode:getController("leftRightCtrl")
	-- local txt_level = self.rightNode:getChildAutoType("txt_level")
	local txt_name = self.rightNode:getChildAutoType("txt_name")
	local img_category = self.rightNode:getChildAutoType("img_category")
	local cardStar = self.rightNode:getChildAutoType("cardStar")
	cardStar = BindManager.bindCardStar(cardStar)

	local img_category_wh = self.rightNode:getChildAutoType("img_category_wh")
	local cardStar_wh = self.rightNode:getChildAutoType("cardStar_wh")
	cardStar_wh = BindManager.bindCardStar(cardStar_wh)
    local loader_career = self.rightNode:getChildAutoType("loader_career")

	if self.rightHeroData then
		-- printTable(1,self.rightHeroData)
		self.rightCtrl:setSelectedIndex(1)
		rightShowCtrl:setSelectedIndex(2)
		leftRightCtrl:setSelectedIndex(1)
		-- txt_level:setText(self.curLeftData.level)
		img_category:setURL(PathConfiger.getCardCategory(self.curLeftData.heroDataConfiger.category))
		cardStar:setData(self.curLeftData.star)
		txt_name:setText(self.rightHeroData.heroName)
		loader_career:setURL(PathConfiger.getCardProfessionalWhite(self.rightHeroData.professional))
		local pos = GetCardsModel:getOffsetById( self.rightHeroData.code )
		self.lihuiDisplayRight:setPosition(269,170)
		self.lihuiDisplayRight:setData(self.rightHeroData.heroId,pos)
		if pos then
			self.lihuiDisplayRight:setPosition(269+pos.x,170+pos.y)
		end
	else
		self.lihuiDisplayRight:setPosition(269,170)
		self.lihuiDisplayRight:setData(0)
		if self.curLeftData then
			self.rightCtrl:setSelectedIndex(0)
			rightShowCtrl:setSelectedIndex(1)
			local config = GetCardsModel:getChangeConfigByType(self.curLeftData.heroDataConfiger.category,self.curLeftData.star)
		    self.btn_zhObj:setData(config.cost[1])
		    --显示阵容
			img_category_wh:setURL(PathConfiger.getCardCategory(self.curLeftData.heroDataConfiger.category))
			cardStar_wh:setData(self.curLeftData.star)
	    else
			self.rightCtrl:setSelectedIndex(2)
			rightShowCtrl:setSelectedIndex(3)

		end
		
	end
end




return GetTyChangeView
