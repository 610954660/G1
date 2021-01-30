---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: lijiejian
-- Date: 2020-01-14 14:55:59
---------------------------------------------------------------------
--每个上阵布局信息的cell控制脚本，每个座位信息对应着一个cell实例

---@class SeatItem
local SeatItem = class("SeatItem",BindView)
local HeroPos=ModelManager.BattleModel.HeroPos
local CameraController=require "Game.Modules.Battle.Effect.CameraController"


local bornEffect={
	path = "Effect/battle",
	downEffect=  "Ef_battle_enter_down",
	upEffect="Ef_battle_enter_up",
	checkEffect="Ef_tongyongxuanzhongguang"
}

function SeatItem:ctor(view)
	self.view = view
	self.packName  = "Battle"
	self.uuid=false
	self.heroId=false
	self.seatId=false
	self.isEmpty=true
	self.index=false
	self.drag=false
	self.Onclick=false
	self.skeletonNode=false--保留加载spine接口
	self.spinePool=false--
	self.controller=self.view:getController("state")
	self.fightCamp=0
	self.heroInfo=false
	self.heroPos=false
	self.star=0
	self.level=0
	self.category=false
	self.initInfo = false
	self.arrayType = false

	self.type=false-- 1是怪，2是人
	self.frame= self.view:getChildAutoType("frame")
	self.camp=self.view:getChildAutoType("camp")
	self.img_uniqueWeapon=self.view:getChildAutoType("img_uniqueWeapon")
	self.levelLabel=self.view:getChildAutoType("level")
	
	self.heroInfo_tactical = self.view:getChildAutoType("heroInfo_tactical")
	self.level1 = self.view:getChildAutoType("level1")
	self.fessionalIcon = self.view:getChildAutoType("fessionalIcon")
	self.cardcategoryIcon = self.view:getChildAutoType("cardcategoryIcon")


	self.icon=self.view:getChildAutoType("seatIcon")--正常上阵英雄
	self.dragRect=self.view:getChildAutoType("dragRect")--正常上阵英雄
	self.dragPos=self.dragRect:getPosition()
	
	self.goWrapObj=self.view:getChildAutoType("goWrap")
	self.goWrap=self.goWrapObj:displayObject()--spine动画挂点
	self.roollOverFx=false
	
	
	self.frame:setURL(PathConfiger.getArrayImage("defaut"))
	
	self.design=self.view:getChildAutoType("spineRect")
	if self.design then
		self.design:setVisible(false)
	end
	self.controller:setSelectedPage("out")
	
	self.sinePos=Vector2.zero
	self.zIndex=false
	
	self.posAttr = self.view:getChildAutoType("posAttr")
	self.tacShowCtrl = self.view:getController("tacShowCtrl")
end


function SeatItem:showTactial_event(_,params)
	if params then
		self.tacShowCtrl:setSelectedIndex(1)
	else
		self.tacShowCtrl:setSelectedIndex(0)
		return
	end
    self:showTactial_event2()
end

function SeatItem:showTactial_event2(_,params)
	if not TacticalModel:getOpenFlag() then
		return
	end

	if self.heroPos==HeroPos.player then
		if not self.isEmpty then
			local arrayType = self.arrayType
			local _curTactical = ModelManager.TacticalModel:getCurTactical(arrayType) --当前选中的阵法
		
			if ModelManager.TacticalModel:isCurUsing(arrayType, _curTactical) then
				self:updatePosAttr(_curTactical)
			else
				self.tacShowCtrl:setSelectedIndex(0)
			end
		else
			self.tacShowCtrl:setSelectedIndex(0)
		end
		
	elseif self.heroPos==HeroPos.enemy then
		if not self.isEmpty then
			--是敌人
			local id = TacticalModel:getPreOtherTacData()
			if id and id>0 then
				self:updatePosAttr(id)
			else
				self.tacShowCtrl:setSelectedIndex(0)
			end
		else
			self.tacShowCtrl:setSelectedIndex(0)
		end
	end

end

