--added by wyang
--秘境地图移动组件
local FairyLandMapRect = class("FairyLandMapRect")
local FairyLandMapItem = require "Game.Modules.FairyLand.FairyLandMapItem"
function FairyLandMapRect:ctor(view)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
	self.mapItem =false
	self._roleMc = false
	self.spineMc = false
	self.spineMc_down = false
	self.spineMc_up = false
	self.pic_bg = false
	self.txt_layer = false
	self.mapSwichCtrl = false
	self.spineNode = false
	self.modelNode = false
	
	
	
	self._isMoving = false
	
	self._movePosList = {}
	self._mapItems = {}
	self._moveTime 	= 0.5 	-- 移动时间
	self._floor = 1
	self._isInit  = false

end

function FairyLandMapRect:init( ... )
	--self.frameLoader = self.view:getChildAutoType("frameLoader")
	self.mapItem = self.view:getChildAutoType("mapItem")
	self:initMapScene()
	self.txt_layer = self.view:getChildAutoType("txt_layer")
	self.mapItem:setDraggable(true)
	local viewWidth = self.view:getWidth()
	local viewHeight = self.view:getHeight()
	local pt = self.view:localToGlobal(Vector2.zero)
	self.mapItem:setDragBounds(CCRectMake( - (3200 - viewWidth) + pt.x, - (1440 -viewHeight) + pt.y, 3200*2 - viewWidth, 1440*2 - viewHeight))
	--[[self.mapItem:addEventListener(FUIEventType.DragStart,function(context)
			print(1,"FairyLandMapRect DragStart")
	end);
	
	self.mapItem:addEventListener(FUIEventType.DragMove,function(context)
		print(1,"FairyLandMapRect dragMove")
		local pos = self.mapItem:getPosition()
		local mapWidth = self.mapItem:getWidth()
		local mapHeight = self.mapItem:getHeight()
		local rectWidth = self.view:getWidth()
		local rectHeight = self.view:getHeight()
		local targetX = pos.x
		local targetY = pos.y
		--if targetX > 0 then targetX = 0 end
		--if targetY > 0 then targetY = 0 end
		--if targetX < -(mapWidth - rectWidth) then targetX = -(mapWidth - rectWidth) end
		--if targetY < -(mapHeight - rectHeight) then targetY = -(mapHeight - rectHeight) end
		self.mapItem:setPosition(targetX, targetY)
	
	end);
	
	self.mapItem:addEventListener(FUIEventType.DragEnd,function(context)
		print(1,"FairyLandMapRect DeagEnd")
	end);--]]
	
	--self.pic_bg = self.mapItem:getChildAutoType("pic_bg")
	self._roleMc = self.mapItem:getChildAutoType("roleMc")
	self.spineMc = self._roleMc:getChildAutoType("spine")
	self.spineMc_down = self._roleMc:getChildAutoType("spine_down")
	self.spineMc_up = self._roleMc:getChildAutoType("spine_up")
	self.magnet  = self._roleMc:getChildAutoType("magnet")
	self.magnet:setVisible(false)
	self.modelNode = SpineUtil.createModel(self.spineMc, {x = 100, y =0}, "stand", 100001,false)
	
	--self.pic_bg:setURL("UI/FairyLand/fairyLand_bg.jpg")
	
	
	
	--self:centerRole()
end


function FairyLandMapRect:initMapScene()
	self.mapSwichCtrl = self.mapItem:getController("mapSwichCtrl")
	if not self._isInit then
		self._isInit = true
		self.mapSwichCtrl:setSelectedIndex(ModelManager.FairyLandModel.mapIndex)
		for i=1,8 do
			local mapLoader = self.mapItem:getChildAutoType("mapLoader"..i)
			mapLoader:setURL(string.format("Bg/fairylandMap/fairyLandMap%s/%s.jpg",ModelManager.FairyLandModel.mapIndex,i))
		end
	end
end

--打开地图时的初始化
function FairyLandMapRect:initMap(isChangeMap)
	self:initMapScene()
	for i = 1,180,1 do
		print(1,"rollItem_"..i)
		local mapItem = self._mapItems[i]
		if not mapItem then
			local posItem = self.mapItem:getChildAutoType("rollItem_"..i)
			mapItem = FairyLandMapItem.new(posItem)
			self._mapItems[i] = mapItem
		end
		local config = DynamicConfigData.t_fairyLand[ModelManager.FairyLandModel.floor][i]
		mapItem:setData(config)
		local isOpen = i <= 6 or i >= 175 or i <= (ModelManager.FairyLandModel.grid + 6)
		mapItem:setState(isOpen, true)
		mapItem.view:setTitle(i)
	end
	
	self:setToPos(ModelManager.FairyLandModel.grid)
	if isChangeMap then
		self._roleMc:setVisible(false)
	else
		self:playInEffect(function()
			if tolua.isnull(self.view) then return end
			self:moveNext()
		end)
	end
end

--让人物显示在地图中间
function FairyLandMapRect:centerRole()
	local mapWidth = self.mapItem:getWidth()
	local mapHeight = self.mapItem:getHeight()
	local rectWidth = self.view:getWidth()
	local rectHeight = self.view:getHeight()
	local rolePos = self._roleMc:getPosition()
	local centerX = rectWidth/2
	local centerY = rectHeight/2
	
	local targetX = centerX - rolePos.x
	local targetY = centerY - rolePos.y
	if targetX > 0 then targetX = 0 end
	if targetY > 0 then targetY = 0 end
	if targetX < -(mapWidth - rectWidth) then targetX = -(mapWidth - rectWidth) end
	if targetY < -(mapHeight - rectHeight) then targetY = -(mapHeight - rectHeight) end
	self.mapItem:setPosition(targetX, targetY)
