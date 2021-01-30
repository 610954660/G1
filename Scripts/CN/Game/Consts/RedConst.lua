--红点常量类
--@class RedConst
local RedConst = {}
local tipsMap = {};
local tipsMapList = {}
local midMap = {};
local lastBattleCard = {}
--初始化处理
function RedConst.init()
    local tm = {}
    local maps = {}
    local mIds = {};
    --定义规则：需要在主界面上显示的则为：M开头, 界面内部的，则为V开头
    --任务
    maps["M_BTN_TASK"] = {"V_TASK_DAILY","V_TASK_WEEK","V_TASK_MAIN","V_RETRIEVERED","V_TASK_Achievement"};
    --英雄
    maps["M_BTN_HERO"] = {"V_HERO_0"};     
    --背包
	maps["M_BTN_BAG"] = {"V_BAG_NOR","V_BAG_EQUIP","V_BAG_SPECIAL","V_BAG_HEROCOMP"};
    --商城
    maps["M_BTN_SHOP"] ={"V_SHOP_LIMIT" , "V_SHOP_DISCOUNT"}; 
     --公会
    maps["M_BTN_Guild"] ={"V_Guild_PANDECT","V_Guild_DIVINATION","V_Guild_BOSSRED","V_Guild_SKILL","V_Guild_CYLF","V_Guild_MLS","V_Guild_League"};
    maps["V_Guild_PANDECT"] ={"V_Guild_APPLYRED"};
    maps["V_Guild_DIVINATION"] ={"V_Guild_DIVINATIONRED"};
    maps["V_Guild_BOSSRED"] ={};
    maps["V_Guild_League"] = {"V_GuildLeague_challenge","V_GuildLeague_def","V_GuildLeague_award","V_GLOL_enter",}
    local bossInfo=DynamicConfigData.t_boss
    for copyCode, value in pairs(bossInfo) do
        local key= "V_Guild_BOSSITEM"..copyCode
        table.insert( maps["V_Guild_BOSSRED"], key )
    end
    maps["V_Guild_SKILL"] ={};
    local configInfo=DynamicConfigData.t_guildSkill
    for skillId, value in pairs(configInfo) do
        local skillkey= "V_Guild_SKILLITEM"..skillId
        table.insert( maps["V_Guild_SKILL"], skillkey )
    end
	maps["M_BTN_BattleArray"]={"V_Battle_Array"}
	
	--种族神殿的战斗
    maps["M_HALLOW_FIGHT"] ={51,52,53,54,55}; 
    --跨服竞技标签
    maps["M_CROSS_AREAN"] ={"V_CrossArenaPVP","V_CROSSPVP","V_CROSSTEAMPVP","V_Stride"}; 
    maps["V_CrossArenaPVP"] ={"V_CrossArenapvp_begin","V_CrossArenapvp_defand","V_CrossArenapvp_reward","V_CrossArenapvp_zan","V_CrossArenapvp_record"}; 
    mIds["V_CrossArenaPVP"] = ModuleId.CrossArena.id
	
	maps["V_Battle_Array"] ={};
	--爬塔的全部玩法后台战斗标记点亮
	maps["V_PATA"] ={GameDef.BattleArrayType.Tower,GameDef.BattleArrayType.HumanTower,GameDef.BattleArrayType.OrcsTower,GameDef.BattleArrayType.MachineryTower,GameDef.BattleArrayType.FairyDemonTower};
	--虚空幻想境后台战斗标记点亮
	maps["V_EndlessTrial"] ={GameDef.BattleArrayType.DreamLandSingle,GameDef.BattleArrayType.DreamLandMultiple};
	--临界之旅红点map
	--maps["V_Boundary"] ={"V_Boundary_Reward"};
	--无尽试炼后台战斗标记点亮
	maps["V_Voidland"] ={};
	
	--次元裂缝后台战斗标记点亮
	maps["V_GuildWorlBoss"] ={GameDef.BattleArrayType.GuildWorldBossNumOne,GameDef.BattleArrayType.GuildWorldBossNumTwo,GameDef.BattleArrayType.GuildWorldBossNumThree};
	--公会boss后台战斗标记点亮
	maps["V_GuildNormalBoss"] ={GameDef.BattleArrayType.GuildDailyBoss,GameDef.BattleArrayType.GuildLimitBoss};
	
	--魔灵山后台战斗标记点亮
	maps["V_EvilMountain"] ={GameDef.BattleArrayType.EvilMountain,GameDef.BattleArrayType.EvilMountainTwo};
	
	--圣器副本后台战斗标记点亮
	maps["V_RELICBATTELPONT"] ={GameDef.BattleArrayType.HallowFairy,GameDef.BattleArrayType.HallowDemon,GameDef.BattleArrayType.HallowOrcs,GameDef.BattleArrayType.HallowHuman,GameDef.BattleArrayType.HallowMachinery};
    
    --月慑神殿后台战斗标记点亮
    maps["V_MOONAWETEMPLEPOINT"] ={GameDef.BattleArrayType.StarTemple};
    
    --公会联赛后台战斗标记点亮
	maps["V_GuildLeague"] ={GameDef.BattleArrayType.GuildPvpAttack};
    
    --巅峰竞技赛红点
	maps["V_Stride"] ={GameDef.BattleArrayType.TopArenaAckOne};
	
	
	
	for k, arrayType in pairs(GameDef.BattleArrayType) do
		table.insert(maps["V_Battle_Array"],arrayType)
	end
	
	--聊天
    maps["M_CHAT"] ={"V_CHAT_PRIVATE" , "V_CHAT_GUILD", "V_CHAT_WORLD","V_CHAT_CROSSREAL", "V_CHAT_WORLDCROSS","V_CHAT_SENDGIFTRED"};  
    --爬塔
    maps["M_TOWER"] ={"V_TOWER"}; 
	mIds["V_TOWER"] = ModuleId.Tower.id
    maps["V_TOWER"] ={"V_TOWER_RANK","V_TOWER_MAINVIEW","V_TOWER_SWEEP"};
	
    maps["V_MAIN_SHILAIN"] = {"V_DailyPlay", "V_RELICCOPYRED","V_DEVILROAdRED"};
    maps["V_DailyPlay"] = {"M_MAZE", "M_FAIRYLAND", "M_ENDLESSROAD","M_MATERIALCOPYRED","M_ENDLESSTRIAL","V_PVESTARTEMPLE", "V_VOIDLAND",}
    maps["M_SUBBTN2"] = {"v_ArneaMain", "V_MOONAWETEMPLE"}

    maps["V_VOIDLAND"] = {"V_VOIDLAND_AWARD"}
	mIds["V_VOIDLAND"] = ModuleId.Voidland.id
	mIds["M_ENDLESSTRIAL"] = ModuleId.EndlessTrial.id
	mIds["V_RELICCOPYRED"] = ModuleId.RelicCopy.id
	mIds["V_DEVILROAdRED"] = ModuleId.DevilRoad.id
	
    maps["V_UNLOCKSPEED"]={}
    for k, v in pairs(DynamicConfigData.t_FightSpeed) do
	     table.insert(maps["V_UNLOCKSPEED"],"V_unlockSpeed"..v.moduleID)
		 mIds["V_unlockSpeed"..v.moduleID]=v.moduleID
    end
   --竞技场按钮 （世界擂台赛）
	
    maps["M_BTN_ARENA"] ={"V_ArenaChallenge","V_ArenaRecord","V_ArenaDefand","V_ArenaScoreReward"}; --一般竞技场
    mIds["v_ArneaMain"] = ModuleId.Arena.id
    maps["V_WORLDCHALLENG"] ={"V_WORLDCHALLENG_JINCAI","V_WORLDCHALLENG_MYCHALL"}; --世界擂台赛
    maps["v_ArneaMain"] ={"M_BTN_ARENA","V_WORLDCHALLENG", "V_HIGHERPVP"};--试炼界面所有竞技场红点
    mIds["M_BTN_ARENA"] = ModuleId.Arena.id--不写模块id会有问题都要写模块id
    mIds["V_WORLDCHALLENG"] = ModuleId.WorldChallengeMainView.id
    maps["V_HIGHERPVP"] = {"V_HIGHERPVP_HISTORY", "V_HIGHERPVP_REWARD", "V_HIGHERPVP_BEGIN", "V_HIGHERPVP_DEF"};--高阶
    mIds["V_HIGHERPVP"] = ModuleId.HigherPvP.id

	maps["V_CROSSPVP"] = {"V_Crosspvp_begin","V_Crosspvp_defand","V_Crosspvp_record"}
	mIds["V_CROSSPVP"] = ModuleId.CrossPVP.id

    -- 组队竞技
    maps["V_CROSSTEAMPVP"] = {"V_CROSSTEAMPVP_REWARD","V_CROSSTEAMPVP_INVITED","V_CROSSTEAMPVP_FIGHT"};
    mIds["V_CROSSTEAMPVP"] = ModuleId.CrossTeamPVP.id;

    -- 跨服天梯赛
    maps["V_CROSSLADDERS"] = {"V_CROSSLADDERS_HAVETIMES","V_CROSSLADDERS_HEROHOUSE","V_CROSSLADDERS_RECORD"};
    mIds["V_CROSSLADDERS"] = ModuleId.CrossLadders.id;

    -- 跨服天梯冠军赛
    maps["V_CROSSLADDERSCHAMP"] = {"V_CROSSLADDERSCHAMP_PAGEONE","V_CROSSLADDERSCHAMP_PAGETWO"};
    mIds["V_CROSSLADDERSCHAMP"] = ModuleId.CrossLaddersChamp.id;

    --梦主争夺
    maps["V_ACTIVITY_72"] ={"V_DREAMMASTER_JINGCAI","V_DREAMMASTER_MYMATCH","V_DREAMMASTER_MAIN"}; 

    --好友
    maps["M_FRIEND"] ={"V_FRIEND", "V_FRIEND_APPLY"};  
    -- 邮箱
    maps["M_MAIL"] = {"V_MAIL_NEW"};
	
	--秘境
    maps["M_FAIRYLAND"] ={"V_FAIRYLAND" , "V_FAIRYLAND_EX"}; 
	mIds["M_FAIRYLAND"] =ModuleId.FairyLand.id
	--阵法
    maps["M_TACTICAL"] ={"V_TACTICAL_ACTIVE" , "V_TACTICAL_UPGRADE","V_TACTICAL_UPGRADENEW"}; 
	
	--英雄谷
    maps["M_HEROPALACE"] ={"V_HEROPALACE_ACTIVE" , "M_TACTICAL", "V_TACTICAL_ADD"}; 
	mIds["M_HEROPALACE"] = ModuleId.HeroPalace.id
	mIds["M_ENDLESSROAD"] = ModuleId.EndlessRoad.id
	mIds["M_MATERIALCOPYRED"] = ModuleId.Copy.id
    -- 推图
    maps["M_PUSHMAP"] = {"V_CHAPTERREWARDRED","V_DELEGATE","V_CHAPTERTARGETREWARDRED","V_PUSHMAPMOFANGRED","M_BTN_TASK","M_DUTY","V_ACTIVITY_12"};
	 -- 秘武升级一(V_SECRETWEAPONSUPLVRED1) 升级二(V_SECRETWEAPONSUPLVRED2) 突破红点 技能红点(V_SECRETWEAPONSSKILLDIANRED) 提升红点
    maps["M_SECRETWEAPONS"] = {"V_SECRETWEAPONONEKEYUP","V_SECRETWEAPONSTUPORED","V_SECRETWEAPONSPROMOTERED", "V_SECRETWEAPON_REFINE","V_SECRETWEAPON_ILLUSION"};
    maps["M_HANDBOOK"] = {"V_HANDBOOK_WEEKREWARD", "V_HANDBOOK_UPGRADE"};
    maps["V_SECRETWEAPON_ILLUSION"] = {"V_SECRETWEAPON_ILLUSION_REWARD","V_SECRETWEAPON_ILLUSION_ACTIVE"}
	mIds["V_SECRETWEAPON_REFINE"] = ModuleId.SecretWeaponsRefined.id
    mIds["V_SECRETWEAPON_ILLUSION"] = 268
    -- 无尽试炼
    maps["M_ENDLESSTRIAL"] ={"V_ENDLESSTRIAL_SYN","V_ENDLESSTRIAL_OTH"}; 
    mIds["M_ENDLESSTRIAL"] = ModuleId.EndlessTrial.id
    -- 招募
    maps["M_GETCARD"] = {"V_GETCARD_NORMAL","V_GETCARD_SENIOR","V_GETCARD_SPECIAL","V_GETCARD_FRIEND","V_GETCARD_NEWPLAYER","V_GETCARD_UP","V_GETCARD_ALIENLAND","V_GETCARD_DIFFWORLD"};
	--mIds["V_GETCARD_DIFFWORLD"] = ModuleId.GetCard_diffWorld.id
	maps["V_GETCARD_SPECIAL"] = {"V_GETCARD_SPECIAL_1"}
	-- 图鉴
    maps["M_HANDBOOK"] = {"V_HANDBOOK_WEEKREWARD", "V_HANDBOOK_UPGRADE"};
    maps["V_HANDBOOK_NEW"] = {"V_HANDBOOK_NEW_CATEGORY1", "V_HANDBOOK_NEW_CATEGORY2","V_HANDBOOK_NEW_CATEGORY3","V_HANDBOOK_NEW_CATEGORY4","V_HANDBOOK_NEW_CATEGORY5"};
    
    -- 委托任务
    maps["V_DELEGATE"] = {};
    maps["V_BTN_GETONE"] = {};

    -- 摇钱树
    maps["M_GOLDTREE"] = {};
      -- 设置
    maps["M_SETTINGRED"] = {"V_BASESETTINGRED"};
    maps["V_BASESETTINGRED"] = {"V_BASESETTING_49"};

    -- 星辰圣所
    maps["V_PVESTARTEMPLE"] = {"V_PVESTARTEMPLE_TASK"}
    mIds["V_PVESTARTEMPLE"] = ModuleId.PveStarTemple.id

    --迷宫 
    maps["M_MAZE"] ={};
	mIds["M_MAZE"] = ModuleId.Maze.id
	
	
	
	--mIds["M_SPEEDPLUGNIN"] = 
	
    --活动UI框架内  活动  子活动红点动态名称  V_ACTIVITY_ + type
    --非活动框架活动 红点动态名称为 V_ACTIVITY_ + type
    maps["M_ACTIVITYFRAME"] ={};  
    --福利系统
    maps["M_ACTIVITYFULI"] ={"V_SIGN","V_GROWTH", "V_MONTHLYCARD"};  
	
    maps["M_PATA"] ={"V_RECORD" , "V_RANK"};
    maps["M_BTN_RUNE"] ={"V_PACKAGE","V_RUNERESET"};
    maps["V_PACKAGE"] = {"V_PACKAGE_SKILL"}
    maps["M_DUTY"] ={"V_DUTYUP","V_DUTYDAIRY","V_DUTYTASK"};
    maps["M_VIP"] = {"V_VIP"--[[, "V_PRIVILIGEGIFT","V_DAILYGIFTBAG"]]};
    mIds["V_DAILYGIFTBAG"] = ModuleId.DailyGiftBag.id;
    

    -- 登录就送
    maps["M_LOGINSEND"]={};
    mIds["M_LOGINSEND"] =ModuleId.LoginSend.id;

    -- 下载礼包
    maps["M_DOWNLOADGIFT"] = {};
	



    -- 精灵
    maps["M_ELVES"] = {"V_ELVES_ATTRIB","V_ELVES_UPGRADE","V_ELVES_UPSTAR","V_ELVES_SUMMOM","V_ELVES_BAG"};
	
	--扭蛋活动
    maps["V_ACTIVITY_47"] = {"V_TWIST_DRAW_ONE", "V_TWIST_DRAW_TEN", "V_TWIST_DRAW_REWARD"};

    --元宵抽奖
    maps["V_ACTIVITY_119"] = {"V_LANTERN_DRAW_ONE", "V_LANTERN_DRAW_TEN", "V_LANTERN_DRAW_REWARD"};
    --探员投票
    maps["V_ACTIVITY_105"] = {"V_POPULAR_VOTE_ITEM", "V_POPULAR_VOTE_REWARD", "V_POPULAR_VOTE_LOGIN"};
    maps["V_ACTIVITY_109"] = {"V_POPULAR_VOTE_TASK"};
    -- 帮助
   -- maps["M_HELP"] = {"V_HELP_GROUP"};
	
	maps["M_DetectiveAgency"] = {"M_ELVES","M_HANDBOOK","M_HERO_LEVELUP","M_HeroFetters"}--, "V_HERO_UPSTAR"};
	
	maps["M_HeroFetters"] = {"V_HeroFettersFirst","V_HeroFettersReward"};
	maps["V_HeroFettersReward"] = {};
	--是否有探员可以升星
	maps["M_HERO_LEVELUP"] = {};
	
	--训练营红点
	--mIds["M_TRANNING"] =ModuleId.Training.id;
	maps["M_TRANNING"] = {"V_TRANNING_REWARD","V_TRANNING_FIRST"};
	maps["V_TRANNING"] = {};
	mIds["V_TRANNING"] =ModuleId.Training.id;

    --超凡段位赛
    --挑战次数大于0 记录红点 首次段位奖励 王者之证可领取奖励
   maps["M_EXTRAODINARYRED"] ={"V_EXTRAODINARYCOPY" , "M_EXTRAORECORDRED", "M_EXTRAOREFIRSTDANRED", "M_EXTRAOREKINGRED"}; 
	mIds["M_EXTRAODINARYRED"] = ModuleId.ExtraordinarylevelMain.id

    --探员宿舍
    maps["M_HERO_DORMITORY"] = {"V_HERO_DORMITORY_INTERACT","V_HERO_DORMITORY_MEMOIRIST"};

	--事件播报
    maps["M_NEW_EVEN"] = {"V_NEW_EVENT_REWARD","V_NEW_EVENT_VOTE"};
    
    --支援助力
    maps["M_COOPERACHEATING"] ={"V_CooperationActivitieCheatingRed"}; 
	mIds["M_COOPERACHEATING"] = ModuleId.CooperationActivitieCheating.id
	
	--头像
	maps["M_HEAD"] = {"V_HEAD_BORDER","V_HEAD"};
    
    --新年活动
    maps["V_ACTIVITY_126"] = {"V_NEW_YEAR_CONTRIBUTE_ITEM", "V_NEW_YEAR_SMALL_BOSS", "V_NEW_YEAR_BIG_BOSS", "V_NEW_YEAR_BIG_RED_PACK"};
    --...待补充
    --处理逻辑
    for k,items in pairs(maps) do
        if items ~=nil then
            for k1,v1 in pairs(items) do
                if tm[v1]==nil then tm[v1] = {} end
                tm[v1][k] = true
            end
        end
    end  
    tipsMap = tm;    
    tipsMapList = maps;
    midMap = mIds
    RedManager.init(tipsMap , tipsMapList , mIds)
    --
    GlobalUtil.delayCallOnce("RedConst.init", function()
        SevenDayActivityModel:mapReddotKeys()
        AdventureDiaryModel:mapReddotKeys()
    end, nil, 0.1)
