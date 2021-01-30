local TacticalDragManager = class("TacticalDragManager")

function TacticalDragManager:ctor(allSeat,tacticalView,arrayType)
	self.gobj = false
	self.dragData = {}
	self.dragData.overIndex = 0
	self.dragData.index = 0
	self.allSeat = allSeat 
	self.view = tacticalView.view
	self.arrayType = arrayType
	self:_init()
end
function TacticalDragManager:_init()
	for key,SeatItem in pairs(self.allSeat) do
		SeatItem.dragRect:setDraggable(SeatItem.initInfo.herId ~= 0)
		if (self.arrayType == GameDef.BattleArrayType.DreamLandSingle) then
			SeatItem.dragRect:setDraggable(false)
		end

		SeatItem.dragRect:addEventListener(FUIEventType.DragStart,handler(self,self.dragStart),101)
		SeatItem.dragRect:addEventListener(FUIEventType.DragMove,handler(self,self.dragMove),102)
		SeatItem.dragRect:addEventListener(FUIEventType.DragEnd,handler(self,self.dragEnd),103)
	end
	self.gobj = fgui.GObject:create()
	SpineUtil.createSpineObj(self.gobj,Vector2(0,0),"animation",PathConfiger.getSettlementRoot(),"Ef_tongyongxuanzhongguang")
	self.gobj:setVisible(false)
	self.view:addChild(self.gobj)
end
function TacticalDragManager:getDropIndex(pos)
	local rawRange ={[1]={100,310},[2]={330,415},[3]={425,640}}
	local rowRange ={[1]=550,[2]=500,[3]=400}
	local rawIndex=0
	local rowIndex=0
    for k, range in pairs(rawRange) do
		 if pos.y>range[1] and pos.y<=range[2] then
			 rowIndex=k
			 rawIndex=k
		 end
	end
	if rowIndex==0 or pos.x>920  then
		return false
	end
	if pos.x<rowRange[rowIndex] then
		rowIndex=2
	else
		rowIndex=1
	end
	return rowIndex*10 + rawIndex
end

function TacticalDragManager:dragStart(context)
	local seatItem = self.allSeat[context:getSender().seatId]
	if seatItem and seatItem:isHasHero() then
		SpineUtil.changeParent(seatItem.dragRect:displayObject(),seatItem.skeletonNode)	
		local spineRect = seatItem.skeletonNode:getBoundingBox()
		seatItem.skeletonNode:setPosition({x = 50,y = 0})
	end
	seatItem.view:setSortingOrder(10)
end
function TacticalDragManager:dragMove(context)
	local node = context:getSender()
	local seatItem = self.allSeat[context:getSender().seatId]
	if seatItem and seatItem:isHasHero() then
		local pos = seatItem.view:localToGlobal(seatItem.dragRect:getPosition())	
		local seatId = self:getDropIndex(pos)
		local lastOver = self.dragData.overIndex
		if seatId then
			local dropItem = self.allSeat[seatId]
			if seatId ~= lastOver then
				if lastOver ~= 0 then
					local lastOverItem = self.allSeat[lastOver]
					if not tolua.isnull(lastOverItem.skeletonNode) then
						lastOverItem.skeletonNode:setPosition(Vector2.zero)
					end
				end

				if dropItem:isHasHero() then
					local pos1 = seatItem.icon:localToGlobal(cc.p(0,0))
					local pos2 = dropItem.icon:localToGlobal(cc.p(0,0))
					local posDiff = {x = pos1.x - pos2.x,y = pos1.y - pos2.y}
					dropItem.skeletonNode:setPosition(posDiff.x,- posDiff.y)
				end
				dropItem.view:addChild(self.gobj)
				self.gobj:setPosition(dropItem.frame:getX(),dropItem.frame:getY())
				self.gobj:setVisible(true)
				self.dragData.overIndex = seatId
				self.dragData.index = context:getSender().seatId
			end
		else
			if lastOver ~= 0 then
				local lastOverItem = self.allSeat[lastOver]
				if lastOverItem:isHasHero() then
					lastOverItem.skeletonNode:setPosition(Vector2.zero)
				end
				self.dragData.overIndex = 0
				self.dragData.index = context:getSender().seatId
			end
		end
	end
end
function TacticalDragManager:dragEnd(context)
	local node = context:getSender()
	local seatItem = self.allSeat[context:getSender().seatId]
	if seatItem and seatItem:isHasHero() then
		local lastOver = self.dragData.overIndex
		if lastOver ~= 0 then
			local battleSeat1 = ModelManager.BattleModel:getSeatById(lastOver)--
			local battleSeat2 = ModelManager.BattleModel:getSeatById(self.dragData.index)
			local senderHeroInfo = ModelManager.BattleModel:getHeroByUid(battleSeat1.uuid)
			local dropHeroInfo = ModelManager.BattleModel:getHeroByUid(battleSeat2.uuid)
			
			battleSeat2:setHeroInfo(senderHeroInfo)--战斗两个英雄交换
			battleSeat1:setHeroInfo(dropHeroInfo)--战斗两个英雄交换

			local toItemSeat = self.allSeat[lastOver]--目标位置
			local fromItemSeat = self.allSeat[self.dragData.index]
			local toIsNull = toItemSeat.initInfo.heroId == 0

			local info = toItemSeat.initInfo
			toItemSeat.initInfo = fromItemSeat.initInfo
			fromItemSeat.initInfo = info

			toItemSeat:initItemCell(toItemSeat.initInfo.heroId,toItemSeat.initInfo.star,toItemSeat.initInfo.level,nil,toItemSeat.initInfo.fashionId, toItemSeat.initInfo.uniqueWeaponLevel)
			toItemSeat.skeletonNode:setPosition({x = 0,y = 0})
			toItemSeat.dragRect:setDraggable(true)
			if toIsNull then--如果目标是空的，目标就要赋值，起点置空
				fromItemSeat:resetItem()
			else
				fromItemSeat:initItemCell(fromItemSeat.initInfo.heroId,fromItemSeat.initInfo.star,fromItemSeat.initInfo.level,nil,fromItemSeat.initInfo.fashionId, fromItemSeat.initInfo.uniqueWeaponLevel)
				fromItemSeat.skeletonNode:setPosition({x = 0,y = 0})
			end
			Dispatcher.dispatchEvent("SeatItem_seatInfoUpdate");
		else
			SpineUtil.changeParent(seatItem.goWrap,seatItem.skeletonNode)
		end
		self.dragData.overIndex = 0
		self.dragData.index = 0
	end
	seatItem.dragRect:setPosition(seatItem.icon:getPosition().x,seatItem.icon:getPosition().y)
	seatItem.view:setSortingOrder(seatItem.zIndex)
	self.gobj:setVisible(false)
end


return TacticalDragManager
