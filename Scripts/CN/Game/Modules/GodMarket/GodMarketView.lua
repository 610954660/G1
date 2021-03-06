--Date :2021-01-14
--Author : generated by FairyGUI
--Desc : 神虚历险

local GodMarketView,Super = class("GodMarketView", MutiWindow)

function GodMarketView:ctor()
	--LuaLog("GodMarketView ctor")
	self._packName = "GodMarket"
	self._compName = "GodMarketView"
	self._rootDepth = LayerDepth.Window
	
	self.timer = false
	self.timer2 = false
end

function GodMarketView:_initEvent( )
	
end

function GodMarketView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:GodMarket.GodMarketView
	self.action = viewNode:getChildAutoType('action')--GGroup
	self.actionText = viewNode:getChildAutoType('actionText')--GTextField
	self.actionTime = viewNode:getChildAutoType('actionTime')--GTextField
	self.allText = viewNode:getChildAutoType('allText')--GTextField
	self.bottom = viewNode:getChildAutoType('bottom')--GGroup
	self.btn_action = viewNode:getChildAutoType('btn_action')--GButton
	self.btn_battle = viewNode:getChildAutoType('btn_battle')--mainBt
		self.btn_battle.img_red = viewNode:getChildAutoType('btn_battle/img_red')--GImage
	self.btn_box = viewNode:getChildAutoType('btn_box')--mainBt
		self.btn_box.img_red = viewNode:getChildAutoType('btn_box/img_red')--GImage
	self.btn_chat = viewNode:getChildAutoType('btn_chat')--mainBt
		self.btn_chat.img_red = viewNode:getChildAutoType('btn_chat/img_red')--GImage
	self.btn_findBox = viewNode:getChildAutoType('btn_findBox')--mainBt
		self.btn_findBox.img_red = viewNode:getChildAutoType('btn_findBox/img_red')--GImage
	self.btn_map = viewNode:getChildAutoType('btn_map')--mainBt
		self.btn_map.img_red = viewNode:getChildAutoType('btn_map/img_red')--GImage
	self.btn_rank = viewNode:getChildAutoType('btn_rank')--mainBt
		self.btn_rank.img_red = viewNode:getChildAutoType('btn_rank/img_red')--GImage
	self.btn_reward = viewNode:getChildAutoType('btn_reward')--GButton
	self.btn_shop = viewNode:getChildAutoType('btn_shop')--mainBt
		self.btn_shop.img_red = viewNode:getChildAutoType('btn_shop/img_red')--GImage
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.goldText = viewNode:getChildAutoType('goldText')--GTextField
	self.hightText = viewNode:getChildAutoType('hightText')--GTextField
	self.normalText = viewNode:getChildAutoType('normalText')--GTextField
	self.timeLeft = viewNode:getChildAutoType('timeLeft')--GGroup
	self.txt_countTimer = viewNode:getChildAutoType('txt_countTimer')--GTextField
	self.txt_countTitle = viewNode:getChildAutoType('txt_countTitle')--GTextField
	--{autoFieldsEnd}:GodMarket.GodMarketView
	--Do not modify above code-------------
end

function GodMarketView:_initListener( )
	
	--神虚宝藏
	self.btn_box:addClickListener(function()
		ViewManager.open("GodMarketMineListView")
	end)

	--房间聊天
	self.btn_chat:addClickListener(function()
		ModuleUtil.openModule( ModuleId.Chat.id , true, {showRoom = true, curChannel = ModelManager.ChatModel.ChatType.GodMarket})
	end)

	--地图预览
	self.btn_map:addClickListener(function()
		ViewManager.open("GodMarketMiniMapView")
	end)

	--排行榜
	self.btn_rank:addClickListener(function()
		ViewManager.open("GodMarketRankView")
	end)

	--商店
	self.btn_shop:addClickListener(function()
		if ActivityModel:getActityById(GameDef.ActivityType.GodMarketShop) then
			ViewManager.open("GodMarketShopView")
		else
			RollTips.show(Desc.godmarket_desc16) --godmarket_desc16="活动未开启"
		end
	end)

	--领取收益
	self.btn_reward:addClickListener(function()
		GodMarketModel:getAreaReward()
	end)

	--集合进攻
	self.btn_battle:addClickListener(function()
		if GodMarketModel.flags then
			local x,y = GodMarketModel:getXY(GodMarketModel.flags)
			Dispatcher.dispatchEvent("godmarket_movetorect",x,y)
		end
	end)

	--快速寻宝
	self.btn_findBox:addClickListener(function()
		for k,v in pairs(GodMarketModel.gridBox) do
			local x,y = GodMarketModel:getXY(v.pos)
			Dispatcher.dispatchEvent("godmarket_movetorect",x,y)
			break
		end
	end)

	--一键行动
	self.btn_action:addClickListener(function()
		ViewManager.open("GodMarketOneKeyView")
	end)

