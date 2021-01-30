---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: lijiejian
-- Date: 2020-03-20 15:22:12
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File
local SkillConfiger=require "Game.ConfigReaders.SkillConfiger"
local SkillAction=require "Game.Modules.Battle.Effect.SkillAction"
local CameraController=require "Game.Modules.Battle.Effect.CameraController"
---@class skillmanager
local SkillManager = {}
local __skillActions={}

local commonEffects={}
local boomEffects={}
local beginEffects={}

local allCount=0
local leftCount=0
local fixTime=0.03
local loadTag=false
local perLoadFunc=false
local fightDataLists={}  --根据所有出手信息缓存特效

local skillList={}  --根据所有出手信息缓存特效
local activeSkillList={}




local soundId = 0
local soundId2 = 0

local allHurt=0


--.SkillEffectData
--id              1:integer   #受影响的目标ID
--skill           2:integer   #主动技能
--status          3:integer   #0命中 1丢失  2死亡 4暴击（ShowEffectType）
--value           4:*integer  #血量
--shiled          5:*integer  #护盾值
--rage            6:*integer  #怒气值
--shiledBuffs     7:*RemoveBuff #护盾buffs
--buffEffect      8:BuffEffectData  #buff效果
--effects         9:SkillValue --又嵌套了一个层解析？牛逼了
--}
--#buff效果
--.BuffEffectData {
--buff            1:*BuffAddData  #生效的buff
--removeBuffs     2:*integer      #删除的buff
--buffValue       3:*integer      #伤害 sum(buffValue) - buffShield才是血量变化
--buffRage        4:integer       #buff怒气
--buffShield      5:integer       #buff护盾
--addShield       6:integer       #buff加护盾
--status          7:integer       #2死亡
--shiledBuffs     8:*RemoveBuff   #护盾buffs
--}



-- eventTime 表示第几段攻击
function SkillManager.hitEvent(eventTime,id,activeSkill,attackCount)

	if not BattleManager.canSchedule then
		return
	end
	--print(5656,eventTime,"eventTimeeventTime")


	local fightInfos= BattleManager:getInstance():getFightObjData()
	local damage=false

	local co =  coroutine.running()
	local haveLastHit=false

	for k, SkillEffectData in pairs(fightInfos.skillEffectSeq) do

		local function doSkillData()
			local beAttacker=ModelManager.BattleModel:getHeroItemById(SkillEffectData.id)
			if beAttacker==nil then
				return
			end
			if SkillEffectData.value==nil then
				SkillEffectData.value={}
			end
			haveLastHit=eventTime==#SkillEffectData.value or #SkillEffectData.value==0 and eventTime==1
			local value=SkillEffectData.value[eventTime]
			local statusList=  SkillManager.bitStausType(SkillEffectData.status)--每个英雄受击后的状态枚举
			if (value~=nil) then
				damage=value<0
				if value<0 then
					allHurt=allHurt+value
				end
			end
			SkillManager.beHitEffect(SkillEffectData.id,SkillEffectData.skill)
			if beAttacker.isSub==true then
				beAttacker:callRevived(SkillEffectData.value)
			else
				if eventTime==1 then
					SkillManager.rightNowEvent(beAttacker,eventTime,SkillEffectData)
				end
				if SkillEffectData==nil then
					printTable(0887,k,fightInfos.skillEffectSeq)
				end
				beAttacker:effectAction(SkillEffectData,eventTime,statusList,function (lastHit)
						SkillManager.afterHitEvent(beAttacker,eventTime,SkillEffectData)--计算扣血完成后其它效果的影响
						if SkillEffectData==nil then
							return
						end
						if lastHit then
							--print(0887,SkillEffectData,"SkillEffectData777777777")
							SkillManager.affterSkillEffect(beAttacker,SkillEffectData)
						end
					end)
			end
		end

		if  SkillEffectData.skill== activeSkill and SkillEffectData.id== id and  SkillEffectData.status~=GameDef.ShowEffectType.OnlyBuffEx then
			if (attackCount and attackCount==k)  or attackCount==nil then
				doSkillData()
			end

		else
			if id==nil then
				doSkillData()
			end
		end
	end

	if damage then
		--造成有效伤害后可以震屏
		local fightInfos= BattleManager:getInstance():getFightObjData()
		local skill=SkillConfiger.getSkillById(fightInfos.skill)
		if skill then
			CameraController.fguiShakeView(skill.isShock)
		end

	end