end

--初始化卡牌的红点关系(因为只显示上阵的英雄，所以每换编辑阵容后需要重新初始化)
function RedConst.initCardMap()
	local allCardRedMap = {}
	local cardCategoryMap = {{},{},{},{},{},{},{}}
	if lastBattleCard then
		for _,info in pairs(lastBattleCard) do
            local hero = ModelManager.CardLibModel:getHeroByUid(info.uuid)
            if (hero) then
                RedManager.regMid("V_CardEquip"..hero.uuid , {})
                RedManager.regMid("V_CardTalet"..hero.uuid , {})
            
                RedManager.addMap("V_CardDetail"..hero.uuid, {})
                RedManager.addMap("V_Card"..hero.uuid, {})
				RedManager.updateValue("V_CardMatchPoint"..hero.uuid, false)
            end
		end
	end
	local allCard = BattleModel:getArrayInfo(GameDef.BattleArrayType.Chapters, true)
	if allCard.array then
		lastBattleCard = allCard.array
	end
	for _,info in pairs(allCard.array) do
		local hero = ModelManager.CardLibModel:getHeroByUid(info.uuid)
		if not hero then break end
		local cardRedMap = {
							"V_CardStarUp"..hero.uuid,
							"V_CardEquip"..hero.uuid,
							"V_CardDetail"..hero.uuid,
							"V_CardTalet"..hero.uuid,
                            --"V_CardMatchPoint"..hero.uuid,
                            "V_Emblem"..hero.uuid,
                            "V_FASHION"..hero.code,
						}
		RedManager.regMid("V_CardEquip"..hero.uuid , ModuleId.Equipment.id)
        RedManager.regMid("V_CardTalet"..hero.uuid , ModuleId.CardTalent.id)
		
		local detailMap = {"V_CardUpgrade"..hero.uuid, "V_CardStepUp"..hero.uuid, "V_CardMatchPoint"..hero.uuid}
		RedManager.addMap("V_CardDetail"..hero.uuid, detailMap)
		RedManager.addMap("V_Card"..hero.uuid, cardRedMap)
		RedManager.addMap("V_CardEquip"..hero.uuid, {"V_CardEquipWear"..hero.uuid, "V_CardUniqueWeapon"..hero.uuid})

		--table.insert(cardCategoryMap[1], "V_Card"..hero.uuid)
		table.insert(cardCategoryMap[hero.heroDataConfiger.category + 1], "V_Card"..hero.uuid)
		
		local skillMap = {}
		for i = 1, 4 do
			table.insert(skillMap, "V_passiveSkill"..hero.uuid.."_"..i)
		end
		RedManager.addMap("V_CardTalet"..hero.uuid, {"V_CardTaletSkill"..hero.uuid, "V_CardTaletLevel"..hero.uuid})
        RedManager.addMap("V_CardTaletSkill"..hero.uuid, skillMap)
        
        local segmentMap = {}
        for i = 1, 4 do
            table.insert(skillMap, "V_CardStarUp_"..hero.uuid.."_"..i)
        end
        RedManager.addMap("V_CardStarUp"..hero.uuid, segmentMap)
	end
	for i = 2,6,1 do 
		table.insert(allCardRedMap, "V_CardCategory"..(i - 1))
		RedManager.addMap("V_CardCategory"..(i - 1), cardCategoryMap[i])
	end
	
	--print(69, "RedConst.initCardMap" )
	--printTable(69, cardCategoryMap)
	RedManager.addMap("V_CardCategory0", allCardRedMap)
	RedManager.addMap("M_Card", {"V_CardCategory0"})
end

function RedConst.clear()
	RedConst = {}
	tipsMap = {};
	tipsMapList = {}
	midMap = {};
end


return RedConst