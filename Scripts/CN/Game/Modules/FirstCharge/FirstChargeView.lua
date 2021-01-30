-- added by wyz
-- 首充礼包
local FirstChargeView = class("FirstChargeView",Window)


function FirstChargeView:ctor()
	-- 资源包
    self._packName 	= "FirstCharge"
    -- 资源包中的组件
    self._compName 	= "FirstChargeView"
    self._rootDepth = LayerDepth.PopWindow

    self.btn_topUp = false

    self.btn_close 	= false

    self.list_page = false

    self.list_reward = false

    self.giftData = {}

    self.txt_topUpMoney = false

    self.clickIndex = 1

	self.lihuiDisplay = false
	
	self.img_left = false
	self.img_right = false
	self.scrollIndex={0,0}

	self.bgLoader = false
	self.banner1 	= false
	self.banner2 	= false
end

function FirstChargeView:_initUI()

	self.list_page = self.view:getChildAutoType("list_page")

	self.btn_close = self.view:getChildAutoType("btn_close")

    self.txt_topUpMoney = self.view:getChildAutoType("txt_topUpMoney")

    self.btn_topUp = self.view:getChildAutoType("btn_topUp")

    self.list_reward = self.view:getChildAutoType("list_reward")

    self.lihuiDisplay = self.view:getChildAutoType("lihuiDisplay")
	self.img_left = self.view:getChildAutoType("img_left")
	self.img_right = self.view:getChildAutoType("img_right")

	self.bgLoader = self.view:getChildAutoType("bgLoader")
	self.banner1 	= self.view:getChildAutoType("banner1")
	self.banner2 	= self.view:getChildAutoType("banner2")
end

function FirstChargeView:_initEvent()
    -- 右侧累计充值按钮
    self.btn_topUp:addClickListener(function()
    	-- ViewManager.open("RechargeView")
 
		if self.list_page:getSelectedIndex() == 1 then 
			if ServerTimeModel:getOpenDay() >= 7 then
				ModuleUtil.openModule(ModuleId.MonthlyGiftBag.id)
			else
				ModuleUtil.openModule(ModuleId.NewServerGift.id)
			end
		else
			ModuleUtil.openModule(ModuleId.DailyGiftBag, true);
		end
    end)

    self.btn_close:addClickListener(function()
    	ViewManager.close("FirstChargeView")
    end)

    self:FirstCharge_upGiftData()
end

