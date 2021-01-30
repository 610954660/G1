---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: ljj
-- Date: 2020-10-13 20:59:10
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class BackstageFight
local FightState = class("FightState")
local ViewArrayType = require "Game.Consts.ViewArrayType"
local ArrayName = require "Game.Consts.ArrayName"
local SkillConfiger=require "Game.ConfigReaders.SkillConfiger"
function FightState:ctor(args)
    self.runTime=0
	self.allTime=0
	self.isBackGroud=false  --是否后台
	self.leftStepData=false --剩余未播放完的战报
	self._args=args
	self.battleData=args.battleData
	self.timeScale=false   
	self.openInfo=false --反面viewManage管理跳转
	self.arrayType=args.battleData.gamePlayInfo.arrayType
	self.gamePlayType=args.battleData.gamePlayInfo.gamePlayType
	
	self.stackTimes={}--本场战斗每个英雄所有攻击动作的时间
	
	self.isRecord=args.isRecord
	self.battleFunc=args.battleFunc --后台回调保存再这里
	self.haveReward=true
	if self.arrayType==GameDef.BattleArrayType.FriendPK or self.arrayType==GameDef.BattleArrayType.PveStarTemple then
		self.haveReward=false  --这两个玩法不弹结算
	end
	
	self:initData()
	
	

	
end

function FightState:getArgsInfo()
    return self._args
end



function FightState:initData()
	self.openInfo=ViewArrayType[self.arrayType]
	self:setTime()
end

--后台战斗往后执行一秒
function FightState:pushTime()
	
	--print(086,BattleModel:getSpeedIndex(),"BattleModel:getSpeedIndex()")
	if BattleModel:getSpeedIndex()<=BattleModel.battleSpeed[1] then
		self.runTime=self.runTime+BattleModel.battleSpeed[3]
	else
		self.runTime=self.runTime+1
	end
	local gameName=ArrayName[self.arrayType] or "未知玩法"
   -- print(5656,self.runTime,self.allTime,self.isBackGroud,gameName.."正在后台运行")
	if self.runTime>=self.allTime and self.isBackGroud then
		 Dispatcher.dispatchEvent(EventType.battle_Next,{arrayType=self.arrayType,isBackGroud=self.isBackGroud})
		 self.runTime=0
	end
end


function FightState:setTime()
	print(086,self.allTime,"setTime")
	self.allTime=0
	--读取战报属性
	self.allTime =self.allTime+1 --加载英雄
	self.allTime =self.allTime+2 --开始游戏的两秒
	
	local heroCodes={}
	for k, battleObj in pairs(self.battleData.battleObjSeq) do
		heroCodes[battleObj.id]=battleObj.code
	end

	
	
	for i, roundData in ipairs(self.battleData.roundDataSeq) do
		

		--回合开始处理
		if roundData.addHeroData~=nil and  next(roundData.addHeroData)~=nil then
			self.allTime =self.allTime+1--增加英雄
			--roundTime=roundTime+1
		end
		--所有玩家一个回合出手信息
		for k, v in ipairs(roundData.dataSeq) do
			for k, fightData in ipairs(v.fightObjDataSeq) do
				local skill=SkillConfiger.getSkillById(fightData.skill)
				local roundTime=0
				local haveStackTime=false
				if skill then
					if  skill.liHui~=nil and skill.liHui~=""then
						roundTime=roundTime+2
					end
					if next(skill.attackAction)~=nil then
						if skill.hitType==1 then
							roundTime=roundTime+0.4 --近战跑位的时间
						end
						local stackName="stack"..skill.attackAction[1]
						local heroCode=heroCodes[fightData.id] or 0
						local stackT=0
						if self.stackTimes[heroCode] then
						    stackT=self.stackTimes[heroCode][stackName] or 1
							roundTime=roundTime+stackT
							haveStackTime=true
						else
							if skill.hitType==1 then
								local moveTime=0.2
								roundTime=roundTime+moveTime*2
								roundTime=roundTime+SkillManager.getActionTime(fightData)
							else
								roundTime=roundTime+1.4
							end
						end

					end						
					if skill.isShade==1 then
						roundTime=roundTime+0.3
					end
					
				end
				if not haveStackTime then
					local skillTime=SkillManager.getSkillMaxTime(fightData)
					roundTime=roundTime+skillTime
				end
				self.allTime=self.allTime+roundTime	
				--print(356,fightData.id,"技能用时"..skillTime)
				--print(356,fightData.id,"计算用时"..roundTime)
			end
			if v.replaceDataSeq and next(v.replaceDataSeq)~=nil then
				self.allTime=self.allTime+1
				--roundTime=roundTime+1
			end
		end	
		--回合结束增加buff 怒气增加
		if roundData.heroDataSeq then
			self.allTime=self.allTime+0.4 
			--roundTime=roundTime+0.4
		end

		--替补上场
		if roundData.replaceDataSeq and next(roundData.replaceDataSeq)~=nil then
			self.allTime=self.allTime+1 ---加上替补换场时间
			--roundTime=roundTime+1
		end
		--print(356,"回合"..i.."用时",roundTime)
	end
	
	self.allTime=self.allTime+2 ---加上胜利动画时间
	print(086,self.allTime,"setTime later")
