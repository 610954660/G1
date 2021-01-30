---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-03-20 15:21:05
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class BattleManager
local SkillConfiger=require "Game.ConfigReaders.SkillConfiger"
local BattleManager = class("BattleManager")
local CameraController=require "Game.Modules.Battle.Effect.CameraController"
--local FsmMachine= require "Game.Modules.Battle.Fsm.FsmMachine"

local instance=false


local fightData={}
--local maxHurt=0




--设置英雄数据
function BattleManager:ctor()
	
	self.eventCount=1 --每个回合出手有效的伤害总个数包括连击
	self.skillEffectList=false
	self.allStep=false
	self.isFinished=false
	self.fightObjData=false
	self.attacker=false
	self.fightID=false
	self.fightIndex=1     --连击等出手的次数
	self.fightTime=0
	self.moveStar=false
	self.moveTime=0
	self.fightStar=false
	self.acttakTime=0
	self.acttakStar=false
	self.waitQues={}
	self.tweenId=false
	self.canSchedule=true
	self.scheduleList={}
	self.beAttackers={}
	self.isBackFight=false--战斗是否后台
	
	self.perAllHurt=0
	
	
end


function BattleManager:getInstance()
	return instance
end


function BattleManager:setFightInfo(data)
	fightData=data
end


function BattleManager:getFightInfo()
	return fightData
end

--或者当前出手玩家id
function BattleManager:setFightID(id)
	self.fightID=id
end

function BattleManager:getFightID()
	return self.fightID
end



--获取技能施法者的信息判断是否带皮肤
function BattleManager:acttakerBaseData()
    return self.attacker.baseData
end




function BattleManager:addWaitQues(name,autoFinished)
	local function f()
		self:waitFinished(name)
	end
	local waitData={
		name=name,
		callBack=f,
		endTime=0
	}
	self.waitQues[name]=waitData
	return  self.waitQues[name]
end

function BattleManager:addWaitSecond(name)

	Scheduler.schedule(function()
         self:waitFinished(name)
	end,0.5,1)
	
	return  self.waitQues[name]
	
end

function BattleManager:getWaitQues()
	 return self.waitQues
end


function BattleManager:waitFinished(name)
	print(523,name,"等待的一条完成了")
	self.waitQues[name]=nil
end


function BattleManager:getFightObjData()
	return self.fightObjData
end

function BattleManager:getBeActtackers()
	return self.beAttackers
end
function BattleManager:getAllHurt()
	return self.perAllHurt
end


--#战斗信息
--.FightData {
	--fightObjDataSeq    1:*FightObjData    #同时播放的技能，如果有两个则是合击
--}
function BattleManager:checkFightData()

	local stepCount=0
	self.allStep=#fightData 
	self.fightIndex=1
	self.waitQues={}
	self:moveFightData(self.fightIndex)
	
end


function BattleManager:moveFightData(index)
	local allStep=#fightData
	local fightObjData=fightData[index]
	if fightObjData==nil then
		return 
	end
	self.fightTime=0
	self.acttakTime=0
	self.acttakStar=false
	self.fightStar=false
	self.moveStar=false
	self.moveTime=0
	self.fightObjData=fightObjData
	self:setEventCount(index)
	self:beginFight(index==allStep)
end

--#战斗角色每次出手信息
--.FightObjData {
--id              1:integer               #战斗位置ID
--skill           2:integer               #使用技能
--buff            3:*integer              #生效的buff，技能施放前
--removeBuffs     4:*integer              #删除的buff，技能施放前
--skillEffectSeq  5:*SkillEffectData      #技能效果
--skillValueSeq   6:*SkillValue           #角色受影响数据
--buffEx          7:*integer              #生效的buff, 技能施放后
--removeBuffExs   8:*integer              #删除的buff, 技能施放后
--buffShield      9:integer               #护盾值
--rage            10:integer              #怒气值
--}

