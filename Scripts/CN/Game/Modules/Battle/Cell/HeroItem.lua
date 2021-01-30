---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: lijiejian
-- Date: 2020-01-16 20:18:49
---------------------------------------------------------------------
-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File
local SkillConfiger=require "Game.ConfigReaders.SkillConfiger"
local BattleObjState= require "Game.Modules.Battle.Fsm.BattleObjState"

local HeroPos=BattleModel.HeroPos
local HeroItem = class("HeroItem",BindView)

local BarController= require "Game.Modules.Battle.Effect.BarController"
local BuffBase= require "Game.Modules.Battle.Effect.BuffBase"


local bornEffect={
	path = "Effect/battle",
	downEffect=  "Ef_battle_enter_down",
	upEffect="Ef_battle_enter_up",
}

---@class HeroItem  战斗角色操作类
function HeroItem:ctor(view,posData)
	self.view = view

	self.heroType=1  --1是小怪  2是boss

	self.initPos=false
	self.skeletonNode=false
	self.spinePool=false

	self.buffIconList=false
	self.bossBar=false

	self.goWrapParent=self.view:getChildAutoType("goWrap")--spine的交底中心點
	self.goWrap=self.goWrapParent:displayObject()--spine动画挂点
	self.subHp=self.view:getChildAutoType("subHp")--飘血的动效的位置
	self.hpTipCount=0


	self.skillName=self.view:getChildAutoType("skillName")
	self.skillFrame=self.view:getChildAutoType("skillFrame")
	self.skillTip=self.view:getChildAutoType("skillTip")



	self.barGroup=self.view:getChildAutoType("bar")
	self.hpProgressBar=self.view:getChildAutoType("hpBar")
	self.hpBarYellow=self.view:getChildAutoType("hpBarYellow")--第二层掉血
	self.angerBar=self.view:getChildAutoType("angerBar")--怒气值
	self.shieldBar=self.view:getChildAutoType("shieldBar")--护盾

	self.design=self.view:getChildAutoType("spineRect")


	self.buffIconList=self.view:getChildAutoType("buffIconList")

	self.packName  = "Battle"


	self.baseData=false --战斗基本信息
	self.model=0
	self.fashionLihuiIndex = 0 --时装立绘index

	self.scheduleID=false

	self.haveDed=false
	self.isDie=false
	self.isHero=true
	self.category=false
	self.hideBarGroup = false --是否隐藏血条

	self.zIndex=self.view:getSortingOrder()


	self.barController=false
	self.buffBase=false
	self.battleState=false


	self.hpPos=false
	self.isFront=true

	self:allSortingOrder()

	if posData then
		self.heroPos=posData
		self.index=posData.pos+posData.seatId
		self.seatIndex=(math.floor(posData.seatId/10)-1)*3+posData.seatId%10
		--print(086,(math.floor(posData.seatId/10)-1)*3,posData.seatId%10)
	   -- print(086,self.seatIndex,"self.seatIndex")
	end

	Dispatcher.addEventListener(EventType.battle_buffUpdate,self)
	self.initPos=self.view:getPosition()
end




--设置英雄数据
function HeroItem:setData(baseData,delay,onlySet)
	if baseData==false then
		return
	end
	self.baseData = baseData
	self.haveDed=false
	self.isDie=false
	self.goWrapParent:setScaleX(0)
	local mapInfo= BattleModel:getMapInfo()
	
    if onlySet then
		self:putHero(baseData)
	else
		if delay==nil then
			delay=0
		end
		BattleManager:schedule(function()
				self:playBorn()
				BattleManager:schedule(function()
						self:putHero(baseData)
					end,0.18,1)
		end,delay,1)--按顺序进场
	end
	self.view:setVisible(true)

end

--播放入场动画
function HeroItem:playBorn()
	local skeletonNode=SpineMnange.createByPath(bornEffect.path,bornEffect.downEffect)
	self:addSpine(skeletonNode,self.goWrapParent:getPosition(),0,1)
	local skeletonNode2=SpineMnange.createByPath(bornEffect.path,bornEffect.upEffect)
	self:addSpine(skeletonNode2,self.goWrapParent:getPosition(),0,1)
end


--创建spine
function HeroItem:addSpine(skeletonNode,pos,zIndex,delayTime)
	if tolua.isnull(self.view) then
		return
	end
	local skillObj =fgui.GObject:create()
	skillObj:displayObject():addChild(skeletonNode)
	self.view:addChild(skillObj)
	skillObj:setSortingOrder(zIndex)
	skillObj:setPosition(pos.x,pos.y)
	skeletonNode:setAnimation(0, "animation", false);
	if delayTime then
		BattleManager:schedule(function()
				if skillObj then
					skillObj:removeFromParent()
				end
			end,delayTime,1)
	end
end


