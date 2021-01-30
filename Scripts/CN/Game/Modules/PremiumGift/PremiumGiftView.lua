-- added by wyz
-- 超值礼包

local TimeLib = require "Game.Utils.TimeLib"
local TimeUtil = require "Game.Utils.TimeUtil"
local PremiumGiftView = class("PremiumGiftView", Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器


function PremiumGiftView:ctor()
	self._packName = "PremiumGift"
    self._compName = "PremiumGiftView"
	self._rootDepth = LayerDepth.PopWindow

    self.pageList 	= false 		-- 顶部分页列表
    self.rewardList = false 		-- 奖励列表
    self.btn_buy 	= false 		-- 购买按钮
    self.txt_buyDec = false 		-- 购买文本说明
    self.txt_countTime 	= false 	-- 倒计时时间
    self.timer 			= false		-- 倒计时
    self.idx 			= false 	-- 记录购买的礼包
    self.buyGiftTime 	= false 	-- 当前可购礼包的数量
    self.rareTime 		= false		-- 多少次后可购买稀有礼包
    self.btn_soldOut 	= false
    self.giftType 		= 1
    self.resetTime 		= false
    self.activityEndTime = false
    self.ctrl1 = false
	self.ctrl2 = false
	self.ctrl3 = false
    self.btn_end 		= false
	self.reqType 		= false
	self.txt_zhe 		= false
	self.btn_close 		= false
	self.bg 			= false
	self.lihui 			= false
	self.txt_num 		= false
	self.iconLoader 	= false
end


function PremiumGiftView:_initUI()
	self.pageList 		= self.view:getChildAutoType("pageList")
	self.rewardList		= self.view:getChildAutoType("rewardList")
	self.btn_buy 		= self.view:getChildAutoType("btn_buy")
	self.txt_buyDec		= self.view:getChildAutoType("txt_buyDec")
	self.txt_buyDec2	= self.view:getChildAutoType("txt_buyDec2")
	self.txt_countTime	= self.view:getChildAutoType("txt_countTime")
	self.btn_soldOut 	= self.view:getChildAutoType("btn_soldOut")
	self.ctrl1 			= self.view:getController("c1")
	self.ctrl2 			= self.view:getController("c2")
	self.ctrl3 			= self.view:getController("c3")
	self.btn_end 		= self.view:getChildAutoType("btn_end")
	self.txt_zhe 		= self.view:getChildAutoType("txt_zhe")
	self.btn_close 		= self.view:getChildAutoType("btn_close")
	self.bg 			= self.view:getChildAutoType("bg")
	self.lihui 			= self.view:getChildAutoType("lihui")
	self.iconLoader 	= self.view:getChildAutoType("iconLoader")
	self.txt_num 		= self.view:getChildAutoType("txt_num")
end


function PremiumGiftView:_initEvent()
	self.bg:setURL("UI/PremiumGift/bg.png")
	self.lihui:setURL("UI/PremiumGift/lihui.png")
	self.btn_close:addClickListener(function()
		ViewManager.close("PremiumGiftView")	
	end)
	self:PremiumGift_UpGiftData()
end

function PremiumGiftView:PremiumGift_UpGiftData()

	local giftData = PremiumGiftModel.giftData
	if #giftData == 0 then
		return 
	else
		self:upTime()
	end
	if giftData[self.giftType] then
		self.pageList:setSelectedIndex(self.giftType - 1)
	else
		self.giftType = 1
		self.pageList:setSelectedIndex(self.giftType - 1)
	end
	
	self.reqType = giftData[self.giftType].giftType
	RPCReq.Activity_BargainGift_Info({type = self.reqType},function(params)
		-- printTable(999,"params",params)
		self.idx = params.id
		if tolua.isnull(self.view) then return end
		self:setGiftPage()
	end)
	-- 菜单栏列表
	self.pageList:setItemRenderer(function(idx,obj)
		local index = idx + 1
		local name = obj:getChildAutoType("txt_name")
		local img_red = obj:getChildAutoType("img_red")
		RedManager.register("V_ACTIVITY_"..GameDef.ActivityType.BargainGift .. index, img_red)

		-- local icon = obj:getChildAutoType("icon")
		local reqType = giftData[index].giftType
		-- icon:setURL(string.format("Icon/premiumGift/menuType%s.png",giftData[index].giftType))
		name:setText(giftData[index].name)
		obj:removeClickListener(666)
		obj:addClickListener(function()
			RPCReq.Activity_BargainGift_Info({type = reqType},function(params)
				-- printTable(999,params)
				self.idx = params.id
				self.giftType = index
				self.reqType = reqType
				if tolua.isnull(self.view) then return end
				self:setGiftPage()
			end)
		end,666)
	end)
	self.pageList:setNumItems(#giftData)
end

-- 礼包界面 
function PremiumGiftView:setGiftPage()

	local num = #PremiumGiftModel.giftData[self.pageList:getSelectedIndex() + 1].giftId
	local giftIndex = self.idx <= num and self.idx or self.idx - 1
	print(8848,">>>>>>>>>>self.idx>>>>",self.idx)
	print(8848,">>>>>>>>>>self.giftType>>>",self.giftType)
	print(8848,">>>>>>>>>>self.reqType>>>",self.reqType)
	local rewardData = PremiumGiftModel.giftData[self.pageList:getSelectedIndex() + 1].giftId[giftIndex]

		-- 奖励列表
		self.rewardList:setItemRenderer(function(idx,obj)
			-- 0 稀有奖励 1 普通奖励
			local rare = obj:getController("rare")
			rare:setSelectedIndex(rewardData.giftMake == 2 and 0 or 1)

			local d =  rewardData.giftItem[idx+1]
			local itemCell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
			itemCell:setData(d.code, 0, d.type)
			-- itemCell:setIsBig(true)
			itemCell:adaptIconImg(true,1.5)
			itemCell:setNoFrame(true)

			local txt_propName = obj:getChildAutoType("txt_propName")
			txt_propName:setText(ItemConfiger.getItemNameByCode(d.code,d.type))

			local txt_propNum = obj:getChildAutoType("txt_propNum")
			txt_propNum:setText(Desc.PremiumGift_number .."："..d.amount)
		end)
		self.rewardList:setNumItems(#rewardData.giftItem)


		-- do return end
		-- 页面其它数据
		local pageData = PremiumGiftModel.giftData[self.pageList:getSelectedIndex() + 1]
		local giftNum = #pageData.giftId + 1
		self.buyGiftTime = giftNum - self.idx
		self.rareTime 	 = pageData.rareNum - self.idx

		if rewardData.discount then
			self.ctrl3:setSelectedIndex(0)
			self.txt_zhe:setText(string.format(Desc.PremiumGift_discount,rewardData.discount))
		else
			self.ctrl3:setSelectedIndex(1)
		end

		local url = ItemConfiger.getItemIconByCode(rewardData.oldPrice.code, rewardData.oldPrice.type,true)
		self.iconLoader:setURL(url)
		self.txt_num:setText(rewardData.oldPrice.amount)
		self.txt_buyDec:setText(string.format(Desc.PremiumGift_buyDec,self.buyGiftTime))
		self.txt_buyDec2:setText(string.format(Desc.PremiumGift_buyDec2,self.rareTime))
		
		self.txt_buyDec2:setVisible(self.rareTime > 0)

		-- 0 普通购买 1 稀有购买
		self.ctrl1:setSelectedIndex(rewardData.giftMake == 2 and 1 or 0)


		local line = self.view:getChildAutoType("line")
		-- 已售完
		if self.buyGiftTime == 0 then
			self.ctrl2:setSelectedIndex(1)
			self.btn_soldOut:getController("button"):setSelectedIndex(2)
			self.btn_soldOut:setTouchable(false)
			self.txt_num:setVisible(false)
			self.iconLoader:setVisible(false)
			line:setVisible(false)
		else
			self.ctrl2:setSelectedIndex(0)
			self.txt_num:setVisible(true)
			self.iconLoader:setVisible(true)
			line:setVisible(true)
		end

		self.btn_buy:setTitle(rewardData.price.amount)
		local img_red = self.btn_buy:getChildAutoType("img_red")
		RedManager.register("V_ACTIVITY_".. GameDef.ActivityType.BargainGift .. self.giftType .. self.idx, img_red)
		self.btn_buy:removeClickListener(888)
		self.btn_buy:addClickListener(function()
			local function onYes()
				LuaLogE("onYes")
				local req = {
					type = pageData.giftType,
				}
				RPCReq.Activity_BargainGift_RecieveReward(req,function()
						if self.resetTime then
							Scheduler.unschedule(self.resetTime)
							self.resetTime = false
						end
						if self.timer then
							TimeUtil.clearTime(self.timer)
						end

					Dispatcher.dispatchEvent(EventType.PremiumGift_UpGiftData)
				end)
			end
			local info = {
				text = string.format(Desc.PremiumGift_buyTips,rewardData.price.amount,pageData.name),
				type = "yes_no",
				onYes = onYes,
			}
			Alert.show(info)
		end, 888)

end

function PremiumGiftView:_exit()
	if self.timer then
		TimeUtil.clearTime(self.timer)
	end

	if self.resetTime then
		Scheduler.unschedule(self.resetTime)
		self.resetTime = false
	end
end

function PremiumGiftView:money_change(_,data)
	self:PremiumGift_UpGiftData()
end

function PremiumGiftView:upTime()
	if self.resetTime then
		Scheduler.unschedule(self.resetTime)
		self.resetTime = false
	end
	if self.timer then
		TimeUtil.clearTime(self.timer)
	end

	local time = ServerTimeModel:getTodayLastSeconds()
	self.timer = TimeUtil.upText(self.txt_countTime,time - 1,"%s")
	self.txt_countTime:setText(TimeLib.formatTime(time - 1))

	local function docallback()
		local todayTime = ServerTimeModel:getTodaySeconds()
		local ServerTime = ServerTimeModel:getServerTime()
		self.activityEndTime = PremiumGiftModel.activityEndTime - ServerTime
		if todayTime == 0 or todayTime >= 86399 then
			Scheduler.unschedule(self.resetTime)
			self.resetTime = false

			if self.timer then
				TimeUtil.clearTime(self.timer)
			end

			if self.activityEndTime > 0 then
				Dispatcher.dispatchEvent(EventType.PremiumGift_UpGiftData)
			else
				local line = self.view:getChildAutoType("line")
				self.ctrl2:setSelectedIndex(2)
				self.btn_end:getController("button"):setSelectedIndex(2)
				self.btn_end:setTouchable(false)
				self.txt_num:setVisible(false)
				self.iconLoader:setVisible(false)
				self.txt_countTime:setText(Desc.PremiumGift_end)
				self.txt_buyDec2:setVisible(false)
				self.txt_buyDec:setVisible(false)
				line:setVisible(false)
				self.pageList:setTouchable(false)
			end
		end
	end
	self.resetTime = Scheduler.schedule(docallback, 1)
end


return PremiumGiftView
