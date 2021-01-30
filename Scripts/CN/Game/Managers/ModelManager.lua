local ModelManager = {}
local allPath = {
	CardLibModel = require "Game.Modules.Card.CardLibModel",
	GMModel = require "Game.Modules.GM.GMModel",
	--所有背包
	MainUIModel=require "Game.Modules.MainUI.MainUIModel",
	PackModel = require "Game.Modules.Pack.PackModel",
    BattleModel = require "Game.Modules.Battle.BattleModel",
	RewardModel = require "Game.Modules.UIPublic_ReWard.RewardModel",
	PlayerModel = require "Game.Modules.Player.PlayerModel",
	ShopModel = require "Game.Modules.Shop.ShopModel",
	EmailModel = require "Game.Modules.Email.EmailModel",
	GetCardsModel = require "Game.Modules.GetCards.GetCardsModel",
	ServerTimeModel = require "Game.Modules.Public.ServerTimeModel",
	ChatModel = require "Game.Modules.Chat.ChatModel",
	ChatUtil = require "Game.Modules.Chat.ChatUtil",
	MaterialCopyModel = require "Game.Modules.MaterialCopy.MaterialCopyModel",
	PataModel = require "Game.Modules.Pata.PataModel",
	PushMapModel = require "Game.Modules.PushMap.PushMapModel",
	EquipmentModel = require "Game.Modules.Equipment.EquipmentModel",
	ArenaModel=require "Game.Modules.Arena.ArenaModel",
	GuideModel = require "Game.Modules.Guide.GuideModel",
	SettingModel = require "Game.Modules.Setting.SettingModel",
	VipMemberModel = require "Game.Modules.VipMember.VipMemberModel",
	TaskModel = require "Game.Modules.Task.TaskModel",
	GuildModel = require "Game.Modules.Guild.GuildModel",
	FriendModel = require "Game.Modules.Friend.FriendModel",
	MazeModel = require "Game.Modules.Maze.MazeModel",
	FairyLandModel = require "Game.Modules.FairyLand.FairyLandModel",
	ActivityModel = require "Game.Modules.Activity.ActivityModel",
	SevenDayActivityModel = require "Game.Modules.SevenDayActivity.SevenDayActivityModel",
	OperatingActivitiesModel = require "Game.Modules.OperatingActivities.OperatingActivitiesModel",
	ExpeditionModel = require "Game.Modules.Expedition.ExpeditionModel",
	TacticalModel = require "Game.Modules.Tactical.TacticalModel",
	RuneSystemModel = require "Game.Modules.RuneSystem.RuneSystemModel",
	HeroPalaceModel = require "Game.Modules.HeroPalace.HeroPalaceModel",
	WorldChallengeModel = require "Game.Modules.WorldChallenge.WorldChallengeModel",
	TurnTableModel = require "Game.Modules.TurnTable.TurnTableModel",
	HandbookModel = require "Game.Modules.Handbook.HandbookModel",
	BloodAbyssModel = require "Game.Modules.BloodAbyss.BloodAbyssModel",
	DelegateModel = require "Game.Modules.Delegate.DelegateModel",
	GoldTreeModel = require "Game.Modules.GoldTree.GoldTreeModel",
	GamePlayModel = require "Game.Modules.GamePlay.GamePlayModel",
	QuesSurveyModel = require "Game.Modules.QuestionnaireSurvey.QuesSurveyModel",
	ServiceCommitModel = require "Game.Modules.ServiceCommit.ServiceCommitModel",
	HelpSystemModel = require "Game.Modules.HelpSystem.HelpSystemModel",
	DutyModel = require "Game.Modules.Duty.DutyModel",
	HeroInfoModel = require "Game.Modules.HeroInfo.HeroInfoModel",
	UpgradeActivityModel = require "Game.Modules.UpgradeActivity.UpgradeActivityModel",
	MoneyBuyGiftModel = require "Game.Modules.MoneyBuyGift.MoneyBuyGiftModel",
	VipModel = require "Game.Modules.Vip.VipModel",
	FirstChargeModel = require "Game.Modules.FirstCharge.FirstChargeModel",
	PriviligeGiftModel = require "Game.Modules.PriviligeGift.PriviligeGiftModel",
	TimeLimitGiftModel = require "Game.Modules.TimeLimitGift.TimeLimitGiftModel",
	backgroundTimeLimitGiftModel = require "Game.Modules.TimeLimitGift.backgroundTimeLimitGiftModel",	
	TimeLimitGiftDupModel = require "Game.Modules.TimeLimitDupGift.TimeLimitGiftDupModel",
	PremiumGiftModel = require "Game.Modules.PremiumGift.PremiumGiftModel", 
	CollectThingModel = require "Game.Modules.CollectThing.CollectThingModel",
	GodMarketModel = require "Game.Modules.GodMarket.GodMarketModel",
	GodMarketShopModel = require "Game.Modules.GodMarketShop.GodMarketShopModel",
	JewelryModel = require "Game.Modules.Jewelry.JewelryModel",
	SecretWeaponsModel = require "Game.Modules.SecretWeapons.SecretWeaponsModel",
	RechargeModel = require "Game.Modules.Shop.RechargeModel",
	EndlessTrialModel = require "Game.Modules.EndlessTrial.EndlessTrialModel",
	MonthlyCardModel = require "Game.Modules.MonthlyCard.MonthlyCardModel",
	LoginAwardModel = require "Game.Modules.LoginAward.LoginAwardModel",
	PveStarTempleModel = require "Game.Modules.PveStarTemple.PveStarTempleModel",
	HigherPvPModel = require "Game.Modules.HigherPvP.HigherPvPModel",
	SuperFundModel = require "Game.Modules.SuperFund.SuperFundModel",
	WeekCardModel  = require "Game.Modules.WeekCard.WeekCardModel",
	LoginSendModel = require "Game.Modules.LoginSend.LoginSendModel",
	AccumulativeDayActivityModel = require "Game.Modules.AccumulativeDayActivity.AccumulativeDayActivityModel",
	DailyGiftBagModel = require "Game.Modules.DailyGiftBag.DailyGiftBagModel",
	WeeklyGiftBagModel = require "Game.Modules.WeeklyGiftBag.WeeklyGiftBagModel",
	NoBilityWeekGiftModel = require "Game.Modules.NoBilityWeekGift.NoBilityWeekGiftModel",
	MonthlyGiftBagModel = require "Game.Modules.MonthlyGiftBag.MonthlyGiftBagModel",
	NewServerGiftModel = require "Game.Modules.NewServerGift.NewServerGiftModel",
	WorkingWelfareModel = require "Game.Modules.WorkingWelfare.WorkingWelfareModel",
	ChatSpeechUtil = require "Game.Modules.Chat.ChatSpeechUtil",
	DownLoadGiftModel = require "Game.Modules.DownLoadGift.DownLoadGiftModel",
	ResDownloadModel = require "Game.Modules.Loading.ResDownloadModel",
	VoidlandModel = require "Game.Modules.Voidland.VoidlandModel",
	AdventureDiaryModel = require "Game.Modules.SevenDayActivity.AdventureDiaryModel",
	TimeSummonModel = require "Game.Modules.TimeSummon.TimeSummonModel",
	DelegateActivityModel = require "Game.Modules.Activity.DelegateActivity.DelegateActivityModel",
	SanctuaryAdventureModel = require "Game.Modules.SanctuaryAdventure.SanctuaryAdventureModel",
	LStarAwakeningModel = require "Game.Modules.LStarAwakening.LStarAwakeningModel",
	UpGetCardActivityModel = require "Game.Modules.UpGetCardActivity.UpGetCardActivityModel",
	GetCardsYjActivityModel = require "Game.Modules.GetCardsYjActivity.GetCardsYjActivityModel",
	ActYjShopModel = require "Game.Modules.GetCardsYjActivity.ActYjShopModel",
	GetCardsUPActivityModel = require "Game.Modules.GetCardsUPActivity.GetCardsUPActivityModel",
	WeeklySignInModel = require "Game.Modules.WeeklySignIn.WeeklySignInModel",
	ElvesSystemModel = require "Game.Modules.ElvesSystem.ElvesSystemModel",
	ResetHeroModel = require "Game.Modules.ResetHero.ResetHeroModel",
	FirstChargeLuxuryGiftModel = require "Game.Modules.FirstChargeLuxuryGift.FirstChargeLuxuryGiftModel",
	EquipTargetModel = require "Game.Modules.EquipTarget.EquipTargetModel",
	EquipUpStarModel = require "Game.Modules.EquipUpStar.EquipUpStarModel",
	NewWeekCardModel = require "Game.Modules.NewWeekCard.NewWeekCardModel",
	GuildMLSModel = require "Game.Modules.GuildMagicLingShan.GuildMLSModel",
	HallowSysModel = require "Game.Modules.HallowSys.HallowSysModel",
	EquipGiftModel = require "Game.Modules.EquipGift.EquipGiftModel",
	RelicCopyModel = require "Game.Modules.RelicCopyView.RelicCopyModel",
	EmblemModel = require "Game.Modules.Emblem.EmblemModel",
	BoundaryMapModel = require "Game.Modules.BoundaryMap.BoundaryMapModel",
	TwistEggLimitGiftModel = require "Game.Modules.TwistEggLimitGift.TwistEggLimitGiftModel",
	GodsLotteryShopModel = require "Game.Modules.GodsLotteryShop.GodsLotteryShopModel",
	TwistEggShopModel = require "Game.Modules.TwistEggShop.TwistEggShopModel",
	TwistEggTaskModel = require "Game.Modules.TwistEggTask.TwistEggTaskModel",
	TwistEggModel = require "Game.Modules.TwistEgg.TwistEggModel",
	TwistSignModel = require "Game.Modules.TwistEggSign.TwistSignModel",
	TwistRuneModel=require "Game.Modules.TwistRune.TwistRuneModel",
	TwistRegimentModel=require "Game.Modules.TwistRegiment.TwistRegimentModel",
	TwistSpFestivalModel =require "Game.Modules.TwistSpFestival.TwistSpFestivalModel",
	
	
	TrainingModel=require "Game.Modules.Training.TrainingModel",
	
	
	
	TrialActivityModel=require "Game.Modules.TrialActivity.TrialActivityModel",
	
	RetrieveModel = require "Game.Modules.Retrieve.RetrieveModel",
	BarrageModel = require "Game.Modules.Barrage.BarrageModel",

	HeroBossActivityModel = require "Game.Modules.HeroBossActivity.HeroBossActivityModel",
	ActATourGiftModel = require "Game.Modules.ActATourGift.ActATourGiftModel",
	ActFinalRewardModel = require "Game.Modules.ActFinalReward.ActFinalRewardModel",
	WorldHighPvpModel = require "Game.Modules.WorldChallenge.WorldHighPvpModel",
	CustomizedGiftsModel = require "Game.Modules.CustomizedGifts.CustomizedGiftsModel",
	ActATourLimitShopModel = require "Game.Modules.ActATourLimitShop.ActATourLimitShopModel",
	TalentModel = require "Game.Modules.Talent.TalentModel",
	ActHeroGatherModel = require "Game.Modules.ActHeroGather.ActHeroGatherModel",
	GoldMagicModel = require "Game.Modules.GoldMagic.GoldMagicModel",
	QuickBattleModel = require "Game.Modules.QuickBattle.QuickBattleModel",
	DreamMasterPvpModel = require "Game.Modules.DreamMasterPvp.DreamMasterPvpModel",
	DetectiveTrialModel = require "Game.Modules.DetectiveTrial.DetectiveTrialModel",
	CrossPVPModel = require "Game.Modules.CrossPVP.CrossPVPModel",
	RankModel = require "Game.Modules.Rank.RankModel",
	MoonAweTempleModel = require "Game.Modules.MoonAweTemple.MoonAweTempleModel",
	GuildLeagueModel = require "Game.Modules.GuildLeague.GuildLeagueModel",
	GuildLeagueOfLegendsModel = require "Game.Modules.GuildLeagueOfLegends.GuildLeagueOfLegendsModel",
	TimingPushModel = require "Game.Modules.TimingPush.TimingPushModel",
	ActShrineShopModel = require "Game.Modules.ActShrineBless.ActShrineShopModel",
	ActShrineBlessModel = require "Game.Modules.ActShrineBless.ActShrineBlessModel",
	DetectiveTrialGiftModel = require "Game.Modules.DetectiveTrialGift.DetectiveTrialGiftModel",
	DetectiveTrialShopModel = require "Game.Modules.DetectiveTrialShop.DetectiveTrialShopModel",
	HeroFettersModel = require "Game.Modules.HeroFetters.HeroFettersModel",
	CrossTeamPVPModel = require "Game.Modules.CrossTeamPVP.CrossTeamPVPModel",
	StrideServerModel = require "Game.Modules.StrideServer.StrideServerModel",
	CrossArenaPVPModel = require "Game.Modules.CrossArenaPVP.CrossArenaPVPModel",
	ActGodsPrayModel=require "Game.Modules.ActGodsPray.ActGodsPrayModel",
	FashionModel = require "Game.Modules.Fashion.FashionModel",
	FestivalGiftModel = require "Game.Modules.FestivalGift.FestivalGiftModel",
	FullsrGiftModel = require "Game.Modules.FullsrGift.FullsrGiftModel",
	CollectWordsActivityModel = require "Game.Modules.CollectWordsActivity.CollectWordsActivityModel",
	ExtraordinarylevelPvPModel = require "Game.Modules.ExtraordinarylevelPvP.ExtraordinarylevelPvPModel",
	CrossLaddersModel = require "Game.Modules.CrossLadders.CrossLaddersModel",
	
	SealDevilModel = require "Game.Modules.SealDevil.SealDevilModel",
	SpecialgiftBagModel = require "Game.Modules.SpecialgiftBag.SpecialgiftBagModel",
	CrossLaddersChampModel = require "Game.Modules.CrossLaddersChamp.CrossLaddersChampModel",
	EventBrocastModel = require "Game.Modules.EventBrocast.EventBrocastModel",
	PopularVoteModel = require "Game.Modules.PopularVote.PopularVoteModel",
	CooperationActivitiesModel = require "Game.Modules.CooperationActivities.CooperationActivitiesModel",
	ActCommonShopModel = require "Game.Modules.ActCommonBoss.ActCommonShopModel",
	ActCommonBossModel = require "Game.Modules.ActCommonBoss.ActCommonBossModel",
	ElfFinalSecondModel 	= require "Game.Modules.ElfFinalSecond.ElfFinalSecondModel",
	HonorMedalModel 	= require "Game.Modules.Player.HonorMedalModel",
	NewYearActivityModel 	= require "Game.Modules.NewYearActivity.NewYearActivityModel",
	DressRechargeModel = require "Game.Modules.Recharge.DressRechargeModel",
	SurveyQuestionModel 	= require "Game.Modules.SurveyQuestion.SurveyQuestionModel",
	LanternShopModel 	=  require "Game.Modules.LanternActivity.LanternShop.LanternShopModel",
	LanternLimitGiftModel 	=  require "Game.Modules.LanternActivity.LanternLimitGift.LanternLimitGiftModel",
	LanternTaskModel 	=  require "Game.Modules.LanternActivity.LanternTask.LanternTaskModel",
	LanternSignModel 	= 	require "Game.Modules.LanternActivity.LanternSign.LanternSignModel",
	LanternDrawModel 	= require "Game.Modules.LanternActivity.LanternDraw.LanternDrawModel",
	LanternRiddleModel 	= require "Game.Modules.LanternActivity.LanternRiddle.LanternRiddleModel",
	ActNewHeroPrayModel 	= require "Game.Modules.ActNewHeroPray.ActNewHeroPrayModel",
	DirectionalPushModel 	= require "Game.Modules.DirectionalPush.DirectionalPushModel",
}

function ModelManager.init()
	for k,v in pairs(allPath) do
		if(not ModelManager[k]) then
			ModelManager[k] = v.new()
			rawset(_G, k, ModelManager[k])
	    end
	end
end
--切换帐号时的清理
--留着后面修改
function ModelManager.clear(changeRole)
	--不需要清理的表
	local excludeTable = {

	}
	for k,v in pairs(allPath) do
		if(not excludeTable[k] and ModelManager[k]) then
			if ModelManager[k].clear then
				ModelManager[k]:clear()
			end
			ModelManager[k] = nil
		end
	end
	
	RedManager.clear()
	RedManager.start();
	print(0,"清理model完成~~~")
	
end

function ModelManager.loginPlayerDataInit(data)
	for k,v in pairs(allPath) do
		if ModelManager[k] and  ModelManager[k].loginPlayerDataInit then
			ModelManager[k]:loginPlayerDataInit(data)
		end
	end
end

function ModelManager.loginPlayerDataFinish(data)
	for k,v in pairs(allPath) do
		if ModelManager[k] and  ModelManager[k].loginPlayerDataFinish then
			ModelManager[k]:loginPlayerDataFinish(data)
		end
	end
end

return  ModelManager