function HeroItem:putHero(baseData)

	local skeletonNode=false
	local spinePool=false
	if self.baseData.type==2 then
		skeletonNode,spinePool=SpineMnange.createSprineById(baseData.code,false,1,nil,baseData.fashion)--这是怪物
		local monster=DynamicConfigData.t_monster[baseData.code]
		self.category=monster.category
		self.model=monster.model
		self.isHero=false
	else
		skeletonNode,spinePool=SpineMnange.createSprineById(baseData.code,true,1,nil,baseData.fashion)--这是英雄
		local hero=DynamicConfigData.t_hero[baseData.code]
		self.category=hero.category
		self.model=hero.model
		self.isHero=true
	end
	
	if baseData.fashion then
		local fashionConfig = DynamicConfigData.t_Fashion[baseData.code][baseData.fashion]
		self.fashionLihuiIndex = fashionConfig and fashionConfig.fashionIndex[2] or 0
	else
		self.fashionLihuiIndex = 0
	end
		

	if self.spinePool then
		if self.battleState then
			self.battleState:OnLeave()
		end
		self.spinePool:returnObject(self.skeletonNode)
	end
	self.skeletonNode=skeletonNode
	self.spinePool=spinePool
	self.goWrap:addChild(self.skeletonNode)
	local scale=1
	if baseData.scale then
		scale=baseData.scale
	end
	if self.heroPos==HeroPos.enemy then
		self.goWrapParent:setScale(-scale,scale)
		local mapInfo= BattleModel:getMapInfo()
		if mapInfo.battleType==2 then
			self.heroType=2
			local spineRect=self.skeletonNode:getBoundingBox()
			local sw=spineRect.width
			if sw>500 then
				sw=500
			end
			self.design:setSize(sw,spineRect.height)
		end
		if mapInfo.bossEnlarge and next(mapInfo.bossEnlarge)~=nil then
			for k, seatIndex in pairs(mapInfo.bossEnlarge) do
				if self.seatIndex==seatIndex then
					self.goWrapParent:setScale(-scale*1.2,scale*1.2)
				end
			end
		end	
		--local arrayType=FightManager.frontArrayType()	
		--if arrayType==GameDef.BattleArrayType.Chapters then
			--local isBoss= PushMapModel:guankaIsBoss()
			--if isBoss then
	
			--end
		--end	
	else
		
		self.goWrapParent:setScale(scale,scale)
	end
	self.baseData=baseData
	self.baseData.myhurt=self.baseData.hpMax-self.baseData.hp
	local arrayType=FightManager.frontArrayType()
	if (arrayType == GameDef.BattleArrayType.EvilMountain or arrayType == GameDef.BattleArrayType.EvilMountainTwo) and baseData.type == 2 then  -- 魔灵山boss血条
		Dispatcher.dispatchEvent(EventType.GuildMLS_battleInitBossHp,{hpMax = self.baseData.hpMax,myhurt = self.baseData.myhurt,hp = self.baseData.hp})
	end
	self.view:setVisible(true)
	self.view:setSortingOrder(self.zIndex)
	self.hpPos= self:setBarByType()
	self:setAllController()
	
	self.barController:setHpBar(self.baseData.hp,true)
	if self.baseData.rage==nil then
		self.baseData.rage=0
	end
	self.barController:setRageBar(self.baseData.rage)
	if self.baseData.addShield then
		self.barController:setShiedBar(self.baseData.addShield)
	end
	--初始化buff处理
	if baseData.buffs ~= nil then
		ModelManager.BattleModel:addBuff(self.index, baseData.buffs )
	end
	self.design:setTouchable(true)
	self.design:addClickListener(function (context)
			context:stopPropagation()--阻止事件冒泡
			if(self.baseData) then
				local buffList = ModelManager.BattleModel:getBuff(self.index)
				if ViewManager.isShow("BattleBuffView") then
					--如果窗口已经打开直接刷新
					Dispatcher.dispatchEvent(EventType.battle_updateBuffList,self.baseData.code,buffList,self.isHero)
				else
					ViewManager.open("BattleBuffView",{heroId=self.baseData.code,buffData=buffList,isHero=self.isHero,level=self.baseData.level})
				end
			end
	end)
	if self.baseData.hp==0  then
		self:goDie()
	end
	
end

--创建游戏角色所有管理类血条 技能 特效 等
function HeroItem:setAllController()
	if self.index then
	   SkillManager.addSkillAciton(
		{
		  skeletonNode=self.skeletonNode,		
		  view=self.view,
	      id=self.index,
		  category=self.category,
		  zIndex=self.zIndex,
		  fashion=self.baseData.fashion,
		  heroCode=self.baseData.code
		})
		
		
		local barGroup={
			shidBar=self.shieldBar,
			hpProgressBar=self.hpProgressBar,
			hpBarYellow=self.hpBarYellow,
			bossBar=self.bossBar,
			angerBar=self.angerBar,
			barParent=self.barGroup,
			heroType=self.heroType,		
		}

		self.barController=BarController.new(barGroup,self.baseData,self)
		self.buffBase=BuffBase.new(self.index,self)

		local stateDate={
			skeletonNode=self.skeletonNode,
			index=self.index,
			view=self.view,
			barController=self.barController,
			buffList=self.buffIconList,
			skillTip=self.skillTip,
		}
		self.battleState=BattleObjState.new(stateDate)
		self.battleState:OnInit()
	end
end


--获得改英雄血条挂点的屏幕坐标
function HeroItem:getModelHungPos()
	local hpHungPos=self.view:getParent():globalToLocal(self.view:localToGlobal(self.hpPos))
	return {x=hpHungPos.x-30,y=hpHungPos.y}
