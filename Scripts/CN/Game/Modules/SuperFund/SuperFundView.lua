-- added by wyz
-- 超值基金活动

local SuperFundView = class("SuperFundView",Window)
	
function SuperFundView:ctor()
 	self._packName 	= "SuperFund"
 	self._compName 	= "SuperFundView"

	self.list_menu 	= false 	-- 按钮列表
	self.list_reward = false 	-- 奖励列表
	self.txt_money1  = false 	-- 顶部金钱文本
	self.txt_money2  = false 	-- 底部金钱文本
	self.btn_buy 	 = false 	-- 购买按钮
	self.txt_getRecord = false  -- 领取记录
	self.txt_getTime   = false 	-- 领取时间
	self.superType 	 = 1   		-- 默认停留在第一个界面
	self.recordNum 	 = 0 		-- 领取记录
	self.showCtrl  	= false
	self.lihui 		= false
	self.bg 		= false
	self.txt_accday = false

	self._rootDepth = LayerDepth.PopWindow
end
 
function SuperFundView:_initUI()
 	self.list_menu  	= self.view:getChildAutoType("list_menu")
 	self.list_reward 	= self.view:getChildAutoType("list_reward")
 	self.txt_money1 	= self.view:getChildAutoType("txt_money1")
 	self.txt_money2 	= self.view:getChildAutoType("txt_money2")
 	self.btn_buy 		= self.view:getChildAutoType("btn_buy")
 	self.txt_getTime 	= self.view:getChildAutoType("txt_getTime")
 	self.txt_getRecord 	= self.view:getChildAutoType("txt_getRecord")
	 self.showCtrl 		= self.view:getController("showCtrl")
	 self.lihui			= self.view:getChildAutoType("lihui")
	 self.lihui2		= self.view:getChildAutoType("lihui2")
	 self.bg 			= self.view:getChildAutoType("bg")
	 self.txt_accday 	= self.view:getChildAutoType("txt_accday")
end

function SuperFundView:_initEvent()
	self:refreshPanel()
end

-- 刷新面板
function SuperFundView:refreshPanel()
	-- local dayStr = DateUtil.getOppostieDays()
	-- FileCacheManager.setBoolForKey("SuperFundView_isShow"..dayStr, true)
	-- SuperFundModel:upDateRed()
	self.list_reward:setOpaque(false)
	local superData = SuperFundModel:getAllData()
	local menuData = DynamicConfigData.t_SuperMoney
	-- 左侧菜单栏列表
	self.list_menu:setSelectedIndex(self.superType - 1)
 	self.list_menu:setItemRenderer(function(idx,obj)
 		local index = idx + 1
 		local data = menuData[index][superData[index].id]
 		local title = obj:getChildAutoType("title")
 		title:setText(data.name)

 		-- 注册页签红点
 		local img_red = obj:getChildAutoType("img_red")
 		RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.AccSuperFund.. index, img_red)

 	end)
 	self.list_menu:setData(superData)

 	self.showCtrl:setSelectedIndex(self.list_menu:getSelectedIndex())
 	self:refreshRewardList(self.superType)
	self:refreshLihuiInfo(self.superType)
	self.txt_accday:setText(string.format(Desc.SuperFund_accDay,superData[self.superType].dayCount))  -- 累计奖励天数
 	self.list_menu:removeClickListener(22)
 	self.list_menu:addClickListener(function()
 		self.superType = self.list_menu:getSelectedIndex()+1
 		self.showCtrl:setSelectedIndex(self.list_menu:getSelectedIndex())
 		self:refreshRewardList(self.superType) 
		self:refreshLihuiInfo(self.superType)
		self.txt_accday:setText(string.format(Desc.SuperFund_accDay,superData[self.superType].dayCount))  -- 累计奖励天数
 	end,22)

 	
end

