-- add by wyang
-- 图片帮助模板

local PublicPicHelpPanel = class("PublicPicHelpPanel", Window)

function PublicPicHelpPanel:ctor()
    self._packName = "UIPublic_Window"
    self._compName = "PublicPicHelpPanel"
    self._rootDepth = LayerDepth.PopWindow
    self.fromPos = self._args.fromPos or cc.vertex2F(0, 0)
end

function PublicPicHelpPanel:_initUI()
    local root = self
    local rootView = self.view
	self.helpPanelMask = self.view:getChildAutoType("blackbg");
    self.helpPanel = self.view:getChildAutoType("helpPanel");
end

function PublicPicHelpPanel:_initEvent()
    self.helpPanelMask:removeClickListener()
	self.helpPanelMask:addClickListener(function( ... )
		self:closeHelpPanel()
	end)
    self:showHelpPanel()
end

function PublicPicHelpPanel:showHelpPanel()
	self.helpPanel:getChildAutoType("img_help"):setURL(self._args.picUrl)
	self.helpPanel:setVisible(true)
	self.helpPanelMask:setVisible(true)
	self.helpPanel:setScaleX(0.01)
	self.helpPanel:setScaleY(0.01)
	self.helpPanel:setPosition(self.fromPos.x, self.fromPos.y)
	local fromScale = self.helpPanel:getScaleX()
	
	-- self.view:setChildIndex(self.helpPanelMask,self.view:numChildren() - 1)
	-- self.view:setChildIndex(self.helpPanel,self.view:numChildren())
    Scheduler.scheduleNextFrame(function()
        if (tolua.isnull(self.view)) then return end
        TweenUtil.scaleTo(self.helpPanel, {from = Vector2(fromScale,fromScale), to = Vector2(1, 1), time = 0.3})
        TweenUtil.moveTo(self.helpPanel, {from = self.helpPanel:getPosition(), to = Vector2(self.view:getWidth()/2, self.view:getHeight()/2), time = 0.3})
    end)
end

function PublicPicHelpPanel:closeHelpPanel()
    local fromScale = self.helpPanel:getScaleX()
	TweenUtil.moveTo(self.helpPanel, {from = self.helpPanel:getPosition(), to = self.fromPos, time = 0.3})
    TweenUtil.scaleTo(self.helpPanel, {from = Vector2(fromScale,fromScale), to = Vector2(0.01, 0.01), time = 0.3, onComplete=function()
        self:closeView()
	end})
end

return PublicPicHelpPanel