
--[[
1、字符串事件用法：
	目的是减少搜索的跳转	
	Dispatcher.addEventListener(functionName, listenerCaller, priority)  3个参数

	字符串即函数名，用法如下:		
	self为一个table, task_tasktraceClick为table中的一个函数
	Dispatcher.addEventListener(EventType.task_tasktraceClick,self)

2、数字事件用法：
	Dispatcher.addEventListener(name, listener, listenerCaller, priority)  4个参数
]]
local EventType = {}
_G.RecvType = EventType
if __IS_RELEASE__ then
return setmetatable(EventType, {__index = function(t, k)
		EventType[k] = k
		return k
	end})
else


local EventTypeTmp = {
	--公共
	"network_ping",  --ping值时间
    "serverTime_crossDay",--跨天时间通知事件
    "serverTime_cross5AM",--凌晨5点
	"serverTime_cross10PM",--晚上十点
	
	"APP_LIFECYCLE_CHANGED",
	"APP_ENTER_FOREGROUND",
	"APP_ENTER_BACKGROUND",
	
	"view_open",--有窗口打开
	"view_change",--有窗口打开或退出
	
	"public_enterGame",
	"public_firstEnterGameToday",
	
	"resDownLoad_start",
	"resDownLoad_stop",
	"resDownLoad_status",
		
	"resDownLoad_file",
	"tips_notify_close",
	"packItem_change",
	--"view_back",--窗口返回上一级

	--模块开启
	"module_open",
	"module_check",
	"module_open_hint",   --有新的模块开放了，检测提示
    "reward_close_event",
	"loading_tipsFont",
	"fight_lose_event",
		
	--登录数据
	"login_player_data",
	"login_player_data_finish",
	"loading_updateProgress",
		
	"guide_first",
	"guide_open",
	"guide_runNext",--新手引导
	"guideType2_checkNext",--新手引导
	'guide_setNameSuccess',
		
	--需要重命名一下
	"money_showMoneyNotEnough",
	
	"crossArena_hideTeam",
	"crossArena_updateTickInfo",
	"crossArena_timeUpdate",

	"godmarket_createModel",
	"godmarket_findGridBox",
	"godMarket_updateGridBoxData",
	"godmarket_updateGridData",
	"godmarket_movetorect",
	"godmarket_updatemap",
	"godmarket_updateTransfer",
	"godmarket_updateOneAction",
	"godmarket_battle",
	"godmarket_rankData",
	"GodMarket_ShopRefresh",
	"godmarket_mineRewardStateChange",

	--需要重命名一下
	"cardView_matchPointSwitch",
	"cardView_showDetial",
	"cardView_levelUpSuc",
	"cardView_stepUpSuc",
	"cardView_CardAddAndDeleInfo",
	"cardView_updateInfo",
	'cardView_starUpSuc',
	'cardView_starUpChoose',
	'cardView_starUpviewClose',
	'cardView_configurationPoint',
	'cardView_activeSkillSuc',
	'CardView_talentLearnSuc',
	'cardView_setLockSuc',
	'cardView_DecomposeSuc',
	'cardView_DecomposeDebrisSuc',
	'cardView_hideUI',
	'cardView_freeResetTimesChange',
	'cardView_setMoneyType',
	'quickStarUp_chooseChange', -- 快捷升星材料选择变化
	'quickStarUp_suc', -- 快捷升星成功
	
	"card_delete_event",
	"cardView_ResetTheChooseUp",
	"cardView_ResetTheViewClear",
	--战斗开始
    "battle_array",
    "battle_config",
	"battle_canCel",
	"battle_requestFunc",		
	"battle_begin",
	"battle_roundStar",--每个回合开始
	"battle_attackStar",--每个人出手
	"battle_roundEnd", -- 每回合结束
	"battle_enter",
	"battle_end",
	"battle_Next",--无尽模式当前场景直接下一场战斗
	"battle_close",
    "battle_reset",
	"battle_setData",
	"battle_refightCamp",
	"battle_updateBuffList",--刷新角色的buff信息	
	"battle_buffUpdate",--角色buff信息更新	
	"Battle_replayRecord",--战斗播放录像
	"Battle_playEditBattle",--播放剧情编辑动画
	"battle_setBattleFunc",--设置
	"battle_elvesStart", -- 精灵出手刷新回合倒数
	"battle_skaking", -- 震屏
	"showTactial_event",
	"showTactial_event2",
	"update_AddTopShow",
	"battle_tacticalUpdate",
		
    "buoyWindow_Close",	
	"buoyWindow_Remove",
	"buoyWindow_SpeedChange",--浮标滑动战斗加速

		
	--幻魔之境
	"bloodAbyss_battle",
	"bloodAbyss_updateView",
	
	"trialActivity_battle",
	"trialActivity_matchSuccess",
	"trialActivity_matchFinish",
	"trialActivity_exchangeSuccess",
	"trialActivity_freeBuySuccess",
	"trialActivity_updateArry",

	--竞技场
	"Arena_open",
	"Arena_getChallengeList",
    "Arena_battleEnd",
	"Arena_showHeroDetail",
	"Arena_updateTickInfo",
	
		
	
	--loading界面
	"loading_begin",
	"loading_end",
	"loading_closeLoading",
	
	--登录系统
	"login_chooseServer",
	"login_showLoginView",
	"login_recommendServerUpdated",
	"login_serverListUpdated",
    "login_begin",
	"login_doLogin",
	"login_loginCheck",
	"login_loginSuccess",
	"login_openServerList",
	"login_show_tips",
	"login_loginFail",
	"login_openNotice",
	"login_sdklogin_success",
	"login_sdkInit_success",
	"login_sdkLogout_success",
	"login_sdkLogin_cancel",
	"login_sdkRegister_success",
	"login_sdkVerify_success",

	--玩家信息
	"player_openInfoView",
	"player_openHeadView",
	"player_headreset",
	"player_sexreset",
	"player_rename_success",
	"player_updateRoleInfo",
	"player_levelUp",
	"player_modelChange",
	"player_closeGgraphBox",

	--推图
	"pushmap_closeView",
	"pushmap_updateAwardList",
	"pushMap_point_change",
		
	"PowerPlan_updateData",

	--远征
	"expedition_fightEvent",
	--商店
	"shop_refreshItem",
	"ShopView_upDataList",
	"shopView_refreshActivityBtn",

	--装备
	"equipment_openForge",
	"equipment_refresheq",
	"equipment_changeCtl",
	"equipment_uniqueWeapon",

	--图鉴
	"handbook_refresh_supportNumber",
	"handbook_groupaward",

	--网络事件
	"socket_tryreconnect",
	"socket_disconnect"	,

	"test_callTime",
	"initiative_break",	

	--材料副本
	"materialCopy_updata", --材料副本
	"materialCopy_pass", --材料副本
	"materialCopy_addCopyNum", --材料副本
	"materialCopy_resetDay", --材料副本
	--背包
	"pack_item_change", --普通背包更新
	"pack_equip_change", --装备道具更新
	"pack_special_change", --特殊道具更新
	"pack_herocomp_change", --碎片更新
	"pack_rune_change",--符文更新
	"pack_jewelry_change", --饰品更新
	"pack_elves_change", -- 精灵更新
	"pack_headBoarder_change", -- 头像框更新
	"pack_crownTitle_change", -- 称号更新
	"pack_emblem_change", -- 纹章更新
	"pack_emblem_equiped_change", -- 已穿戴纹章更新
	"pack_fashion_change", -- 时装背包更新
	"pack_HonorMedalWall_change", -- 勋章更新
	"rune_changePage",
	"pveStarTemple_change",--星辰圣所配置
	"update_rune_heroList",
	"reset_update_FreeTime",
    "Bag_UseItem",--道具使用
    "Bag_DropItem",
    "Bag_Reclaim",
    "Bag_Arrange",
    "Add_Item",
    "money_change",
    "show_gameReward",--通用奖励显示
    -- "update_Bag_Items",--bag_info协议更新某一背包数据
	
    --卡牌召唤
    "update_getCardsView",
    "update_yj_heroPage",

    --聊天
    "update_chat",
	'update_chatInfo',
	'update_chatFace',
	'update_chatClientPrivte',
	'update_chatClientPrivteInfo',
	'update_deletechatClientPrivteInfo',
	'update_chatClientPrivteOpenView',
	'chat_clickLink',
	'chat_newMsg',
	'update_chatClientGuildDivination',
	'update_chatClientGuildOpenView',
	'update_chatClientCardShare',
	'update_chatClientCardShareOpenView',
	'update_chat_runMonkeyMsg',
	'update_chatClientRoleNameShare',
	"update_chatClientRoleNameShareOpenView",
	"update_chatClientVideoShare",
	"update_chatClientVideoShareOpenView",
	"update_VideoTotalRecord",
	"chat_autoPlay_pause",
	"chat_autoPlay_continue",
	"chat_sendVoiceMsg",
	"chat_voicePlay_begin",
	"chat_voicePlay_end",	
	"chat_jingyan_updataInfo",	
	"chat_autoPlayQueue_push",	
	"update_chatClientOpenViewByChannelId",
	"update_openChatClientChannelId",	
	"update_upChatGiftTimes",	
	"update_upChatGiftGiftRecord",	
    --爬塔
    "pata_showNext",
	"pata_beginChallege",
    "pata_scrollToCurFloor",
	
	--客服
	"serviceMyFeedRed_updata",
	"serviceMyFeedInfo_updata",
    --卡牌獲取
    "getcard_update_success",
    "getcard_update_success2",
    "update_cards_fightVal",
    "update_cardListTime",

    --任务更新
    "task_update",
    "dailyTask_update",
    "dailyScore_update",
    "task_finish",   --主线任务完成

    --邮件系统
    "update_EmailList",--更新邮件列表
    "init_emailView",
    "update_EmailList2",
    --好友系统
    "apply_update_list",
	"friend_update_list",
	"Friend_OpenInfoView",
    "black_update_list",
    "check_update_panel",
	"flash_start_timer",
	--公会系统
	"guild_up_headId",
	"guild_up_recommendedList",
	"guild_up_ApplyList",
	"guild_up_recordList",
	"guild_up_guildPlayerList",
	"guild_up_guildBaseInfo",
	"guild_up_guildBaseInfoPosTion",
	"guild_up_guildOpenBossSuc",
	"guild_up_guildSkillupLv",
	"guild_up_guildSkillResetLv",
	"guild_up_guildDivination",
	"guild_up_guildDivinationXiaoGuo",
	"guild_up_guildDivinationPlayTexiao",
	"guild_cylf_update",
	"guild_update_fissure",
	"guild_add_evet",
	"guild_exit_evet",
	"guild_Apply_upData",
	"guild_moduleshow_upData",
	--迷宫
	"maze_update_MazeView",
	"maze_check_open_getGodRes",
	
	--迷宫
	"fairyLand_updateInfo",
	"fairyLand_gotRewardUpdate",
	"fairyLand_moveComplete",
	"fairyLand_moveNextGrid",
	"fairyLand_moveNextAnim",
	"fairyLand_end",
	"fairyLand_refresh",
	"fairyLand_cancelAuto",
	"fairyLand_onRwardClose",

	--推图
	"pushMap_getCurPassPoint",
	"pushMap_updateInfo",
	"pushMap_chapterRewardRecord",
	"pushMap_updatePointInfo",
	"pushMap_updateCityInfo",
	"pushMap_figthendInfo",
	"pushMap_upChapterRewardRed",
	"pushMap_upTargetRewardRed",
	"pushMap_specificguidancepoint",
	"pushMap_shownextGuankaComp",
	"update_ActivateCtrl",
	"pushMap_jingbisa1",
	"pushMap_jingbisa2",
	"pushMap_showBarAnim",
	--世界竞技场
	"worldChallenge_HonourInfoupdateInfo",
	"worldChallenge_dianjijincai",
	"squadtomodify_change",
	"worldChallenge_daojishishuaxing",
	"worldChallenge_wodebisaianniu",
	"worldChallenge_xiasaijidaojishi",
	"worldChallenge_dianjiwodebisaixiugaizhenrong",
	"worldChallenge_jingcaiRedUp",
	--超凡段位赛
	"extraordinarylevelPvP_mainInfo",
	"extraordinarylevelPvP_zhenrongUp",
	"extraordinarylevelPvP_zijizhanji",
	"extraordinarylevelPvP_shoutongduanweijiangli",
	"extraordinarylevelPvP_gerenzongzhanji",
	"extraordinarylevelPvP_gerenzhanji",
	"extraordinarylevelPvP_wangzhezhizheng",
	"extraordinarylevelPvP_saijichuangqi",
	"extraordinarylevelPvP_saijiqchuangqi",
	"extraordinarylevelPvP_rankInfoup",
	"extraordinarylevelPvP_BattleEnd",
	--梦主擂台
	"dreamMaster_updateView",
	"dreamMaster_updateButton",
	"dreamMaster_updateState",
	"dreamMaster_updateGuess",
	"dreamMaster_dianjijincai",
	"dreamMaster_wodebisaianniu",
	"dreamMaster_playZengsong",
	--登陆奖励
	"loginSign_updateEvent",
	--活动框架刷新
	"activity_open",
	"activity_update",
	"activity_eightdayActiveupdate",
	"activity_OnlineGiftActiveupdate",
	"activity_TurnTableActiveUpdate",
	"activity_PolestarActiveupdate",
	"activity_AccumulatedAddInfoupdate",
	"activity_OnlineGiftTimeOverupdate",
	"activity_WarmakesActiveupdate",
	"activity_TimeLimitGiftActiveUpdate",
	"activity_SpecialgiftActiveUpdate",
	"activity_LimitedmarketActiveUpdate",
	"activity_AwakeningCharacterisUpdate",
	"activity_CollectMap",
	"activity_nieYingComingUpdate",
	"activity_OpenTakeWelfareTaskUpdate",
	"activity_ElvestoCollectUpdate",
	"activity_ElvestoElfSummontUpdate",
	"activity_ElvesmalActiveUpdate",
	"activity_HeroBossShop",
	"activity_CommonBossShop",
	"activity_HeroBossData",
	"activity_AnyPrepaidphoneupdate",
	"activity_GroupBuyGiftupdate",
	"activity_WarmakesElfActiveupdate",
		
	"activity_FestivalWishUpdate",
		
    "activity_SurveyQuestionUpdate",
		
		
	--主界面
	"mainui_closeQuickUse",
	"mainui_showHeroChange",
	"mainui_updateLeftTopBtns",
	"sevenday_activity_update",
	"sevenday_activity_tower_pass",


	--阵法
	"tatical_activeNew",
	"tatical_change",
	
	--训练营更新数据	
	"training_UpdateData",
	
	--英雄谷
	"heroPalace_groupAChange",
	"heroPalace_groupBChange",
	"heroPalace_crystalChange",
	"heroPalace_heroLvUp",
	--符文系统
	"rune_quit_change",
	"rune_changeSmallPage",
	"update_RuneServerData",
	"update_smallPage",
	"change_packageviewName",
	"set_runeHechengEvent",
	"set_runeResetEvent",
	"update_HeroRuneShow",
	"init_smallPageShow",
	"update_resetPage_OneListCell",
	"set_runeChangeItem",
	--极地探索
	"set_ExpeditionBigRewardEvent",
	--图鉴系统
	"handbook_titleChange",
	"handbook_pointChange",
	"handbook_refresh_jihuo",
	"handbook_state_change",
	--秘武
	"secretWeapons_getInfo",
	"secretWeapons_AddExp",
	"secretWeapons_UpLevel",
	"secretWeapons_UpStage",
	"secretWeapons_Lianhua",
	"secretWeapons_fanganxiugai",
	"secretWeapons_fangangaiming",
	"secretWeapons_fanganChoose",
	"secretWeapons_IndexIdChoose",
	"secretWeapons_shengjijinengdian",
	"secretWeapons_chongzhijinengdian",
	"secretWeapons_shuangfangmiwuinfo",
	"SecretWeaponBattleView_fightFresh",
	"SecretWeapons_reward",
	"SecretWeapons_active",
	"SecretWeaponsMainView_refresh",

	-- 委托任务
	"delegate_upWaitList",
	"delegate_upTaskList",
	--走马灯公告
	"BoradWalk_AddMsg",
	-- 问卷调查
	"QuestionnaireSurvey_upData",
	--职级系统
	"duty_listupdate",
	"update_dutyShow",
	"update_MainDutyShow",
	-- 英雄信息
	"HeroInfo_Show",
	"HeroView_initView",
	-- 限时升级活动
	"UpgradeActivity_upView",
	--英雄展示
	"show_GetCardView",
	-- VIP等级更新
	"Vip_UpLevel",
    --限时礼包
    "Event_updateTimeLimit",
    "Event_updateTimeDupLimit",
    "close_ActivityView",
    -- 超值礼包
    "PremiumGift_UpGiftData",
    -- 首充礼包
	"FirstCharge_upGiftData",
	-- 首充豪礼礼包
	"FirstChargeGift_upGiftData",
	"FirstChargeGift_upGiftclose",
    -- 集星活动
    "CollectThingView_upData",
	-- 充值
    "charge_pay",
    "charge_status_change",
    -- 无尽试炼
    "EndlessTrial_refreshFriendPanel",
    "EndlessTrial_refreshMainViewPanel",
    "EndlessTrial_refreshAddTopChallengeView",
    "EndlessTrial_refreshRewardTipsView",
    "EndlessTrial_endBuffView",
    "EndlessTrial_endRewardTipsView",
    --成长基金
    "update_Growth",

	--星辰圣所
	"PveStarTemple_Start",
	"PveStarTemple_GetAttr",
	"PveStarTemple_GetTargetTask",
	"PveStarTemple_SetAutoItem",
	"PveStarTemple_SetArrayHeroInfo",
	"PveStarTemple_Sweep",
	"PveStarTemple_EevntUse",
	"PveStarTemple_Battle",
	"PveStarTemple_ReceiveTaskReward",
	"PveStarTemple_NextLayer",
	"PveStarTemple_ItemUse",
	"PveStarTemple_BuyMall",
	"PveStarTemple_SetBttleFlag",
	"PveStarTemple_GetItemUseLimit",
	"PveStarTemple_AutoItem",
	"PveStarTemple_Reset",
	"PveStarTemple_HandleAutoItem",
	"PveStarTemple_HandleArea",
    "PveStarTemple_updateLayerReward",
		
		
    "update_FullsrGiftData",
		
	
	 --封魔之路
	"DevilRoad_Reset",--重置关卡
	"DevilRoad_MoveGrid",
	"DevilRoad_updateGrid",
	"DevilRoad_unLockLevel",
		
		
	-- 超值基金
	"SuperFundView_refreshPanel",

	-- 周卡
	"WeekCardView_refreshPanel",

	"event_getHighStarHero",

	-- 积天奖励
	"accumulative_day_activity_update",

	-- 每日礼包
	"DailyGiftBagView_refresh",

	-- 每周礼包
	"WeeklyGiftBagView_refresh",
	-- 贵族专享周礼包
	"NoBilityWeekGiftView_refresh",
	-- 每月礼包
	"MonthlyGiftBagView_refresh",
	--新服专享礼包
	"Activity_NewServerGift_GetReward",

		-- 登录就送
	"LoginSend_Entrance",

	-- 下载礼包
	"DownLoadGift_Entrance",

	-- 开工福利
	"working_welfare_activity_update",
	--购买礼包成功
	"buyGift_Success",
	--刷新限时召唤界面
	"TimeSummonView_refreshPanal",
	--委托夺宝
	"delegate_contend_activity_update",
	"update_upgetCard",

	-- 升星觉醒
	"LStarAwakeningView_refreshPanal",

	--圣所探险
	"SanctuaryAdventureView_refreshPanal",

	--祈愿商店
	"GodsLotteryShop_refreshPanal",

	-- 每周签到
	"WeeklySignInView_refreshPanal",

	-- 精灵系统
	"ElvesSystemBaseView_refreshPanal",
	"ElvesAttributeView_refreshPanal",
	"ElvesUpgradeView_refreshPanal",
	"ElvesUpstarView_refreshPanal",
	"ElvesSummonView_refreshPanal",
	"ElvesPlanView_refreshPanal",
	"ElvesPlanView_refreshListPage",
	"ElvesPlanView_refreshListInfo",
	"ElvesSystemBaseView_setPage",
	"ElvesAddTopView_refresh",
	"ElvesAddTopView_fightFresh",
	"ElvesPromoteView_refreshPanal",
	"ElvesSkin_refreshPanal", -- 精灵皮肤
	"TwistEggSignView_refresh",
	"TwistRuneView_refresh",
		
	-- 装备目标活动
	"EquipTargetView_refreshPanal",

	
	"set_lihuiPos_Event",
	"set_lihuiPos_state",--改变立绘动静状态


	-- 新周卡
	"NewWeekCardView_refreshPanal",

	-- 阵法
	"tactical_changeUseStatus",

	-- 公会  魔灵山
	"GuildMLSMain_refreshPanal", -- 主界面
	"GuildMLSSummonBoss_refreshPanal", -- 召唤界面
	"GuildMLSChallege_refreshPanal", -- 挑战界面刷新
	"GuildMLSTakeReward_refreshPanal", -- 领取奖励界面
	"GuildMLS_battleInitBossHp", -- 设置boss血条 

	-- 虚空幻境
	"Voidland_infoUpdate",
	"Voidland_upSingleList",
	"Voidland_upAssList",
	"Voidland_upMyHire",
	"voidland_updateRank",
	"Voidland_battle",

	-- 圣器系统
	"Hallow_sysInfoUpdate",
	-- 圣器副本系统
	"HallowCopy_getInfoUpdate",
	"HallowCopy_battleEndUpdate",
	"HallowCopy_UpdatecuntDown",
	-- 装备礼包活动
	"EquipGift_refreashData",

	-- 纹章
	"Emblem_emblemEquipChange",
	"Emblem_refreshBag",
	
	-- 扭蛋活动
	"TwistEggTask_refreshPanal", -- 扭蛋任务
	"TwistEggShop_refreshPanal", -- 扭蛋商店
	"TwistEggLimitGift_refreshPanal", -- 扭蛋礼包（限时商城）
	"TwistEggView_refreshPanel", -- 扭蛋
	"TwistRegimentView_refreshPanel", -- 天降神兵
	--资源找回
	"RetrieveView_refreshPanal", -- 刷新界面
	"ActATourGiftView_refresh", -- 刷新界面
	"ActFinalRewardView_refresh", -- 刷新界面
	"CardStarUpSuccessView_Close",
	"ATourRed_panelCheck",

	"ActATourLimitShop_refreshPanal", -- 精灵限时商城（巡礼商城）
		
	"CustomizedGifts_refreshPanal", --定制礼包 
	
	-- 探员集结
	"ActHeroGatherView_refreshPanal",
	--点石成金
	"GoldMagicView_refreshPanal",
	--作战行动
	"QuickBattleView_refreshPanal",
	-- 探员试炼
	"DetectiveTrialView_refreshPanal",
	"DetectiveTrialShop_refreshPanal",
	"DetectiveTrialShopTipsView_upDate",
	"DetectiveTrialGift_refreshPanal",

	-- 月慑神殿
	"MoonAweTempleChallengeView_refreshPanal",
	"MoonAweTempleView_refreshPanal",
	"MoonAweTempleRecordView_refresh",

	--神社祈福
	"ActShrineShop_refreshPanal",
	"ActShrineView_refreshPanal",
	"ActYjShopView_refreshPanal",



	-- 组队竞技
	"CrossTeamPVPMainView_refreshPanel",  		-- 主界面
	"CrossTeamPVPTeamHallView_refreshPanel", 	-- 组队大厅
	"CrossTeamPVPInviteView_refreshPanel", 		-- 邀请界面
	"CrossTeamPVPRecordOutView_refreshPanel", 	-- 战斗记录
	"CrossTeamPVPSquadSortView_refreshPanel", 	-- 阵容调整
	"CrossTeamFightAnimateView_refreshPanel", 	-- 匹配成功界面
	"CrossTeamPVPAddTopView_refreshPanel", 		-- 战斗界面
	"CrossTeamPVPRankView_refreshPanel", 		-- 排行榜
	
	-- 集物兑换
	"CollectThingShopView_refreshPanel",	 	-- 兑换商店

	-- 集字活动
	"CollectWordsActivityShopView_refreshPanel", 	-- 商店
	"CollectWordsActivityView_refreshPanel", 	
	--巅峰竞技场
	"update_stride_enterPanel",
	"update_stride_dianfenPanel",
	"update_stride_myCourse",
	"update_stride_guessMain",
	"update_stride_guessRecord",
	"update_stride_upGradeJJPvp",
	"update_stride_champtionGJPvp",
	"update_stride_GuessPanelInfo",
	"update_stride_rank",
	"battle_StrideChangeTeamType",
	"battle_StridePVPrefrush",
	"StridePVPAddTopView_refreshPanel",
	"update_stride_histroyRank",
	"update_event_combox",

	-- 跨服玩法界面
	"CrossTabView_refresh",

	-- 跨服天梯赛
	"CrossLaddersMainView_refreshPanel",
	"CrossLaddersRecordView_refreshPanel",
	"CrossLaddersHeroHouseView_refreshPanel",

	--探员宿舍
	"HeroDormitoryView_Num",
	"HeroDormitoryView_UpdateLiking",

	--时装弹窗
	"FashionLoginTips_Show",
	"FashionPreView_PlaySkill",
	"FashionPreView_EndSkill",

	--探员投票
	"PopularVote_updateData",
	"PopularVoteTask_updateData",
	"PopularVote_refreshView",
	"PopularVoteShop_refreshView",
	"PopularVote_updateItemNum",

	--消息播报
	"EventBrocast_updateInfo",


	-- 天梯冠军赛
	"CrossLaddersChampPrimaryView_refreshPanel", -- 预选赛
	"CrossLaddersChampMainView_refreshPanel", 	-- 主界面
	"CrossLaddersChampGroupView_refreshPanel", -- 分组界面
	"CrossLaddersChampQuizView_refreshPanel",
	"CrossLaddersChampQuizView_updateCountDown",
	"CrossLaddersChampRankView_refreshPanel",

	-- 协力作战
	"CooperationActivitie_timerefresh", -- 
	"CooperationActivitie_refresh", -- 保存刷新
	"CooperationActivitie_Helprefresh", -- 助力刷新
	"CommonBossShop_refreshPanal",
	"CooperationActivitie_Holpprefresh", -- 限时商城刷新
	"CooperationActivitie_ShopRefresh", -- 兑换商店刷新
	"CooperationActivitie_TogetherGetHelpReward", -- 领取助力奖励刷新
	"CooperationActivitie_gerenReward", -- 领取个人积分奖励刷新
	-- 最终奖赏2
	"ElfFinalSecondView_refreshPanel",

	--新年活动
	"NewYearActivity_BossTimesUpdate",
	"NewYearActivity_KillNumUpdate",
	"NewYearActivity_DrawTimesUpdate",
	"NewYearActivity_ContributeUpdate",
	"NewYearActivity_BossInfoUpdate",
	"NewYearActivity_NextIdUpdate",

	"reflash_CommonBossView",

	-- 元宵活动
	"LanternTask_refreshPanal",
	"LanternLimitGiftView_refreshPanal",
	"LanternShopView_refreshPanal",
	"LanternSignView_refresh",
	"LanternDrawView_refreshPanel",
	"LanternRiddleView_refreshPanel",

	"NewHeroPray_updateConvertView",
	"NewHeroPray_refreshPanal",
	"NewHeroPray_shoprefreshPanal",
}



local check = {}

--检查事件名称长度
for i, v in ipairs(EventTypeTmp) do	
	assert(string.find(v,"_")>1 and #v < 60 and not check[v])
	check[v] = true
end

local Network = require "Dex.Network.Network"

return setmetatable(EventType, {__index = function(t, k)
	assert(check[k] or Network.CheckRecvEvent(k) )
	EventType[k] = k
	return k
end})

end