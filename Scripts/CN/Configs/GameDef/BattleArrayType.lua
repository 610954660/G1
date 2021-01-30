return {
	Normal				= 1,	--通用
	ArenaDef			= 2,	--竞技场防守
	ArenaAck			= 3,	--竞技场攻击
	Chapters 			= 4,	--推图
	Copy 				= 5,	--日常副本
	Tower 				= 6,	--普通塔
	HumanTower			= 7,	--人族塔
	OrcsTower 			= 8,	--兽族塔
	MachineryTower		= 9,	--机械塔
	GuildDailyBoss 		= 10,	--公会日常BOSS
	GuildLimitBoss		= 11,	--公会限时BOSS
	Maze 				= 12,	--迷宫
	FairyLand			= 13,	--秘境
	EndlessRoad			= 14,	--远征
	WorldArena			= 15,	--世界擂台赛阵容
	FairyDemonTower 	= 16,	--仙魔塔
	EvilMountain		= 17,	--魔灵山 
	PveStarTemple 		= 18,	--晨星
	DreamLandSingle		= 19,	--幻境单人模式 --战斗信息
	DreamLandMultiple	= 20,	--幻境全体模式
	DreamLandPost		= 21,	--幻境雇佣发布阵容
	DreamLandSingleEx 	= 22,	--幻境单人模式 --记录信息
	FriendPK			= 23,	--好友，实际用竞技场
	Boundary 			= 24,	--临界
	NewHeroCopy			= 25,   --新英雄活动副本战斗
	Monopoly			= 26,   --大富翁活动战斗
	DreamPvp			= 27,	--梦境pvp
	HeroTrial			= 28,	--探员试炼
	StarTemple 			= 29,	--星河神殿 	
	EvilMountainTwo		= 30,	--魔灵山类型2
	BloodAbyss			= 31,	--幻墨之境
	DevilRoad 			= 32,	--封魔之路
	WorkTogether 		= 33,	--协力大作战
	PowerPlan			= 34,	--异能计划
	GodMarket 			= 35,	--神墟(跨服)
	NewYear 			= 36,	--新年活动


	-- 圣器每个副本一套阵容50 - 60 
	HallowFairy			= 51,	--圣器仙族副本
	HallowDemon			= 52,	--圣器魔族副本
	HallowOrcs			= 53,	--圣器兽族副本
	HallowHuman			= 54,	--圣器人族副本
	HallowMachinery		= 55,	--圣器械族副本

	--战斗阵容
	GuildPvpDef			= 56,	--公会联赛防守阵容
	GuildPvpAttack		= 57,	--公会联赛进攻阵容
	
	--临界阵容
	BoundaryAssassin 	= 58, 	--刺客路
	BoundaryStriker 	= 59, 	--射手路
	BoundaryWarrior 	= 60, 	--战士路
	BoundaryMage 		= 61, 	--法师路
	--公会跨服BOSS阵容(策划要求每个BOSS一套阵容, boss类型以后会扩展, 现在预留20个)
	GuildWorldBossNumOne = 101,		--公会跨服BOSS 1号BOSS
	GuildWorldBossNumTwo = 102,		--公会跨服BOSS 2号BOSS
	GuildWorldBossNumThree = 103,	--公会跨服BOSS 3号BOSS

	--无尽试炼
	TopChallengeCommon	= 121,		--无尽试炼, 综合试炼
	TopChallengeHuman	= 122,		--无尽试炼, 人族试炼
	TopChallengeOrc		= 123,		--无尽试炼, 兽族试炼
	TopChallengeMachine	= 124,		--无尽试炼, 械族试炼
	TopChallengeFairy	= 125,		--无尽试炼, 仙魔试炼


	HigherPvpAckOne		= 1000,	--高阶竞技场 1v1攻击阵容 
	HigherPvpAckThree	= 1001,	--高阶竞技场 3v3攻击阵容 
	HigherPvpAckSix		= 1002,	--高阶竞技场 6v6攻击阵容 
	HigherPvpDefOne		= 2000,	--高阶竞技场 1v1防守阵容 
	HigherPvpDefThree	= 2001,	--高阶竞技场 3v3防守阵容 
	HigherPvpDefSix		= 2002,	--高阶竞技场 6v6防守阵容

	GuildLeagueOne		= 2011, -- 公会传奇赛队伍1
	GuildLeagueTwo		= 2012, -- 公会传奇赛队伍2
	GuildLeagueThree	= 2013, -- 公会传奇赛队伍3

	--天境赛世界擂台赛 防守阵容
	WorldSkyPvpDefOne 		= 3001,		--天境赛世界擂台赛 1V1防守阵容
	WorldSkyPvpDefThree 	= 3002,		--天境赛世界擂台赛 1V1防守阵容
	WorldSkyPvpDefSix 		= 3003,		--天境赛世界擂台赛 1V1防守阵容

	--天域赛PVP
	HorizonPvpAckOne		= 3011,	--天域赛PVP 1v1攻击阵容 
	HorizonPvpAckThree		= 3012,	--天域赛PVP 3v3攻击阵容 
	HorizonPvpAckSix		= 3013,	--天域赛PVP 6v6攻击阵容 
	HorizonPvpDefOne		= 3014,	--天域赛PVP 1v1防守阵容 
	HorizonPvpDefThree		= 3015,	--天域赛PVP 3v3防守阵容 
	HorizonPvpDefSix		= 3016,	--天域赛PVP 6v6防守阵容

	--跨服竞技场
	CrossArenaAckOne		= 3031,	--跨服竞技场 攻击队伍1
	CrossArenaAckTwo		= 3032,	--跨服竞技场 攻击队伍2
	CrossArenaAckThree		= 3033,	--跨服竞技场 攻击队伍3
	CrossArenaDefOne		= 3034,	--跨服竞技场 防守队伍1
	CrossArenaDefTwo		= 3035,	--跨服竞技场 防守队伍2
	CrossArenaDefThree		= 3036,	--跨服竞技场 防守队伍3
	
	--跨服超凡段位赛
	CrossSuperMundaneAckFirst	= 3041,--跨服超凡段位赛 攻击队伍1
	CrossSuperMundaneAckTwo 	= 3042,--跨服超凡段位赛 攻击队伍2
	CrossSuperMundaneDefFirst	= 3043,--跨服超凡段位赛 防守队伍1
	CrossSuperMundaneDefTwo 	= 3044,--跨服超凡段位赛 防守队伍2
	
	--组队竞技
	WorldTeamArena       = 4000,  --组队竞技阵容（攻击防守共用）

	--巅峰竞技
	TopArenaAckOne		= 4006,	--巅峰竞技 攻击队伍1
	TopArenaAckTwo		= 4007,	--巅峰竞技 攻击队伍2
	TopArenaAckThree	= 4008,	--巅峰竞技 攻击队伍3
	TopArenaAckOneBak	= 4009,	--巅峰竞技 攻击队伍1生效阵容
	TopArenaAckTwoBak	= 4010,	--巅峰竞技 攻击队伍2生效阵容
	TopArenaAckThreeBak	= 4011,	--巅峰竞技 攻击队伍3生效阵容
	TopArenaAckOneNext	= 4012,	--巅峰竞技 攻击队伍1次日生效阵容
	TopArenaAckTwoNext	= 4013,	--巅峰竞技 攻击队伍2次日生效阵容
	TopArenaAckThreeNext = 4014, --巅峰竞技 攻击队伍3次日生效阵容
	
	-- 跨服天梯赛
	SkyLadderAck 		= 4015, -- 攻击队伍
	SkyLadderDef		= 4016, -- 防守队伍

	--阵营试炼
	Trail           = 4017, --阵营试炼阵容（攻击防守共用）
	
	-- 跨服天梯冠军赛
	SkyLadChampion 		= 4018, -- 攻击防守共用

	-- 节日活动boss
	HolidayBoss         = 4019,
}