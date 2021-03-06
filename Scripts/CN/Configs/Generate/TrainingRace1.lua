
--DynamicConfigData.FightConfig

return
{
	--我方英雄
	hero = {
		[1] = {
			id = 45001,--英雄ID
			pos = 122, --英雄位置
			hp = 26820,--初始血量
			level=100,
			hurt=30103,
			cure=0,
			beHurt=17568
		}},
	--敌方英雄
	enemy = {{{id = 55001, pos = 222,hp = 29103,level=150,hurt=17568,cure=0,beHurt=30103},}},
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
				text = {{[122] = "种族之间相互克制"}},
				skillid = 5500121,  --技能
				pos1 = 222,   --出手位置ID,
				pos2 = {122}, --受击对象ID  可以多个对象
				status = {2^2}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-7932},    --扣减血量，根据技能实际配几次

			},
		},
		
		--第二回合
		[2] = {

			[1] = {
				skillid = 4500122,  --技能
				pos1 = 122,   --出手位置ID,
				pos2 = {222}, --受击对象ID  可以多个对象
				status = {2^1}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-18230},    --扣减血量，根据技能实际配几次
			},
		},
		--第三回合
		[3] = {
			[1] = {
				skillid = 5500121,  --技能
				pos1 = 222,   --出手位置ID,
				pos2 = {122}, --受击对象ID  可以多个对象
				status = {2^2}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-7227},    --扣减血量，根据技能实际配几次

			},
			},
		--第四回合
		[4] = {

			[1] = {
				skillid = 4500131,  --技能
				pos1 = 122,   --出手位置ID,
				pos2 = {222}, --受击对象ID  可以多个对象
				status = {2^3}, --受击对象的状态  暴击，死亡，格挡。。。。
				subHp = {-21230},    --扣减血量，根据技能实际配几次
			},
			}

	}

}