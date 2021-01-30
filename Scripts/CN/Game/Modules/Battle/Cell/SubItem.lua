---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: lijiejian
-- Date: 2020-01-14 14:55:59
---------------------------------------------------------------------
--每个上阵布局信息的cell控制脚本，每个座位信息对应着一个cell实例

---@class SeatItem
local SubItem = class("SubItem")
local HeroPos=ModelManager.BattleModel.HeroPos
local BuffBase= require "Game.Modules.Battle.Effect.BuffBase"

function SubItem:ctor(view,posData)
	self.view = view
	self.packName  = "ui://Battle/"
	self.uuid=false
	self.heroId=false
	self.seatId=false
	self.isEmpty=true
	self.index=false
	self.icon=false
	self.drop=false
	self.drag=false
	self.Onclick=false
	self.fightCamp=0
	self.heroInfo=false
	self.heroPos=false
	self.controller=self.view:getController("state")
	self.frame= self.view:getChildAutoType("frame")
	self.colorImg=self.view:getChildAutoType("colorImg")--星级框
	self.camp=self.view:getChildAutoType("camp")
	self.level=self.view:getChildAutoType("level")
	self.img_quality=self.view:getChildAutoType("img_quality")
    self.lockTitle=self.view:getChildAutoType("lockTitle")
	

	local test=self.view:getChildAutoType("heroCell")
	
	--if test then
		--self.heroCell = BindManager.bindHeroCell(test)
	--end

	self.heroCell = BindManager.bindHeroCell(test)
	
	local starList=self.view:getChildAutoType("starList")
	--self.cardStar=BindManager.bindCardStar(starList)
	self.icon=test:getChildAutoType("img_icon")--正常上阵英雄
	self.isSub=true
	
	self.category=false
	
	self.type=false-- 1是怪，2是人
	self.buffBase=false
	self.baseData=false
	
	if posData  then
		self.heroPos=posData
		self.index=posData.pos+posData.seatId
		self.seatId=posData.seatId
	end
	self.view:setVisible(false)

end

function SubItem:initUI()
	if self.heroPos==HeroPos.enemy then
	    return 
	end
	local arrayType=BattleModel:getBattleArrayType()
    --if arrayType==GameDef.BattleArrayType.EndlessRoad then
	--end
	self.view:setVisible(arrayType~=GameDef.BattleArrayType.EndlessRoad)
	if self.seatId==31 and  not ModuleUtil.moduleOpen(ModuleId.Alternate_Front.id,false) then
		self.controller:setSelectedPage("lock")
		self.lockTitle:setText("60级解锁")
		self.view:setVisible(false)
	end
	
	if self.seatId==32 and  not ModuleUtil.moduleOpen(ModuleId.Alternate_Back.id,false) then
		self.controller:setSelectedPage("lock")
		self.lockTitle:setText("70级解锁")
		self.view:setVisible(false)
	end
	self.isSub=true
end


--绑定每个cell的事件
function SubItem:bindEvent()
	self.view:addEventListener(FUIEventType.TouchEnd,function(context)
			print(4,"bindEvent Onclick")
			self.Onclick(self.uuid,self.seatId)
			self:resetItem()
			self.drag=false
			self.drop=false
	end);
end

--绑定每个cell的事件
function SubItem:unBindEvent()
	self.view:removeEventListener(FUIEventType.TouchEnd);
	self.icon:setDraggable(false)
	self.icon:removeEventListener(FUIEventType.DragStart)
end


--设置英雄各属性显示UI的层级
function SubItem:getModelHungPos()
	--local hpHungPos=self.view:getParent():globalToLocal(self.view:localToGlobal(self.hpPos))
	return false
end


--设置位置信息
function SubItem:setData(heroId,uuid,type)

	
end

--设置位置信息
function SubItem:setHeroInfo(heroInfo)
	self.fightCamp=heroInfo.combat
	self.heroInfo=heroInfo
	self.heroId=heroInfo.code
	self.uuid=heroInfo.uuid
		
	if self.seatId<HeroPos.enemy.pos then
		self:bindEvent()
		ModelManager.BattleModel:fillSeatByIndex(self.index,false,self.fightCamp)
		local data={
			uuid = heroInfo.uuid,
			id=self.seatId
		}
		ModelManager.BattleModel:setRequestArrayInfo(self.uuid,data)
	end
	self:initItemCell(heroInfo.code,heroInfo.star,heroInfo.level,nil,heroInfo.fashionCode or heroInfo.fashion, heroInfo.uniqueWeaponLevel)
end


