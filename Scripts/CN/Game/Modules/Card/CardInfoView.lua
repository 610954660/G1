---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: ljj
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local ViewGroups = require "Game.UI.ViewGroups"
local CardInfoView, Super = class("CardInfoView", MutiWindow)
function CardInfoView:ctor()
    self._packName = "CardSystem"
    self._compName = "CardInfoView"
	self._tabBarName = "leftBtnList"
	self._showParticle=true
	
	self.pageView = false
	self.leftBtnList = false
	self.frame = false
	self.uuid = 0
	self.showMoneyTypeDefault = {
			{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold}, 
			{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond}
		} 
		
	self.showMoneyTypeUpgrade = {
			{type = GameDef.ItemType.Item, code = 10000006},
			{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold}, 
			{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond}
		}
		
	self.showMoneyTypeStepUp = {
			{type = GameDef.ItemType.Item, code = 10000007},
			{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold}, 
			{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond}
		}
	
	if not ModelManager.CardLibModel.curCardStepInfo then
		ModelManager.CardLibModel:setCardsByCategory(0)
		local CardList=ModelManager.CardLibModel:getHeroInfoToIndex(true, 1)
		ModelManager.CardLibModel.curCardStepInfo = CardList[1]
	end
	
end

function CardInfoView:_initUI( )
	self:_initVM()
	self:moveTitleToTop()
	--self:setBg("bg_cardInfo.jpg")
	self.pageView = self.view:getChildAutoType("pageView")
	self.leftBtnList = self.view:getChildAutoType("leftBtnList")
	self.frame = self.view:getChildAutoType("frame")
	self:createComponentByPageName("CardInfoShowView")
	
	self:setTabBarData({{},{mid=ModuleId.Equipment.id},{mid=ModuleId.UpStart.id},{mid=ModuleId.CardTalent.id}, {mid=ModuleId.EmblemView.id}}) -- , {mid=ModuleId.EmblemView.id}
	self.leftBtnList:setItemRenderer(function(index,obj)
		obj:getController("size"):setSelectedIndex(1)
		if index == 0 then
			RedManager.register("V_CardDetail"..self.uuid, obj:getChild("img_red"))
		elseif index == 1 then
			RedManager.register("V_CardEquip"..self.uuid, obj:getChild("img_red"), ModuleId.Equipment.id)
		elseif index == 2 then
			RedManager.register("V_CardStarUp"..self.uuid, obj:getChild("img_red"))
		elseif index == 3 then
			RedManager.register("V_CardTalet"..self.uuid, obj:getChild("img_red"))
		elseif index == 4 then
			RedManager.register("V_Emblem"..self.uuid, obj:getChild("img_red"))
		end
	end)
	self:setDetailsById()
end

function CardInfoView:cardView_updateInfo(_, data)
	self:setDetailsById()
end

function CardInfoView:setDetailsById()
	local heroInfo = ModelManager.CardLibModel.curCardStepInfo
	self.uuid = heroInfo.uuid
	if self.leftBtnList then 
		self.leftBtnList:setNumItems(self.leftBtnList:getNumItems()) 
		if (self.leftBtnList:getSelectedIndex() == 3) then
			if (not TalentModel:checkModelOpen(heroInfo)) then
				self.leftBtnList:setSelectedIndex(0);
				self:_setPage(0);
			end
		end
		if (self.leftBtnList:getSelectedIndex() == 4) then -- 纹章
			if (not EmblemModel:checkModelOpen(heroInfo, false)) then
				self.leftBtnList:setSelectedIndex(0);
				self:_setPage(0);
			end
		end
	end
	
	self:setBg("cardInfoBg_"..heroInfo.heroDataConfiger.category..".jpg")
end


function CardInfoView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:CardSystem.CardInfoView
		vmRoot.CardInfoDetailView = viewNode:getChildAutoType("$CardInfoDetailView")--list
		vmRoot.CardInfoStarUpView = viewNode:getChildAutoType("$CardInfoStarUpView")
		vmRoot.CardInfoShowView = viewNode:getChildAutoType("$CardInfoShowView")
		vmRoot.EquipmentView = viewNode:getChildAutoType("$EquipmentView")
		-- vmRoot.CardInfoTalentView = viewNode:getChildAutoType("$CardInfoTalentView")
	--{vmFieldsEnd}:CardSystem.CardInfoView
	--Do not modify above code-------------
end


function CardInfoView:cardView_hideUI(event, isHide)
	self.pageView:setVisible(not isHide)
	self.leftBtnList:setVisible(not isHide)
	self.frame:getChildAutoType("leftTop"):setVisible(not isHide)
	self.frame:getChildAutoType("moneyComp"):setVisible(not isHide)
	
end

function CardInfoView:__checkPageModule(mid,page,backPage)

	local moduleId = mid
	if not moduleId and page then
		local info = ViewGroups[page]
		if  info and info.mid then
			moduleId = info.mid
		end
	end

	if moduleId then
		if (moduleId == ModuleId.CardTalent.id) then
			local heroInfo = ModelManager.CardLibModel.curCardStepInfo;
			if (not TalentModel:checkModelOpen(heroInfo, true)) then
				if backPage then
					self:_setPage(backPage,false)
				end
				return false;
			end
		end
		if (moduleId == ModuleId.EmblemView.id) then
			local heroInfo = ModelManager.CardLibModel.curCardStepInfo;
			if (not EmblemModel:checkModelOpen(heroInfo)) then
				if backPage then
					self:_setPage(backPage,false)
				end
				return false
			end
		end
		if not ModuleUtil.moduleOpen(moduleId,true) then
			if backPage then
				self:_setPage(backPage,false)
			end
			return false
		end
	end

	return true
end

function CardInfoView:onShowPage(page)
	if page == "CardInfoDetailView" then
		--self:setMoneyType(self.showMoneyTypeUpgrade)
	else
		self:setMoneyType(self.showMoneyTypeDefault)
	end
end

function CardInfoView:cardView_setMoneyType(evnt, data)
	if data == "upgrade" then
		self:setMoneyType(self.showMoneyTypeUpgrade)
	elseif data == "stepUp" then
		self:setMoneyType(self.showMoneyTypeStepUp)
	end
end

function CardInfoView:_exit()
    --ModelManager.CardLibModel:clearupStarInfo()
	if ModelManager.CardLibModel then
		ModelManager.CardLibModel:clearupStarInfo()
	end
end

function CardInfoView:_enter()
end

return CardInfoView
