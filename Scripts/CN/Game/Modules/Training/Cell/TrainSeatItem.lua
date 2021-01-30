---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: lijiejian
-- Date: 2020-01-14 14:55:59
---------------------------------------------------------------------
--每个上阵布局信息的cell控制脚本，每个座位信息对应着一个cell实例

---@class TraningCell
local SeatItem= require "Game.Modules.Battle.Cell.SeatItem"
local TrainSeatItem,Super = class("TrainSeatItem",SeatItem)
local HeroPos=ModelManager.BattleModel.HeroPos



function TrainSeatItem:ctor(view)

end

function TrainSeatItem:dragRollOver(lastIndex)
	if lastIndex~=0 then
		local lastOverItem=TrainingModel:getSeatById(lastIndex)
		lastOverItem:dragRollOut()
	end

	self:inputRollOver()

end


function TrainSeatItem:inputRollOver()
	if self.skeletonNode then
		local targetIndex=BattleModel:getDragData().index
		local sender=TrainingModel:getSeatById(targetIndex)
		if sender==nil then
			return
		end
		local pos1=sender.icon:localToGlobal(self.sinePos)
		local pos2=self.icon:localToGlobal(self.sinePos)
		local posDiff={x=pos1.x-pos2.x,y=pos1.y-pos2.y}
		self.skeletonNode:setPosition(self.sinePos.x+posDiff.x,self.sinePos.y-posDiff.y)
	end
	if BattleModel.rollOverFx then
		self.view:addChild(BattleModel.rollOverFx)
		BattleModel.rollOverFx:setPosition(self.frame:getX(),self.frame:getY())
		BattleModel.rollOverFx:setVisible(true)
	end
end


function TrainSeatItem:setHeroInfo(heroInfo,playBorn)
	if heroInfo==false  then
		self:resetItem()
		return
	end
	self.heroId=heroInfo.code
	self.uuid=heroInfo.uuid
	self.heroInfo=heroInfo
	self:initItemCell(heroInfo.code,heroInfo.star,heroInfo.level,nil,heroInfo.fashionId, heroInfo.uniqueWeaponLevel)
	if playBorn then
		self:playBorn();
	end
	self.view:setSortingOrder(self.zIndex)
	self:bindEvent()
	--print(5656,self.seatId,"号位放了一个英雄",heroInfo.code)
	TrainingModel.answer={
		heroId=self.heroId,
		pos=self.seatId	
	}
end


--绑定每个cell的事件
function TrainSeatItem:bindEvent()
	if tolua.isnull(self.view) then
		return
	end

    if self.canDrag then
		Super.bindEvent(self)
	else
		self.view:addClickListener(function(context)
				if GuideModel:IsGuiding() then
					return
				end
				if self.drag==true then
					self.drag=false
					return
				end
				local uuid=self.uuid
				local seatId=self.seatId
				self.Onclick(uuid,seatId)
		end);
	end
end

function TrainSeatItem:itemDragMove()
	if not self.skeletonNode then
		return
	end
	local movePos=self.view:localToGlobal(self.dragRect:getPosition())
	movePos=self.view:getParent():globalToLocal(movePos)
	local seatId=TrainingModel:getDropIndex(movePos)
	local dropItem=false
	if seatId then
		dropItem=TrainingModel:getSeatById(seatId)
		if not dropItem.canDrag then
			dropItem=false
		end
	end
	
	
	local lastOver=BattleModel:getDragData().overIndex
	if dropItem then
		if seatId~=self.index and seatId~=lastOver then
			dropItem:dragRollOver(lastOver)
			BattleModel:setDragData({index=self.seatId,overIndex=seatId})
		end
	else
		if lastOver~=0 then
			local dropItem=TrainingModel:getSeatById(lastOver)
			dropItem:dragRollOut()
			BattleModel:setDragData({index=self.seatId,overIndex=0})
		end
	end
	self.skeletonNode:setPosition({x=50,y=0})
	
end


function TrainSeatItem:itemDragEnd()
	if not tolua.isnull(self.view) then
		local lastOver=BattleModel:getDragData().overIndex
		if self.skeletonNode then
			SpineUtil.changeParent(self.goWrap,self.skeletonNode)
		end
		if lastOver~=0 then
			local dropItem=TrainingModel:getSeatById(lastOver)
			dropItem:dropInCallBack()
		else
			--self.dragRect:setPosition(self.icon:getPosition().x,self.icon:getPosition().y)
		end
		self.dragRect:setPosition(self.icon:getPosition().x,self.icon:getPosition().y)
		BattleModel:setDragData({index=0,overIndex=0})

	end
	self.view:setSortingOrder(self.zIndex)
end


--卡牌被拖入框中的回调
function TrainSeatItem:dropInCallBack(userdata)

	if  BattleModel.rollOverFx then
		BattleModel.rollOverFx:setVisible(false)
	end
	if GuideModel:IsGuiding() then
		Dispatcher.dispatchEvent(EventType.guideType2_checkNext,"playerSeatLatout")
	end


	local senderIndex=BattleModel:getDragData().index
    print(5656,senderIndex,"拖入信息id")

	local sender=TrainingModel:getSeatById(senderIndex)
	print(5656,sender.uuid,"sender.uuid")
	local dropCell=self
	local senderHeroInfo= TrainingModel:getHeroByUid(dropCell.uuid)
	local dropHeroInfo=TrainingModel:getHeroByUid(sender.uuid)
	sender:setHeroInfo(senderHeroInfo)--两个英雄交换位置
	
	print(5656,dropHeroInfo,"???")
	dropCell:setHeroInfo(dropHeroInfo)--两个英雄交换位置
	Dispatcher.dispatchEvent("SeatItem_seatInfoUpdate");


end	


function TrainSeatItem:setForbid()
	self.frame:setURL(PathConfiger.getArrayImage("forbid"))
end
function TrainSeatItem:setDefault()
	self.frame:setURL(PathConfiger.getArrayImage("defaut"))
end
	

--重置位置的信息
function TrainSeatItem:resetItem()
	--print(5656,self.seatId,"号位下阵了一个英雄",self.heroId)
	Super.resetItem(self)
	TrainingModel.answer={}
end





return TrainSeatItem