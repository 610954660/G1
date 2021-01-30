---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: lijiejian
-- Date: 2020-03-20 15:27:13
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class SkillAction
local  SkillAction =class("SkillAction")
--local  FsmMachine= require "Game.Modules.Battle.Fsm.FsmMachine"
local CameraController=require "Game.Modules.Battle.Effect.CameraController"
local SkillConfiger=require "Game.ConfigReaders.SkillConfiger"
function SkillAction:ctor(skillData)


	self.battlePackge="Battle"
	self.centerPoint=BattleModel:getMapPoint()["center"]
	self.enemyCenter=BattleModel:getMapPoint()["enemyCenter"]
	self.playerCenter=BattleModel:getMapPoint()["playerCenter"]
	self.index=skillData.id
	self.isGodArms=skillData.isGodArms

	self.towardIndex=1

	if skillData.isGodArms then
		self.isGodArms=true
		self.view=skillData.view
		if skillData.heroPos==BattleModel.HeroPos.enemy then
			self.towardIndex=-1
		end
	else

		self.view=skillData.view
		self.skeletonNode=skillData.skeletonNode
		self.category=skillData.category
		self.zIndex=skillData.zIndex
		self.fashion=skillData.fashion
		self.heroID=skillData.heroCode
		self.goWrapParent=self.view:getChildAutoType("goWrap")
		self.towardIndex=self.goWrapParent:getScaleX()
		self.viewGroup=self.view:getGroup()

		self.spineHang_Point=SpineMnange.getBonPosition(self.skeletonNode,"hanging_point",self.index)
		self.spineHit_point=SpineMnange.getBonPosition(self.skeletonNode,"hit_point",self.index)
		self.spineStack_point=SpineMnange.getBonPosition(self.skeletonNode,"stack_point",self.index)

		self.stack_point= self.view:getParent():globalToLocal(self.goWrapParent:localToGlobal(self.spineStack_point))--获取特效挂点坐标
		self.hanging_point= self.view:getParent():globalToLocal(self.goWrapParent:localToGlobal(self.spineHang_Point))--获取特效挂点坐标
		self.hit_point= self.view:getParent():globalToLocal(self.goWrapParent:localToGlobal(self.spineHit_point))--获取特效挂点坐标
		self.globalRoot= self.view:getParent():globalToLocal(self.goWrapParent:localToGlobal(Vector2.zero))--获取角色脚底锚点



		self.localRoot= self.view:globalToLocal(self.goWrapParent:localToGlobal(Vector2.zero))--获取角色脚底锚点相对于父节点
		self.localHang_point=self.view:globalToLocal(self.goWrapParent:localToGlobal(self.spineHang_Point))
		self.localHit_point=self.view:globalToLocal(self.goWrapParent:localToGlobal(self.spineHit_point))

	end

	self.scheduleID=false
	self.buffFxList={}--需求需要死了之后还挂着特效这里保存一下
	self.dieFxList={}--死亡的墓碑特效
	self.connectFx=false
	self.isDie=false


end