end



--获取一个技能从施法到完成总时间
function SkillManager.getSkillMaxTime(fightInfo)

	--print(086,"getSkillMaxTime",fightInfo)
	local fightInfos= fightInfo or BattleManager:getInstance():getFightObjData()
	local flyTime=0
	local endTime=0
	for k, effectData in pairs(fightInfos.skillEffectSeq) do
		local activeSkillId= effectData.skill
		if activeSkillId then
			local activeSkill = DynamicConfigData.t_activeSkill[activeSkillId]
			if  next(activeSkill.flyEffect)~=nil then
				local effectInfo = DynamicConfigData.t_effect[activeSkill.flyEffect[1]]--查看技能信息
				for k, effectConfig in pairs(effectInfo) do
					if effectConfig.flyTime~="" and effectConfig.flyTime>flyTime then
						flyTime=effectConfig.flyTime
					end
				end
			end
			if  next(activeSkill.boomEffect)~=nil then
				for k, effetId in pairs(activeSkill.boomEffect) do
					local effectInfo = DynamicConfigData.t_effect[effetId]--查看技能信息
					for k, effectConfig in pairs(effectInfo) do
						if effectConfig.endTime~="" and effectConfig.endTime>endTime then
							endTime=effectConfig.endTime
						end
					end
				end
			end
		end

	end
	return flyTime+endTime
end


--获取一个技能从施法到完成总时间
function SkillManager.getActionTime(fightInfo)

	local fightInfos=  fightInfo or BattleManager:getInstance():getFightObjData()
	local skillInfo=SkillConfiger.getSkillById(fightInfos.skill)
	local actionTime=0
	local commonTime=0
	if  next(skillInfo.commonEffect)~=nil then
		for k, effetId in pairs(skillInfo.commonEffect) do
			local effectInfo = DynamicConfigData.t_effect[effetId]--查看技能信息
			for k, effectConfig in pairs(effectInfo) do
				if effectConfig.endTime~="" and effectConfig.endTime>commonTime then
					commonTime=effectConfig.endTime
				end
			end
		end
	end
	return commonTime
end




--处理瞬时Buff 瞬时怒气
function SkillManager.rightNowEvent(beAttacker,eventTime,SkillEffectData)
	local buffEffect=SkillEffectData.buffEffect

	if buffEffect==nil then
		return
	end
	if buffEffect.buff~=nil and eventTime==1 then--增加buff -- and skillEffectData.buff[eventTime]~=nil  [eventTime]
		for i=#buffEffect.buff, 1,-1 do
			local buffData=buffEffect.buff[i]
			local buff=DynamicConfigData.t_buff[buffData.buffId]
			if buff then
				if buff.boneStyle==2 or buff.boneStyle==1 then--这个buff有冰冻状态 瞬时加上
					local temp={
						[1]=buffData
					}
					ModelManager.BattleModel:addBuff(beAttacker.index, temp)
					buffEffect.buff[i]=nil
				end
			end
		end
	end
end

--找到一个受击目标上的一个链接buff
function SkillManager.findLineBuff(effects,buffId)
	local targetbuff,targetID=false
	for k, skillValue in pairs(effects) do
		targetID=skillValue.id
		local otherEffecter=ModelManager.BattleModel:getHeroItemById(skillValue.id)
		if skillValue.buffEffect then
			for k, buffData in pairs(skillValue.buffEffect.buff) do
				local buff=DynamicConfigData.t_buff[buffData.buffId]
				if buffData.buffId==buffId then
					targetbuff=buff
					break;
				end
			end
		end
	end
	return targetID