end

function GodMarketView:_initUI( )
	self:_initVM()
	self:_initListener()

	self:setBg("")
	self._pageNode = self.frame:getChildAutoType("contentNode")

	--初始化地图数据
	GodMarketModel:initMapData()
	--模拟多页控制器 可忽略
	self:__regCtrl()  
	--创建地图页
	self:createComponentByPageName("GodMarketMapView")

	self:updateBottom()
	self:godmarket_updateOneAction()
	self:updateCountTimer()
	
	RedManager.register(self.btn_shop:getChildAutoType("img_red","V_ACTIVITY_" .. GameDef.ActivityType.GodMarketShop))
	RedManager.register(self.btn_chat:getChildAutoType("V_CHAT_GODMARKET"))
end

--更新地图信息
function GodMarketView:godmarket_updatemap()
	self:updateBottom()
	
end



-- 更新下方数据
function GodMarketView:updateBottom()
	self.normalText:setText(string.format("%d/%d",GodMarketModel.eventCurNum[1],GodMarketModel.eventAllNum[1]))
	self.hightText:setText(string.format("%d/%d",GodMarketModel.eventCurNum[2],GodMarketModel.eventAllNum[2]))
	self.allText:setText(GodMarketModel.serverData.newAmount)
	self.goldText:setText(GodMarketModel.curHourGet..Desc.godmarket_desc6) --godmarket_desc6="/小时"
	if GodMarketModel.serverData.newAmount and GodMarketModel.serverData.newAmount > 0 then
		--RPCReq.Activity_GodMarket_GetAreaReward({roomId = self.roomId})
		self.btn_reward:setGrayed(false)
		self.btn_reward:setTouchable(true)
	else
		self.btn_reward:setGrayed(true)
		self.btn_reward:setTouchable(false)
    end
end


-- 行动力更新
function GodMarketView:godmarket_updateOneAction()
	self.actionText:setText(GodMarketModel.serverData.action)
	self.actionTime:setText("")
	if GodMarketModel.serverData.action == 0 then
		self.btn_action:setGrayed(true)
		self.btn_action:setTouchable(false)
	else
		self.btn_action:setGrayed(false)
		self.btn_action:setTouchable(true)
	end
	local lastTime = (GodMarketModel.serverData.actionTime or 0) - ModelManager.ServerTimeModel:getServerTime()

	if lastTime <= 0 then return end
	local function onCountDown(time)
		if not tolua.isnull(self.actionTime) then
			--self.isEnd = false
			self.actionTime:setText(TimeLib.formatTime(time, 2)..Desc.godmarket_desc7) --godmarket_desc7="后恢复"
		end
	end
	local function onEnd(...)
		--self.isEnd = true
		if not tolua.isnull(self.actionTime) then
			--  self.activityEnable = true
			--self.actionTime:setText(Desc.activity_txt18)
		end
	end
	if self.timer2 then
		TimeLib.clearCountDown(self.timer2)
	end
	self.timer2 = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
end


-- 倒计时
function GodMarketView:updateCountTimer()
	--if self.isEnd then return end
	local actData = ModelManager.ActivityModel:getActityByType(GameDef.ActivityType.GodMarket)
	if not actData then return end
	local actId   = actData.id
	local status, addtime = ModelManager.ActivityModel:getActStatusAndLastTime(actId)
	if not addtime then 
		self.txt_countTimer:setText(Desc.activity_txt18)
		return 
	end


	local lastTime = (GodMarketModel.serverData.roundTimes or 0) - ModelManager.ServerTimeModel:getServerTime()
	if lastTime <= 0 then return end
	if not tolua.isnull(self.txt_countTimer) then
		self.txt_countTimer:setText(TimeLib.GetTimeFormatDay(lastTime, 2))
	end
	local function onCountDown(time)
		if not tolua.isnull(self.txt_countTimer) then
			--self.isEnd = false
			self.txt_countTimer:setText(TimeLib.GetTimeFormatDay(time, 2))
		end
	end
	local function onEnd(...)
		--self.isEnd = true
		if not tolua.isnull(self.txt_countTimer) then
			--  self.activityEnable = true
			self.txt_countTimer:setText(Desc.activity_txt18)
		end
	end
	if self.timer then
		TimeLib.clearCountDown(self.timer)
	end
	self.timer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
	
	
end

function GodMarketView:_exit()

	if self.timer then
		TimeLib.clearCountDown(self.timer)
		self.timer = false
	end

	if self.timer2 then
		TimeLib.clearCountDown(self.timer2)
		self.timer2 = false
	end

end

return GodMarketView
