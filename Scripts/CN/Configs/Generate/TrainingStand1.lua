
--DynamicConfigData.FightConfig

return
{
	--我方英雄
	hero = {
		[1] = {
			id = 55008, --英雄ID
			pos = 123, --英雄位置
			hp = 23494,--初始血量
			level=100,
			hurt=19250,
			cure=0,
			beHurt=0
		},
		[2] = {id = 55009, pos = 112,hp = 22354,level=100,hurt=6340,cure=0,beHurt=15583}},
	--敌方英雄
	enemy = {{{id = 54001, pos = 222,hp = 25537,level=120,hurt=6583,cure=0,beHurt=25537},}},
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
				text = {{[122] = "移动站位胜算更大"}},
				skillid = 5400121,  --技能
				pos1 = 222,   --出手位置ID,
				pos2 = {112}, --受击对象ID  可以多个对象
				status = {2^2}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-6383},    --扣减血量，根据技能实际配几次

			},
		},
		
		--第二回合
		[2] = {

			[1] = {
				skillid = 5500821,  --技能
				pos1 = 123,   --出手位置ID,
				pos2 = {222}, --受击对象ID  可以多个对象
				status = {2^1}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-11250},    --扣减血量，根据技能实际配几次
			},
			[2] = {

				skillid = 5500911,  --技能
				pos1 = 112,   --出手位置ID,
				pos2 = {222}, --受击对象ID  可以多个对象
				status = {2^2}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-5583},    --扣减血量，根据技能实际配几次

			},
		},
		--第三回合
		[3] = {
			[1] = {
				skillid = 5400131,  --技能
				pos1 = 222,   --出手位置ID,
				pos2 = {112}, --受击对象ID  可以多个对象
				status = {2^1}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-9227},    --扣减血量，根据技能实际配几次

			},
			},
		--第四回合
		[4] = {
			[1] = {
				skillid = 5500831,  --技能
				pos1 = 123,   --出手位置ID,
				pos2 = {222}, --受击对象ID  可以多个对象
				status = {2^3}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-19227},    --扣减血量，根据技能实际配几次

			},
			}

	}

}