end

function HeroItem:getModelLocalHungPos()
	return self.hpPos
end


function HeroItem:getModelHpPosPos()
	local hpPos=self.view:getParent():globalToLocal(self.subHp:localToGlobal(Vector2.zero))
	return hpPos
end

--设置英雄各属性显示UI的层级
function HeroItem:allSortingOrder()
	--self.view:setSortingOrder(self.zIndex)
	self.goWrapParent:setSortingOrder(self.zIndex)
	self.hpBarYellow:setSortingOrder(self.zIndex+2)
	self.hpProgressBar:setSortingOrder(self.zIndex+3)
	self.angerBar:setSortingOrder(self.zIndex+2)
	self.buffIconList:setSortingOrder(self.zIndex+2)
	self.shieldBar:setSortingOrder(self.zIndex+4)
	self.skillFrame:setSortingOrder(self.zIndex+5)
	self.skillName:setSortingOrder(self.zIndex+6)
	self.design:setSortingOrder(self.zIndex+5)
end


--根据怪的类型设置血条
function HeroItem:setBarByType()
	local hpPos=self:getBonPosition("hanging_point")
	hpPos= self:getSelfLocalPos(self:getHungPos(hpPos),self.view)
	self.buffIconList:setPosition(hpPos.x-39,hpPos.y-30)
	self.skillTip:setPosition(self.skillTip:getPosition().x,hpPos.y-80)
	if self.heroType==1 then
		self.barGroup:setVisible((not self.hideBarGroup) and true)
		self.barGroup:setPosition(hpPos.x-39,hpPos.y-25)
	else
		local viewInfo=ViewManager.getViewInfo("BattleBeginView")
		if viewInfo then
			self.bossBar = viewInfo.window.ctlView["GuildBossBarView"].bossBar
			self.barGroup:setVisible(false)
			self.bossBar:setVisible(true)
		end
	end
	return hpPos
end


