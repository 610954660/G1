return {
	--基础属性
	hp                  = 1,            --气血
	attack              = 2,            --物攻
	defense             = 3,            --物防
	magic               = 4,            --法攻
	magicDefense        = 5,            --法防
	speed               = 6,            --速度
    
	--高级属性
	hit                 = 101,          --物理命中
	magicHit            = 102,          --法术命中
	dodge               = 103,          --物理躲闪
	magicDodge          = 104,          --法术躲闪
	crit                = 105,          --物理暴击
	magicCrit           = 106,          --法术暴击
	critResist          = 107,          --抗物理暴击
	magicCritResist     = 108,          --抗法术暴击
	critEffect          = 109,          --物理暴伤比例
	magicCritEffect     = 110,          --法术暴伤比例
	controlHit          = 111,          --控制命中
	controlResist       = 112,          --控制抵抗
	damageAdd           = 113,          --物伤加成
	magicDamageAdd      = 114,          --法伤加成
	damageDec           = 115,          --物伤减免
	magicDamageDec      = 116,          --法伤减免
	cureAdd             = 117,          --治疗加成
	recoverAdd          = 118,          --受疗加成

	--战斗属性
	attackPercent       = 201,          --物理攻击百分比
	defensePercent      = 202,          --物理防御百分比
	magicAttackPercent  = 203,          --法术攻击百分比
	magicDefensePercent = 204,          --法术防御百分比
	extraAttack         = 205,          --额外物理攻击
	extraDefense        = 206,          --额外物理防御
	extraMagicAttack    = 207,          --额外法术攻击
	extraMagicDefense   = 208,          --额外法术防御
	rage                = 209,          --怒气值
	shield              = 210,          --护盾值
	recoverDec          = 211,          --受疗减免
	doubleHitRate       = 212,          --物理连击概率
	doubleHitDamage     = 213,          --物理连击伤害衰减
	doubleHitBuffRate   = 214,          --物理连击buff概率衰减
	magicDoubleHitRate       = 215,     --法术连击概率
	magicDoubleHitDamage     = 216,     --法术连击伤害衰减
	magicDoubleHitBuffRate   = 217,     --法术连击buff概率衰减
	godBlessRate		= 218,			--神佑概率
	godBlessEffect		= 219,			--神佑回复血量
	godBlessCount		= 220,			--神佑次数限制
	hurtBackRate		= 221,			--物理反伤概率
	hurtBackEffect		= 222,			--物理反伤效果
	magicHurtBackRate	= 223,			--法术反伤概率
	magicHurtBackEffect	= 224,			--法术反伤效果
	suckEffect			= 225,			--物理吸血效果
	magicSuckEffect		= 226,			--法术吸血效果
	pass				= 227,			--物理破防属性
	magicPass			= 228,			--法术破防属性
	rageSpeed			= 229,			--获取怒气速度加成
	hpMax 				= 230,			--最大生命值
	hpPercent			= 231, 			--生命百分比
	categoryRestraint	= 232,			--种族克制
	speedPercent		= 233,			--速度百分比
	damageAddEx 		= 234,			--伤害加成（对物伤和法伤都起作用）
	damageDecEx			= 235,			--伤害减免（对物伤和法伤都起作用）
	critEx				= 236,			--暴击（物理和法术都起作用）
	suckEffectEx 		= 237,			--吸血（物理和法术都起作用）
	doubleHitRateEx 	= 238,			--连击（物理和法术都起作用）
	sputteringPercent 	= 239,			--溅射百分比
	shieldAdd			= 240,			--护盾加成
	combatRestraintAdd  = 241,			--战力压制伤害加成
	combatRestraintDesc = 242,			--战力压制伤害减免
	attackPercentEx     = 243,          --攻击百分比(物理和法术都起作用)
	recoverDecResist	= 244,			--受疗减免抵抗
	critEffectDec       = 245,          --暴伤减免
	doubleHitResist 	= 246,			--连击抵抗
	doubleHitHurt		= 247,			--连击伤害
}