function BattleManager:beginFight(lastStep)

	local fightObjData= self.fightObjData
	--printTable(086,fightObjData,"操作信息")
	self.beAttackers={}
	self.isFinished=lastStep
	
	local attacker=ModelManager.BattleModel:getHeroItemById(fightObjData.id)
	self:setFightID(fightObjData.id)
	if attacker then
		self.attacker=attacker
	end
	for k, v in pairs(fightObjData.skillEffectSeq) do
		local beAttacker=ModelManager.BattleModel:getHeroItemById(v.id)
		self.beAttackers[k]=beAttacker
	end
	local skill=SkillConfiger.getSkillById(fightObjData.skill)
	if not  skill then
		ModelManager.BattleModel:playBattleInQue("配表中没有这个技能")
		return
	end
	--print(356,"beginFight",fightObjData.id,TimeLib.formatTime(ServerTimeModel:getTodayLastSeconds()))
	--self:printTime("beginFight",fightObjData.id)
	
	if fightObjData.rage ~= nil then
		if attacker.index==122 then
			print(086,fightObjData.rage,"fightObjData.rage")
		end
		attacker:addRege(fightObjData.rage)
	end
	
	--准备出手
	local function goFight ()

		if fightObjData.buffEffect then
			for k, buffEffectData in pairs(fightObjData.buffEffect) do
				local otherEffecter=ModelManager.BattleModel:getHeroItemById(buffEffectData.id)
				SkillManager.buffEffectData(otherEffecter,buffEffectData)--#技能释放前buff效果
			end
		end
		if next(self.beAttackers)==nil then
			LuaLogE("找不到攻击目标，服务器下发数据不正常了！")
			self:affterSkillEffect(attacker,fightObjData)
			ModelManager.BattleModel:playBattleInQue("找不到攻击目标，服务器下发数据不正常了！")
			return
		end
		if self:checkAttacker(attacker)==false then
			ModelManager.BattleModel:playBattleInQue()
			return
		end
		--设置施法位置再进行施法动作
		if skill.isShade==1 then
			CameraController.blankScreen()
		end
		CameraController.hideHeroByScreenType(attacker,self.beAttackers,skill.screenType)
		local function doAttack()
			self.acttakStar=true
			if skill.hitType==1 then  --人物自身hit事件
				attacker:standByAttack(function ()
						self.fightStar=self.acttakStar
						self:affterSkillEffect(attacker,fightObjData,skill.screenType)
					end)
			end
			--self:printTime("doAttack",fightObjData.id)
			if skill.hitType>1 and skill.hitType<5 then --受击特效hit事件
				attacker:magicAttack(function ()
						self.fightStar=self.acttakStar
						local delayTime =SkillManager.getSkillMaxTime()
						local waitData=self:addWaitQues("delayTime",delayTime,"等待..")
						--self:printTime("magicAttack",fightObjData.id)
						self:schedule(function ()
								waitData.callBack()
								self:affterSkillEffect(attacker,fightObjData,skill.screenType)
							end,delayTime,1)
					end,skill.hitType,skill.bulletType)
			end
			self:setSecreenEffect(fightObjData.skill,attacker,self.beAttackers)
		end
		self.moveStar=true	
		attacker:setAttackPos(function ()
				self.moveStar=false
				self.moveTime=0
				doAttack()
		end)
	
	end
	
	
	--角色出手前需要说话
	if fightObjData.talking then
        self:talking(fightObjData.talking,function ()
			goFight()
		end)
	else
		goFight()
	end
	
	
end

--设置镜头
function BattleManager:setSecreenEffect(skillID,attacker,beAttackers)
	--移动镜头
	local skillInfo=SkillConfiger.getSkillById(skillID)
	local stackId=skillInfo.attackAction[1]
	local modelData=DynamicConfigData.t_Camera[attacker.model]
	local cameraData=false
	if modelData then
		cameraData=modelData[stackId]
	end
	if cameraData then
		local index=0
		local function moveCamera()
			local carmeraId=0
			if table.nums(cameraData.camera)>0 and next(cameraData.camera,index)~=nil then
				index,carmeraId=next(cameraData.camera,index)
				CameraController.runCameraId(carmeraId,attacker,beAttackers,function ()
						if self.canSchedule then
							moveCamera()
						end
					end)
			else
				CameraController.runActions(function ()
						printTable(0232,"finished",CameraController.getScreenView():displayObject():getPosition())
				end)		
			end
		end
		local index2=0
		local function shakeCamera()
			local shockId=0
			--printTable(086,cameraData.shock,table.nums(cameraData.shock),"cameraData.shock")
			if table.nums(cameraData.shock)>0 and next(cameraData.shock,index2)~=nil then
				index2,shockId=next(cameraData.shock,index2)
				CameraController.shakingView(shockId,function ()
						if self.canSchedule then
							shakeCamera()
						end
					end)
			end
		end
		shakeCamera()
		moveCamera()
	end
