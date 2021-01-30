---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-11-24 14:56:30
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class ElveSkillManage
local ElveSkillManage = {}
local commonEffectsElves = {} 	
local boomEffectsElves = {}

-- 获取精灵施法特效
function ElveSkillManage.getCommonEffetElves(effectID,parent)
	if commonEffectsElves[effectID]==nil then
		commonEffectsElves[effectID]=SpineUtil.createEffectById(effectID,PathConfiger.getSpineRoot(),parent)
	end	
	return commonEffectsElves[effectID]
end

-- 获取精灵爆炸特效
function ElveSkillManage.getBoomEffetElves(effectID,parent)
	if boomEffectsElves[effectID]==nil then
		boomEffectsElves[effectID]=SpineUtil.createEffectById(effectID,PathConfiger.getSpineRoot(),parent)
	end	
	return boomEffectsElves[effectID]
end

function ElveSkillManage.normalEffect2(skillId,parentView,RHero,LHero,elfId,skinId)
	if DynamicConfigData.t_ElfSkinSkill
		and DynamicConfigData.t_ElfSkinSkill[elfId]
		and DynamicConfigData.t_ElfSkinSkill[elfId][skinId]
		and DynamicConfigData.t_ElfSkinSkill[elfId][skinId][skillId] then
		skillId = DynamicConfigData.t_ElfSkinSkill[elfId][skinId][skillId].skinSkillId
	end

	local skill 	= DynamicConfigData.t_skill[skillId] or {}
	--skill.commonEffect 可能是他
	local activeSkill = DynamicConfigData.t_activeSkill[skillId] or {}

	local effectData = {}
	if TableUtil.GetTableLen(activeSkill.boomEffect) > 0 then
		effectData = activeSkill.boomEffect
		for k, effectID in pairs(activeSkill.boomEffect) do
			local fxList= ElveSkillManage.getBoomEffetElves(effectID,parentView)
			if fxList then
				local keys = {}
				for k, infos in pairs(fxList) do
					ElveSkillManage.resetSkill(infos,keys,k,false,effectID,parentView,RHero,LHero)
				end
			end
		end
	else
		effectData = skill.commonEffect
		for k, effectID in pairs(skill.commonEffect) do
			local fxList= ElveSkillManage.getCommonEffetElves(effectID,parentView)
			if fxList then
				local keys = {}
				for k, infos in pairs(fxList) do
					ElveSkillManage.resetSkill(infos,keys,k,true,effectID,parentView,RHero,LHero)
				end
			end
		end
	end
	local endTime = {}
	for k,effectId in pairs(effectData) do
		local effectInfo = DynamicConfigData.t_effect[effectId]--查看技能信息
		for o,p in pairs(effectInfo) do
			local data = {}
			if p.endTime then
				data.endTime = p.endTime
				table.insert(endTime,data)
			end
		end
	end
	local keys = {
		{key = "endTime",asc = true},
	}
	TableUtil.sortByMap(endTime,keys)
	local delay = endTime[1].endTime + 0.5 or 0.5
	Scheduler.scheduleOnce(delay, function()
			if not tolua.isnull(parentView) then
				ElveSkillManage.normalEffect2(skillId,parentView,RHero,LHero,elfId,skinId)
			end
		end)
end

-- 获取特效层级
function ElveSkillManage.getHierarchy(elfId,skillId,skinId)
	if DynamicConfigData.t_ElfSkinSkill
		and DynamicConfigData.t_ElfSkinSkill[elfId]
		and DynamicConfigData.t_ElfSkinSkill[elfId][skinId]
		and DynamicConfigData.t_ElfSkinSkill[elfId][skinId][skillId] then
		skillId = DynamicConfigData.t_ElfSkinSkill[elfId][skinId][skillId].skinSkillId
	end

	local skill 	= DynamicConfigData.t_skill[skillId] or {}
	local activeSkill = DynamicConfigData.t_activeSkill[skillId] or {}
	local effectData = {}
	if TableUtil.GetTableLen(activeSkill.boomEffect) > 0 then
		effectData = activeSkill.boomEffect
	else
		effectData = skill.commonEffect
	end
	local hierarchy = {}
	for k,effectId in pairs(effectData) do
		local effectInfo = DynamicConfigData.t_effect[effectId]--查看技能信息
		for o,p in pairs(effectInfo) do
			local hieData = {}
			hieData.hierarchy = p.hierarchy
			table.insert(hierarchy,hieData)
		end
	end
	local keys2 = {
		{key = "hierarchy",asc = true}
	}
	TableUtil.sortByMap(hierarchy,keys2)
	return hierarchy[1].hierarchy
end

