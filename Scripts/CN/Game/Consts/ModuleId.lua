--功能模块Id枚举类，需要策划配置相关的功能模块Id ，一一映射即可，如果单纯是前端所用id ，直接添加到最后，不冲突即可。
return {  
	mainWindow  = {id=0, view= "MainUIView"},   --主界面  
    Hero  =  {id=1, view= "CardBagView"},   --英雄
    Bag   =  {id=2, view= "BagWindow",args = {page=1}},   --背包
    Shop  =  {id=4, view= "ShopView"},   --商城
    Tower =  {id=5, view= "PataView",args={ type = 6 , activeType= 2000 , towerType=1,rankType=2,space = -15,showCount = 6,moveCount = 4 }},  --爬塔
	
	
    Arena =  {id=6, view= "ArenaPerformView"},   --竞技场
    Copy  =  {id=7, view= "MaterialCopyView"},   --副本
    Mail  =  {id=8, view= "EmailView"},   --邮件
    Friend = {id=9, view= "FriendBaseView"},  --好友
    TowerRace = {id=10, view= "PataChooseView"}, --种族塔    
    Chat  = {id=11, view= "ChatView"},   --聊天
    Guild  = {id=12, view= "GuildMallView"},   --公会
    GetCard  = {id=13, view= "GetCardsView"},   --召唤
    GetSpeCards  = {id=83, view= "GetSpeCardsView"},   --特异功能
    GetTyChange  = {id=84, view= "GetTyChangeView"},   --特异转换
	UpStart  = {id=14, view= "CardInfoView",args = {page=2}},   --升星
	Equipment  = {id=15, view= "CardInfoView",args = {page=1}},   --模块
	RankMain  = {id=16, view= "RankMainView"},   --排行榜
	CardTalent  = {id=17, view= "CardInfoView",args = {page=3}},   --特性
	Forge  = {id=18, view= "EquipmentforgeView",args = {page="EquipmentRecastView"}},   --重铸
	Alternate  = {id=19, view= ""},   --替补
	CardDecompose  = {id=20, view= "CardDetailsDecompose"},   --英雄分解
	PushMap  = {id=21, view= "PushMapCheckPointView"},   --侦察
    Maze  = {id=22, view= "MazeView"},   --迷宫
    --PushMap  = {id=23, view= "PushMapCheckPointView"},   --推图
	--SevenDay  = {id=24, view= "SevenDayActView"},   --七日目标（弃用）
	NewSevenDay = {id=81, view= "SevenDayActView"}, -- 新七日活动
	FairyLand  = {id=25, view= "FairyLandView"},   --秘境
	DailySign  = {id=26, view = "LoginAwardView",args = {page="DailySignView"}},   --签到
	ActivationCode  = {id=46, view= "ActivationCodeView"},   --激活码
	GrowthFund  = {id=74, view= "LoginAwardView",args = {page="GrowthFundView"}}, --成长基金
	Recharge  = {id=27, view= "RechargeBaseView"},   --充值
	AccumulativeDay = {id=86, view = "AccumulativeDayActivityView"}, -- 积天豪礼
	FestivalWish = {id=295, view = "ActivityFrame8View",args = {page="TwistSpFestivalView"}}, -- 春节寄语
	--战斗  
	BattleSpeed  = {id=28, view= ""},   --战斗加速
	BattleSkip  = {id=29, view= ""}, --战斗跳过
	EightDayActivity  = {id=30, view= "ActivityFrameView",args = {page=1}}, --八日登陆
	BattleSkip  = {id=31, view= ""}, --战斗跳过
	StarCollectReward  = {id=32, view= ""}, --集星奖励
	PushMapReward  = {id=33, view= ""}, --推图奖励
	OnlineGiftBag  = {id=34, view= "ActivityFrameView",args = {page=4}}, --在线礼包
	
	
	Tactical  = {id=35, view= "TacticalView"},   --阵法
	EndlessRoad  = {id=36, view= "ExpeditionView"},   --远征
	WorldChallengeMainView  = {id=37, view= "WorldChallengeMainView"},--世界擂台赛
	
	HeroPalace  = {id=38, view= "HeroPalaceView"},--英雄谷

	TurnTable = {id = 39, view = "TurnTableView"}, -- 聚能寻宝
	Handbook = {id = 41, view = "HandbookView"}, -- 图鉴
	-- QuesSurveyView = {id = 44, view = "QuesSurveyView"}, -- 问卷调查
	RuneSystem = {id = 45, view = "RuneSystemView"}, -- 符文系统

	ActivationCode = {id = 46, view = "LoginAwardView",args = {page="ActivationCodeView"}}, -- 符文系统
	GoldTree = {id = 47, view = "GoldTreeView"}, -- 摇钱树
	Delegate = {id = 48, view = "DelegateView"}, -- 委托任务
	ServiceCommitView = {id = 49, view = "ServiceCommitView"}, -- 客服
	
	CardInfo = {id = 52, view = "CardInfoView"}, -- 英雄详情
	--游戏内公告
	GameNoticeView = {id = 43, view = "GameNoticeView"},

	-- EveryDailyTask = {id = 187, view = "TaskView",args = {page="EveryDailyView"}}, -- 日常系统
	-- WeekDailyTask = {id = 186, view = "TaskView",args = {page="WeekDailyView"}}, -- 周常系统
	-- Task = {id = 3, view = "TaskView",args = {page="DailyTaskView"}}, -- 主线系统
	Task = {id = 3, view = "TaskView"}, -- 主线系统
	Retrieve = {id = 184, view = "TaskView",args = {page="RetrieveView"}}, -- 资源找回

	Duty = {id = 51, view = "DutyView"}, -- 职级系统
	PushMapOnhookReward = {id = 134, view = "PushMapOnhookRewardView"}, -- 快速挂机
	
	Help = {id = 53, view = "HelpSystemView"}, -- 帮助系统
	EquipmentforgeView= {id = 54, view= "EquipmentforgeView"}, -- 锻造坊
	--战斗三倍加速
	BattleSpeed3  = {id=55, view= ""},   -- 战斗加速

	MoneyBuyGift = {id = 56, view = "MoneyBuyGiftView"}, -- 直购礼包
	FirstCharge  = {id=60, view= "FirstChargeView"}, --首充礼包

	Vip = {id= 57, view="RechargeBaseView", args = {page="VipView"}}, -- vip界面

	AixinCards = {id = 61, view= "GetAixinCardsView"}, -- 积分招募

	SevenDayAct = {id=24,view="SevenDayActView"},
	AdventureDiary = {id=121,view="AdventureDiaryView"},
	TeyiGetCard = {id=62,view="GetCardsView",args = {page=3}},
	EverDayAccumulatedView  = {id=63,view="EverDayAccumulatedView"},--每日累计充值
	AccumulatedAddMoneyView = {id=64,view="AccumulatedAddMoneyView"},--累计充值
	AccumulatedAddMoneyView1 = {id=261,view="AccumulatedAddMoneyView1"},--节日累充
	AnyPrepaidphoneView  = {id=190,view="AnyPrepaidphoneView"},--每日累计充值	
	ohterOneEveryAddMoneyView = {id=64,view="ohterOneEveryAddMoneyView"},--合集每日充值
	PriviligeGiftView= {id = 58, view="RechargeBaseView", args = {page="PriviligeGiftView"}},

	HeroGiftView  = {id=65, view= "HeroGiftView"}, -- 送礼
	PremiumGiftView  = {id=66, view= "PremiumGiftView"}, -- 超值礼包
	CollectThingView = {id=71, view= "ActivityFrameView",args = {page=8}}, -- 集物兑换活动
	
	Alternate_Front = {id=67, view= ""}, --前排替补
	Alternate_Back  = {id=68, view= ""}, --后排替补
	EquipmentDecompose  = {id=69, view= "EquipmentUpstarView",args = {page=1}}, --装备分解
	Herobook  = {id=70, view= "HerobookView"}, --英雄档案室
	SecretWeapon  = {id=76, view= "SecretWeaponsMainView"}, --秘武
	EndlessTrial = {id =75 ,view="EndlessTrialMainView"}, -- 无尽试炼
	EndlessTrialSecond = {id =123 ,view="EndlessTrialSecondView"}, -- 无尽试炼

	--MonthlyCard= {id = 73, view = "MonthlyCardView"}, -- 月卡
	MonthlyCard  = {id=73, view = "LoginAwardView",args = {page="MonthlyCardView"}},   -- 月卡
	WarmakesActive = {id = 77, view = "WarmakesActiveView"}, -- 战令
	WarmakesElfActive = {id = 200, view = "WarmakesElfActiveView"}, -- 精灵战令
	WarmakesCriticalActive = {id = 228, view = "WarmakesCriticalActiveView"}, -- 临界战令
	WarmakesPolaarActive = {id = 267, view = "WarmakesPolaarActiveView"}, -- 极地战令
	WarmakesMazeActive = {id = 244, view = "WarmakesMazeActiveView"}, -- 迷宫战令
	WarmakesHallowsActive = {id = 270, view = "WarmakesHallowsActiveView"}, -- 迷宫战令	
	WarmakesSmallElfActive = {id = 297, view = "WarmakesSmallElfActiveView"}, -- 小额精灵战令
	PveStarTemple = {id = 72,view = "PveStarTempleMainView"},--星辰圣所
	HigherPvP = {id = 79, view = "HigherPvPView"}, -- 高阶竞技场
	SuperFund 	  = {id = 80,view = "SuperFundView"}, 	-- 超值基金
	WeekCard 	= {id = 82,view ="WeekCardView"}, 	-- 周卡
	NewWeekCard = {id= 142,view="NewWeekCardView"}, -- 新周卡
	UpgradeActivity = {id = 50, view = "UpgradeActivityView"}, -- 限时升级
	LoginSend 	= {id = 87,view ="LoginSendView"}, 	-- 登录就送
	GuildFissure 	= {id = 85,view ="GuildFissureView"}, 	-- 次元裂缝
	DailyGiftBag = {id = 88,view = "RechargeBaseView",args = {page="DailyGiftBagView"}}, 	-- 每日礼包
	
	
	Bag_Equip = {id = 89,view ="BagWindow",args = {page=1}}, 	-- 背包-装备
	Bag_Spec = {id = 90,view ="BagWindow",args = {page=2}}, 		-- 背包-特殊
	Bag_Split = {id = 91,view ="BagWindow",args = {page=3}}, 	-- 背包-碎片
	Bag_Jwerly = {id = 92,view ="BagWindow",args = {page=4}}, 	-- 背包-饰品
	
	GetCard_Normal = {id = 93,view ="GetCardsView"}, 	-- 招募-普通
	GetCard_Senior = {id = 94,view ="GetCardsView",args = {page=2}}, 	-- 招募-高级
	GetCard_Friend = {id = 95,view ="GetCardsView",args = {page=4}}, 	-- 招募-友情
	GetCard_alienLand = {id = 138,view ="GetCardsView",args = {page=6}}, 	-- 招募-仙魔
	GetCard_diffWorld = {id = 93,view ="GetCardsView",args = {page=7}}, 	-- 异界
	
	Forge_starUp = {id = 96,view ="EquipmentforgeView"}, 	-- 锻造坊-升星
	Forge_Decompose = {id = 97,view ="EquipmentUpstarView"}, 	-- 锻造坊-分解
	--Forge_Recast = {id = 98,view ="EquipmentforgeView",args = {page=2}}, 	-- 锻造坊-重铸  与18重复了
	Forge_Compose = {id = 99,view ="EquipmentforgeView",args = {page="JewelryMergeView"}}, 	-- 锻造坊-合成
	Forge_Wash = {id = 100,view ="EquipmentforgeView",args = {page="JewelryRebuildView"}}, 	-- 锻造坊-洗炼

	
	
	Copy_Gold = {id = 101,view ="MaterialCopyView"}, 	-- 副本-金币
	Copy_Aura = {id = 102,view ="MaterialCopyView",args = {page=1}}, 	-- 副本-灵气
	Copy_Equip = {id = 103,view ="MaterialCopyView",args = {page=2}}, 	-- 副本-装备
	Copy_Hero = {id = 104,view ="MaterialCopyView",args = {page=3}}, 	-- 副本-英雄
	Copy_Rune = {id = 105,view ="MaterialCopyView",args = {page=4}}, 	-- 副本-符文
	Copy_Screct = {id = 106,view ="MaterialCopyView",args = {page=5}}, 	-- 副本-秘武
	Copy_Jewelry = {id = 107,view ="MaterialCopyView",args = {page=6}}, -- 副本-饰品

	WeeklyGiftBag = {id = 108,view="ActivityFrameView",args = {page=24}}, -- 每周礼包
	MonthlyGiftBag = {id = 109,view="ActivityFrameView",args = {page=25}}, -- 每月礼包
	NewServerGift = {id = 110, view = "NewServerGiftView"}, -- 新服专享礼包
	Guild_Skill = {id = 111, view = "GuildskillsView"}, -- 公会科技
	WorkingWelfare = {id = 112, view = "WorkingWelfareView"}, -- 开工福利
	TimeSummon 	= {id = 116,view ="ActivityFrame2View",args={page=33}}, -- 限时召唤
	MainSubBtn = {id = 117, view = "MainSubBtnView"}, -- 试炼
	DelegateActivity = {id = 120, view = "DelegateActivityView"}, -- 委托夺宝
	SanctuaryAdventure 	= {id = 122,view ="ActivityFrame2View",args={page=32}}, -- 圣所探险
	LStarAwakening 	= {id = 119,view ="ActivityFrame2View",args={page=35}}, -- 升星觉醒
	-- UpGetCardActivity = {id =124 ,view = "ActivityFrame2View",args={page="GetCardsYjActivityView"}}, -- 精英召唤
	WeeklySignIn = {id = 115,view = "ActivityFrame2View",args={page=30}},-- 每周签到
	DailyPlay = {id = 118,view = "MainSubBtnView"}, -- 日常玩法
	Elves_Attribute	= {id = 126,view = "ElvesSystemBaseView"}, 	-- 精灵-属性
	Elves_Upgrade 	= {id = 127,view = "ElvesSystemBaseView",args = {page=5}}, -- 精灵-升级
	Elves_Upstar 	= {id = 128,view = "ElvesSystemBaseView",args = {page=1}}, -- 精灵-升星
	Elves_Summon 	= {id = 129,view = "ElvesSystemBaseView",args = {page=2}}, -- 精灵-召唤
	Elves_Bag 		= {id = 130,view = "ElvesSystemBaseView",args = {page=3}}, -- 精灵-背包
	Elves_NewPlan 	= {id = 198,view = "ElvesSystemBaseView",args = {page=4}}, -- 精灵-方案 新    
	
	----后续添加

	Shop_limit = {id = 131,view = "ShopView",args={shopType=2}},-- 每周签到
	Voidland = {id = 132, view = "VoidlandView"}, -- 虚空幻境
	GuildBossSweep = {id = 135, view = "GuildBossSweepView"}, -- 狩猎场扫荡
	FirstChargeLuxuryGift  = {id=136, view= "FirstChargeLuxuryGiftView"}, --首充豪礼
	AwakeningCharacteristics  = {id=137, view= "AwakeningCharacteristicsView"}, --特性觉醒
	EquipTarget = {id = 140,view = "ActivityFrame4View",args = {page=40}}, 	-- 装备目标
	EquipUpStar = {id = 139,view = "ActivityFrame4View", args = {page=39}}, -- 装备升星
	EquipGift = {id = 152, view= "ActivityFrame4View", args = {page = 43}}, -- 装备礼包
	RelicCopy= {id = 153,view= "MainSubBtnView",args = {page="RelicCopyView"},}, -- 圣器副本
	
	Shop_Guild = {id = 154, view= "ShopView", args={shopType = 4}}, -- 公会商店
	Shop_Expedition = {id = 155, view= "ShopView", args={shopType = 6}}, -- 极地商店
	Shop_Maze = {id = 156, view= "ShopView", args={shopType = 7}}, -- 迷宫商店
	Shop_FairyLand = {id = 157, view= "ShopView",args={shopType = 12}}, -- 秘境商店
	ResetHero_low = {id = 158, view= "ResetHeroView",args = {page=1}}, -- 探员回退-初级
	ResetHero_high = {id = 159, view= "ResetHeroView",args = {page=2}}, -- 探员回退-高级
	
	Shop_hero = {id = 160, view= "ShopView",args = {shopType=3}}, -- 探员商城
	Shop_arena = {id = 161, view= "ShopView",args = {shopType=5}}, -- 竞技商城
	Shop_elite = {id = 162, view= "ShopView",args = {shopType=8}}, -- 精英商店
	Shop_highPvp = {id = 163, view= "ShopView",args = {shopType=13}}, -- 天境商店
	Shop_Talent = {id = 125, view = "ShopView", args={shopType = 11}}, -- 特性商店
	Shop_noble 	= {id = 217,view="ShopView",args={shopType = 18}}, -- 贵族商店
	Shop_CrossTeamPVP 	= {id = 221,view="ShopView",args={shopType = 20}}, -- 跨服组队商店
	Shop_fashion = {id = 230,view = "ShopView",args={shopType = 21}}, -- 时装商店(探员皮肤商店)
	Shop_crossArean = {id = 221,view = "ShopView",args={shopType = 20}}, -- 跨服竞技场 声望商店
	Shop_crossLadders = {id = 248,view = "ShopView",args={shopType = 22}}, -- 跨服天梯赛 天梯商店
	Shop_strideShop = {id = 260,view = "ShopView",args={shopType = GameDef.ShopType.TopArena}}, -- 巅峰商店
	Shop_ExtraordShop = {id = 276,view = "ShopView",args={shopType = GameDef.ShopType.CrossSuperMundane}}, -- 超凡商店
	Shop_crossLaddersChamp = {id = 293,view = "ShopView",args={shopType = GameDef.ShopType.SkyLadChampion}}, -- 天冠商店

	GuildMLS = {id = 133,view = "GuildMLSMainView"}, --魔灵山
	HallowSys = {id = 141, view = "HallowBaseSeatView"}, -- 圣器
	UpGetCardActivity = {id =164 ,view = "ActivityFrame2View",args={page="GetCardsYjActivityView"}}, -- 精英召唤
	NieYinComing  = {id=165, view= "NieYinComingView"}, --聂隐降临
	OpenTakeWelfareTask  = {id=166, view= "OpenTakeWelfareTaskView"}, --开服福利
	PushMapTargetReward  = {id=167, view= "PushMapTargetRewardView"}, --推图通关奖励
	EmblemView = {id = 151, view = "EmblemEquipView"}, -- 纹章英雄装备界面
	
	TwistEggTask = {id = 170,view = "ActivityFrame2View",args = {page=49}}, 	-- 扭蛋任务
	TwistEggShop = {id = 171,view = "ActivityFrame2View",args = {page=50}}, 	-- 扭蛋商城
	TwistEggLimitGift = {id = 172,view = "ActivityFrame2View",args = {page=51}}, -- 扭蛋礼包（限时商城）
	TwistEggView = {id = 168,view = "ActivityFrame2View",args = {page=47}}, -- 扭蛋
	TwistEggSignView = {id = 169,view = "ActivityFrame2View",args = {page=48}}, -- 扭蛋签到
	TwistRuneTaskView = {id = 182,view = "ActivityFrame2View",args = {page=1}}, -- 符文活动
	TwistRegimentView = {id = 193,view = "ActivityFrame2View",args = {page=1}}, --天降神兵 
	
	RuneActiveView = {id = 185,view = "ActivityFrame2View",args = {page=1}}, -- 符文礼包
	
	HeroShopView = {id = 181,view = "ActivityFrame2View",args = {page="HeroShopView"}}, -- 英雄活动商店
	HeroBossActivityView = {id = 180,view = "ActivityFrame2View",args = {page="HeroBossActivityView"}}, -- 英雄活动
	TwistEggLimitGiftView = {id = 172,view = "ActivityFrame2View",args = {page="TwistEggLimitGiftView"}},--扭蛋礼包(限时商城)
	ElvestoCollectActive  = {id=173, view= "ActivityFrame5View",args = {page="ElvestoCollectActiveView"}}, --精灵收集
	ElvesCalledActive  = {id=174, view= "ActivityFrame5View",args = {page="ElvesCalledActiveView"}}, --精灵召唤
	ElvesmalActivel  = {id=175, view= "ActivityFrame5View",args = {page="ElvesmalActivelView"}}, --精灵商城
	CrystalUpgrade  = {id=176, view= "CrystalCombineView",args = {page=""}}, --提升石合成
	ArenaShop  = {id=177, view= "ArenaShopView"}, --竞技场门票购买
	HigherPvPTicket  = {id=178, view= "HigherPvPTicketView"}, --天境赛门票购买
	MainUI  = {id=179, view= ""}, --去到主界面
	BoundaryMapView = {id = 149,view = "BoundaryMapView"}, --临界之旅
	RuneResetView = {id = 186,view = "RuneSystemView",args = {page="RuneResetView"}}, -- 符文重置
	ActFinalRewardView = {id = 188,view = "ActivityFrame2View",args = {page="ActFinalRewardView"}}, 
	ActATourGiftView = {id = 187,view = "ActivityFrame2View",args = {page="ActATourGiftView"}},
	ActATourLimitShop = {id = 189,view = "ActivityFrame2View",args = {page = 61}}, -- 精灵限时商城(巡礼商店)
	DetectiveAgencyView = {id = 196,view = "DetectiveAgencyView",args = {page = "DetectiveAgencyView"}}, -- 侦探社)
	CustomizedGiftsView = {id = 191,view = "ActivityFrame2View",args = {page="CustomizedGiftsView"}},--定制礼包
	GroupBuyGift  = {id=192,view="GroupBuyGiftView"},--团购礼包

	Limitedmarket = {id = 113,view="ActivityFrame7View",args = {page=28}}, 	-- 限时商城
	DreamMasterPvp = {id = 202,view="DreamMasterPvpView"}, 	-- 梦主争夺
	--DreamMasterPvpMain = {id = 202,view="DreamMasterPvpMainView"} 	-- 梦主争夺
	DetectiveTrial = {id = 203,view = "DetectiveTrialView"}, -- 探员试炼
	ExtraordinarylevelMain = {id = 243,view = "ExtraordinarylevelMainView"}, -- 超凡段位赛
	
	GuildLeague = {id = 204,view = "GuildLeagueMainView"}, -- 公会联赛
	GuildHourse = {id = 218,view = "GuildHourseView"}, --公会金库
	ArenaVideo = {id = 205,view = "VideoLibraryView"}, --录像库
	MoonAweTemple = {id= 207,view = "MainSubBtn2View",args = {page="MoonAweTempleView"}}, -- 月慑神殿
	TaskAchievement = {id= 208,view = "TaskView",args = {page=4}}, -- 成就任务

	CrossPVP = {id= 214,view = "CrossPVPView"}, -- 天域试炼
	CrossTeamPVP = {id= 215,view = "CrossTeamPVPMainView"}, -- 组队竞技
	StridePVP = {id= 239,view = "StrideMainView"}, -- 巅峰竞技
	SecretWeaponsRefined = {id= 216,view = "SecretWeaponsRefinedView"}, -- 秘武精练
	NoBilityWeekGift = {id= 220,view = "NoBilityWeekGiftView"}, -- 贵族专享周礼包
	Training = {id= 223,view = "TrainingCampView"}, -- 训练营
	CrossArena = {id= 222,view = "CrossArenaPVPView"}, -- 跨服竞技
	TurnTableShop = {id= 224,view = "ShopView",args={shopType=19}}, -- 时空商店
	ActGodsPrayView = {id= 226,view = "ActivityFrame2View",args = {page="ActGodsPrayView"}}, -- 时空商店
	GodsLotteryShopView = {id= 227,view = "GodsLotteryShopView",args = {page=1}}, -- 祈愿商店
	ActYjShopView = {id= 219,view = "ActivityFrame2View",args = {page=1}}, -- 召唤商城
	ActYjShopView = {id= 219,view = "ActivityFrame2View",args = {page=1}}, -- 召唤商城
	Fashion = {id= 229,view = "FashionView"}, -- 探员时装
	CardResetthe = {id= 232,view = "CardResettheView"}, -- 探员转换
	FestivalGift = {id= 233,view = "FestivalGiftView"}, -- 圣诞登录礼物
	CollectThingShop = {id= 234,view = "ActivityFrame2View",args = {page=87}}, -- 集物兑换商店
	CollectWordsActivityShop = {id= 237,view = "ActivityFrame8View",args = {page=89}}, -- 集字商店
	CollectWordsActivity = {id= 236,view = "ActivityFrame8View",args = {page=90}}, -- 集字活动
	CardStarUp20 = {id = 238, view= "CardInfoView",args = {page=2}},
	----后续添加
	FullsrGiftView = {id= 235,view = "ActivityFrame2View"}, -- 全服活动
	-- StrideSeverView = {id= 222,view = "MainSubBtnView",args = {page="StrideSeverView"}}, -- 跨服竞技场
	CrossLadders = {id= 246,view = "CrossLaddersMainView"}, -- 跨服天梯赛
	HelpFunctionManual = {id = 247,view = "HelpSystemView",args = {page=7}}, -- 功能手册
	MainSubBtn2 = {id = 250, view = "MainSubBtn2View"}, -- 铳梦竞技
	DevilRoad = {id = 249, view = "DevilRoadView"}, -- 铳梦竞技
	EmblemBag = {id = 251, view = "EmblemBagView"}, -- 纹章背包
	HeroDormitory = {id = 252, view = "HeroDormitoryView"}, -- 探员宿舍
	UniqueWeapon = {id = 253, view = "UniqueWeaponTipsView"}, -- 专武
	SpecialgiftBagShrinePray = {id = 254, view = "SpecialgiftBagShrinePrayView"}, -- 神社祈福特惠礼包
	SpecialgiftBagGashapon = {id = 255, view = "SpecialgiftBagGashaponView"}, -- 扭蛋特惠礼包
	SpecialgiftBagTour = {id = 256, view = "SpecialgiftBagTourView"}, -- 巡礼特惠礼包
	SpecialgiftBagHeroTrial = {id = 257, view = "SpecialgiftBagHeroTrialView"}, -- 探员试炼特惠礼包
	FashionLoginTips = {id = 269, view = "FashionLoginTipsView"}, -- 时装登录弹窗
	GuildLeagueOfLegends = {id = 274, view = "GuildLeagueMainView", {page = "GLLegendsMainView"}}, -- 公会传奇赛
	BatteSpeedPlugin={id=275, view= "BatteSpeedView"},   --战斗加速付费插件
	CrossLaddersChamp = {id = 277,view = "CrossLaddersChampMainView"}, -- 跨服天梯冠军赛
	PopularVote = {id = 271,view = "PopularVoteEmptyView"}, -- 人气票选
	PopularVoteTask = {id = 272,view = "PopularVoteTaskView"}, -- 人气票选任务
	PopularVoteShop = {id = 273,view = "PopularVoteShopView"}, -- 人气票选商城
	CooperationActivitieMain  = {id=279, view= "ActivityFrame9View",args = {page="CooperationActivitieMainView"}}, --领地协战
	CooperationActivitieCheating  = {id=280, view= "ActivityFrame9View",args = {page="CooperationActivitieMainView"}}, --支援助力
	CooperationActivitieShop  = {id=281, view= "ActivityFrame9View",args = {page="CooperationActivitieShopView"}}, --物资兑换
	CooperationActivitieLimit  = {id=282, view= "ActivityFrame9View",args = {page="CooperationActivitieLimitView"}}, --协力商城
	EventBrocast = {id = 290,view = "EventBrocastView"}, -- 事件播报
	PowerPlant={id = 296,view = "PowerPlanView"}, -- 异能计划
	ActCommonBossView = {id = 289,view = "ActCommonBossView"}, -- 世界通用boss
	SurveyQuestion = {id = 304,view = "ActivityFrame1View",args = {page="SurveyQuestionView"}}, -- 问卷调查
	DressRecharge = {id = 306, view = "RechargeBaseView", args= {page = "DressRechargeView"}}, -- 时装纽扣充值
	NewYearActivity = {id = 305, view = "NewYearActivityMainView"}, -- 新年活动
	-- 元宵活动
	LanternDraw = {id = 298,view = "ActivityFrame2View",args = {page=GameDef.ActivityType.LanternDraw}},
	LanternSign = {id = 299,view = "ActivityFrame2View",args = {page=GameDef.ActivityType.LanternEveryDaySign}},
	LanternTask = {id = 300,view = "ActivityFrame2View",args = {page=GameDef.ActivityType.LanternTask}},
	LanternLimitGift = {id = 301,view = "ActivityFrame2View",args = {page=GameDef.ActivityType.LanternGift}},
	LanternShop = {id = 302,view = "ActivityFrame2View",args = {page=GameDef.ActivityType.LanternShop}},
	LanternGuess = {id = 303,view = "ActivityFrame2View",args = {page=GameDef.ActivityType.LanternGuess}},

	--赠礼
	ChatGift = {id = 307, view = "ChatGiftView"}, --赠礼 
}