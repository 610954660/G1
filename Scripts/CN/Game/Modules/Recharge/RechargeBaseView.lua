
-- 充值界面
-- added by zn


local RechargeBaseView = class("RechargeBaseView", MutiWindow)

function RechargeBaseView:ctor()
    self._packName = "Recharge"
    self._compName = "RechargeBaseView"
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
	-- self.redArr = {
	-- 	"",
	-- 	"V_VIP",
	-- 	"V_PRIVILIGEGIFT",
	-- 	"V_DAILYGIFTBAG"
	-- }

    self:setMoneyType(self.showMoneyTypeDefault)
end

function RechargeBaseView:getViewData()
	local data = {}
	
	-- 充值
	local temp =  {
		page = "RechargeView",
		btData = {
			title = Desc.Recharge_title1,
			icon = string.format("Icon/recharge/tabIcon%s.png", 1),
		},
		-- red = "V_SIGN", --红点名称
		-- bg = "loginaward_sign_bg.jpg",
		mid = ModuleId.Recharge.id
	}
	table.insert(data,temp)

	-- 纽扣购买
	if (DressRechargeModel.data and not ModuleUtil.getModuleOpenTips(ModuleId.DressRecharge.id)) then
		local temp =  {
			page = "DressRechargeView",
			btData = {
				title = Desc.Recharge_title2,
				icon = string.format("Icon/recharge/tabIcon%s.png", 2),
			},
			-- red = "V_SIGN", --红点名称
			-- bg = "loginaward_sign_bg.jpg",
			-- mid = ModuleId.Recharge.id
		}
		table.insert(data,temp)
	end

	-- VIP
	local temp =  {
		page = "VipView",
		btData = {
			title = Desc.Recharge_title3,
			icon = string.format("Icon/recharge/tabIcon%s.png", 3),
		},
		red = "V_VIP", --红点名称
		-- bg = "loginaward_sign_bg.jpg",
		mid = ModuleId.Vip.id
	}
	table.insert(data,temp)

	-- 特权
	local temp =  {
		page = "PriviligeGiftView",
		btData = {
			title = Desc.Recharge_title4,
			icon = string.format("Icon/recharge/tabIcon%s.png", 4),
		},
		red = "V_PRIVILIGEGIFT", --红点名称
		-- bg = "loginaward_sign_bg.jpg",
		mid = ModuleId.PriviligeGiftView.id
	}
	table.insert(data,temp)

	-- 每日礼包
	local temp =  {
		page = "DailyGiftBagView",
		btData = {
			title = Desc.Recharge_title5,
			icon = string.format("Icon/recharge/tabIcon%s.png", 5),
		},
		red = "V_DAILYGIFTBAG", --红点名称
		-- bg = "loginaward_sign_bg.jpg",
		mid = ModuleId.DailyGiftBag.id
	}
	table.insert(data,temp)
	return data;
end

function RechargeBaseView:_initUI( )
	self:_initVM()
	self:setBg("bg_shop.jpg")
	self.pageView = self.view:getChildAutoType("pages")
	self.list_page = self.view:getChildAutoType("list_page")
	self.frame = self.view:getChildAutoType("frame")

	self._args.viewData = self:getViewData();
	if (not self._args.page) then
		self._args.page = self._args.viewData[1].page;
	end
end

function RechargeBaseView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
        vmRoot.RechargeView = viewNode:getChildAutoType("RechargeView");
        vmRoot.VipView = viewNode:getChildAutoType("VipView");
        vmRoot.PriviligeGiftView = viewNode:getChildAutoType("PriviligeGiftView");
        vmRoot.DailyGiftBagView  = viewNode:getChildAutoType("DailyGiftBagView");
end

function RechargeBaseView:Vip_openRecharge()
	self:_setPage("DailyGiftBagView")
end

function RechargeBaseView:onShowPage(pageName)
	if (pageName == "DressRechargeView") then
		self.showMoneyTypeDefault = {
			{type = GameDef.ItemType.Money, code = GameDef.MoneyType.FashionPoint},
			-- {type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold}, 
			-- {type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond}
		}
	else
		self.showMoneyTypeDefault = {
			{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold}, 
			{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond}
		}
	end
	self:setMoneyType(self.showMoneyTypeDefault)
end


return RechargeBaseView;