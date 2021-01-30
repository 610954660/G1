-- RecordType.dfr
return {
	--需要注意, 如果p1,p2,p3这些参数存在不同, 目前对应配置的recordId必须配置成不一样

	AchievePoint				= 1,		--总成就点>=count
	Level						= 2,		--人物等级>=count
	HeroLevel					= 4,		--达到指定等级的英雄数量 count=英雄数量 p1=等级
	ArenaWin					= 5,		--竞技场赢指定次数, count=次数
	ArenaScore					= 6,		--竞技场积分达到指定值, count=分数
	AutoFightRes				= 7,		--挂机累积领取资源达到指定值 count=资源值 p1=资源类型, p2=资源ID
	HeroNumType					= 8,		--拥有的英雄种类达到指定数量 count=数量
	HeroNumStar					= 9,		--拥有满足指定星级的英雄数量 count=数量, p1=星级  --星级不一样, 进阶升星 recordId必须配置成不同数值
	CopyLevel					= 10,		--通关指定副本副本难度  count=难度等级, p1=玩法类型
	CopyCount					= 11,		--通关相关指定难度指定次数 count=次数  p1=玩法类型, p2=难度等级
	ChaptersCityId				= 12,		--通关关卡指定城市 count=次数  p1=城市id --实际逻辑是通关某个城市最后一个章节最后一个关卡次数
	ChaptersCityLevel 			= 13, 		--通关关卡指定城市章节 count=关卡章节, p1=城市id --策划需要显示为 x/x章节
	ChaptersCityLevelSeq 		= 14, 		--通关关卡指定城市章节序号 count=关卡序号, p1=城市id, p2=关卡章节 --策划需要显示为 x/x关卡序号

	JoinGamePlayType			= 15,		--参与指定玩法 count=次数, p1=副本玩法类型(竞技场, 爬塔, 其他副本)
	JoinHeroLottery				= 16,		--参与抽卡玩法 count=次数
	HeroLevelUp					= 17,		--卡牌升级 count=升级次数
	JoinFastAutoFight			= 18,		--快速挂机 count=次数
	GetAutoFightReward			= 19,		--领取挂机奖励 count=次数
	JoinDailyCopy				= 20,		--挑战日常副本 count=次数
	HeroStageLevelUp			= 21,		--英雄进阶  count=进阶次数
	ShopBugCount				= 22,		--商店购买  count=购买次数

	-- 
	Login						= 101,		--登陆游戏 count=次数
	MazeShopBuy					= 102,		--迷宫商店购买  count=购买次数 
	ArenaSort					= 103,		--竞技场排名 count=1  p1 = 名次
	EquipStroge					= 104,		--装备强化 count=件数 p1 = 级数
	Power						= 105,		--玩家战力 count>= 次数  p1= 战力
	AddFriend					= 106,		--添加好友 count>= 好友个数
	FriendSendGift				= 107,  	--好友送礼 count>= 次数
	JoinGuild					= 108,		--加入公会 count = 1
	GuildDonate					= 109,		--公会捐献 count >= 次数
	SceneAddStar				= 110,  	--关口获取星 count >= 星个数
	RaceTowerMop				= 112,  	--种族塔扫荡 层次
	GamePlayTypeLevel			= 114,		--玩法类型层数或等级	count=层数  p1=副本玩法类型(竞技场, 爬塔, 其他副本)
	FinishSecretEvent			= 115,		--秘境事件  count=次数
	HeroAddPoint				= 116, 		--英雄配点 	count=次数
	HeroLearnSkill				= 117,		--英雄替换技能 count=次数
	EquipReset					= 118,		--装备重铸 x 次数
	GuildSkillUp				= 119,		--公会技能升级
	WorldSpeek					= 120,		--世界频道发言
	HeroNumStarAdd				= 121,		--增加满足指定星级的英雄数量 count=数量, p1=星级  --星级不一样, 进阶升星 + 召唤升星 
	GuildBoss					= 122,		--挑战公会boss count = 次数
	MazeLayer					= 123,		--迷宫层数 count = 客户端显示 p1 对应迷宫id
	PassDailyCopy				= 124,		--通关日常副本 count=次数
	PassRaceTower				= 125,		--通关种族塔 count=次数
	HeroUpStar					= 126,		--英雄升星 count = 次数 p1 星级
	PassCopy					= 127,		--通关指定次数 count=次数  p1=玩法类型, p2>=难度等级

	HeroLotteryType 			= 128,		--招募类型 count = 次数  p1 = 类型 
	DelegateColor 				= 129,		--委托任务 count = 次数  p1 = 品质
	ActiveHeroSkill				= 130,		--激活卡牌技能 count = 次数
	AddEquipStar				= 131,		--装备强化 count=件数 p1 = 品质 p2 = 星数
	ChaptersPass				= 132,		--主线通关次数统计不重复 count=次数  主线
	MazeBattle 					= 133,		--迷宫挑战 count=次数
	FinishDelegateColor			= 134,		--领取完成委托 count=次数 p1 >= 品质 

	AcceptDelegateTask			= 135,		--接取委托任务	count=次数
	EquipmentUpgrade			= 136,		--提升装备,任意装备升星或重铸 count=次数
	SendFriendshipScore			= 137,		--赠送好友友情点, count=次数
	MoneyAmount					= 138,		--累计获得XX数量XX货币, count=数量, p1=货币code
	MazeLayerCount				= 139,		--击败迷宫指定层级次数, count=次数, p1=层级(困难也算作第三层)
	MazeLevelCount				= 140,		--通关指定难度迷宫, count=次数, p1=难度
	JoinEndlessRoad				= 141,		--参与极地探索,每轮活动只算1次, count=次数
	EndlessRoadLevelCount		= 142,		--通关极地探索第N关及以上M次, count=次数, p1=关卡等级
	FairyLandScrollCount		= 143,		--秘境使用卷轴N次, count=次数, p1=卷轴类型
	FairyLandLevel				= 144,		--秘境通关第N层, count=层级
	FairyLandAnyScrollCount		= 145,		--秘境使用任意类型卷轴N次, count=次数

	CreateName					= 146,		--创建名字
	ShopBuyItem					= 147,		--商店购买指定物品 count = 个数 p1 = 物品id
	RecvDayDutyReward			= 148, 		--领取每日职级 	count = 次数
	DutyUp						= 149,		--职级升级		count = 次数
	GetHeroWithStar				= 150,		--获得指定星级的英雄 count=数量, p1=星级 
	UpgradeHeroLevel			= 151,		--达到指定等级的英雄数量 count>=英雄数量 p1>=等级
	DelegateRefreshCount        = 152,      --刷新委托任务次数
	ShopTypeBuyCount            = 153,      --指定商城类型购买次数 count >=次数 p1=商城类型
	ShopTypeRefreshCount        = 154,      --指定商城类型刷新次数 count >=次数 p1=商城类型
	ShopTypeAnyRefreshCount     = 155,      --任意商城类型刷新次数 count >=次数

	ChaptersAuto 				= 156,		--主线通关层数 count >= 1 p1 >=关卡总序号
	TowerIndex					= 157,		--爬塔  count >= 层数 p1 = 玩法

	RecvTask					= 158,		--领取完成 任务 count = 次数 p1 == 玩法类型 p2 == 比较条件

	ElfAddNum					= 160,		--新获得精灵数量(召唤和合成获得, 包括重复获得分解成碎片的) count >= 数量
	ElfActivedNum				= 161,		--已激活的精灵数量 count >= 数量
	ElfStarNum					= 162,		--X只精灵达到X星及以上 count >= 数量, p1 >= 星级
	ElfStageNum					= 163,		--X只精灵达到X阶及以上 count >= 数量, p1 >= 品阶
	ElfSummonCount				= 164,		--精灵召唤次数 count >= 数量

	RuneGet						= 165,		--符文收集 count = 次数, p1 = 物品id
	RuneReset					= 166,		--符文重置 count = 次数

	RechargeAmount 				= 167,		--充值XXrmb  count=rmb
	CostMoneyAmount 			= 168,		--消费xx货币  count=数量, p1=货币code

	GodArmsLevel				= 169,		--秘武等级 count>=等级
	DreamLandLevel 				= 170,		--幻境层数 count>=  p1=1单人幻境 p1=2多人 
	DreamLandLevelAnd 			= 171,		--幻境层数 count>=   
	DreamLandLevelOr			= 172,		--幻境层数 count>=
	PowerTurnTableDraw 			= 173,		--抽装盘 count >= p1 = 1 普通 2 高级
	JoinActivityGamePlayType 	= 180,		--活动玩法参与次数 计数活动自己记录 count >= 次数 p1 = gamePlayType玩法
	WorldBattleStageAmount      = 181,      --世界擂台赛xxx模式累计进入x次xx强    p1 ==（4001：世界擂台赛竞技场 4005：世界擂台赛天境赛）p2 == 多少强 count >= 次数  eeg
	WorldBattleChampion         = 182,      --获得x次世界擂台赛xxx模式冠军  p1 ==（4001：世界擂台赛竞技场 4005：世界擂台赛天境赛）count >= 次 new_eg
	WorldBattleGuessAllRight    = 183,      --世界擂台赛xxx模式中竞猜全部正确  p1 ==（4001：世界擂台赛竞技场 4005：世界擂台赛天境赛) count >= 次 new_eg
	LearnPassiveSkill           = 184,      --累计学习x个xx属性   p1 == 特性的quality count >= 数量 new_eg
	BattleTotalHunt             = 185,      --单场战斗累计造成%点伤害 count >= 伤害 g
	HigherPvpWin				= 186,		--天境賽赢指定次数, count=次数 g
	HeroNumTypeStar             = 187,      --使x个x族探员达到x星  p1 == 种族  p2 == 星 count >= 个数eeg
	NewPower                    = 188,      ----玩家战力 count>= 战力

	PveStarTemple				= 189,		-- 星辰圣所 count>=次数，p1=0（不需要战胜，进入战斗即可），p1=1（需要战胜）
	PveStarTempleReset			= 190,		-- 星辰圣所使用胶南 count>=次数

	HallowPassLevel				= 191,  	-- 通关 p1 族副本 count 难度以上
	HallowPassCount				= 192, 		-- 通关 p1 族副本 p2 难度 count 次以上

	TrainingCampFinish			= 193,		-- 训练营任务通关

	--1001 模块自定义实现类型, 非通用类型
	--(目前只有任务系统3种任务类型生效)
	TaskAssembly				= 1001      --组合任务类型, 若干子任务完成触发此任务完成, p1=对应的subTask编号, p2p3服务器逻辑处理占用

}