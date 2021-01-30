	--added by wyang
--秘境摇骰子组件
local FairyLandRoll = class("FairyLandRoll")
function FairyLandRoll:ctor(view)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
	
	self.rollArea = false
	self.list_roll = false
	self.btn_roll = false
	self.btn_ok = false
--	self.txt_target = false
	self.dragArea = false
	self.btn_switch = false
	self.costItem = false
	self.txt_moveNum = false
	self.c1 = false

	self._items = {}
	self._allItems = {}
	
	self._updateTimeId = false
	self._defaultSpeed = 20 	-- 默认速度 			-- 默认速度40  3倍数
	self._speed = 0
	self._num = 0   --每次变位置加1，加到一定数量改变速度  
	
	self._speedDesc = 10  --每次速度下降 				-- 每次速度下降 20
	self._targetNum = 2 --目标滚动到什么数字
	self._minSpeed = 10	--最小移动速度 				-- 最小移动速度 20
	self._midX = 110	--组件中间坐标 				-- 
	self._changeSpeed = 40 -- 每50次降低一次速度 		-- 每20次下降一次速度
	
	
	self._completeCaller = false
	self._completeCallback = false
	
	self._moveX = 0
	self._dragMoveX = 0
	self._lastPosX = 0 --拖动时上一次的点，用来计算方向
	self._dir = 1;

	self._poor = 10 -- 默认的
	
	self._itemDis = 70
	self._numPos = 50 -- 单个数字与相对于图片左上角的偏移值
	self._allWidth = self._itemDis * 6

	self.txt_freetime = false  -- 免费抽奖次数

end


