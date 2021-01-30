----------------------------------------------------
-- 本文件用于定义与php通信相关的常量
----------------------------------------------------
--接口action类型
HttpActionType = {
	--资源及版本，游戏启动第一个接口调用（非常关键）
	GET_VERSION = "get_version", 
	
	--进入游戏时的帐号数据校验
	GYLOGIN = "gyLogin",
	
	--获取推荐服
	GET_RECOMMEND_SERVER = "get_recommend_server",
	--获取服务器列表
	GET_SERVER = "get_server",
	--更新玩家最后一次登录的信息
	UPDATE_PLAYER = "update_player",
	--游戏bug监控
	REPORT_BUG = "report_bug",
	--步骤监控
	REPORT_STEP = "report_step",
	--获取商店内商品列表
	GET_GOLD_TAG = "get_gold_tag",
	--下载分包信息
	PACKAGE_LOG = "package_log", 
	--登录界面获取公告
	GAME_NOTICE = "game_notice",
	--获取进入游戏后的版本公告
	VERSION_NOTICE = "version_notice",
	--激活码
	ACTIVATION = "activation",
	
	--设备激活
	DEVICE_ACTIVATION = "deviceActivation",

	REGISTER = "register",
	PHONE = "user_phone",
	PASSWORD = "user_password",
	USER_CHECK = "user_check",
	FEED_BACK = "feedBack",
	FEED_BACK_MY = "feedBackMy",
	FEED_BACK_UPDATE = "feedBackUpdate",
	-- 实名认证
	IDENTITY_CARD = "identity_card",
	--提交客服反馈
	COMMIT_QUESTION = "feed_back",

	--获取订单
	GET_ORDER_ID = "gyOrder",
	
	--Vip客服
	GS_MEMBER = "gsMember",
	
}

--玩家到达步骤信息
ReportStepType = {	
	ENTER_LUA 					= 100, 		--启动游戏到Lua入口
	SDK_INIT_SUCCESS 			= 150, 		--sdk初始化成功
	GET_UPDATE_INFO 			= 200, 		--获得正确的更新信息
	GET_RES_LIST 				= 300, 		--获得正确的资源列表
	UPDATE_FINISH 				= 400,  	--更新结束
	SDK_LOGIN_SUCCESS 			= 500, 		--SDK登录成功
	PHP_VARIFY_SUCCESS 			= 600, 		--PHP验证登录成功
	GET_RECOMMEND_SERVER 		= 650, 		--获得推荐服
	ENTER_SERVER_LIST 			= 700, 		--进入选服界面
	GET_SERVER_LIST 			= 720, 		--获得服务器列表
	CONNNECT_SERVER_SUCCESS 	= 740, 		--连接服务器成功
	SERVER_CHECK_SUCCESS 		= 790, 		--服务器校验成功
	CHOOSE_EVENT				= 795, 			--到达选择事件步骤
	ENTER_CREATE_ROLE 			= 800, 		--创建角色界面
	CLICK_CR_BTN 				= 820, 		--点击创建角色按钮
	CREATE_ROLE_SUCCESS 		= 840, 		--创建角色成功
	FIRST_FIGHT_PREPARE			= 1100, 	--第一场战斗备战
	FIRST_FIGHT_BEGIN			= 1200, 	--第一场战斗开始
	FIRST_FIGHT_END 			= 1300, 	--第一场战斗结束
	ENTER_GAME_SCENE 			= 1400, 	--准备进入主界面
	ENTER_MAIN_UI 				= 1500, 	--进入主界面
	
	SUBPACK_DOWN_START 			= 1901, 	--分包下载开始	
	SUBPACK_DOWN_FINISH 		= 1910, 	--分包下载完成	
	
	UPDATE_BEGIN 				= 2000, 	--版本更新开始
	UPDATE_FINISH 				= 2100, 	--版本更新结束
	
	GET_MODULE_OPEN = 2000 --功能模块开放
}

--异常信息类型
BugInfoType = {
	--lua报错
	LUA_ERROR=1,
	--部分资源更新失败
	RES_UPDATE_FAILED=2,
	--获取服务器列表失败
	GET_SERVER_LIST_FAILED=3,
	--登录SDK失败
	LOGIN_SDK_FAILED=4,
	--登录游戏登录服失败
	LOGIN_LOGIN_SERVER_FAILED=5,
	--登录游戏游戏服失败
	LOGIN_GAME_SERVER_FAILED=6,
	--创号失败
	CREATE_ROLE_FAILED=7,
	--进地图长时间未收到主角信息下推
	LONG_TIME_NOT_RECEIVED_KING_INFO=8,
	--玩家跳到了一个不可到达的坐标
	JUMPED_TO_UNREACHABLE_GRID=9,
	--获取充值商品列表失败
	GET_RECHARGE_LIST_FAILED=10,
	--cpp底层信息
	NATIVE_INFO=11,
}