end

--某些技能扣完血后可能还有别的英雄
--这里有一个奇怪逻辑： 移除Buff和技能段数有关系，添加Buff和技能段数没有关系
function SkillManager.afterHitEvent(beAttacker,eventTime,SkillEffectData)
	if beAttacker.index==112  then
		--printTable(5656,SkillEffectData.skill,eventTime,SkillEffectData.rage)
	end
	if SkillEffectData.rage~=nil and SkillEffectData.rage[eventTime]~=nil then--移除buff

		beAttacker:addRege(SkillEffectData.rage[eventTime])
	end
	if SkillEffectData.shiledBuffs~=nil and SkillEffectData.shiledBuffs[eventTime]~=nil then--移除buff
		ModelManager.BattleModel:removeBuff(beAttacker.index , SkillEffectData.shiledBuffs[eventTime].removeBuffs)
	end
	if SkillEffectData.effects then
		for k, skillValue in pairs(SkillEffectData.effects) do--溅射伤害等上buff
			local otherEffecter=ModelManager.BattleModel:getHeroItemById(skillValue.id)
			SkillManager.afterHitEvent(otherEffecter,eventTime,skillValue)
			if skillValue.value then
				local statusList=  SkillManager.bitStausType(skillValue.status)--每个英雄受击后的状态枚举
				otherEffecter:effectAction(skillValue,eventTime,statusList,function (lastHit)
					end)
			end
		end
	end
end


--.SkillValue {
--id              1:integer   #受影响的目标ID
--status          3:integer   #0命中 1丢失  2死亡 4暴击（ShowEffectType）
--value           4:*integer  #血量  value - shiled 才是血量变化
--shiled          5:*integer  #护盾值
--rage            6:*integer  #怒气值
--shiledBuffs     7:*RemoveBuff   #护盾buffs
--buffEffect      8:BuffEffectData  #buff效果
--}
--角色完成所有伤害后 有些buff是立即生效造成伤害的在这里处理
function SkillManager.affterSkillEffect(beAttacker,SkillEffectData)
	local fightInfos= BattleManager:getInstance():getFightObjData()
	--printTable(0887,SkillEffectData,"SkillEffectData")
	--if SkillEffectData==nil then
	--return
	--end
	local buffEffect=SkillEffectData.buffEffect
	SkillManager.buffEffectData(beAttacker,buffEffect)
	if SkillEffectData.effects then
		for k, skillValue in pairs(SkillEffectData.effects) do--溅射伤害等上buff
			local otherEffecter=ModelManager.BattleModel:getHeroItemById(skillValue.id)
			if skillValue.buffEffect then
				SkillManager.buffEffectData(otherEffecter,skillValue.buffEffect)
			end
		end
	end
	
	local summons=SkillEffectData.summons
	if summons then--有召唤物
		for k, objData in pairs(summons) do		
			local target=ModelManager.BattleModel:getHeroItemById(objData.id)	
			local waitData= FsmMachine:getInstance():addWaitQues(SkillEffectData.skill,objData.id,"summons")	
			target:beConverPos(objData,function ()
					if waitData then
						waitData.callBack()
					end			
			end)
		end	
	end
	
	
	
end


function SkillManager.showAllHurt()
	local atackerId=BattleManager:getInstance():getFightID()
	local attacker=ModelManager.BattleModel:getHeroItemById(atackerId)
	if attacker then
		attacker:showAllHurtTips(BattleManager:getInstance():getAllHurt())
	end
end



--#buff效果
--.BuffEffectData {
--id              0:integer   #受影响的目标ID
--buff            1:*BuffAddData  #生效的buff
--removeBuffs     2:*integer      #删除的buff
--buffValue       3:*integer      #伤害 sum(buffValue) - buffShield才是血量变化
--buffRage        4:integer       #buff怒气
--buffShield      5:integer       #buff护盾
--addShield       6:integer       #buff加护盾
--status          7:integer       #2死亡
--effectBuffs     8:*integer      #产生特效buff
--}