--技能受击前的爆炸特效
function SkillAction:creatorBoomFx(skillId,hitEvent,bulletType)

	local activeSkill = DynamicConfigData.t_activeSkill[skillId]
	local boomEffect=false
	local a_baseData=BattleManager:getInstance():acttakerBaseData()
	
	local fashion=false
	if a_baseData then
		fashion=a_baseData.fashion --施法者是带皮肤爆炸特效也带皮肤
	end	
	
	if fashion then
		local fightInfo= BattleManager:getInstance():getFightObjData()
		local skillInfo=SkillConfiger.getSkillById(fightInfo.skill)
		local fanshionInfo = DynamicConfigData.t_Fashion[a_baseData.code] and DynamicConfigData.t_Fashion[a_baseData.code][fashion]
		boomEffect=fanshionInfo.boomEffect
		if next(boomEffect)==nil then
			boomEffect=activeSkill.boomEffect
		else
			local fashionEffect={}
			for k, v in pairs(boomEffect) do
				if v[1]==skillInfo.attackAction[1] then
					for k2, v2 in pairs(v) do
						if v2~=skillInfo.attackAction[1] then
							table.insert(fashionEffect,v2)
						end
					end
				end
			end
			if next(fashionEffect)==nil then
				boomEffect=activeSkill.boomEffect
				--boomEffect=fashionEffect
			else
				boomEffect=fashionEffect  --带皮肤的特效
			end	
		end
		
	else
		boomEffect=activeSkill.boomEffect
	end
	
	

	local beAttacker=ModelManager.BattleModel:getHeroItemById(self.index)
	local skeletonNode=false
	local skillObj =false
	if activeSkill==nil or next(boomEffect)==nil then
		LuaLogE("技能  "..skillId.."  的爆炸特效没有配表",self.index)
		hitEvent(1,self.index,0)
	else
		local upCount=0--现在特效还放两个上层 我只能只触发一个
		
	
		for k, effectID in pairs(boomEffect) do
			local effectInfo = DynamicConfigData.t_effect[effectID]
			local fxList= SkillManager.getBoomEffet(effectID,self.index,self.view:getParent())
			for k, infos in pairs(fxList) do
				local skillObj,skeletonNode,effectConfig=infos.goWrap,infos.spine,infos.effectConfig
				if skeletonNode==false  then
					hitEvent(1,self.index,0)
					return
				end
				skeletonNode:setAnimation(0, effectConfig.stack, false)
				skillObj:setSortingOrder(self.zIndex+effectConfig.hierarchy)
				skillObj:setVisible(true)
				local waitData= FsmMachine:getInstance():addWaitQues(effectID,self.index,effectConfig.stack)
				local toGlobal=false
				local hasHit=true

				local hitPoint=self:getBoomPoint(effectConfig)
				skillObj:setPosition(hitPoint.x,hitPoint.y)
				skillObj:setScale(-self.towardIndex,math.abs(self.towardIndex))
				local count=1
				if  string.find(effectConfig.stack,"up")~=nil then
					upCount=upCount+1
					local eventCount=skeletonNode:getEventCount()
					hasHit=false
					skeletonNode:setEventListener(function (name)
							hasHit=true
							hitEvent(count,self.index)
							count=count+1
						end)
				end
				skeletonNode:setCompleteListener(function()
						if waitData then
							waitData.callBack()
						end
					end)
				if effectConfig.endTime=="" then
					effectConfig.endTime=2
				end
				self.scheduleID=BattleManager:schedule(function()
						if waitData then
							waitData.callBack()
						end
						if upCount==1 and hasHit==false and string.find(effectConfig.stack,"up")~=nil then
							if bulletType~=1 then
								BattleManager:getInstance():fxCheckTips(effectConfig.name.."受击特效结束时间过快特效没有生效")
							end

						end
						if upCount==1 and activeSkill.skillEffect  and (count-1)~=#activeSkill.skillEffect and #activeSkill.skillEffect~=0 and string.find(effectConfig.stack,"up")~=nil then
							if bulletType~=1 then
								BattleManager:getInstance():fxCheckTips("爆炸特效："..effectConfig.stack.." "..(count-1).. " 配表:"..#activeSkill.skillEffect)
							end
						end
						if upCount==0 then
							BattleManager:getInstance():fxCheckTips("爆炸特效："..effectConfig.stack.."找不到一个带_up的后缀")
						end
						--cc.TextureCache:getInstance():removeUnusedTextures()
						--skillObj:removeFromParent()
						skillObj:setVisible(false)
					end,effectConfig.endTime,1)

			end
		end
	end
end


--创建受击者的受击特效
function SkillAction:creatorHitFx(skillId)
	local activeSkill = DynamicConfigData.t_activeSkill[skillId]
	local beAttacker=ModelManager.BattleModel:getHeroItemById(self.index)
	local skeletonNode=false
	local skillObj =false
	if activeSkill then
		BattleManager:getInstance():playSkillSound(activeSkill.sound)
	end
	if activeSkill==nil or next(activeSkill.hitEffect)==nil then
		--LuaLogE("技能  "..skillId.."  的受击特效没有配表",self.index)
	else
		for k, effectID in pairs(activeSkill.hitEffect) do
			local effectInfo = DynamicConfigData.t_effect[effectID]
			local fxList= self:createEffectById(effectID,PathConfiger.getSpineRoot(),self.view:getParent())
			for k, infos in pairs(fxList) do
				local skillObj,skeletonNode,effectConfig=infos.goWrap,infos.spine,infos.effectConfig
				if skeletonNode==false  then
					return
				end
				skeletonNode:setAnimation(0, effectConfig.stack, false)
				local waitData= FsmMachine:getInstance():addWaitQues(effectID,self.index,effectConfig.stack)
				local toGlobal=false

				local hitPoint=self:getBoomPoint(effectConfig)
				skillObj:setPosition(hitPoint.x,hitPoint.y)
				skillObj:setScale(-self.towardIndex,math.abs(self.towardIndex))
				skeletonNode:setCompleteListener(function()
						if waitData then
							waitData.callBack()
						end
					end)
				if effectConfig.endTime=="" then
					effectConfig.endTime=2
				end
				waitData.endTime=effectConfig.endTime
				self.scheduleID=BattleManager:schedule(function()
						if waitData then
							waitData.callBack()
						end
						skillObj:removeFromParent()
					end,effectConfig.endTime,1)
			end
		end
	end
end



--技能施法特效创建
function SkillAction:creatActionFX(skillId,hitEvent,finished)
	local skill = DynamicConfigData.t_skill[skillId]
	
	local commonEffect=false
	if self.fashion then
		local fanshionInfo = DynamicConfigData.t_Fashion[self.heroID] and DynamicConfigData.t_Fashion[self.heroID][self.fashion]
		commonEffect=fanshionInfo.commonEffect
		if next(commonEffect)==nil then
			commonEffect=skill.commonEffect
		else
			local fashionEffect={}
			for k, v in pairs(commonEffect) do
				if v[1]==skill.attackAction[1] then
					for k2, v2 in pairs(v) do
						if v2~=skill.attackAction[1] then
							table.insert(fashionEffect,v2)
						end
					end
				end
			end
			if next(fashionEffect)==nil then
				commonEffect=skill.commonEffect
			else
				commonEffect=fashionEffect  --带皮肤的特效
			end
		end
	else
		commonEffect=skill.commonEffect
	end
	
	
	if  next(commonEffect)==nil then
		LuaLogE("技能"..skillId.."的施法特效没有配表")
	else
		local function addMainFx()
			printTable(55656,commonEffect,"commonEffect")
			for k, effectID in pairs(commonEffect) do

				local fxList= SkillManager.getCommonEffet(effectID)
				if fxList then
					for k, infos in pairs(fxList) do
						local texiaoObj,skeletonNode=infos.goWrap,infos.spine
						local effectConfig=infos.effectConfig
						if texiaoObj==false or  tolua.isnull(texiaoObj) then
							return
						end
						self:setFxLayer(effectConfig.hierarchy,texiaoObj)
						texiaoObj:setVisible(true)
						skeletonNode:setAnimation(0, effectConfig.stack, false)
						local waitData= FsmMachine:getInstance():addWaitQues(effectID,self.index,effectConfig.stack)
						waitData.endTime=effectConfig.endTime
						skeletonNode:setCompleteListener(function ()
								--if waitData then
								--waitData.callBack()
								--end
							end)
						local count=1
						if  string.find(effectConfig.stack,"up")~=nil then
							local eventCount=skeletonNode:getEventCount()
							skeletonNode:setEventListener(function (name)
									if hitEvent then
										hitEvent(count,self.index)
									end
									count=count+1
								end)
						end
						texiaoObj:setScale(self.towardIndex,math.abs(self.towardIndex))
						local texiaoPos=self:getAcFxPoint(effectConfig)
						texiaoObj:setPosition(texiaoPos.x,texiaoPos.y)
						if effectConfig.endTime=="" then
							effectConfig.endTime=5
						end
						self.scheduleID=BattleManager:schedule(function()
								if waitData then
									if not tolua.isnull(texiaoObj) then
										texiaoObj:setVisible(false)
									end
									waitData.callBack()
								end
								if finished then
									finished()
									finished=false
								end
							end,effectConfig.endTime,1)
					end
				end
			end

		end
		addMainFx()
	end
end

-- 精灵技能施法特效创建
function SkillAction:creatElfActionFX(skillId,hitEvent,finished,elfId,skinId)
	if DynamicConfigData.t_ElfSkinSkill
		and DynamicConfigData.t_ElfSkinSkill[elfId]
		and DynamicConfigData.t_ElfSkinSkill[elfId][skinId]
		and DynamicConfigData.t_ElfSkinSkill[elfId][skinId][skillId] then
		skillId = DynamicConfigData.t_ElfSkinSkill[elfId][skinId][skillId].skinSkillId
	end
	local skill = DynamicConfigData.t_skill[skillId]
	if  next(skill.commonEffect)==nil then
		--LuaLogE("技能"..skillId.."的施法特效没有配表")
	else
		local function addMainFx()

			for k, effectID in pairs(skill.commonEffect) do
				-- print(086,effectID,"effectID")
				local fxList= SkillManager.getCommonEffet(effectID)
				if fxList then
					for k, infos in pairs(fxList) do
						local texiaoObj,skeletonNode=infos.goWrap,infos.spine
						local effectConfig=infos.effectConfig
						if tolua.isnull(texiaoObj) or texiaoObj==false or  texiaoObj==nil then
							return
						end
						self:setFxLayer(effectConfig.hierarchy,texiaoObj)
						texiaoObj:setVisible(true)
						skeletonNode:setAnimation(0, effectConfig.stack, false)
						local waitData= FsmMachine:getInstance():addWaitQues(effectID,self.index,effectConfig.stack)
						waitData.endTime=effectConfig.endTime
						skeletonNode:setCompleteListener(function ()
								--if waitData then
								--waitData.callBack()
								--end
							end)
						local count=1
						if  string.find(effectConfig.stack,"up")~=nil then
							local eventCount=skeletonNode:getEventCount()
							skeletonNode:setEventListener(function (name)
									if hitEvent then
										hitEvent(count,self.index)
									end
									count=count+1
								end)
						end
						texiaoObj:setScale(self.towardIndex,math.abs(self.towardIndex))
						local texiaoPos=self:getAcFxPoint(effectConfig)
						texiaoObj:setPosition(texiaoPos.x,texiaoPos.y)
						if effectConfig.endTime=="" then
							effectConfig.endTime=5
						end
						self.scheduleID=BattleManager:schedule(function()
								if waitData then
									if not tolua.isnull(texiaoObj) then
										texiaoObj:setVisible(false)
									end
									waitData.callBack()
								end
								if finished then
									finished()
									finished=false
								end
							end,effectConfig.endTime,1)
					end
				end
			end

		end
		addMainFx()
	end
end

--创建例会特效
function SkillAction:creatorLihuiFx(skill,finished, lihuiIndex)
	--finished()
	local lihuiParent=false
	local viewInfo=ViewManager.getViewInfo("BattleBeginView")
	if viewInfo then
		lihuiParent=viewInfo.window.ctlView["BattleSecnesView"].lihuiMask
		lihuiParent:setSortingOrder(2)
	else
		lihuiParent=self.view:getParent():getChildAutoType("lihuiMask")
		lihuiParent:setSortingOrder(13)
	end
	local lihuiPos=self.centerPoint:getPosition()

	--下层特效
	local comonUiObj,comonUiSpine=self:createSkillFx(PathConfiger.getBattleFxRoot(),"Ef_jinengshifang_up",-1,lihuiParent:getParent())
	comonUiObj:setPosition(lihuiPos.x,lihuiPos.y)
	comonUiSpine:setAnimation(0,"lihui_efx",false)

	--中间层特效
	local comonUiObj_spine,comonUiSpine__spine=self:createSkillFx(PathConfiger.getBattleFxRoot(),"Ef_jinengshifang_up",-1,lihuiParent)
	comonUiSpine__spine:setAnchorPoint({x=0.5,y=0.5})
	comonUiObj_spine:setPosition(lihuiPos.x,lihuiPos.y)
	local ccNode = comonUiSpine__spine:getNodeForSlot("lihui")--找到插槽的挂
	ccNode:setAnchorPoint({x=0.5,y=0.5})
	local lihuiObj=false
	
	local lihuiName = skill.liHui..(lihuiIndex == 0 and "" or "_"..lihuiIndex).."_lihui"
	lihuiObj=SpineMnange.createByPath("lihui",lihuiName,lihuiName)
	ccNode:addChild(lihuiObj)
	lihuiObj:setAnimation(0,"animation2",false)
	comonUiSpine__spine:setAnimation(0,"spine",false)

	----最上层特效
	local comonUiObj_ziti,comonUiSpine_ziti=self:createSkillFx(PathConfiger.getBattleFxRoot(),"Ef_jinengshifang_up",14,lihuiParent:getParent())
	local ccNode2 = comonUiSpine_ziti:getNodeForSlot("ziti")--找到艺术字插槽挂点
	ccNode2:setAnchorPoint({x=0.5,y=0.5})
	local sprite= cc.Sprite:create("lihui/UI/"..skill.liHui..".png")
	sprite:setAnchorPoint({x=0.5,y=0.5})
	ccNode2:addChild(sprite,2)
	comonUiObj_ziti:setPosition(lihuiPos.x,lihuiPos.y)
	comonUiSpine_ziti:setAnimation(0,"ziti",false)


	local scalex=self.towardIndex/math.abs(self.towardIndex)

	comonUiObj:setScaleX(scalex)
	lihuiParent:setScaleX(scalex)
	comonUiObj_ziti:setScaleX(scalex)
	sprite:setScaleX(scalex)


	self.scheduleID=BattleManager:schedule(function()
			finished()
			comonUiObj:removeFromParent()
			comonUiObj_spine:removeFromParent()
			comonUiObj_ziti:removeFromParent()
		end,1.6,1)
end


--被动莫名其妙的爆炸特效 真是生搬硬套的设计
function SkillAction:createBuffBoomFx(buffId)
	local buff=DynamicConfigData.t_buff[buffId]
	if buff.specialEffectsEx then
		for k, effectID in pairs(buff.specialEffectsEx) do
			local fxList= self:createEffectById(effectID,PathConfiger.getSpineRoot(),self.view:getParent())
			for k, infos in pairs(fxList) do
				local texiaoObj,skeletonNode=infos.goWrap,infos.spine
				local effectConfig=infos.effectConfig
				skeletonNode:setAnimation(0, effectConfig.stack, false)
				local hitPoint=self:getBoomPoint(effectConfig)
				texiaoObj:setPosition(hitPoint.x,hitPoint.y)
			end
		end
	end
end

--添加buff特效
function SkillAction:addBuffFx(buffData)

	local hungObjs={}
	local buff=DynamicConfigData.t_buff[buffData.buffId]
	if buff.boneStyle==1 then--这个buff有眩晕状态需要处理
		local beAttacker=ModelManager.BattleModel:getHeroItemById(self.index)
		beAttacker.battleState:OnStun()
	end
	if buff.boneStyle==2 then--这个buff有冰冻状态
		local beAttacker=ModelManager.BattleModel:getHeroItemById(self.index)
		beAttacker.battleState:OnFreeze()
	end
	if buff.specialEffects~="" and self.buffFxList[buffData.id]==nil then
		if buffData.contactIds then
			local lineFrom=self.localHit_point
			local beAttacker=ModelManager.BattleModel:getHeroItemById(buffData.contactIds[1])
			local hanging_point=SpineMnange.getBonPosition(beAttacker.skeletonNode,"hit_point",self.index)
			local particleObj,particle=ParticleUtil.createParticleObj(self.view,cc.p(lineFrom.x,lineFrom.y),"particle_texture")
			particleObj.contactId=buffData.contactIds[1]
			local toGlobal=beAttacker.goWrapParent:localToGlobal(Vector2.zero)
			local lineEnd=self.goWrapParent:globalToLocal(toGlobal)
			particle:setAngle(self:getAngleByPos2(lineFrom,lineEnd))
			particle:setSpeed(Vector2.distance(Vector2(lineFrom.x,lineFrom.y),Vector2(lineEnd.x,lineEnd.y))*2)
			table.insert(hungObjs,particleObj)
			SkillManager.addConnectFx(self.index,particleObj)
			SkillManager.addConnectFx(particleObj.contactId,particleObj)
		end
		for k, effectID in pairs(buff.specialEffects) do
			local effectInfo = DynamicConfigData.t_effect[effectID]--查看技能信息
			for k, effectConfig in pairs(effectInfo) do
				local skillObj,skeletonNode=false,false
				skillObj,skeletonNode= self:createSkillFx(PathConfiger.getSpineRoot(),effectConfig.name,effectConfig.hierarchy)
				local hangPos=self:getFxHungPoint(effectConfig,self.view)
				skillObj:setPosition(hangPos.x,hangPos.y)
				skillObj:setScale(self.towardIndex,math.abs(self.towardIndex))
				skillObj:setVisible(not self.isDie)
				if effectConfig.endTime=="" then
					skeletonNode:setAnimation(0, effectConfig.stack, true);
					table.insert(hungObjs,skillObj)
				else
					skeletonNode:setAnimation(0, effectConfig.stack, false);
					self:recycleByConfig(effectConfig,function ()
							skillObj:removeFromParent()
							self.buffFxList[buffData.id]=nil
						end)
				end
			end
		end
		if next(buff.specialEffects)~=nil then
			self.buffFxList[buff.specialEffects[1]]=hungObjs
		end
	end
end


--关联一个能链接到另外一个角色的buff特效
function SkillAction:addConnectFx(connectFx)
	self.connectFx=connectFx
end



--移除buff特效
function SkillAction:removeBuffFx(effName,boneStyle)
	local hungObjs=self.buffFxList[effName]

	if boneStyle==1 then--这个buff有眩晕状态需要处理
		print(5656,"removeBuffFx,","解冻眩晕",self.index)
		local beAttacker=ModelManager.BattleModel:getHeroItemById(self.index)
		beAttacker.battleState:OnInit(boneStyle)--死亡的角色移除buff 这个操作会把尸体显示出来！！
	end
	if boneStyle==2 then--这个buff有冰冻状态
		--print(52100,"removeBuffFx,","解冻")
		local beAttacker=ModelManager.BattleModel:getHeroItemById(self.index)
		beAttacker.battleState:OnInit(boneStyle)--死亡的角色移除buff 这个操作会把尸体显示出来！！
	end
	if hungObjs~=nil then
		for k, skillObj in pairs(hungObjs) do
			if skillObj.contactId then
				SkillManager.addConnectFx(self.index,false)
				SkillManager.addConnectFx(skillObj.contactId,false)
			end
			if skillObj.removeFromParent then
				skillObj:removeFromParent()
			end
		end
		self.buffFxList[effName]=nil
	end
end


--隐藏buff特效
function SkillAction:setBuffVisible(isVisible,isDie)
	self.isDie= isDie
	for k, hungObjs in pairs(self.buffFxList) do
		for k2, skillObj in pairs(hungObjs) do
			if not skillObj.contactId then
				skillObj:setVisible(isVisible)
			end

		end
	end
	if self.connectFx and not self.connectFx.isDie then
		self.connectFx.isDie=isDie
		self.connectFx:setVisible(isVisible)
	end
end

function SkillAction:clearAllFx()
	for k, hungObjs in pairs(self.buffFxList) do
		for k2, skillObj in pairs(hungObjs) do
			skillObj:removeFromParent()
		end
	end
	self:removeDieFX()
end




--根据种族播放死亡特效
function SkillAction:creatorDieFX()
	local effectID=100000+self.category
	local waitData= false
	local fxList= self:createEffectById(effectID,PathConfiger.getSpineRoot())

	if fxList==false then
		waitData=FsmMachine:getInstance():addWaitQues(effectID,self.index,"死亡特效没有配表 ")
		return
	else
		waitData=FsmMachine:getInstance():addWaitQues(effectID,self.index,"animation")
	end
	for k, infos in pairs(fxList) do
		local skillObj,skeletonNode,effectConfig=infos.goWrap,infos.spine,infos.effectConfig
		if skillObj==false then
			return
		end
		skeletonNode:setAnimation(0, effectConfig.stack, true)
		skeletonNode:setCompleteListener(function ()
			end)
		skillObj:setScaleX(self.towardIndex)
		local globalRoot=self.view:getParent():globalToLocal(self.goWrapParent:localToGlobal(Vector2.zero))--获取角色脚底锚点
		if self.localRoot then
			skillObj:setPosition(self.localRoot.x,self.localRoot.y)
		end
		table.insert(self.dieFxList,skillObj)
	end
	local fxList2=self:createEffectById(10058,PathConfiger.getSpineRoot())
	for k, infos in pairs(fxList2) do
		local skillObj,skeletonNode,effectConfig=infos.goWrap,infos.spine,infos.effectConfig
		if skillObj==false then
			return
		end
		skeletonNode:setAnimation(0, effectConfig.stack, false)
		skeletonNode:setCompleteListener(function ()
			end)
		skillObj:setScaleX(self.towardIndex)
		local globalRoot=self.view:getParent():globalToLocal(self.goWrapParent:localToGlobal(Vector2.zero))--获取角色脚底锚点
		if self.localRoot then
			skillObj:setPosition(self.localRoot.x,self.localRoot.y)
		end
		table.insert(self.dieFxList,skillObj)
	end
	if self.connectFx then
		self.connectFx.isDie=false
		self.connectFx:setVisible(true)
	end
	if waitData then
		waitData.callBack()
	end



end


--复活后移除死亡特效
function SkillAction:removeDieFX()
	if self.dieFxList~=nil then
		for k2, skillObj in pairs(self.dieFxList) do
			if skillObj.removeFromParent then
				skillObj:removeFromParent()
			end
		end
	end
	self.dieFxList={}
end

--播放复活特效
function SkillAction:creatorRevivedFx()
	local effectID=10057

	local waitData= false
	local fxList= self:createEffectById(effectID,PathConfiger.getSpineRoot())
	if fxList==false then
		waitData=FsmMachine:getInstance():addWaitQues(effectID,self.index,"复活特效没有配表 ")
		return
	else
		waitData=FsmMachine:getInstance():addWaitQues(effectID,self.index,"animation")
	end
	for k, infos in pairs(fxList) do
		local skillObj,skeletonNode,effectConfig=infos.goWrap,infos.spine,infos.effectConfig
		if skillObj==false then
			return
		end
		skeletonNode:setAnimation(0, effectConfig.stack, true)
		skillObj:setScaleX(self.towardIndex)
		local globalRoot=self.view:getParent():globalToLocal(self.goWrapParent:localToGlobal(Vector2.zero))--获取角色脚底锚点
		if self.localRoot then
			skillObj:setPosition(self.localRoot.x,self.localRoot.y)
		end
		self:recycleByConfig(effectConfig,function ()
				skillObj:removeFromParent()
			end)
	end
	if waitData then
		waitData.callBack()
	end
end




--根据组合技能播放带轨迹的技能特效
function SkillAction:creatorFlyFx(skillData,finished)

	local activeSkillId=skillData.skill
	local targetId=skillData.id
	local flyType=skillData.skillType


	local beAttacker=ModelManager.BattleModel:getHeroItemById(targetId)
	local activeSkill = DynamicConfigData.t_activeSkill[activeSkillId]

	local effectInfo = DynamicConfigData.t_effect[activeSkill.flyEffect[1]]
	if beAttacker.isSub==true then
		--print(521,"复活替补复活替补复活替补")
		return
	end
	if  next(activeSkill.flyEffect)==nil then
		self.scheduleID=BattleManager:schedule(function()
				finished()
				local waitData= BattleManager:addWaitSecond(1,beAttacker.index,"noflyEffect")
			end,0.1,1)
		--LuaLogE("技能"..activeSkillId.."的飞行特效没有配表")
	else
		local fxList=self:createEffectById(activeSkill.flyEffect[1],PathConfiger.getSpineRoot(),self.view:getParent())
		for k, infos in pairs(fxList) do
			local skillObj,skeletonNode,effectConfig=infos.goWrap,infos.spine,infos.effectConfig
			if skillObj==false then
				return
			end
			if self.stack_point  then
				local stack_point=self:getFxHungPoint(effectConfig,self.view:getParent())
				skillObj:setPosition(stack_point.x,stack_point.y)
			end
			skeletonNode:setAnimation(0, effectConfig.stack, true)
			skillObj:setVisible(true)
			local fromGloblal=skillObj:localToGlobal(Vector2.zero);
			local toGlobal=false
			if effectConfig.zhongDian==1 then
				if beAttacker.heroPos==BattleModel.HeroPos.enemy then
					toGlobal=self.enemyCenter:localToGlobal(Vector2.zero)
				else
					toGlobal=self.playerCenter:localToGlobal(Vector2.zero)
				end
			else
				toGlobal=SpineMnange.getBonPosition(beAttacker.skeletonNode,effectConfig.guaDian,self.index)
				toGlobal=beAttacker.goWrapParent:localToGlobal(toGlobal)
			end
			local toPos=skillObj:getParent():globalToLocal(toGlobal)
			if effectConfig.flyTime=="" then
				effectConfig.flyTime=0.2
			end

			local waitData= FsmMachine:getInstance():addWaitQues(activeSkill.flyEffect[1],beAttacker.index,effectConfig.stack)
			local onComplete=function()
				if tolua.isnull(self.view) then
					return
				end
				if waitData then
					waitData.callBack()
				end
				skillObj:removeFromParent()
			end
			if flyType==2 then  --直线飞行
				if effectConfig.delayTime=="" then
					effectConfig.delayTime=0
				end
				--print(086,flyType,"flyTypeflyTypeflyType")
				skeletonNode:setRotation(self:getAngleByPos(fromGloblal,toGlobal))
				skillObj:setScale(self.towardIndex,math.abs(self.towardIndex))
				local fromPos=skillObj:getPosition()
				local ky=(toPos.y-fromPos.y)/(toPos.x-fromPos.x)
				local fx=(toPos.x-fromPos.x)/effectConfig.flyTime*effectConfig.delayTime
				local fy=fx*ky

				local arg = {}
				arg.from = fromPos
				arg.to = Vector2(toPos.x+fx,toPos.y+fy)
				arg.time = effectConfig.flyTime+effectConfig.delayTime
				arg.ease = EaseType.SineOut
				arg.tweenType="Battle"
				--arg.onUpdate=function(x,y)
				----print(086,x,toPos.x,"toPos.x")
				--if math.ceil(x)>=toPos.x then
				--arg.onUpdate=false
				--end
				--end
				BattleManager:schedule(function()
						finished()
					end,effectConfig.flyTime,1)
				arg.onComplete = function( ... )
					onComplete()
				end

				TweenUtil.moveTo(skillObj,arg)
			else--曲线飞行
				skeletonNode:setAnimation(0, effectConfig.stack, true)
				local toPos2=Vector2(toPos.x-skillObj:getPosition().x,toPos.y-skillObj:getPosition().y)
				local spineRect=skeletonNode:getBoundingBox()
				skeletonNode:setAnchorPoint(Vector2(1,1))
				self:run_PwAction(skeletonNode,0.6,Vector2.zero,Vector2(toPos2.x,-toPos2.y),100,30,function ()
						finished()
						onComplete()
					end)

			end
		end
	end
end





--抛物线弹道
function SkillAction:run_PwAction(obj,t,startPoint,endPoint,height,angle,finished)
	--把角度转换为弧度
	--local obj=skillObj:displayObject()
	local scaleX=1
	if endPoint.x<0 then
		scaleX=-1
	end
	local radian = angle*3.14159/180.0;
	-- 第一个控制点为抛物线左半弧的中点
	local q1x = startPoint.x+(endPoint.x - startPoint.x)/4.0;
	local q1 = ccp(q1x, height + startPoint.y+math.cos(radian)*math.abs(q1x));
	-- 第二个控制点为整个抛物线的中点
	local q2x = startPoint.x + (endPoint.x - startPoint.x)/2.0;
	local q2 = ccp(q2x, height + startPoint.y+math.cos(radian)*math.abs(q2x));

	--曲线配置
	local cfg={q1,q2,endPoint}
	local a1=cc.BezierBy:create(t,cfg)
	local a2= cc.MoveTo:create(t,endPoint)

	local finihed=cc.CallFunc:create(function()
			--obj:removeFromParent()
			if finished then
				finished()
			end
		end)
	obj:setScaleX(scaleX)

	obj:runAction(cc.Sequence:create(a1,finihed))
	local LastPos={x=obj:getPositionX(),y=obj:getPositionY()}
	obj:onUpdate(function (dt)
			local nextPos={x=obj:getPositionX(),y=obj:getPositionY()}
			--printTable(0866,nextPos,"nextPos")
			obj:setRotation(scaleX*self:getAngleByPos(nextPos,LastPos))
			LastPos=nextPos
		end)
end



function SkillAction:createEffectById(effectID,pathRoot,parent)
	local effectInfo = DynamicConfigData.t_effect[effectID]--查看技能信息
	if effectInfo==nil then
		LuaLogE("特效:"..effectID.."没有配表")
		return  false
	end
	local fxList={}
	for k, effectConfig in pairs(effectInfo) do
		local skeletonNode=SpineMnange.createByPath(pathRoot,effectConfig.name)
		if skeletonNode==nil then
			print(4,"加载 spine  :"..effectConfig.name.." .skel    "..effectConfig.name.." .atlas","出错")
			return  false
		end
		--local skillObj = FGUIUtil.createObjectFromURL(self.battlePackge,'GoWrap')
		local skillObj = fgui.GObject:create()
		skillObj:displayObject():addChild(skeletonNode)
		if parent==nil then
			parent=self.view
		end
		parent:addChild(skillObj)
		skillObj:setSortingOrder(self.zIndex+effectConfig.hierarchy)
		local infos={}
		infos.goWrap=skillObj
		infos.spine=skeletonNode
		infos.effectConfig=effectConfig
		table.insert(fxList,infos)
		skillObj:setGroup(self.viewGroup)
	end
	return  fxList
end





--创建一个技能特效
function SkillAction:createSkillFx(path,skelPath,layer,parent)

	local skeletonNode=SpineMnange.createByPath(path,skelPath)
	if skeletonNode==nil then
		print(4,"加载 spine  :"..skelPath.." .skel    "..skelPath.." .atlas","出错")
		return  false,false
	end
	local skillObj = fgui.GObject:create()
	skillObj:displayObject():addChild(skeletonNode)
	if parent==nil then
		parent=self.view
	end
	parent:addChild(skillObj)
	--print(0866,self.zIndex+layer,"设置层级为")
	if layer==-1 then
		skillObj:setSortingOrder(1)
	else
		skillObj:setSortingOrder(self.zIndex+layer)
	end

	skillObj:setGroup(self.viewGroup)
	return  skillObj,skeletonNode

end

--在特效配表时间内回收释放掉
function SkillAction:recycleByConfig(effectConfig,finished)
	self.scheduleID=BattleManager:schedule(function()
			if finished then
				finished()
			end
		end,effectConfig.endTime,1)
end





--根据配表类型获取爆炸位置
function SkillAction:getBoomPoint(effectConfig)

	local hitPoint=false
	local toGlobal=false

	if effectConfig.point==1 then--特效在阵营场地中间上爆炸
		local beAttacker=ModelManager.BattleModel:getHeroItemById(self.index)
		if beAttacker.heroPos==BattleModel.HeroPos.enemy then
			toGlobal=self.enemyCenter:localToGlobal(Vector2.zero)
		else
			toGlobal=self.playerCenter:localToGlobal(Vector2.zero)
		end
		toGlobal=self.view:getParent():globalToLocal(toGlobal)
		hitPoint=toGlobal
	end
	if effectConfig.point==2 then --特效在屏幕中间上爆炸
		toGlobal=self.centerPoint:getPosition()
		toGlobal=self.view:getParent():globalToLocal(toGlobal)
		hitPoint=toGlobal
	end
	if effectConfig.point=="" then --受击者身上爆炸
		hitPoint=self:getFxHungPoint(effectConfig,self.view:getParent())
	end
	return hitPoint
end


function SkillAction:getAcFxPoint(effectConfig)
	local point=false
	local toGlobal=false
	if effectConfig.fieldEffect==1 then--技能特效在场地中间
		point=self.centerPoint:getPosition()
	else
		if self.isGodArms then
			BattleManager:getInstance():fxCheckTips("精灵技能不能配施法特效,因为找不到施法位置",2)
			return self.centerPoint:getPosition()
		end
		point=self.view:getParent():globalToLocal(self.goWrapParent:localToGlobal(Vector2.zero))--获取角色脚底锚点
	end
	return point
end




--寻找挂点
function SkillAction:getFxHungPoint(effectConfig,parent)
	local  hungPoint=false
	if effectConfig.guaDian=="" then
		effectConfig.guaDian="root"
	end
	if effectConfig.guaDian=="root" then
		hungPoint=Vector2.zero
	end
	if effectConfig.guaDian=="hit_point" then
		hungPoint=self.spineHit_point
	end
	if effectConfig.guaDian=="hanging_point" then
		hungPoint=self.spineHang_Point
	end
	if effectConfig.guaDian=="stack_point" then
		hungPoint=SpineMnange.getBonPosition(self.skeletonNode,"stack_point",self.index)--攻击的时候位置会变化
	end
	hungPoint = parent:globalToLocal(self.goWrapParent:localToGlobal(hungPoint))--获取特效挂点相对于某个父类节点的坐标
	return hungPoint
end


function SkillAction:setFxLayer(layer,texiaoObj)

	if math.abs(layer)>24 then
		--self.ctlView["BattleSecnesView"]
		local viewInfo=ViewManager.getViewInfo("BattleBeginView")
		local view=viewInfo.window.ctlView["BattleSecnesView"]
		--local view = ViewManager.getLayerTopWindow(LayerDepth.Window)
		local fXparent=view.view
		fXparent:addChild(texiaoObj)
		return
	end

	local effectParent=CameraController.getScreenView()
	effectParent:addChild(texiaoObj)
	if math.abs(layer)>9 then
		if layer>0 then
			texiaoObj:setSortingOrder(layer)
		else
			texiaoObj:setSortingOrder(0)
		end
	else
		local attackZindex=self.view:getSortingOrder()
		texiaoObj:setSortingOrder(attackZindex+layer)
	end
	if self.viewGroup then
		texiaoObj:setGroup(self.viewGroup)
	end

end


--特效角度计算
function SkillAction:getAngleByPos(p1,p2)
	local p = {}
	p.x = (p2.x - p1.x)
	p.y = (p2.y - p1.y)

	local r=0
	if p2.x>p1.x then
		p.x = (p2.x - p1.x)
		p.y = (p2.y - p1.y)
		r = math.atan2(p.y,p.x)*180/math.pi
	else
		p.x = -(p2.x - p1.x)
		p.y = -(p2.y - p1.y)
		r = -math.atan2(p.y,p.x)*180/math.pi
	end
	--print(086,"夹角[-180 - 180]:",r)
	return r
end


function SkillAction:getAngleByPos2(p1,p2)
	local p = {}
	local r=0
	p.x = self.towardIndex*(p2.x - p1.x)
	p.y = self.towardIndex* (p2.y - p1.y)
	r = math.atan2(p.y,p.x)*180/math.pi
	--print(086,"getAngleByPos2:",r)
	return (-self.towardIndex)*r
end



--如果立即结束战斗有什么报错,可以在结束前在这里清理数据
function SkillAction:clear()
	--cc.TextureCache:getInstance():removeUnusedTextures()
	display.removeUnusedSpriteFrames()
	self:clearAllFx()
	self.dieFxList={}
	self.buffFxList={}
end



return SkillAction