function SeatItem:updatePosAttr( tactical )
	if tactical <= 0 then self.tacShowCtrl:setSelectedIndex(0) return end
	if not self.heroId then self.tacShowCtrl:setSelectedIndex(0) return end
	self.tacShowCtrl:setSelectedIndex(1)
	local level = ModelManager.TacticalModel:getTacticalLevel(tactical)
	local info = DynamicConfigData.t_Tactical[tactical][level]
	if(info) then
		local txt = self.posAttr:getChildAutoType("pos")
		txt:setText(info["standDescribe"..self.index])
		self.posAttr:getChildAutoType("num"):setText(self.index)
	end
end


function SeatItem:dragRollOver(lastIndex)
	if lastIndex~=0 then
		local lastOverItem=ModelManager.BattleModel:getSeatById(lastIndex)
		lastOverItem:dragRollOut()
	end

	self:inputRollOver()

end


function SeatItem:inputRollOver()
	if self.skeletonNode then
		local targetIndex=BattleModel:getDragData().index
		local sender=ModelManager.BattleModel:getSeatById(targetIndex)
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



function SeatItem:dragRollOut()
	if self.skeletonNode then
		self.skeletonNode:setPosition(Vector2.zero)
	end
	if BattleModel.rollOverFx then
		BattleModel.rollOverFx:setVisible(false)
	end
end


--绑定每个cell的事件
function SeatItem:bindEvent()
	
	if tolua.isnull(self.view) then
		return 
	end
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
			self:showTactial_event2()
	end);
	self.dragRect:setDraggable(true)
	if (BattleModel:getBattleArrayType() == GameDef.BattleArrayType.DreamLandSingle) then
		self.dragRect:setDraggable(false)
	end
	self.dragRect:addEventListener(FUIEventType.DragStart,function(context)
          self:itemDragStart()
	end,101)
	self.dragRect:addEventListener(FUIEventType.DragMove,function(context)
		  self:itemDragMove(context)
	end,102)
	
self.dragRect:addEventListener(FUIEventType.DragEnd,function(context)
		 self:itemDragEnd()
	end,103)
end


function SeatItem:itemDragStart()
	if self.skeletonNode then
		SpineUtil.changeParent(self.dragRect:displayObject(),self.skeletonNode)
		local spineRect=self.skeletonNode:getBoundingBox()
		self.skeletonNode:setPosition({x=72,y=50})
	end
	self.drag=true
	BattleModel:setDragData({index=self.seatId,overIndex=0})
	self.view:setSortingOrder(10)
end

function SeatItem:itemDragMove(context)
	if not self.skeletonNode then
		return
	end
	local inputPos=Vector2(context:getInput():getX(),context:getInput():getY())
	

	
	--local movePos=self.view:localToGlobal(self.dragRect:getPosition())
	local movePos=self.view:getParent():globalToLocal(inputPos)
	--context:getInput()
	printTable(5656,inputPos)
	--printTable(5656,movePos)
	
	
	
	local seatId=BattleModel:getDropIndex(movePos)
	local lastOver=BattleModel:getDragData().overIndex
	if seatId then
		local dropItem=ModelManager.BattleModel:getSeatById(seatId)
		if seatId~=self.index and seatId~=lastOver then
			dropItem:dragRollOver(lastOver)
			BattleModel:setDragData({index=self.seatId,overIndex=seatId})
		end
	else
		if lastOver~=0 then
			local dropItem=ModelManager.BattleModel:getSeatById(lastOver)
			dropItem:dragRollOut()
			BattleModel:setDragData({index=self.seatId,overIndex=0})
		end
	end
	self.skeletonNode:setPosition({x=72,y=50})
end


function SeatItem:itemDragEnd()
	if not tolua.isnull(self.view) then
		local lastOver=BattleModel:getDragData().overIndex
		if self.skeletonNode then
			SpineUtil.changeParent(self.goWrap,self.skeletonNode)
		end
		if lastOver~=0 then
			local dropItem=ModelManager.BattleModel:getSeatById(lastOver)
			dropItem:dropInCallBack()
		else
			--self.dragRect:setPosition(self.icon:getPosition().x,self.icon:getPosition().y)
		end
		self.dragRect:setPosition(self.dragPos.x,self.dragPos.y)
		BattleModel:setDragData({index=0,overIndex=0})
		
	end
	self.view:setSortingOrder(self.zIndex)
end


