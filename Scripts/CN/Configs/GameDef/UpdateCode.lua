
return {
	--这个是用于后台查询消耗和增加的具体来源的，要具体到某个功能  如xx功能领取奖励   进入xx副本等等
	--scene 1-1000
	ModuleOpen_Mail = 900,						--功能开放邮件推送

	-- 测试接口 1001-1100
	Test_Panel = 1001,							-- 测试面板指令(内网用)

	--任务系统 1101 - 1200
	Task_GetTaskReward = 1101,					-- 领取任务奖励
	Task_ActiveScoreReward = 1102,			-- 任务活跃度奖励

	--背包 1201-1300
	Bag_UseItem = 1205,							-- 使用物品
	Bag_ExchangeEquip = 1206,					-- 穿卸装备
	Bag_ItemDecompose = 1209,					-- 物品分解
	Bag_Arrange	= 1212,							-- 背包整理
	Bag_Sell =1213,                             -- 出售物品
	Bag_HangUpItem = 1214,						-- 使用挂机获取道具物品
	Bag_ItemOver = 1215,						-- 背包物品过期


	--商城
	Shop_BuyItem 						= 1301, 	--购买
	Shop_RestLimit						= 1303,		--限购刷新
	Shop_RestPreferential  				= 1304,		--特惠刷新
	Shop_Limits 						= 1305,		--限购商城
	Shop_Preferential 					= 1306,		--特惠商城
	Shop_Hero							= 1307,		--英雄商城
	Shop_Guild							= 1308,		--公会商城
	Shop_CollectActivity				= 1309,		--集物活动商城
	Shop_Arena							= 1310,		--竞技商店
	Shop_EndlessRoad					= 1311,		--远征商店
	Shop_Maze							= 1312,		--迷宫商店
	Shop_Daily							= 1313,		--精英币商店
	Shop_Special						= 1314,		--特异商店
	Shop_Gift 							= 1315,		--礼包商店
	Shop_Test 							= 1316,		--测试商店
	Shop_Character 						= 1317,		--特性商店
	Shop_SecretArea 					= 1318,		--秘境商店
	Shop_HighArena 						= 1319,		--高阶竞技商店
	Shop_Tactical 						= 1320,		--阵法商店
	Shop_Boundary						= 1321,		--临界商店
	Shop_HorizonPvp 					= 1322,		--天域商店
	Shop_Noble 							= 1323,		--贵族商店
	Shop_TimeGather 					= 1324,		--时空聚集商城
	Shop_WorldTeamArena                 = 1325,     --组队竞技商城
	Shop_Fashion           		        = 1326,     --时装商店
	Shop_CrossArena           		    = 1327,     --跨服竞技场商店
	Shop_SkyLadder 						= 1328,     --跨服天梯赛商店
	Shop_TopArena						= 1329,		--巅峰竞技商店
	Shop_CrossSuperMundane 				= 1330,		--跨服超凡商店
	Shop_SkyLadChampion					= 1331,		--天梯冠军赛商店
	--邮件 
	Mail_GetItem = 1401, 						-- 邮件提取物品
	Mail_NewPlayer= 1402,						-- 9377新手邮件

	--玩家奖励
	Player_InitReward = 1450,					-- 新号奖励

	--公会 1451-1600
	Guild_CreateGuild = 1501, 					-- 创建公会 
	Guild_GuildRename = 1502,					-- 公会改名
	Guild_ChallengeGuildBoss = 1536,			-- 挑战公会BOSS
	Guild_GuildBossEndReward = 1537,			-- 公会BOSS结算奖励
	Guild_SkillLevelUp = 1538,					-- 公会技能升级
	Guild_SkillReset = 1539,					-- 公会技能重置
	Guild_DivinationReward = 1540,				-- 公会占卜奖励
	Guild_PurchaseWorldBossChallenge = 1541,	-- 购买公会跨服BOSS挑战次数
	Guild_WorldBossRankLevelReward = 1542,		-- 公会跨服BOSS段位奖励

	Guild_PackPutInCost 		= 1543,			--公会背包放入消耗
	Guild_PackPutInAdd 			= 1544,			--公会背包放入奖励
	Guild_PackTackOutCost		= 1545,			--公会背包取出消耗
	Guild_PackTackOutAdd		= 1546,			--公会背包取出奖励

	--后台操作1801 - 2000
	GM_Recharge = 1801,							--充值
	GM_Operation = 1802,						--后台操作
	GM_ClearBag = 1003,							--gm清理背包

	--副本4101-4500
	Copy_EnterCopy = 4105,						--进入副本
	Copy_EndCopy = 4106,						--副本结算
	Copy_SweepCopy = 4107,						--副本扫荡
	Copy_EnterTower = 4108,						--进入爬塔
	Copy_EndTower = 4109,						--爬塔结算
	Copy_SweepTower = 4110,						--爬塔扫荡
	Copy_TowerTopReward = 4111,					--爬塔前三奖励
	Copy_TowerBigReward = 4112,					--爬塔大奖

	--福利 4961 - 5000 
	Welfare_DailyLoginReward	 	= 4964, --登陆奖励
	Welfare_DailyLoginBack	 		= 4965, --登陆奖励返回限时购买钻石

	--limit 6050-6100
	Limit_TopUp = 6051,							--购买limit次数

	--改名 7291 - 7300
	Rename_OneselfRename    = 7291,              --自己改名消耗

	--推图关卡 8491 - 8500
	Chapter_Battle = 8491,    --战斗推图
	Chapter_FastBattle = 8492, --快速推图
	Chapter_HangUpReward = 8493, --挂机收益
	Chapter_PointStar = 8494,--通关星数奖励
	Chapter_TargetReward 	=8495, --通关奖励

	--竞技场 8501 - 8510
	Arena_WinReward = 8501,				--竞技场胜利奖励
	Arena_DailyReward = 8502,			--竞技场每日奖励
	Arena_SeasonReward = 8503,			--竞技场赛季奖励
	Arena_Challenge = 8504,				--竞技场挑战
	Arena_BuyTicket = 8505,				--竞技场购买门票
	Arena_GetScoreReward = 8506,        --领取积分奖励

	--卡牌相关功能 8511 - 8600
	Hero_LevelUp = 8511,				--卡牌升级
	Hero_StageLevelUp = 8512,			--卡牌升阶
	Hero_StarLevelUp = 8513,			--卡牌升星
	Hero_Decompose = 8514,				--卡牌分解
	Hero_ActivePassiveSkill = 8515,		--卡牌被动技能激活
	Hero_LearnPassiveSkill = 8516,		--卡牌被动技能学习
	Hero_Combine = 8517,				--卡牌合成
	Hero_HeroRest = 8518,				--卡牌重置
	Hero_HeroRestCost = 8519,			--卡牌重置 消耗
	Hero_HeroRestPointCost = 8520,		--卡牌重置属性分配点
	Hero_Lottery_Transform = 8521,		--卡牌特异英雄置换 
	Hero_HeroSwitchPointCost = 8522,	--卡牌切换属性点方案
	Hero_LoginInitCombat = 8523, 		--登陆初始化战力
	Hero_PointPlanSet = 8524,		    --卡牌分配属性点
	Hero_StarReset = 8526,				--星级回退
	Hero_SkillReset = 8527,				--技能遗忘
	Hero_InitAttr = 8528,				--初始化卡牌属性
	
	--卡牌抽卡 8601 - 8620
	HeroLottery_LuckyDraw = 8601,		--抽卡
	HeroLottery_Normal 	  = 8602,		--普通召唤
	HeroLottery_Rare 	  = 8603,		--高级召唤
	HeroLottery_Lucky 	  = 8604,		--幸运值召唤
	HeroLottery_Special   = 8605,		--特异召唤
	HeroLottery_Category  = 8606,		--种族召唤
	HeroLottery_FriendShip = 8607,		--友情召唤
	HeroLottery_Transform = 8608,	 	--特异英雄置换
	HeroLottery_NewPlayer = 8609,	 	--新手召唤
	HeroLottery_Up 		  = 8610,	 	--up召唤
	HeroLottery_Senior    = 8611,		--精英召唤
	HeroLottery_SeniorVIP = 8612,		--高级VIP召唤
	HeroLottery_Farplane  = 8613,		--异界召唤
	HeroLottery_UpHero	  = 8614,		--UP英雄召唤

	--装备 8631 - 8660
	Equipment_UpgradeStar  = 8631,		--装备升星
	Equipment_UpgradeOrder = 8632,		--装备升阶
	Equipment_UpgradeMix = 8633,		--装备合成
	Equipment_Exchange = 8634,			--装备兑换
	Equipment_TakeOff = 8635,			--装备卸下
	Equipment_Wear = 8636,				--装备装上
	Equipment_SaveRecasting = 8637,		--保存装备重铸
	Equipment_HopeSkill = 8638,			--保存心愿技能
	Equipment_Recasting = 8639,		    --装备重铸

	--迷宫 8661 - 8670
	Maze_Shop 			= 8661,			--迷宫商店
	Maze_Box			= 8662,			--迷宫宝箱
	Maze_GoddessRestore = 8663,			--迷宫女神之泪
	Maze_battle 		= 8664,			--迷宫战斗
	--秘境 8671 - 8680
	FairyLand_UseItem      = 8671,		--秘境掷骰子
	FairyLand_Reward   = 8672,			--秘境奖励

	--活动 8680 - 9000 
	SevenDayTask_Reward					= 8681,			--七天活动奖励
	EightDayLogin_Reward				= 8682,		--8天活动奖励
	CollectStar_Reward					= 8683,		--推图星数活动奖励
	PushChapter_Reward					= 8684,		--推图关数活动奖励
	OnlineReward_Reward					= 8685,		--在线活动奖励
	PowerTurnTable_Cost 				= 8686,		--转盘活动消耗
	PowerTurnTable_Reward 				= 8687,		--转盘活动奖励
	ActivationCode_Rewards  			= 8688,		--激活码奖励
	CollectThingsDaily_Rewards	 		= 8689,		--集物活动(每日)奖励
	CollectThingsHasy_Rewards 			= 8690,		--集物活动(持久)奖励
	FastUpLevel_Rewards 				= 8691,		--升级活动奖励
	TouchStoneGold_Rewards 				= 8692,		--点石成金活动奖励
	SaleGiftPack_Rewards				= 8693,		--直购礼包
	FirstCharge_Reward					= 8694,		--首冲礼包
	AccChargeDay_Reward 				= 8695,		--每日累计豪礼 
	AccCharge_Reward 					= 8696,		--累计豪礼 
	AccChargeDayEx_Reward 				= 8697,		--每日累计常驻豪礼 
	SurpriseGift_Purchase				= 8698,		--限时推送礼包购买
	BargainGift_Reward 					= 8699,		--超值礼包购买
	QuestionnaireSurvey_Reward 			= 8700,		--调查问卷奖励
	PowerTurnTable_RewardEx 			= 8701,		--转盘活动奖励高级抽奖励
	PowerTurnTable_BoxReward 			= 8702,		--转盘活动奖励高级抽奖励
	WarOrder_Reward                     = 8703,     --战令奖励
	WarOrder_BuyHighWarOder             = 8704,     --购买高阶执照
	SevenDayRecord_BuyGift				= 8705,		--21 新七天活动购买礼包
	SevenDayRecord_PointReward			= 8706,		--21 新七天活动点数奖励
	SevenDayRecord_Mail					= 8707,		--21 新七天活动邮件
	SevenDayRecord_Task					= 8708,		--21 新七天活动领取任务奖励
	NewServerGift_BuyGift               = 8709,     --购买新服专享礼包
	NewServerGift_GetReward             = 8710,     --领取新服专享礼包
	MoonGift_BuyGift 					= 8711, 	--购买月购礼包
	MoonGift_Rewards					= 8712, 	--领取月购礼包
	WeekGift_PaidMoney					= 8713,		--24 每周礼包付钱 
	WeekGift_GetReward					= 8714,		--24 每周礼包领取奖励 
	PreferentialkGift_BuyGift 			= 8715,		--27 特惠礼包
	LimitGift_BuyGift 					= 8716,		--28 限时礼包
	RiskDiary_BuyGift					= 8717,		--29 冒险日记活动购买礼包
	RiskDiary_PointReward				= 8718,		--29 冒险日记活动点数奖励
	RiskDiary_Mail						= 8719,		--29 冒险日记活动邮件
	RiskDiary_Task						= 8720,		--29 冒险日记活动领取任务奖励
	WeekLogin_Reward 					= 8721,		--每周签到奖励
	DelegateContend_Reward 				= 8722, 	--委托夺宝奖励
	StarTempleExpedition_Reward 		= 8723, 	--圣所探险奖励
	Activity_HeroSummon					= 8724,		--限时召唤活动
	Activity_SpecialSummon				= 8725,		--精英召唤活动
	Activity_HeroStarLevel				= 8726,		--升星觉醒活动
	QuestionnaireSurveyStar_Reward 		= 8727,		--调查问卷星奖励
	SecordCharge_Reward					= 8728,		--C-充值豪礼
	WeekLogin_MailReward 				= 8729, 	--每周签到邮件奖励
	Features_Reward 					= 8730, 	--特性觉醒奖励
	Features_MailReward 				= 8731, 	--特性觉醒邮件奖励
	EquipUpStar_CostReward 				= 8732,		--装备兑换升星消耗
	EquipUpStar_Reward 					= 8733,		--装备兑换升星奖励
	EquipMission_Reward 				= 8734,		--装备目标任务奖励
	EquipMission_MailReward				= 8735,		--装备目标邮件奖励  
	NewWeekCard_Reward					= 8736,		--黑金周卡奖励   
	NewWeekCard_MailReward				= 8737,		--黑金周卡邮件奖励
	NewWeekCard_BuyCard					= 8738,		--购买黑金周卡
	DelegateContend_MailReward			= 8739,		--委托夺宝邮件奖励
	StarTempleExpedition_MailReward		= 8740,		--圣所探险邮件奖励
	CollectMap_Reward					= 8741,		--集图夺宝激活地图奖励
	CollectMap_BoxReward				= 8742,		--集图夺宝激活宝箱奖励
	CollectMap_BoxTimesReward			= 8743,		--集图夺宝激活宝箱次数奖励
	CollectMap_MailReward				= 8744,		--集图夺宝邮件奖励
	EquipGift_GetReward					= 8745,		--装备礼包领取奖励 
	Farplane_GetReward					= 8746,		--异界召唤活动奖励领取
	HeroCome_GetReward					= 8747,		--英雄降临
	PrimaryTask_GetReward				= 8748,		--新手任务

	Gashapon_GetReward					= 8749,     --幸运扭蛋积分领取
	EveryDaySign_GetReward				= 8750,     --扭蛋每日签到领取奖励
	GashaponTask_GetReward				= 8751,     --扭蛋任务领取奖励
	GashaponShop_CostBuy				= 8752,     --扭蛋商店购买消耗
	GashaponGift_GetReward				= 8753,     --扭蛋限时礼包
	GashaponShop_Buy					= 8754,		--扭蛋商店购买获得奖励
	Gashapon_BuyGfit					= 8755,		--扭蛋商店购买礼包 这个是rmb
	Gashapon_DrawCost					= 8756,		--扭蛋抽奖消耗
	

	ElfCollectionActivity_Reward		= 8757,		--精灵收集活动任务奖励
	ElfCollectionActivity_MailReward	= 8758,		--精灵收集活动邮件奖励
	ElfSummonActivity_Reward 			= 8759,		--精灵召唤活动任务奖励
	ElfSummonActivity_MailReward		= 8760,		--精灵召唤活动邮件奖励
	ElfGiftActivity_Purchase			= 8761,		--购买精灵商城活动礼包
	Gashapon_DrawReward					= 8762,		--扭蛋抽奖抽奖
	ElfGiftActivity_Reward				= 8763,		--精灵商城零元礼包



	NewHeroShop_Buy						= 8764,		--新英雄商店购买
	NewHeroShop_Cost					= 8765,		--新英雄商店消耗
	
	RuneMission_Reward 					= 8766,		--符文目标任务奖励
	RuneMission_MailReward				= 8767,		--符文目标邮件奖励  

	ElfHis_Reward 						= 8768,		--一番巡礼
	ElfFinal_Reward 					= 8769,		--最终赏
	ElfTourShop_Reward					= 8770,		--巡礼商店
	

	NewHeroCopy_GetReward				= 8771,		--新英雄领取奖励
	RuneActivityShop_BuyGift			= 8772,		--符文商城活动购买礼包
	NewHeroCopy_RankReward				= 8773,		--新英雄排行奖励

	WantCharge_GetReward				= 8774,		--任意充值领取
	WantCharge_MailReward				= 8775,		--任意充值邮件领取

	UpHero_GetReward					= 8776,		--UP英雄召唤活动奖励领取
	CustomLimitGift_BuyGift				= 8777,		--定制礼包购买礼包

	Monopoly_BoxReward					= 8778,		--精灵降临 大富翁 宝箱奖励
	Monopoly_FightReward				= 8779,		--精灵降临 大富翁 战斗奖励
	Monopoly_Cost						= 8780,		--精灵降临 大富翁 购买指定色子消耗
	Monopoly_GetReward					= 8781,		--精灵降临 大富翁 普通奖励

	GroupBuyGift_PreBuyGift				= 8782,		--团购礼包预购
	GroupBuyGift_BuyGift				= 8783,		--团购礼包购买

	ElfFinal_MailReward					= 8784,		--精灵最终赏邮件奖励

	ElfWarOrder_GetReward				= 8785,		--精灵战令领取
	ElfWarOrder_MailReward				= 8786,		--精灵战令邮件领取

	NewWarOrder_ResetCost				= 8787, 	--战令重置消耗
	HeroCollectionActivity_Reward		= 8788,		--探员集结活动奖励
	HeroCollectionActivity_MailReward	= 8789,		--探员集结活动邮件奖励
	GoldMagicActivity_Reward			= 8790,		--点石成金活动奖励
	GoldMagicActivity_MailReward		= 8791,		--点石成金活动邮件奖励
	HeroTrialActivity_PersonalReward	= 8792,		--探员试炼个人奖励
	HeroTrialActivity_CommonReward		= 8793,		--探员试炼全服奖励
	HeroTrialActivity_MailReward		= 8794,		--探员试炼邮件奖励
	GoldMagicActivity_RankReward		= 8795,		--点石成金活动排行榜奖励

	DelegateContendActivity_RankReward	= 8796,		--委托夺宝活动排行榜奖励
	NewHeroCourageCoin_Recycle			= 8797,		--新英雄活动勇气勋章回收

	ShrinePrayShopActivity_Purchase		= 8798,		--购买祈福商城活动礼包
	ShrinePray_Reward 					= 8799,		--神社祈福
	ShrinePrayShop_Reward				= 8800,		--祈福商店

	QuickBattle_Reward					= 8801,		--行动达人活动奖励
	QuickBattle_MailReward				= 8802,		--行动达人活动邮件奖励
	QuickBattle_RankReward				= 8803,		--行动达人活动排行榜奖励

	Gashapon_RecycleScore 				= 8804,		--扭蛋回收积分
	HeroTrial_RecycleScore 				= 8805,		--探员试炼回收积分
	AccChargeDayCopy_Reward				= 8806,		--每日累充复刻奖励
	HeroTrialShop_CostBuy				= 8807,     --探员试炼商店购买消耗
	HeroTrialShop_Buy					= 8808,		--探员试炼商店购买获得奖励
	HeroTrialGift_BuyGfit				= 8809,		--探员试炼商店购买礼包
	HeroSummonShop_BuyGift 				= 8810,		--精英召唤限时商城
	NoBilityWeekGift_GetReward			= 8811,		--贵族专享礼包领取

	GodsPray_Reward 					= 8812,		--神灵祈愿
	GodsPrayShop_Reward					= 8813,		--神灵祈愿商店
	GodsPrayCoin_Recycle				= 8814,		--神灵祈愿币回收

	CollectThingsShop_Buy				= 8815,		--集物商店购买
	CollectThingsShop_Cost				= 8816,		--集物商店消耗

	CollectWordsShop_Reward				= 8817,		--集字活动商店

	MazeWarOrder_GetReward				= 8818,		--逆境迷宫战令领取
	MazeWarOrder_MailReward				= 8819,		--逆境迷宫战令邮件领取

	EndlessRoadWarOrder_GetReward		= 8820,		--极地探索战令领取
	EndlessRoadWarOrder_MailReward		= 8821,		--极地探索战令邮件领取
	TrialShop_Reward                    = 8822,     --阵营试炼商店
	Trial_ReMatchCost                   = 8823,     --阵营试炼重新匹配消耗
	Trial_ExchangeCost                  = 8824,     --阵营试炼兑换消耗
	Trial_ExchangeGet                   = 8825,     --阵营试炼兑换获得
	BoundaryWarOrder_GetReward 			= 8826,		--临界战令
	BoundaryWarOrder_MailReward			= 8827, 	--临界战令邮件领取
	HeroTrialPreferGift_BuyGift			= 8828,		--探员试炼特惠礼包购买
	TourPreferGift_BuyGift				= 8829,		--巡礼特惠礼包购买
	GashaponPreferGift_BuyGift			= 8830,		--扭蛋特惠礼包购买
	ShrinePrayPreferGift_BuyGift		= 8831,		--神社祈福特惠礼包购买
	Trial_MailRewards                   = 8832,     --阵营试炼结束邮件奖励
	HeroSummonShopDay_BuyGift			= 8833,		--精英召唤每日限时商城购买
	Trial_BattleReward                  = 8834,     --阵营试炼战斗奖励
	FestivalRecharge_Reward 			= 8835,		--节日累计充值豪礼奖励
	HallowWarOrder_GetReward			= 8836,		--圣器战令领取
	HallowWarOrder_MailReward			= 8837,		--圣器战令战令邮件领取
	ElfFinalSecond_TimesReward		    = 8838,     --最终赏2抽奖进度奖励
	ElfFinalSecond_RecycleItem		    = 8839,     --最终赏2结束邮件补发奖励

	SmallElfWarOrder_GetReward			= 8840,		--小额精灵战令领取
	SmallElfWarOrder_MailReward			= 8841,		--小额精灵战令邮件领取
	HolidayShop_Reward                  = 8842,     --通用节日活动商店

	NewHeroSummon_GetReward				= 8843, 	--新英雄召唤祈愿获得
	NewHeroSummon_Cost					= 8844, 	--新英雄召唤祈愿消耗
	NewHeroSummon_Recycle				= 8845, 	--新英雄召唤祈愿回收
	NewHeroSummonExchange_Buy			= 8846, 	--新英雄召唤兑换商城购买
	NewHeroSummonExchange_Cost			= 8847, 	--新英雄召唤兑换商城消耗
	NewHeroSummonShop_Reward			= 8848, 	--新英雄召唤购买商城获得

	NewYearShop_Reward 					= 8849, 	--新年商城购买获得
	NewYearShopDay_Reward 				= 8850, 	--新年每日商城购买获得
	NewYearExchange_Cost				= 8851,     --新年兑换商城消耗
	NewYearExchange_Buy					= 8852,  	--新年兑换商城获得

	
	--远征9001 - 9020
	EndlessRoad_Reward	= 9001,			--远征奖励
	EndlessRoad_RewardEx= 9002,			--远征10关奖励
	EndlessRoad_CostGod = 9003,			--远征消耗女神之泪
	--阵法系统9021 - 9040
	Tactical_UpgradeTactical = 9051,	--升级阵法
	Tactical_ResetCompensate = 9052,	--新阵法重置等级补偿

	--英雄谷9041 -9060
	HeroPalace_OpenGroupBIndex = 9041,	--共生殿开启栏位
	HeroPalace_ClearCoolTime = 9042,	--共生殿清除冷却时间
	HeroPalace_UpgradeCrystal = 9043,	--共生殿升级水晶
	HeroPalace_LevelChange	= 9044,		--共生殿等级变化
	HeroPalace_AddGroupBHero = 9045,	--共生殿添加栏位英雄
	HeroPalace_RemoveGroupBHero = 9046,	--共生殿移除栏位英雄
	HeroPalace_ResetGroupBHero = 9047,	--共生殿重置栏位英雄

	--符文9061 - 9080 
	Rune_Unlock 						= 9061,		--解锁符文
	Rune_ResetAttr 						= 9062,		--重置属性
	Rune_UnlockPage 					= 9063,		--解锁符文页
	Rune_Synthetic 						= 9064,		--合成符文
	Rune_AddToPageRune 					= 9065,		--添加符文位置
	Rune_TakeOffRunePos 				= 9066,		--脱下单个符文
	Rune_TakeOffPageAllRunePos			= 9067,		--脱下单页全部符文
	Rune_SyntheticCost					= 9068,		--合成消耗
	Rune_UnlockCdEquipCd 				= 9069,		--解锁英雄格子cd
	Rune_UnlockCdEquip 					= 9070,		--解锁英雄格子
	Rune_SetSkillIds 					= 9071,		--设置符文技能
	Rune_EquipmentHero					= 9072,		--符文上阵英雄
	Rune_TakeOffHero					= 9073,		--符文下阵英雄
	Rune_SaleRune 						= 9074,		--出售符文
	Rune_Decom							= 9075,		--分解符文
	--英雄图鉴9081-9100
	HeroTotems_UpdateTitle				= 9081,		--英雄图鉴头衔升级
	HeroTotems_WeekTitle				= 9082,		--英雄图鉴周奖励实发
	HeroTotems_GiveItem 				= 9083,		--图鉴赠送
	HeroTotems_HangUp 					= 9084,		--图鉴挂机奖励
	HeroTotems_AddPoint 				= 9085, 	--图鉴添加收集点
	HeroTotems_GetFirstReward           = 9086,     --获取第一次奖励
	HeroTotems_GiftHeroRecommendset 	= 9087,		--英雄组合奖励
	HeroTotems_InteractionLimit 		= 9088,		--互动次数
	--委托任务 9101 - 9150
	Delegate_Cost						= 9101,		--委托任务消耗
	Delegate_Reward						= 9102,		--委托任务奖励
	--职级任务 9151 - 9200				
	Duty_Task_Reward 					= 9151,		--职级奖励
	Duty_Task_UpdateLevel 				= 9152,		--职级晋升

	--世界擂台赛  9201 - 9299
	WorldArena_Guess				= 9201,		--世界擂台赛竞猜
	WorldArena_Battle				= 9202,		--世界擂台赛战斗

	--摇钱树 9300-9305
	GoldMoney_GetReward 				= 9300,		--摇钱树购买金币
	TimePush_GetReward 					= 9301,		--定时推送奖励
	--VIP 9306 - 9400
	Vip_DayGift							= 9306,		--领取VIP每日奖励
	Vip_LevelGift 						= 9307,		--领取VIP等级奖励
	Privilege_Gift 						= 9308, 	--购买特权礼包
	--好友9401 - 9420
	Friend_ForwardMoney 				= 9401,		--好友增送点
	--神器 9421 - 9450
	GodArms_AddExp						= 9421,		--神器增加经验
	GodArms_UpStage						= 9422,		--神器升阶
	GodArms_UpCount						= 9423, 	--神器炼神
	GodArms_Start						= 9424,		--神器激活
	GodArms_Refine						= 9425,		--神器精炼
	GodArms_Task						= 9426,		--神器任务
	GodArms_Trigger						= 9427,		--客户端激活秘武
	GodArms_Buy							= 9428,		--rmb购买激活

	--晨星圣所 9451 - 9500
	PveStarTemple_task 					= 9451,		--晨星任务奖励领取
	PveStarTemple_event 				= 9452,		--晨星事件奖励
	PveStarTemple_CostMall 				= 9453,		--晨星商店消费
	PveStarTemple_CostEvent				= 9454,		--晨星事件消费
	PveStarTemple_Mall 					= 9455,		--晨星商店获取
	--无尽试炼  9501 - 9530
	TopChallenge_Challenge				= 9501,		--无尽试炼战斗
	TopChallenge_FirstReward			= 9502,		--无尽试炼首通奖励
	TopChallenge_FriendHelp				= 9503,		--无尽试炼好友协助
	TopChallenge_FriendshipScore		= 9504,		--无尽试炼友情点奖励
	TopChallenge_RankReward				= 9505,		--无尽试炼排名奖励

	--基金奖励  9531 - 9535 				
	Fund_Reward 						= 9531, 	--成长基金奖励
	Fund_Buy 	 						= 9532, 	--购买成长基金

	--月卡奖励  9536 - 9540 	 			
	MoonCard_Reward 				 	= 9536, 	--月卡奖励
	MoonCard_RhodMailReward 			= 9537,     --白金月卡邮件奖励
	MoonCard_ExtremeMailReward 			= 9538,     --至尊月卡邮件奖励

	--饰品系统  9541 - 9550
	Jewelry_Wear						= 9541,		--饰品穿上	
	Jewelry_TakeOff						= 9542,		--饰品卸下	
	Jewelry_UpgradeOrder				= 9543,		--饰品重铸
	Jewelry_SaveRecasting				= 9544, 	--饰品保存重铸

	--高阶pvp 9551 - 9600 	 		
	HigherPvp_FightReward				= 9551, 	--高阶PVP战斗奖励
	HigherPvp_RankReward				= 9552, 	--高阶PVP段位奖励
	HigherPvp_SeasonReward				= 9553, 	--高阶PVP赛季奖励
	HigherPvp_BuyCost					= 9554, 	--高阶PVP买票消耗
	HigherPvp_FightCost					= 9555, 	--高阶PVP战斗奖励
	HigherPvp_BuyTick					= 9556,		--高阶竞技场买票

	--超级基金 9601 - 9610
	SuperFund_BuyReward 			 	= 9601,    	--购买奖励
	SuperFund_Reward 				 	= 9602,    	--奖励

	--周卡 9611 - 9620
	WeekCrad_GetReward 					= 9611, 	--周卡奖励
	WeekCrad_BuyCard 					= 9612,		--周卡购买

	--每日礼包 9621 - 9625
	DailyGift_BuyReward					= 9621, 	--每日礼包购买奖励
	DailyGift_OneKeyBuyReward			= 9622, 	--一键购买每日礼包奖励

	--登录就送 9626 - 9630
	LoginToSend_Reward					= 9626, 	--登录就送奖励

	--积天豪礼 9631 - 9635 				
	AccumulativeDay_Reward 				= 9631, 	--积天豪礼奖励

	--下载礼包 9636 - 9640
	DownloadReward_GetReward			= 9636, 	--下载礼包奖励

	-- 开工福利 9641 - 9645
	WorkingWelfare_Reward 		 	 	= 9641, 	--开工福利奖励

	-- 幻境通关奖励 9645 - 9660
	DreamLand_PassReward				= 9645,		--幻境通关奖励
	DreamLand_Reward 					= 9646,		--幻境挑战奖励
	DreamLand_BeHireReward				= 9647,		--幻境挑被雇佣奖励友情点
	--精灵奖励 9660 - 9690
	Elf_SummonTimesReward				= 9660,		--精灵召唤次数奖励
	Elf_ComponentReward 				= 9661,		--精灵碎片合成奖励
	Elf_ComponentSummon					= 9662,		--精灵碎片召唤
	Elf_Transfer						= 9663,		--转成精灵碎片
	Elf_UpdateElfStar 					= 9664,		--精灵升星
	Elf_SummonCostReward 				= 9665,		--精灵召唤消耗
	Elf_ReceiveSummonReward 			= 9666,		--精灵召唤奖励
	Elf_UpdateAttrs 					= 9667,		--精灵属性更新
	Elf_UseItem 						= 9668,		--精灵道具使用
	Elf_ActiveSkin 						= 9669,		--精灵激活道具
	Elf_DecomposeSkin					= 9670,		--精灵分解道具
	--道具合成使用 9691 - 9750
	Item_CrystalUpgrade					= 9691,		--水晶合成消耗
	Item_CrystalUpgradeConst 			= 9692,		--水晶合成奖励

	--圣器  9751- 9800
	Hallow_FirstReward					= 9751, 	--圣器副本首通奖励
	Hallow_MopReward					= 9752, 	--圣器副本扫荡奖励
	Hallow_UpLevelCost					= 9753,		--升级圣器消耗
	Hallow_UpLevel 						= 9754,		--圣器升级
	Hallow_BaseUpLevel 					= 9755,		--圣器基座升级
	Hallow_UpCopyBuyCost				= 9756,		--圣器副本购买消耗
	Hallow_RankReward					= 9757,		--圣器排行奖励
	--魔灵山  9801 - 9850
	EvilMountain_Open					= 9801,		--魔灵山功能开启
	EvilMountain_SummonBoss				= 9802,		--魔灵山召唤BOSS
	EvilMountain_PurchaseEnergy			= 9803,		--魔灵山购买精力
	EvilMountain_BossReward				= 9804,		--魔灵山BOSS结算
	EvilMountain_Challenge				= 9805,		--魔灵山挑战BOSS

	--头像框 9851 - 9860
	HeadFrame_Reward					= 9851,		--头像框奖励
	HeadFrame_Update 					= 9852,		--头像框更新
	--临界 9861 - 9880 					
	Boundary_Battle						= 9861,		--临界战斗

	--纹章 9881 - 9890
	Heraldry_UpgradeStar 					= 9881,  	--纹章升星
	Heraldry_GoldUpgradeStar 				= 9882,  	--纹章金币升星
	Heraldry_Dress 							= 9883,  	--穿戴纹章
	Heraldry_Unload 						= 9884,  	--卸下纹章
	Heraldry_UpgradeStarCost				= 9885,  	--纹章升星消耗道具
	Heraldry_ResetRace						= 9886,  	--纹章重铸

	--找回 9891 - 9900
	Retrieve_RetrieveItemCost				= 9891,		--找回物品消耗
	Retrieve_RetrieveItemReward				= 9892,		--找回物品获得的物品
	Retrieve_OneKeyRetrieveItemCost			= 9893,		--一键找回物品消耗
	Retrieve_OneKeyRetrieveItemReward		= 9894,		--一键找回物品获得的物品

	--天境赛世界擂台赛  9901 - 9920
	WorldSkyPvp_Guess				= 9901,		--世界擂台赛竞猜
	WorldSkyPvp_Battle				= 9902,		--世界擂台赛战斗

	--梦境pvp  9921 - 9940
	DreamPvp_RankReward				= 9921,		--排行邮件奖励
	DreamPvp_ScoreReward			= 9922,		--积分邮件奖励
	--跨服天域pvp赛 9941 - 9970
	HorizonPvp_BattleReward				= 9941,		--天域pvp战斗奖励
	HorizonPvp_ResultReward 			= 9942,		--天域pvp战斗结算奖励
	HorizonPvp_MatchLimit 				= 9943,		--天域pvp匹配次数扣除
	--排行榜进度奖励 9971 - 9980
	TaskRankReward_Reward 			= 9971,		--排行榜进度奖励

	--录像 9981 - 9990
	BattleRecord_AddLikesReward = 9981,       --录像点赞奖励

	-- 称号 9991 - 10000
	CrownTitle_Add			= 9991,	--增加称号
	CrownTitle_Remove		= 9992, --移除称号

	--弹幕10001-10010
	Barrage_SendLimit			=10001,		--发送弹幕次数扣除

	--训练营 10011 - 10015
	TrainingCamp_GetReward		= 10011, 	--训练营奖励

	--公会联赛 10016 - 10050
	GuildPvp_ChallengeSucc			= 10016,	--公会联赛挑战胜利
	GuildPvp_ChallengeFailed		= 10017,	--公会联赛挑战失败
	GuildPvp_MatchGiftBox			= 10018,	--公会联赛比赛宝箱
	GuildPvp_BattleScoreReward		= 10019,	--公会联赛得分奖励
	GuildPvp_GuildRankLevel			= 10020,	--公会联赛段位首达奖励
	GuildPvp_SeasonRankLevel		= 10021,	--公会联赛段位结算奖励

	--英雄羁绊 10051 - 10055
	HeroFetter_GetReward			= 10051,	--羁绊条件完成奖励
	HeroFetter_AddHeroAttr			= 10052,	--羁绊条件完成增加属性

	--组队竞技10060 - 10070
	WorldTeamArena_RefreshTimes        = 10060,    --刷新次数
	WorldTeamArena_AddBattleWinReward  = 10061,  --发放组队竞技战斗结束赢的奖励
	WorldTeamArena_AddBattleLoseReward = 10062, --发放组队竞技战斗结束输的奖励
	WorldTeamArena_AddSeasonRankReward = 10063, --发放组队竞技赛季奖励
	WorldTeamArean_MatchLimit          = 10064, --组队竞技赛匹配次数扣除
	WorldTeamArean_TaskEndReward       = 10065, --组队竞技赛结算上一次未领取的任务奖励

	--跨服竞技场 10100 - 10150
	CrossArena_FightCost			= 10100,	--跨服竞技场战斗消耗
	CrossArena_WinReward			= 10101,	--跨服竞技场胜利奖励
	CrossArena_DailyReward			= 10102,	--跨服竞技场次数宝箱奖励
	CrossArena_DailyRewardMail		= 10103,	--跨服竞技场次数宝箱邮件奖励
	CrossArena_RankReward			= 10104,	--跨服竞技场排行奖励
	CrossArena_LikeReward			= 10105,	--跨服竞技场点赞奖励

	--时装皮肤10151 - 10160
	Fashion_Compose					= 10151,	--时装皮肤合成
	Fashion_ItemAdd					= 10152,	--时装皮肤获得
	Fashion_ItemDelete				= 10153,	--时装皮肤移除

	--探员置换 10161 - 10165
	HeroChange_Transform 			= 10161,	--探员置换

	--幻墨之境 10166 - 10170
	BloodAbyss_MultipleRank			= 10166,	--幻墨之境总排行榜奖励
	BloodAbyss_GetReward 			= 10167,	--幻墨之镜领取次数奖励
	BloodAbyss_SaveScore 			= 10168,	--幻墨之镜保存积分
	BloodAbyss_MailReward 			= 10169,	--幻墨之镜邮件发放次数奖励
	BloodAbyss_RecycleScore			= 10170,    --幻墨之镜回收试炼积分

	--每日登录活动 10181 - 10190
	EveryDayLogin_Reward			= 10181,	--每日登录活动奖励
	EveryDayLogin_RewardMail		= 10182,	--每日登录活动邮件奖励
	
	--集字活动 10200 - 10220
	CollectWordsShop_CostBuy		= 10200,    --集字活动商店购买消耗
	CollectWordsShop_Buy			= 10201,	--集字活动商店购买获得奖励
	CollectWords_ExchangeConsume    = 10202,    --集字活动兑换消耗
	CollectWords_ExchangeGet        = 10203,    --集字活动兑换获得
	CollectWords_MailRewards        = 10204,    --集字活动结束邮件奖励

	--全服礼包 10221 - 10230
	ServerGroupBuy_BuyGift			= 10221,    --全服礼包购买礼包
	ServerGroupBuy_GetFreeReward    = 10222,	--全服礼包获得免费奖励
	ServerGroupBuy_GetPayReward     = 10223,	--全服礼包获得付费奖励
	ServerGroupBuy_GetUnClaimReward = 10224,	--全服礼包获得未领取奖励
	--跨服超凡 10231 - 10250
	CrossSuperMundane_GetDanReward 			= 10232,--领取段位奖励
	CrossSuperMundane_DanKingReward 		= 10233,--领取王者之证奖励
	CrossSuperMundane_BuyDanKingReward 		= 10234,--购买王者之证奖励
	CrossSuperMundane_MatchLimit 			= 10235,--匹配消耗次数
	CrossSuperMundane_BattleReward 			= 10236,--战斗奖励
	CrossSuperMundane_ResultDanReward 		= 10237,--结算首达段位奖励
	CrossSuperMundane_ResultCurDanReward 	= 10238,--段位结算奖励
	CrossSuperMundane_BeforeRankReward 		= 10239,--排行榜前几名的奖励
	CrossSuperMundane_ResultKingJourneyReward 	= 10240,--王者之征结算奖励
	--封魔之路 10251 - 10260
	DevilRoad_TreasureReward 		= 10251,	--封魔之路宝箱奖励
	DevilRoad_GateReward			= 10252,	--封魔之路通关奖励 
	-- 公会传奇赛 10301 - 10350
	GuildLeague_GuessCost 			= 10301, 	--公会传奇赛竞猜消耗
	GuildLeague_GuessReward			= 10302, 	--公会传奇赛竞猜获得
	GuildLeague_MailReward			= 10303,	--公会传奇赛排名邮件奖励
	GuildLeague_BuyCost 			= 10304, 	--公会传奇赛购买币消耗
	GuildLeague_BuyReward 			= 10305, 	--公会传奇赛购买币消耗
	GuildLeague_DrawCost 			= 10306, 	--公会传奇赛抽奖消耗
	GuildLeague_DrawReward 			= 10307, 	--公会传奇赛抽奖消耗
	
	--巅峰竞技 10351 - 10380
	TopArena_LikeReward				= 10351,	--巅峰竞技点赞奖励
	TopArena_RankReward				= 10352,	--巅峰竞技赛季排行奖励
	TopArena_GuessReward			= 10353,	--巅峰竞技竞猜奖励
	

	--跨服天梯赛 10260 - 10280
	SkyLadder_FightCost 			= 10260,	--天梯赛消耗
	SkyLadder_FightReward			= 10261, 	--天梯赛奖励

	--专属武器 10281 - 10290
	UniqueWeapon_UpdateLevelCost 	= 10281,	--专武升级消耗
	UniqueWeapon_AddHeroAttr 		= 10282,	--获得专武卡牌增加属性
	SkyLadder_HeroLike				= 10262, 	--天梯赛英雄殿点赞

	--协力大作战活动 10291 - 10310
	WorkTogether_Reward				= 10291,	--协力活动奖励
	WorkTogether_MailScoreReward	= 10292,	--协力活动邮件积分奖励
	WorkTogether_MailHelpReward		= 10293,	--协力活动邮件助力奖励
	WorkTogether_ExchangeBuy		= 10294,	--协力活动兑换商城
	WorkTogether_LimitTimeBuy		= 10295,	--协力活动兑换商城
	WorkTogether_RankReward			= 10296,	--协力活动排行奖励	
	WorkTogether_OccupyReward		= 10297,	--协力活动占领奖励	
	
	--人气探员票选 10311-10320
	HeroVote_VoteTimesReward		= 10311,    --人气探员票选个人进度奖励
	HeroVote_VoteCost				= 10312,    --人气探员票选道具消耗
	HeroVote_VoteReward				= 10313,    --人气探员票选单次投票奖励
	HeroVote_VoteTaskReward			= 10314,    --人气探员票选任务奖励
	HeroVoteTable_Reward			= 10315,    --人气探员票选返场奖励
	HeroVoteTable_Cost				= 10316,    --人气探员票选返场消耗
	HeroVoteShop_Reward				= 10317,    --人气探员票选商店
	HeroVote_AddBuff				= 10318,   	--人气探员票选投票期结束加Buff
	HeroVote_RecycleItem			= 10319,   	--人气探员票选回收

	-- 新闻 10321-10340
	NewsBoard_AgreeReward			= 10321,	--新闻奖励
	NewsBoard_DayReward				= 10322,	--新闻每日奖励

	--节日通用活动10400 - 10420
	Holiday_ExchangeCost            = 10400, --节日活动兑换消耗
	Holiday_ExchangeGet             = 10401, --节日活动兑换获得
	Holiday_BattleGet               = 10402, --节日活动打boss奖励

	--跨服天梯冠军赛 10421 - 10440
	SkyLadChampion_PreRewards 		= 10421,	--天梯冠军赛预选赛奖励
	SkyLadChampion_Rewards			= 10422, 	--天梯冠军赛结算奖励
	SkyLadChampion_InTopTip			= 10423, 	--天梯冠军进入几强通知
	SkyLadChampion_HeroLike 		= 10424, 	--天梯冠军赛点赞奖励
	SkyLadChampion_ScoreReward 		= 10425, 	--天梯冠军赛积分转换邮件

	--神墟 10441 - 10460
	GodMarket_GodSpiritMailReward 		 = 10441,--神墟神灵塔奖励
	GodMarket_GuardsMailReward 			 = 10442,--神墟守卫奖励
	GodMarket_BossMailReward 			 = 10443,--神墟邮件Boss奖励
	GodMarket_ResetCost 				 = 10444,--神墟重置积分
	GodMarket_GridRoomReward 	 		 = 10445,--神墟神格奖励
	GodMarket_GridReward 				 = 10446,--神墟挑战奖励
	GodMarket_BoxTreasureReward 		 = 10447,--神墟神墟宝藏
	GodMarket_BoxReward 				 = 10448,--神墟宝箱奖励
	GodMarket_ShopBuy 					 = 10449,--神墟商店兑换
	GodMarket_ShopCost 					 = 10450,--神墟兑换消耗
	GodMarket_ShopTisp 					 = 10451,--神墟商店说明
	GodMarket_BossReward 				 = 10452,--神墟Boss奖励
	--异能计划10461 - 10480
	PowerPlan_RankReward			= 10461,	--异能计划排行榜奖励
	PowerPlan_GetReward				= 10462,	--异能计划阶段奖励
	PowerPlan_FightReward			= 10463,	--异能计划阶段战斗奖励

	--节日寄语活动 10481 - 10490
	FestivalWish_Reward				= 10481,	--节日寄语奖励

	--荣耀墙 10491 - 10495
	HonorMedalWall_TakeOffMedal		= 10491,	--卸下勋章
	HonorMedalWall_LoadMedal		= 10492,	--装上勋章
	HonorMedalWall_LoadMedal		= 10493,	--旧号补偿勋章

	--元宵活动 10496 - 10550		
	Lantern_ShopCost				= 10496,	--元宵商店消耗
	Lantern_ShopBuy					= 10497,	--元宵商店获得
	Lantern_GiftBuy					= 10498,	--元宵礼包购买
	Lantern_RecycleScore			= 10499,	--元宵回收积分
	Lantern_DrawCost				= 10500,	--元宵抽奖消耗
	Lantern_DrawReward				= 10501,	--元宵抽取奖励
	Lantern_GetReward				= 10502,	--元宵抽取领取奖励
	Lantern_DaySignGetReward		= 10503,	--元宵签到领取奖励
	Lantern_TaskGetReward			= 10504,    --元宵任务领取奖励
	Lantern_GuessGetReward			= 10505,	--元宵猜谜奖励

	--周巡拼图活动 10551 - 10570
	WeekPuzzle_LightReward			= 10551,	--周巡拼图点亮奖励
	WeekPuzzle_BigReward			= 10552,	--周巡拼图大奖奖励
	WeekPuzzle_StageReward			= 10553,	--周巡拼图阶段奖励
	WeekPuzzle_TaskReward			= 10554,	--周巡拼图任务奖励
	WeekPuzzle_TaskMailReward		= 10555,	--周巡拼图任务邮件奖励
	WeekPuzzle_MailReward			= 10556,	--周巡拼图其他邮件奖励

	--新年活动 10571 - 10590
	NewYear_Challenge				= 10571,	--新年活动挑战
	NewYear_Contribute 		 		= 10572,	--新年活动贡献
	NewYear_Draw 		 			= 10573,	--新年活动抽奖
	NewYear_BigBossRewards 			= 10574,	--新年活动大boss奖励

	--赠礼 10600 - 10610
	DonateGift_ClaimGiftReward      = 10600,
}