function FairyLandRoll:init( ... )
	self.c1 = self.view:getController("c1")
	self.rollArea = self.view:getChildAutoType("rollArea")
	self.txt_moveNum = self.view:getChildAutoType("txt_moveNum")
	self.btn_roll = self.view:getChildAutoType("btn_roll")
	self.btn_switch = self.view:getChildAutoType("btn_switch")
	self.btn_ok = self.view:getChildAutoType("btn_ok")
	self.btn_auto = self.view:getChildAutoType("btn_auto")
	self.btn_cancelAuto = self.view:getChildAutoType("btn_cancelAuto")
	self.txt_freetime = self.view:getChildAutoType("txt_freetime")
	--self.txt_target = self.view:getChildAutoType("txt_target")
	self.dragArea = self.rollArea:getChildAutoType("dragArea")
	local costItem = self.view:getChildAutoType("costItem")
	self.costItem = BindManager.bindCostItem(costItem)
	self.costItem:setData(3,10000005, 5)
	self.costItem.txt_num:setColor(ColorUtil.textColor.white)
	self.rollArea:setTouchable(true)
	self.dragArea:setDraggable(true)
	self.btn_auto:setVisible(not FairyLandModel.autoNext)
	self.btn_cancelAuto:setVisible(FairyLandModel.autoNext)
		
	self.dragArea:addEventListener(FUIEventType.DragStart,function(context)
			print(1,"FairyLandRoll DragStart")
			self._dragMoveX = 0
			self._lastPosX = 0
	end);
	
	self.dragArea:addEventListener(FUIEventType.DragMove,function(context)
		print(1,"FairyLandRoll dragMove")
		self._dragMoveX = self.dragArea:getPosition().x
		if self._lastPosX ~= 0 then
			if self._dragMoveX - self._lastPosX < 0 then
				self._dir = 1
			else
				self._dir = -1
			end
		end
		self._lastPosX = self._dragMoveX
		self:moveItem(self._moveX + self._dragMoveX)
		
		local posX = -math.mod(self._moveX + self._dragMoveX + self._numPos, self._allWidth) + self.view:getWidth()/2
		self._targetNum = math.mod(math.ceil(posX / self._itemDis), 6) + 1
		if self._targetNum > 6 then self._targetNum = 6 end
		if(self._targetNum <= 0) then
			self._targetNum =  self._targetNum + 6
		end
		
		if(self._targetNum > 6) then
			self._targetNum = self._targetNum - 6 
		end
		self:updateMoveNum()
	end);
	
	self.dragArea:addEventListener(FUIEventType.DragEnd,function(context)
		print(1,"FairyLandRoll DeagEnd")
		self._moveX = self._moveX + self._dragMoveX
		self._dragMoveX = 0 
		self.dragArea:setPosition(0,0)
		
		self._speed = self._minSpeed
		self._num = 0
		self:setToNum(self._targetNum)
		--self:startMove()
	end);
	
	for i = 1,6,1 do
		local item = self.rollArea:getChildAutoType("rollItem_"..i)
		--item:setMask(self.img_mask)
		item:setTitle(i)
		table.insert(self._items, item)
		table.insert(self._allItems, item)
	end
	
	self.btn_auto:addClickListener(function ( ... )
		FairyLandModel.autoNext = true
		self.btn_roll:dispatchEvent(FUIEventType.Click)
		self.btn_auto:setVisible(false)
		self.btn_cancelAuto:setVisible(true)
	end)

	self.btn_cancelAuto:addClickListener(function ( ... )
		FairyLandModel.autoNext = false
		self.btn_auto:setVisible(true)
		self.btn_cancelAuto:setVisible(false)
	end)
	
	self.btn_roll:addClickListener(function ( ... )
		if ModelManager.FairyLandModel.moveNum > 0 then 
			RollTips.show(Desc.fairyLand_notMoveComplete)
			return
		end
		if (FairyLandModel.forWardTime < 1) and (not ModelManager.PlayerModel:isCostEnough({{type = GameDef.GameResType.Item, code = 10000023, amount=1}}, true) ) then
			return
		end
		
		self.btn_roll:setTouchable(false)
		self.btn_switch:setTouchable(false)
		self.btn_auto:setTouchable(false)
		
		self:doRoll()
	end)

	self.btn_ok:addClickListener(function ( ... )
		if FairyLandModel.moving then
			RollTips.show(Desc.fairyLand_notMoveComplete)
			return
		end
		if not ModelManager.PlayerModel:isCostEnough({{type = GameDef.GameResType.Item, code = 10000024, amount=1}}, true) then
			return
		end
		
		self.btn_ok:setTouchable(false)
		self.btn_switch:setTouchable(false)
		self:doRoll()
	end)

	self.btn_switch:addClickListener(function ( ... )
		local isManual = self.c1:getSelectedIndex() == 0
		self.c1:setSelectedIndex(isManual and 1 or 0)
		if isManual then
			FairyLandModel.autoNext = false
			self:fairyLand_cancelAuto()
		end
		self:updatePage()		
		self:updateForwardTime()
	end)
	
	--[[GlobalUtil.createTouchLayer(0,0,1280,720,function(type)
		print(1, type)
	end,true,ccp(0,0))--]]
	
	RedManager.register("V_FAIRYLAND", self.btn_roll:getChildAutoType("img_red"))
	RedManager.register("V_FAIRYLAND_EX", self.btn_ok:getChildAutoType("img_red"))

	self:updateMoveNum()
	self:setToNum(self._targetNum)
	self:updatePage()
	self:updateForwardTime()
end

function FairyLandRoll:fairyLand_cancelAuto()
	self.btn_auto:setVisible(true)
	self.btn_cancelAuto:setVisible(false)
end


function FairyLandRoll:updateMoveNum()
	self.txt_moveNum:setText(string.format(Desc.fairyLand_moveNum,self._targetNum ))
end

--初始化 如果使用手动道具的，直接跳到手动页
function FairyLandRoll:initData(data)
	if(data and data.type == GameDef.ItemType.FairyLandItemEx) then
		self.c1:setSelectedIndex(1)
	end
	if(ModelManager.FairyLandModel.moveNum > 0) then
		self.btn_roll:setTouchable(false)
		self.btn_ok:setTouchable(false)
		self.btn_switch:setTouchable(false)
		self.btn_auto:setTouchable(false)
	end
	self:updatePage()