end



function FightState:setHeroStackTimes(stackTimes)
	self.stackTimes=stackTimes
	self:setTime()
end


--获取后台剩余战报数据
function FightState:getStepData()
	self.isBackGroud=false
	local numCount=0
	local battleDataObj={}
	battleDataObj.battleObjSeq={}

	local heroLists={}
	for k, battleObj in pairs(self.battleData.battleObjSeq) do
		heroLists[battleObj.id]=clone(battleObj)
	end

	local stepTime=0

	battleDataObj.roundDataSeq={}
	battleDataObj.currentIndex=1
	--读取战报属性
	for i, roundData in ipairs(self.battleData.roundDataSeq) do

		local roundDataObj={}
		roundDataObj.dataSeq={}

		--local roundTime=0
		numCount=numCount+1
		local roundIndex=numCount

		--回合开始处理
		roundDataObj.roundStartSeq=roundData.roundStartSeq
		if roundData.addHeroData~=nil and  next(roundData.addHeroData)~=nil then
			stepTime=stepTime+0.5
		end

		if roundData.playFilm then
			local function playFilmFunc()
				self:playFilm(roundData.playFilm)
			end
		end
		local skillData={}
		--所有玩家一个回合出手信息
		for k, v in ipairs(roundData.dataSeq) do
			v.fightObjDataSeq["numCount"]=numCount
			local dataSeq={}
			dataSeq.replaceDataSeq={}
			dataSeq.fightObjDataSeq={}
			for k, fightData in ipairs(v.fightObjDataSeq) do	
				local skill=SkillConfiger.getSkillById(fightData.skill)
				if skill then
					if skill.hitType==1 then
						local moveTime=0.2
						stepTime=stepTime+moveTime*2
						stepTime=stepTime+SkillManager.getActionTime(fightData)
					
					else
						stepTime=stepTime+1.4
					end
					if skill.isShade==1 then
						stepTime=stepTime+0.3
					end
				end
				stepTime=stepTime+SkillManager.getSkillMaxTime(fightData)
				if self:getRunTrace(stepTime)then
					table.insert(dataSeq.fightObjDataSeq,fightData)
				else
					self:getEffectDatas(fightData.skillEffectSeq,heroLists)
					battleDataObj.currentIndex=numCount
				end

			end
			
			if self:getRunTrace(stepTime) then
				dataSeq.replaceDataSeq=v.replaceDataSeq
				table.insert(roundDataObj.dataSeq,dataSeq)
			else
				self:exchangeHero(v.replaceDataSeq,heroLists)
				stepTime=stepTime+0.5
				battleDataObj.currentIndex=numCount
			end
		end
		if self:getRunTrace(stepTime) then
			--回合结束数据
			roundDataObj.heroDataSeq=roundData.heroDataSeq

			roundDataObj.replaceDataSeq=roundData.replaceDataSeq
		else
			self:exchangeHero(roundData.replaceDataSeq,heroLists)
			stepTime=stepTime+0.5
			battleDataObj.currentIndex=numCount
		end
		table.insert(battleDataObj.roundDataSeq,roundDataObj)
	end
	

	
	for k, battleObj in pairs(heroLists) do
		table.insert(battleDataObj.battleObjSeq,battleObj)
	end
	battleDataObj.result=self.battleData.result
	battleDataObj.mapId=self.battleData.mapId
	battleDataObj.gamePlayInfo={}
	battleDataObj.gamePlayInfo.arrayType=self.battleData.gamePlayInfo.arrayType
	ModelManager.BattleModel.roundNum=battleDataObj.currentIndex
	return battleDataObj