--寻找挂点
function ElveSkillManage.getFxHungPoint(effectConfig,parent,RHero)
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
	-- if effectConfig.guaDian=="stack_point" then
	-- 	hungPoint=SpineMnange.getBonPosition(self.skeletonNode,"stack_point",self.index)--攻击的时候位置会变化
	-- end
	hungPoint = parent:globalToLocal(RHero[2]:localToGlobal(hungPoint))--获取特效挂点相对于某个父类节点的坐标
	return hungPoint
end

--根据配表类型获取爆炸位置
function ElveSkillManage.getBoomPoint(parentView,effectConfig,RHero,LHero)
	local centerPoint = parentView:getChildAutoType("centerPoint")
	local enemyCenter = parentView:getChildAutoType("enemyCenter")
	local playerCenter = parentView:getChildAutoType("playerCenter")
	local arrayCenter = parentView:getChildAutoType("arrayCenter")
	local hitPoint=false
	local toGlobal=false
	if effectConfig.point==1 then--特效在阵营场地中间上爆炸
		local beAttacker = RHero[2]
		toGlobal=enemyCenter:localToGlobal(Vector2.zero)
		toGlobal=parentView:getParent():globalToLocal(toGlobal)
		hitPoint=toGlobal
	end
	if effectConfig.point==2 then --特效在屏幕中间上爆炸
		toGlobal=centerPoint:getPosition()
		toGlobal=parentView:getParent():globalToLocal(toGlobal)
		hitPoint=toGlobal
	end
	if effectConfig.point=="" then --受击者身上爆炸
		hitPoint=ElveSkillManage.getFxHungPoint(effectConfig,parentView:getParent(),RHero)
	end
	return hitPoint
end

function ElveSkillManage.getAcFxPoint(effectConfig,parentView,LHero)
	local centerPoint = parentView:getChildAutoType("centerPoint")
	local enemyCenter = parentView:getChildAutoType("enemyCenter")
	local playerCenter = parentView:getChildAutoType("playerCenter")
	local arrayCenter = parentView:getChildAutoType("arrayCenter")
	local point=false
	local toGlobal=false
	if effectConfig.fieldEffect==1 then--技能特效在场地中间
		point = centerPoint:getPosition()
	else
		point = parentView:getParent():globalToLocal(LHero[2]:localToGlobal(Vector2.zero))--获取角色脚底锚点
	end
	return point
end

function ElveSkillManage.resetSkill(infos,keys,k,commonEffect,effectID,parentView,RHero,LHero)
	local skillObj,skeletonNode,effectConfig=infos.goWrap,infos.spine,infos.effectConfig
	keys[k] = true
	skeletonNode:setAnimation(0, effectConfig.stack,false)
	local taget = {}
	if commonEffect then
		taget = ElveSkillManage.getAcFxPoint(effectConfig,parentView,LHero)
		skillObj:setPosition(taget.x,taget.y)
	else
		taget = ElveSkillManage.getBoomPoint(parentView,effectConfig,RHero,LHero)
		skillObj:setPosition(taget.x,taget.y)
	end
	skeletonNode:setCompleteListener(function()
			local checkKeys = true
			keys[k] = false
			for o,p in pairs(keys) do
				if p == true then
					checkKeys = false
					break
				end
			end
			if checkKeys  then
				if not tolua.isnull(skillObj) then
					skillObj:removeFromParent()
				end
				if commonEffect then
					commonEffectsElves[effectID] = nil
				else
					boomEffectsElves[effectID] = nil
				end
			end
		end)
end




-- 移除无角色施法(精灵)
function ElveSkillManage.removeEffect2(skillId,elfId,skinId)
	if DynamicConfigData.t_ElfSkinSkill
		and DynamicConfigData.t_ElfSkinSkill[elfId]
		and DynamicConfigData.t_ElfSkinSkill[elfId][skinId]
		and DynamicConfigData.t_ElfSkinSkill[elfId][skinId][skillId] then
		skillId = DynamicConfigData.t_ElfSkinSkill[elfId][skinId][skillId].skinSkillId
	end
	local skill 		= DynamicConfigData.t_skill[skillId] or {}
	local activeSkill 	= DynamicConfigData.t_activeSkill[skillId] or {}

	for k, effectID in pairs(skill.commonEffect) do
		local fxList= ElveSkillManage.getCommonEffetElves(effectID)
		if fxList then
			local keys = {}
			for k, infos in pairs(fxList) do
				local skillObj,skeletonNode,effectConfig=infos.goWrap,infos.spine,infos.effectConfig
				skillObj:removeFromParent()
			end
		end
		commonEffectsElves[effectID] = nil
	end

	for k, effectID in pairs(activeSkill.boomEffect) do
		local fxList= ElveSkillManage.getBoomEffetElves(effectID)
		if fxList then
			for k, infos in pairs(fxList) do
				local skillObj,skeletonNode,effectConfig=infos.goWrap,infos.spine,infos.effectConfig
				skillObj:removeFromParent()
			end
		end
		boomEffectsElves[effectID] = nil
	end
end
	
	
	
	
return 	ElveSkillManage