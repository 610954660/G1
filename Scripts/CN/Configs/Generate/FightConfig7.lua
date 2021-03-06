
--DynamicConfigData.FightConfig

return
{
	--我方英雄
	hero = {
		[1] = {
			id = 34002, --英雄ID
			pos = 122, --英雄位置
			hp = 18240,--初始血量
			level=100,
			hurt=7251,
			cure=0,
			beHurt=18240
		},
		[2] = {id = 15004, pos = 112,hp = 26138,level=100,hurt=15560,cure=0,beHurt=26138}},
	--敌方英雄
	enemy = {{{id = 25002, pos = 212,hp = 25537,level=120,hurt=44378,cure=0,beHurt=23537},}},
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
				skillid = 2500211,  --技能
				pos1 = 212,   --出手位置ID,
				pos2 = {112}, --受击对象ID  可以多个对象
				status = {2^2}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-9021},    --扣减血量，根据技能实际配几次

			},
		},
		
		--第二回合
		[2] = {

			[1] = {
				skillid = 1500411,  --技能
				pos1 = 112,   --出手位置ID,
				pos2 = {212}, --受击对象ID  可以多个对象
				status = {2^2}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-5165},    --扣减血量，根据技能实际配几次
			},
			[2] = {

				skillid = 3400221,  --技能
				pos1 = 122,   --出手位置ID,
				pos2 = {212}, --受击对象ID  可以多个对象
				status = {2^2}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-5411},    --扣减血量，根据技能实际配几次

			},
		},
		--第三回合
		[3] = {
			[1] = {
				skillid = 2500231,  --技能
				pos1 = 212,   --出手位置ID,
				pos2 = {112}, --受击对象ID  可以多个对象
				status = {2^3}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-18240},    --扣减血量，根据技能实际配几次

			},
			},
		--第四回合
		[4] = {
			[1] = {
				skillid = 3400221,  --技能
				pos1 = 122,   --出手位置ID,
				pos2 = {212}, --受击对象ID  可以多个对象
				status = {2^1}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-9227},    --扣减血量，根据技能实际配几次

			},
		},
		--第五回合
		[5] = {
			[1] = {
				skillid = 2500211,  --技能
				pos1 = 212,   --出手位置ID,
				pos2 = {122}, --受击对象ID  可以多个对象
				status = {2^3}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-18418},    --扣减血量，根据技能实际配几次

			},
		}

	}

}