----近身攻击
function HeroItem:standByAttack(finished)
	
	if tolua.isnull(self.skeletonNode) then
		LuaLogE(self.index.."这个位置发生一个异常的攻击动作")
		return
	end
	local fightInfo= BattleManager:getInstance():getFightObjData()
	local skillInfo=SkillConfiger.getSkillById(fightInfo.skill)
	local eventCount=0
	if not tolua.isnull(self.skeletonNode) then
		eventCount=self.skeletonNode:getEventCount()-1
	end
	local activeSkill=SkillConfiger.getActiveBySkillId(skillInfo.activeSkill[1])
	local function beginAttack()
		if fightInfo.isDoubleHit then
			self.skillTip:setVisible(false)
			self.buffBase:showBuffTips(1,"lianji")

		else
			self.skillName:setText(skillInfo.skillName)
		end
		local attackCount=0
		local nextStep=function()
			attackCount=attackCount+1
			SkillManager.hitEvent(attackCount)--完成一段攻击伤害
		end

		local stackName=""
		if next(skillInfo.attackAction)~=nil then
			stackName="stack"..skillInfo.attackAction[1]
		end

		if stackName=="" then  --无动作释放技能
			self.battleState:OnNextState()
			BattleManager:schedule(function()
					nextStep()
			end,0.3,1)
	        BattleManager:schedule(function()
					finished(self.isDie)
					self.view:setSortingOrder(self.zIndex)
			end,0.5,1)	
			return
		end
		
		--BattleManager:printTime("standByAttack","attack")
		
		
		self.battleState:OnStack(stackName,skillInfo.skillName~="" and not __LJJ_BattleTest__)
		
		
		local isCheck = true
		--local eventTest=self.skeletonNode:findEvent("jump_key")
		--print(086,eventTest:getTime(),"tttttt")
		SkillManager.normalEffect(self.index,fightInfo.skill)
		self.skeletonNode:setEventListener(function(aniName,event)
				local eventName=event:getData():getName()
				print(5656,eventName,event:getTime())
				if string.find(eventName,"stack")~=nil then
					if isCheck then
						nextStep()
					end
				end
				--if eventName=="trigger_key" then
					--SkillManager.normalEffect(self.index,fightInfo.skill)
				--end
				--if eventName=="jump_key" then
					--self:setAttackPos(function()
						--end)
				--end
				--if eventName=="jump2_key" then
					--finished(self.isDie)
				--end
			end)
		self.skeletonNode:setCompleteListener(function(name)
				isCheck=false
				if name==stackName then
					if activeSkill.skillEffect and attackCount~=#activeSkill.skillEffect and #activeSkill.skillEffect~=0 then
						BattleManager:getInstance():fxCheckTips("人物特效："..attackCount.. " 配表:"..#activeSkill.skillEffect)
					end
					finished(self.isDie)
					self.view:setSortingOrder(self.zIndex)
					--BattleManager:printTime("standByAttack","Complete")
				end
		end)
	end
	beginAttack()


end


--设置出手攻击选定的位置
function HeroItem:setAttackPos(finished)

	local target=self.initPos
	local fightInfo= BattleManager:getInstance():getFightObjData()
	local beAttackers=BattleManager:getInstance():getBeActtackers()
	local skillInfo=SkillConfiger.getSkillById(fightInfo.skill)
	local skillPos=skillInfo.skillPos
	local beAttacker=beAttackers[1]

	local  function addDistance(toPos) --计算好位置之后还要加上填表的偏移
		if self.heroPos==HeroPos.player then
			target={x=toPos.x+skillInfo.distance[1],y=toPos.y-skillInfo.distance[2]}
		else
			target={x=toPos.x-skillInfo.distance[1],y=toPos.y-skillInfo.distance[2]}
		end
	end

	local function beginMoveTo()
		if skillPos==2 then --近距离贴脸第一个目标施法
			self.view:setSortingOrder(beAttacker.zIndex)--改变一下层级
			local toPos= self:getSelfLocalPos(beAttacker:getSelfScreenPos())
			addDistance(toPos)
		end
		if skillPos==1 then
			target= self.initPos--原地施法
			addDistance(target)
		end
		if skillPos==3 then
			local centerPoint=BattleModel:getMapPoint()["arrayCenter"]
			target= self:getSelfLocalPos(centerPoint:localToGlobal(Vector2.zero))--场地中间施法
			addDistance(target)
		end
		
		local arg = {}
		arg.from = self.view:getPosition()
		arg.to = Vector2(target.x,target.y)
		arg.time = 0.15
		arg.ease = EaseType.SineOut
		arg.tweenType="Battle"
		arg.onComplete = function( ... )
			if finished then
				if tolua.isnull(self.skeletonNode) then				
					LuaLogE(self.index.."这个位置发生一个错误的动作回调")
					self.view:setPosition(self.initPos.x,self.initPos.y)	
					return
				else
					finished()
				end		
			end
		end
		TweenUtil.moveTo(self.view,arg)
		
	end
	if  skillInfo.liHui~=nil and skillInfo.liHui~=""then
		BattleManager:printTime("liHui","a")
		SkillManager.lihuiEffect(self.index,skillInfo,function ()
				BattleManager:printTime("liHui","b")
				beginMoveTo()--有例会先播放再进行攻击目标站位
			end, self.fashionLihuiIndex)
	else 
		beginMoveTo()
	end
end


--英雄受击掉血表现
function HeroItem:effectAction(skillEffectData,eventTime,statusList,finished)
	
	
	if self.baseData==false then
		return
	end
	
	local hitList=skillEffectData.value  or {}   --多段伤害数组

	local shiledList=skillEffectData.shiled or {}  --护盾抵消数组

	local value  =hitList[eventTime]
	local shield =shiledList[eventTime]
	if shield==nil then shield=0 end
	self.haveDed=false
	if value~=nil then
		if self.baseData.myhurt then
			self.baseData.myhurt=self.baseData.myhurt-(value-shield)
			if self.baseData.myhurt<0 then
				self.baseData.myhurt=0
			end
			if self.baseData.myhurt>self.baseData.hpMax then
				--if  FightManager.frontArrayType() ~= GameDef.BattleArrayType.BloodAbyss  then
					self.baseData.myhurt=self.baseData.hpMax
				--end
			end
		end
		value=value-shield
	end
	local lastHit=eventTime==#hitList or #hitList==0 and eventTime==1
	--printTable(086,statusList)
	for k, func in pairs(statusList) do
		self["call"..func](self,value,eventTime,function ()
				if self.baseData==false then
					return 
				end
				finished(lastHit)
				if self.isDie==true then
					return
				end
			end,lastHit)--根据服务器下发状态执行受击者的动效
	end
	self.barController:setShiedBar(shield,eventTime)
end


function HeroItem:showAllHurtTips(allHurt)
	self.barController:createAllHurt(allHurt)
end

--正常状态 如果没有伤害值可能是加buff状态否值会进入闪避状态
function HeroItem:callNormal(value,eventTime,finished,lastHit,notSetBar)
	if value==nil or value==0 or not self.barController or not self.baseData then
		finished()
		return
	end
	self.baseData.myhurt = self.baseData.myhurt or 0
	local lefthp=self.baseData.hpMax-self.baseData.myhurt
	local hpTip=false
	if value<0 then
		hpTip=self.barController:createHpType(1,finished)
		self.battleState:OnHit()
	else
		hpTip=self.barController:createHpType(3,finished)
	end
	hpTip:getChildAutoType("add_value"):setText(value)
	self:beHitAnimation(hpTip,lefthp,finished,lastHit,notSetBar)
end

--反伤攻击后被反伤
function HeroItem:callHurtBack(value,eventTime,finished,lastHit,notSetBar)
	self.baseData.myhurt = self.baseData.myhurt or 0
	local lefthp=self.baseData.hpMax-self.baseData.myhurt
	if  value==nil then
		finished()
		return
	end

	local hpTip=false
	local valueText="反伤"..value
	hpTip=self.barController:createHpType(1,finished)
	hpTip:setVisible(true)
	hpTip:getChildAutoType("add_value"):setText(valueText)
	self:beHitAnimation(hpTip,lefthp,finished,false,true)
end


--暴击
function HeroItem:callCrit(value,eventTime,finished,lastHit)
	self.baseData.myhurt = self.baseData.myhurt or 0
	local lefthp=self.baseData.hpMax-self.baseData.myhurt
	if value==nil then
		return
	end
	local hpTip=false
	local valueText="暴击"..value
	if value<0 then
		hpTip=self.barController:createHpType(2,finished)
		--self.skeletonNode:setAnimation(0, "hit", false);
		hpTip:getChildAutoType("crit"):setTitle(valueText)
		self.battleState:OnHit()
	else
		hpTip=self.barController:createHpType(5,finished)
		hpTip:getChildAutoType("add_value"):setText(valueText)
	end

	hpTip:setVisible(true)
	--hpTip:setTitle(valueText)
	self:beHitAnimation(hpTip,lefthp,finished,lastHit)
end

--攻击闪避
function HeroItem:callMiss(value,eventTime,finished)
	--print(4,"攻击丢失")
	self:attackEvasion(function ()
			finished()
		end)

end

--神佑
function HeroItem:callGodBless(value,eventTime,finished,lastHit)
	if lastHit then
		self.buffBase:showBuffTips(eventTime,"sy")
	end
end





--攻击格挡
function HeroItem:callHurtBlock(value,eventTime,finished,lastHit,notSetBar)
	--print(4,"攻击格挡")
	if value==0 then
		self.buffBase:showBuffTips(eventTime,"block")
		self.scheduleID=BattleManager:schedule(function()
				finished()
		end,0.5,1)
	else
		self:callNormal(value,eventTime,finished,lastHit,notSetBar)
	end
end


--死亡
function HeroItem:callDead(value)
	print(5656,"callDead")
	self.haveDed=true
end


function HeroItem:callSummon(value,eventTime,finished)
	print(5656,"callSummon")
	if finished then
		finished()
	end
	--self.haveDed=true
end


--复活
function HeroItem:callRevived(value)
	print(086,"callRevived")
	if value==nil then
		value=0
	end
	SkillManager.creatorRevivedFx(self.index)
	self.battleState:OnRevived()
	SkillManager.removeDieFX(self.index)
	SkillManager.setBuffVisible(self.index,true,false)
	self:updateBuffIcon()
	self.isDie=false
	self.haveDed=false
	self.barGroup:setVisible((not self.hideBarGroup) and true)
	self.baseData.myhurt=self.baseData.hpMax-value
	self.baseData.hp=value
end



--增加buff
function HeroItem:callOnlyBuff(value,eventTime,finished)
	print(086,"callOnlyBuff",self.index)
	if finished then
		finished()
	end

end

--攻击后被动给任何人增加buff状态很骚这个设计？
function HeroItem:callOnlyBuffEx(value,eventTime,finished,lastHit)
	--if lastHit then
		----print(0866,"callOnlyBuffEx")
	--end
	if finished then
		finished()
	end

end

--传递
function HeroItem:callPassed(value,eventTime,finished)
	print(521000,"callPassed传递",self.index)
	if finished then
		finished()
	end

end

--溅射
function HeroItem:callSputtering(value,eventTime,finished)
	print(0933,"callSputtering溅射",self.index)
	if finished then
		finished()
	end

end

--抵挡死亡
function HeroItem:callResistDead(value,eventTime,finished,lastHit)
	if lastHit then
		self.buffBase:showBuffTips(eventTime,"lx")
	end
	--if finished then
		----finished()
	--end

end

--怒气抵挡伤害
function HeroItem:callRageResistHurt(value,eventTime,finished)
	if finished then
		print(5656,"callRageResistHurt")
		self.buffBase:showBuffTips(eventTime,"mianyi")
		finished()
	end
end


--轮回转生
function HeroItem:callReincarnation(value,eventTime,finished,lastHit)
	if lastHit then
		self.buffBase:showBuffTips(eventTime,"lh")
	end
	if finished then
		finished()
	end

end


--s锁血
function HeroItem:callLockHp(value,eventTime,finished)
	
	if finished then
		self.buffBase:showBuffTips(eventTime,"mianyi")
		finished()
	end
end


--吸血
function HeroItem:callSuck(value,eventTime,finished)
	local hpTip=false
	hpTip=self.barController:createHpType(3,finished)
	hpTip:setVisible(true)
	local arrayType=FightManager.frontArrayType()
	local valueText=value
	if arrayType == GameDef.BattleArrayType.NewHeroCopy and self.heroType == 2 then --血色庄园BOSS回血导致伤害回退特殊处理
		if not self.baseData.bloodSucking then self.baseData.bloodSucking = 0 end
		local realValue = value 
		if value > self.baseData.myhurt then
			realValue = self.baseData.myhurt
		end
		self.baseData.bloodSucking = self.baseData.bloodSucking + realValue
	end
	self.baseData.myhurt = self.baseData.myhurt or 0
	self.baseData.myhurt=self.baseData.myhurt-value
	if self.baseData.myhurt<0 then
		self.baseData.myhurt=0
	end
	local lefthp=self.baseData.hpMax-self.baseData.myhurt
	hpTip:getChildAutoType("add_value"):setText(valueText)
	self:beHitAnimation(hpTip,lefthp,finished)
end


--扣血动效
function HeroItem:beHitAnimation(hpTip,lefthp,finished,lastHit,notSetBar)

	if lastHit and self.haveDed==false then
		self.battleState:OnStand()
	end
	if lastHit and self.haveDed==true then
		print(086,"beHitAnimation goDie")
		self:goDie()
	end

	if notSetBar then return end
	if self.heroType==2 then
		local arrayType=FightManager.frontArrayType()
	    if arrayType == GameDef.BattleArrayType.GuildWorldBossNumOne 
		or arrayType == GameDef.BattleArrayType.GuildWorldBossNumTwo 
		or arrayType == GameDef.BattleArrayType.GuildWorldBossNumThree
		or arrayType ==GameDef.GamePlayType.GuildWorldBoss  then
			self.barController:setBossBar2(self.baseData.myhurt,self.baseData.hpMax)
		elseif arrayType == GameDef.BattleArrayType.EvilMountain or arrayType == GameDef.BattleArrayType.EvilMountainTwo then
			self.barController:setBossBar3(self.baseData.myhurt,self.baseData.hpMax)
		elseif arrayType == GameDef.BattleArrayType.BloodAbyss  then
			self.barController:setBossBar4(self.baseData.myhurt,self.baseData.hpMax)
		elseif arrayType == GameDef.BattleArrayType.HolidayBoss  then
			self.barController:setBossBar5(self.baseData.myhurt,self.baseData.hpMax)
		elseif arrayType == GameDef.BattleArrayType.NewHeroCopy then
			local realHurt = self.baseData.myhurt
			if self.baseData.bloodSucking and self.baseData.myhurt >= self.baseData.bloodSucking then
				realHurt = self.baseData.myhurt + self.baseData.bloodSucking
			end
			self.barController:setBossBar(realHurt)
		else
			self.barController:setBossBar(self.baseData.myhurt)
		end
	else
		self.barController:setHpBar(lefthp)
		self.baseData.hp=lefthp
	end
end


--受击躲避
function HeroItem:attackEvasion(func)
	self.buffBase:showBuffTips(1,"miss")
	self.scheduleID=BattleManager:schedule(function()
			func()
		end,0.5,1)
end


--远程AOE
function HeroItem:magicAttack(finished,skillType,bulletType)

	if tolua.isnull(self.skeletonNode) then
		LuaLogE(self.index.."这个位置发生一个异常的攻击动作")
		return
	end
	local fightInfos= BattleManager:getInstance():getFightObjData()
	local skill=SkillConfiger.getSkillById(fightInfos.skill)
	if fightInfos.isDoubleHit then
		self.skillTip:setVisible(false)
		self.buffBase:showBuffTips(1,"lianji")
	else
		self.skillName:setText(skill.skillName)
	end
	local stackName=""
	if next(skill.attackAction)~=nil then
		stackName="stack"..skill.attackAction[1]
	end
	--local testTime=1
	--if self.skeletonNode.getAnimationDuration then
		--testTime=self.skeletonNode:getAnimationDuration(stackName)
	--end
--	BattleManager:printTime("magicAttack","begin")

	local function beginAttack(attackCount)

		if bulletType and bulletType~="" then
			local effectData=false
			print(086,bulletType,"bulletType")
			if bulletType==2 then  --一发子弹选择一个目标
				effectData=fightInfos.skillEffectSeq[attackCount]
			end
			if  bulletType==1 then  --一发子弹对应一个伤害
			   --effectData=fightInfos.skillEffectSeq[1]
				for k, effectV in pairs(fightInfos.skillEffectSeq) do --多发子弹选择多个目标
					local skillData={skillType=skillType,skill=effectV.skill,id=effectV.id,bulletType=bulletType}
					print(5656,effectV.id,"effectData")
					SkillManager.playEffect(self.index,skillData,attackCount)
				end
			end
			if effectData then
				local skillData={skillType=skillType,skill=effectData.skill,id=effectData.id,bulletType=bulletType}
				SkillManager.playEffect(self.index,skillData,attackCount)
			end
			if attackCount==1 then
				finished()
			end
			return 
		end
		
		
		for k, effectData in pairs(fightInfos.skillEffectSeq) do --多发子弹选择多个目标
				local beAttacker=ModelManager.BattleModel:getHeroItemById(effectData.id)
				if beAttacker.isSub==true then
					beAttacker:callRevived(effectData.value)
				else
					--特殊触发的buff
					if effectData.status==GameDef.ShowEffectType.OnlyBuffEx then
						  self.scheduleID=BattleManager:schedule(function()
								SkillManager.affterSkillEffect(beAttacker,effectData)
						  end,0.3,1)
					else
					local skillData={skillType=skillType,skill=effectData.skill,id=effectData.id}
				    SkillManager.playEffect(self.index,skillData)
					end
				end
		end
		finished()
	end

	if stackName=="" then --无动作播放技能
		self.scheduleID=BattleManager:schedule(function()
				beginAttack()
				self.battleState:OnNextState()
		end,0.3,1)

	else
		self.battleState:OnStack(stackName,skill.skillName~="" and not __LJJ_BattleTest__)--有动作播放技能
		SkillManager.normalEffect(self.index,fightInfos.skill)
		local isCheck = true
		local attackCount=0
		self.skeletonNode:setEventListener(function(name)
				print(0933,stackName,"stackName")
				if  name==stackName then
					--BattleManager:printTime("magicAttack","attack")
					attackCount=attackCount+1
					beginAttack(attackCount)
				end
		end)
		self.skeletonNode:setCompleteListener(function (name)
				if name==stackName then
					--BattleManager:printTime("magicAttack","end")
					self.battleState:OnNextState()
				end
		end)
	end
end


--英雄死亡
function HeroItem:goDie (func)
	if self.skeletonNode==false then
		return
	end
	self.barGroup:setVisible(false)
	self.battleState:OnDie()
	self.scheduleID=BattleManager:schedule(function()
			self:updateBuffIcon()
			self.isDie=true
			if func then
				func()
			end
	end,1,1)
end



function HeroItem:walk()
	self.skeletonNode:setAnimation(0, "stand", true);
end


--英雄补位
function HeroItem:beConverPos (baseData,finished)
	--local co =  coroutine.running()
	SkillManager.removeDieFX(self.index)
	self:setData(baseData,0)
	self.view:setVisible(false)
	self.scheduleID=BattleManager:schedule(function()
			finished()
		end,1,1)
	--coroutine.yield()
end


--收回来的时候卡动作
function HeroItem:turnIdie (finished)
	
	if tolua.isnull(self.view) then
		return 
	end
	self.view:setSortingOrder(self.zIndex)	
	local arg = {}
	arg.from = self.view:getPosition()
	arg.to = Vector2(self.initPos.x,self.initPos.y)
	arg.time = 0.2
	arg.ease = EaseType.SineOut
	arg.tweenType="Battle"
	arg.onComplete = function( ... )
		
		if finished then
			finished()
		end
	end

	TweenUtil.moveTo(self.view,arg)

end


--每个回合刷新怒气值
function HeroItem:addRege(value)
	if self.barController then
		self.barController:setRageBar(value)
	end
end

--刷新护盾
function HeroItem:setShiedBar(value)
	printTable(5656,self.index,"刷新护盾")
	if self.barController then
		self.barController:setShiedBar(value)
	end

end



--buff造成的多段伤害,总伤害要扣去护盾值
function HeroItem:buffHurt(buffEffect,finished)
	
	local values=buffEffect.buffValue
	local shileValue=buffEffect.buffShield
	local statusList= SkillManager.bitStausType(buffEffect.status)
	
    --printTable(086,statusList,"statusList")
	if type(values)~="table" then
		values={
			[1]=values
		}
	end
	if shileValue==nil then shileValue=0 end
	if next(values)==nil or self.baseData==false or self.barController==false then
		if finished then
			finished()
		end
		return 
	end
	
	
	local hurt=0
	for k, value in pairs(values) do
		hurt=hurt+value
		for k, func in pairs(statusList) do
			local eventCount=0
			self["call"..func](self,value,k,function ()
					eventCount=eventCount+1
					if eventCount==#values then
						self.barController:setShiedBar(shileValue)
						if finished then
							finished()
							finished=false
						end
					end
			end,true,true)--根据服务器下发状态执行受击者的动效
			print(086,k,#values)
		end
	end
	--print(086,"buffHurtbuffHurt")
	if self.baseData.myhurt then
		self.baseData.myhurt=self.baseData.myhurt-(hurt-shileValue)
	end
	if self.heroType==2 then
		local arrayType=FightManager.frontArrayType()
		if arrayType == GameDef.BattleArrayType.GuildWorldBossNumOne
			or arrayType == GameDef.BattleArrayType.GuildWorldBossNumTwo
			or arrayType == GameDef.BattleArrayType.GuildWorldBossNumThree
			or arrayType ==GameDef.GamePlayType.GuildWorldBoss  then
			self.barController:setBossBar2(self.baseData.myhurt)
		elseif arrayType == GameDef.BattleArrayType.EvilMountain or arrayType == GameDef.BattleArrayType.EvilMountainTwo then
			self.barController:setBossBar3(self.baseData.myhurt)
		elseif arrayType == GameDef.BattleArrayType.BloodAbyss  then
			self.barController:setBossBar4(self.baseData.myhurt,self.baseData.hpMax)
		elseif arrayType == GameDef.BattleArrayType.NewHeroCopy then
			local realHurt = self.baseData.myhurt
			if self.baseData.bloodSucking and self.baseData.myhurt >= self.baseData.bloodSucking then
				realHurt = self.baseData.myhurt + self.baseData.bloodSucking
			end
			self.barController:setBossBar(realHurt)
		else
			self.barController:setBossBar(self.baseData.myhurt)
		end
	else
		self.baseData.hp=self.baseData.hp+(hurt-shileValue)
		self.barController:setHpBar(self.baseData.hp)
	end

end

function HeroItem:buffRevived(value,finished)
	self:callRevived(value)
	BattleManager:schedule(function()
			if finished then
				finished()
			end
		end,0.5,1)
end

function HeroItem:skillHurtBack(values,shileValue,finished)
	if type(values)~="table" then
		values={
			[1]=values
		}
	end
	if shileValue==nil then shileValue=0 end

	local hurt=0
	local eventCount=0
	for k, value in pairs(values) do
		hurt=hurt+value
		self:callHurtBack(value,k,function ()
				eventCount=eventCount+1
				if eventCount==#values then
					if self.baseData.myhurt then
						self.baseData.myhurt=self.baseData.myhurt-(hurt-shileValue)
					end
					self.barController:setShiedBar(shileValue)
				end
			end)
	end
	self.baseData.hp=self.baseData.hp+(hurt-shileValue)
	self.barController:setHpBar(self.baseData.hp)

	if self.baseData.hp<1 then
		self.scheduleID=BattleManager:schedule(function()
				print(086,"skillHurtBack goDie")
				self:goDie(function ()
						if finished then
							finished(true)
						end
					end)
			end,0.3,1)
	else
		if finished then
			finished(false)
		end
	end

end



--#buff添加信息
--.BuffAddData {
--id          1:integer           #唯一标识
--buffId      2:integer           #buffid
--round       3:integer           #回合数
--}
--buff更新处理
function HeroItem:battle_buffUpdate(_,_changeIdx)
	if _changeIdx and _changeIdx.index == self.index then
		--print(1 , "BuffUpdate : " , self.index , ServerTimeModel:getServerTimeMS())
		self:updateBuffIcon()

	end
end



function HeroItem:updateBuffIcon()

	local buffDatas={}
	--死亡后，需要清理buff
	if self.haveDed==false then
		local buffList = ModelManager.BattleModel:getBuff(self.index)
		if buffList==nil then buffList = {} end
		for k, v in pairs(buffList) do
			local buff=DynamicConfigData.t_buff[v.buffId]
			if buff and buff.showBuff==1 then
				table.insert(buffDatas,v)
			end
		end
	end
	if tolua.isnull(self.view)  then
		return
	end
	--print(086,#buffDatas.."  buffCount",self.index)
	self.buffIconList:setItemRenderer(function(index,item)
			local data=buffDatas[index+1]
			if data then
				local buff=DynamicConfigData.t_buff[data.buffId]	
				local iconPath=string.format("%s%s.png","skill/Icon/buff/",buff.buffIcon)
				--print(086,iconPath,self.index)
				item:setIcon(iconPath)
				if data.buffCount>1 then
					item:setTitle(data.buffCount)
				else
					item:setTitle("")
				end
			end
		end)

	local buffCount = #buffDatas
	if buffCount >3 then
		for i = buffCount, buffCount-3,-1 do
			buffDatas[buffCount-i+1]=clone(buffDatas[i])
		end
		buffCount = 3
	end
	self.buffIconList:setNumItems(buffCount)
	self.buffIconList:setVisible(not __LJJ_BattleTest__)
end





--播放胜利动作
function HeroItem:playWin(value)
	if  self.isDie==false and self.battleState then
		self.battleState:OnWin()
	end
end

--说话
function HeroItem:talking(str)
	if self.battleState then
		self.battleState:OnTalking()
		self.skillName:setText(str)
	end
end



function HeroItem:getBonPosition(name)
	local temp= self.skeletonNode:findBone(name)
	if temp==nil  then
		print(0,self.baseData.code,"这个英雄没有"..name.."挂点")
		return {x=2,y=133}--美术没做 默认一个挂点
	end
	--printTable(4,{x=temp:getWorldX(),y=temp:getWorldY()},"挂点坐标")
	return  {x=temp:getWorldX(),y=temp:getWorldY()}
end


--获取spine挂點世界坐标 pos 是相对于goWaro锚点的偏移
function HeroItem:getHungPos(pos)
	return self.goWrapParent:localToGlobal({x=pos.x,y=-pos.y})--self.view局部坐标转屏幕坐标
end


--获取组件本身的屏幕坐标
function HeroItem:getSelfScreenPos()
	return self.view:getParent():localToGlobal(self.view:getPosition())--self.view局部坐标转屏幕坐标
end


--屏幕坐标相对于该组件的局部坐标
function HeroItem:getSelfLocalPos(pos,parent)
	if parent==nil then
		parent=self.view:getParent()
	end
	return parent:globalToLocal(pos)
end

--重置下一场战斗
function HeroItem:resetData()	
	if tolua.isnull(self.view)then return end	
	if self.baseData then
		if self.barController then
			self.barController:clear()
		end	
		if self.battleState then
			self.battleState:OnLeave()
		end	
		self.baseData=false
	end
	if self.initPos then
		self.view:setPosition(self.initPos.x,self.initPos.y)
	end
	if self.spinePool then
		if not tolua.isnull(self.skeletonNode) then
			self.skeletonNode:setEventListener(function ()end)
			self.skeletonNode:setCompleteListener(function ()end)
			self.spinePool:returnObject(self.skeletonNode)
		end
		self.spinePool=false
	end
	SkillManager.setBuffVisible(self.index,false)
	self.barGroup:setVisible(false)
	Dispatcher.removeEventListener(EventType.battle_buffUpdate,self)
end


function  HeroItem:setHideBarGroup(isHide)
	self.hideBarGroup = isHide
	-- body
	if isHide then
		self.barGroup:setVisible(false)
	end
end

function HeroItem:exit()
    self:resetData()
end


function HeroItem:__onExit()
	self:resetData()
end

function HeroItem:myError(k,message)
	print(4,self.index,"這個位置报错了","属性是"..k,message)
end




return HeroItem
