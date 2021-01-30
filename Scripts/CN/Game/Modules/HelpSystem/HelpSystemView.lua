
-- added by zn
-- 帮助系统

local HelpSystemView,Super = class("HelpSystemView", MutiWindow)

function HelpSystemView:ctor()
    self._packName = "HelpSystem"
    self._compName = "HelpSystemView"
	self._tabBarName = "list_page"
	self._showParticle=true
	
	self.pageView = false
	self.list_page = false
	self.frame = false
	-- self.showMoneyTypeDefault = {
    --     -- {type = GameDef.ItemType.Money, code = GameDef.MoneyType.Friend},
    --     {type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold}, 
    --     {type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond}
	-- }
		
	self.redArr = {
		"",
		"",
		"",
		"",
	}

    -- self:setMoneyType(self.showMoneyTypeDefault)
end

function HelpSystemView:_initUI( )
	self:_initVM()
	self:setBg("bg_default.jpg")
	-- self:setBg("bg_HelpSystem.png")
	self.pageView = self.view:getChildAutoType("page")
	self.list_page = self.view:getChildAutoType("list_page")
	self.frame = self.view:getChildAutoType("frame")
	-- self:createComponentByPageName("HelpSysStrongView");
	
	-- self:setTabBarData({{},});
end
function HelpSystemView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:CardSystem.HelpSystemView
        vmRoot.HelpSysStrongView = viewNode:getChildAutoType("HelpSysStrongView");
        vmRoot.HelpSysQuestionView = viewNode:getChildAutoType("HelpSysQuestionView");
        vmRoot.HelpSysRecomView = viewNode:getChildAutoType("HelpSysRecomView");
	--{vmFieldsEnd}:CardSystem.HelpSystemView
	--Do not modify above code-------------
end


-- function HelpSystemView:cardView_hideUI(event, isHide)
-- 	self.pageView:setVisible(not isHide)
-- 	self.leftBtnList:setVisible(not isHide)
-- 	self.frame:getChildAutoType("leftTop"):setVisible(not isHide)
-- 	self.frame:getChildAutoType("moneyComp"):setVisible(not isHide)
	
-- end


-- function HelpSystemView:onShowPage(page)
-- 	if page == "CardInfoDetailView" then
-- 		self:setMoneyType(self.showMoneyTypeUpgrade)
-- 	else
-- 		self:setMoneyType(self.showMoneyTypeDefault)
-- 	end
-- end

-- function HelpSystemView:_exit()
    -- --ModelManager.CardLibModel:clearupStarInfo()
	-- if ModelManager.CardLibModel then
	-- 	ModelManager.CardLibModel:clearupStarInfo()
	-- end
-- end
--监听多页切换，并构建
function HelpSystemView:onViewControllerChanged()
	if self.viewCtrl:getSelectedPage() == "HelpSysGroupView" then
		ViewManager.open("HelpSysGroupView")
		self:_setPage(self._prePage,false)
	else
		Super.onViewControllerChanged(self)
	end
end

return HelpSystemView;