end


function FightState:exchangeHero(replaceDataSeq,heroLists)

	if replaceDataSeq==nil or next(replaceDataSeq)==nil then
		return
	end
	
	for k, fightObjReplaceData in ipairs(replaceDataSeq) do
		printTable(086,fightObjReplaceData)
		local subtion={}

		local dataTemp=heroLists[fightObjReplaceData.replaceId]--替补上场的id
		printTable(086,dataTemp,"dataTemp")
		for k, v in pairs(dataTemp) do
			subtion[k]=v
		end
		local target={}
		local dataTemp2=heroLists[fightObjReplaceData.id]--场上的id 
		if dataTemp2 then
			for k, v in pairs(dataTemp2) do
				target[k]=v
			end
		else
			--替换位置没有数据保存原有数据
			target=subtion
		end
		heroLists[fightObjReplaceData.replaceId]=target
		heroLists[fightObjReplaceData.id]=subtion
		target.id=fightObjReplaceData.replaceId
		subtion.id=fightObjReplaceData.id
	end
	printTable(086,heroLists)
end


function FightState:getEffectDatas(skillEffectSeq,heroLists)
	local datas={}
	for k, effectData in pairs(skillEffectSeq) do
		local allHurt=self:addValues(effectData.value)
		heroLists[effectData.id].hp=heroLists[effectData.id].hp+allHurt
		if heroLists[effectData.id].hp<0 then
			heroLists[effectData.id].hp=0
		end
		local buffEffect=effectData.buffEffect
		if buffEffect then
			local buffHurt=self:addValues(buffEffect.buffValue)
			heroLists[buffEffect.id].hp=heroLists[buffEffect.id].hp+buffHurt
			if heroLists[buffEffect.id].hp<0 then
				heroLists[buffEffect.id].hp=0
			end
			if buffEffect.id ==111 then
			end
		end
	end
end

function FightState:addValues(list)
	local value=0
	if list==nil or next(list)==nil then
		return value
	end
	for k, v in pairs(list) do
		value=value+v
	end
	return value
end


function FightState:getRunTrace(stepTime)
	return stepTime>self.runTime
end

--将战斗隐藏至后台
function FightState:hideToBack()
    self.isBackGroud=true
end

--多线程战斗开始
function FightState:onBegin()
   if self.battleFunc then
		self.battleFunc("begin")
   end
end

