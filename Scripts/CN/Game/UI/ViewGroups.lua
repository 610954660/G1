--[[
{
	["HomeView"] = {path="Module.Game.HomeView", hide=false, preview=""},
},
**
视图集合：			[table]			集合
	path			[string]		视图路径
	hide			[bool]			是否隐藏View
	resident		[bool]			是否常驻模块(永不关闭)
    isResident      [bool]			true/false
    closeOthers     [bool]			true/false 打开时需关闭其它窗口
    playSound       [bool]			true/false 是否播放打开音效
]]

return {
	GMView = {path = "Game.Modules.GM.GMView"}, --GM
	GMCheckDataView = {path = "Game.Modules.GM.GMCheckDataView"},
	GMSendMsgView = {path = "Game.Modules.GM.GMSendMsgView"},
	
	--多页面使用案例
	BagWindowTest = {path = "Game.Modules.Test.BagWindowTest"}, --多页面使用案例 继承于windowTabBar1
	
	ExampleView = {path = "Game.Modules.Example.ExampleView"},
	ControllerView = {path = "Game.Modules.Example.ControllerView"},
	oneView = {path = "Game.Modules.Example.oneView"},
	threeView = {path = "Game.Modules.Example.threeView"},
	twoView = {path = "Game.Modules.Example.twoView"},
	
	--新手引导
	GuideView = {path="Game.Modules.Guide.GuideView"},
	GuideType1View = {path="Game.Modules.Guide.GuideType1View"},
	GuideType2View = {path="Game.Modules.Guide.GuideType2View"},
	GuideEditView = {path="Game.Modules.GuideEdit.GuideEditView"},
	
	-- 创角
	GuideRoleChoseView = {path = "Game.Modules.GuideRoleChose.GuideRoleChoseView"},
	GuideSetNameView = {path = "Game.Modules.GuideRoleChose.GuideSetNameView"},
	
	PushMapFilmView = {path="Game.Modules.Film.PushMapFilmView"},
	PushMapHuiguView = {path="Game.Modules.Film.PushMapHuiguView"},
	FilmEditView = {path="Game.Modules.Film.FilmEditView"},

	--设置
	SettingView = {path="Game.Modules.Setting.SettingView"},
	GameSettingView = {path="Game.Modules.Setting.GameSettingView"},
	SoundSettingView = {path="Game.Modules.Setting.SoundSettingView"},

	--升级提示
	UpgradeView = {path="Game.Modules.UpgradeLevel.UpgradeView"},
	ModuleOpenView = {path="Game.Modules.UpgradeLevel.ModuleOpenView"},
	
	--背包
	BagWindow = {path="Game.Modules.Bag.BagWindow" , mid = ModuleId.Bag.id },
	CrystalCombineView={path="Game.Modules.Bag.CrystalCombineView", mid = ModuleId.CrystalUpgrade.id},
	BagSplitView = {path = "Game.Modules.Bag.BagSplitView"}, --背包分解
	BatchUseView = {path = "Game.Modules.Bag.BatchUseView"}, --背包使用
	BagQuickView = {path = "Game.Modules.Bag.BagQuickView"}, --背包主界面快捷使用
	ItemTips = {path = "Game.Modules.Tips.ItemTips"}, --道具tips
	ItemSpeTipsView = {path = "Game.Modules.Tips.ItemSpeTipsView"}, --自选礼包特殊处理
	ItemTipsBagView = {path="Game.Modules.Tips.ItemTipsBagView"},
	ItemTipsItemUseView = {path = "Game.Modules.Tips.ItemTipsItemUseView"}, --道具使用窗口
	ItemTipsItemSellView = {path = "Game.Modules.Tips.ItemTipsItemSellView"}, --道具出售窗口
	ItemTipsItemComposeView = {path = "Game.Modules.Tips.ItemTipsItemComposeView"}, --道具合成窗口
	ItemTipsOptionalGiftBox = {path = "Game.Modules.Tips.ItemTipsOptionalGiftBox"}, -- 多选礼包选择窗口
	ItemTipsOptionalGiftBox2 = {path = "Game.Modules.Tips.ItemTipsOptionalGiftBox2"}, -- 多选礼包 选组形式选择窗口
	ItemTipsTacticalView = {path = "Game.Modules.Tips.ItemTipsTacticalView"}, --阵法tips
	--邮件 公告
	--EmailBaseView= {path= "Game.Modules.Email.EmailBaseView",},
	EmailView = {path = "Game.Modules.Email.EmailView", mid = ModuleId.Mail.id},
	EmailContentView = {path = "Game.Modules.Email.EmailContentView"},
	-- EmailWindow = {path="Game.Modules.Email.EmailWindow",mid = ModuleId.Mail.id},

	--卡牌召唤
	GetCardsView = {path="Game.Modules.GetCards.GetCardsView",mid = ModuleId.GetCard.id},
	GetSpeCardsView = {path="Game.Modules.GetCards.GetSpeCardsView"},
	GetTyAwardShowView = {path="Game.Modules.GetCards.GetTyAwardShowView"},

	--爱心幸运召唤
	GetAixinCardsView = {path="Game.Modules.GetCards.GetAixinCardsView"},
	--获取途径
	GetCardsHelpView = {path="Game.Modules.GetCards.GetCardsHelpView"},
	GetPublicHelpView = {path="Game.Modules.GetCards.GetPublicHelpView"},
	PublicPicHelpPanel = {path="Game.UI.Global.PublicPicHelpPanel"},
	PublicRateTipsView = {path="Game.UI.Global.PublicRateTipsView"},
	ItemNotEnoughView = {path="Game.Modules.common.ItemNotEnoughView"},
	NotEnoughView = {path="Game.Modules.common.NotEnoughView"},
	--单抽成功
	GetSuccess1View = {path="Game.Modules.GetCards.GetSuccess1View"},
	GetSuccess2View = {path="Game.Modules.GetCards.GetSuccess2View"},
	GetTYSuccessView = {path="Game.Modules.GetCards.GetTYSuccessView"},
	GetTyChangeView = {path="Game.Modules.GetCards.GetTyChangeView"},

	--神虚历险
	GodMarketView = {path="Game.Modules.GodMarket.GodMarketView"},
	GodMarketMapView = {path="Game.Modules.GodMarket.GodMarketMapView"},
	GodMarketMiniMapView = {path="Game.Modules.GodMarket.GodMarketMiniMapView"},
	GodMarketResultView = {path="Game.Modules.GodMarket.GodMarketResultView"},
	GodMarketOneKeyView = {path="Game.Modules.GodMarket.GodMarketOneKeyView"},
	GodMarketEvent1View = {path="Game.Modules.GodMarket.GodMarketEvent1View"},
	GodMarketEvent3View = {path="Game.Modules.GodMarket.GodMarketEvent3View"},
	GodMarketEvent4View = {path="Game.Modules.GodMarket.GodMarketEvent4View"},
	GodMarketEvent5View = {path="Game.Modules.GodMarket.GodMarketEvent5View"},
	GodMarketRankView = {path="Game.Modules.GodMarket.GodMarketRankView"},
	GodMarketMineView = {path="Game.Modules.GodMarket.GodMarketMineView"},
	GodMarketMineListView = {path="Game.Modules.GodMarket.GodMarketMineListView"},
	
	--神墟商店
	GodMarketShopView = {path="Game.Modules.GodMarketShop.GodMarketShopView"},
	GodMarketShopTipsView = {path="Game.Modules.GodMarketShop.GodMarketShopTipsView"},

	--公共弹窗
	AlertView = {path="Game.Modules.Alert.AlertView"},
	AlertViewCost = {path="Game.Modules.Alert.AlertViewCost"},
	AlertInputComfirmView = {path="Game.Modules.Alert.AlertInputComfirmView"},
	AlertRewardView = {path="Game.Modules.UIPublic_Window.AlertRewardView"},
	
	--弹幕
	BarrageView = {path="Game.Modules.Barrage.BarrageView"},
	
	WebPageView = {path="Game.Modules.Alert.WebPageView"},
	RollTipsView = {path="Game.Modules.Alert.RollTipsView"},
	RollTipsListView = {path="Game.Modules.Alert.RollTipsListView"},
	FightPointAddView = {path="Game.Modules.Alert.FightPointAddView"},
	RollTipsGetRewardListView = {path="Game.Modules.Alert.RollTipsGetRewardListView"},
	CohesionRewardView = {path="Game.Modules.Alert.CohesionRewardView"},
	
	--公用奖励弹窗
	AwardShowView = {path="Game.Modules.Alert.AwardShowView"},
	GetHeroCardShowView = {path="Game.Modules.UIPublic_Window.GetHeroCardShowView"},
	
	--登录模块
	LoginView = {path = "Game.Modules.Login.LoginView"},
	ServerListView = {path = "Game.Modules.Login.ServerListView"},
	LoginNoticeView = {path = "Game.Modules.Login.LoginNoticeView"},
	GameNoticeView = {path = "Game.Modules.Login.GameNoticeView"},
	
	--用户界面
	PlayerInfoView = {path = "Game.Modules.Player.PlayerInfoView"},
	PlayerHeadView = {path = "Game.Modules.Player.PlayerHeadView"},
	PlayerHeadBaseView = {path = "Game.Modules.Player.PlayerHeadBaseView"},
	PlayerHeadFrameView = {path = "Game.Modules.Player.PlayerHeadFrameView"},
	PlayerCrownTitleView = {path = "Game.Modules.Player.PlayerCrownTitleView"},
	EditBoxView = {path = "Game.Modules.Player.EditBoxView"},
	MedalChooseView = {path = "Game.Modules.Player.MedalChooseView"},
	
	--无尽远征
	ExpeditionView = {path = "Game.Modules.Expedition.ExpeditionView",mid =ModuleId.EndlessRoad.id},
	EDEnemyView = {path = "Game.Modules.Expedition.EDEnemyView"},
	EDAgentListView = {path = "Game.Modules.Expedition.EDAgentListView"},
	ExpeditionTearsView = {path = "Game.Modules.Expedition.ExpeditionTearsView"},
	--图鉴
	HerobookView = {path = "Game.Modules.Handbook.HerobookView"},
	HandbookView = {path = "Game.Modules.Handbook.HandbookView",mid =ModuleId.Handbook.id},
	HeroInfoView = {path = "Game.Modules.Handbook.HeroInfoView"},
	HeroCheckView = {path = "Game.Modules.Handbook.HeroCheckView"},
	HeroDiscussView = {path = "Game.Modules.Handbook.HeroDiscussView"},
	HeroGiftView = {path = "Game.Modules.Handbook.HeroGiftView"},
	HandbookTitleView = {path = "Game.Modules.Handbook.HandbookTitleView"},
	HandbookTitleInfoView = {path = "Game.Modules.Handbook.HandbookTitleInfoView"},
	
	--推图闯关界面
	PushMapWorldMapView={path = "Game.Modules.PushMap.PushMapWorldMapView"},
	MoveChaptersView={path = "Game.Modules.PushMap.MoveChaptersView"},
	PushMapChaptersView = {path = "Game.Modules.PushMap.PushMapChaptersView"},
	PushMapCheckPointView = {path = "Game.Modules.PushMap.PushMapCheckPointView",mid =ModuleId.PushMap.id,  waitBattle = true},
	PushMapChapterRewardView = {path = "Game.Modules.PushMap.PushMapChapterRewardView"},
	PushMapInvestigationView = {path = "Game.Modules.PushMap.PushMapInvestigationView"},
	PushMapOnhookRewardView = {path = "Game.Modules.PushMap.PushMapOnhookRewardView"},
	PushMapQuickOnhookView = {path = "Game.Modules.PushMap.PushMapQuickOnhookView"},
	PushMapEndLayerView = {path = "Game.Modules.PushMap.PushMapEndLayerView"},
	PushMapTargetRewardView = {path = "Game.Modules.PushMap.PushMapTargetRewardView"},
	PushMapTargetHeroView = {path = "Game.Modules.PushMap.PushMapTargetHeroView"},
	PushMapChpterpassView = {path = "Game.Modules.PushMap.PushMapChpterpassView"},
	PushMapCityPassView = {path = "Game.Modules.PushMap.PushMapCityPassView"},
	PowerPlanView = {path = "Game.Modules.PushMap.PowerPlanView"},
	PowerFreakView = {path = "Game.Modules.PushMap.PowerFreakView"},
	PowerRewardView = {path = "Game.Modules.PushMap.PowerRewardView"},
	-- PushMapView = {path = "Game.Modules.PushMap.PushMapView"},
	-- PushMapRankView = {path = "Game.Modules.PushMap.PushMapRankView"},
	-- PushMapQuickFightView = {path = "Game.Modules.PushMap.PushMapQuickFightView"},
	-- PushMapGetBoxView = {path = "Game.Modules.PushMap.PushMapGetBoxView"},
	-- PushMapDescView = {path = "Game.Modules.PushMap.PushMapDescView"},
	--商城
	ShopView = {path = "Game.Modules.Shop.ShopView",mid = ModuleId.Shop.id},
	RechargeView = {path = "Game.Modules.Shop.RechargeView",mid = ModuleId.Recharge.id},
	ShopItemTipsView = {path = "Game.Modules.Shop.ShopItemTipsView"},
	ShopRefreshTipsView =  {path = "Game.Modules.Shop.ShopRefreshTipsView"},
	
	
	FullsrGiftView =  {path = "Game.Modules.FullsrGift.FullsrGiftView"},

	--装备
	EquipmentView = {path = "Game.Modules.Equipment.EquipmentView",mid = ModuleId.Equipment.id},
	EquipmentCompareView = {path = "Game.Modules.Equipment.EquipmentCompareView"},
	EquipmentBaseView = {path = "Game.Modules.Equipment.EquipmentBaseView"},
	EquipmentchooseView = {path = "Game.Modules.Equipment.EquipmentchooseView"},
	EquipmentHopeView = {path = "Game.Modules.Equipment.EquipmentHopeView"},
	EquipmentforgeView = {path = "Game.Modules.Equipment.EquipmentforgeView"},
	EquipmentSkillTipsView = {path = "Game.Modules.Equipment.EquipmentSkillTipsView"},
	EquiMentListView   = {path = "Game.Modules.Equipment.EquiMentListView"},
	EquipmentSkillView   = {path = "Game.Modules.Equipment.EquipmentSkillView"},
	EquipmentRecastView = {path = "Game.Modules.Equipment.EquipmentRecastView"},
	EquipmentUpstarView = {path = "Game.Modules.Equipment.EquipmentUpstarView"},
	EquipmentUpStageView = {path = "Game.Modules.Equipment.EquipmentUpStageView"},
	UniqueWeaponTipsView = {path = "Game.Modules.Equipment.UniqueWeaponTipsView"},
	UniqueWeaponUpgradeView = {path = "Game.Modules.Equipment.UniqueWeaponUpgradeView"},
	
    TestUIView = {path = "Game.Modules.Test.TestUIView",hide = true,isResident= false,closeOthers = false,playSound = false},
    LoadingView = {path = "Game.Modules.Loading.LoadingView"},
    TestUIViewG1 = {path = "Game.Modules.Test.TestUIViewG1"}, --测试面板UI
    GLoaderView = {path = "Game.Modules.Test.GLoaderView"},
    MainUIView = {path = "Game.Modules.MainUI.MainUIView"},--常驻UI
	MainHeroSetView = {path = "Game.Modules.MainUI.MainHeroSetView"},
	MainSubBtnView = {path = "Game.Modules.MainUI.MainSubBtnView"},
	MainSubBtn2View = {path = "Game.Modules.MainUI.MainSubBtn2View"},
	CrossTabView = {path = "Game.Modules.MainUI.CrossTabView"},
	SubBtnView = {path = "Game.Modules.MainUI.SubBtnView"},
	--卡牌库
	CardDetailsView = {path = "Game.Modules.Card.CardDetailsView"},
	CardBagView = {path = "Game.Modules.Card.CardBagView",mid = ModuleId.Hero.id },
	CardHandBookView = {path = "Game.Modules.Card.CardHandBookView", mid=ModuleId.Handbook.id},
	--CardDetailsUpStar = {path = "Game.Modules.Card.CardDetailsUpStar"},
	CardDetailsUpStarChoose = {path = "Game.Modules.Card.CardDetailsUpStarChoose"},
	CardInfoView = {path = "Game.Modules.Card.CardInfoView", mid = ModuleId.CardInfo.id},
	CardInfoDetailView = {path = "Game.Modules.Card.CardInfoDetailView"},
	MatchPointView = {path = "Game.Modules.Card.MatchPointView"},
	MatchPointTipsView = {path = "Game.Modules.Card.MatchPointTipsView"},
	CardInfoStarUpView = {path = "Game.Modules.Card.CardInfoStarUpView"},
	CardInfoStepUpView = {path = "Game.Modules.Card.CardInfoStepUpView"},
	CardStepUpSuccessView = {path = "Game.Modules.Card.CardStepUpSuccessView"},
	CardStarUpSuccessView = {path = "Game.Modules.Card.CardStarUpSuccessView"},
	CardSkillUpView = {path = "Game.Modules.Card.CardSkillUpView"},
	CardInfoShowView = {path = "Game.Modules.Card.CardInfoShowView"},
	CardInfoTalentView = {path = "Game.Modules.Card.CardInfoTalentView"},
	CardTalentLearnSkillView = {path = "Game.Modules.Card.CardTalentLearnSkillView"},
	CardTalentActiveSkillView = {path = "Game.Modules.Card.CardTalentActiveSkillView"},
	CardAttrView = {path = "Game.Modules.Card.CardAttrView"},
	CardChooseView = {path = "Game.Modules.Card.CardChooseView"},
	CardQuickStarUpView = {path = "Game.Modules.Card.CardQuickStarUpView"},
	HeroResetView = {path = "Game.Modules.HeroReset.HeroResetView"},
	 CardUpstarPreview = {path = "Game.Modules.Card.CardUpstarPreview"},--卡牌升星预览
	CardResettheView = {path = "Game.Modules.Card.CardResettheView"},--卡牌转换
	CardResettheChooseView = {path = "Game.Modules.Card.CardResettheChooseView"},--卡牌转换
	CardResetSuccessView = {path = "Game.Modules.Card.CardResetSuccessView"},--卡牌转换
	CardHelpView = {path = "Game.Modules.Card.CardHelpView"},
	CardTalentSkillTipsView = {path = "Game.Modules.Card.CardTalentSkillTipsView"},
	CardDetailsSkillActiveView={path="Game.Modules.Card.CardDetailsSkillActiveView"},
	CardLearnSkillView={path="Game.Modules.Card.CardLearnSkillView"},
	CardCombineSureView={path="Game.Modules.Card.CardCombineSureView"},
	
	CardDetailsDecompose={path="Game.Modules.Card.CardDetailsDecompose",mid = ModuleId.CardDecompose.id},
	CardDecomposeSetting={path="Game.Modules.Card.CardDecomposeSetting"},
	
	CardSegmentView={path="Game.Modules.Card.CardSegmentView"},
	CardSegmentPreView={path="Game.Modules.Card.CardSegmentPreView"},
	CardSegmentChoseView = {path="Game.Modules.Card.CardSegmentChoseView"},
	
	--战斗
	BattlePrepareView={path="Game.Modules.Battle.BattlePrepareView", waitBattle = true},
	BattleBeginView={path="Game.Modules.Battle.BattleBeginView"},
	BattleSecnesView={path="Game.Modules.Battle.BattleSecnesView"},
	BattleSettleView={path="Game.Modules.Battle.BattleSettleView"},
	BattleBuffView={path="Game.Modules.Battle.BattleBuffView"},
	BattleTestView={path="Game.Modules.Battle.BattleTestView"},
	BattledataView={path="Game.Modules.Battle.BattledataView"},
	BattleCampView={path="Game.Modules.Battle.BattleCampView"},
	BattleRaceView={path="Game.Modules.Battle.BattleRaceView"},
	BatteSpeedView={path="Game.Modules.Battle.BatteSpeedView"},
	
	--测试面板
	BattleEditView={path="Game.Modules.BattleEdit.BattleEditView"},
	
	--测试面板
	CardTestView={path="Game.Modules.Public.CardTestView"},
	--竞技场
	ArenaPerformView={path="Game.Modules.Arena.ArenaPerformView",mid = ModuleId.Arena.id, waitBattle = true},
	ArenaRecordView={path="Game.Modules.Arena.ArenaRecordView"},
	ChallengeView={path="Game.Modules.Arena.ChallengeView"},
	ArenaRewardView={path="Game.Modules.Arena.ArenaRewardView"},
	ArenaShopView={path="Game.Modules.Arena.ArenaShopView", mid = ModuleId.Arena.id},
	
 
	-- 聊天
	ChatTextView={path="Game.Modules.Chat.ChatTextView",mid = ModuleId.Chat.id},
	ChatView={path="Game.Modules.Chat.ChatView",mid = ModuleId.Chat.id},
	ChatFaceView={path="Game.Modules.Chat.ChatFaceView"},
	VideoLibraryView={path="Game.Modules.Chat.VideoLibraryView"},
	ShareVideoView={path="Game.Modules.Chat.ShareVideoView"},
	ChatSettingView={path="Game.Modules.Chat.ChatSettingView"},
	ChatPlayTipsView={path="Game.Modules.Chat.ChatPlayTipsView"},
	HigerRecordView={path="Game.Modules.Chat.HigerRecordView"},
	ArenaVideoView={path="Game.Modules.Chat.ArenaVideoView",mid = ModuleId.ArenaVideo.id},
	WorldArenaVideoView={path="Game.Modules.Chat.WorldArenaVideoView"},
	ChatPlayShareView={path="Game.Modules.Chat.ChatPlayShareView"},
	ChatStudioRecordingView={path="Game.Modules.Chat.ChatStudioRecordingView"},
	testChatView={path="Game.Modules.Chat.testChatView"},
	ChatGiftView={path="Game.Modules.Chat.ChatGiftView"},
	ChatGiftReceiveView={path="Game.Modules.Chat.ChatGiftReceiveView"},
	--爬塔
	
	
	PataView={path="Game.Modules.Pata.PataView",mid = ModuleId.Tower.id},
	--PataEndLayer={path="Game.Modules.Pata.PataEndLayer"},
	PataChooseView={path="Game.Modules.Pata.PataChooseView", mid = ModuleId.TowerRace.id},
	PataRankReward={path="Game.Modules.Pata.PataRankReward"},
	PataPlayerView={path="Game.Modules.Pata.PataPlayerView"},
	PataRecordView={path="Game.Modules.Pata.PataRecordView"},	
	PataBigReWard={path="Game.Modules.Pata.PataBigReWard"},

	--材料副本
	MaterialCopyView = {path = "Game.Modules.MaterialCopy.MaterialCopyView",mid = ModuleId.Copy.id,  waitBattle = true},
	MateriCopyEndLayer = {path = "Game.Modules.MaterialCopy.MateriCopyEndLayer"},

	--任务
	TaskView = {path="Game.Modules.Task.TaskView",mid = ModuleId.Task.id},
	DailyTaskView = {path="Game.Modules.Task.DailyTaskView",mid = ModuleId.Task.id},
	AchievementView = {path="Game.Modules.Task.AchievementView",mid = ModuleId.Task.id},
	WeekDailyView = {path="Game.Modules.Task.WeekDailyView",mid = ModuleId.Task.id},
	EveryDailyView = {path="Game.Modules.Task.EveryDailyView",mid = ModuleId.Task.id},
	--好友系统
	FriendBaseView = {path="Game.Modules.Friend.FriendBaseView", mid = ModuleId.Friend.id},
	FriendCheckView = {path="Game.Modules.Friend.FriendInfoView"},
	ViewPlayerView = {path="Game.Modules.PlayerInfo.ViewPlayerView"},
	FriendView = {path="Game.Modules.Friend.FriendView"},
    FriendapplyView = {path="Game.Modules.Friend.FriendapplyView"},
    FriendsearchView = {path="Game.Modules.Friend.FriendsearchView"},
    FriendblacklistView = {path="Game.Modules.Friend.FriendblacklistView"},
	
	--公会
	GuildMallView = {path="Game.Modules.Guild.GuildMallView", mid = ModuleId.Guild.id},
	GuildMainView = {path="Game.Modules.Guild.GuildMainView"},
	GuildEditNoticeView = {path="Game.Modules.Guild.GuildEditNoticeView"},
	GuildListView = {path="Game.Modules.Guild.GuildListView", mid = ModuleId.Guild.id},
	GuildHeadView = {path="Game.Modules.Guild.GuildHeadView"},
	GuildManageListView = {path="Game.Modules.Guild.GuildManageListView"},
	GuildSettingView = {path="Game.Modules.Guild.GuildSettingView"},
	GuildReNameView = {path="Game.Modules.Guild.GuildReNameView"},
	GuildApplyView = {path="Game.Modules.Guild.GuildApplyView"},
	GuildBossView = {path="Game.Modules.Guild.GuildBossView"},
	GuildBossSweepView = {path="Game.Modules.Guild.GuildBossSweepView"},
	--GuildBossRankView = {path="Game.Modules.Guild.GuildBossRankView"},
	GuildDvinationView = {path="Game.Modules.Guild.GuildDvinationView"},
	GuildskillsOpenView = {path="Game.Modules.Guild.GuildskillsOpenView"},
	GuildskillsView = {path="Game.Modules.Guild.GuildskillsView"},
	GuildBossEndLayerView = {path="Game.Modules.Guild.GuildBossEndLayerView"},
	GuildFissureEndLayerView = {path="Game.Modules.Guild.GuildFissureEndLayerView"},
	GuildFissureView = {path="Game.Modules.Guild.GuildFissureView"},
	GuildFissureTargetRewardView = {path="Game.Modules.Guild.GuildFissureTargetRewardView"},
	GuildHourseView = {path="Game.Modules.GuildHourse.GuildHourseView"},
	GuildBuyTipsView = {path="Game.Modules.GuildHourse.GuildBuyTipsView"},
	GuildAllRecordView = {path="Game.Modules.GuildHourse.GuildAllRecordView"},

	--排行榜
	RankView = {path="Game.Modules.Rank.RankView"},
	GuildBossRankView = {path="Game.Modules.Rank.GuildBossRankView"},
	HeroRankView = {path="Game.Modules.Rank.HeroRankView"},
	EndlessRankView = {path="Game.Modules.Rank.EndlessRankView"},
	PublicRankView = {path="Game.Modules.Rank.PublicRankView"},
	PublicRankView2 = {path="Game.Modules.Rank.PublicRankView2"},
	PataRankView = {path="Game.Modules.Rank.PataRankView"},
	FairyLandRankView = {path="Game.Modules.Rank.FairyLandRankView"},
	GuildFissuseRankView = {path="Game.Modules.Rank.GuildFissuseRankView"},
	GuildFissuseTipRankView = {path="Game.Modules.Rank.GuildFissuseTipRankView"},
	BloodAbyssRankView = {path="Game.Modules.Rank.BloodAbyssRankView"},
	
	
	PublicRankRewardView = {path="Game.Modules.Rank.PublicRankRewardView"},
	TaskRankRewardView = {path="Game.Modules.Rank.TaskRankRewardView"},
	
	RankMainView = {path="Game.Modules.Rank.RankMainView",mid = ModuleId.RankMain.id},

	--迷宫系统
	MazeView = {path="Game.Modules.Maze.MazeView",mid = ModuleId.Maze.id},
	GoddessTearsView = {path="Game.Modules.Maze.GoddessTearsView"},
	GodResView = {path="Game.Modules.Maze.GodResView"},
	HeroListView = {path="Game.Modules.Maze.HeroListView"},
	HireTipView = {path="Game.Modules.Maze.HireTipView"},
	HotSpringTipView = {path="Game.Modules.Maze.HotSpringTipView"},
	MonsterTipView = {path="Game.Modules.Maze.MonsterTipView"},
	ShopTipView = {path="Game.Modules.Maze.ShopTipView"},
	GodResGetView = {path="Game.Modules.Maze.GodResGetView"},
	
	
	--秘境
	FairyLandView = {path="Game.Modules.FairyLand.FairyLandView",mid = ModuleId.FairyLand.id, waitBattle = true},
	FairyLandQuestionView = {path="Game.Modules.FairyLand.FairyLandQuestionView"},
	FairyLandTreasureRewardView = {path = "Game.Modules.FairyLand.FairyLandTreasureRewardView"},


	--登录奖励
	LoginAwardView = {path="Game.Modules.LoginAward.LoginAwardView"},
	DailySignView = {path="Game.Modules.LoginAward.DailySignView"},
	ActivationCodeView = {path="Game.Modules.LoginAward.ActivationCodeView"},
	GrowthFundView = {path="Game.Modules.LoginAward.GrowthFundView"},

	--活动UI框架1
	ActivityFrameViewBase = {path="Game.Modules.ActivityFrame.ActivityFrameViewBase"},
	ActivityFrameView = {path="Game.Modules.ActivityFrame.ActivityFrameView"},
	ActivityFrame1View = {path="Game.Modules.ActivityFrame.ActivityFrame1View"},
	ActivityFrame2View = {path="Game.Modules.ActivityFrame.ActivityFrame2View"},
	ActivityFrame3View = {path="Game.Modules.ActivityFrame.ActivityFrame3View"},
	ActivityFrame4View = {path="Game.Modules.ActivityFrame.ActivityFrame4View"},
	ActivityFrame5View = {path="Game.Modules.ActivityFrame.ActivityFrame5View"},
	ActivityFrame6View = {path="Game.Modules.ActivityFrame.ActivityFrame6View"},
	ActivityFrame7View = {path="Game.Modules.ActivityFrame.ActivityFrame7View"},
	ActivityFrame8View = {path="Game.Modules.ActivityFrame.ActivityFrame8View"},
	ActivityFrame9View = {path="Game.Modules.ActivityFrame.ActivityFrame9View"},	
	--public_reward
	ReWardView={path="Game.Modules.UIPublic_ReWard.ReWardView"},
	AwardView={path="Game.Modules.UIPublic_ReWard.AwardView"},

	--开服活动七天任务
	SevenDayActView={path="Game.Modules.SevenDayActivity.SevenDayActView"},
	-- 冒险日记
	AdventureDiaryView={path="Game.Modules.SevenDayActivity.AdventureDiaryView"},
	
	--阵法
	TacticalView={path="Game.Modules.Tactical.TacticalView",mid = ModuleId.Tactical.id},
	TacticalActiveHintView={path="Game.Modules.Tactical.TacticalActiveHintView"},
	
	--UI框架內活動
	--英雄谷
	HeroPalaceView={path="Game.Modules.HeroPalace.HeroPalaceView", mid = ModuleId.HeroPalace.id},
	HeroPalaceRemoveView={path="Game.Modules.HeroPalace.HeroPalaceRemoveView"},
	HeroPalaceUpLvView={path="Game.Modules.HeroPalace.HeroPalaceUpLvView"},
	
	
	EightDayActView={path="Game.Modules.OperatingActivities.EightDayActView"},
	OnlineGiftBagView={path="Game.Modules.OperatingActivities.OnlineGiftBagView"},
	TurnTableView = {path = "Game.Modules.TurnTable.TurnTableView", mid =ModuleId.TurnTable.id},
	TurnTableLuckyView = {path = "Game.Modules.TurnTable.TurnTableLuckyView"},

	PolestarActiveView = {path = "Game.Modules.OperatingActivities.PolestarActiveView"},
	PolestarPayInfoView = {path = "Game.Modules.OperatingActivities.PolestarPayInfoView"},
	RuneActiveView = {path = "Game.Modules.OperatingActivities.RuneActiveView"},--符文礼包
	
	AnyPrepaidphoneView = {path = "Game.Modules.OperatingActivities.AnyPrepaidphoneView"},
	EverDayAccumulatedView = {path = "Game.Modules.OperatingActivities.EverDayAccumulatedView"},
	AccumulatedAddMoneyView = {path = "Game.Modules.OperatingActivities.AccumulatedAddMoneyView"},
	AccumulatedAddMoneyView1 = {path = "Game.Modules.OperatingActivities.AccumulatedAddMoneyView1"},
	WarmakesActiveView = {path = "Game.Modules.OperatingActivities.WarmakesActiveView"},
	WarmakesPayInfoView = {path = "Game.Modules.OperatingActivities.WarmakesPayInfoView"},
	UpGetCardActivityView={path="Game.Modules.UpGetCardActivity.UpGetCardActivityView"},
	UpGetAwardView={path="Game.Modules.UpGetCardActivity.UpGetAwardView"},
	UpGetHelpView={path="Game.Modules.UpGetCardActivity.UpGetHelpView"},	
	LimitedmarketView = {path = "Game.Modules.OperatingActivities.LimitedmarketView"},
	
	AwakeningCharacteristicsView = {path = "Game.Modules.OperatingActivities.AwakeningCharacteristicsView"},
	NieYinComingView = {path = "Game.Modules.OperatingActivities.NieYinComingView"},
	OpenTakeWelfareTaskView = {path = "Game.Modules.OperatingActivities.OpenTakeWelfareTaskView"},
	WarmakesElfActiveView = {path = "Game.Modules.OperatingActivities.WarmakesElfActiveView"},
	WarmakesSmallElfActiveView = {path = "Game.Modules.OperatingActivities.WarmakesSmallElfActiveView"},
	WarmakesCriticalActiveView = {path = "Game.Modules.OperatingActivities.WarmakesCriticalActiveView"},	
	WarmakesPolaarActiveView = {path = "Game.Modules.OperatingActivities.WarmakesPolaarActiveView"},	
	WarmakesElfPayInfoView = {path = "Game.Modules.OperatingActivities.WarmakesElfPayInfoView"},
	ohterOneEveryAddMoneyView = {path = "Game.Modules.OperatingActivities.ohterOneEveryAddMoneyView"},	
	WarmakesMazeActiveView = {path = "Game.Modules.OperatingActivities.WarmakesMazeActiveView"},	
	WarmakesHallowsActiveView = {path = "Game.Modules.OperatingActivities.WarmakesHallowsActiveView"},	

	ElvestoCollectActiveView = {path = "Game.Modules.OperatingActivities.ElvestoCollectActiveView"},
	ElvesCalledActiveView = {path = "Game.Modules.OperatingActivities.ElvesCalledActiveView"},
	ElvesmalActivelView = {path = "Game.Modules.OperatingActivities.ElvesmalActivelView"},
	GroupBuyGiftView = {path = "Game.Modules.OperatingActivities.GroupBuyGiftView"},
	--符文系統 主页为RuneSystemView
	RuneSystemView = {path="Game.Modules.RuneSystem.RuneSystemView"},
	RunPackageView = {path="Game.Modules.RuneSystem.RunPackageView"},
	RuneSkillView = {path="Game.Modules.RuneSystem.RuneSkillView"},
	RuneResetView = {path="Game.Modules.RuneSystem.RuneResetView"},
	RuneCompoundView = {path="Game.Modules.RuneSystem.RuneCompoundView"},
	RuneBagView = {path="Game.Modules.RuneSystem.RuneBagView"},
	RuneChooseView = {path="Game.Modules.RuneSystem.RuneChooseView"},
	RuneEditBoxView = {path="Game.Modules.RuneSystem.RuneEditBoxView"},
	RuneSelectView = {path="Game.Modules.RuneSystem.RuneSelectView"},
	RuneHeroChooseView = {path="Game.Modules.RuneSystem.RuneHeroChooseView"},
	RuneHeroDemountView = {path="Game.Modules.RuneSystem.RuneHeroDemountView"},
	RuneHeroShowView = {path="Game.Modules.RuneSystem.RuneHeroShowView"},
	RunePreView = {path="Game.Modules.RuneSystem.RunePreView"},
	RuneTipsView = {path="Game.Modules.RuneSystem.RuneTipsView"},
	
	

	--世界擂台赛
	WorldChallengeView = {path="Game.Modules.WorldChallenge.WorldChallengeView", mid = ModuleId.Arena.id},
	WorldChallengeMainView = {path="Game.Modules.WorldChallenge.WorldChallengeMainView"},
	WorldChallengeQuizView = {path="Game.Modules.WorldChallenge.WorldChallengeQuizView"},
	WorldChallengeHallPlayerView = {path="Game.Modules.WorldChallenge.WorldChallengeHallPlayerView"},
	WorldChallengeIntegralView = {path="Game.Modules.WorldChallenge.WorldChallengeIntegralView"},
	WorldChallengeRewardView = {path="Game.Modules.WorldChallenge.WorldChallengeRewardView"},
	WorldChallengeGuessRecordView = {path="Game.Modules.WorldChallenge.WorldChallengeGuessRecordView"},
	--超凡段位赛
	ExtraordinarylevelMainView = {path="Game.Modules.ExtraordinarylevelPvP.ExtraordinarylevelMainView"},	
	ExtraordinaryMatchingView = {path="Game.Modules.ExtraordinarylevelPvP.ExtraordinaryMatchingView"},
	ExtraordinaryAnimationView = {path="Game.Modules.ExtraordinarylevelPvP.ExtraordinaryAnimationView"},
	ExtraordinaryPVPBattleView = {path="Game.Modules.ExtraordinarylevelPvP.ExtraordinaryPVPBattleView"},
	ExtraordinarylevelRecordtView = {path="Game.Modules.ExtraordinarylevelPvP.ExtraordinarylevelRecordtView"},
	ExtraordinaryRewardsView = {path="Game.Modules.ExtraordinarylevelPvP.ExtraordinaryRewardsView"},
	ExtraordinaryleveTaleView = {path="Game.Modules.ExtraordinarylevelPvP.ExtraordinaryleveTaleView"},	
	ExtraordinaryPersonalrecordView = {path="Game.Modules.ExtraordinarylevelPvP.ExtraordinaryPersonalrecordView"},	
	ExtraordinarylevelRankView = {path="Game.Modules.ExtraordinarylevelPvP.ExtraordinarylevelRankView"},	
	ExtraordinaryKingView = {path="Game.Modules.ExtraordinarylevelPvP.ExtraordinaryKingView"},	
	ExtraordinaryKingbountyView = {path="Game.Modules.ExtraordinarylevelPvP.ExtraordinaryKingbountyView"},	
	ExtraordinaryDeclareView = {path="Game.Modules.ExtraordinarylevelPvP.ExtraordinaryDeclareView"},	
	ExtraordinaryPVPjingjiSucView = {path="Game.Modules.ExtraordinarylevelPvP.ExtraordinaryPVPjingjiSucView"},	
	ExtraordinaryPVPjingjiLoseView = {path="Game.Modules.ExtraordinarylevelPvP.ExtraordinaryPVPjingjiLoseView"},	
	ExtraordinarEndLayerView = {path="Game.Modules.ExtraordinarylevelPvP.ExtraordinarEndLayerView"},	
	ExtraordinarBuyView = {path="Game.Modules.ExtraordinarylevelPvP.ExtraordinarBuyView"},	
	ExtraordinaryleveResultView = {path="Game.Modules.ExtraordinarylevelPvP.ExtraordinaryleveResultView"},	
	-- 委托任务
	DelegateView = {path = "Game.Modules.Delegate.DelegateView"},
	DelegateHeroChoseView = {path = "Game.Modules.Delegate.DelegateHeroChoseView"},

	-- 摇钱树
	GoldTreeView = {path = "Game.Modules.GoldTree.GoldTreeView"},
	--广播页面

	BroadcastView = {path = "Game.Modules.Broadcast.BroadcastView",isResident=true}, --常驻UI
	-- 问卷调查
	QuesSurveyView = {path = "Game.Modules.QuestionnaireSurvey.QuesSurveyView"},
	--客服
	ServiceCommitView = {path = "Game.Modules.ServiceCommit.ServiceCommitView"},
	-- 帮助系统 
	HelpSystemView = {path = "Game.Modules.HelpSystem.HelpSystemView", mid = ModuleId.Help.id},
	HelpSysStrongView = {path = "Game.Modules.HelpSystem.HelpSysStrongView"},
	HelpSysQuestionView = {path = "Game.Modules.HelpSystem.HelpSysQuestionView"},
	HelpSysRecomView = {path = "Game.Modules.HelpSystem.HelpSysRecomView"},
	HelpSysGroupView = {path = "Game.Modules.HelpSystem.HelpSysGroupView"},
	HelpTacticalView = {path = "Game.Modules.HelpSystem.HelpTacticalView"},
	HelpHallowView = {path = "Game.Modules.HelpSystem.HelpHallowView"},
	HelpTalentView = {path = "Game.Modules.HelpSystem.HelpTalentView"},
	HelpEmblemView = {path = "Game.Modules.HelpSystem.HelpEmblemView"},
	--职级系统
	DutyView = {path = "Game.Modules.Duty.DutyView"},
	DutyWatchView = {path = "Game.Modules.Duty.DutyWatchView"},
	DutySuccessView = {path = "Game.Modules.Duty.DutySuccessView"},
	-- 限时升级
	UpgradeActivityView = {path = "Game.Modules.UpgradeActivity.UpgradeActivityView"},
	-- 英雄信息
	HeroView = {path = "Game.Modules.HeroInfo.HeroView"},
	-- 直购礼包
	MoneyBuyGiftView = {path = "Game.Modules.MoneyBuyGift.MoneyBuyGiftView"},
	-- 首充礼包
	FirstChargeView = {path = "Game.Modules.FirstCharge.FirstChargeView", mid = ModuleId.FirstCharge.id},
	--首充豪礼礼包
	FirstChargeLuxuryGiftView = {path = "Game.Modules.FirstChargeLuxuryGift.FirstChargeLuxuryGiftView", mid = ModuleId.FirstChargeLuxuryGift.id},
	-- 充值
	RechargeBaseView = {path = "Game.Modules.Recharge.RechargeBaseView"},
	VipView = {path = "Game.Modules.Vip.VipView"},
	VipUpLevelView = {path = "Game.Modules.Vip.VipUpLevelView"},
	VipMemberView = {path = "Game.Modules.VipMember.VipMemberView"},
	DressRechargeView = {path = "Game.Modules.Recharge.DressRechargeView"},
	-- 特权购买
	PriviligeGiftView = {path = "Game.Modules.PriviligeGift.PriviligeGiftView"},
	PriviligeGiftTipsView = {path = "Game.Modules.PriviligeGift.PriviligeGiftTipsView"},
	TimeLimitGiftView = {path = "Game.Modules.TimeLimitGift.TimeLimitGiftView"},
	backgroundTimeLimitGiftView = {path = "Game.Modules.TimeLimitGift.backgroundTimeLimitGiftView"},
	TimeLimitGiftDupView = {path = "Game.Modules.TimeLimitDupGift.TimeLimitGiftDupView"},	-- 超值礼包
	PremiumGiftView = {path = "Game.Modules.PremiumGift.PremiumGiftView"},

	-- 集物活动
	CollectThingView = {path = "Game.Modules.CollectThing.CollectThingView"},

	-- 饰品
	JewelryChoseListView = {path = "Game.Modules.Jewelry.JewelryChoseListView"},
	JewelryMergeView = {path = "Game.Modules.Jewelry.JewelryMergeView"},
	JewelryRebuildView = {path = "Game.Modules.Jewelry.JewelryRebuildView"},
	JewelryCompareView = {path = "Game.Modules.Jewelry.JewelryCompareView"},
	JewelryExchangeTipView = {path = "Game.Modules.Jewelry.JewelryExchangeTipView"},
	JewelrySkillView = {path = "Game.Modules.Jewelry.JewelrySkillView"},

	-- 秘武
	SecretWeaponsMainView = {path = "Game.Modules.SecretWeapons.SecretWeaponsMainView"},
	SecretWeaponsGetView = {path = "Game.Modules.SecretWeapons.SecretWeaponsGetView"},
	SecretWeaponStrainView = {path = "Game.Modules.SecretWeapons.SecretWeaponStrainView"},
	SecretWeaponAddattrView = {path = "Game.Modules.SecretWeapons.SecretWeaponAddattrView"},
	SecretWeaponDeployView = {path = "Game.Modules.SecretWeapons.SecretWeaponDeployView"},
	SecretWeaponPromoteView = {path = "Game.Modules.SecretWeapons.SecretWeaponPromoteView"},
	SecretWeaponRenameView = {path = "Game.Modules.SecretWeapons.SecretWeaponRenameView"},
	SecretWeaponsBreakView = {path = "Game.Modules.SecretWeapons.SecretWeaponsBreakView"},
	SecretWeaponAddTopView = {path = "Game.Modules.SecretWeapons.SecretWeaponAddTopView"},
	SecretWeaponBattleView = {path = "Game.Modules.SecretWeapons.SecretWeaponBattleView"},
	SecretWeaponsRefinedView = {path = "Game.Modules.SecretWeapons.SecretWeaponsRefinedView", mid = ModuleId.SecretWeaponsRefined.id},
	SecretWeaponActiveView = {path = "Game.Modules.SecretWeapons.SecretWeaponActiveView"},
	SecretWeaponTaskView = {path = "Game.Modules.SecretWeapons.SecretWeaponTaskView"},
	
	-- 无尽试炼
	EndlessTrialMainView = {path = "Game.Modules.EndlessTrial.EndlessTrialMainView",mid = ModuleId.EndlessTrial.id},
	EndlessTrialSecondView = {path = "Game.Modules.EndlessTrial.EndlessTrialSecondView",mid = ModuleId.EndlessTrialSecond.id},
	EndlessFirstRewardView = {path = "Game.Modules.EndlessTrial.EndlessFirstRewardView"},
	EndlessFriendSupportView = {path = "Game.Modules.EndlessTrial.EndlessFriendSupportView"},
	EndlessFriendSupportTipsView = {path = "Game.Modules.EndlessTrial.EndlessFriendSupportTipsView"},
	EndlessSelectBuffView 	= {path = "Game.Modules.EndlessTrial.EndlessSelectBuffView"},
	AddTopChallengeView 	= {path = "Game.Modules.EndlessTrial.AddTopChallengeView"},
	EndlessRewardTipsView 	= {path = "Game.Modules.EndlessTrial.EndlessRewardTipsView"},

	-- 月卡
	MonthlyCardView = {path = "Game.Modules.MonthlyCard.MonthlyCardView"},

	--星辰圣所
	PveStarTempleMainView = {path = "Game.Modules.PveStarTemple.PveStarTempleMainView"},
	PveStarTempleSelectView = {path = "Game.Modules.PveStarTemple.PveStarTempleSelectView"},
	PveStarTempleMedcineView = {path = "Game.Modules.PveStarTemple.PveStarTempleMedcineView"},
	PveStarTempleAcidView = {path = "Game.Modules.PveStarTemple.PveStarTempleAcidView"},
	PveStarTempleExploreStoreView = {path = "Game.Modules.PveStarTemple.PveStarTempleExploreStoreView"},
	PveStarTempleMysteryStoreView = {path = "Game.Modules.PveStarTemple.PveStarTempleMysteryStoreView"},
	PveStarTempleRankView = {path = "Game.Modules.PveStarTemple.PveStarTempleRankView"},
	PveStarTempleTaskView = {path = "Game.Modules.PveStarTemple.PveStarTempleTaskView"},
	PveStarTempleBuffView = {path = "Game.Modules.PveStarTemple.PveStarTempleBuffView"},
	PveStarTempleFightView = {path = "Game.Modules.PveStarTemple.PveStarTempleFightView"},
	PveStarTempleNpcView = {path = "Game.Modules.PveStarTemple.PveStarTempleNpcView"},
	PveStarTempleManView = {path = "Game.Modules.PveStarTemple.PveStarTempleManView"},
	PveStartTempleSundriesView = {path = "Game.Modules.PveStarTemple.PveStartTempleSundriesView"},
	PveStarTempleCardView = {path = "Game.Modules.PveStarTemple.PveStarTempleCardView"},
	PveStarTempleCardResultView = {path = "Game.Modules.PveStarTemple.PveStarTempleCardResultView"},
	PveStarTempleLockBoxView = {path = "Game.Modules.PveStarTemple.PveStarTempleLockBoxView"},
	PveStarTempleStartAnswerView = {path = "Game.Modules.PveStarTemple.PveStarTempleStartAnswerView"},
	PveStarTempleAnswerView = {path = "Game.Modules.PveStarTemple.PveStarTempleAnswerView"},
	PveStarTempleRewardView = {path = "Game.Modules.PveStarTemple.PveStarTempleRewardView"},

	-- 高阶竞技场
	HigherPvPView = {path = "Game.Modules.HigherPvP.HigherPvPView"},
	HigherPvPMatchView = {path = "Game.Modules.HigherPvP.HigherPvPMatchView"},
	HigherPvPTicketView = {path = "Game.Modules.HigherPvP.HigherPvPTicketView"},
	HigherRewardView = {path = "Game.Modules.HigherPvP.HigherRewardView"},
	AddHPvPPrebattleView = {path = "Game.Modules.HigherPvP.AddHPvPPrebattleView"},
	HigherPvPHistoryView = {path = "Game.Modules.HigherPvP.HigherPvPHistoryView"},
	HigherPvPResultView = {path = "Game.Modules.HigherPvP.HigherPvPResultView"},
	HigherPvPPlayerInfoView = {path = "Game.Modules.HigherPvP.HigherPvPPlayerInfoView"},
	HigherPvPUpRankView = {path = "Game.Modules.HigherPvP.HigherPvPUpRankView"},

	-- 超值基金
	SuperFundView 	= {path = "Game.Modules.SuperFund.SuperFundView",mid = ModuleId.SuperFund.id},
	WeekCardView 	= {path = "Game.Modules.WeekCard.WeekCardView",mid = ModuleId.WeekCard.id},

	
	
	SurveyQuestionView={path = "Game.Modules.SurveyQuestion.SurveyQuestionView"},

	
	
	-- 周卡
	NewWeekCardView = {path = "Game.Modules.NewWeekCard.NewWeekCardView",mide = ModuleId.NewWeekCard.id},

	-- 积天豪礼活动
	AccumulativeDayActivityView = {path = "Game.Modules.AccumulativeDayActivity.AccumulativeDayActivityView", mid = ModuleId.AccumulativeDay.id},
	-- 登录就送
	LoginSendView 	= {path = "Game.Modules.LoginSend.LoginSendView",mid = ModuleId.LoginSend.id},
	-- 每日礼包
	DailyGiftBagView = {path = "Game.Modules.DailyGiftBag.DailyGiftBagView",mid = ModuleId.DailyGiftBag.id},
	-- 每周礼包
	WeeklyGiftBagView = {path = "Game.Modules.WeeklyGiftBag.WeeklyGiftBagView"},
	-- 贵族专享周礼包
	NoBilityWeekGiftView = {path = "Game.Modules.NoBilityWeekGift.NoBilityWeekGiftView"},
	-- 每月礼包
	MonthlyGiftBagView = {path = "Game.Modules.MonthlyGiftBag.MonthlyGiftBagView"},
	NewServerGiftView = {path = "Game.Modules.NewServerGift.NewServerGiftView"},
	-- 开工福利
	WorkingWelfareView = {path = "Game.Modules.WorkingWelfare.WorkingWelfareView", mid = ModuleId.WorkingWelfare.id},
	-- 下载有礼
	DownLoadGiftView = {path = "Game.Modules.DownLoadGift.DownLoadGiftView"},


	-- 虚空幻境
	VoidlandView = {path = "Game.Modules.Voidland.VoidlandView"},
	VoidlandOpenView = {path = "Game.Modules.Voidland.VoidlandOpenView"},
	AddVoidlandSingleView = {path = "Game.Modules.Voidland.AddVoidlandSingleView"},
	VoidlandSkillView = {path = "Game.Modules.Voidland.VoidlandSkillView"},
	VoidlandSkillView1 = {path = "Game.Modules.Voidland.VoidlandSkillView1"},
	VoidlandSkillView2 = {path = "Game.Modules.Voidland.VoidlandSkillView2"},
	VoidlandSkillView3 = {path = "Game.Modules.Voidland.VoidlandSkillView3"},
	VoidlandRewardView = {path = "Game.Modules.Voidland.VoidlandRewardView"},
	VoidlandAssView = {path = "Game.Modules.Voidland.VoidlandAssView"},
	VoidlandMyAssView = {path = "Game.Modules.Voidland.VoidlandMyAssView"},
	VoidlandAddAssView = {path = "Game.Modules.Voidland.VoidlandAddAssView"},
	VoidlandRankView = {path = "Game.Modules.Voidland.VoidlandRankView"},
	VoidlandResultView = {path = "Game.Modules.Voidland.VoidlandResultView"},
	VoidlandAssTipsView = {path = "Game.Modules.Voidland.VoidlandAssTipsView"},
	VoidlandBattleView = {path = "Game.Modules.Voidland.VoidlandBattleView"},
	VoidlandSkillBagView = {path = "Game.Modules.Voidland.VoidlandSkillBagView"},

	-- 限时召唤
	TimeSummonView = {path="Game.Modules.TimeSummon.TimeSummonView"},--,mid = ModuleId.TimeSummon.id},
	-- 委托夺宝
	DelegateActivityView = {path = "Game.Modules.Activity.DelegateActivity.DelegateActivityView", mid = ModuleId.DelegateActivity.id},
	-- 圣所探险
	SanctuaryAdventureView = {path="Game.Modules.SanctuaryAdventure.SanctuaryAdventureView"},
	-- 升星觉醒
	LStarAwakeningView = {path="Game.Modules.LStarAwakening.LStarAwakeningView"},
	-- 每周签到
	WeeklySignInView = {path="Game.Modules.WeeklySignIn.WeeklySignInView"},

	-- 精灵系统
	ElvesSystemBaseView	= {path = "Game.Modules.ElvesSystem.ElvesSystemBaseView"},
	ElvesAttributeView 	= {path = "Game.Modules.ElvesSystem.ElvesAttributeView"}, 	-- 属性
	ElvesUpgradeView 	= {path = "Game.Modules.ElvesSystem.ElvesUpgradeView"}, 	-- 升级
	ElvesUpstarView 	= {path = "Game.Modules.ElvesSystem.ElvesUpstarView"}, 		-- 升星
	ElvesSummonView 	= {path = "Game.Modules.ElvesSystem.ElvesSummonView"}, 		-- 召唤
	ElvesBagView 		= {path = "Game.Modules.ElvesSystem.ElvesBagView"}, 		-- 背包
	ElvesAddattrView  	= {path = "Game.Modules.ElvesSystem.ElvesAddattrView"}, 	-- 精灵属性总览
	ElvesPlanView 		= {path = "Game.Modules.ElvesSystem.ElvesPlanView"}, 		-- 精灵方案
	ElvesPlanEditBoxView = {path = "Game.Modules.ElvesSystem.ElvesPlanEditBoxView"}, -- 精灵方案名字修改
	ElvesSkillTipsInfoView = {path = "Game.Modules.ElvesSystem.ElvesSkillTipsInfoView"}, -- 精灵技能介绍界面
	ElvesSyntheticView  = {path = "Game.Modules.ElvesSystem.ElvesSyntheticView"}, 	-- 精灵合成
	ElvesAddTopView 	= {path = "Game.Modules.ElvesSystem.ElvesAddTopView"}, 		-- 精灵备战
	ElvesGetView 		= {path = "Game.Modules.ElvesSystem.ElvesGetView"}, 		-- 获得精灵
	ElvesSummonHelpView = {path = "Game.Modules.ElvesSystem.ElvesSummonHelpView"}, 	-- 精灵召唤概率
	ElvesPromoteView  	= {path = "Game.Modules.ElvesSystem.ElvesPromoteView"},		-- 精灵羁绊
	ElvesSkinView  	 	= {path = "Game.Modules.ElvesSystem.ElvesSkinView"}, 		-- 精灵皮肤
	ElvesGetSkinView 	= {path = "Game.Modules.ElvesSystem.ElvesGetSkinView"}, 	-- 获得精灵皮肤
	ElvesSkinSkillPreView = {path = "Game.Modules.ElvesSystem.ElvesSkinSkillPreView"}, -- 精灵皮肤战斗预览
	ElvesNewPlanView 	= {path = "Game.Modules.ElvesSystem.ElvesNewPlanView"}, 		-- 精灵方案（新）
	

	-- 特性激活
	TalentActiveSucView = {path="Game.Modules.Talent.TalentActiveSucView"},
	TalentLearnSucView = {path="Game.Modules.Talent.TalentLearnSucView"},
	TalentEquipView = {path="Game.Modules.Talent.TalentEquipView"},
	TalentLearnView = {path="Game.Modules.Talent.TalentLearnView"},
	TalentTipsView = {path="Game.Modules.Talent.TalentTipsView"},
	TalentForgetSureView = {path="Game.Modules.Talent.TalentForgetSureView"},

	-- 英雄回退
	ResetHeroView = {path = "Game.Modules.ResetHero.ResetHeroView"},
	ResetHeroChooseView = {path = "Game.Modules.ResetHero.ResetHeroChooseView"},
	ResetHeroSureTipView = {path = "Game.Modules.ResetHero.ResetHeroSureTipView"},

	-- 装备目标
	EquipTargetView = {path = "Game.Modules.EquipTarget.EquipTargetView"}, 

	-- 装备升星活动
	EquipUpStarView = {path = "Game.Modules.EquipUpStar.EquipUpStarView"},
	EquipChooseView = {path = "Game.Modules.EquipUpStar.EquipChooseView"},

	-- 装备礼包活动
	EquipGiftView = {path = "Game.Modules.EquipGift.EquipGiftView"},

	SnatchActivityView = {path = "Game.Modules.SnatchActivity.SnatchActivityView"},

	-- 公会 魔灵山
	GuildMLSMainView = {path = "Game.Modules.GuildMagicLingShan.GuildMLSMainView"}, -- 主界面
	GuildMLSSummonBossView = {path = "Game.Modules.GuildMagicLingShan.GuildMLSSummonBossView"}, -- 召唤界面
	GuildMLSChallegeView = {path = "Game.Modules.GuildMagicLingShan.GuildMLSChallegeView"}, -- 挑战界面
	GuildMLSRwardTipsView = {path = "Game.Modules.GuildMagicLingShan.GuildMLSRwardTipsView"}, -- 奖励预览
	GuildMLSEndLayerView = {path = "Game.Modules.GuildMagicLingShan.GuildMLSEndLayerView"}, -- 结算界面
	GuildMLSTakeRewardView  = {path = "Game.Modules.GuildMagicLingShan.GuildMLSTakeRewardView"}, -- 领取奖励界面
	GuildMLSPowerTipsView = {path = "Game.Modules.GuildMagicLingShan.GuildMLSPowerTipsView"}, -- 购买体力界面
	GuildBossBarView 	= {path = "Game.Modules.GuildMagicLingShan.GuildBossBarView"},

	-- 圣器
	HallowBaseSeatView = {path = "Game.Modules.HallowSys.HallowBaseSeatView"},
	HallowUpView = {path = "Game.Modules.HallowSys.HallowUpView"},
	HallowPointView = {path = "Game.Modules.HallowSys.HallowPointView"},
	HallowSkillUnlockView = {path = "Game.Modules.HallowSys.HallowSkillUnlockView"},


	--临界之旅
	BoundaryMapView = {path = "Game.Modules.BoundaryMap.BoundaryMapView"},
	FightInfoView = {path = "Game.Modules.BoundaryMap.FightInfoView"},
	BossInfoView = {path = "Game.Modules.BoundaryMap.BossInfoView"},
	BlessingBagView = {path = "Game.Modules.BoundaryMap.BlessingBagView"},
	BlessingSelectView = {path = "Game.Modules.BoundaryMap.BlessingSelectView"},
	SceneRewardView = {path = "Game.Modules.BoundaryMap.SceneRewardView"},
	SceneTpView = {path = "Game.Modules.BoundaryMap.SceneTpView"},
	CustomsRecordView = {path = "Game.Modules.BoundaryMap.CustomsRecordView"},
	SkillPreviewView = {path = "Game.Modules.BoundaryMap.SkillPreviewView"},
	ClearanceView = {path = "Game.Modules.BoundaryMap.ClearanceView"},
	BoundaryRankView = {path = "Game.Modules.BoundaryMap.BoundaryRankView"},

	-- 圣器副本
	RelicCopyView = {path = "Game.Modules.RelicCopyView.RelicCopyView"},
	RelicCopyRankView = {path = "Game.Modules.RelicCopyView.RelicCopyRankView"},
	--资源找回
	RetrieveView = {path = "Game.Modules.Retrieve.RetrieveView"},
	RetrieveChooseView = {path = "Game.Modules.Retrieve.RetrieveChooseView"},
	-- 纹章
	EmblemEquipView = {path = "Game.Modules.Emblem.EmblemEquipView"},
	EmblemBagView = {path = "Game.Modules.Emblem.EmblemBagView"},
	EmblemCompareView = {path = "Game.Modules.Emblem.EmblemCompareView"},
	EmblemStarUpView = {path = "Game.Modules.Emblem.EmblemStarUpView"},
	EmblemRecastView = {path = "Game.Modules.Emblem.EmblemRecastView"},
	EmblemSuitSuggestView = {path = "Game.Modules.Emblem.EmblemSuitSuggestView"},
	EmblemEquipedView = {path = "Game.Modules.Emblem.EmblemEquipedView"},

	GetCardsYjActivityView={path="Game.Modules.GetCardsYjActivity.GetCardsYjActivityView"},
	GCHeroChooseView = {path="Game.Modules.GetCardsYjActivity.GCHeroChooseView"},
	GCHeroSelectView = {path="Game.Modules.GetCardsYjActivity.GCHeroSelectView"},
	GCTyTipsView = {path="Game.Modules.GetCardsYjActivity.GCTyTipsView"},
	GetCardsYjAwardView={path="Game.Modules.GetCardsYjActivity.GetCardsYjAwardView"},
	ActYjShopView = {path = "Game.Modules.GetCardsYjActivity.ActYjShopView"},
	HeroSummonShopDayView = {path = "Game.Modules.GetCardsYjActivity.HeroSummonShopDayView"}, --精英召唤每日限时商城

	GetCardsUPActivityView={path="Game.Modules.GetCardsUPActivity.GetCardsUPActivityView"},
	UPHeroChooseView = {path="Game.Modules.GetCardsUPActivity.UPHeroChooseView"},
	UPHeroSelectView = {path="Game.Modules.GetCardsUPActivity.UPHeroSelectView"},
	--UPTyTipsView = {path="Game.Modules.GetCardsUPActivity.UPTyTipsView"},
	GetCardsUPAwardView={path="Game.Modules.GetCardsUPActivity.GetCardsUPAwardView"},

	-- 扭蛋活动
	TwistEggLimitGiftView = {path="Game.Modules.TwistEggLimitGift.TwistEggLimitGiftView"}, -- 限时商店
	GodsLotteryShopView = {path="Game.Modules.GodsLotteryShop.GodsLotteryShopView"}, -- 祈愿商店
	TwistEggShopView = {path="Game.Modules.TwistEggShop.TwistEggShopView"}, -- 扭蛋商店
	TwistEggShopTipsView = {path="Game.Modules.TwistEggShop.TwistEggShopTipsView"}, -- 扭蛋商店购买界面
	TwistEggTaskView = {path="Game.Modules.TwistEggTask.TwistEggTaskView"}, -- 扭蛋任务
	TwistEggView = {path="Game.Modules.TwistEgg.TwistEggView"}, -- 扭蛋
	TwistEggSignView = {path="Game.Modules.TwistEggSign.TwistEggSignView"}, -- 扭蛋签到
	TwistRuneTaskView = {path="Game.Modules.TwistRune.TwistRuneTaskView"}, -- 符文收集
	TwistWordTipView={path="Game.Modules.TwistSpFestival.TwistWordTipView"}, -- 春节寄语
	TwistWordEditView={path="Game.Modules.TwistSpFestival.TwistWordEditView"}, -- 春节寄语
	TwistSpFestivalView={path="Game.Modules.TwistSpFestival.TwistSpFestivalView"}, -- 春节寄语
	
	TwistRegimentView={path="Game.Modules.TwistRegiment.TwistRegimentView"}, -- 天降神兵
	TwistDoubleScoreView={path="Game.Modules.TwistRegiment.TwistDoubleScoreView"},--多倍积分滚动窗
	TrainingCampView={path="Game.Modules.Training.TrainingCampView"},--训练营任务
	TrainingPrepareView={path="Game.Modules.Training.TrainingPrepareView"},--训练营备战界面
	TrainingTipView={path="Game.Modules.Training.TrainingTipView"},--训练营提示界面
	

		--阵营试炼
	TrialActivityView = {path = "Game.Modules.TrialActivity.TrialActivityView"},
	TrialActivityTipsView = {path = "Game.Modules.TrialActivity.TrialActivityTipsView"},
	TrialActivityBattleView = {path = "Game.Modules.TrialActivity.TrialActivityBattleView"},
	TrialActivityAddView = {path = "Game.Modules.TrialActivity.TrialActivityAddView"},

	
	CustomizedGiftsView = {path="Game.Modules.CustomizedGifts.CustomizedGiftsView"},
	CustomizedChoseView = {path="Game.Modules.CustomizedGifts.CustomizedChoseView"},
	
	DetectiveAgencyView = {path = "Game.Modules.DetectiveAgency.DetectiveAgencyView"},
	HeroUpStarView = {path = "Game.Modules.DetectiveAgency.HeroUpStarView"},--新升星界面

	HeroBossActivityView = {path = "Game.Modules.HeroBossActivity.HeroBossActivityView"},--新英雄活动BOSS
	HeroShopView = {path = "Game.Modules.HeroBossActivity.HeroShopView"},--新英雄活动商店
	HeroBossRanInfoView = {path = "Game.Modules.HeroBossActivity.HeroBossRanInfoView"},--新英雄活动商店
	HeroBossResultView = {path = "Game.Modules.HeroBossActivity.HeroBossResultView"},--新英雄活动BOSS结算
	HeroShopTipsView = {path = "Game.Modules.HeroBossActivity.HeroShopTipsView"},--新英雄活动商店弹出
	
	--探员宿舍
	DormJigsawView = {path = "Game.Modules.Dorm.DormJigsawView"},
	DormChatView = {path = "Game.Modules.Dorm.DormChatView"},
	DormStartView = {path = "Game.Modules.Dorm.DormStartView"},
	DormAnswerView = {path = "Game.Modules.Dorm.DormAnswerView"},
	
	--最终大赏
	ActFinalRewardView = {path = "Game.Modules.ActFinalReward.ActFinalRewardView"},
	--一番巡礼
	ActATourGiftView = {path = "Game.Modules.ActATourGift.ActATourGiftView"},
	WishingWellView = {path = "Game.Modules.ActATourGift.WishingWellView"},
	ActATourLimitShopView = {path = "Game.Modules.ActATourLimitShop.ActATourLimitShopView"}, 	-- 精灵限时商城（巡礼商店）
	ActHeroGatherView = {path = "Game.Modules.ActHeroGather.ActHeroGatherView"}, 	-- 探员集结
	ActGodsPrayView={path="Game.Modules.ActGodsPray.ActGodsPrayView"},--神灵祈愿
	GoldMagicView = {path = "Game.Modules.GoldMagic.GoldMagicView"}, 	-- 点石成金
	QuickBattleView = {path = "Game.Modules.QuickBattle.QuickBattleView"}, 	--  作战行动
	--梦主争夺
	DreamMasterPvpMainView = {path = "Game.Modules.DreamMasterPvp.DreamMasterPvpMainView"}, 
	DreamMasterPvpQuizView = {path = "Game.Modules.DreamMasterPvp.DreamMasterPvpQuizView"},
	DreamMasterPvpRewardView = {path = "Game.Modules.DreamMasterPvp.DreamMasterPvpRewardView"},
	DreamMasterPvpView = {path = "Game.Modules.DreamMasterPvp.DreamMasterPvpView"},
	DreamMasterPvpGuessView = {path = "Game.Modules.DreamMasterPvp.DreamMasterPvpGuessView"},
	--血荆之源
	BloodAbyssMainView = {path = "Game.Modules.BloodAbyss.BloodAbyssMainView"}, 
	BloodAbyssView = {path = "Game.Modules.BloodAbyss.BloodAbyssView"},
	BloodAbyssRewardView = {path = "Game.Modules.BloodAbyss.BloodAbyssRewardView"},
	BloodAbyssResultView = {path = "Game.Modules.BloodAbyss.BloodAbyssResultView"},

	-- 探员试炼活动
	DetectiveTrialView = {path = "Game.Modules.DetectiveTrial.DetectiveTrialView"},
	DetectiveTrialEndView = {path = "Game.Modules.DetectiveTrial.DetectiveTrialEndView"},
	DetectiveTrialGiftView = {path = "Game.Modules.DetectiveTrialGift.DetectiveTrialGiftView"},
	DetectiveTrialShopView = {path = "Game.Modules.DetectiveTrialShop.DetectiveTrialShopView"},
	DetectiveTrialShopTipsView= {path = "Game.Modules.DetectiveTrialShop.DetectiveTrialShopTipsView"},
	--天域试炼
	CrossPVPView = {path = "Game.Modules.CrossPVP.CrossPVPView"}, 
	CrossPVPBattleView = {path = "Game.Modules.CrossPVP.CrossPVPBattleView"}, 
	CrossPVPMatchView = {path = "Game.Modules.CrossPVP.CrossPVPMatchView"}, 
	CrossPVPSetArrayView = {path = "Game.Modules.CrossPVP.CrossPVPSetArrayView"}, 
	CrossPVPHistoryView = {path = "Game.Modules.CrossPVP.CrossPVPHistoryView"}, 
	CrossPVPResultView = {path = "Game.Modules.CrossPVP.CrossPVPResultView"}, 
	CrossPVPRewardView = {path = "Game.Modules.CrossPVP.CrossPVPRewardView"}, 
	CrossPVPPlayerInfoView = {path = "Game.Modules.CrossPVP.CrossPVPPlayerInfoView"}, 
	CrossFightAnimationView = {path = "Game.Modules.CrossPVP.CrossFightAnimationView"}, 
	CrossPVPResultLayerView = {path = "Game.Modules.CrossPVP.CrossPVPResultLayerView"}, 
	--跨服真人PK
	CrossArenaFightAnimationView = {path = "Game.Modules.CrossArenaPVP.CrossArenaFightAnimationView"}, 
	CrossArenaPVPBattleView = {path = "Game.Modules.CrossArenaPVP.CrossArenaPVPBattleView"}, 
	CrossArenaPVPPlayerInfoView = {path = "Game.Modules.CrossArenaPVP.CrossArenaPVPPlayerInfoView"}, 
	CrossArenaPVPHistoryView = {path = "Game.Modules.CrossArenaPVP.CrossArenaPVPHistoryView"}, 
	CrossArenaPVPResultLayerView = {path = "Game.Modules.CrossArenaPVP.CrossArenaPVPResultLayerView"}, 
	CrossArenaPVPResultView = {path = "Game.Modules.CrossArenaPVP.CrossArenaPVPResultView"}, 
	CrossArenaPVPRewardView = {path = "Game.Modules.CrossArenaPVP.CrossArenaPVPRewardView"}, 
	CrossArenaPVPSetArrayView = {path = "Game.Modules.CrossArenaPVP.CrossArenaPVPSetArrayView"}, 
	CrossArenaPVPView = {path = "Game.Modules.CrossArenaPVP.CrossArenaPVPView"}, 
	CrossArenaPVPSlectedView = {path = "Game.Modules.CrossArenaPVP.CrossArenaPVPSlectedView"}, 
	CrossArenShopView = {path = "Game.Modules.CrossArenaPVP.CrossArenShopView"}, 
	-- 月慑神殿
	MoonAweTempleView = {path = "Game.Modules.MoonAweTemple.MoonAweTempleView"}, 	-- 主界面
	MoonAweTempleChallengeView = {path = "Game.Modules.MoonAweTemple.MoonAweTempleChallengeView"}, -- 挑战界面
	MoonAweTempleRecordView = {path = "Game.Modules.MoonAweTemple.MoonAweTempleRecordView"}, -- 挑战记录
	MoonAweTempleResultView = {path = "Game.Modules.MoonAweTemple.MoonAweTempleResultView"}, -- 结算界面

	-- 公会联赛
	GuildLeagueMainView = {path = "Game.Modules.GuildLeague.GuildLeagueMainView"},
	GuildLeagueAwardView = {path = "Game.Modules.GuildLeague.GuildLeagueAwardView"},
	GLScoreAwardView = {path = "Game.Modules.GuildLeague.GLScoreAwardView"},
	GLBoxView = {path = "Game.Modules.GuildLeague.GLBoxView"},
	GLRankAwardView = {path = "Game.Modules.GuildLeague.GLRankAwardView"},
	GLSeasonAwardView = {path = "Game.Modules.GuildLeague.GLRankAwardView"},
	GuildLeagueRankView = {path = "Game.Modules.GuildLeague.GuildLeagueRankView"},
	GuildLeagueFortView = {path = "Game.Modules.GuildLeague.GuildLeagueFortView"},
	GuildLeagueEnemyView = {path = "Game.Modules.GuildLeague.GuildLeagueEnemyView"},
	GuildLeagueLogView = {path = "Game.Modules.GuildLeague.GuildLeagueLogView"},
	GuildLeagueHonorView = {path = "Game.Modules.GuildLeague.GuildLeagueHonorView"},
	GuildLeagueRecordView = {path = "Game.Modules.GuildLeague.GuildLeagueRecordView"},
	GLRecordRankView = {path = "Game.Modules.GuildLeague.GLRecordRankView"},
	GLRecordLogView = {path = "Game.Modules.GuildLeague.GLRecordLogView"},
	GuildLeagueHistoryView = {path = "Game.Modules.GuildLeague.GuildLeagueHistoryView"},
	GuildLeagueTreasureView = {path = "Game.Modules.GuildLeague.GuildLeagueTreasureView"},
	GLNormalMainView = {path = "Game.Modules.GuildLeague.GLNormalMainView"},
	-- 公会联赛-传奇赛
	GLLegendsMainView = {path = "Game.Modules.GuildLeagueOfLegends.GLLegendsMainView"},
	GLLegendsAwardView = {path = "Game.Modules.GuildLeagueOfLegends.GLLegendsAwardView"},
	GLLegendsBattleResultView = {path = "Game.Modules.GuildLeagueOfLegends.GLLegendsBattleResultView"},
	GLLegendsBetView = {path = "Game.Modules.GuildLeagueOfLegends.GLLegendsBetView"},
	GLLegendsDefPreView = {path = "Game.Modules.GuildLeagueOfLegends.GLLegendsDefPreView"},
	GLLegendsGroupView = {path = "Game.Modules.GuildLeagueOfLegends.GLLegendsGroupView"},
	GLLegendsGuessView = {path = "Game.Modules.GuildLeagueOfLegends.GLLegendsGuessView"},
	GLLegendsGuestLogView = {path = "Game.Modules.GuildLeagueOfLegends.GLLegendsGuestLogView"},
	GLLegendsBattleTeamView = {path = "Game.Modules.GuildLeagueOfLegends.GLLegendsBattleTeamView"},
	GLOLBattlePreTopView = {path = "Game.Modules.GuildLeagueOfLegends.GLOLBattlePreTopView"},
	GLLegendsTableView = {path = "Game.Modules.GuildLeagueOfLegends.GLLegendsTableView"},
	GLOLExchangeView = {path = "Game.Modules.GuildLeagueOfLegends.GLOLExchangeView"},
	GLOLGuildInfoView = {path = "Game.Modules.GuildLeagueOfLegends.GLOLGuildInfoView"},

	--小橘定时推送
	TimingPushView = {path = "Game.Modules.TimingPush.TimingPushView"}, 
	--神社祈福
	ActShrineBlessView = {path = "Game.Modules.ActShrineBless.ActShrineBlessView"},
	ActBlessView = {path = "Game.Modules.ActShrineBless.ActBlessView"},
	ActCurRewardView = {path = "Game.Modules.ActShrineBless.ActCurRewardView"},
	ActShrineShopView = {path = "Game.Modules.ActShrineBless.ActShrineShopView"},
	HeroFettersShowInfoView = {path = "Game.Modules.HeroFetters.HeroFettersShowInfoView"},
	HeroFettersView = {path = "Game.Modules.HeroFetters.HeroFettersView"},

	-- 组队竞技（跨服）
	CrossTeamFightAnimateView = {path = "Game.Modules.CrossTeamPvp.CrossTeamFightAnimateView"},
	CrossTeamPVPAddTopView = {path = "Game.Modules.CrossTeamPvp.CrossTeamPVPAddTopView"},
	CrossTeamPVPEndView = {path = "Game.Modules.CrossTeamPvp.CrossTeamPVPEndView"},
	CrossTeamPVPInviteView = {path = "Game.Modules.CrossTeamPvp.CrossTeamPVPInviteView"},
	CrossTeamPVPMainView = {path = "Game.Modules.CrossTeamPvp.CrossTeamPVPMainView"},
	CrossTeamPVPMatchView = {path = "Game.Modules.CrossTeamPvp.CrossTeamPVPMatchView"},
	CrossTeamPVPRankView = {path = "Game.Modules.CrossTeamPvp.CrossTeamPVPRankView"},
	CrossTeamPVPRecordInView = {path = "Game.Modules.CrossTeamPvp.CrossTeamPVPRecordInView"},
	CrossTeamPVPRecordOutView = {path = "Game.Modules.CrossTeamPvp.CrossTeamPVPRecordOutView"},
	CrossTeamPVPRewardView = {path = "Game.Modules.CrossTeamPvp.CrossTeamPVPRewardView"},
	CrossTeamPVPSquadSortView = {path = "Game.Modules.CrossTeamPvp.CrossTeamPVPSquadSortView"},
	CrossTeamPVPTeamHallView = {path = "Game.Modules.CrossTeamPvp.CrossTeamPVPTeamHallView"},
	CrossTeamPVPRankRewardView = {path = "Game.Modules.CrossTeamPvp.CrossTeamPVPRankRewardView"},

	--时装
	FashionView = {path = "Game.Modules.Fashion.FashionView"}, --时装界面
	FashionShopTipsView = {path = "Game.Modules.Fashion.FashionShopTipsView"}, -- 时装商店tips
	FashionLoginTipsView = {path = "Game.Modules.Fashion.FashionLoginTipsView"}, -- 时装登录tips
	GetFshionShowView = {path = "Game.Modules.Fashion.GetFshionShowView"}, -- 获得时装界面
	FashionPreView = {path = "Game.Modules.Fashion.FashionPreView"}, -- 时装战斗预览
	FashionPreBtnView = {path = "Game.Modules.Fashion.FashionPreBtnView"}, -- 时装战斗预览界面
	FashionPreBattleView = {path = "Game.Modules.Fashion.FashionPreBattleView"}, -- 时装战斗预览界面

	FestivalGiftView = {path = "Game.Modules.FestivalGift.FestivalGiftView"}, -- 圣诞礼物登录

	-- 集物兑换商店
	CollectThingShopView = {path = "Game.Modules.CollectThing.CollectThingShopView"},

	-- 集字活动
	CollectWordsActivityShopView = {path = "Game.Modules.CollectWordsActivity.CollectWordsActivityShopView"}, -- 商店
	CollectWordsActivityExchangeView = {path = "Game.Modules.CollectWordsActivity.CollectWordsActivityExchangeView"}, -- 兑换窗口
	CollectWordsActivityView 	= {path = "Game.Modules.CollectWordsActivity.CollectWordsActivityView"},

	--巅峰竞技场
	StrideMainView = {path = "Game.Modules.StrideServer.StrideMainView"},--巅峰主页
	StrideBattleView = {path = "Game.Modules.StrideServer.StrideBattleView"},--巅峰布阵控件页
	StrideGuessRecordView = {path = "Game.Modules.StrideServer.StrideGuessRecordView"},--竞猜记录
	StrideMyCourseView = {path = "Game.Modules.StrideServer.StrideMyCourseView"},--我的赛程
	StrideRankJJGameView = {path = "Game.Modules.StrideServer.StrideRankJJGameView"},--x强赛/晋级赛
	StrideRankGJGameView = {path = "Game.Modules.StrideServer.StrideRankGJGameView"},--冠军赛
	StrideRecordInView = {path = "Game.Modules.StrideServer.StrideRecordInView"},--对阵详情
	StrideResultView = {path = "Game.Modules.StrideServer.StrideResultView"},--战斗数据界面
	StrideRewardView = {path = "Game.Modules.StrideServer.StrideRewardView"},--挑战奖励
	StrideSetArrayView = {path = "Game.Modules.StrideServer.StrideSetArrayView"},--战队排序
	StrideTopVersionView = {path = "Game.Modules.StrideServer.StrideTopVersionView"},--巅峰赛
	StridePVPAddTopView = {path = "Game.Modules.StrideServer.StridePVPAddTopView"},--巅峰赛战斗贴页
	
	SealDevilView = {path = "Game.Modules.SealDevil.SealDevilView"},--封魔之路
	DevilRoadView= {path = "Game.Modules.SealDevil.DevilRoadView"},
	DevilEventView= {path = "Game.Modules.SealDevil.DevilEventView"},
	DevilBuffView= {path = "Game.Modules.SealDevil.DevilBuffView"},
	DevilResView= {path = "Game.Modules.SealDevil.DevilResView"},
	
	StridePVPRankView = {path = "Game.Modules.StrideServer.StridePVPRankView"},--巅峰赛排行
	-- 跨服天梯赛
	CrossLaddersEndView 	= {path = "Game.Modules.CrossLadders.CrossLaddersEndView"},	-- 结算界面
	CrossLaddersHeroHouseView 	= {path = "Game.Modules.CrossLadders.CrossLaddersHeroHouseView"},	-- 点赞界面
	CrossLaddersMainView 	= {path = "Game.Modules.CrossLadders.CrossLaddersMainView"},	-- 主界面
	CrossLaddersRankView 	= {path = "Game.Modules.CrossLadders.CrossLaddersRankView"},	-- 排行榜
	CrossLaddersRecordView 	= {path = "Game.Modules.CrossLadders.CrossLaddersRecordView"},	-- 战斗记录
	CrossLaddersRewardView 	= {path = "Game.Modules.CrossLadders.CrossLaddersRewardView"},	-- 奖励界面
	CrossLaddersShopView 	= {path = "Game.Modules.CrossLadders.CrossLaddersShopView"},	-- 购买门票界面
	CrossLaddersFightTipsView 	= {path = "Game.Modules.CrossLadders.CrossLaddersFightTipsView"},	-- 使用门票界面
	

	-- 功能手册
	HelpFunctionManualView = {path = "Game.Modules.HelpSystem.HelpFunctionManualView"},
	--探员宿舍
	HeroDormitoryView = {path = "Game.Modules.Handbook.HeroDormitoryView"},
	--特惠礼包
	SpecialgiftBagView = {path = "Game.Modules.SpecialgiftBag.SpecialgiftBagView"},
	SpecialgiftBagTourView = {path = "Game.Modules.SpecialgiftBag.SpecialgiftBagTourView"},
	SpecialgiftBagShrinePrayView = {path = "Game.Modules.SpecialgiftBag.SpecialgiftBagShrinePrayView"},
	SpecialgiftBagHeroTrialView = {path = "Game.Modules.SpecialgiftBag.SpecialgiftBagHeroTrialView"},
	SpecialgiftBagGashaponView = {path = "Game.Modules.SpecialgiftBag.SpecialgiftBagGashaponView"},

	-- 跨服天梯冠军赛
	CrossLaddersChampGroupView 	= {path = "Game.Modules.CrossLaddersChamp.CrossLaddersChampGroupView"}, 	-- 分组界面
	CrossLaddersChampGuessView 	= {path = "Game.Modules.CrossLaddersChamp.CrossLaddersChampGuessView"}, 	-- 竞猜押注界面
	CrossLaddersChampMainView 	= {path = "Game.Modules.CrossLaddersChamp.CrossLaddersChampMainView"}, 		-- 主界面
	CrossLaddersChampPrimaryView = {path = "Game.Modules.CrossLaddersChamp.CrossLaddersChampPrimaryView"}, 	-- 预选赛界面
	CrossLaddersChampQuizView 	= {path = "Game.Modules.CrossLaddersChamp.CrossLaddersChampQuizView"}, 		-- 竞猜主界面
	CrossLaddersChampRankRewardView = {path = "Game.Modules.CrossLaddersChamp.CrossLaddersChampRankRewardView"}, -- 排名奖励
	CrossLaddersChampRankView 	= {path = "Game.Modules.CrossLaddersChamp.CrossLaddersChampRankView"}, 		-- 排行榜
	CrossLaddersChampRecordView = {path = "Game.Modules.CrossLaddersChamp.CrossLaddersChampRecordView"}, 	-- 战斗记录
	CrossLaddersChampEndView = {path = "Game.Modules.CrossLaddersChamp.CrossLaddersChampEndView"},

	--探员投票
	PopularVoteView = {path = "Game.Modules.PopularVote.PopularVoteView"}, 	
	PopularVoteTipsView = {path = "Game.Modules.PopularVote.PopularVoteTipsView"}, 	
	PopularVoteBuyView = {path = "Game.Modules.PopularVote.PopularVoteBuyView"}, 	
	PopularVoteAdvanceView = {path = "Game.Modules.PopularVote.PopularVoteAdvanceView"}, 	
	PopularVoteRankView = {path = "Game.Modules.PopularVote.PopularVoteRankView"}, 	
	PopularVoteRewardView = {path = "Game.Modules.PopularVote.PopularVoteRewardView"}, 	
	PopularVoteTaskView = {path = "Game.Modules.PopularVote.PopularVoteTaskView"}, 
