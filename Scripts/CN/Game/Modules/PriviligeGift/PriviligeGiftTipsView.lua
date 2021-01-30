local PriviligeGiftTipsView = class("PriviligeGiftTipsView",Window)
local MoneyUtil = require "Game.Utils.MoneyUtil"

function PriviligeGiftTipsView:ctor()
	self._packName = "PriviligeGift"
	self._compName = "PriviligeGiftTipsView"
	self._rootDepth = LayerDepth.PopWindow

	self.btn_close 	= false
	self.btn_ok 	= false
	self.txt_buyTime = false
	self.txt_RMB 	 = false
	self.txt_desc1 	 = false
	self.txt_desc2 	 = false
	self.costItem1 	 = false

	self.buyTypeCtrl = false 	
end

function PriviligeGiftTipsView:_initUI()
	self.btn_ok 	= self.view:getChildAutoType("btn_ok")
	self.btn_close 	= self.view:getChildAutoType("btn_close")
	self.txt_RMB 	= self.view:getChildAutoType("txt_RMB")
	self.txt_desc1 	= self.view:getChildAutoType("txt_desc1")
	self.txt_desc2 	= self.view:getChildAutoType("txt_desc2")
	self.costItem1 	= self.view:getChildAutoType("costItem1")
	self.buyTypeCtrl = self.view:getController("buyType")
	self.txt_buyTime = self.view:getChildAutoType("txt_buyTime")
end

function PriviligeGiftTipsView:_initEvent()
	local data 		= self._args
	local buyType 	= data.buyType

	self.buyTypeCtrl:setSelectedIndex(buyType)
	self.txt_buyTime:setText(string.format(Desc.privilege_buyTime,data.limitNum))



	if buyType == 1 then
		local costItem1  	= BindManager.bindCostItem(self.costItem1)
		local isMoneyColor 		= data.price <= ModelManager.PlayerModel:getMoneyByType(2)

		costItem1:setData(CodeType.MONEY, 2002, data.price,true,false,isMoneyColor)
		
		self.txt_desc2:setText(string.format(Desc.privilege_zhuanshi,data.giftName))
	else
		self.txt_RMB:setText(string.format(Desc.privilege_rmb,data.price,data.giftName))
	end

	self.btn_close:removeClickListener(888)
	self.btn_close:addClickListener(function()
		ViewManager.close("PriviligeGiftTipsView")
	end,888)

	printTable(8848,"data",data)
	self.btn_ok:removeClickListener(999)
	self.btn_ok:addClickListener(function()
		if data.buyType == 2 then
			ModelManager.RechargeModel:directBuy(data.price,  GameDef.StatFuncType.SFT_Privilege, data.id,data.giftName,nil,data.showName1)
		else
			local req = {
				id = data.id,
			}
			RPCReq.Privilege_BuyPrivilege(req, function(param)
				if not param.result then
					RollTips.show(Desc.privilege_failure)
				end
			end)
		end
		ViewManager.close("PriviligeGiftTipsView")
	end,999)
end


return PriviligeGiftTipsView