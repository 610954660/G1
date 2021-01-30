
local RollTipsView,Super = class("RollTipsView", View)


function RollTipsView:ctor(args)
	--LuaLogE("RollTips ctor")
	self._packName = "UIPublic_Window"
	self._compName = "RollTipsView"
	self._rootDepth = args._rootDepth or LayerDepth.RollTips
	self.args = args
	self.title = false
	self._isFullScreen = false
end



function RollTipsView:_initUI()
	--LuaLogE("RollTipsView _initUI")


	--LoginModel:readSavedServerInfo()
	self:centerScreen()
	
	self.title = self.view:getChildAutoType("title")
	local bg = self.view:getChildAutoType("bg")
	self.title:setText(self.args.text)
	self.title:center();
	bg:setWidth(self.title:getTextSize().width+80)
	bg:center();
	--print(33,"title = ",self.title:getWidth(),self.title:getHeight())
	--print(33,"title = ",self.title:getSize().width)
	local time = self.args.time or 1
	local action1 = cc.DelayTime:create(time)
	local action2 = cc.Spawn:create(cc.MoveBy:create(0.5,cc.p(0,20)),cc.FadeOut:create(0.5))
	local action3 = cc.CallFunc:create(function()
			RollTips.close(self.args.viewName)
	end)
	local action = cc.Sequence:create(action1,action2,action3)
	self.view:displayObject():runAction(action)
	
end


return RollTipsView