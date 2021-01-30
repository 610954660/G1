   --活动配置关系
   local ActivityMap = {}
   --actWinMap  对应关系  moduleOpenid ->活动
   ActivityMap.actWinMap = {
      [24] = "SevenDayActView", --七天（弃用）
      [30] = "EightDayActView",--八日
      [39] = "TurnTableView", --聚能寻宝
      [44] = "QuesSurveyView",--问卷调查
      [32] = "PolestarActiveView",--集星
      [34] = "OnlineGiftBagView",--在线礼包
      [50] = "UpgradeActivityView",--限时升级
      [56] = "MoneyBuyGiftView", -- 直购礼包
      [60] = "FirstChargeView",  -- 首充礼包
      [63] = "EverDayAccumulatedView",  -- 每日累充  
      [64] = "AccumulatedAddMoneyView",  -- 累充好礼
      [59] = "TimeLimitGiftView",  -- 限时礼包
      [66] = "PremiumGiftView",     -- 超值礼包
      [71] = "CollectThingView",    -- 集物兑换
      [77] = "WarmakesActiveView",       -- 战令
      [80] = "SuperFundView",       -- 超级基金
      [81] = "SevenDayActView", -- 新7日活动
      [82] = "WeekCardView",        -- 周卡
      [86] = "AccumulativeDayActivityView", -- 充值累计天数活动
      [108] = "WeeklyGiftBagView", -- 每周礼包
      [109] = "MonthlyGiftBagView", -- 每月礼包
      [110] = "NewServerGiftView",         --新服专享礼包
      [112] = "WorkingWelfareView",         --开工福利
      [121] = "AdventureDiaryView", -- 冒险日记
      [116] = "TimeSummonView",  --限时召唤
      [120] = "DelegateActivityView",  -- 委托夺宝
      [122] = "SanctuaryAdventureView", -- 圣所探险
      [119] = "LStarAwakeningView", -- 升星觉醒
      [124] = "UpGetCardActivityView",  -- 精英召唤
      [113] = "LimitedmarketView", -- 限时商城
      [114] = "SpecialgiftBagView", -- 特惠礼包  
      [115] = "WeeklySignInView", -- 每周登录  
      [136] = "FirstChargeLuxuryGiftView",  -- 首充豪礼礼包
      [137] = "AwakeningCharacteristicsView",  -- 特性觉醒
      [140] ="EquipTargetView",     -- 装备目标
      [139] = "EquipUpStarView",    -- 装备升星
      [142] = "NewWeekCardView",    -- 新黑金周卡
      [143] = "SnatchActivityView",    -- 集图夺宝
      [152] = "EquipGiftView", -- 装备礼包
      [164] = "GetCardsYjActivityView",  -- 异界召唤
      [165] = "NieYinComingView",  -- 聂隐降临
      [166] = "OpenTakeWelfareTaskView",  -- 开服福利
	   [168] = "TwistEggView", -- 扭蛋
	   [169] = "TwistEggSignView", -- 扭蛋签到
      [170] = "TwistEggTaskView", -- 扭蛋任务
      [171] = "TwistEggShopView", -- 扭蛋商店
      [172] = "TwistEggLimitGiftView", -- 扭蛋礼包(限时商城)
      [173] = "ElvestoCollectActiveView", -- 精灵收集
      [174] = "ElvesCalledActiveView", -- 精灵召唤
      [175] = "ElvesmalActivelView", -- 精灵商城   
		[180] = "HeroBossActivityView",--新英雄活动副本
	   [181] = "HeroShopView",  --新英雄获得商店
	   [182] = "TwistRuneTaskView",--符文活动
	   [185] = "RuneActiveView",  --符文礼包
	   [187] = "ActFinalRewardView",  --最终赏
	   [188] = "ActATourGiftView",  --一番巡礼
		[189] = "ActATourLimitShopView",   -- 精灵限时商城(巡礼商店)
      [190] = "AnyPrepaidphoneView",  -- 任意充值
      [191] = "CustomizedGiftsView", -- 定制礼包
      [192] = "GroupBuyGiftView", -- 团购礼包
	   [193] = "TwistRegimentView", -- 天降神兵
      [194] = "TimeLimitGiftDupView", -- 重推礼包（可重复的限时礼包）
      [195] = "GetCardsUPActivityView", -- UP招募
      [197] = "backgroundTimeLimitGiftView",  -- 后台限时礼包
      [199] = "ActHeroGatherView",  -- 探员集结
      [200] = "WarmakesElfActiveView",  -- 精灵战令
      [201] = "GoldMagicView",  -- 点石成金
 	   [202] = "DreamMasterPvpView",  -- 梦主争夺
      [203] = "DetectiveTrialView",  -- 探员试炼
      [206] = "ActShrineBlessView",  -- 神社祈福(当铺寻觅)
	   [209] = "QuickBattleView",  -- 作战行动
	   [211] = "ActShrineShopView",  -- 神社商店
      [210] = "ohterOneEveryAddMoneyView",  -- 合集里的每日累充
      [212] = "DetectiveTrialShopView", -- 探员试炼商店
      [213] = "DetectiveTrialGiftView", -- 探员试炼礼包
      [219] = "ActYjShopView", -- 异界招募限时商店
      [220] = "NoBilityWeekGiftView", -- 贵族专享周礼包
      [225] = "BloodAbyssView", -- 血荆之源
      [228] = "WarmakesCriticalActiveView",  -- 临界战令
	   [226] = "ActGodsPrayView", -- 神灵祈愿
      [227] = "GodsLotteryShopView", -- 祈愿商店
      [233] = "FestivalGiftView", -- 圣诞登录礼物
      [234] = "CollectThingShopView", -- 集物兑换商店
      [236] = "CollectWordsActivityView", -- 集字活动
      [237] = "CollectWordsActivityShopView", -- 集字礼包商店
      [235] = "FullsrGiftView", -- 集字礼包商店
      [244] = "WarmakesMazeActiveView", --迷宫战令	
      [254] = "SpecialgiftBagShrinePrayView", --神社祈福特惠礼包
      [255] = "SpecialgiftBagGashaponView", --扭蛋特惠礼包
      [256] = "SpecialgiftBagTourView", --巡礼特惠礼包
      [257] = "SpecialgiftBagHeroTrialView", --探员试炼特惠礼包
      [258] = "TrialActivityView", --阵营试炼
      [259] = "HeroSummonShopDayView", --精英召唤每日限时商城
      [267] = "WarmakesPolaarActiveView",  -- 极地战令  
      [261] = "AccumulatedAddMoneyView1",  -- 累充好礼
      [270] = "WarmakesHallowsActiveView",  -- 圣器战令
      [271] = "PopularVoteEmptyView",  -- 人气票选
      [272] = "PopularVoteTaskView",  -- 人气票选任务
      [273] = "PopularVoteShopView",  -- 人气票选商城
      [279] = "CooperationActivitieMainView",  -- 领地协战
      [281] = "CooperationActivitieShopView",  -- 物资兑换
      [282] = "CooperationActivitieLimitView",  -- 协力商城
      [289] = "ActCommonBossView",  -- 通用节日BOSS活动
      [291] = "ActCommonShopConVertView",  -- 通用节日BOSS活动-兑换
      [292] = "ActCommonShopView",  -- 通用节日BOSS活动-商城
      [295] = "TwistSpFestivalView",  -- 春节寄语
      [294]  = "ElfFinalSecondView",    -- 最终奖赏2
      [297]  = "WarmakesSmallElfActiveView",    -- 小额精灵战令
      [304]  = "SurveyQuestionView",    -- 问卷调查
      [305]  = "NewYearActivityMainView",    -- 问卷调查
      [298]  = "LanternDrawView",   -- 元宵抽奖
      [299]  = "LanternSignView",   -- 元宵签到
      [300]  = "LanternTaskView",   -- 元宵任务
      [301]  = "LanternShopView",   -- 元宵商城
      [302]  = "LanternLimitGiftView",   --元宵礼包
      [308]  = "ActNewHeroPrayView",   --新英雄售卖
      [309]  = "ActNewHeroShopConVertView",   --新英雄售卖
      [310]  = "ActNewHeroShopView",   --新英雄售卖
    }
   
   --预告页面配置
   ActivityMap.actYugaoMap = {
      [1] ="SevenDayYugaoView",
      -- [1] = "MoneyBuyGiftView",
   }

   showContent = {xxID = 3}

   --有新加合集时填写
   --UI合集样式 默认是1  Id->合集UI样式  
   ActivityMap.ActivityFrame = {
     [1] = "ActivityFrameView",
     [2] = "ActivityFrame1View",
     [3] = "ActivityFrame2View",
     [4] =  "ActivityFrame3View",
     [5] =  "ActivityFrame4View", -- 装备活动集合
     [6] =  "ActivityFrame5View", -- 精灵活动集合
     [7] =  "ActivityFrame6View", -- 充值活动集合
     [8] =  "ActivityFrame2View", -- 符文活动
     [9] =  "ActivityFrame7View", -- 限时特惠活动合集
     [10] = "ActivityFrame2View", -- 一番巡礼系列
     [11] = "ActivityFrame2View", -- 幸运扭蛋系列
     [12] = "ActivityFrame2View", -- 蔷薇圣宴系列
     [13] = "ActivityFrame2View", -- 限时召唤系列
     [14] = "ActivityFrame2View", -- 神社祈福系列
     [15] = "ActivityFrame2View",
     [16] = "ActivityFrame2View", -- 集字活动
     [17] = "ActivityFrame2View", 
     [18] = "ActivityFrame2View",
     [19] = "ActivityFrame2View",
     [20] = "ActivityFrame2View",
     [21] = "ActivityFrame2View", -- 节日通用boss  
     [22] = "ActivityFrame9View", -- 协力大作战
     [23] = "ActivityFrame8View", -- 新年活动
     [24] = "ActivityFrame2View",   -- 元宵合集
     [25] = "ActivityFrame2View",   -- 新英雄皮肤售卖
   }
   return ActivityMap
