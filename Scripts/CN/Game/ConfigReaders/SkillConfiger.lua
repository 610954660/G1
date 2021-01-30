local SkillConfiger = {}
local MATH_RANDOM = math.random
-----------------
--[[
* 获取技能信息
* @param value
* @return
--]]
function SkillConfiger.getSkillById(skillId)
	local skill=DynamicConfigData.t_skill[skillId]
	if not skill then
		luaLogE(DescAuto[2]..skillId) -- [2]="技能表里面没有这个技能"
		--skill={
			--skillName="未知技能"
		--}
		return false

	end
	return skill
end

--根据id获取主动技能
function SkillConfiger.getActiveBySkillId(skillId)
	local skill=DynamicConfigData.t_activeSkill[skillId]
	if not skill then
		print(4,"技能表里面没有这个主动技能")
		skill={
			flyEffect = "houyi_stack"--默认赋值一个飞行技能
		}

	end
	return skill
end

-- 获取精灵的技能
function SkillConfiger.getElfSkillById(skillId,elfId,skinId)
	if DynamicConfigData.t_ElfSkinSkill 
	and DynamicConfigData.t_ElfSkinSkill[elfId]
	and DynamicConfigData.t_ElfSkinSkill[elfId][skinId] 
	and DynamicConfigData.t_ElfSkinSkill[elfId][skinId][skillId] then
		skillId = DynamicConfigData.t_ElfSkinSkill[elfId][skinId][skillId].skinSkillId
	end

	local skill 	= DynamicConfigData.t_skill[skillId]
	if not skill then
		luaLogE(DescAuto[3].. skillId) -- [3]="精灵技能表里面没有这个技能"
		return false
	end
	return skill
end

--技能效果
function SkillConfiger.getSkillEffectById(effectId)
	return DynamicConfigData.t_skill[effectId]
end


return SkillConfiger