--buff结算的通用方法
function SkillManager.buffEffectData(beAttacker,buffEffect,hutFinished)

	if buffEffect==nil or   beAttacker==nil then
		return
	end
	if buffEffect.buff~=nil   then--增加buff -- and skillEffectData.buff[eventTime]~=nil  [eventTime]
		ModelManager.BattleModel:addBuff(beAttacker.index, buffEffect.buff)
	end
	if buffEffect.removeBuffs~=nil  then--移除buff   --    and skillEffectData.removeBuffs[eventTime]~=nil [eventTime]
		ModelManager.BattleModel:removeBuff(beAttacker.index , buffEffect.removeBuffs)
	end

	if buffEffect.buffRage~=nil then--怒气上升
		beAttacker:addRege(buffEffect.buffRage)
	end

	if buffEffect.addShield~=nil then
		beAttacker:setShiedBar(buffEffect.addShield)
	end

	if buffEffect.buffValue ~= nil then
		SkillManager.buffHurt(beAttacker.index,buffEffect,function ()
				if hutFinished then --如果buff有伤害可能要等待伤害完成
					hutFinished()
				end
		end)
	end

	if buffEffect.effectBuffs then  --有些buff会产生爆炸特效
		SkillManager.buffBoomEffect(beAttacker.index,buffEffect.effectBuffs)
	end


	if buffEffect.refreshBuff then --有些buff不移除需要刷新
		ModelManager.BattleModel:refeashBuff(beAttacker.index, buffEffect.refreshBuff)
	end
end





--释放技能后的反伤等效果
function SkillManager.skillFeedBack(fightObjData,finished)
	local isDie=false
	local attacker=ModelManager.BattleModel:getHeroItemById(fightObjData.id)
	if fightObjData.suck~=nil then
		if attacker then
			attacker:callSuck(fightObjData.suck,1,function ()
					--吸血完成
				end)
		end
	end

	--反伤并且扣护盾等
	if fightObjData.hurtBack~=nil then
		SkillManager.skillHurtBack(fightObjData.id,fightObjData.hurtBack,fightObjData.hurtBackShield,function(isDie)
				isDie=isDie
				if finished then
					finished(isDie)
				end
			end)
	end
	--反伤怒气
	if fightObjData.hurtBackRage~=nil then
		attacker:addRege(fightObjData.hurtBackRage)
	end

end



--与下发的状态进行位运算检测攻击造成了那种状态
function SkillManager.bitStausType(status)
	local have = {}
	print(521,status,"statusstatus")
	if status==nil then
		return  {"Normal"}
	end
	local notHurt=false
	local havaDie=false
	for k,v in pairs(GameDef.ShowEffectType) do
		if bit.band(status,v)~= 0 then
			if  v==GameDef.ShowEffectType.Crit or
				v==GameDef.ShowEffectType.Miss or
				v==GameDef.ShowEffectType.OnlyBuff or
				v==GameDef.ShowEffectType.HurtBlock or
				v==GameDef.ShowEffectType.RageResistHurt or 
				v==GameDef.ShowEffectType.Summon then
				notHurt=true
			end
			if v==GameDef.ShowEffectType.Normal then
				notHurt=true
			end
			if v==GameDef.ShowEffectType.Dead then
				table.insert(have,1,"Dead")--将死亡插到最高优先级
			else
				table.insert(have,k)
			end
		end
	end
	if notHurt==false then
		table.insert(have,"Normal")--如果没有暴击或者闪避，把普通伤害加进去
	end

	return have
end


--buff伤害
function SkillManager.buffHurt(id,buffEffect,finished)
	--printTable(0866,"values",id,values)
	local beAttacker=ModelManager.BattleModel:getHeroItemById(id)
	beAttacker:buffHurt(buffEffect,function ()
			if finished then
				finished()
			end
		end)
