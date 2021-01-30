-- const value prefix: 
--Task_				--任务
--Skill_ 			--技能
--Buff_ 			--buff
--Item_ 			--道具
--Scene_ 			--场景
--Map_ 				--地图
--Title_ 			--称号
--Mob_ 				--怪物
--BuffState_ 		--buff效果
--SkillEffect_		--技能效果
--MobRefresh_ 		--刷怪计划
--GameRes_ 			--通用资源格式

-- local SceneType
-- if _CD then
-- 	SceneType = _CD._GD.SceneType
-- else
-- 	if _CD == false then
-- 		SceneType = GameDef.SceneType
-- 	else
-- 		SceneType = loadfile("./GameDef/SceneType.dfr")()
-- 	end
-- end

return {
	--跨服一个组最多的服数量
	MaxCorssGroupServerNum = 8,
	MaxOfflineMs = 120000,--最大离线时间（需要刷新NetDataHandle才能热更，修改后一般可重启生效）
	StartHangUpMs = 20000,--多久没收到客户端数据后开始挂机

	Map_Newbee = 1101002,			--新手地图点。(用灵雾岛不用序章的)

	OfflineExpMinTime = 180,	--离线弹窗最短时间
	PublicCD = 600,				--公共cd

	--frame的单位都是SceneFrameInterval ms
	SceneFrameInterval = 100,	--场景的刷新逻辑帧的时间间隔。
	SceneFrameMobRefresh = 500,	--
	SceneFramePosUpdate = 100,	--移动的检测定时器。
	---
	--这里注意，AI必须必Logic大。
	SceneFrameAI = 500,		--AI的帧触发（可以考虑更长一点。）
	SceneFrameLogic = 200,	--实体逻辑帧。
	---
	SceneSkillFrameInterval = 30,	--技能触发帧

	ChangeJob4Level = 370,	--四转前卡等级

	--odm的这个管制统一以后，系统退出时间就基本上可以定在20秒。（本地开发的话会将这个时间弄得更短）
	ODMCommonUpdateInterval = 15000,--最快每10秒更新一次odm
	ODMCommonUpdateTimerInterval = 5000, --定时器每5秒检测一次odm更新。

	RemoveSrvKeepAliveInterval = 5000,--集群远端静态服务需要有个机制定期更新服务的id。

	

	-- 帮派的中文职位,广播用不知道写去哪里好
	Chairman = "帮主",	
	ViceChairman = "副帮主",
	Elder		= "长老",
	Elite		= "精英",
	Member		= "弟子",
	-- 帮派仓库兑换消耗积分
	WarehouseConsume1 = 83815,
	WarehouseConsume2 = 335260,
	--创建帮派物品的code
	Item_consumeCode = 500040001,

	--登录加VIP成长
	LoginAddVipGrowthValue = 5,

	UseGoldAddVipGrowthValue = 100,

	--模型帧率
	ModelFramesPerSecond = 30,

	-- 广播用的
	NoGuildDesc = "无",

	--等级保护
	NewbeeProtectionLevel = 150,

    --个人改名卡
	Item_MyselfRenameNotBind = 500590001,
	Item_MyselfRenameBind = 500591001,

	--帮派改名卡
	Item_GuildRenameNotBind = 500600001,
	Item_GuildRenameBind = 500601001,
	
	--世界等级开放等级
	WorldLvOpenLv    = 110,          

	-- 购买VIP投资需要的元宝
	VIPInvestmentBuyCost = 300,
	-- 购买VIP投资的等级限制
	VIPInvestmentLvLimit = 4,

	-- 月卡投资物品
	Item_MonthCardInv = 500370002,
	-- 月卡投资消耗元宝
	MonthCardInvestBuyCost = 300,

	-- 安全锁冷却时间
	SecurityLockCDTime = 300,
	-- 安全锁输入多少次错误触发冷却时间
	SecurityLockMaxTimes = 3,

	

	-- 喇叭
	Item_Trumpet = 500030001,

	--记录辅助类型，对应完成的achieveId做两个运算 achieveId//RecordAssistFactor 得出对应p1,  achieveId % RecordAssistFactor 得出对应完成位置N的2^(n-1)值，即900008 相当于完成完成了对应AchieveType.RecordAssist p1 = 9的其中一项成就，并给对应的count += 8
	RecordAssistFactor = 100000,


	--帮派最大等级
	GuildMaxLevel = 10,

	--默契游戏图片个数
	TacitGameImgNum = 15,

	--可以加入跨服的最小开服天数
	CanJoinCrossMinOpenDays = 2,

	--可以分配在同一组跨服的世界等级差最大绝对值
	CanBeSameGroupWorldLevelDiff = 15,


	--绑元兑换每日上限
	BindEmoneyExchangeTodayLimit = 1000,

	--战斗相关
	BattleMaxRound = 30,			--战斗最大回合数
	BattleMaxRage = 10000,			--战斗怒气值满
	BattleSideMaxNum = 8,			--最大战斗单位数
	BattleWarriorDeadKeepRage = 0.3,  --英雄死亡保留的怒气值
 
	TowerGamePlayType = 2000,		--爬塔副本类型

	--改名费用
	RenameDiamondCost	= 200,		--改名所需的费用
}

