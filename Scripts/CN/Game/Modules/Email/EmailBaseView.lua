
-- added by zn
-- 邮件基础界面

local EmailBaseView = class("EmailBaseView", MutiWindow)

function EmailBaseView:ctor()
    self._packName = "Email"
    self._compName = "EmailBaseView"
	self._tabBarName = "list_page"
	self._showParticle=true
	
	self.pageView = false
	self.list_page = false
	self.frame = false
	-- self.showMoneyTypeDefault = {
	-- 		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold}, 
	-- 		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond}
	-- 	}
	self.redArr = {
		"V_MAIL_NEW",
	}
		
	-- self.showMoneyTypeUpgrade = {
	-- 		{type = GameDef.ItemType.Item, code = 10000006},
	-- 		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold}, 
	-- 		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond}
	-- 	}
end

function EmailBaseView:_initUI( )
	self:_initVM()
	self:setBg("bg_generalA.jpg")
	self.pageView = self.view:getChildAutoType("page")
	self.list_page = self.view:getChildAutoType("list_page")
	self.frame = self.view:getChildAutoType("frame")
	-- self:createComponentByPageName("EmailView");
	
	self:setTabBarData({{},});
end
function EmailBaseView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:CardSystem.EmailBaseView
		vmRoot.EmailView = viewNode:getChildAutoType("EmailView");
	--{vmFieldsEnd}:CardSystem.EmailBaseView
	--Do not modify above code-------------
end


-- function EmailBaseView:cardView_hideUI(event, isHide)
-- 	self.pageView:setVisible(not isHide)
-- 	self.leftBtnList:setVisible(not isHide)
-- 	self.frame:getChildAutoType("leftTop"):setVisible(not isHide)
-- 	self.frame:getChildAutoType("moneyComp"):setVisible(not isHide)
	
-- end


-- function EmailBaseView:onShowPage(page)
-- 	if page == "CardInfoDetailView" then
-- 		self:setMoneyType(self.showMoneyTypeUpgrade)
-- 	else
-- 		self:setMoneyType(self.showMoneyTypeDefault)
-- 	end
-- end

function EmailBaseView:_exit()
    -- --ModelManager.CardLibModel:clearupStarInfo()
	-- if ModelManager.CardLibModel then
	-- 	ModelManager.CardLibModel:clearupStarInfo()
	-- end
end


return EmailBaseView;