--绑定每个cell的事件
function SeatItem:unBindEvent()
	if tolua.isnull(self.view) then return end
	self.view:removeClickListener();
	self.dragRect:setDraggable(false)
	self.dragRect:removeEventListener(FUIEventType.DragStart,101)
	self.dragRect:removeEventListener(FUIEventType.DragMove,102)
	self.dragRect:removeEventListener(FUIEventType.DragEnd,103)
end


--卡牌被拖入框中的回调
function SeatItem:dropInCallBack(userdata)
	
	if  BattleModel.rollOverFx then
		BattleModel.rollOverFx:setVisible(false)
	end
	if GuideModel:IsGuiding() then 
		Dispatcher.dispatchEvent(EventType.guideType2_checkNext,"playerSeatLatout")
	end
	
	
	local senderIndex=BattleModel:getDragData().index
	

	local sender=ModelManager.BattleModel:getSeatById(senderIndex)
	local dropCell=self
	if dropCell.uuid == sender.uuid then
		return
	end
	local senderHeroInfo= ModelManager.BattleModel:getHeroByUid(dropCell.uuid)
	local dropHeroInfo=ModelManager.BattleModel:getHeroByUid(sender.uuid)
	sender:setHeroInfo(senderHeroInfo,false,dropCell.arrayType)--两个英雄交换位置
	dropCell:setHeroInfo(dropHeroInfo,false,sender.arrayType)--两个英雄交换位置
	Dispatcher.dispatchEvent("SeatItem_seatInfoUpdate");


end

--设置位置信息
function SeatItem:setHeroInfo(heroInfo,playBorn,arrayType,type)
	if heroInfo==false  then
		self:resetItem()
		return
	end
	self.fightCamp=heroInfo.combat or 0
	self.heroId=heroInfo.code
	self.uuid=heroInfo.uuid
	if self.heroPos==HeroPos.player then
		self:unBindEvent()	
		self:bindEvent()--如果这里是交换位置 事件多了一次
		if  self.heroInfo==false then
			ModelManager.BattleModel:fillSeatByIndex(self.index,false,self.fightCamp)
		end
		local data={
			uuid = heroInfo.uuid,
			id=self.seatId
		}
		ModelManager.BattleModel:setRequestArrayInfo(self.uuid,data)
	end
	
	self.heroInfo=heroInfo
	self:initItemCell(heroInfo.code,heroInfo.star,heroInfo.level,nil,heroInfo.fashionCode or heroInfo.fashion, heroInfo.uniqueWeaponLevel or heroInfo.uniqueWeapon,arrayType)
	if playBorn then
		self:playBorn();
	end
	self.view:setSortingOrder(self.zIndex)
	self:showTactial_event2()
end


function SeatItem:initItemCell(heroId,star,level,type,fashion, uniqueWeaponLevel,arrayType)
	self.arrayType = arrayType or false
	self.star=star
	self.level=level
	if type==nil then
		type=1--默认是人
	end
	self.type=type
	local heroStarInfo = DynamicConfigData.t_heroResource[star]
	if heroStarInfo then
		self.frame:setURL(PathConfiger.getArrayImage(heroStarInfo.headRes))
	else
		self.frame:setURL(PathConfiger.getArrayImage("defaut"))
	end
	local mapInfo= BattleModel:getMapInfo()
	if heroId ~= 0 then
		self.controller:setSelectedIndex(1)
		if self.type==2 then 
			local monster=DynamicConfigData.t_monster[heroId]--读表的数据
			if monster then
				self.camp:setURL(PathConfiger.getCardCategory(monster.category))
				self.category=monster.category
			end
		else
			local hero=DynamicConfigData.t_hero[heroId]--读表的数据
			if hero then
				self.controller:setSelectedIndex(1)
				self.camp:setURL(PathConfiger.getCardCategory(hero.category))
				self.category=hero.category
			end
		end 
		
		if uniqueWeaponLevel and uniqueWeaponLevel >= 0 then
			self.img_uniqueWeapon:setURL(PathConfiger.getUniqueWeaponLevel(uniqueWeaponLevel))
		else
			self.img_uniqueWeapon:setURL(nil)
		end
	else
		self.controller:setSelectedIndex(0)
	end
	self.levelLabel:setText(level.."级")
	if self.heroPos==HeroPos.enemy then
		self.goWrap:setScaleX(-1)
	end
    self:createSpine(heroId,fashion)
	self.heroId=heroId
	if self.isTactical and heroId then --阵法
		self.controller:setSelectedPage("out")
		self.heroInfo_tactical:setVisible(true)
		self.level1:setText(level.."级")
		local hero = DynamicConfigData.t_hero[heroId]
		if hero then
			self.fessionalIcon:setURL(PathConfiger.getCardProfessional(hero.professional))
			self.cardcategoryIcon:setURL(PathConfiger.getCardCategoryColor(hero.category))
		end
	end