end


--出手前可能有人物说话
function BattleManager:talking(text,finished)
	local index=0
	local talkList={}
	local talkData={}
	for k, v in pairs(text) do
		table.insert(talkData,v)
	end

	local function doTalk()
		if next(talkData,index)~=nil then
			index,talkList=next(talkData,index)
			for id, str in pairs(talkList) do
				local target=ModelManager.BattleModel:getHeroItemById(id)
				target:talking(str)
			end
			self:schedule(function()
					doTalk()
				end,3,1)		
		else
			if finished then
				finished()
			end
		end
	end	
	doTalk()
end



--检查攻击者状态是否异常
function BattleManager:checkAttacker(attacker)
	if attacker==nil or attacker.isSub==true then
		LuaLogE("不是有效的施法操作位")
		return false
	end
	if  attacker.isDie then
		LuaLogE(attacker.index.."攻击者状态异常直接跳过")
		
		return false
	end
	return true
end




--处理一些额外数据
function BattleManager:setEventCount(step)
	self.eventCount=0
	self.perAllHurt=0
	for k, v in pairs(fightData[step].skillEffectSeq) do
		if v.value==nil then
			self.eventCount=self.eventCount+1
			v.value={}--闪避服务会传空自己补一个吧，以免影响后面逻辑判断
		else
			self.eventCount=self.eventCount+#v.value
			for k, v in pairs(v.value) do
				if v<0 then
					self.perAllHurt=self.perAllHurt+v	
				end
	
			end
		end
	end
end


--角色完成所有伤害后的结算
function BattleManager:affterSkillEffect(attacker,fightObjData,screenType)

	SkillManager.skillFeedBack(fightObjData)--反伤最后结算	
	if fightObjData.buffEffectEx then
		for k, buffEffectData in pairs(fightObjData.buffEffectEx) do
			local otherEffecter=ModelManager.BattleModel:getHeroItemById(buffEffectData.id)
			SkillManager.buffEffectData(otherEffecter,buffEffectData)--#技能释放后buff效果
		end	
	end

	if screenType and screenType>0 then
		for k, v in pairs(BattleModel:getLifeHero()) do
			v.view:setVisible(true)
		end
	end
	if attacker and self.isFinished and not attacker.spelCaster then
		attacker:turnIdie(function ()
				if self.canSchedule then
					attacker.battleState:OnNextState()
				end
		end)
	end
	--self:printTime("affterSkillEffect",fightObjData.id)
	local waitData=self:addWaitQues("blankMask",self.index,"亮屏")
	CameraController.lightScreen(function ()
			if waitData then
				--self:printTime("end",fightObjData.id)
				waitData.callBack()
			end
		end)
	SkillManager.showAllHurt()
	

end



--检查本轮出手是否完成
function BattleManager:checkMoveNext()
	
	print(356,self.attacker.index,"出手用时"..self.acttakTime)
	self.fightTime=0
	self.fightStar=false
	self.acttakTime=0
	self.acttakStar=false
    if self.fightIndex== self.allStep then
		if self.attacker and not self.attacker.spelCaster then
		   self.attacker.battleState:OnAllStateEnd()
		end

		ModelManager.BattleModel:playBattleInQue()
	else
		self.fightIndex=self.fightIndex+1
		self:moveFightData(self.fightIndex)
	end
end

----每回合结束	
function BattleManager:roundEnd()
	 	BattleModel:roundEnd()
end


--玩家提前结束战斗，在这里清下数据 clenEffect 是否清除缓存特效
function BattleManager:cleansup(clearEffect)
	self:unscheduleAll()
	TweenUtil.clearAllTween("Battle")
	if BattleModel then
		BattleModel:clearQuese();
	end
	self.fightTime=0
	self.acttakTime=0
	self.acttakStar=false
	self.fightStar=false
	BattleModel.roundNum=0
	--self.attacker=false
	CameraController.lightScreen()
	__LJJ_BattleTest__=false
	SkillManager.clear(true)
	if clearEffect  and BattleModel then
		BattleModel:endGame()
	else
		CameraController.resetScreenView()--如果镜头在动跳过的时候又是无尽要重置一下
	end