-- 刷新立绘部分 聊天内容框信息
function SuperFundView:refreshLihuiInfo(superType)
	local data 		= DynamicConfigData.t_SuperMoney
	local superData = SuperFundModel:getAllData()
	local index 	= superData[superType].id 		-- 索引

	self.bg:setURL("UI/SuperFund/superfundBg"..self.superType..".jpg")
	self.lihui:setURL("UI/SuperFund/superfundLihui"..self.superType..".png")
	self.lihui2:setURL("UI/SuperFund/superfundLihui"..self.superType..".png")
	-- print(8848,"index>>>>>>>>>",index)
	self.txt_money1:setText(data[superType][index].diamond)
	self.txt_money2:setText(data[superType][index].showPrice)

	local buyCtrl  	= self.view:getController("buyCtrl")
	local isBuy 	= superData[superType].isBuy 

	buyCtrl:setSelectedIndex(isBuy and 1 or 0)
	self.btn_buy:removeClickListener(22)
	self.btn_buy:addClickListener(function()
		local reqInfo = {
			type = superType,
		}
		local config = data[superType][index]
		ModelManager.RechargeModel:directBuy(config.price, GameDef.StatFuncType.SFT_BuySuperFund,superType, config.name,nil, config.showName1)
	end,22)

	self.btn_buy:setText(string.format(Desc.SuperFund_buy,data[superType][index].price))
	if isBuy then
		self.txt_getRecord:setText(string.format(Desc.SuperFund_getRecord,self.recordNum)) -- 领取记录
	end	
end

-- 根据左侧索引刷新右侧奖励列表
function SuperFundView:refreshRewardList(superType)
	local rewardAllData = {} 
	if superType == 1 then
		rewardAllData = DynamicConfigData.t_SuperMoneyOne
	else
		rewardAllData = DynamicConfigData.t_SuperMoneyTwo
	end
	local superData	 = SuperFundModel:getAllData()
	local recvList 	= superData[superType].recvList  -- 奖励领取状态
	local dayCount 	= superData[superType].dayCount  -- 可领取的奖励索引
	local isBuy 	= superData[superType].isBuy  -- 是否已购买基金
	local period 	= superData[superType].id 	  -- 第几期
	local rewardData = rewardAllData[period] 	  -- 对应基金的奖励
	self.recordNum = 0 						  -- 已领天数
	self.list_reward:setSelectedIndex(0)
 	self.list_reward:setItemRenderer(function(idx,obj)
 		local index = idx + 1
 		local data = rewardData[index]
 		local txt_day = obj:getChildAutoType("txt_day")
 		local frameLoader = obj:getChildAutoType("frameLoader")
 		txt_day:setText(data.day)
 		local reward = data.reward[1]
 		local itemCell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
 		itemCell:setData(reward.code,reward.amount,reward.type)
		itemCell:setIsHook(recvList[data.day])
		if recvList[data.day] then
			itemCell.iconLoader:setGrayed(true)
		else
			itemCell.iconLoader:setGrayed(false)
		end

		itemCell.effectLoader:setVisible(false)
		itemCell:adaptIconImg(true,0.8)
		itemCell.iconLoader:setPosition(14,20)
		itemCell.txtNum:setPosition(3,71)
		itemCell:setNoFrame(true)

		local selectCtrl = obj:getController("selectCtrl")
		frameLoader:setURL("Icon/superFund/frame_"..data.color..".png")

		selectCtrl:setSelectedIndex(0)
		if recvList[data.day] then self.recordNum = self.recordNum + 1 end
		if index <= dayCount and isBuy then
			-- itemCell:setReceiveFrame(not flag)
			selectCtrl:setSelectedIndex(not recvList[data.day] and 1 or 0)
			if not recvList[data.day] then
				obj:getChildAutoType("itemCell"):setTouchable(false)
			else
				obj:getChildAutoType("itemCell"):setTouchable(true)
			end
		else
			obj:getChildAutoType("itemCell"):setTouchable(true)
		end
 	end)
 	self.list_reward:setData(rewardData)

 	self.list_reward:removeClickListener(22)
 	self.list_reward:addClickListener(function()
 		local idx = self.list_reward:getSelectedIndex()
 		local reqInfo = {
			activityId = GameDef.ActivityType.AccSuperFund,
			fundType = superType,
			index = idx + 1,
 		}
 		RPCReq.Activity_AccSuperFund_RecvReward(reqInfo,function()
 			LuaLogE(DescAuto[312]) -- [312]="*** 有返回 ****"
 			if tolua.isnull(self.view) then return end
 			self:refreshPanel()
 		end)
 	end,22)
end

function SuperFundView:SuperFundView_refreshPanel()
	self:refreshPanel()
end

return SuperFundView
