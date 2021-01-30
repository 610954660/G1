--这个是用来做skilleffect的时候做表现的。按位来记录
return {
	Miss = 2^0,			--闪避
	Crit = 2^1,			--暴击
	Normal = 2^2,		--普通攻击
	Dead = 2^3,			--死亡
	Revived = 2^4,		--复活
	OnlyBuff = 2^5,		--加buff
	Sputtering = 2^6,	--溅射
	Passed = 2^7,		--传递
	OnlyBuffEx = 2^8,	--加buff2
	HurtBlock = 2^9,	--格挡
	Reincarnation = 2^10, --转生轮回
	ResistDead = 2^11, 	--抵挡死亡
	RageResistHurt = 2^12, --怒气抵挡伤害
	LockHp = 2^13,		--锁血
	Summon = 2^14, 		--召唤
	GodBless = 2^15,	--神佑
}