end

--添加需要移动的点
function FairyLandMapRect:addMovePoint(points)
	if #points == 0 then return end
	for _,v in ipairs(points) do
		table.insert(self._movePosList, v)
	end
	if not self._isMoving then
		self:moveNext()
	end
end


--移动到下一个点
function FairyLandMapRect:moveNext()
	if #self._movePosList > 0 then
			self._isMoving = true
			local index = table.remove(self._movePosList, 1)
			self:moveToPos(index)
	else
		self._isMoving = false
		self:onMoveEnd()
	end
end

--移动完成
function FairyLandMapRect:onMoveEnd()
	Dispatcher.dispatchEvent(EventType.fairyLand_moveComplete)
end

--获取第x个格子对象
function FairyLandMapRect:getItem(index)
	return self.mapItem:getChildAutoType("rollItem_"..index)
end

--移动到某个点
function FairyLandMapRect:moveToPos(index)
	if tolua.isnull(self.mapItem) then return end
	local posItem = self.mapItem:getChildAutoType("rollItem_"..index)
	if(posItem) then
		local pos = posItem:getPosition()
		--self._roleMc:setPosition(pos.x, pos.y)
		local curPos = self._roleMc:getPosition()
		--local tw = fgui.GTween:getTween(self._roleMc)
		--tw:to({x=pos.x,y=pos.y},0.3)
		if curPos.x < pos.x then
			self.modelNode:setScaleX(1)
		else
			self.modelNode:setScaleX(-1)
		end
		FairyLandModel.moving = true
		self.magnet:setVisible(FairyLandModel.status > 0)

		local tween1 = fgui.GTween:to(curPos,{x=pos.x,y=pos.y},self._moveTime)
		tween1:onUpdate(function(tweener)
			if tolua.isnull(self._roleMc) then
				return
			end
			self._roleMc:setPosition(tweener:getDeltaValue():getVec2().x,tweener:getDeltaValue():getVec2().y)
			self:centerRole()
		end)
		
		tween1:onComplete(function(tweener)
			FairyLandModel.moving = false
			self:moveNext()
			if tolua.isnull(self.magnet) then return end
			if FairyLandModel.moveNum == 0 and FairyLandModel.status > 0 then
				self.magnet:setVisible(false)
			end
			
			local isMagnet = DynamicConfigData.t_fairyLand[FairyLandModel.floor][FairyLandModel.grid].type
			if isMagnet == GameDef.FairyLandGridType.Magnet  then
				self.magnet:setVisible(true)
			end
		end)
	end
	
	for i = index, index + 6, 1 do 
		local posItem = self._mapItems[i]
		if posItem then
			local isOpen =i <= 6 or  i >= 175 or i <= (ModelManager.FairyLandModel.grid + 6)
			posItem:setState(isOpen)
		end
	end
end

function FairyLandMapRect:isSpeedUp(isUp)
	self._moveTime = isUp and 0.15 or 0.5
end

--直接去到某点（用于打开时）
function FairyLandMapRect:setToPos(index)
	local posItem = self.mapItem:getChildAutoType("rollItem_"..index)
	if(posItem) then
		local pos = posItem:getPosition()
		self._roleMc:setPosition(pos.x, pos.y)
		self:centerRole()
	end
end

function FairyLandMapRect:playInEffect(endFunc)
	self._roleMc:setVisible(true)
	SpineUtil.createSpineObj(self.spineMc_down, vertex2(0,0), "mijing_cx_down", "Spine/ui/mijing", "efx_mijing", "efx_mijing",false)
		
	self.spineMc:getTransition("in"):play(function( ... )
		
	end)
	
	local spineNode = SpineUtil.createSpineObj(self.spineMc_up, vertex2(0,0), "mijing_cx_up", "Spine/ui/mijing", "efx_mijing", "efx_mijing",false)
	spineNode:setCompleteListener(function(name)
		Scheduler.scheduleNextFrame(function()
				if endFunc then endFunc() end
			end)
	end)
end

function FairyLandMapRect:playOutEffect(endFunc)
	SpineUtil.createSpineObj(self.spineMc_down, vertex2(0,0), "mijing_xs_down", "Spine/ui/mijing", "efx_mijing", "efx_mijing",false)
	
	
	self.spineMc:getTransition("out"):play(function( ... )

	end)

	local spineNode = SpineUtil.createSpineObj(self.spineMc_up, vertex2(0,0), "mijing_xs_up", "Spine/ui/mijing", "efx_mijing", "efx_mijing",false)
	spineNode:setCompleteListener(function(name)
					Scheduler.scheduleNextFrame(function()
							if endFunc then endFunc() end
						end)
				end)
				
end


--退出操作 在close执行之前 
function FairyLandMapRect:__onExit()
    print(1,"FairyLandMapRect __onExit")
	Scheduler.unschedule(self._updateTimeId)
--   self:_exit() --执行子类重写
   --[[self:clearEventListeners()
   for k,v in pairs(self.baseCtlView) do
   		v:__onExit()
   end--]]
end

return FairyLandMapRect