function SubItem:initItemCell(heroId,star,level,type, fashion, uniqueWeaponLevel)
	if type==nil then
	   type=1--默认是人
	end
	local heroStarInfo = DynamicConfigData.t_heroResource[star]
	--self.colorImg:setURL(PathConfiger.getCardQuaColor(heroStarInfo.headRes))
	local mapInfo= BattleModel:getMapInfo()
	self.frame:setURL(PathConfiger.getHeroFrame(star))

	
	if type==2 then
		local monster=DynamicConfigData.t_monster[heroId]--读怪物表的数据 monster_pro
		self.category=monster.category
	else
		local hero=DynamicConfigData.t_hero[heroId]--读英雄表的数据
		self.category=hero.category
	end

	self.type=type
	self.heroCell:setBaseData({code=heroId,star=star,level=level,category=self.category,type=self.type, fashion = fashion, uniqueWeaponLevel = uniqueWeaponLevel})
	self.controller:setSelectedPage("on")
	self.view:setVisible(true)
end

function SubItem:setAllController()
	self.buffBase=BuffBase.new(self.index,self)
end

function SubItem:setIcon(heroId)
	if heroId==false then
		return
	end
end

--获取组件本身的屏幕坐标
function SubItem:getSelfScreenPos()
	return self.view:getParent():localToGlobal(self.view:getPosition())--self.view局部坐标转屏幕坐标
end

--替补复活
function SubItem:callRevived(values,finished)
	print(086,"替补 复活callRevived")
	local value=0
	if type(values)=="table" then
		 value=values[1]
	else
		 value=values
	end

	if value==nil then
		value=self.baseData.hpMax
	end
	self.baseData.myhurt=self.baseData.hpMax-value
	self.baseData.hp=value
	self.controller:setSelectedPage("on")
	self.view:setGrayed(false)
	local skeletonNode=SpineUtil.createSpineObj(self.icon, Vector2.zero, nil, SpinePathConfiger.RevivedEffect.path, SpinePathConfiger.RevivedEffect.upEffect, SpinePathConfiger.RevivedEffect.upEffect,false,true)
	skeletonNode:setAnimation(0,"animation",false)
	BattleManager:schedule(function()
			if finished then
				finished()
			end
			skeletonNode:removeFromParent()
	end,1, 1)
	self.view:getChildAutoType("isDead"):setVisible(false)
	
end

--替补增加怒气
function SubItem:addRege(values)
	if self.baseData.rage==nil then
		self.baseData.rage=0
	end
	self.baseData.rage=self.baseData.rage+values
	
end

--有些buff给替补扣血然后还触发替补复活
function SubItem:buffHurt(buffEffect,finished)

	local statusList= SkillManager.bitStausType(buffEffect.status)
	local values=buffEffect.buffValue

	if self.index==231 then
		printTable(5656,statusList,"statusList")
	end
	if next(values)~=nil then
		for k, value in pairs(values) do
			for fk, func in pairs(statusList) do
				local eventCount=0
				if self["call"..func] then
					self["call"..func](self,value,function ()
							eventCount=eventCount+1
							if eventCount==#values then
								if finished then
									finished()
									finished=false
								end
							end
						end,k==#values)
				end
			end
		end
	end
	if finished then
		finished()
	end
end


function SubItem:setShiedBar(value)
    print(086,"替补居然能增加护盾！！！")
end


function SubItem:buffRevived(value,finished)
	local values={
		[1]=value
	}
	self:callRevived(values,finished)
end


function SubItem:callDead(values,finished,last)
	
	print(5656,"callDead",last)
	local value=0
	if type(values)=="table" then
		value=values[1]
	else
		value=values
	end
    if value then
		self.baseData.myhurt=self.baseData.hpMax-value
		self.baseData.hp=value
	end
	
	if last then
		self:goDie()
	end
	if finished then
		finished()
	end
	
end

function SubItem:goDie()
	self.view:setGrayed(true)
	self.view:getChildAutoType("isDead"):setVisible(true)
	self.controller:setSelectedPage("into")
end



--重置位置的信息
function SubItem:resetItem()
	if not tolua.isnull(self.view) then
		self.frame:setURL(string.format("%s%s.png","Icon/heroFrame/heroFrame",1))
		self.icon:setURL("")
		self:unBindEvent()
		self.controller:setSelectedPage("out")
		self:initUI()
	end

	self.heroId=false
	if self.heroPos==HeroPos.player then
		ModelManager.BattleModel:fillSeatByIndex(self.index,true,-self.fightCamp)
		ModelManager.BattleModel:setRequestArrayInfo(self.uuid,nil)
	end
	self.uuid=false
	self.fightCamp=0
	self.category=false
end

function SubItem:resetData()
	self.frame:setURL(string.format("%s%s.png","Icon/heroFrame/heroFrame",1))
	self.icon:setURL("")
	self.heroId=false
	self.uuid=false
	self.fightCamp=0
	self:unBindEvent()
	self.controller:setSelectedPage("out")
	self.category=false
end

function SubItem:exit()
	print(1,"SubItem exit",self.index)
end
return SubItem