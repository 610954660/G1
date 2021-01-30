--added by xhd 控制器管理
---@class ControllerManager
local ControllerManager = {}

local allPath = {
    "Game.Modules.MainUI.MainUIController",
    "Game.Modules.Public.Keyboard.KeyboardController",
	"Game.Modules.Public.CommonMsgController",
	"Game.Modules.Guide.GuideController",
    "Game.Modules.Equipment.EquipmentController",
    "Game.Modules.Login.LoginController",
	"Game.Modules.Card.CardViewController",
	"Game.Modules.Battle.BattleController",
	"Game.Modules.Player.PlayerController",
    "Game.Modules.Arena.ArenaController",
	"Game.Modules.Shop.ShopController",
    "Game.Modules.Bag.BagController",
    "Game.Modules.GetCards.GetCardsController",
    "Game.Modules.Chat.ChatController",
    "Game.Modules.MaterialCopy.MaterialCopyViewController",
    "Game.Modules.PushMap.PushMapController",
	"Game.Modules.Task.TaskController",
    "Game.Modules.Email.EmailController",
    "Game.Modules.Guild.GuildController",
    "Game.Modules.Friend.FriendController",
    "Game.Modules.Pata.PataController",
    "Game.Modules.Maze.MazeController",
    "Game.Modules.FairyLand.FairyLandController",
    "Game.Modules.LoginAward.LoginAwardController",
    "Game.Modules.UpgradeLevel.UpgradeController",
    "Game.Modules.Activity.ActivityController",
    "Game.Modules.SevenDayActivity.SevenDayActivityController",
    "Game.Modules.OperatingActivities.OperatingActivitiesController",
    "Game.Modules.Tactical.TacticalController",
    "Game.Modules.Hint.HintController",
    "Game.Modules.WorldChallenge.WorldChallengeController",
    "Game.Modules.HeroPalace.HeroPalaceController",
    "Game.Modules.RuneSystem.RuneSystemController",
    "Game.Modules.TurnTable.TurnTableController",
    "Game.Modules.GamePlay.GamePlayController",
    "Game.Modules.QuestionnaireSurvey.QuesSurveyController",
    "Game.Modules.ServiceCommit.ServiceCommitController",
    "Game.Modules.GodMarket.GodMarketController",
    "Game.Modules.Duty.DutyController",
    "Game.Modules.UpgradeActivity.UpgradeActivityController",
    "Game.Modules.MoneyBuyGift.MoneyBuyGiftController",
    "Game.Modules.FirstCharge.FirstChargeController",
    "Game.Modules.PriviligeGift.PriviligeGiftController",
    "Game.Modules.TimeLimitGift.TimeLimitGiftController",
    "Game.Modules.TimeLimitDupGift.TimeLimitGiftDupController",
    "Game.Modules.PremiumGift.PremiumGiftController",
    "Game.Modules.CollectThing.CollectThingController",
    "Game.Modules.SecretWeapons.SecretWeaponsController",
    "Game.Modules.EndlessTrial.EndlessTrialController",
    "Game.Modules.PveStarTemple.PveStarTempleController",
    "Game.Modules.SuperFund.SuperFundController",
    "Game.Modules.Debug.DebugController",
    "Game.Modules.WeekCard.WeekCardController",
    "Game.Modules.AccumulativeDayActivity.AccumulativeDayActivityController",
    "Game.Modules.LoginSend.LoginSendController",
    "Game.Modules.DailyGiftBag.DailyGiftBagController",
    "Game.Modules.WeeklyGiftBag.WeeklyGiftBagController",
    "Game.Modules.NoBilityWeekGift.NoBilityWeekGiftController",
    "Game.Modules.MonthlyGiftBag.MonthlyGiftBagController",
    "Game.Modules.NewServerGift.NewServerGiftController",
	"Game.Modules.WorkingWelfare.WorkingWelfareController",
    "Game.Modules.DownLoadGift.DownLoadGiftController",
    "Game.Modules.TimeSummon.TimeSummonController",
    "Game.Modules.SevenDayActivity.AdventureDiaryController",
    "Game.Modules.Activity.DelegateActivity.DelegateActivityController",
    "Game.Modules.SanctuaryAdventure.SanctuaryAdventureController",
    "Game.Modules.LStarAwakening.LStarAwakeningController",
    "Game.Modules.UpGetCardActivity.UpGetCardActivityController",
    "Game.Modules.GetCardsYjActivity.GetCardsYjActivityController",
    "Game.Modules.GetCardsYjActivity.ActYjShopController",
    "Game.Modules.GetCardsUPActivity.GetCardsUPActivityController",
    "Game.Modules.WeeklySignIn.WeeklySignInController",
    "Game.Modules.BloodAbyss.BloodAbyssController",
    "Game.Modules.Talent.TalentController",
    "Game.Modules.ElvesSystem.ElvesSystemController",
    "Game.Modules.FirstChargeLuxuryGift.FirstChargeLuxuryGiftController",
    "Game.Modules.EquipTarget.EquipTargetController",
    "Game.Modules.NewWeekCard.NewWeekCardController",
    "Game.Modules.GuildMagicLingShan.GuildMLSController",
    "Game.Modules.RelicCopyView.RelicCopyViewController",
    "Game.Modules.BoundaryMap.BoundaryMapController",
    "Game.Modules.GodsLotteryShop.GodsLotteryShopController",
    "Game.Modules.TwistEggLimitGift.TwistEggLimitGiftController",
    "Game.Modules.TwistEggTask.TwistEggTaskController",
    "Game.Modules.TwistEggShop.TwistEggShopController",
	"Game.Modules.TwistRune.TwistRuneController",
    "Game.Modules.TwistEgg.TwistEggController",
    "Game.Modules.TwistEggSign.TwistSignController",
    "Game.Modules.Retrieve.RetrieveViewController",
    "Game.Modules.ActATourGift.ActATourGiftController",
    "Game.Modules.ActFinalReward.ActFinalRewardController",
	"Game.Modules.CustomizedGifts.CustomizedGiftsController",
    "Game.Modules.ActATourLimitShop.ActATourLimitShopController",
    "Game.Modules.ActHeroGather.ActHeroGatherController",
    "Game.Modules.GoldMagic.GoldMagicController",
    "Game.Modules.QuickBattle.QuickBattleController",
	"Game.Modules.DreamMasterPvp.DreamMasterPvpController",
    "Game.Modules.DetectiveTrial.DetectiveTrialController",
	"Game.Modules.CrossPVP.CrossPVPController",
	"Game.Modules.CrossArenaPVP.CrossArenaPVPController",
    "Game.Modules.Rank.RankController",
    "Game.Modules.Barrage.BarrageController",
    "Game.Modules.MoonAweTemple.MoonAweTempleController",
	"Game.Modules.TimingPush.TimingPushController",
    "Game.Modules.ActShrineBless.ActShrineShopController",
    "Game.Modules.ActShrineBless.ActShrineBlessController",
    "Game.Modules.DetectiveTrialShop.DetectiveTrialShopController",
    "Game.Modules.DetectiveTrialGift.DetectiveTrialGiftController",
    "Game.Modules.GuildLeague.GuildLeagueController",
    "Game.Modules.Training.TrainingController",
    "Game.Modules.CrossTeamPVP.CrossTeamPVPController",
	"Game.Modules.HeroFetters.HeroFettersController",
    "Game.Modules.ActGodsPray.ActGodsPrayController",
	"Game.Modules.FullsrGift.FullsrGiftController",
    "Game.Modules.CollectWordsActivity.CollectWordsActivityController",
    "Game.Modules.ExtraordinarylevelPvP.ExtraordinarylevelPvPController",
    "Game.Modules.Fashion.FashionController",
    "Game.Modules.CrossLadders.CrossLaddersController",
    "Game.Modules.SealDevil.SealDevilController",
    "Game.Modules.TrialActivity.TrialActivityController",
	"Game.Modules.SpecialgiftBag.SpecialgiftBagController",
    "Game.Modules.Handbook.HandbookController",
    "Game.Modules.StrideServer.StrideServerController",
    "Game.Modules.CrossLaddersChamp.CrossLaddersChampController",
    "Game.Modules.EventBrocast.EventBrocastController",
    "Game.Modules.PopularVote.PopularVoteController",
    "Game.Modules.PopularVote.PopularVoteTaskController",
    "Game.Modules.PopularVote.PopularVoteShopController",
    "Game.Modules.CooperationActivities.CooperationActivitiesController",
    "Game.Modules.TwistSpFestival.TwistSpFestivalController",
    "Game.Modules.ElfFinalSecond.ElfFinalSecondController",
    "Game.Modules.ActCommonBoss.ActCommonBossController",
    "Game.Modules.SurveyQuestion.SurveyQuestionController",
    "Game.Modules.LanternActivity.LanternShop.LanternShopController",
    "Game.Modules.LanternActivity.LanternLimitGift.LanternLimitGiftController",
    "Game.Modules.LanternActivity.LanternTask.LanternTaskController",
    "Game.Modules.LanternActivity.LanternSign.LanternSignController",
    "Game.Modules.LanternActivity.LanternDraw.LanternDrawController",
    "Game.Modules.LanternActivity.LanternRiddle.LanternRiddleController",
    "Game.Modules.NewYearActivity.NewYearActivityController",
    "Game.Modules.DirectionalPush.DirectionalPushController",
    "Game.Modules.ActNewHeroPray.ActNewHeroPrayController",
}

local _controllers = {}

function ControllerManager.init()
    _controllers = {}

    for _, classPath in ipairs(allPath) do
        xpcall(ControllerManager.__register,__G__TRACKBACK__,classPath)
    end
    -- ControllerManager.initRedDotRelated()
end

function ControllerManager.__register(classPath)
    if _controllers[classPath] then
        --reload?
    else
        local class = require(classPath)
        _controllers[classPath] = class.new()
    end
end

-- 动态添加
function ControllerManager.register(classPath, requireNow)
    if not _controllers then
        table.insert(allPath, classPath)
        return
    end

    if not _controllers[classPath] then
        if requireNow then
            ControllerManager.__register(classPath)
        else
            table.insert(allPath, classPath)
        end
    else
        error(classPath .. " already existed!")
    end
end

function ControllerManager.clear()
    for k, v in pairs(_controllers) do
        if v.clear then
            v:clear()
        end
		_controllers[k] = nil
    end
    -- ControllerManager.clearRedDotRelated()
end

--reload 控制器
function ControllerManager.reloadController(classPath, newClass)
    local cls = _controllers[classPath]
    if cls then
        cls:clear()
    end
    _controllers[classPath] = newClass.new()
end

return ControllerManager