end

--技能反伤
function SkillManager.skillHurtBack(id,values,shiedValue,finished)
	local beAttacker=ModelManager.BattleModel:getHeroItemById(id)
	beAttacker:skillHurtBack(values,shiedValue,function (isDie)
			if finished then
				finished(isDie)
			end
		end)
end


--飛行特效
function SkillManager.playEffect(id,skillData,attackCount)
    print(5656,id,"SkillManager.playEffect")
	--local skillData={skillType=skillType,skill=effectData.skill,id=effectData.id,bulletType=bulletType}
	local action= __skillActions[id]
	if action  and skillData.skill then
		action:creatorFlyFx(skillData,function ()
				SkillManager.boomEffect(skillData,attackCount)
			end)
	end
end

--播放技能施法特效
function SkillManager.normalEffect(id,skillId,hitEvent,finished)
	local action= __skillActions[id]
	if action then
		local skill=SkillConfiger.getSkillById(skillId)
		if type(skill.sound2)=="number" and skill.sound2>0 then
			soundId2 =BattleManager:getInstance():playSkillSound(skill.sound2)
		end
		action:creatActionFX(skillId,hitEvent,finished)
	end
end

-- 精灵播放技能施法特效
function SkillManager.normalEffect3(id,skillId,hitEvent,finished,elfId,skinId)
	local action= __skillActions[id]
	if action then
		local skill = SkillConfiger.getElfSkillById(skillId,elfId,skinId)
		if type(skill.sound2)=="number" and skill.sound2>0 then
			soundId2 =BattleManager:getInstance():playSkillSound(skill.sound2)
		end
		action:creatElfActionFX(skillId,hitEvent,finished,elfId,skinId)
	end
end


--播放技能施法特效
function SkillManager.lihuiEffect(id,skill,finished, lihuiIndex)
	local action= __skillActions[id]
	if action then
		if type(skill.sound)=="number" and skill.sound>0 then
			soundId = BattleManager:getInstance():playSkillSound(skill.sound)
		end
		action:creatorLihuiFx(skill,finished, lihuiIndex)
	end
end


--爆炸特效
function SkillManager.boomEffect(skillData,attackCount)
	local action= __skillActions[skillData.id]
	--printTable(5656,skillData,"boomEffect")
	local hitTime=attackCount
	if action  then
		--printTable(5656,hitTime,"hitTime")
		action:creatorBoomFx(skillData.skill,function(eventTime,index)
				if skillData.bulletType==nil or skillData.bulletType=="" then
					SkillManager.hitEvent(eventTime,index,skillData.skill)--只有一个事件攻击一个目标
				end
				if skillData.bulletType==1 then

					SkillManager.hitEvent(eventTime>1 and eventTime or hitTime,index,skillData.skill)--多个事件触发多段伤害
				end
				if skillData.bulletType==2 then
					SkillManager.hitEvent(eventTime,index,skillData.skill,attackCount)--多个事件攻击多个目标
				end
			end,skillData.bulletType)
	end
end

--buff受击特效
function SkillManager.buffBoomEffect(id,buffIds)
	local action= __skillActions[id]
	if action  then
		for k, buffId in pairs(buffIds) do
			action:createBuffBoomFx(buffId)
		end
	end
end

--受击特效
function SkillManager.beHitEffect(id,skillId)
	local action= __skillActions[id]
	if action  then
		action:creatorHitFx(skillId)
	end
end


--添加一个buff特效
function SkillManager.addbuffFx(id,buffData)
	local action= __skillActions[id]
	if action then
		action:addBuffFx(buffData)
	end
end

--添加一个链接buff特效
function SkillManager.addConnectFx(id,connectFx)
	local action= __skillActions[id]
	if action then
		action:addConnectFx(connectFx)
	end
end


