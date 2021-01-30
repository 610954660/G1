
--DynamicConfigData.FightConfig

return
{
	--我方英雄
	hero = {
		[1] = {
			id = 35003,--英雄ID
			pos = 122, --英雄位置
			hp = 26820,--初始血量
			level=100,
			hurt=9620,
			cure=0,
			beHurt=36820
		}},
	--敌方英雄
	enemy = {{{id = 55001, pos = 222,hp = 29103,level=150,hurt=36820,cure=0,beHurt=9620},}},
	--回合开始播放剧情 并且暂停战斗  下标为第几回合
	speed=2,
	skip=false,
	background=100026,

	--回合数据
	round = {
		--第一回合
		[1] = {
			--第一次出手
			[1] = {
				skillid = 5500121,  --技能
				pos1 = 222,   --出手位置ID,
				pos2 = {122}, --受击对象ID  可以多个对象
				status = {2^2}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-17932},    --扣减血量，根据技能实际配几次

			},
		},
		
		--第二回合
		[2] = {

			[1] = {
				skillid = 3500311,  --技能
				pos1 = 122,   --出手位置ID,
				pos2 = {222}, --受击对象ID  可以多个对象
				status = {2^2}, --受击对象的状态  暴击，死亡，格挡。。。。
				hitBuff = {{id=222,buffId=3500301}}, --受击后增加buff
				subHp = {-6230},    --扣减血量，根据技能实际配几次
			},
		},
		--第三回合
		[3] = {
			[1] = {
				skillid = 5500131,  --技能
				pos1 = 222,   --出手位置ID,
				pos2 = {122}, --受击对象ID  可以多个对象
				status = {2^3}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-19227},    --扣减血量，根据技能实际配几次

			},
			}
	}

}