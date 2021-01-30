
-- 头像设置
-- added by wyang


local PlayerHeadBaseView = class("PlayerHeadBaseView", MutiWindow)

function PlayerHeadBaseView:ctor()
    self._packName = "Player"
    self._compName = "PlayerHeadBaseView"
	self._tabBarName = "list_page"
	self._rootDepth = LayerDepth.PopWindow
	self._showParticle=true
	
	self.pageView = false
	self.list_page = false
	self.frame = false
	
	self.redArr = {
		"V_HEAD",
		"V_HEAD_BORDER",
	}

    self:setMoneyType(self.showMoneyTypeDefault)
end

function PlayerHeadBaseView:_initUI( )
	self:_initVM()
	self.pageView = self.view:getChildAutoType("pages")
	self.list_page = self.view:getChildAutoType("list_page")

end
function PlayerHeadBaseView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	vmRoot.PlayerHeadView = viewNode:getChildAutoType("PlayerHeadView");
	vmRoot.PlayerHeadFrameView = viewNode:getChildAutoType("PlayerHeadFrameView");
end

function PlayerHeadBaseView:Vip_openRecharge()
	self:_setPage("DailyGiftBagView")
end


return PlayerHeadBaseView;