end

--播放开始动效
function BattleManager:playBeginFX(finished)
	local centerPoint=BattleModel:getMapPoint()["center"]:getPosition()
	local parent = CameraController.getScreenView()
	local skeletonNode=SpineUtil.createSpineObj(parent, centerPoint, nil, SpinePathConfiger.BeginEffect.path, SpinePathConfiger.BeginEffect.upEffect, SpinePathConfiger.BeginEffect.upEffect)
	skeletonNode:setAnimation(0,"animation",false)
	self:schedule(function()
			if finished then
				finished()
			end
			print(0866,self.canSchedule,"self.canSchedule")
			skeletonNode:removeFromParent()
	end,1.5, 1)


end


--无尽播放第几关动效
function BattleManager:playBeginFX2(finished)
	SkillManager.playBeginFX2(finished)
end



function BattleManager:onUpdate(dt)
	
	
	if self.moveStar then
		self.moveTime=self.moveTime+dt
		if self.moveTime>2 then
			self.acttakStar=true
			self.moveStar=false
			self.moveTime=0
			print(096,"角色移动过程报错，自动跳到下一阶段")
		end
	end
	
	
	if self.acttakStar  then	
		self.acttakTime=self.acttakTime+dt
		if self.acttakTime>9 then
			self.acttakTime=0
			--真机填错表超时直跳过
			if CC_TARGET_PLATFORM == CC_PLATFORM_IOS or CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
				self.fightStar=false
				self.waitQues={}
				if self.attacker and  self.attacker.battleState and  not self.attacker.spelCaster then
					self.attacker:turnIdie()--角色已经出手出现异常本次攻击跳过回到原位
					self.attacker.battleState:OnAllStateEnd()
				end
				ModelManager.BattleModel:playBattleInQue()--等待回合过长真机上要直接跳过不卡住
			else
				if self.fightStar==false then
					RollTips.show("PC端卡住提示==>攻击动作没有完成事件")
					return 
				end
				--RollTips.show("卡住已经大于8秒测试环境不做跳过请检查受击特效结束时间是否过长",6)
		        for k, v in pairs(self.waitQues) do
					RollTips.show(k.."本回合出手特效大于9秒"..v.endTime,10)
				end
			end
		end
	end
	
	
	
	if self.fightStar==false then
		return
	end
	self.fightTime=self.fightTime+dt
	if self.fightTime>0.6 then
		
		if table.nums(self.waitQues)==0 then
			self:checkMoveNext()
		end
	end	

end



function BattleManager:beginGame()
	self.canSchedule=true
end

local unitIndex =1
function BattleManager:getUnitIndex()
	unitIndex = unitIndex + 1
	return unitIndex
end

--战斗统一管理的定时器
function BattleManager:schedule(listener, interval, repeatCount)
	local scheduleID=false
	local sIndex=self:getUnitIndex()
    scheduleID= Scheduler.schedule(function()
			if self.canSchedule then
				listener()
			end
			self.scheduleList[sIndex]=nil
	end,interval, repeatCount)
	self.scheduleList[sIndex]=scheduleID
	return scheduleID
end


function BattleManager:playSkillSound(soundId)
	local topView = ViewManager.getLayerTopWindow(LayerDepth.Window,{})
	if topView and  topView.window._viewName ~= "BattleBeginView" then
		return
	end
	
	if not self.isBackFight then
		return  SoundManager.playSound(soundId,false)
	end
    --ViewArrayType=
end


function BattleManager:fxCheckTips(tips,time)
	if __IS_RELEASE__ then
		return 
	end
	if CC_TARGET_PLATFORM == CC_PLATFORM_IOS or  CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
       return 
	end
	RollTips.show(tips,time)
end

function BattleManager:printTime(tag,tag2)
	print(5656,tag,tag2,os.clock())
end


--战斗统一管理的定时器
function BattleManager:unscheduleAll()
	self.canSchedule=false
	for k, v in pairs(self.scheduleList) do
		print(096,"移除",v)
		Scheduler.unschedule(v)
	end
	unitIndex=1
	self.scheduleList={}
end

	




instance = BattleManager.new()

return instance