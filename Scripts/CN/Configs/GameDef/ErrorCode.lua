--服务器的下来的errorcode。客户端不建议共用。配合服务器优化，不改了,客户端这部分改成工具生成，将code和注释换过去，并将对应的string 变成注释。
return {
	Timeout 					= 1,		--调用超时了
	NoReturn					= 2,		--调用没返回
	DataError					= 4,		--数据异常
	ServiceError				= 3,		--服务器开小差了,请联系客服
	SetTimerError				= 5,		--设置定时器异常
	FrameTimerNotInit 			= 6,	
	FrameTimerHasStart 			= 7,			
	ServieHasNoConnection 		= 8,
	SendMsgFindNoEntity 		= 9,
	LoginAuthError 				= 10,
	PlatformNotDef 				= 11,		--没平台数据
	PlatformAuthErr 			= 12,		--平台验证错误
	OthersInLogin 				= 13,
	NotPassAuthCheck 			= 14,
	SrvNameDuplicate 			= 15,
	ServiceHasDwon 				= 16,
	MethodNotFound 				= 17,
	ComponentInitTooEarly		= 18,		--组件过早被加载
	TypeNotDefined 				= 19,		--类型不存在
	StaticSrvNotExist			= 20,		--静态服务不存在
	ComponentNotExist 			= 21,		--组件不存在
	IsNotAGameObject			= 22,		--不是GameObject
	ComponentHasExist			= 23,		--组件已经存在不能重复建立
	IsNotComponent				= 24,		--该类不是组件
	InputParamMissing			= 25,		--一些输入缺少了
	HandlerNeedsType			= 26,		--类型处理器必须要有匹配类型
	DubugModeOnly				= 27,		--非开发模式禁止调用
	HandlerTypeNotNumber		= 28,		--handler的type传错了，一般发生在这个handler用:的情况
	UidCreateError				= 29,		--本地服务获取不了对应的uid
	ServerDoesNotExist			= 30,		--服务器不存在
	ParamError					= 31,		--参数错误
	TestInterfaceForbidden		= 32,		--测试接口被屏蔽
	DebugOnly					= 33,		--仅允许在本地测试环境下运行
	IsNotClassInstance			= 34,		--不是类实例
	ClassNameHasDefineInParent	= 35,		--类名字已经出现在父类中
	ServiceNoCallBack			= 36,		--内部服务没返回
	FactoryNotFindingItsType	= 37,		--工厂并没找到对应的类型
	FactoryNotFindingItsHandler = 38,		--工厂并没找到对应的处理方法
	TimerStartIntervalTooBig	= 39,		--定时器时间间隔太长
	GameDefCanNotBeChange		= 40,		--游戏定义或配置文件都不能改
	GameDefNotExist				= 41,		--游戏定义文件不存在
	ServerNotStart 				= 42,		--服务器君正在努力启动中
	ClusterInfoError			= 43,		--集群信息错误
	GetServerIdError			= 44,		--集群配置中获取服务ID异常
	SrvBindObjIsNotSameKind		= 45,		--Snsa服务绑定对象不能是不同类型对象。（必须继承于首个绑定的对象）
	RedirectSelfAtreqFail		= 46,		--重定向服务绑定对象调用错误
	GameObjNotFoundInSnsa		= 47,		--绑定GameObject不存在
	StaticServiceIsNotExist		= 48,		--静态服务不存在
	StaticServiceIsNotReady		= 49,		--静态服务没准备好
	TimeOutForQueryingSrvice	= 50,		--请求服务超时
	ClusterKeyNotMatch			= 51,		--集群的key对不上
	WaitLastNodeExit			= 52,		--等待上个集群节点退出
	ClientVerError				= 53,		--客户端版本错误
	InputParamMissingName		= 54,		--名字不能为空
	InputParamMissingCareer		= 55,		--职业不能为空
	InputParamMissingMac		= 56,		--Mac不能为空
	TryItself					= 57,		--地址一样不能调用
	NodeLock					= 58,		--节点已经被锁了
	RouterFailed				= 59,		--消息路由节点失效
	LoginLogicError				= 60,		--登陆验证失败Hero_NotHeroTransform
	MasterIDCenterIsOK 			= 61,		--主IDCenter运行正常
	NoMasterIDCenter			= 62,		--没有配置主IDCenter
	TimeoutFuncNotExist			= 63,		--超时处理函数不存在
	CommonErrorStr				= 64,		--%s
	ProtoIsClosed 				= 65,		--该功能正在优化中，请稍等
	ProtoIsInvalid 				= 66, 	    --唉哟，请联系客服


	--物品背包系统用100-200
	ItemConfigNotExist			= 100,		--物品配置不存在
	NotEnoughSpace 				= 101,		--背包空间不足,请清理完成后再领取
	ItemGetNoComponent			= 102,		--物品的Component没实现
	ItemConfigCheckError		= 103,		--物品配置检测错误
	ItemNotExist				= 104,		--物品不存在
	ItemNotEnough				= 105,		--物品数量不足
	BagNotDefine				= 106,		--没有对应的背包
	ItemAlreadyExist			= 107,		--物品已存在	
	ItemUuidMissing				= 108,		--物品缺少uuid这是个非法物品
	BagAlreadyExist				= 109,		--背包已经存在
	BagTypeError				= 110,		--背包类型错误
	BagCreateError				= 111,		--背包建创错误
	ItemSexError				= 112,		--性别不符
	RoleLevelError				= 113,		--等级不足
	RoleCareerError				= 114,		--职业不符
	BagDiscardError				= 115,		--当前背包物品不可丢弃
	ItemDiscardError			= 116,		--当前物品不可丢弃
	ItemSplitError				= 117,		--当前背包物品不可拆分
	ItemUseError				= 118,		--物品不可使用
	BagIsEmpty					= 119,		--当前背包为空
	OverMaxAmount				= 120,		--超过最大叠加数
	ItemObjAlreadyExist			= 121,		--格子上已经有物品
	ItemObjNotExist				= 122,		--格子不存在
	ShowItemNotEnough			= 123,		--物品数量不足
	ItemTypeError				= 124,		--物品类型不符
	ShowNotEnoughSpace 			= 125, 		--背包空间不足, 物品已通过邮件发放
	RoleReinLevelError			= 126,		--转生等级不足
	EquipCannotMove 			= 127,		--装备不能移动
	EquipItemNotEqual 			= 128,		--物品数量不等
	EquipNumError 				= 129,		--装备数量错误
	SameTypeEquipExist 			= 130,		--同类型装备已存在
	LvUpExpDragUseError			= 131,		--大于等于80级不能使用该物品
	AresCallLeftTimesMax		= 132,		--召唤次数已达上限
	NoRemainUseTimes	 		= 133,		--今天使用次数已用完
	ItemStackOverflow			= 134,		--物品堆叠数超过上限
	GoldBrickUseTimeNotEnough 	= 135,		--今天使用次数已用完，升级特权卡可增加次数
	WeaponShouldBeCarried		= 136,		--请先装备上武器
	NoPKValue					= 137,		--当前红名值为0，无法使用此道具减少红名值
	EquipIsNotEquip				= 138,		--不是装备
	EquipOutofDate				= 139,		--这件装备已过期
	ItemOutofDate				= 140,		--这个物品已过期
	EquipSuitLevelError			= 141,		--激活套装等级错误
	EquipIsNotSuit				= 142,		--装备的颜色或星级未达到打造要求
	WildBossCountZero 			= 143,		--少侠你暂时没有疲劳度，无法使用疲劳药水
	PickupNotEnoughSpace		= 144,		--背包已满，无法拾取
	CurseWildBossOutOfRange		= 145,		--使用数量超过能恢复的疲劳值
	ItemCanNotDecompose			= 146,		--该物品不能分解
	OptionalGiftBoxNotOption    = 147,      --未选中物品
	ItemNotCanSell              = 148,      --该道具不可出售
	EquipCanNotRecast 			= 149,		--橙色及以上的装备才可以重铸

	--角色登陆201-220
	PlayerNotExist				= 201,		--玩家不存在
	SamePlayerInLogin			= 202,		--同角色玩家在登陆中
	CreateRoleError				= 203,		--创建角色异常
	NameHasExist				= 204,		--名字已经存在
	NameIsNoReg					= 205,		--该名字无法注册,请重新输入
	CreateRoleDBError			= 206,		--玩家角色数据库创建失败。
	KickOutErrorOnWaiting		= 207,		--踢出玩家异常
	NameFilterErr 				= 208,		--名字中包含敏感词,请重新输入
	GM_LOCKED					= 209,		--您已被系统锁定,请联系客服处理
	IP_LOCKED 					= 210,		--您的IP已被系统锁定,请联系客服处理
	PlayerNotExistInAccount		= 211,		--角色不在该账户中
	PlayerDelFailed				= 212,		--角色删除失败
	NameTooLong					= 213,		--字数太多
	CreatRoleMax 				= 214,		--角色数量已达上限,创建失败
	Name_IsSpecial 				= 215,		--包含特殊字符%s,请重新输入
	MAC_LOCKED 					= 216,		--您的机器已被系统锁定,请联系客服
	IsLogining					= 217,		--正在登陆中
	Name_BlankSpaceNotAllowed	= 218,		--命名中不可以有空格

	--货币消耗221-240
	Money_NotEnough				= 221,		--货币不足
	Money_ShowNotEnough			= 222,		--货币不足
	Money_TypeError				= 223,		--货币类型错误
	Money_ExchangeError			= 224,		--货币兑换错误

	--商店系统241-259
	CanNotByThisShopItems		= 241,		--该商店物品不能购买
	Shop_ItemNotExist			= 242,		--商店中无该物品出售
	Shop_ItemExpire				= 243,		--商品已过期
	Shop_LimitsCouts			= 244,		--限购刷新次数多
	Shop_LimitsMoney			= 245,		--限购刷新钱不够
	Shop_NotType				= 246,		--找不到此类型
	Shop_ItemAmount				= 247,		--大于物品的数量
 
	--跨服260-299
	Cross_NCapDuplicated 		= 260,	--有N*跨服的nCapId被重复持有了。

	
	--300-350
	Scene_MapNotExist				= 300,		--地图不存在
	Test_CanNotSpeedUpInTrunk       = 301,		--Trunk服禁止加速时间

	--351-400 GM命令控制
	GMControl_Consume			= 351,		--现控制资源消耗及流通，请耐心等待本服恢复正常。

	--角色属性501-599
	ExpError					= 501, 		--经验增加值错误
	CultivationError            = 502,      --修为不足
	ExpLevelError				= 503,		--等级经验不存在
	Attr_ExpNotEnough			= 504,		--经验不足
	AlreadyActivated			= 505,		--已经激活

	--ODM错误600 - 650
	OdmAddOtherOdmNode			= 600,		--odm节点应该显示调用copy来做赋值。
	OdmNodeConfigNotExist		= 601,		--odm几点对应的配置不存在。
	OdmRootIsNotOdmNode		 	= 602,		--odm节点的根节点不是odm
	OdmKeyMustBeNumberOrString	= 603,		--odm节点必须是数字或者字符
	OdmValueNotMatchWithConfig 	= 604,		--odm的数值跟个配置不匹配
	OdmUnknownConfigType		= 605,		--未知的odm配置数值类型
	OdmOidValueError			= 606,		--oid的数值跟定义的oid数值不一样，这是个严重的问题。
	OdmWriteError				= 607,		--odm更新出错节点没有配置
	OdmKeyTypeNotMatchToKey		= 608,		--odm的结构中的key值不等于key的值
	OdmNewNodeError				= 609,		--odm的新的节点怀疑具有其他odm节点信息
	OdmContainerConfigError		= 610,		--odm的容器配置错误(_key and _value),需要同时出现。
	OdmKeyNotFoundInValue		= 611,		--odm的_key是字段名，但是在_value里面没找到
	OdmContainerValueError		= 612,		--odm容器的值的类型匹配不上
	Odm_DataBaseNotExist		= 613,		--odm对应数据库不存在
	Odm_LastUpdateError			= 614,		--数据更新异常,请联系客服
	Odm_DataFixError			= 615,		--odm数据整理错误。
	Odm_DataNeverBeFunction		= 616,		--odm数值不可能为function
	Odm_DataNeverBeUD			= 617,		--odm数值不可能为userdata
	Odm_NumberIsNotRight		= 618,		--odm数字类型不可能为inf,-inf,nan
	Odm_KeyCanNotToBeNum		= 619,		--odm的key值，不能被转化成需要的number
	Odm_CreateOdmError			= 620,		--创建odm数据失败
	Odm_RawDataMissUID			= 621,		--odm原始创建数据必须包含uid即_id
	Odm_AutoUpdateMustHasFailedHandler = 622,--自动更新的ODM必须包含更新失败处理器。
	Odm_ConfigNotExist			= 623,		--没有对应的odm配置
	Odm_AutoUpdateMustBindRoot	= 624,		--odm自动更新必须绑定在root上


	
	--技能战斗651-800
	SkillNotExist				= 651,		--技能不存在
	SkillInCD					= 652,		--技能正在cd中
	SkillReleasing				= 653,		--技能正在施放中
	MpNotEnought				= 654,		--mp不足

	--任务801-900
	Task_TaskNotInCanGetStatus	= 801,		--任务不在可接取状态
	Task_TaskNotInFinishedStatus = 802,		--任务不在已完成状态
	Task_TaskNotExist			= 803,		--任务不存在
	Task_TaskCanNotQuickFinish	= 804,		--该任务无法快速完成
	Task_TaskNotInDoingTask		= 805,		--任务不在进行中状态
	Task_TransportCantPass		= 806,		--护送任务中，不可前往
	Task_GuildTaskGetDonate 	= 807,		--获得%s帮派贡献
	Task_GuildTaskGetMoney		= 808,		--获得%s帮派资金
	Task_GuildTaskFinishAll		= 809,		--已完整本周任务
	Task_CategoryNotActive		= 810,		--任务大类尚未激活
	Task_NotSelectReward		= 811,		--请先选择奖励类型
	Task_OdmError 				= 812,		--任务数据异常，请联系客服
	Task_TaskChapterRewardGot 	= 813,		--奖励已领取
	Task_TaskChapterNotComp 	= 814,		--请先完成章节内所有任务
	Task_InOtherServer 			= 815,		--您正在其他服务器中,无法操作

	--限制类型错误 1301-1320		
	LimitConfigNotExist			= 1301,		--限制的配置不存在
	Limited 					= 1302,		--次数已用完
	CDLimited					= 1303,		--cd次数限制
	ConsumeTimesDataError		= 1304,		--限制次数不能小于0
	LimitCanNotAddTopup			= 1305,		--不能增加次数上限了

	--玩法系统GamePlay 1321-1350
	

	--玩法系统 1321-1550
	GamePlay_IsNotOpen			= 1321,		--功能尚未开放
	GamePlay_NotExist			= 1322,		--功能配置不存在
	GamePlay_DataNotDefine		= 1323,		--玩法数据并没有定义缩写（见GamePlayType.df)
	GamePlay_NoData				= 1324,		--还没有玩法数据
	GamePlay_GamePlayPanelRewardGot = 1325,	--奖励已领取
	GamePlay_MinCapNotEnough = 1326,			--跨服条件不足
	GamePlay_WorldLevelNotEnough = 1327,			--世界等级不足
	GamePlay_InMaintain			= 1328,		--功能正在优化中
	GamePlay_NotPower 			= 1339,		--战力不足
	GamePlay_NotConditions 		= 1340,		--条件不足
	--邮件
	Mail_TitleNotDefine			= 1585,		--标题id没定义
	Mail_ContentNotDefine		= 1586,		--内容id没定义
	Mail_NotNeedClean			= 1587,		--无可清理邮件
	Mail_OneKeyExtractError 	= 1588,		--一键提取失败
	Mail_MailNotEixst 			= 1589,		--邮件不存在

	--聊天系统	 1611-1650
	Chat_InitInfoIsNull			= 1611,		--初始化聊天模块得到数据为空
	Chat_ChannelNoType			= 1612,		--没有对应类型的频道
	Chat_ChannelIsExisted		= 1613,		--频道已经存在
	Chat_ChannelNotExist		= 1614,		--频道不存在
	Chat_RepeatSubscrib			= 1615,		--重复订阅
	Chat_EmptyContent			= 1616,		--空消息
	Chat_playerIdError			= 1617,		--玩家id错误
	Chat_TooFrequently 			= 1618,  	--请勿频繁操作
	Chat_NotInGuild				= 1619,		--你已经不在帮派中
	Chat_NotInTeam				= 1620,		--你已经脱离队伍
	Chat_Blacklist1				= 1621,		--请先将对方移出黑名单
	Chat_Blacklist2				= 1622,		--对方已将你拉入黑名单，无法发送消息
	Chat_ItemNotExist			= 1623,		--你要发送的物品已经不存在
	Chat_PrivateChat 			= 1624,		--未选择聊天对象
	Chat_MsgTooLong				= 1625,		--发送消息过长
	Chat_HaveNotFriend 			= 1626,		--没有好友
	Chat_IsCoolingDown			= 1627,		--发言过快，%s秒后才能发言
	Chat_BagNotExist			= 1628,		--你要发送的物品所属背包不存在

	CallBoss_MapForbid			= 1695,		--物品不能在该地图使用
	CallBoss_CopyForbid 		= 1696,		--物品不能在副本中使用
	CallBoss_SafeAreaForbid 	= 1697,		--物品不能在安全区使用

	-- 副本	1701-1900
	Copy_EntranceIsClosed		= 1701,		--副本入口已关闭
	Copy_ActiveClosed			= 1702,		--活动不在开启期间，可在活动界面查看具体开启时间
	Copy_NoPassCanNotGetRewards = 1703,		--副本未通关,领取失败
	Copy_RemoveError			= 1704,		--副本销毁失败
	Copy_MICannotIntoScene 		= 1705,		--入口已关闭
	Copy_IntervalEnough			= 1706,		--进入间隔不足
	Copy_MaxTowerCount 			= 1707,		--防御塔数量已达上限！
	Copy_BuildInInvalidPos 		= 1708,		--这个位置已经有一座防御塔了！
	Copy_NoReward 				= 1709,		--没有可领取的奖励
	Copy_BuildTowerError		= 1710,		--建造防御塔出现未知错误
	Copy_CannotHide				= 1711,		--隐身无效
	Copy_DLComingIsEnd			= 1712,		--魔君已被击杀，活动结束
	Copy_DLComingNoTimes1		= 1713, 	--绑元鼓舞次数已用完
	Copy_DLComingNoTimes2		= 1714, 	--元宝鼓舞次数已用完
	Copy_MaxFloor 				= 1715,		--已经达到最大关卡
	Copy_GuildBattleTime		= 1716,		--加入帮派24小时后才能参加帮派争霸
	Copy_NotTeam 				= 1717,		--此副本不能组队
	Copy_ActiveOpened			= 1718,		--活动已经开启了
	Copy_FinishddCanNotBeIn		= 1719,		--您已通关，无法再次进入
	Copy_Lock					= 1720,		--副本尚未解锁
	Copy_InBossMapNoPass		= 1721,		--首领地图中，无法进入
	Copy_EquipCopyClosed 		= 1722,		--等级过高，无法进入
	Copy_HadChallengeCopy 		= 1723,		--您上一个副本还未挑战结束
	Copy_NotPassCanNotSweep		= 1724,		--还未通关无法扫荡
	Copy_TowerHadFinish			= 1725, 	--您所有挑战已经完毕，敬请期间后面层数的开放
	Copy_PassLastDifficulty     = 1726,		--前面难度还未通过

	--活动 1921-2000
	Active_NotStart				= 1921,		--活动还未开始
	Active_ParamsError 			= 1922, 	--参数错误
	Active_DataNotDefine		= 1923,		--活动数据并没有定义缩写
	Active_End 					= 1924,     --活动已过期
	Active_NotEnoughLevel 		= 1925, 	--尚未达到活动开启等级
	Active_HasNotEnough 		= 1926,		--超出可兑换次数
	Active_RecvNotEnough		= 1927,		--领取的条件不足
	Active_IsPause				= 1928,		--活动正在修复中

	--公共错误码 2006-3000
	Common_UHadGetRewards			= 2006,		--您已经领取了该奖励
	Common_ConfigError				= 2007,		--配置错误
	Common_EnterTimesError			= 2008,		--进入次数不足
	Common_PleaseGetResFirst		= 2009,		--请先领取您的奖励
	Common_CopyFinished				= 2010,		--副本已完成
	Common_UCanNotGetRewardsYet 	= 2011,		--暂未达到领取条件
	Common_UHadBuy					= 2012,		--您已经购买过了
	Common_LevelNotEnough			= 2013,		--等级不足
	Common_VipLevelNotEnough		= 2014,		--VIP等级不足
	Common_MaxLv					= 2015,		--已经达到最大等级
	Common_PlayerOffline			= 2016,		--玩家离线
	Common_TargetPlayerOffline		= 2017,		--对方离线
	Common_PasswordErr				= 2018,		--密码错误
	Common_SystemErr				= 2019,		--系统错误,请联系客服
	Common_ActivityNotOpen			= 2020,		--活动未开启
	Common_ActivityNotEnd			= 2021,		--活动未结束
	Common_CanNotGetReward			= 2022,		--条件不足
	Common_ModeChange				= 2023,		--切换战斗模式成功
	Common_ChatBened				= 2024,		--您已被系统禁言
	Common_NotOpen 					= 2025,		--功能未开启
	Common_ActivityEnd 				= 2026,		--活动已结束
	Common_HolySpiritLvNotEnough	= 2027,		--圣灵等级不足
	Common_UseTimesNotEnough 		= 2028,		--使用次数不足
	Common_PlayerDeleted 			= 2029,		--少侠%s已随风而去
	Common_CanNotPassWhileDead 		= 2030,		--死亡状态下无法传送
	Common_FightCapNotEnough		= 2031,		--战力不足
	Common_DropCountNotEnough		= 2032,		--掉落次数不足
	Common_MaxChapter 				= 2033,		--已经达到最高关卡
	Common_SpendResErr				= 2034,		--资源消耗错误
	Common_NotPKRobot				= 2035,     --这是个极其神秘的人，无法进行此操作
	Common_NotBuy					= 2036,		--不能购买
	Common_NotArea					= 2037,		--地区不存在
	Common_ServerOpenDayLimit		= 2038,		--开服第%s天开启
	Common_NormalTowerNotEnough 	= 2039,		--通关第五之塔%s层开启
	Common_ActiveReadyTime			= 2040,		--活动准备阶段
	Common_ActiveRewardTime 		= 2041,		--活动结算阶段
	Common_CanntChallenge 			= 2042,		--不可挑战

	--队伍3311 - 3500
	Team_UHadApplied			= 3311,		--您已经申请过了
	Team_URNotApplied			= 3312,		--您未申请过,无需取消
	Team_URInTeam				= 3313,		--您已经在队伍中
	Team_URNotInTeam			= 3314,		--您不在队伍中
	Team_NotLeaderCanNotDisband = 3315,		--只有队长可以解散队伍
	Team_TeamNotExist 			= 3316,		--队伍已解散
	Team_TargetNotInTeam 		= 3317,		--对方不在队伍中
	Team_OnlyCaptainCanDo		= 3318,		--您不是队长,无法处理
	Team_PlayerNotInApplyList	= 3319,		--玩家不在申请列表中
	Team_TeamFull				= 3320,		--队伍人数已满
	Team_TargetInTeam 			= 3321,		--对方已经在队伍中
	Team_ConfigErr				= 3322,		--队伍目标不存在
	Team_RefuseInvite 			= 3323,		--%s拒绝了您的组队邀请
	Team_TargetNotInTeamCanNotApply = 3324, --该玩家目前没有队伍，无法申请入队
	Team_RefuseApply 			= 3325,		--%s拒绝了您的入队申请
	Team_URAlreadyCaptain 		= 3326,		--无法转让队长给自己 
	Team_ApplyMax 				= 3327,		--申请达到上限
	Team_TargetLevelErr 		= 3328,		--大侠等级不满足组队目标等级要求
	Team_CaptainChanges 		= 3329,		--%s将队长转移给%s
	Team_MemberOfflineCanNotMatch = 3330,	--%s离线,无法开始匹配
	Team_URInMatch 				= 3331,		--您已经在匹配中了
	Team_InMatch 				= 3332,		--您的队伍已经在匹配中了
	Team_InMatchCanNotDo 		= 3333,		--正在匹配中,无法操作
	Team_UrgeCaptain 			= 3334,		--%s已经急不可耐了,催促队长大人你速速开启挑战
	Team_BeKickOut 				= 3335,		--大侠您已经被队长%s请离了队伍
	Team_RefuseEnterCopy 		= 3336,		--%s拒绝了本次进入副本操作
	Team_PlayerLeaveTeam 		= 3337,		--%s主动离开了队伍
	Team_PlayerOfflineCanNotOpen = 3338, 	--玩家%s离线无法进入组队副本
	Team_MemberInCopy 			= 3339,		--%s在副本中,无法开启
	Team_MemberLvNotEnough 		= 3340,		--%s等级不满足组队目标,无法开启
	Team_NewTargetLvErr 		= 3341,		--目标等级不能低于或高于成员等级
	Team_PlayerIsNotTeamMember 	= 3342,		--玩家不在队伍中
	Team_PlayerItemNotEnough 	= 3343,		--%s%s不足
	Team_PlayerInCopyCd			= 3344,		--%s副本冷却中
	Team_PlayerCopyTimesMax		= 3345,		--%s副本次数不足

	-- 称号5301-5350
	Title_NotExist				= 5301,		--称号不存在
	Title_AlreadyActivated		= 5302,		--无须重复激活
	Title_NotActived			= 5303, 	--称号未激活
	Title_NotUsed				= 5304, 	--称号未使用，无法卸下

	--市场 5651-5700
	Market_CanNotSellBindItem 		= 5651,			--绑定物品无法出售
	Market_CanNotBuyYouSelfItem 	= 5652,			--不能购买自己出售的物品
	Market_ErrPasswordMax 			= 5653,			--密码输入的错误次数过多，%ss后才能购买有交易密码的物品
	Market_SellMax					= 5654,			--上架已达上限，最多只能上架10个物品
	Market_ItemExpiredCanNotBuy 	= 5655,			--物品已过期无法购买
	Market_ItemExpiredCanNotSell	= 5656,			--物品已过期无法上架
	Market_ItemCanNotSell 			= 5657,			--该物品无法上架
	Market_SellErr 					= 5658,			--上架失败,请火速联系客服
	Market_BuyErr					= 5659,			--购买失败,请火速联系客服
	Market_SellEmoneyMax			= 5660,			--超过今日售卖上限，请明天再来
	Market_PriceError				= 5661,			--出售价不能低于2元宝

	--每日首充 5861-5880
	DailRecharge_NotReceive         = 5861,        --您还不满足领取要求
	DailRecharge_BagFull            = 5862,        --您的背包已满，奖励已通过邮件发送
	DailRecharge_Received           = 5863,        --您已领取过奖励 
	DailRecharge_NotReward          = 5864,        --没有这种奖励
	DailRecharge_ParamsError        = 5865,        --参数错误
	DailRecharge_AlreadyGet         = 5866,        --您已经领取过该奖励了

	--七天登录 5881-5900
	SevenDayLogin_NotReward         = 5881,        --没有这种奖励
	SevenDayLogin_ReceivedAll       = 5882,        --需要先领取完七天的奖励

	SevenDayTask_NotTask			= 5883,       --没有这个任务
	SevenDayTask_NotRecord			= 5884,		  --没有记录这个任务
	SevenDayTask_NotFinishTask		= 5885,       --您没有完成这个任务
	SevenDayTask_GetFinishReward	= 5886,       --您已经领取了这个任务的奖励
	SevenDayTask_ActiveNotEnough	= 5887,		  --您的活动完成度不够

	OnlineReward_IsReward			= 5890,		  --在线礼包活动已经领取
	OnlineReward_NotEnough			= 5891,		  --在线礼包活动礼包还没有到时间

	--改名 8011 - 8020
	Rename_Guild                   = 8011,       --只有帮主能更改帮派名字
	Rename_NameHasExist            = 8012,       --玩家名字已经存在
	Rename_NameFilterErr 		   = 8013,		 --玩家名字中包含敏感词,请重新输入
	Rename_GuildNameFilterErr 	   = 8014,		 --帮派名字已经存在
	Rename_NameIsNoReg			   = 8015,		 --该名字无法注册,请重新输入
	Rename_NameIsSpecial 		   = 8016,		 --包含特殊字符%s,请重新输入
	Rename_NameDiamond			   = 8017,		 --钻石不足
	Rename_SignatureFilterErr 	   = 8018,		 --签名包含敏感词,请重新输入
	Rename_NameNotChineseLimitNum  = 8019,       --不可包含6个及以上非汉字字符

	--日常活跃度 8021 - 8030
	DailyActivity_NotEnough        = 8021, 		--活跃度不足
	DailyActivity_HasGet           = 8022, 		--已经领取过了
	DailyActivity_MaxLevel 		   = 8023,		--已经达到最大级
	DailyActivity_TomorrowGet 	   = 8024,      --明日可领取俸禄哦
	DailyActivity_NotEnoughStage   = 8025, 		--还没有达到领取阶数

	--安全锁 8171 - 8180
	SecurityLock_PwExist			= 8171,		--你已经设置过密码
	SecurityLock_PwNotExist			= 8172,		--安全锁密码还没设置
	SecurityLock_ShowUnlockPanel	= 8173,		--需要解锁
	SecurityLock_AnswerWrong		= 8174,		--安全问题回答错误
	SecurityLock_LockUnlockPanel	= 8175,		--解锁错误次数过多，剩余锁定时间%s秒

    --成就 8301-8310
    Record_NoReward					= 8301,	--没有奖励
    Record_RewardGot					= 8302,	--奖励已领取
    Achieve_DuplicaReg					= 8303,	--重复注册

    --首充 8351 - 8360
	FirstRecharge_AlreadyPickUp         = 8351, --您已经领取过该首充奖励了
	FirstRecharge_ParamsError           = 8352, --参数错误
	FirstRecharge_AlreadyOpenGift       = 8353, --您已经开启过该礼包了
	FirstRecharge_UnfinishedFirstRe     = 8354, --您还未完成首充，不能领取首充奖励
	FirstRecharge_NotReachPickUpDt      = 8355, --还未到达领取该首充奖励的时间
	FirstRecharge_NotExit               = 8356, --该物品不存在
	FirstRecharge_NotActive				= 8357,	--未完成首充,无法开启功能

	--实名认证 8391 - 8400 
	Author_UnderAge  					= 8391, --您还未成年

	--每日累消 8881-8890
	DailConsume_NotReceive         = 8881,        --您还不满足领取要求
	DailConsume_BagFull            = 8882,        --您的背包已满，奖励已通过邮件发送
	DailConsume_Received           = 8883,        --您已领取过奖励 
	DailConsume_NotReward          = 8884,        --没有这种奖励
	DailConsume_ParamsError        = 8885,        --参数错误
	DailConsume_AlreadyGet         = 8886,        --您已经领取过该奖励了

	--充值有礼 9001 - 9010
	BeautyRecharge_NotEnough = 9001,				--条件不足
	BeautyRecharge_HasGet = 9002,				    --已领取该奖励

	--累计消费 9071 - 9080
	CumulativeConsume_NotEnough = 9071,				--条件不足
	CumulativeConsume_HasGet = 9072,				--已领取该奖励


	--跨服拍卖 9321 - 9330
	CrossAuction_AuctionNotStart = 9321,	--竞拍未开始
	CrossAuction_AuctionFinish = 9322,		--竞拍已结束
	CrossAuction_LessThanAddPrice = 9323,   --小于最低加价
	CrossAuction_ReAuction = 9324,			--此拍卖品您已竞拍，不可重复竞拍哦

  	--兑换商店 9501 - 9510
   	ExchangeStore_ExchangeLimit			= 9501,		--兑换已到上限


	-- 拍卖行 9941 - 9970
	AuctionHouse_CanNotSell 				= 9941, 	--该物品无法上架
	AuctionHouse_SellErr 					= 9942,		--道具上架失败
	AuctionHouse_ItemNotExist				= 9943, 	--道具不存在
	AuctionHouse_BuyOutOnly					= 9944,		--道具只支持一口价出售
	AuctionHouse_BiddingOnly				= 9945, 	--道具只支持竞价出售
	AuctionHouse_LessThanAddPrice			= 9946,		--小于最低加价
	AuctionHouse_Prepare					= 9947,		--道具即将开拍，请等候准备时间结束
	AuctionHouse_BiddingErr					= 9948,		--竞价失败，请火速联系客服
	AuctionHouse_CanNotBuySelfItem			= 9949,		--不能购买自己的道具
	AuctionHouse_UpdateErr					= 9950,		--上架道具数据更新失败,请火速联系客服
	AuctionHouse_CanNotBiddingSameItem		= 9951,		--不能竞价自己已经竞价中的道具
	AuctionHouse_BuyOutErr					= 9952,		--一口价竞拍失败，请火速联系客服
	AuctionHouse_Bidding					= 9953,		--上次竞价还未结束，请稍候
	AuctionHouse_MaxAmount 					= 9954,		--您上架的道具已经超过20个，无法再次上架
	AuctionHouse_AlreadySell				= 9955,		--该道具已经上架过了
	AuctionHouse_DelErr						= 9956,		--道具删除失败
	AuctionHouse_GetBackItemErr				= 9957,		--下架道具失败，道具的可能已经回收了
	AuctionHouse_CanNotGetBackItem			= 9958,		--不能下架不是自己的道具
	AuctionHouse_GetBackBiddingItem			= 9959,		--该道具已被玩家竞拍，不能下架
	AuctionHouse_CanNotCancelCollect		= 9960,		--你不能取消未收藏过的道具
	AuctionHouse_CanNotCollectSelfItem		= 9961,		--不可以收藏自己的道具哦
	AuctionHouse_AlreadyCollect			 	= 9962, 	--您已经收藏过当前道具
	AuctionHouse_MaxCollectCount			= 9963, 	--收藏数量不得超过20个哦
	AuctionHouse_TimeOut					= 9964, 	--道具已超时
	AuctionHouse_GuildActivitySellItemErr 	= 9965,		--帮派活动道具上架失败.请火速联系客户
	AuctionHouse_MoneyNotEnough				= 9966,		--当前绑元不足，是否花费绑元%d、元宝%d拍卖道具
	AuctionHouse_BuyOutItemMulti			= 9967,		--竞价成功，已成功拍走拍卖道具
	AuctionHouse_GuildActivitySellErr 		= 9968,		--系统活动道具上架失败
	AuctionHouse_ScreenLimit 				= 9969,		--您操作太快了，休息下再排序吧

	--绑元兑换 10351 - 10360
	BindEmoneyExchange_ExchangeLimit 		= 10351,	--今日绑元兑换已超过上限	


	--英雄功能 10361 - 10500
	Hero_HeroLevelMax						= 10361,    --已达最大等级
	Hero_RoleLevelLimit						= 10362,    --角色等级限制
	Hero_StageLevelLimit					= 10363, 	--已达当前可升级最大等级
	Hero_StageLevelUpLevelLimit				= 10364,	--未达到进阶所需等级
	Hero_StageLevelMax						= 10365,	--已达最高品阶
	Hero_StarLevelMax                       = 10366,    --已达最高星级
	Hero_HeroNumMaxLimit					= 10367,	--英雄数量已达最大值
	Hero_StageLevelUpStarLimit				= 10368,	--未达到进阶所需星级
	Hero_StarLevelUpNotPermitted			= 10369,	--当前英雄无法升星
	Hero_NotChooseStarLevelUpCostHero		= 10370,	--请先选择升星材料
	Hero_HeroNotExist						= 10371,	--该探员已经不存在
	Hero_ExistHeroCanNotBeCost				= 10372,	--升星材料不能处于上阵状态
	Hero_StarLevelUpCostNotEnough			= 10373,	--升星材料不足
	Hero_AttrPointRemainNumZero				= 10374,	--没有可分配的属性点
	Hero_AttrPointRemainNumNotEnough		= 10375,	--超过当前可分配的属性点
	Hero_AttrPointPlanEmpty					= 10376,	--请选择需要分配的属性点
	Hero_AttrPointPlanNotSet				= 10377,	--当前没有分配属性点，无需重置
	Hero_DecomposeHeroListEmpty				= 10378,	--请选择需要分解的英雄
	Hero_RemoveErrInBattleArray				= 10379,	--出战英雄无法被消耗或分解
	Hero_PassiveSkillHasActived				= 10380,	--需要遗忘后才学习新技能
	Hero_PassiveSkillNotExist				= 10381,	--技能不存在
	Hero_GetPassiveSkillByActive			= 10382,	--请通过激活获得该技能
	Hero_PassiveSkillCanNotLearn			= 10383,	--当前无法学习该技能
	Hero_ActiveSkillCostNotEnough			= 10384,	--材料不足
	Hero_ActiveSkillNotActived				= 10385,	--技能未激活
	Hero_CanOnlyActiveSkillByMoney			= 10386,	--只能通过购买激活该技能
	Hero_CanNotActiveSkillByMoney			= 10387,	--无法通过购买激活该技能
	Hero_CanNotActiveSkillByLearn			= 10388,	--无法通过学习获得该技能
	Hero_SkillHasLearned					= 10389,	--已学习该技能
	Hero_DecomposeStarLimit					= 10390,	--只能分解5星及以下星级的英雄
	Hero_CanNotDecompose					= 10391,	--无法分解该英雄
	Hero_CanNotReset						= 10392,	--无法重置该英雄
	Hero_LearnSkillErrPassiveSkillEmpty		= 10393,	--没有可替换技能，无法学习获得新技能
	Hero_Locked								= 10394,	--英雄已锁定，无法被分解或消耗
	Hero_HeroEquipNotActivate 				= 10395, 	--英雄装备没激活
	Hero_AttrPointPlanIdIsWrong				= 10396,  	--错误的属性点分配方案
	Hero_PassiveSkillLevelNotEnough         = 10397,    --探员达到%s级后，才可激活或学习特效
	Hero_AllPassiveSkillNotActive           = 10398,    --需要技能全部激活后，才可以学习技能进行替换。
	Hero_CannotResetStar 					= 10399,	--该探员无法重置星级
	Hero_HeroInPalace 						= 10400,	--探员处于共生殿中，无法进行此操作
	Hero_TransformExistErr					= 10401,	--存在特异转换的探员，无法进行此操作
	Hero_NotHeroTransform					= 10402,	--该探员暂时不支持转换
	Hero_NotHeroStarSkill					= 10403,	--探员星级达到%s星开启
	Hero_NotItemColor						= 10404,	--材料品级不够
	Hero_RemoveErrInHeroPalace				= 10405,	--共生殿中的探员无法被消耗或分解
	Hero_HeroStarLevelUpToNineteen			= 10406,	--需要共生殿等级达到%s级
	Hero_PlayerLevelNotEnough 				= 10407,	--需要玩家等级达到%s级
	Hero_HasStarSegmentLevelUp				= 10408,    --该探员已激活星段，无法进行回退操作
	Hero_HasStarSegmentActive				= 10409,    --该星段已激活
	Hero_NotEnoughHeroStarNum				= 10410,	--升星条件不满足

	--英雄召唤 10501 - 10600
	HeroLottery_FreeDrawNotEnough			= 10501,	--召唤次数不足
	HeroLottery_LuckyValueNotEnough			= 10502,	--幸运值不足
	HeroLottery_RareDrawDailyLimit			= 10503,	--已经达到本次召唤上限
	HeroLottery_NewPlayerDrawEnd			= 10504,	--召唤已结束
	HeroLottery_MaxTimesLimit				= 10505,	--已达最大召唤次数
	HeroLottery_NotAssignHero				= 10506,	--请设置指定英雄

	--战斗相关 10601 - 10700
	Battle_ErrorHeroData					= 10601,	--英雄不存在
	Battle_HeroHadInBattleArray				= 10602,	--英雄已上阵
	Battle_CanNotUpSameHeroInArray			= 10603,	--备战区英雄不能相同
	Battle_MaxBattleArrayNum				= 10604,	--备战区的英雄已满
	Battle_HeroNotInBattleArray				= 10605,	--不在备战区中
	Battle_ErrorBattleArrayPos				= 10606,	--错误的备战位置
	Battle_ErrorFightConfig					= 10607,	--错误的战斗配置
	Battle_ErrorBattleArray 				= 10608,	--暂无出战探员，请先上阵
	Battle_ErrorHeroCategory				= 10609,	--该英雄种族不匹配
	Battle_ErrorHeroArray					= 10670,	--布阵有重复
	Battle_BattleRecordTimeOut				= 10671,	--战斗记录已经过期
	Battle_NotHeroInFightPos 				= 10672,	--请上阵角色
	Battle_NotRecordId						= 10673,	--战报不存在
	Battle_NotEnemyId						= 10674,	--没有敌方id
	Battle_BadArrayType						= 10675,	--错误阵型输入
	Battle_NotOpenReplace					= 10676,	--替补功能未开启
	Battle_NotArray 						= 10677,	--阵容不存在

	--推图关卡 10701 － 10730 				
	Chapters_NotBattlePoint					= 10701,	--挑战的章节关卡不存在
	Chapters_NotBattleCityRecord			= 10702,	--没有挑战这个城市记录
	Chapters_NotBattlePointRecord			= 10703,	--没有挑战这个章节记录
	Chapters_NotBattleLevelRecord			= 10704,	--没有挑战这个关卡记录
	Chapters_NotBattlePointStar				= 10705,	--此章这没有达到足够星数
	Chapters_NotAchieveLevel				= 10706,	--探长%s级可侦察
	Chapters_ReceiveStarReward 				= 70706,	--此章这已经领取过了
	Chapters_NotHangUpTime					= 70707,	--挂机时间不足
	Chapters_NotTarget						= 70708,	--通关条件不足
	Chapters_OverUseTimes					= 70709,	--快速战斗次数不足
	Chapters_AllCity 						= 70710,	--该城市的章节已经全新通关
	Chapters_AllCityPoint 					= 70711,	--该章节关卡已经全新通关

	--任务系统  10731 - 10800
	Task_TaskNotAchieved					= 10731,	--任务未完成
	Task_RewardHasReceived					= 10732,	--奖励已领取
	Task_NoRewardCanReceived				= 10733,	--没有可领取的奖励

	--竞技场10801 -10850
	Arena_NotArenaPlayer					= 10801,	--竞技场对象不存在		
	Arena_CanNotChallengeSelf				= 10802,	--不能挑战自己
	Arena_NotChallengePlayer				= 10803,	--挑战对象不存在
	Arena_ScoreNotEnough                    = 10804,    --积分不足，无法领取该奖励

	--活跃度功能 10851-10900
	ActiveScore_RewardReceived				= 10851,	--奖励已领取
	ActiveScore_RewardNotAchieved			= 10852,	--未达到领取条件

	--好友等关系 10901-11000
	Friend_NotFound			= 10901,		--没有找到对应玩家
	Friend_FriendsCount1	= 10902,		--对方好友已满，无法添加
	Friend_NotName			= 10903,		--不能查找自己	
	Friend_NotOnline		= 10904,		--对方不在线
	Friend_Isplayer			= 10905,		--已经是好友
	Friend_Black			= 10906,	    --在黑名单中
	Friend_Apply			= 10907,		--不在申请列表
	Friend_Max				= 10908,		--超过好友最大数量
	Friend_Arena_NotAttry   = 10909,   		--您的竞技场阵容不存在
	Friend_Arena_NotToAttry = 10910, 		--对方竞技场阵容不存在
	Friend_NotPKSelf 		= 10911,		--不能切磋自己
	Friend_NotMoneyAccept 	= 10912,		--没有好友赠送不能领取

	--装备 11001 - 11010
	Equipment_MaxOrder		= 11001,		--装备已达最高
	Equipment_DressWrong    = 11002,		--无法穿上此装备

	--公会 11051-11300
	Guild_AlreadyInGuild		= 11051,	--当前已有公会
	Guild_PlayerInGuild			= 11052,	--玩家已加入其他公会
	Guild_NameErr				= 11053,	--名字中包含敏感词
	Guild_NoticeErr				= 11054,	--公告中包含敏感词
	Guild_AnnouncementErr 		= 11055,	--宣言中包含敏感词
	Guild_GuildExist			= 11056,	--公会已存在
	Guild_NameExist 			= 11057,	--公会名已存在
	Guild_GuildNotExist			= 11058,	--公会不存在
	Guild_NotInSameGuild		= 11059,	--不在同一个帮派	
	Guild_PrivilegeLimit		= 11060,	--权限不足
	Guild_MaxNum				= 11061,	--人数已满
	Guild_NotInGuild			= 11062,	--需要加入公会
	Guild_CannotKickMember		= 11063,	--活动期间不能踢人
	Guild_CannotChangeName		= 11064,	--活动期间不能改名
	Guild_DailyRewardHasGot		= 11065,	--你已经领取过今天的奖励
	Guild_NoGuildCanBeApplied	= 11066,	--当前没有公会可以申请
	Guild_PlayerNotOnLine		= 11067,	--对方不在线
	Guild_OperateFreqErr		= 11068,	--操作频繁，请稍后再试
	Guild_AlreadyInApplyList	= 11069,	--已经申请过该公会了
	Guild_ApplyNumLimit			= 11070,	--当前公会已达可申请人数上限
	Guild_MemberNotFind			= 11071,	--找不到公会成员
	Guild_JoinLevelLimit		= 11072,	--未达到可加入等级
	Guild_ApproveTypeRefuse		= 11073,	--当前公会拒绝所有申请
	Guild_GuildNameIsNone		= 11074,	--公会名不能为空
	Guild_QueryGuildNameNone	= 11075,	--请输入想要查找的公会名或编号
	Guild_QueryGuildIdNone		= 11076,	--请输入想要查找的公会编号
	Guild_GuildNameLengthLimit	= 11077,	--公会名不能超过%s个字
	Guild_NoticeLengthLimit 	= 11078,	--公会公告最大%s个字
	Guild_AnnounceLengthLimit 	= 11079,	--公会宣言最大%s个字
	Guild_RenameErrNewName		= 11080,	--请输入新的公会名
	Guild_JoinIntervalErr		= 11081,	--您刚退出公会，需要%s分钟后可加入新公会
	Guild_JoinIntervalLimit		= 11082,	--对方刚离开公会，暂时无法入会
	Guild_NotInApplyList		= 11083,	--找不到该申请
	Guild_GuildBossHadOpen		= 11084,	--公会首领已经开启
	Guild_GuildBossNotOpen		= 11085,	--公会首领未开启
	Guild_GuildBossOpenNotEnough = 11086,	--公会活跃度不足，无法开启
	Guild_ChangePositionPriviErr = 11087,	--无法提升至与您同级或以上
	Guild_PositionMemberMax		= 11088,	--%s职位已满
	Guild_ApplyOperateMemberMax	= 11089,	--公会人数已满，无法通过申请
	Guild_ApplyOperateJoinOther	= 11090,	--玩家已进入其他公会，无法通过申请
	Guild_ApplyListIsEmpty		= 11091,	--当前没有玩家申请
	Guild_SkillLevelMax			= 11092,	--当前公会技能已达最高等级
	Guild_SkillLevelZero		= 11093,	--当前技能未升级
	Guild_DivinHelpSelfErr 		= 11094,	--无法帮自己提升手气
	Guild_DivinHelpCountLimit	= 11095,	--获助次数已满，无法继续帮TA提升手气
	Guild_DivinHelpLuckyMax		= 11096,	--手气已满，无法继续帮TA提升手气
	Guild_DivinCountLimit		= 11097,	--次数不足，无法占卜
	Guild_DivinLuckyNotEnough	= 11098,	--手气不足，无法占卜
	Guild_DivinRetryCountLimit	= 11099,	--次数不足，无法改运
	Guild_DivinRetryLuckyNotEnough = 11100,	--手气不足，无法改运
	Guild_DivinRetryRewardMax	= 11101,	--奖励数量已满
	Guild_DivinRewardNotReceive = 11102,	--请先领取上一次占卜奖励
	Guild_DivinHelpRepeated		= 11103,	--今天已帮对方提升过手气
	Guild_DivinHelpReqExpired	= 11104,	--请求已过期
	Guild_ChangePositionSelfErr	= 11105,	--不能调整自己的职位
	Guild_GuildBossJoinStampLimit = 11106,	--刚加入新公会，还剩%s小时才能挑战首领
	Guild_WorldBossChallengeNotEnough = 11107,	--挑战次数不足
	Guild_WorldBossChallengeRemain = 11108,	--当前还有剩余可挑战次数
	Guild_PurchaseWorldBossChallengeFailed = 11109,	--购买失败
	Guild_WorldBossInfoExpired	= 11110,	--活动已更新，请刷新后重新尝试
	Guild_WorldBossBattleHeroNotInPalace = 11111,	--只有共生殿中的英雄才被允许出战
	Guild_QuickChallengeBossError = 11112,		--请先进行一场战斗后才能扫荡
	Guild_SkillLevelUpMinLimit		= 11113,	--其他技能%s级后才能继续升级
	Guild_DoEndStatusLimit		= 11114,	--活动正在结算，请稍后再试

	Guild_PackNotType 			 = 11200,		--公会背包没有这个类型
	Guild_PackMaxItem 			 = 11201,		--当前公会宝库已满，无法继续放入物品了
	Guild_PackItemGong			 = 11202,		--物品已消失了
	Guild_PackNotEnough 		 = 11203,		--物品不足
	Guild_PackDayMaxAdd			 = 11204,		--今日已经达到兑换上限
	Guild_PackNotItem 			 = 11205,		--这个物品不能放入公会宝库
	Guild_PackMaxPutInItem 		 = 11206,		--超过放入物品的上限
	Guild_PackMaxTakeOutItem 	 = 11207,		--超过取出物品的上限
	
	--迷宫11301-11350
	Maze_NotMove				= 11301,	--不能移动到此格子
	Maze_NotGrid				= 11302,	--格子不存在
	Maze_NotSuccessful 			= 11303,	--还没有通关
	Maze_NotMonster				= 11304,	--不能挑战此关怪物
	Maze_NotHeroHpZero			= 11305,	--有英雄没有血量了 

	--秘境11351-11400
	FairyLand_HandlerNotRegister = 11351,	--秘境类型句柄没有注册
	FairyLand_HadMoveNumToMove = 11352,		--秘境步数没有走完
	FairyLand_HadFininshAll = 11353,		--已经完成所有秘境，敬请等候下一层的开放
	FairyLand_HadFinishFloor = 11354,		--已经完成秘境当前层，请进入下一层进行探索
	FairyLand_UnderAnswering = 11355,       --请先完成答题
	FairyLand_CanNotMove = 11356,			--没有步数，无法前进
	FairyLand_CanNotAction = 11357,			--此类型格子无法操作
	FairyLand_QuestionTimeout = 11358,		--秘境答题已经超时
	FairyLand_UnderFighting = 11359,		--遇到守卫，请先挑战守卫	
	FairyLand_GuarderHadFighted = 11360,	--已经挑战过守卫，请继续往前走
	FairyLand_FloorTimesNotEnough = 11361,  --本层探宝次数不足，无法进入下一层
	FairyLand_FloorTimesNotGetFloorReward = 11362, --本层探宝次数不足，无法领取奖励 

	-- 福利活动 11401-11550 		
	Welfare_DailyLoginCount		= 11401,		--未达到领取条件
	Welfare_DailyLoginRevFinish	= 11402,		--已经领取奖励
	Welfare_DailyLoginRevRechange = 11403,		--不能领取登陆充值奖励

	-- 极地 11550-11600
	EndlessRoad_NotEvent	= 11550,		--无效事件,请关闭界面再试
	EndlessRoad_EventError	= 11551,		--网络异常,请关闭界面再试
	EndlessRoad_EventErrorCfg = 11552,		--参数配置错误
	EndlessRoad_EventNotEough = 11553,		--您的补给不足
	EndlessRoad_NotOpenTime  = 11554,		--极地开服时间不够
	EndlessRoad_NotHero  	= 11555,		--没有需要恢复的英雄
	EndlessRoad_Hero 		= 11556,		--需要英雄的职业错误
	EndlessRoad_HeroCount   = 11557,		--超出英雄限制
	EndlessRoad_NotArrayHero = 11558,       --无可上阵的探员

	--个人商店 11600 - 11650
	Mall_NotType			= 11600,		--找不到商店类型 

	--英雄谷 11601-11650
	HeroPalace_GroupBIndexNotOpen = 11601,		--该栏位未解锁
	HeroPalace_IndexHasHero = 11602,		    --栏位上放入英雄
	HeroPalace_HeroNotExist = 11603,	        --英雄不存在
	HeroPalace_IndexUnderCoolTime = 11604, 	    --栏位处理冷却中，无法放入
	HeroPalace_IndexHadNotHero = 11605,		    --栏位没有英雄
	HeroPalace_AllIndexHadOpen = 11606,		    --所有栏位已经解锁
	HeroPalace_IndexCoolTimeOut = 11607,	    --栏位冷却时间失效了
	HeroPalace_CrystalNotActivate = 11608,	    --水晶等级没有激活
	HeroPalace_CrystalMaxLevel = 11609,		    --水晶等级已经达到最高级
	HeroPalace_CrystalNeedCondition = 11610,	--升级水晶等级条件不满足
	HeroPalace_HeroHadInIndex = 11611,			--英雄已经在栏位中，无法重复放入
	HeroPalace_IndexCanNotUpStage = 11612,	    --共生殿英雄无法升阶
	HeroPalace_IndexCanNotUpLevel = 11613,		--共生殿英雄无法升级
	HeroPalace_UpdateOtherHero = 11614,		    --请先升级其他英雄
	HeroPalace_IndexCanNotDecompose = 11615,	--共生殿英雄无法分解
	HeroPalace_IndexCanNotRest = 11616,		    --共生殿英雄无法重置

	-- 11651-11700
	DelegateTask_HasHero	= 11651,			--委托任务英雄已经派遣
	DelegateTask_NotTask 	= 11652, 			--委托任务没有这个任务
	DelegateTask_NotFree	= 11653,			--委托任务免费次数不够
	DelegateTask_NotFinish 	= 11654,			--委托任务没有完成
	DelegateTask_HasFinish 	= 11655,			--委托任务已经领取过
	DelegateTask_NotRev		= 11656,			--请先领取委托任务
	DelegateTask_NotStar	= 11657,			--委托任务没有达到星级要求
	DelegateTask_NotCategory= 11658,			--委托任务没有达到种族要求
	DelegateTask_HasRev		= 11659,			--委托任务已经领取了
	
	--公共玩法基础服务相关 11701 - 11799
	PubGame_PubGameSrvNotFind = 11701,			--玩法服务未开启
	PubGame_PubGameMgrSrvNotFind = 11702,		--指定服玩法管理服务不存在

	--符文11800 - 11850
	Rune_SetPageName 			= 11801,		--符文页改名字不合法
	Rune_SetSkill 				= 11802,		--符文页技能学习等级不足
	Rune_NotUnlockPage			= 11803,		--没有解锁该符文页
	Rune_NotlockHero  			= 11804,		--已上阵英雄
	Rune_NotUnlockHeroPos 		= 11805,		--没有解锁格子
	Rune_NotDecom				= 11806,		--该符文不能分解
	--图鉴11851 - 1190
	HeroTotems_NotReceiveWeekTitle 		= 11851,	 --已经领取过了头衔奖励
	HeroTotems_NotReceiveWeekTitleId	= 11852,	 --没有资格领取周奖励
	HeroTotems_NotUpdateTitle 			= 11853,	 --头衔升级条件不够
	HeroTotems_FilterErr				= 11854, 	 --评论信息包括敏感字符
	HeroTotems_TooLong					= 11855, 	 --评论信息字数太多了
	HeroTotems_NotHero 					= 11856,	 --英雄没有收集
	HeroTotems_GiftHeroRecommendset		= 11857,	 --已经领取英雄领取组合奖励
	
	--职级 12000 - 12050		
	Duty_HaveRecvDailyReward		 	= 12000,	--职级每日奖励已经领取
	Duty_NotUp							= 12001,	--职级已经最大
	Duty_TaskNotFinish					= 12002,	--职级任务没有完成
	Duty_TaskNotConfig					= 12003,	--职级没有这个任务
	Duty_TaskMax						= 12004,	--职级已到上限

	--世界擂台赛 12051 - 12100
	WorldArena_ActivityEnded			= 12051,	--活动已结束
	WorldArena_ActivityClosed			= 12052,	--活动未开启
	WorldArena_GuessErrBattleStart		= 12053,	--比赛已经开始，无法竞猜
	WorldArena_GuessErrCanNotGuess		= 12054,	--当前无法参与竞猜
	WorldArena_GuessErrNoGuessBattle	= 12055,	--本轮比赛全部轮空，没有可竞猜的比赛
	WorldArena_GuessErrHasGuessed		= 12056,	--已参与过本轮比赛竞猜
	WorldArena_SetBattleArrayError		= 12057,	--只能在准备阶段调整阵容
	WorldArena_CanNotSetBattleArray		= 12058,	--当前无法设置阵容信息

	--限时推送礼包 12101 - 12120
	SurpriseGift_Expired				= 12101,	--限时礼包已过期
	SurpriseGift_PurchaseFailed			= 12102,	--购买失败

	--神器 12120 - 12220
	GodArms_MaxLevel 					= 12121,	--已经达上限
	GodArms_NotLevel					= 12122,	--等级不足
	GodArms_NotId						= 12123,	--神器没有激活
	GodArms_NotPoint					= 12124,	--没有足够的技能点
	GodArms_NotTask						= 12125,	--没有这个任务
	GodArms_NotRecord					= 12126,	--没有注册这个任务
	GodArms_NotConfig					= 12127,	--不存在这个秘武
	GodArms_HaveTrigger					= 12128,	--已经激活这个秘武
	GodArms_NotItemTrigger				= 12129,	--激活方式错误

	--调查问卷 12221 - 12230
	QuestionnaireSurvey_RewardCantReceive  	= 12221,	--尚未可以领取
	QuestionnaireSurvey_RewardCantRepeat	= 12222,	--不可重复领取
	QuestionnaireSurvey_CantAnswer			= 12223,	--不可回答该题目
	QuestionnaireSurvey_CantRepeatAnswer	= 12224,	--不可重复回答题目
	QuestionnaireSurvey_SelectNumError		= 12225,	--选项个数不合法

	--无尽试炼 12231 - 12350
	TopChallenge_JoinedOtherType			= 12231,	--今天已参与了其他类型试炼
	TopChallenge_MaxLevel					= 12232,	--已通关当前试炼
	TopChallenge_NotDailyType				= 12233,	--当前无法挑战该试炼类型
	TopChallenge_RewardReceived				= 12234,	--奖励已领取
	TopChallenge_FriendHelperRepeated		= 12235,	--不能重复设置好友协助英雄
	TopChallenge_HelperHeroCombatLimit		= 12236,	--好友协助英雄不能超过自身同种族最高战力%s%
	TopChallenge_FriendHeroCanNotSetAsHelper	= 12237,	--该英雄当前不可参与协助，请更新好友协助列表
	TopChallenge_BattleArrayHeroCategoryNotMatch	= 12238,	--只能上阵对应试炼类型的英雄
	TopChallenge_SetHelperHeroDailyLimit	= 12239,	--每天只能设置一次好友协助英雄

	--成长基金 12360 - 12370
	Fund_NotExist 						 	= 12360, 	--基金不存在
	Fund_NotBuy	 						 	= 12361, 	--请购买基金
	Fund_NotReward 						 	= 12362, 	--基金奖励不存在
	Fund_NotCondition 						= 12363, 	--未达到领奖条件

	--月卡 12371 -  12380
	MoonCard_NotExist  						= 12371, 	--月卡不存在
	MoonCard_NotActivation 				 	= 12372, 	--月卡未激活
	MoonCard_NotReward 				 		= 12373, 	--奖励已领

	--特权 12381 - 12390 	
	Privilege_NotGitf 						= 12381, 	--礼包不存在
	Privilege_NoBuyTimes					= 12382, 	--礼包购买次数上限

	--超级基金 12391 - 12400 			 
	SuperFund_NotFund 	 					= 12391, 	--基金不存在
	SuperFund_NotBuyFund 	 				= 12392, 	--请购买基金
	SuperFund_TimeOver 		 				= 12393, 	--基金已过期
	SuperFund_NotReward 		 			= 12394, 	--奖励有误
	SuperFund_RewardOver 		 			= 12395, 	--奖励已领
	SuperFund_Close		 		 			= 12396, 	--活动购买入口已关闭
	SuperFund_NotCondition		 		 	= 12397, 	--未达到领奖条件


	--高阶竞技场12401 - 12409
	HigherPvp_NotPlayer						= 12401,	--高阶竞技场没有这个玩家
	HigherPvp_NotArmy						= 12402,	--敌方玩家获取不到
	HigherPvp_IsSelf						= 12403,	--为何打击自己
	HigherPvp_NotRecv						= 12404,	--不能领取这个奖励
	HigherPvp_NotRecord						= 12405,	--没有战斗记录
	HigherPvp_RestTime						= 12406,	--休赛时间	

	--战令12410 - 12420
	WarOrder_AlreadyBuy                     = 12410,    --已购买过高阶执照
	WarOrder_LastTwoHourNotBuy              = 12411,    --最后两小时不可购买
	WarOrder_NotRewardCanGet                = 12412,    --无奖励可领取.

	--活动错误码 12421 -13420 
	Activity_FastUpLevel_GetLimit 			= 12421,	--限时升级，到达领取上限
	Activity_SevenDayRecord_TimeLimit		= 12422,	--未到礼包购买时间
	Activity_SevenDayRecord_CountLimit		= 12423,	--礼包购买次数上限
	Activity_SevenDayRecord_PointLimit		= 12424,	--积分不足无法领取
	Activity_SevenDayRecord_VipLevelLimit 	= 12425,	--VIP等级达到%s可购买
	Activity_RewardNotAchieved				= 12426,	--未达到领取条件
	Activity_RewardTimesLimit				= 12427,	--已达可领取次数上限
	Activity_PurchaseTimesLimit				= 12428,	--已达可购买次数上限
	Activity_NextTime						= 12429,	--挑战时间结束

	--周卡 13421 - 13430
	WeekCard_NotExist 					 	= 13421,    --周卡不存在
	WeekCard_NotBuy 					 	= 13422,    --请购买周卡
	WeekCard_AlreadyBuy 					= 13423,    --已购买过周卡

	-- 指引 13431 - 13440
	Guide_SoLong							= 13431,	--保存的指引字符串太长
	Guide_SoBig								= 13432,	--保存的指引数量超过最大数
	--1v1 晨星 13441 - 13500
	PveStarTemple_storeyLimit 				= 13441, 	--已达今日爬塔层数上限
	PveStarTemple_SrrayLimit				= 13442,	--上阵人数超过上限

	--新服专享礼包13501 - 13520
	NewServerGift_ReachMaxBuyTime           = 13501,    --已达最大购买次数
	NewServerGift_NotBuyGift                = 13502,    --请先购买礼包
	NewServerGift_NotRewardGet              = 13503,    --无奖励可领取


	--幻境13521 - 13540
	DreamLand_NotNode						= 13521,	--关卡传输错误
	DreamLand_RepeatHire					= 13522,	--不能多次雇佣同一个英雄
	DreamLand_NotHireSelf					= 13523,	--不能雇佣自己的英雄
	DreamLand_NotType						= 13524,	--今天不开放这个模式
	DreamLand_NotSkill						= 13525, 	--技能已经过期
	DreamLand_MaxPassCount					= 13526,	--每天可最多通关%s关，请隔天再来挑战
	--精灵13541-13600
	Elf_NotPaln 							= 13541,	--精灵方案不存在
	Elf_ItemConfigNotExist					= 13542,	--精灵配置不存在
	Elf_NotSummon							= 13543,	--精灵召唤类型不存在
	Elf_CanRewardTimes						= 13544,	--精灵召唤奖励次数不足
	Elf_ReceiveSummonReward					= 13545,	--精灵召唤奖励已经领取过
	Elf_SkinAchieve 						= 13546,	--精灵皮肤已经激活
	Elf_NotSkinAchieve						= 13547,	--精灵皮肤没有激活
	Elf_NotId								= 13548,	--精灵不存在
	--集图夺宝 13601-13620
	CollectMap_NotNextMap 					= 13601, 	--进入新宝图，条件不足
	CollectMap_NotExist 					= 13602, 	--配置有误
	CollectMap_NotReward 					= 13603, 	--未达领取条件
	CollectMap_OverReward 					= 13604, 	--奖励已领取

	--圣器13621-13670
	Hallow_NotCopy							= 13621,	--今天不开这个副本
	Hallow_NotTimes							= 13622,	--副本挑战点不足
	Hallow_DayMax							= 13623,	--已经超过最大挑战次数
	Hallow_NeedFight						= 13624,	--请先挑战完成才可以扫荡
	Hallow_NeedMopUp						= 13625,	--可以扫荡
	Hallow_IDConfig							= 13626,	--此id不可战斗
	Hallow_MustFinish						= 13627,	--请先完成上一个关卡
	Hallow_NotBossType						= 13628,	--今天不打这个boss类型
	Hallow_MaxBaseLevel 					= 13629,	--已经达到最大级
	Hallow_NotPoint							= 13630,	--升级点不足
	Hallow_NotBase							= 13631,	--请先激活基座
	Hallow_NotBaseLevel						= 13632,	--请先升级基座
	Hallow_NotMaxBuyTimes					= 13633,	--已经达到最大购买次数
	Hallow_NotCategory						= 13634,	--%s
	Hallow_NotArray							= 13635,	--请先设置阵容
	Hallow_NotLevel							= 13636,	--继续升级需要其他圣器最低等级达到%s级

	--魔灵山 13671 - 13750 
	EvilMountain_BossNotFound				= 13671,	--首领已被击退
	EvilMountain_CanNotChallenge			= 13672,	--当前无法挑战
	EvilMountain_BossHasDied				= 13673,	--已被击退，无法挑战
	EvilMountain_ChallengeNumLimit			= 13674,	--当前首领已达挑战人数上限
	EvilMountain_ChallengeInterval			= 13675,	--%s秒后可再次挑战当前首领
	EvilMountain_EnergyNotEnough			= 13676,	--精力不足，无法挑战
	EvilMountain_RelationshipLimit			= 13677,	--只能挑战自己公会成员或好友召唤的首领
	EvilMountain_BossInfoExpired			= 13678,	--首领信息已过期，请刷新
	EvilMountain_SendRewardMail				= 13679,	--奖励已通过邮件发放
	EvilMountain_CanNotGetReward			= 13680,	--没有可领取的奖励
	EvilMountain_OpenRewardErr				= 13681,	--奖励已领取
	EvilMountain_SummonLevelLimit			= 13682,	--需要先击败上一个难度等级的首领

	--临界 13751 - 13800
	Boundary_BlessingBuffPos				= 13751,	--选择BUFF位置有错
	Boundary_BlessingOpenDay 				= 13752,	--此层暂未开放

	--纹章 13801 - 13820 					
	Heraldry_NotItem 						= 13801, 	--物品不存在
	Heraldry_HeroNotExist					= 13802,	--英雄不存在
	Heraldry_ConfigError					= 13803,	--配置错误
	Heraldry_NotUpgradeStar					= 13804,	--升星条件不足
	Heraldry_AlreadyUpgradeStar				= 13805,	--已达升星条件
	Heraldry_NotResetRace					= 13806,	--重铸条件不足
	Heraldry_NotConditions					= 13807,	--条件不足
	Heraldry_NotUse 						= 13808,	--使用道具不符合
	Heraldry_NotHeraldry 					= 13809,	--无纹章卸下
	Heraldry_UpgradeStarLimit 				= 13810,	--已达升星上限
	Heraldry_DressHeroBody					= 13911,	--该纹章还在英雄身上

	-- 扭蛋 13821 - 13900
	Gashapon_SignGone						= 13821,	--奖励已经过期
	Gashapon_MaxBuy							= 13822, 	--已经达到最大购买上限

	--精灵活动 13901 - 13950
	Elf_NotAddWish							= 13901,	--重置奖励后才可重新许愿
	Elf_NotAddWishlimt 						= 13902,	--该大奖抽取次数达到上限，无法许愿
	Elf_NotFinalItem 						= 13903,	--没有足够收集道具

	--新英雄副本活动 13971 - 13990
	NewHeroCopy_NotPlace					= 13971,	--只有共生殿中的英雄才被允许出战
	NewHeroCopy_Wait						= 13972,	--请求过快，请稍等一会

	--大富翁 13991 - 14000
	Monopoly_NotFight						= 13991,	--不是战斗事件
	Monopoly_HaveFight						= 13992,	--这个怪物已经战斗过了
	Monopoly_NotBoss						= 13993,	--boss还没有激活
	Monopoly_MaxLimit						= 13994,	--已经达到今天最大限制
	Monopoly_NotTimes						= 13995,	--您的色子不够
	Monopoly_MaxBuyLimit					= 13996,	--已经达到最大购买次数

	--天境赛世界擂台赛 14001 - 14050
	WorldSkyPvp_ActivityEnded			= 14001,	--活动已结束
	WorldSkyPvp_ActivityClosed			= 14002,	--活动未开启
	WorldSkyPvp_GuessErrBattleStart		= 14003,	--比赛已经开始，无法竞猜
	WorldSkyPvp_GuessErrCanNotGuess		= 14004,	--当前无法参与竞猜
	WorldSkyPvp_GuessErrNoGuessBattle	= 14005,	--本轮比赛全部轮空，没有可竞猜的比赛
	WorldSkyPvp_GuessErrHasGuessed		= 14006,	--已参与过本轮比赛竞猜
	WorldSkyPvp_SetBattleArrayError		= 14007,	--只能在准备阶段调整阵容
	WorldSkyPvp_CanNotSetBattleArray	= 14008,	--当前无法设置阵容信息


	--录像  14100 - 14150
	BattleRecord_OverShareTime          = 14100,    --已超过分享时间无法分享
	BattleRecord_ReachMaxLikes          = 14101,    --已达到今日最大点赞次数
	BattleRecord_HaveAddLikes           = 14102,    --今日已经点赞过该录像
	BattleRecord_CombatUnShareAble      = 14103,    --由于战力悬殊，无法分享
	BattleRecord_CollectAmountMax       = 14104,    --收藏录像数量已达上限

	--梦幻pvp  14150 - 14200
	DreamPVP_NotScore          			= 14151,    --积分不够
	DreamPVP_MaxScore          			= 14152,    --最大购买1000积分
	DreamPVP_NotStateArray				= 14153,	--当前阶段不可以调整阵容

	--探员试炼 14201 - 14230
	HeroTrial_BossDayNumError			= 14201,	--首领未开启，无法挑战

	--跨服天域pvp赛 14231 - 14250
	HorizonPvp_NotMatch 				= 14231,	--没有匹配到玩家
	HorizonPvp_NotAddBattleData 		= 14232,	--对手还没有准备好战斗数据
	HorizonPvp_AckBattleArrayType 		= 14233,	--没有布阵攻击阵容
	HorizonPvp_DefBattleArrayType 		= 14234,	--没有布阵防击阵容
	HorizonPvp_NotMatchServer 			= 14235,	--该对手的服务器尚未准备好,请重新匹配
	--排行榜进度奖励 14250 -14259
	TaskRankReward_HadGotReward 		= 14250,	--已经领取该奖励
	TaskRankReward_RewardNotActivate 	= 14251,	--该奖励未达到领取条件

	--神社祈福活动 14260 - 14269
	ShrinePray_NotAddWish				= 14260,	--已开启寻宝，无法添加许愿
	ShrinePray_NotAddWishlimt 			= 14261,	--该大奖抽取次数达到上限，无法许愿
	ShrinePray_HadGotChooseTheGrid		= 14262,	--已经寻过该格子的宝物了

	--星河神殿 14270 - 14290
	StarTemple_NotArenaRank				= 14271,	--需要提升竞技场排名
	StarTemple_HasThisPos				= 14272,	--您已经占领神位
	StarTemple_CoolTime					= 14273,	--请您的过了冷却时间再次挑战
	StarTemple_MaxStage					= 14274,	--超过最大强化等级

	--公会联赛 14291 - 14400
	GuildPvp_ChallengeActStatusErr		= 14291,	--当前阶段无法挑战
	GuildPvp_SetDefArrayActStatusErr	= 14292,	--只能在准备阶段设置防守阵容
	GuildPvp_ChallengeNumErr			= 14293,	--次数不足，无法挑战
	GuildPvp_ChallengeObjNotFind		= 14294,	--目标不存在
	GuildPvp_ChallengeObjHealthErr		= 14295,	--据点已击破，可追击提升公会增益
	GuildPvp_GiftBoxIsOpened			= 14296,	--该宝箱已被其他玩家开启
	GuidlPvp_ChallengeExpired			= 14297,	--当前据点已被其他成员挑战
	GuildPvp_ChallengeBeatHeathErr		= 14298,	--据点未击破，无法追击
	GuildPvp_ChallengeBeatNumLimit		= 14299,	--当前据点已达可追击次数上限
	GuildPvp_DefArrayGuildLimitErr		= 14300,	--您已不在本公会，无法进行该操作
	GuildPvp_DefArrayJoinLimit			= 14301,	--未参与本场比赛，无法进行该操作

	--公会传奇赛14401 - 14500
	GuildLeague_NotPreState				= 14401, 	--当前阶段不可以设置阵容
	GuildLeague_NotExitGuild			= 14402, 	--公会传奇赛期间无法进行此操作

	--组队竞技 15000 - 15100
	WorldTeamArena_AlreadyInvite        = 15000,    --已经邀请过
	WorldTeamArena_AlreadyHasTeam       = 15001,    --对方已经组队
	WorldTeamArena_MatchTimesNotEnough  = 15002,    --匹配次数不足
	WorldTeamArena_NotInBattleTime      = 15003,    --挑战还未能开始
	WorldTeamArena_BattleTimesNotEnough = 15004,    --挑战次数不足
	WorldTeamArena_DanLagToLarge        = 15005,    --段位差距过大
	WorldTeamArena_TeamMateCanBattle    = 15006,    --队员无法发起战斗

	--羁绊 15101-15105
	HeroFetter_HadGotReward				= 15101,	--已经领取过该奖励
	HeroFetter_RewardNotActivate		= 15102,	--条件未达成，无法领取奖励

	--封魔之路 15110 - 15130
	DevilRoad_NotPickGate 				= 15110,	--没有选择关卡
	DevilRoad_GridHadOpen				= 15111,	--格子已经激活
	DevilRoad_CanNotMove				= 15112,	--无法移动此格子
	DevilRoad_GridNotReach				= 15113,	--请到达后，再操作
	DevilRoad_GridNotOpen				= 15114,	--格子未激活
	DevilRoad_FinishLastChallenge		= 15115,	--请先结束上一场战斗
	DevilRoad_ChallengeHadFinished		= 15116,	--由于战斗中断，探员回复到战斗前的状态
	DevilRoad_NotChooseBuffs 			= 15117,	--没有增益效果可选择
	DevilRoad_NotExsitBuffs 			= 15118,	--错误的增益效果
	DevilRoad_CanNotChallenge 			= 15119,	--无法重复挑战


	--跨服竞技场 15150 - 15200
	CrossArena_NotFindPlayer			= 15150,	--竞技场没有此玩家
	CrossArena_NotFindEnemy				= 15151,	--敌方玩家未找到
	CrossArena_IsSelf					= 15152,	--不可挑战自己
	CrossArena_CanNotAward				= 15153,	--不可领取此奖励
	CrossArena_HadAward					= 15154,	--奖励已领取过
	CrossArena_NotRecord				= 15155,	--没有战斗记录
	CrossArena_RestTime					= 15156,	--休赛时间
	CrossArena_FreeTimesErr				= 15157,	--扣免费次数失败
	CrossArena_IsFighting				= 15158,	--正在挑战中
	CrossArena_CanNotBuy				= 15159,	--已达最大购买次数
	CrossArena_LikeFailed				= 15160,	--点赞失败
	CrossArena_NotFindTargetPlayer		= 15161,	--未找到目标玩家
	CrossArena_NoLikeNum				= 15162,	--点赞次数已用完
	CrossArena_DBDoesNotExist			= 15163,	--跨服竞技场DB不存在
	CrossArena_DoFightError				= 15164,	--战斗出错了
	CrossArena_ForbidFunction			= 15165,	--跨服竞技场禁用此接口
	CrossArena_NeedSetAckArray			= 15166,	--请先设置攻击阵容
	CrossArena_NoDefArray				= 15167,	--对方无防守阵容，不可被挑战
	CrossArena_TooFast					= 15168,	--请勿重复点击
	CrossArena_ServiceNotReady			= 15169,	--服务正在启动中
	CrossArena_HideNumError				= 15170,	--当前只可隐藏%s支队伍
	CrossArena_HadLikeThisPlayer		= 15171,	--已点赞过此玩家
	
	--每日登录活动 15201 - 15210
	EveryDayLogin_ParamError			= 15201,	--参数错误
	EveryDayLogin_CanNotReward			= 15202,	--不可领取此奖励
	EveryDayLogin_HadReward				= 15203,	--已领取过
	

	-- 探员置换 15211 - 15220
	HeroChange_ParamError					= 15211,	--参数错误
	HeroChange_HeroChange_NoSameCatagory	= 15212,	--非同种族卡牌
	HeroChange_StarNotFive					= 15213,	--材料卡牌非五星
	HeroChange_HeroNotSame					= 15214, 	--材料卡牌非同英雄
	HeroChange_StarNotTrueFive				= 15215,	--材料卡牌非真五星卡牌
	HeroChange_NumNotEnough					= 15216,	--材料卡牌个数不足
	--跨服超凡段位赛 15221 - 15250
	CrossSuperMundane_RestTime			= 15221,	--休赛时间
	CrossSuperMundane_JoinKingMatch 	= 15222,	--已经参加王者赛
	CrossSuperMundane_NotJoinKing		= 15223,	--没有参加王者赛资格
	CrossSuperMundane_NotMatchRival 	= 15224,	--没有匹配到对手,请从重新匹配
	CrossSuperMundane_NotRivalbattle 	= 15225,	--匹配的对手还没有准备好数据
	CrossSuperMundane_NotMathType 		= 15226,	--匹配类型参数错误

	--全服礼包 15230 - 15240
	ServerGroupBuy_AlreadyClaimed       = 15230,    --已领取该奖励
	ServerGroupBuy_ProgressNotReach     = 15231,    --还没达到对应的进度
	ServerGroupBuy_NotBuy               = 15232,    --还没购买对应的礼包

	--巅峰竞技 15241 - 15270
	TopArenaHadGuess					= 15241,	--已竞猜过
	TopArenaPlayerError					= 15242,	--玩家创建错误
	TopArena_NotFindPlayer				= 15243,	--未找到玩家
	TopArena_NoLikeNum					= 15244,	--点赞次数已用完
	TopArena_HadLikeThisPlayer			= 15245,	--已点赞过此玩家
	TopArena_GuessWrongPlayer			= 15246,	--竞猜选择的玩家非当前竞猜组
	TopArena_ServiceNotReady			= 15247,	--服务尚未初始化完成
	TopArenaGuessPassed					= 15248,	--已过竞猜时间
	TopArenaNotGuessTime				= 15249,	--当前非竞猜时间
	TopArenaNotLikeTime					= 15250,	--非活动时间
	
	--阵营试炼15280 - 15290
	TrialExchangeLimit                  = 15280,    --阵营试炼兑换次数已满
	TrialBattleEnd                      = 15282,    --不在挑战时间内
	TrialBattleLimit                    = 15283,    --已达到最大挑战次数

	--跨服天梯赛 15300 - 15320
	SkyLadder_NotJoin	                   = 15300,    --没有参赛资格
	SkyLadder_CantFindEnemy                = 15301,    --找不到玩家
	SkyLadder_BeActtacking                 = 15302,    --玩家正在被挑战中
	SkyLadder_ActNotStart                  = 15304,    --活动未开启
	SkyLadder_NotLikeTimes                 = 15305,    --已经点过赞了
	SkyLadder_RankHadChanged 			   = 15306,    --对手排名已经发生变化，请重新刷新
	SkyLadder_IsSelf 					   = 15307,    --不能挑战自己
	SkyLadder_DoFightError 				   = 15308,    --战斗错误
	SkyLadder_CanNotBuy 				   = 15309,    --购买次数达上限
	SkyLadder_ChallengeNotTimes 		   = 15310,    --没有挑战次数

	-- 专武功能 15321 - 15330
	UniqueWeapon_HeroStarNotEnough			= 15321,	--卡牌未达到%s级，无法解锁专武
	UniqueWeapon_NoUniqueWeapon				= 15322,	--卡牌专武未实现或者无专武
	UniqueWeapon_ReachMaxLevel				= 15323,	--卡牌专武已达到最高等级

	--协力大作战活动 15331 - 15350
	WorkTogether_ParamError					= 15331,	--参数错误
	WorkTogether_CanNotReward				= 15332,	--奖励未达成
	WorkTogether_HadReward					= 15333,	--奖励已领取过
	WorkTogether_ServiceError				= 15334,	--服务忙碌中，休息一下
	WorkTogether_HadHelp					= 15335,	--今日已助力过
	WorkTogether_BuyLimit					= 15336,	--不可超过最大购买次数
	WorkTogether_NotSell					= 15337,	--此商品已下架
	WorkTogether_NotFreeItem				= 15338,	--非免费商品
	WorkTogether_CanNotSetArray				= 15339,	--活动非开启状态，不可设置阵容
	WorkTogether_HeroHadUsed				= 15340,	--不可上阵今日已使用过的英雄
	WorkTogether_NoChallengeTimes			= 15341,	--挑战次数不足
	WorkTogether_NotDiamondBuy				= 15342,	--非钻石购买类商品
	WorkTogether_GroupChange				= 15343,	--关卡已刷新，请重新打开界面
	WorkTogether_CanNotFight				= 15344,	--该据点已完成占领，请选择其他进行挑战
	WorkTogether_ArrayEmpty					= 15345,	--请先设置阵容
	WorkTogether_PassIdError				= 15346,	--关卡错误
	WorkTogether_PlzChallenge				= 15347,	--挑战后才需保存积分
	
	--赠礼 15360 - 15370
	DonateGift_DonateMaxLimit               = 15360,    --今天赠礼次数已满
	DonateGift_ReceiveMaxLimit              = 15361,    --对方今日收礼次数已满
	DonateGift_GetRewardTimePass            = 15362,    --该赠礼已过期
	DonateGift_GetRewardTimeGet             = 15363,    --该赠礼已领取

	--事件播报 15371 - 15400					
	NewsBoard_AreadyArgee 					= 15371,	--不能重复点赞
	NewsBoard_NotArgeePlayer				= 15372,	--没有这个点赞的玩家
	NewsBoard_NotArgeeNews					= 15373,	--没有这个新闻
	NewsBoard_AreadyRecv 					= 15374,	--奖励已经领取过

	--合服 15401 - 15450
	MergeServer_ActivityNotEqual			= 15401,	--合服活动id相同内容不同
	MergeServer_DBExcuteError				= 15402,	--合服数据库执行报错


	--异能计划 15501 - 15550
	PowerPlan_NotConfig 					= 15501,	--异能计划没有这个配置
	PowerPlan_IsFighting 					= 15502,	--有其他玩家正在攻击boss，请稍后再试
	PowerPlan_NotPoint						= 15503, 	--挑战次数不足
	PowerPlan_NotArray						= 15504, 	--异能计划 没有阵型
	PowerPlan_NotConfigEx					= 15505,	--战斗配置错误
	PowerPlan_NotNodeId 					= 15506,	--超过当前关卡
	PowerPlan_NotReward						= 15507,	--没有达到领取的条件
	PowerPlan_HadReward						= 15508,	--已经领取过这个奖励
	PowerPlan_HadPass						= 15509,	--已经通关不能挑战
	
	--跨服天梯冠军赛 15551 - 15580
	SkyLadChampion_ActNotStart 				= 15551, 	--活动未开启
	SkyLadChampion_PointNotEnough			= 15552, 	--积分不足
	SkyLadChampion_CanntGuess				= 15553, 	--不是竞猜阶段
	SkyLadChampion_DBDoesNotExist			= 15554,	--跨服天梯冠军赛DB不存在

	--节日寄语活动 15581 - 15600
	FestivalWish_ParamError					= 15581,	--版本配置错误
	FestivalWish_hadWish					= 15582,	--已填写寄语
	FestivalWish_Empty						= 15583,	--寄语内容为空，请填写再提交
	FestivalWish_TooLong					= 15584,	--寄语内容太长
	FestivalWish_SpecialErr					= 15585,	--寄语内容含特殊字符
	FestivalWish_FilterErr					= 15586,	--寄语内容含敏感词

	--合服调查问卷
	Survey_HasVote							= 15591,	--您已经投过票了

	--荣誉墙 15595 - 15600
	HonorMedalWall_NoTheMedal				= 15595, 	--没有获得此成就勋章
	HonorMedalWall_MaxLevel					= 15596, 	--荣誉头衔已达到最高级
	HonorMedalWall_MedalLoaded				= 15597,	--成就勋章已装配

	 --神墟活动 15601 - 15630
	GodMarket_NotFindGridId 				= 15601, --找不到格子
	GodMarket_NotJoinGridId 				= 15602, --没有资格加入
	GodMarket_GridLocking 					= 15603, --格子已经解锁
	GodMarket_NotLockGrid   				= 15604, --附近格子未通关
	GodMarket_NotAction 					= 15605, --行动力不足
	GodMarket_NotNormaLand 					= 15606, --普通神格通关数量不足
	GodMarket_NotTopLand  					= 15607, --普通神格通关数量不足
	GodMarket_NotMoveCd 					= 15608, --移动过于频繁了
	GodMarket_NotMoveGridId 				= 15609, --移动格子不对
	GodMarket_NotBuy 						= 15610, --已经购买过了
	GodMarket_NotBosPoS 					= 15611, --宝箱位置不存在
	GodMarket_AlreadyBosPoS					= 15612, --已经领取过该位置的宝箱
	GodMarket_NotBosConfig 					= 15613, --找不到宝箱配置

	--周巡拼图活动 15631 - 15650
	WeekPuzzle_HadLight						= 15631,	--此格子已点亮过
	WeekPuzzle_HadChoose					= 15632,	--已选择大奖
	WeekPuzzle_NotFindConfig				= 15633,	--未找到对应配置
	WeekPuzzle_NotChoose					= 15634,	--尚未选择大奖
	WeekPuzzle_HadGetReward					= 15635,	--已领取过奖励
	WeekPuzzle_NotLightAll					= 15636,	--尚未全部点亮格子
	WeekPuzzle_NotHaveTheTask				= 15637,	--当前未有此任务
	WeekPuzzle_NotFinishTask				= 15638,	--此任务尚未完成
	WeekPuzzle_NotFinish					= 15639,	--尚未达成,不可领取
	
	--定向推送礼 15651 - 15670
	CustomPushGift_HadBuy					= 15651,	--已购买过
}