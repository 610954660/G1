-- added by wyz
-- 登陆就送界面

local LoginSendView = class("LoginSendView",Window)

function LoginSendView:ctor()
	self._packName = "LoginSend"
	self._compName = "LoginSendView"
	self._rootDepth = LayerDepth.PopWindow

	self.list_reward = false  	-- 奖励列表
	self.btn_ok 	 = false 	-- 确定按钮
	self.btn_close 	 = false
end

function LoginSendView:_initUI()
	self.list_reward = self.view:getChildAutoType("list_reward")
	self.btn_ok 	 = self.view:getChildAutoType("btn_ok")
	self.btn_close 	 = self.view:getChildAutoType("btn_close")
end

function LoginSendView:_initEvent()
	self:refreshPanal()
end

function LoginSendView:refreshPanal()
	local dayStr = DateUtil.getOppostieDays()
    FileCacheManager.setBoolForKey("LoginSendView_isShow" .. dayStr,true)
	local rewardData = DynamicConfigData.t_AdShowReward[1].reward
	printTable(8848,"rewardData",rewardData)
	self.list_reward:setItemRenderer(function(idx,obj)
		local itemCell = BindManager.bindItemCell(obj)
		local data = rewardData[idx+1]
		itemCell:setData(data.code,data.amount,data.type)
	end)
	self.list_reward:setNumItems(#rewardData)

	self.btn_ok:removeClickListener(222)
	self.btn_ok:addClickListener(function()
		RPCReq.GamePlay_Modules_LoginToSend_GetLoginToSendReward({},function(params)
			ViewManager.close("LoginSendView")
		end)
	end,222)

	self.btn_close:removeClickListener(222)
	self.btn_close:addClickListener(function()
		ViewManager.close("LoginSendView")
	end,222)
end

return LoginSendView