end

function SeatItem:setIsTactical(state)
	self.isTactical = state
end

function SeatItem:createSpine(heroId,fashion)
	if heroId == 0 then return end
	local skeletonNode=false
	if self.heroPos==HeroPos.player then
			if self.skeletonNode then
				self.skeletonNode:removeFromParent()
			end
			skeletonNode=SpineMnange.createSprineById(heroId,true,nil,nil,fashion)
			skeletonNode:retain()
	else
		local spinePool=false
		if self.spinePool and self.heroId then
			self.spinePool:returnObject(self.skeletonNode)
		end
		skeletonNode,spinePool=SpineMnange.createSprineById(heroId,self.type==1,1,nil,fashion)
		self.spinePool=spinePool
	end
	
	skeletonNode:setAnimation(0, "stand", true);
	self.goWrap:addChild(skeletonNode)
	self.skeletonNode=skeletonNode
	self.controller:setSelectedPage("on")


end

--播放入场动画
function SeatItem:playBorn()
	local skeletonNode=SpineMnange.createByPath(bornEffect.path,bornEffect.downEffect)
	self:addSpine(skeletonNode,self.icon:getPosition(),0)
	local skeletonNode2=SpineMnange.createByPath(bornEffect.path,bornEffect.upEffect)
	self:addSpine(skeletonNode2,self.icon:getPosition(),2)
end


function SeatItem:addSpine(skeletonNode,pos,zIndex,delayTime)
	local skillObj = fgui.GObject:create()
	skillObj:displayObject():addChild(skeletonNode)
	self.view:addChild(skillObj)
	skillObj:setSortingOrder(zIndex)
	skillObj:setPosition(pos.x,pos.y)
	skeletonNode:setAnimation(0, "animation", false);
	Scheduler.schedule(function()
			if tolua.isnull(self.view) then
				return
			end
			if skillObj then
				skillObj:removeFromParent()
			end
	end,0.5,1)
end

--重置位置的信息
function SeatItem:resetItem()
	if self.heroId==false then
		print(0932,"没东西",self.seatId)
		return 
	end	
	if tolua.isnull(self.view) then
		return 
	end
	self.frame:setURL(PathConfiger.getArrayImage("defaut"))
	if self.heroPos==HeroPos.player then
		ModelManager.BattleModel:setRequestArrayInfo(self.uuid,nil)
		ModelManager.BattleModel:fillSeatByIndex(self.index,true,-self.fightCamp)
	end
	self.uuid=false
	self.fightCamp=0
	if not self.isTactical then
		self:unBindEvent()
	end
	self.controller:setSelectedPage("out")   
	self.heroInfo=false
	self.category=false
	self.view:setSortingOrder(0)
	self:recycleSpine()
	self.heroId=false
	if self.isTactical then
		self.heroInfo_tactical:setVisible(false)
	end
	self:showTactial_event2()
end

function SeatItem:recycleSpine()
	if self.heroId==false then
		return
	end
	if self.heroPos==HeroPos.player then
		if self.skeletonNode then
			SpineUtil.relaseSpine(self.skeletonNode)
			self.skeletonNode=false
		end
	else
		if self.spinePool then
			self.spinePool:returnObject(self.skeletonNode)
		end
	end
end
--------------------------阵法特殊处理------------------------------
function SeatItem:setTacticalInfo(info)
	self.initInfo = info
end
function SeatItem:getTacticalInfo()
	self.initInfo = info
end
function SeatItem:isHasHero()
	return self.initInfo and self.initInfo.heroId ~= 0
end
--------------------------阵法特殊处理------------------------------
function SeatItem:_exit()
	self:recycleSpine()
end


return SeatItem