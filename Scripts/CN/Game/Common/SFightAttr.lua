local SFightAttr = {}
local allAttrs = {	
	hp = true,						--生命 							具体值
	hpMax = true,					--最大生命						具体值
	attack = true, 					--攻击 							具体值
	defense = true, 				--防御							具体值
	crack = true, 					--破甲							具体值
	hpRecover = true, 				--生命恢复						具体值
	moveSpeed = true, 				--移动速度						具体值
	internalDamage = true, 			--内功伤害						具体值
	internalDamageAddPct = true, 	--内功伤害加成					百分比
	internalInjury = true,			--内功减伤						具体值
	internalInjuryAddPct = true, 	--内功减伤加成 					百分比
	hurtBack = true, 				--伤害反弹						具体值
	lifeSteal = true, 				--生命偷取						具体值
	levelHpMaxAdd = true,			--等级加成最大生命(每3级增加)  	具体值
	levelAttackAdd = true,			--等级加成攻击(每3级增加)  		具体值
	levelDefenseAdd = true,			--等级加成防御(每3级增加)  		具体值
	levelCrackAdd = true,			--等级加成破甲(每3级增加)  		具体值
	levelHpRecoverAdd = true,		--等级加成生命恢复(每1级增加)  	具体值
	eachLevelAttackAdd = true,		--等级加成攻击(每1级增加)  		具体值
	
	hpRecoverAddPct = true, 		--生命恢复加成					百分比
	hpMaxRecoverPct = true,			--生命恢复(最大值比例)			百分比
	hurtAdditionPct = true,			--伤害加成						百分比
	hurtResistancePct = true, 		--伤害抵抗						百分比
	critRatePct = true, 			--暴击率						百分比
	toughPct = true,				--坚韧率							百分比
	critEffectPct = true, 			--暴击效果						百分比
	critInjuryPct = true,			--暴伤抵抗						百分比
	blockPct = true,				--格挡 							百分比
	wreckPct = true,				--破击 							百分比
	blockEffectPct = true, 			--格挡效果						百分比
	blockPenetratePct = true,		--格挡穿透						百分比
	skillAdditionPct = true,		--技能加成						百分比
	skillResistancePct = true, 		--技能抵抗						百分比
	dodgePct = true,				--闪避加成						百分比
	hitPct = true,					--命中加成						百分比
	fatalBlowPct = true, 			--致命一击						百分比
	fatalResistancePct = true, 		--致命抵抗						百分比
	attackSpeedPct = true,			--攻击速度						百分比
	controlResistancePct = true, 	--控制抵抗						百分比
	hpMaxAddPct = true,				--全系统生命最大值加成			百分比
	attackAddPct = true, 			--全系统攻击加成				百分比
	crackAddPct = true,				--全系统破甲加成				百分比
	defenseAddPct = true,			--全系统防御加成				百分比
	subSysHpMaxAddPct = true,		--基础系统生命最大值加成		百分比
	subSysAttackAddPct = true,		--基础系统攻击加成				百分比
	subSysCrackAddPct = true,		--基础系统破甲加成				百分比
	subSysDefenseAddPct = true,		--基础系统防御加成				百分比
	killMobRecoverHpPct = true,		--击杀怪物恢复生命				百分比
	coinDropRatePct = true,			--金币掉落率加成				百分比
	petHurtAddPct = true,			--宠物伤害加成					百分比
	expRatioAddPct = true,			--打怪经验加成比例				百分比
	weaponAttackAddPct = true,		--武器攻击加成					百分比
	weaponCrackAddPct = true,		--武器破甲加成					百分比
	equipStrenAddPct = true,		--强化加成						百分比
	armorHpMaxAddPct = true,		--防具生命加成					百分比
	armorDefenseAddPct = true,		--防具防御加成					百分比
	decorationAttackAddPct = true,	--饰品攻击加成					百分比
	decorationCrackAddPct = true,	--饰品破甲加成					百分比
	finalHurtAddPct = true, 		--伤害直接加成					百分比
	hurtBackPct = true,				--伤害反弹						百分比
	hurtReducePct = true,			--伤害减免						百分比
	hurtReduceToPlayerPct = true, 	--对玩家伤害减免				百分比
	hurtAddToWildBossPct = true,	--对野外boss伤害加成			百分比
	hurtAddToBossPct = true,		--对boss伤害加成				百分比
	moveSpeedAddPct = true,			--移动速度加成					百分比
	smart = true,					--睿智							具体值
	small = true,					--玲珑							具体值
	steady = true,					--稳重							具体值
	tameless = true,				--桀骜							具体值
	passionate = true,				--多情							具体值
	finalFixHurt = true,			--最终额外固伤					具体值
	lifeStealPVP = true,			--生命偷取(仅PVP有效)			具体值
	addBattle = true, 				--技能增加的战力
	skillCDPct = true, 				--技能冷却 
	addEquipBasePct = true,			--增加装备的基础属性
	levelCrackAdd = true,			--等级加成破甲(每3级增加)
	hpRecoverAddPct = true, 		--生命恢复加成
	moveSpeedAddPct = true, 		--移动速度加成
	internalDamageAddPct = true,	--内功伤害加成
	internalInjuryAddPct = true,	--内功减伤加成
	level50HurtAddPct = true,		--等级加成伤害(每50级增加)
	addBattlePct = true, 			--技能增加的百分比战力
	dodge = true,					--闪避							具体值
	hit = true,						--命中							具体值
	finalDodgePct = true,			--最终闪避						百分比
	finalHitPct = true,				--最终命中						百分比
	critHurt = true,				--暴击伤害						具体值
	critInjury = true,				--暴击减伤						具体值
	comboRate = true,				--连击率 						具体值
	holySpiritAttack = true,		--圣灵攻击						具体值
	holySpiritDefense = true,		--圣灵防御						具体值
	roleSpellDefense = true,		--人物法术防御
	tough = true,					--坚韧
	crit = true,					--暴击
	fatalBlowAddHurtPct = true,		--致命一击增伤
	fatalBlowInjuryPct = true,		--致命一击减伤
	pvpHurtAddPct = true,			--PVP伤害加成
	pvpHurtDelPct = true,			--PVP伤害减少
	psychic = true,
	physical = true,
	power = true,
	agile = true,
	roleSpellDefense = true,
}

-- local function getAllKeys(attr1,attr2)
-- 	local keys = {}
-- 	for k,_ in pairs(attr1) do
-- 		keys[k] = true
-- 	end

-- 	for k,_ in pairs(attr2) do
-- 		keys[k] = true
-- 	end
-- 	return keys
-- end

local mt = {
	--相加
	__add = function (attr1,attr2)
		local tb = {}
		for k,_ in pairs(allAttrs) do
			tb[k] = (attr1[k] or 0) + (attr2[k] or 0)
		end
		return new(tb, true)
	end,

	--相减
	__sub = function (attr1,attr2)
		local tb = {}
		for k,_ in pairs(allAttrs) do
			local val = (attr1[k] or 0) - (attr2[k] or 0)
			if val < 0 then
				val = 0
			end
			tb[k] = val
		end
		return new(tb, true)
	end,

	__newindex = function (t,k,v)
		if not allAttrs[k] then
			error("SFightAttr no member named %s",k)
		else
			if v < 0 then 
				v = 0 
			end
			rawset(t,k,v)
		end
	end
}


function SFightAttr.new(src, notCopy)
	local tb
	src = src or {}

	if notCopy then
		tb = src
	else
		tb = {}
		for k,_ in pairs(allAttrs) do
			tb[k] = src[k] or 0
		end
	end
	setmetatable(tb,mt)
	return tb
end