end

function FairyLandRoll:updatePage()
	local isManual = self.c1:getSelectedIndex() == 1
	self.dragArea:setVisible(isManual)
	self.costItem:setData(CodeType.ITEM, isManual and 10000024 or 10000023, 1)
	self.costItem.txt_num:setColor(ColorUtil.textColor.white)
	local img_red_switch = self.btn_switch:getChildAutoType("img_red")
	local redType = isManual and "V_FAIRYLAND" or "V_FAIRYLAND_EX"
	if redType == "V_FAIRYLAND_EX" then
		img_red_switch:setVisible(ModelManager.PackModel:getItemsFromAllPackByCode(10000024) > 0)
	else
		RedManager.register(redType, img_red_switch)
	end

end

-- 更新免费前进次数
function FairyLandRoll:updateForwardTime()
	self.txt_freetime:setText(string.format(Desc.fairyLand_freeForwardTime,FairyLandModel.forWardTime))
	if FairyLandModel.forWardTime > 0 and (self.c1:getSelectedIndex() == 0) then
		self.txt_freetime:setVisible(true)
		self.costItem:setVisible(false)
	else
		self.txt_freetime:setVisible(false)
		self.costItem:setVisible(true)
	end
end




function FairyLandRoll:doRoll()
	local params = {}
		params.itemType = self.c1:getSelectedIndex() == 1 and GameDef.ItemType.FairyLandItemEx or GameDef.ItemType.FairyLandItem
		params.moveNum = self._targetNum
		params.onSuccess = function (res )
			ModelManager.FairyLandModel.moveNum = res.moveNum
			ModelManager.FairyLandModel.sieveTimes = res.sieveTimes
			ModelManager.FairyLandModel:setFreeForwardTime(res.freeRunTimes)
			if tolua.isnull(self.view) then return end --如果view已经关掉了，不需要走了
			self:updateForwardTime()
			
			local configInfo = DynamicConfigData.t_fairyLand[ModelManager.FairyLandModel.floor][ModelManager.FairyLandModel.grid]
			if ModelManager.FairyLandModel:reachTimesLimit() and (configInfo.type == GameDef.FairyLandGridType.Ending) then
				Dispatcher.dispatchEvent(EventType.fairyLand_end)
			end
			self._targetNum = res.moveNum
			if self._targetNum < 1 or self._targetNum > 6 then return end
			if(params.itemType == GameDef.ItemType.FairyLandItem ) then
				self:startRoll()
			else
				self:onComplete()
			end
		end
		RPCReq.FairyLand_UseItem(params, params.onSuccess)
		--[[local num = self._targetNum
		if(params.itemType == GameDef.ItemType.FairyLandItem ) then
			num = math.floor(math.random() * 6) + 1
		end
		params.onSuccess({
			moveNum=num
	})--]]
end

function FairyLandRoll:setCompleteCallBack(caller, callBack)
	self._completeCaller = caller
	self._completeCallback = callBack
end

function FairyLandRoll:startRoll()
	self._moveX = 0
	--self._targetNum = tonumber(self.txt_target:getText())
	self._speed = self._defaultSpeed
	self._num = 0
	self:startMove()
end

--直接跳到某个数
function FairyLandRoll:setToNum(num)
	local moveX = 40 - self._itemDis*(num - 2)
	self:moveItem(moveX)
end

function FairyLandRoll:startMove()
	Scheduler.unschedule(self._updateTimeId)
	self._updateTimeId  = Scheduler.schedule(function()
		self:onRollUpdate()
	end,0.01)
end

function FairyLandRoll:stopRoll()
	Scheduler.unschedule(self._updateTimeId)
end