PopularVoteEmptyView = {path = "Game.Modules.PopularVote.PopularVoteEmptyView"},
	PopularVoteShopView = {path = "Game.Modules.PopularVote.PopularVoteShopView"},
	
	EventBrocastView = {path = "Game.Modules.EventBrocast.EventBrocastView"}, 	--消息播报
	--协力活动
	CooperationBaseView = {path = "Game.Modules.CooperationActivities.CooperationBaseView"},	
	CooperationActivitieMainView = {path = "Game.Modules.CooperationActivities.CooperationActivitieMainView"},
	CooperationActivitieCheatingView = {path = "Game.Modules.CooperationActivities.CooperationActivitieCheatingView"},
	CooperationActivitieLimitView = {path = "Game.Modules.CooperationActivities.CooperationActivitieLimitView"},
	CooperationActivitieRankView = {path = "Game.Modules.CooperationActivities.CooperationActivitieRankView"},
	CooperationActivitieshopBuyView = {path = "Game.Modules.CooperationActivities.CooperationActivitieshopBuyView"},
	CooperationActivitieShopView = {path = "Game.Modules.CooperationActivities.CooperationActivitieShopView"},
	CooperationActivitieSkillView = {path = "Game.Modules.CooperationActivities.CooperationActivitieSkillView"},
	CooperationEndLayerView = {path = "Game.Modules.CooperationActivities.CooperationEndLayerView"},
	CooperationRewardView = {path = "Game.Modules.CooperationActivities.CooperationRewardView"},
	--通用Boss活动
	ActCommonBossView = {path = "Game.Modules.ActCommonBoss.ActCommonBossView"},
	ActCommonBossResultView = {path = "Game.Modules.ActCommonBoss.ActCommonBossResultView"},
	ActCommonShopTipsView = {path = "Game.Modules.ActCommonBoss.ActCommonShopTipsView"},
	ActCommonShopView = {path = "Game.Modules.ActCommonBoss.ActCommonShopView"},
	ActCommonShopConVertView = {path = "Game.Modules.ActCommonBoss.ActCommonShopConVertView"},
	ActCommonShopTipsView = {path = "Game.Modules.ActCommonBoss.ActCommonShopTipsView"},

	-- 最终奖赏2 
	ElfFinalSecondView = {path = "Game.Modules.ElfFinalSecond.ElfFinalSecondView"},

	-- 查看信息
	ViewPlayerGuildSkillTipView = {path = "Game.Modules.PlayerInfo.ViewPlayerGuildSkillTipView"},
	ViewPlayerHallowSkillTipView = {path = "Game.Modules.PlayerInfo.ViewPlayerHallowSkillTipView"},
	ViewPlayerHallowBaseTipsView = {path = "Game.Modules.PlayerInfo.ViewPlayerHallowBaseTipsView"},
	ViewPlayerElvesTipsView = {path = "Game.Modules.PlayerInfo.ViewPlayerElvesTipsView"},
	ViewPlayerScrectWeaponTipView = {path = "Game.Modules.PlayerInfo.ViewPlayerScrectWeaponTipView"},
	ViewPlayerRuneTipsView = {path = "Game.Modules.PlayerInfo.ViewPlayerRuneTipsView"},
	
	--新年活动
	NewYearActivityMainView = {path = "Game.Modules.NewYearActivity.NewYearActivityMainView"},
	NewYearActivityMapView = {path = "Game.Modules.NewYearActivity.NewYearActivityMapView"},
	NewYearActivityBigBossView = {path = "Game.Modules.NewYearActivity.NewYearActivityBigBossView"},
	NewYearActivitySmallBossView = {path = "Game.Modules.NewYearActivity.NewYearActivitySmallBossView"},
	NewYearActivityRankView = {path = "Game.Modules.NewYearActivity.NewYearActivityRankView"},
	NewYearActivityRedPackView = {path = "Game.Modules.NewYearActivity.NewYearActivityRedPackView"},
	NewYearActivityResultView = {path = "Game.Modules.NewYearActivity.NewYearActivityResultView"},
	
	-- 元宵活动
	LanternSignView = {path = "Game.Modules.LanternActivity.LanternSign.LanternSignView"},
	LanternTaskView = {path = "Game.Modules.LanternActivity.LanternTask.LanternTaskView"},
	LanternShopView = {path = "Game.Modules.LanternActivity.LanternShop.LanternShopView"},
	LanternLimitGiftView = {path = "Game.Modules.LanternActivity.LanternLimitGift.LanternLimitGiftView"},
	LanternDrawView = {path = "Game.Modules.LanternActivity.LanternDraw.LanternDrawView"},
	LanternShopTipsView = {path = "Game.Modules.LanternActivity.LanternShop.LanternShopTipsView"},


	--新英雄召唤
	ActNewHeroPrayView = {path = "Game.Modules.ActNewHeroPray.ActNewHeroPrayView"},
	ActNewHeroTipsView = {path = "Game.Modules.ActNewHeroPray.ActNewHeroTipsView"},
	ActNewHeroShopTipsView = {path = "Game.Modules.ActNewHeroPray.ActNewHeroShopTipsView"},
	ActNewHeroShopConVertView = {path = "Game.Modules.ActNewHeroPray.ActNewHeroShopConVertView"},
	ActNewHeroShopView = {path = "Game.Modules.ActNewHeroPray.ActNewHeroShopView"},
}