
-- added by zn
-- 邮件基础界面

local FriendBaseView = class("FriendBaseView", MutiWindow)

function FriendBaseView:ctor()
    self._packName = "Friend"
    self._compName = "FriendBaseView"
	self._tabBarName = "list_page"
	self._showParticle=true
	
	self.pageView = false
	self.list_page = false
	self.frame = false
	self.showMoneyTypeDefault = {
        -- {type = GameDef.ItemType.Money, code = GameDef.MoneyType.Friend},
        {type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold}, 
        {type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond}
	}

	self.showMoneyTypeFriend = {
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Friend},
        {type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold}, 
        {type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond}
	}
		
	self.redArr = {
		"V_FRIEND",
		"V_FRIEND_APPLY",
	}

    self:setMoneyType(self.showMoneyTypeDefault)
end

function FriendBaseView:_initUI( )
	self:_initVM()
	-- self:setBg("handbook_hero.jpg")
	self:setBg("bg_default.jpg")
	self.pageView = self.view:getChildAutoType("page")
	self.list_page = self.view:getChildAutoType("list_page")
	self.frame = self.view:getChildAutoType("frame")
	-- self:createComponentByPageName("FriendView");
	
	-- self:setTabBarData({{},});
end
function FriendBaseView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:CardSystem.FriendBaseView
        vmRoot.FriendView = viewNode:getChildAutoType("FriendView");
        vmRoot.FriendapplyView = viewNode:getChildAutoType("FriendapplyView");
        vmRoot.FriendsearchView = viewNode:getChildAutoType("FriendsearchView");
        vmRoot.FriendblacklistView = viewNode:getChildAutoType("FriendblacklistView");
	--{vmFieldsEnd}:CardSystem.FriendBaseView
	--Do not modify above code-------------
end


-- function FriendBaseView:cardView_hideUI(event, isHide)
-- 	self.pageView:setVisible(not isHide)
-- 	self.leftBtnList:setVisible(not isHide)
-- 	self.frame:getChildAutoType("leftTop"):setVisible(not isHide)
-- 	self.frame:getChildAutoType("moneyComp"):setVisible(not isHide)
	
-- end


function FriendBaseView:onShowPage(page)
	if page == "FriendView" then
		self:setMoneyType(self.showMoneyTypeFriend)
	else
		self:setMoneyType(self.showMoneyTypeDefault)
	end
end

-- function FriendBaseView:_exit()
    -- --ModelManager.CardLibModel:clearupStarInfo()
	-- if ModelManager.CardLibModel then
	-- 	ModelManager.CardLibModel:clearupStarInfo()
	-- end
-- end


return FriendBaseView;