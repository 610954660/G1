local HeroBossResultView, Super = class("HeroBossResultView", Window)
function HeroBossResultView:ctor(args)
	self._packName = "HeroBossActivity"
	self._compName = "HeroBossResultView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true

	self.t_NewHeroBossReward = DynamicConfigData.t_NewHeroBossReward
	self.t_NewHeroActivity = DynamicConfigData.t_NewHeroActivity
	self.t_NewHeroShop = DynamicConfigData.t_NewHeroShop
	self.data = args
end

function HeroBossResultView:_initUI()
	self.str_boxNum = self.view:getChildAutoType("str_boxNum")
	self.str_shuchu = self.view:getChildAutoType("str_shuchu")
	self.spineParent = self.view:getChildAutoType("spineParent")

	self.btn_get = self.view:getChildAutoType("btn_get")
	self.btn_get:addClickListener(function()
		local params = {}
        params.activityId = GameDef.ActivityType.NewHeroCopy
		RPCReq.Activity_NewHeroCopy_GetReward(params, function(data)
			self:closeView()
			OperatingActivitiesModel:setHeroBossShopRedFirst()
		end)
	end)
	self.toutouch = self.view:getChildAutoType("blackBg")
	self.toutouch:addClickListener(function()
		self:closeView()
	end)
	self.btn_rego = self.view:getChildAutoType("btn_rego")
	self.btn_rego:addClickListener(function()
		self.data.view:goFight()
		self:closeView()
	end)
	self.str_boxNum:setText("X"..self.data.index)
	self.str_shuchu:setText(self.data.damage)

	local spineParentDown = self.view:getChildAutoType("spineParentDown")
	local spineParentUp = self.view:getChildAutoType("spineParentUp")
	local spineDown =  SpineUtil.createSpineObj(spineParentDown,cc.p(0,0), "gongnengjiesuo_down", "Spine/ui/jiesuan", "efx_gongnengjiesuo", "efx_gongnengjiesuo",true)
	local spineUp =  SpineUtil.createSpineObj(spineParentUp,cc.p(0,0), "gongnengjiesuo_up", "Spine/ui/jiesuan", "efx_gongnengjiesuo", "efx_gongnengjiesuo",true)

end
function HeroBossResultView:_exit()
	Dispatcher.dispatchEvent(EventType.activity_HeroBossData)
end
return HeroBossResultView