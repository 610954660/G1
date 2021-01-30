
local WebPageView,Super = class("WebPageView", Window)


function WebPageView:ctor(args)
	--LuaLogE("RollTips ctor")
	self._packName = "UIPublic_Window"
	self._compName = "WebPageView"
	self._rootDepth = LayerDepth.OverGame
	self.args = args
	
	self.frame = false
end



function WebPageView:_initUI()
	self.frame = self.view:getChildAutoType("frame")
	self.frame:setTitle(self.args.title or "")
	
	if not (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID or CC_TARGET_PLATFORM == CC_PLATFORM_IOS) then
		--仅安卓或者ios支持
		RollTips.show("仅安卓或ios支持内嵌浏览器，请在真机测试")
		return
	end
	--Scheduler.scheduleOnce(0.1, function()
		local img_content = self.view:getChildAutoType("img_content")
		PHPUtil.showWebPage(img_content, self.args.url, img_content:getWidth(), img_content:getHeight(), 0, 0)
	--end)
end


return WebPageView