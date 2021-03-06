
--DynamicConfigData.FightConfig
--增益buff失败选择1：腾蛇和妮月
return
{
	--我方英雄
	hero = {
		[1] = {
			id = 35002, --英雄ID
			pos = 112, --英雄位置
			hp = 18520,--初始血量
			level=100,
			hurt=0,
			cure=0,
			beHurt=0
		},
		[2] = {
			id = 25001, --英雄ID
			pos = 122, --英雄位置
			hp = 18520,--初始血量
			level=100,
			hurt=0,
			cure=0,
			beHurt=0
		}},
	--敌方英雄
	enemy = {{{id = 45007, pos = 212,hp = 18520,level=150,hurt=0,cure=0,beHurt=0},}},
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
				skillid = 4500723,  --技能
				pos1 = 212,   --出手位置ID,
				pos2 = {112}, --受击对象ID  可以多个对象
				status = {2^2}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-11112},    --扣减血量，根据技能实际配几次

			},
		},
		
		--第二回合
		[2] = {

			[1] = {
				skillid = 2500123,  --技能
				pos1 = 122,   --出手位置ID,
				pos2 = {212}, --受击对象ID  可以多个对象
				status = {2^2}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-3704},    --扣减血量，根据技能实际配几次
			},
		},
		--第三回合
		[3] = {
			[1] = {
				skillid = 3500223,  --技能
				pos1 = 112,   --出手位置ID,
				pos2 = {212}, --受击对象ID  可以多个对象
				status = {2^2}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-9260},    --扣减血量，根据技能实际配几次

			},
			},
		--第四回合
		[4] = {
			[1] = {
				skillid = 4500723,  --技能
				pos1 = 212,   --出手位置ID,
				pos2 = {112}, --受击对象ID  可以多个对象
				status = {2^3}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-11112},    --扣减血量，根据技能实际配几次

			},
			},
		--第五回合
		[5] = {
			[1] = {
				skillid = 2500123,  --技能
				pos1 = 122,   --出手位置ID,
				pos2 = {212}, --受击对象ID  可以多个对象
				status = {2^2}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-3704},    --扣减血量，根据技能实际配几次

			},
			},
		--第六回合
		[6] = {
			[1] = {
				skillid = 4500733,  --技能
				pos1 = 212,   --出手位置ID,
				pos2 = {122}, --受击对象ID  可以多个对象
				status = {2^3}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-18520},    --扣减血量，根据技能实际配几次

			},
			},


	}

}