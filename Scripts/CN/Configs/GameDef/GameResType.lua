--游戏资源类型。对应的策划配置的数据应该是长成这样的。{type = 1,code = 0,amount = 3}  相当于经验加3
--这个以后用来做游戏资源的增加减少的统一数据格式，主要是对外，比如配活动奖励数据可以用这个，来表达，配限制消耗也可以用这个来表达
--关于消耗优先使用绑定：默认情况是所有物品优先使用绑定 比如配 {type = 3, code = 40130001, amount = 1} 和 {type = 3, code = 40131001, amount = 1} 是一
--样的 都是表示消耗唐门通行证 有绑定优先消耗绑定 (统一都配绑定的code吧) 特殊情况是{type = 2, code = 2, amount = 1, notUseBackup = 1}
--这里配了 notUseBackup 表示只能消耗元宝 不能用绑定元宝代替
return {
	Exp = 1,				--经验
	Money = 2,				--金币，code就是货币类型
	Item = 3,				--物品，code就是itemCode
	Hero = 4,               --卡牌英雄, code是HeroConfig的heroId
	VipExp = 5,				--VIP经验
	Elf = 6, 				--精灵
}