function FairyLandRoll:onRollComplete()
	if self.c1:getSelectedIndex() == 1 then return end
	self:updateMoveNum()
	self:onComplete()
end

--打开屏蔽
function FairyLandRoll:open(isMoveEnd)
	if tolua.isnull(self.view) then return end
	self.btn_roll:setTouchable(true)
	self.btn_switch:setTouchable(true)
	self.btn_ok:setTouchable(true)
	self.btn_auto:setTouchable(true)
	--如果选了自动走，随机券又充足的话，自动帮他点了
	if isMoveEnd and FairyLandModel.autoNext and (ModelManager.PackModel:getItemsFromAllPackByCode(10000023) > 0 or FairyLandModel.forWardTime > 0) then
		self.btn_roll:dispatchEvent(FUIEventType.Click)
	end
end
function FairyLandRoll:onComplete()
	self:open()
	if self._completeCallback then
		self._completeCallback(self._completeCaller, self._targetNum)
	end
end

function FairyLandRoll:onRollUpdate()
	self._num  = self._num + 1
	if(self._num >= self._changeSpeed) then
		self._num = 0
		if(self._speed > self._minSpeed) then
			self._speed = self._speed  - self._speedDesc
		end
		if(self._speed < self._minSpeed) then
			self._speed = self._minSpeed
		end
	end
	if(self._speed  == self._minSpeed ) then
		-- if (not self._targetNum) or (not self._items[self._targetNum]) then return end
		local targetPos = self._items[self._targetNum]:getPosition().x
		if(math.abs(targetPos - self._midX - self._poor) <= self._speed) then
			print(8848, "------------------------", targetPos, self._midX, self._poor, self._speed);
			self:stopRoll()
			self:onRollComplete()
			self._moveX = self._moveX - math.abs(targetPos - self._midX) * self._dir
		    self:moveItem(self._moveX);
		    return;
		end
	end
	self._moveX = self._moveX - self._speed * self._dir
	self:moveItem(self._moveX)
end

function FairyLandRoll:moveItem(moveX)
	print(8848,">>>>>>>>>>>>>moveX>>>>>",moveX)
	local dis = self._itemDis--self._allItems[5]:getPosition().x - self._allItems[4]:getPosition().x
	local allwidth = self._allWidth
	for i=1,6,1 do
		local item = self._allItems[i]
		local posX = dis*(i - 1) + math.mod(moveX, allwidth)
		if(posX < (self._midX  - dis*4)) then
			posX = posX + allwidth
		end
		
		if(posX > (self._midX  + dis*4)) then
			posX = posX - allwidth
		end
		-- print(8848,">>>>>>>>>>>>posX>>>>>>",posX)
		item:setPosition(posX, 64)
		local dis = math.abs(self._midX - posX)
		local scale = 1 - 0.3 * math.abs(self._midX - posX)/self._midX
		if(dis > 180/2) then
			scale = 0.8
		end
		item:setScale(scale, scale)
		item:setAlpha(scale)
	end
end

function FairyLandRoll:isSpeedUp(isUp)
	if isUp then
		self._defaultSpeed 	= 40 	-- 默认速度 					-- 默认速度40  3倍数
		self._changeSpeed 	= 20 	-- 每50次降低一次速度 		-- 每20次下降一次速度
		self._speedDesc 	= 20  	-- 每次速度下降 				-- 每次速度下降 20
		self._minSpeed 		= 20	-- 最小移动速度 				-- 最小移动速度 20
		self._poor			= 14
	else
		self._defaultSpeed 	= 20 	
		self._changeSpeed 	= 40 	
		self._speedDesc 	= 10  	
		self._minSpeed 		= 10
		self._poor 			= 10	
	end
end


--退出操作 在close执行之前 
function FairyLandRoll:__onExit()
    print(1,"FairyLandRoll __onExit")
	Scheduler.unschedule(self._updateTimeId)
end

return FairyLandRoll