--移除一个buff特效
function SkillManager.removeBuffFx(id,effName,boneStyle)
	local action= __skillActions[id]
	if action then
		--print(521,"一处处有出处",buffIndex)
		action:removeBuffFx(effName,boneStyle)
	end
end


function SkillManager.setBuffVisible(id,isVisible,isDie)
	local action= __skillActions[id]
	if action then
		if isDie==nil then
			isDie=false
		end
		action:setBuffVisible(isVisible,isDie)
	end

end

--创建死亡特效
function SkillManager.creatorDieFX(id)

	local action= __skillActions[id]
	if action then
		action:creatorDieFX()
	end
end

--移除死亡特效
function SkillManager.removeDieFX(id)
	local action= __skillActions[id]
	if action then
		action:removeDieFX()
	end
end

--创建复活特效
function SkillManager.creatorRevivedFx(id)
	local action= __skillActions[id]
	if action then
		action:creatorRevivedFx()
	end
end


function SkillManager.addSkillAciton(skillData)
	local action= SkillAction.new(skillData)
	__skillActions[skillData.id]=action
end

--特效预加载
function SkillManager.preLoadSkillFxs(finished)
	loadTag=true
	allCount=#fightDataLists
	perLoadFunc=finished
	leftCount=0
end



--根据施放的技能加载所有特效资源 立绘太大不处理
function SkillManager.loadInFightData(index)
	local fightDatas=fightDataLists[index]
	if not fightDatas then
		return
	end
	--print(086,"loadInFightData",index)
	for k, fightData in pairs(fightDatas) do
		local skill = DynamicConfigData.t_skill[fightData.skill]
		if skill~=nil  then
			for k, effectID in pairs(skill.commonEffect) do
				if commonEffects[effectID]==nil then
					local fxList= SpineUtil.createEffectById(effectID,PathConfiger.getSpineRoot(),CameraController.getScreenView())--预加载图集可能还不够
					if fxList  then
						for k, infos in pairs(fxList) do
							local texiaoObj,skeletonNode=infos.goWrap,infos.spine
							texiaoObj:setVisible(false)
						end
						commonEffects[effectID]=fxList
					end
				end

			end
			--for k, SkillEffectData in pairs(fightData.skillEffectSeq) do
			--if SkillEffectData.skill and activeSkillList[SkillEffectData.skill]==nil then
			--local activeSkill = DynamicConfigData.t_activeSkill[SkillEffectData.skill]
			--for k, effectID in pairs(activeSkill.boomEffect) do
			--if commonEffects[effectID]==nil then
			--printTable(086,"加载爆炸特效",effectID)
			--local fxList= SpineUtil.createEffectById(effectID,PathConfiger.getSpineRoot())
			--commonEffects[effectID+fightData.id]=fxList
			--end
			--end
			--end
			--end
		end
	end
end




function SkillManager.addSkillData(fightData,roundIndex)
	table.insert(fightDataLists,fightData)
end

--获取施法特效
function SkillManager.getCommonEffet(effectID,parent)
	if commonEffects[effectID]==nil then
		commonEffects[effectID]=SpineUtil.createEffectById(effectID,PathConfiger.getSpineRoot(),parent)
	end
	return commonEffects[effectID]
end

--获取爆炸特效
function SkillManager.getBoomEffet(effectID,target,parent)
	if boomEffects[target]==nil then
		boomEffects[target]={}
	end
	local boomEffect=boomEffects[target]
	if boomEffect[effectID]==nil then
		boomEffect[effectID]=SpineUtil.createEffectById(effectID,PathConfiger.getSpineRoot(),parent)
	end
	return boomEffects[target][effectID]
end


function SkillManager.onUpdate(dt)
	if loadTag then
		fixTime=fixTime-dt
		if fixTime<=0 then
			leftCount=leftCount+1
			SkillManager.loadInFightData(leftCount)
			fixTime=0.1
			if leftCount==allCount then
				loadTag=false
				if perLoadFunc then
					perLoadFunc()
					perLoadFunc=false
				end
				leftCount=0
			end

		end
	end
