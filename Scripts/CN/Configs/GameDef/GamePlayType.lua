--玩法类型的集合，或者也可以是某个功能点的统一称呼。
--功能点的地方，限制和副本小功能都共用这个了都用这个了
--GamePlayType不做映射检测了。这是个特例。
--数据库缩写尽量不要超过7个字母
return {
--Agent（0-999）
	--常规功能限制，从1-200吧，200个功能够开发两年了。
	Murder 				= 1,
	[1]					= "murder",
	TimeRefresh 		= 2,
	Guild				= 5,			--公会
	[5]					= "guild",
	Title 				= 9, 		    --称号
	[9] 				= "title",
	Vip					= 11,			--vip
	Rank 				= 14,			--排行榜

	Rename              = 58,           --改名
	ActivePlayer  	 	= 59,			--前天活跃玩家
	[59] 				= "activePlayer",
	
	DailyActivity 		= 62,			--日常活跃度系统
	UpdateAnnouncement	= 68,			--更新公告
	[68]				= "ua",		
	Achieve				= 69,			--成就
	

	Setting 			= 81,			--设置
	[81] 				= "setting",

	FirstRecharge       = 89,           --首充
	[89]                = "firstRe",    

	Authenticate  		= 98,			--实名认证
	[98] 				= "auth",

	DailyConsume        = 114,           --每日累消
	[114]               = "dailyConsume",

	WorldServer			= 117,			--世界服

	Activity 			= 123,			--活动
	[123]				= "activity",
	GPOpenMail			= 124,			--功能开启邮件提示
	[124]				= "gpMail",
	
	BroadCast			= 142,			--广播
	[142]				= "broadCast",

	ChatIcon			= 151,			--聊天头像框
	ChatBubble			= 152,			--聊天气泡

	Task 				= 170,			--任务
	Relationship		= 184,			--好友服务

	Arena				= 185,			--竞技场
	[185]				= "Arena",

	GuideSetting		= 321,			--设置指引
	Friend 				= 322,			--好友

	--小玩法定义325-399
	GoldTree			= 325,			--摇钱树
	[325]				= "goldTree",
	DownloadReward		= 326,			--下载奖励
	[326]				= "downloadReward",
	HeadFrame			= 327,			--头像框
	[327]				= "headFrame",
	TimePush			= 328,			--定时推送
	[328]				= "timePush",
	TrainingCamp		= 329,			-- 训练营
	[329]				= "trainingCamp",
	HonorMedalWall		= 330,			-- 荣誉墙
	[330]				= "honorMedalWall",

	--500-599  公会玩法占用
	GuildDailyBoss  	= 500,			--公会日常BOSS
	GuildLimitBoss		= 501,			--公会限时BOSS
	GuildDivination		= 502,			--公会占卜
	GuildSkill			= 503,			--公会技能
	GuildPack			= 504,			--公会宝库
	--1000-1500 副本占用
	CoinCopy			= 1000,			--金币副本
	HeroChipCopy		= 1001,			--英雄碎片副本
	ExpCopy				= 1002,			--经验副本
	UpgradeMaterialCopy	= 1003,			--进阶材料副本
	HeroExp				= 1004,			--英雄经验副本
	SweepCopy			= 1005,			--符文副本
	GodArmsCopy			= 1006,			--秘武副本
	JewelryCopy			= 1007,			--首饰副本

	--1501-1700 卡牌占用 
	HeroLotteryRare			= 1501,			--卡牌高级召唤
	HeroLotteryNormal		= 1502,			--卡牌普通召唤
	HeroDecompose			= 1503,			--卡牌分解
	HeroReset				= 1504,			--卡牌重置
	HeroCombine 			= 1505,			--卡牌合成
	HeroStarLevelUp			= 1506,			--卡牌升星
	HeroLotteryNewPlayer	= 1507,			--新手召唤
	HeroLotteryUp			= 1508,			--up召唤
	HeroLotteryVIPSenior	= 1509,			--高级VIP召唤
	HeroLotteryFarplane		= 1510,			--异界召唤
	HeroLotteryUpHero		= 1511,			--UP英雄活动
	HeroPassive				= 1512,			--被动技能

	--1701-1750推图系统　　　			
	ChaptersBattle 				= 1701,--挑战关卡
	ChaptersFastBattle			= 1702,--快速挑战关卡
	ChaptersHangUp				= 1703,--挂机奖励
	--2000-2010 爬塔
	NormalTower					= 2000,	--普通塔
	[2000]						= "tower",  
	HumanTower 					= 2001, --人族塔
	[2001]						= "tower",
	OrcsTower					= 2002, --兽族塔
	[2002]						= "tower",
	MachineryTower 				= 2003, --机械塔
	[2003]						= "tower",
	TowerTopInfo 				= 2004,	--爬塔前三奖励
	FairyDemonTower 			= 2005, --仙魔塔
	[2005]						= "tower",

	--2101-2200 任务系统 --用于区分具体任务玩法类型
	TaskMain			= 2101,			--主线任务
	TaskDaily			= 2102,			--日常任务
	TaskWeekly			= 2103,			--周常任务
	TaskAchieve         = 2104,         --成就任务
	TaskWorldTeamArena  = 2105,         --组队竞技任务
	--2201 邮件
	Mail 			= 2201,--邮件
	--2210-2220 迷宫
	Maze 			= 2210,--迷宫

	DevilRoad 		= 2221,		--封魔之路
	--2300-2400 福利
	WelfareDailyLogin	= 2301,	 --日常登陆

	--2500-2600 活动
	ActivitySevenDay 	= 2501,	--七日活动
	ActivityEightDayLogin = 2502,--8日活动
	ActivityCollectStar = 2503,--推图星数收集
	ActivityPushChapter = 2504,--推图关数
	ActivityOnlineReward = 2505,--在线奖励
	ActivityPowerTurnTable = 2506, --转盘活动
	ActivityCollectThingsDaily = 2507, --集物活动(每日)
	ActivityCollectThingsHas = 2508,--集物活动(持久)
	ActivityFastUpLevel 	= 2509,	--快速升级活动
	ActivityTouchStoneGold  = 2510, --点石成金
	ActivitySaleGiftPack	= 2511, --直购礼包
	ActivityFirstCharge		= 2512, --首冲礼包
	ActivityAccChargeDay	= 2513, --每日累计充值豪礼
	ActivityAccCharge		= 2514, --累计充值豪礼
	ActivityAccChargeDayEx	= 2515, --每日累计充值豪礼
	ActivityBargainGift 	= 2516,	--超值礼包
	ActivityWarOrder        = 2517, --战令
	ActivitySevenDayRecord 	= 2518,	--新七日活动
	ActivityNewServerGift   = 2519, --新服专享礼包
	ActivityPreferentialkGift = 2520,--特惠礼包
	ActivityLimitGift 		= 2521, --限时礼包
	ActivityRiskDiary   	= 2522,	--冒险日志
	ActivityWeekLogin 				= 2523,		-- 每周签到
	ActivityDelegateContend 		= 2524,		-- 委托夺宝
	ActivityStarTempleExpedition 	= 2525,		-- 圣所探险
	ActivitySecordCharge			= 2526,		-- 充值豪礼
	ActivityEquipUpStar 			= 2527,		-- 装备竞换
	ActivityEquipMission			= 2528,		-- 装备目标
	ActivityFeatures				= 2529,		-- 特性觉醒  
	ActivityNewWeekCard				= 2530,		-- 黑金周卡  
	ActivityCollectMap				= 2531,		-- 集图夺宝  
	ActivityHeroCome				= 2532,		-- 英雄降临
	ActivityPrimaryTask				= 2533,		-- 新手任务

	ActivityGashapon				= 2534, --幸运扭蛋
	ActivityEveryDaySign			= 2535, --每日签到
	ActivityGashaponTask			= 2536, --扭蛋任务
	ActivityGashaponShop			= 2537, --扭蛋商店
	ActivityGashaponGift			= 2538, --扭蛋限时礼包

	ActivityElfCollection			= 2539, --精灵收集
	ActivityElfSummon				= 2540, --精灵召唤
	ActivityElfGift					= 2541, --精灵礼包
	
	ActivityNewHeroShop				= 2542, --新英雄活动商店
	ActivityNewHeroCopy				= 2543, --新英雄活动副本

	ActivityRuneMission				= 2544,	-- 符文目标
	ActivityRuneShop				= 2545,	-- 符文活动商城

	ActivityElfHis 					= 2546, --一番巡礼
	ActivityElfFinal 				= 2547, --最终赏
	ActivityElfTourShop				= 2548, --巡礼商店

	ActivityWantCharge				= 2549, --任意充值
	ActivityCustomLimitGift			= 2550, --定制礼包
	ActivityMonopoly 				= 2551, --大富翁精灵降临
	ActivityGroupBuyGift			= 2552, --团购礼包

	ActivityElfWarOrder				= 2553, --精灵战令

	ActivityShrinePray				= 2554, --神社祈福
	ActivityShrinePrayShop			= 2555, --祈福商店
	ActivityHeroTrialShop			= 2556, --探员试炼商店
	ActivityHeroTrialGift			= 2557, --探员试炼礼包
	ActivityHeroSummonShop 			= 2558,	--精英召唤限时商城
	ActivityBoundaryWarOrder 		= 2559, --临界战令

	ActivityGodsPray				= 2560, --神灵祈愿
	ActivityGodsPrayShop			= 2561, --神灵祈愿商店
	ActivityEveryDayLogin 			= 2562,	--每日登录活动

	ActivityCollectThingsShop		= 2563, --集物活动商店
	ActivityCollectWordsShop        = 2564, --集字活动商店
	ActivityCollectWords            = 2565, --集字活动
	ActivityServerGroupBuy          = 2566, --全服礼包

	ActivityMazeWarOrder            = 2567, --逆境迷宫战令
	ActivityEndlessRoadWarOrder     = 2568, --极地探索战令
	ActivityTrialShop               = 2569, --阵营试炼商城
	ActivityTrial                   = 2570, --阵营试炼
	[2570] = "ActivityTrial",
	ActivityHeroTrialPreferGift     = 2571,	--探员试炼特惠礼包
	ActivityTourPreferGift     		= 2572,	--巡礼特惠礼包
	ActivityGashaponPreferGift      = 2573,	--扭蛋特惠礼包
	ActivityShrinePrayPreferGift    = 2574,	--神社祈福特惠礼包
	ActivityHeroSummonShopDay    	= 2575,	--精英召唤每日限时商城
	ActivityHallowWarOrder     		= 2576, --圣器战令
	ActivityGodMarket 				= 2577, --神墟历险(跨服)
	[2577] = "ActivityGodMarket",
	ActivityHeroVote				= 2578, --人气探员票选
	ActivityHeroVoteShop			= 2579, --人气探员票选商店
	ActivityHeroVoteTask			= 2580, --人气探员票选任务
	ActivityHolidayBoss             = 2581, --节日活动boss
	ActivityHolidayExchange         = 2582, --节日活动兑换商城
	ActivityHolidayShop             = 2583, --节日活动商城
	ActivityElfFinalSecond 			= 2584, --最终赏2
	ActivitySmallElfWarOrder		= 2585, --小额精灵战令
	ActivityGodMarketShop 			= 2586, --神墟历险商店(跨服)
	ActivityFashionCharge 			= 2587, --时装点券充值购买

	ActivityLanternDraw				= 2587, --元宵抽奖活动
	ActivityLanternEveryDaySign		= 2588, --元宵每日签到
	ActivityLanternTask				= 2589, --元宵任务
	ActivityLanternShop				= 2590, --元宵商店
	ActivityLanternGift				= 2591, --元宵限时礼包
	ActivityLanternGuess			= 2592, --元宵猜谜

	ActivityNewHeroSummon			= 2593, --新英雄召唤祈愿活动
	ActivityNewHeroSummonShop		= 2594, --新英雄召唤购买商城
	ActivityNewHeroSummonExchange	= 2595, --新英雄召唤兑换商城

	ActivityNewYearShop 			= 2596,	--新年商城
	ActivityNewYearShopDay 			= 2597,	--新年每日商城
	ActivityNewYearExchange 		= 2598,	--新年兑换商城

	--2600-2610 远征
	EndlessRoad			= 2601,	--远征

	FairyLand 			= 2611, --秘境

	--3000-4000 背包道具使用
	Bag_MoneyItem		= 3001, --增加货币


	--公共玩法 4001 - 5000
	WorldArena = 4001,			--世界擂台赛
	[4001] = "WorldArena",
	TopChallenge = 4002,		--无尽试炼管理
	[4002] = "TopChallenge",
	GuildWorldBoss = 4003,		--公会跨服BOSS
	[4003] = "GuildWorldBoss",
	EvilMountain = 4004,		--魔灵山
	[4004] = "EvilMountain",
	WorldSkyPvp = 4005,			--天境赛世界擂台赛
	[4005] = "WorldSkyPvp",
	GuildPvp = 4006,			--公会联赛
	[4006] = "GuildPvp",
	GuildLeague = 4007,			--公会传奇赛(目前用于管理全区服公会总排名数据)
	[4007] = "GuildLeague",
	WorldTeamArena = 4008,      --组队竞技
	[4008] = "WorldTeamArena",
	GuildPvpRank = 4009,		--公会联赛全服排名数据服务
	[4009] = "GuildPvpRank",
	

	--图鉴 5001 - 5010
	HeroTotems 			= 5001, --图鉴
	HeroDetailed 		= 5002 ,--图鉴详情
	[5002] 				= "heroDetailed",

	--符文 5011 - 5020 --
	Rune 				= 5011,

	--委托任务 5011 - 5020
	DelegateTask 		= 5011,

	--职级任务 5021 - 5030
	DutyTask 			= 5021,

	--激活码 5031 - 5050
  	ActivationCode   	= 5031,
  	
  	--特权
  	Privilege 			= 5032,

  	--晨星1V1
  	PveStarTemple 		= 5033,

  	--高级竞技场5051 - 5100
  	HigherPvp 			= 5051,
  	[5051] 				= "HigherPvp",

  	--首饰 5101 - 5110
  	Jewelry 			= 5101,	

  	--月卡 5111 - 5115
  	MoonCard 			= 5111,
  	[5111] = "MoonCard",

  	--基金 5116 - 5120
  	Fund 				= 5116,

	--超级基金 5121
	SuperFund 			= 5121,

	--周卡 5122
	WeekCard 			= 5122,
	[5122] 				= "weekCard",

	GmOperation = 5123,
	[5123]				= "gmOperation",

	-- 每日礼包 5125
	DailyGift 			= 5125,

	-- 月购礼包 5126
	MoonGift 			= 5126,

	-- 登录就送 5127
	LoginToSend 		= 5127,
	[5127]				= "loginToSend",

	-- 积天豪礼 5128 	 
	AccumulativeDay 	= 5128,

	-- 开工福利 5129 	
	WorkingWelfare 		= 5129,

	DreamLand			= 5130,
	[5130]				= "DreamLand",

	-- 装备 	5131 		
	Equipment 			= 5131,
	--精灵 5132
	Elf 				= 5132,

	-- 圣器
	Hallow			 	= 5133, 
	[5133]				= "Hallow",
	--临界 5134
	Boundary 			= 5134,	
	[5134] 				= "Boundary",
	--找回
	Retrieve			= 5135,
	[5135] 				= "Retrieve",

	--天域pvp
	HorizonPvp 			= 5136,
	[5136] 				= "HorizonPvp",
	BattleRecord		= 5137,
	[5137]				= "battleRecord",

	DreamPvp			= 5138,
	[5138]				= "DreamPvp",

	HeroTrial			= 5139,		--探员试炼

	TaskRankReward  	= 5140,
	[5140]				= "taskRankReward",

	StarTemple 			=  5141,
	[5141]				= "StarTemple",

	Barrage 			= 5142,--弹幕
	[5142]				= "Barrage",

	CrownTitle			= 5143, -- 称号

	CrossArena 			= 5144,	--跨服竞技场
	[5144] 				= "CrossArena",
		
	Fashion 			= 5145,--时装皮肤
	[5145]				= "Fashion",

	HeroFetter			= 5146,	--羁绊
	[5146]				= "HeroFetter",

	CrossSuperMundane 	= 5147,--跨服超凡段位赛
	[5147] 				= "CrossSuperMundane",

	HeroChange			= 5148,	--探员转换
	[5148]				= "HeroChange",

	BloodAbyss			= 5149,	--幻魔之镜
	[5149]				= "BloodAbyss",

	GodArms 			= 5150, --秘武玩法

	TopArena 			= 5151,	--巅峰竞技
	[5151] 				= "TopArena",

	SkyLadder 			= 5152,	--跨服天梯赛
	[5152] 				= "SkyLadder",

	UniqueWeapon		= 5153,	--专武
	[5153]				= "UniqueWeapon",

	NewsBoard			= 5154, -- 事件播报
	[5154]				= "NewsBoard",

	SkyLadChampion 		= 5155,	--跨服天梯冠军赛
	[5155] 				= "SkyLadChampion",

	WorkTogether 		= 5156,	--协力大作战
	[5156] 				= "WorkTogether",

	PowerPlan			= 5157,	--异能计划
	[5157]				= "PowerPlan",

	HeroVoteAddBuff 	= 5158, --人气票选加Buff
	[5158] 				= "heroVoteAddBuff",

	festivalWish 		= 5159,	--节日寄语
	[5159] 				= "festivalWish",

	MergeServer 		= 5160, --合服
	[5160]				= "MergeServer",

	WeekPuzzle	 		= 5161, --周巡拼图
	[5161]				= "WeekPuzzle",
	
	CustomGift	 		= 5162, --定向推送礼
	[5162]				= "CustomGift",

	NewYear 			= 5163, --新年活动
	[5163]				= "NewYear",
}