--多线程战斗执行下一步
function FightState:onNext(args)
	if EndlessTrialModel:judgType(self.arrayType)  or  VoidlandModel:isVoidlandMode(self.arrayType)  then --无尽模式打赢的情况下直接下一关
		if self.battleFunc then
			self.battleFunc("next")
		else
			Dispatcher.dispatchEvent(EventType.battle_end,args)
		end
	elseif HigherPvPModel:judgType(self.arrayType)then
		if self.battleFunc then
			if (args and args.onClickSkip) then
				-- self.battleFunc("end")
				Dispatcher.dispatchEvent(EventType.battle_end,args)--非无尽 或者无尽打输的情况下也直接结束
			else
				self.battleFunc("next")
			end
		else
			Dispatcher.dispatchEvent(EventType.battle_end,args)
		end
	elseif CrossTeamPVPModel:isCrossTeamPvpType(self.arrayType) then -- 组队竞技
		if self.battleFunc then
			if (args and args.onClickSkip) then
				-- self.battleFunc("end")
				Dispatcher.dispatchEvent(EventType.battle_end,args)--非无尽 或者无尽打输的情况下也直接结束
			else
				self.battleFunc("next")
			end
		else
			Dispatcher.dispatchEvent(EventType.battle_end,args)
		end
	elseif StrideServerModel:isCrossTeamPvpType(self.arrayType) then -- 巅峰竞技
		if self.battleFunc then
			if (args and args.onClickSkip) then
				-- self.battleFunc("end")
				Dispatcher.dispatchEvent(EventType.battle_end,args)--非无尽 或者无尽打输的情况下也直接结束
			else
				self.battleFunc("next")
			end
		else
			Dispatcher.dispatchEvent(EventType.battle_end,args)
		end
	elseif CrossPVPModel:isCrossPVPType(self.arrayType)then
		if self.battleFunc then
			if (args and args.onClickSkip) then
				Dispatcher.dispatchEvent(EventType.battle_end,args)--非无尽 或者无尽打输的情况下也直接结束
			else
				self.battleFunc("next",args)
			end
		else
			Dispatcher.dispatchEvent(EventType.battle_end,args)
		end
	elseif CrossArenaPVPModel:isCrossPVPType(self.arrayType)then
		if self.battleFunc then--跳过一场
			self.battleFunc("next",args)
		else
			Dispatcher.dispatchEvent(EventType.battle_end,args)
		end
	elseif ExtraordinarylevelPvPModel:isCrossPVPType(self.arrayType)then
		if self.battleFunc then--跳过一场
			self.battleFunc("next",args)
		else
			Dispatcher.dispatchEvent(EventType.battle_end,args)
		end
	elseif self.arrayType == GameDef.BattleArrayType.GodMarket then
		if self.battleFunc then--跳过一场
			self.battleFunc("next",args)
		else
			Dispatcher.dispatchEvent(EventType.battle_end,args)
		end
	else
		Dispatcher.dispatchEvent(EventType.battle_end,args)--非无尽 或者无尽打输的情况下也直接结束
	end
end

--多线程战斗执行结束
function FightState:onEnd(args)
	
	local function rewardFunc()  --队列一个个弹出结算界面

    	local function goFunc()
			if self.haveReward then  --判断这个玩法是否需要弹结算
				ModelManager.RewardModel:setArrayType(self.arrayType,self.gamePlayType, self.battleData)
			end
			if self.battleFunc then
				self.battleFunc("end")
			end
			if self.haveReward then			
				Dispatcher.dispatchEvent(EventType.show_gameReward,{gamePlayType=self.gamePlayType})
			end
		end
		
		
		local battleData=self.battleData
		if battleData.gameEnd then --战斗全部结束之后又要插播剧情
			ViewManager.open("PushMapFilmView",{_rootDepth = LayerDepth.WindowUI,step =battleData.gameEnd.playFilm ,endfunc=function()
						goFunc()
			  end})
			if self.battleFunc then
				self.battleFunc("fightEnd")
			end
			battleData.gameEnd = false
		else
			goFunc()
		end
	end
	
	if  not self._args.isRecord or self._args.editorFight then 
		RewardModel:pushRewardQues(rewardFunc)--奖励放入队列中弹出
	end

	if not self.isBackGroud then
		cc.TextureCache:getInstance():setSpineUseAsyncType(0)
		BattleManager:getInstance():cleansup(true)--清理战斗数据
		ViewManager.close("BattleBeginView")
		ModelManager.BattleModel:changeSpeedIndex(1,true)--恢复游戏速度
	end
end


--多线程无尽等连续战斗将下一场战斗重置
function FightState:resetData(battleData)
	if self.arrayType==GameDef.BattleArrayType.Chapters then --推图有假战斗走配置，接到服务端真战斗数据也不刷新
		--self.battleData.battleObjSeq=battleData.battleObjSeq
	    return 
	end	
	self.battleData=battleData
	self.runTime=0
	self.allTime=0
	self:setTime()
	local gameName=ArrayName[self.arrayType] or "未知玩法"
	print(086,gameName.."正在切换了下一场战斗")
	if not self.isBackGroud then --这站战斗不在后台的话直接开始一场新的战斗
		BattleManager:getInstance():cleansup(false)
		Dispatcher.dispatchEvent(EventType.battle_setData,{playData=clone(self.battleData)})
	end
end


return FightState