end


--无尽播放第几关动效
function SkillManager.playBeginFX2(finished)
	local centerPoint=BattleModel:getMapPoint()["center"]:getPosition()
	local parent = CameraController.getScreenView()
	if next(beginEffects)==nil then
		beginEffects["skillObj1"]=fgui.GObject:create()
		beginEffects["skillObj2"]=fgui.GObject:create()
		parent:addChild(beginEffects["skillObj1"])
		parent:addChild(beginEffects["skillObj2"])
		beginEffects["skillObj1"]:setPosition(0,720)
		beginEffects["skillObj2"]:setPosition(0,720)
		beginEffects["gameTip"]=FGUIUtil.createObjectFromURL("Battle",'gameBegin')--开始提示
		parent:addChild(beginEffects["gameTip"])
		beginEffects["skeletonNode"]=SpineUtil.createSpineObj(beginEffects["skillObj1"], centerPoint, nil, SpinePathConfiger.BeginEffect.path, SpinePathConfiger.BeginEffect.upEffect, SpinePathConfiger.BeginEffect.upEffect)
		beginEffects["skeletonNode2"]=SpineUtil.createSpineObj(beginEffects["skillObj2"], centerPoint, nil, SpinePathConfiger.BeginEffect.path, SpinePathConfiger.BeginEffect.upEffect, SpinePathConfiger.BeginEffect.upEffect)

	end

	beginEffects["gameTip"]:setPosition(centerPoint.x+45,centerPoint.y)
	for k, v in pairs(beginEffects) do
		v:setVisible(true)
	end
	beginEffects["skeletonNode"]:setAnimation(0,"title_up",false)
	beginEffects["skeletonNode2"]:setAnimation(0,"title_down",false)

	local arrayType=FightManager.frontArrayType()--BattleModel:getRunArrayType()
	local str = "";
	if  HigherPvPModel:isHigherPvpType(arrayType) then --跨服竞技场
		str = string.format(Desc.CrossPVPDesc3, HigherPvPModel.recordIdIdx)
	elseif CrossPVPModel:getArrayByType(arrayType) then --天域试炼
		str = string.format(Desc.CrossPVPDesc3,CrossPVPModel:getRecordIndex())
	elseif CrossArenaPVPModel:getArrayByType(arrayType) then --跨服真人
		str = string.format(Desc.CrossPVPDesc3,CrossArenaPVPModel:getRecordIndex())
	elseif VoidlandModel:isVoidlandMode(arrayType) then -- 虚空幻境
		local index = VoidlandModel:getCurWave();
		str = string.format(Desc.Voidland_point4, index);
	elseif CrossTeamPVPModel:isCrossTeamPvpType(arrayType) then -- 组队竞技
		str = string.format(Desc.CrossPVPDesc3, CrossTeamPVPModel.recordIdIdx)
	elseif ExtraordinarylevelPvPModel:getArrayByType(arrayType) then --超凡段位赛
		str = string.format(Desc.CrossPVPDesc3,ExtraordinarylevelPvPModel:getRecordIndex())
	elseif StrideServerModel:isCrossPVPType(arrayType) then -- 巅峰竞技
		str = string.format(Desc.CrossPVPDesc3,StrideServerModel:getRecordIndex())
	elseif arrayType == GameDef.BattleArrayType.GodMarket then -- 神虚历险
		str = GodMarketModel:getFightStr()
	else
		local level = EndlessTrialModel:getCurrentLevel() - 1  -- 关卡数
		str = string.format(Desc.EndlessTrial_beginFx,level)
	end
	
	beginEffects["gameTip"]:setTitle(str);
	beginEffects["gameTip"]:getChildAutoType("title2"):setText(str);
	beginEffects["gameTip"]:getTransition("t_gameTip"):play(function(context)
			if finished then
				finished();
			end
			for k, v in pairs(beginEffects) do
				v:setVisible(false)
			end
		end)
	beginEffects["skillObj1"]:setSortingOrder(22)
	beginEffects["skillObj2"]:setSortingOrder(23)
	beginEffects["gameTip"]:setSortingOrder(24)
