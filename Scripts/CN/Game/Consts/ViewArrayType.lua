local OpenParam=require "Game.Consts.OpenParam"
return {

	[3]={id=6,view= "ArenaPerformView"},--竞技场


	[4] = {id=21, view= "PushMapCheckPointView"},--侦查

    [5]= {id=7, view= "MaterialCopyView",args={moduleId=101}}, --日常副本金币
	
	[6]={id=5, view= "PataView",args= OpenParam.PataParam[2000]},
	[7]={id=5, view= "PataView",args= OpenParam.PataParam[2001]},  
	[8]={id=5, view= "PataView",args= OpenParam.PataParam[2002]},  
	[9]={id=5, view= "PataView",args= OpenParam.PataParam[2003]},  
	[16]={id=5, view= "PataView",args= OpenParam.PataParam[2005]},
	--HumanTower			= 7,	--人族塔
	--OrcsTower 			= 8,	--兽族塔
	--MachineryTower		= 9,	--机械塔
	[10]={id=10, view= "GuildBossView"},
	[11]={id=11, view= "GuildBossView"},
	--GuildDailyBoss 		= 10,	--公会日常BOSS
	--GuildLimitBoss		= 11,	--公会限时BOSS
	[12] = {id=22, view= "MazeView"},
	--FairyLand			= 13,	--秘境
	[13] = {id=25, view= "FairyLandView"}, -- 秘境
	--EndlessRoad			= 14,	--远征
	[14] = {id=36, view= "ExpeditionView"},
	--WorldArena			= 15,	--世界擂台赛阵容
	--FairyDemonTower 	= 16,	--仙魔塔
	--TopChallenge		= 17,	--无尽试炼  --废弃,后续可以用来作为其他试炼,重命名下即可
	--PveStarTemple 		= 18,	--晨星
	[17] = {id = 133,view = "GuildMLSMainView"}, 	-- 魔灵山
	[30] = {id = 133,view = "GuildMLSMainView"}, 	-- 魔灵山
	
	[18]=  {id = 72,view = "PveStarTempleMainView"},
	[19] = {id = 132, view = "VoidlandView"},
	[20] = {id = 132, view = "VoidlandView"},

	[24] = {id = 24, view = "BoundaryMapView"},
	[25] = {id = 180, view = "ActivityFrame2View",args = {page="HeroBossActivityView"}},
	
	[26] = {id = 193,	view = "TwistRegimentView"},--大富翁活动
	[28] = {id = 203,	view = "DetectiveTrialView"}, -- 探员试炼

	[31] = {id = 225,	view = "BloodAbyssMainView"}, -- 幻魔之境
	
	[32] = {id = 29,	view = "SealDevilView"}, --封魔之路
	[34] = {id = 296,	view = "PowerPlanView"}, --异能计划
	
	
	
	
	
	[57] = {id = 204,view = "GuildLeagueFortView"}, -- 公会联赛
	
	
	[58] = {id = 58, view = "BoundaryMapView"},
	[59] = {id = 59, view = "BoundaryMapView"},
	[60] = {id = 60, view = "BoundaryMapView"},
	[61] = {id = 61, view = "BoundaryMapView"},
	

	--公会跨服BOSS阵容(策划要求每个BOSS一套阵容, boss类型以后会扩展, 现在预留20个)
	[101] ={id = 85,view ="GuildFissureView"},	--公会跨服BOSS 1号BOSS
	[102] ={id = 85,view ="GuildFissureView"},		--公会跨服BOSS 2号BOSS
    [103] ={id = 85,view ="GuildFissureView"},--公会跨服BOSS 3号BOSS


	--跨服竞技场
	[3031] = {id = 222, view = "CrossArenaPVPView"},	--跨服竞技场 攻击队伍1
	[3032] = {id = 222, view = "CrossArenaPVPView"},	--跨服竞技场 攻击队伍2
	[3033] = {id = 222, view = "CrossArenaPVPView"},	--跨服竞技场 攻击队伍3
	[3034] = {id = 222, view = "CrossArenaPVPView"},	--跨服竞技场 防守队伍1
	[3035] = {id = 222, view = "CrossArenaPVPView"},	--跨服竞技场 防守队伍2
	[3036] = {id = 222, view = "CrossArenaPVPView"},	--跨服竞技场 防守队伍3


	[1000] = {id = 79, view = "HigherPvPView"},
	[1001] = {id = 79, view = "HigherPvPView"},
	[1002] = {id = 79, view = "HigherPvPView"},
	[2000] = {id = 79, view = "HigherPvPView"},
	[2001] = {id = 79, view = "HigherPvPView"},
	[2002] = {id = 79, view = "HigherPvPView"},

	[51] = {id = 153, view = "MainSubBtnView",args = {page="RelicCopyView"}},
	[52] = {id = 153, view = "MainSubBtnView",args = {page="RelicCopyView"}},
	[53] = {id = 153, view = "MainSubBtnView",args = {page="RelicCopyView"}},
	[54] = {id = 153, view = "MainSubBtnView",args = {page="RelicCopyView"}},
	[55] = {id = 153, view = "MainSubBtnView",args = {page="RelicCopyView"}},

	HorizonPvpAckOne		= 3011,	--天域赛PVP 1v1攻击阵容 
	HorizonPvpAckThree		= 3012,	--天域赛PVP 3v3攻击阵容 
	HorizonPvpAckSix		= 3013,	--天域赛PVP 6v6攻击阵容 
	HorizonPvpDefOne		= 3014,	--天域赛PVP 1v1防守阵容 
	HorizonPvpDefThree		= 3015,	--天域赛PVP 3v3防守阵容 
	HorizonPvpDefSix		= 3016,	--天域赛PVP 6v6防守阵容

	[3011] = {id = 3011, view = "CrossPVPView"},
	[3012] = {id = 3012, view = "CrossPVPView"},
	[3013] = {id = 3013, view = "CrossPVPView"},
	[3014] = {id = 3014, view = "CrossPVPView"},
	[3015] = {id = 3015, view = "CrossPVPView"},
	[3016] = {id = 3016, view = "CrossPVPView"},
	
	[4000] = {id = 215,	view = "CrossTeamPVPMainView"}, -- 组队竞技
	[4015] = {id = 246,	view = "CrossLaddersMainView"}, -- 跨服天梯赛
	[4017] = {id = 258,	view = "TrialActivityView"}, -- 阵营试炼
	[4018] = {id = 277,	view = "CrossLaddersChampPrimaryView"}, -- 天梯冠军赛

	[3041] = {id = 243,	view = "ExtraordinarylevelMainView"}, -- 超凡段位赛
	[3042] = {id = 243,	view = "ExtraordinarylevelMainView"}, -- 超凡段位赛

}