function FirstChargeView:setListCell()
	local itemData = DynamicConfigData.t_FirstCharge  -- 礼包数据
	local dataCfg = {6,98}
	self.bgLoader:setURL("UI/FirstChargeGift/bg" .. self.clickIndex .. ".png")
	self.banner1:setURL("UI/FirstChargeGift/banner" .. self.clickIndex .. ".png")
	self.banner2:setURL("UI/FirstChargeGift/banner" .. self.clickIndex .. ".png")

	self.list_page:setSelectedIndex(self.clickIndex - 1)
	self.list_page:setItemRenderer(function(idx,obj)
		local img_red = obj:getChildAutoType("img_red")
		local title = obj:getChildAutoType("title")
		title:setText(string.format(Desc.firstCharge_pageDec,dataCfg[idx+1]))
		
		RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.FirstCharge.. (idx+1), img_red)
	end)	
	self.list_page:setNumItems(#dataCfg)
	-- self.list_reward:setVirtual()
	self.list_reward:setItemRenderer(function(idx,obj)
		local index 	= self.list_page:getSelectedIndex()
		local data 		= itemData[dataCfg[index+1]][idx+1]
		local txt_day 	= obj:getChildAutoType("txt_day")
		local list_reward = obj:getChildAutoType("list_reward")
		local btn_rewardRed = obj:getChildAutoType("img_red")
		local txt_take 	= obj:getChildAutoType("txt_take")
		RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.FirstCharge.. (index+1) .. (idx+1), btn_rewardRed)

		local takeCtrl = obj:getController("takeCtrl")
		local state  = 1
		takeCtrl:setSelectedIndex(2)
		txt_take:setText(string.format(Desc.firstCharge_day,idx+1))

		if self.giftData.accTypeMap[dataCfg[index+1]] ~= nil then
			local recvMark = self.giftData.accTypeMap[dataCfg[index+1]].recvMark
			local flag = bit.band(recvMark, bit.lshift(1, idx)) > 0

			state = flag and 3 or 1
			if flag then
				takeCtrl:setSelectedIndex(1)
				txt_take:setText(Desc.firstCharge_take)
			elseif data.dayIndex <= self.giftData.accTypeMap[dataCfg[index+1]].dayIndex then
				takeCtrl:setSelectedIndex(0)
			end
		end

		local clickArea = obj:getChildAutoType("clickArea")

		clickArea:removeClickListener(222)
		clickArea:addClickListener(function()
			print(8848,">>>>>>>>>>>>>>clickArea>>>>>>>>>>>")
			local req = {
				accType  = data.accType,
				dayIndex = data.dayIndex
			}
			RPCReq.Activity_FirstCharge_RecvReward(req)
		end,222)

		local reward  	= data.reward
		list_reward:setItemRenderer(function(idx2,obj2)
			local dd = reward[idx2+1]
			local itemCell = BindManager.bindItemCell(obj2)
			itemCell:setData(dd.code,dd.amount,dd.type)
			itemCell:setIsHook(state == 3)
		end)
		list_reward:setNumItems(#reward)
		txt_day:setText(Desc["firstCharge_day"..data.dayIndex])
	end)
	self.list_reward:setNumItems(#itemData[dataCfg[self.clickIndex]])
	self.list_page:removeClickListener(222)
	self.list_page:addClickListener(function()
		self.clickIndex = self.list_page:getSelectedIndex() + 1
		-- self.list_reward:setNumItems(#itemData[dataCfg[self.clickIndex]]):setListCell()
		self:setListCell()
	end,222)



	local function doSpecialEffect( context )
		local curIndex = (self.list_reward:getFirstChildInView())%self.list_reward:getNumItems()
		local ll = self.list_reward:getNumItems() - 4
        if curIndex == 0 then
            self.img_left:setVisible(false)
            self.img_right:setVisible(true)
        elseif curIndex == self.list_reward:getNumItems() - 4 then
            self.img_left:setVisible(true)
            self.img_right:setVisible(false)
        else
            self.img_left:setVisible(true)
            self.img_right:setVisible(true)
        end
    end
    self.list_reward:addEventListener(FUIEventType.Scroll,doSpecialEffect)

	self:getScrollIndex(itemData,dataCfg)
	if self.scrollIndex[self.clickIndex] <= 2 then
        self.list_reward:getScrollPane():setPosX(1,false)
    elseif self.scrollIndex[self.clickIndex] > 2 then
        self.list_reward:scrollToView(self.scrollIndex[self.clickIndex] - 2,false,true)
    end
	-- self.lihuiDisplay = BindManager.bindLihuiDisplay(self.lihuiDisplay)
	-- self.lihuiDisplay:setData(45009)
end

function FirstChargeView:getScrollIndex(itemData,dataCfg)
	local index 	= self.list_page:getSelectedIndex()
	for i =1,#itemData[dataCfg[self.clickIndex]] do
		local data 		= itemData[dataCfg[index+1]][i]
		local state  = 1

		if self.giftData.accTypeMap[dataCfg[index+1]] ~= nil then
			local recvMark = self.giftData.accTypeMap[dataCfg[index+1]].recvMark
			local flag = bit.band(recvMark, bit.lshift(1, i-1)) > 0
			if flag then
			elseif data.dayIndex <= self.giftData.accTypeMap[dataCfg[index+1]].dayIndex then
				self.scrollIndex[self.clickIndex] = i 
				break
			end
		end
	end
end

function FirstChargeView:FirstCharge_upGiftData()
	self.giftData = FirstChargeModel.currentGift
	-- printTable(8848,"self.giftData>>>>>>>>>>>>>",self.giftData)
	self.giftData.count = self.giftData.count and self.giftData.count or 0

    self.txt_topUpMoney:setText(string.format(Desc.firstCharge_topUpCurrent,self.giftData.count))
	self:setListCell()
end

return FirstChargeView