end


--给战斗技能预览用
function SkillManager.playSkill(attackerID,targetID,fightObjData,finished)

	local attacker=ModelManager.BattleModel:getHeroItemById(attackerID)
	local beAttackers={}
	beAttackers[1]=ModelManager.BattleModel:getHeroItemById(targetID)
	local toPos= attacker:getSelfLocalPos(beAttackers[1]:getSelfScreenPos())--近战的话这里砍第一个位置



	BattleManager.getInstance().fightObjData=fightObjData
	BattleManager.getInstance().attacker=attacker
	BattleManager.getInstance().beAttackers=beAttackers
	BattleManager.getInstance():setFightID(attackerID)

	local skillInfo=SkillConfiger.getSkillById(fightObjData.skill)
	--CameraController.setScreenView(self.view)
	CameraController.hideHeroByScreenType(attacker,beAttackers,skillInfo.screenType)
	if skillInfo.isShade==1 then
		CameraController.blankScreen()
	end
	-- local eventCount=fightObjData.skillEffectSeq[1].value
	local function doAttcack()

		local newSkillType=skillInfo.hitType
		
		if skillInfo.hitType==1 then  --人物自身hit事件
			BattleManager.getInstance().isFinished=true
			
			attacker:standByAttack(function (isDie)
					if finished then
						finished()
					end
					BattleManager:getInstance():affterSkillEffect(attacker,fightObjData,skillInfo.screenType)
				end)
		end
		if skillInfo.hitType>1 and skillInfo.hitType<5 then --受击特效hit事件
			BattleManager.getInstance().isFinished=true
			attacker:magicAttack(function ()
					local delayTime =SkillManager.getSkillMaxTime()
					GlobalUtil.delayCall(function()end,function ()
							if finished then
								finished()
							end
							BattleManager.getInstance():affterSkillEffect(attacker,fightObjData,skillInfo.screenType)
						end,delayTime,1)


				end,newSkillType,skillInfo.bulletType)
		end
		--镜头移动
		BattleManager:getInstance():setSecreenEffect(fightObjData.skill,attacker,beAttackers)
	end

	attacker:setAttackPos(function ()
			doAttcack()
		end)
end





--清理特效管理定时器等时间
function SkillManager.clear(clearEffect)
	for k, ac in pairs(__skillActions) do
		ac:clear()
	end
	__skillActions={}
	loadTag=false
	if soundId2 then
		SoundManager.stopSound(soundId2)
	end
	if soundId then
		SoundManager.stopSound(soundId)
	end
	if clearEffect then
		for effectID, fxList in pairs(commonEffects) do
			if fxList then
				for k, infos in pairs(fxList) do
					local texiaoObj,skeletonNode=infos.goWrap,infos.spine
					if not tolua.isnull(texiaoObj) then
						texiaoObj:removeFromParent()
					end
					--print(086086,"移除",infos.effectConfig.name,infos.effectConfig.stack)
				end
			end
		end
		for effectID, effectList in pairs(boomEffects) do
			for effectID, fxList in pairs(effectList) do
				for k, infos in pairs(fxList) do
					if fxList then
						local texiaoObj,skeletonNode=infos.goWrap,infos.spine
						if not tolua.isnull(texiaoObj) then
							texiaoObj:removeFromParent()
						end
						--print(086086,"移除",infos.effectConfig.name,infos.effectConfig.stack)
						--texiaoObj:removeFromParent()
					end
				end
			end
		end
		boomEffects={}
		commonEffects={}
		beginEffects={}
		fightDataLists={}
		skillList={}
		activeSkillList={}
	end

end





return SkillManager
