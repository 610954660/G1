local AgentConfiger = {}
local httpPrefix = "http"
if __USE_HTTPS__ then
	httpPrefix = "https"
end

--正式中央后台
local formalCenterFormat = string.format("%s://api-%s.guangyv.com/v1/%s/", httpPrefix, __PROJECT_NAME__, "%s")
--测式中央后台
local testCenterFormat = string.format("%s://api-%s-test.guangyv.com/v1/%s/", httpPrefix, __PROJECT_NAME__, "%s")
--资源下载备机地址
AgentConfiger.backupCDNUrlFormat = string.format("%s://cdn%s-%s.guangyv.com/%s", httpPrefix, "%d", __PROJECT_NAME__,"%s")
AgentConfiger.backupClientUrlFormat = string.format("%s://client%s-%s.guangyv.com/%s", httpPrefix, "%d", __PROJECT_NAME__,"%s")
--资源下载源服务器地址
AgentConfiger.serverClientUrlFormat = string.format("%s://client-%s.guangyv.com/%s", httpPrefix, __PROJECT_NAME__,"%s")


--使用的中央后台
function AgentConfiger.initUrls()	
	local finalCenterFormat = formalCenterFormat
	if __USE_TEST_URL__ and not GlobalUtil.isPCDownload() then
		finalCenterFormat = testCenterFormat
	end

	AgentConfiger.logkey = "g1##1@bd&CKEY"

	AgentConfiger.encryptKey = AgentConfiger.logkey
	--用于上传语音
	AgentConfiger.yySKey = "$%&s#y&$p#&i$&c$"
	--用于上传头像
	AgentConfiger.yyzgSKey = "yy_ZG^&020&CKEY"
	--等待sdk登录成功后写入
	AgentConfiger.tokenKey = ""

	--测试中央后台
	AgentConfiger.testCenterURL = string.format(testCenterFormat, "client")

	--最终使用的中央后台
	AgentConfiger.centerURL = string.format(finalCenterFormat, "client")
	--登录
	AgentConfiger.loginURL = string.format(finalCenterFormat, "login")
	--支付
	AgentConfiger.payURL = string.format(finalCenterFormat, "pay") .. "gyPay/platform/"
	--获取订单
	AgentConfiger.orderURL = string.format(finalCenterFormat, "order")

	--语音服地址
	AgentConfiger.speechUploadURL = string.format("%s://yy-%s.guangyv.com/sy_voice/up_voice.php?", httpPrefix, __PROJECT_NAME__)
	AgentConfiger.speechDownloadURL = string.format("%s://yy-%s.guangyv.com/sy_voice/down_voice.php?", httpPrefix, __PROJECT_NAME__)

	--自定义头像上传下载
	AgentConfiger.customPhotoUploadURL = string.format("%s://yy.guangyv.com/api/upImage/upImage?", httpPrefix)
	AgentConfiger.customPhotoDownloadURL = string.format("%s://yy.guangyv.com/api/downImage/downImage?", httpPrefix)

	-------------------------------------
	-- 一些提交给渠道的数据相关，需确保值与出包枚举里的一致
	AgentConfiger.SDK_RECORD_CREATE_ROLE = 100 --记录创建角色
	AgentConfiger.SDK_RECORD_ENTER_SERVER = 101 --记录登录服务器
	AgentConfiger.SDK_RECORD_LEVEL_UPDATE = 102 --记录等级变化
	AgentConfiger.SDK_LOGIN_VERIFICATION = 103  --sdk登陆验证
	AgentConfiger.SDK_RECORD_PAYMENT = 104 --支付记录
	AgentConfiger.SDK_RECORD_CONSUME = 105  --消费记录
	AgentConfiger.SDK_RECORD_VIP_UPDATE = 106  --vip等级改变
	
	AgentConfiger.SDK_OPEN_CUSTOMERSERVICE = 150  --打开客服中心

	AgentConfiger.SDK_REGISTER_ACCOUNTS = 200 --调用sdk接口注册帐号
	AgentConfiger.SDK_LOGIN_SDK = 201 --调用sdk接口登录		
	--------------------------------------

	AgentConfiger.DEVICE_GET_SAFE_AREA = 300  --获取安全区
	AgentConfiger.SCREEN_SHOT_SUCCESS = 301	--截图完成
	AgentConfiger.USER_GET_REALNAMEINFO = 302	--获取实名信息
	AgentConfiger.BUGLY_SET_USERINFO = 303	--bugly设置用户信息
	AgentConfiger.BUGLY_REPORT_ERROR = 304  --bugly上报错误信息
	AgentConfiger.BUGLY_SET_USERSTEP = 305  --bugly设置用户当前操作
end

--通过这个接口获取渠道标识
function AgentConfiger.getRealAgent()
	if  __AGENT_SUFFIX__ ~= "" then
		return __AGENT_SUFFIX__
	end

	return __AGENT_CODE__
end

--获取登录时用的agent，用于不同渠道帐号互通
function AgentConfiger.getLoginAgent()
	if __AGENT_LOGIN__ ~= "" then
		return __AGENT_LOGIN__
	end
	return AgentConfiger.getRealAgent()
end

--检测当前平台是否需要屏蔽客服系统
function AgentConfiger.canShowCustomService()
	local qq = FileCacheManager.getStringForKey("CustomerServiceQQ", "", nil, true)
	if qq and qq ~= "" then
		if qq == "-" then
			return false
		end

		local firstChar = string.sub(qq, 1, 1)
		if firstChar == "-" then
			local leftChars = string.sub(qq, 2, -1)
			if leftChars == __APP_VERSION__ then
				return false
			end
		end
	end

	return true
end


-- 登录时检测是否连错了中央后台
function AgentConfiger.needShowURLWanning()
	if __USE_TEST_URL__ then
		local agent = getRealAgent()
-- 手盟版署	smbanshu
-- 评测越狱	pingceyueyu
-- 评测君海	pingcejunhai
-- 版署		banshu
-- 光娱测试	test
		if not ( 
			agent == "banshu"
			or agent == "smbanshu" 
		) then
			return true
		end
	end
	return false
end

function AgentConfiger.isDalanInAuditing()
	return __AGENT_CODE__ == "dalan_appstore" and __IN_AUDITING__
end

--是否是评测渠道
function AgentConfiger.isPingceAgent()
	return string.find(getRealAgent(), "pingce") ~= nil
end

--版署
function AgentConfiger.isBanshu()
	return string.find(getRealAgent(), "banshu") ~= nil
end

--内网包
function AgentConfiger.isInnerTest()
	return string.find(__AGENT_CODE__, "test")
end

--获取审核loading图
function AgentConfiger.getAuditLoadingBg()
	if __AGENT_CODE__ == "sshx_appstore" then
		return string.format("UI/Loading/loading_%s.jpg",__AGENT_CODE__)
	end

	return false
end

--获取审核登录图
function AgentConfiger.getAuditLoginBg()
	if not AgentConfiger.isAudit() then return false end

	return string.format("UI/Loading/login_%s.jpg",__AGENT_CODE__)
end

--是否审核版本
function AgentConfiger.isAudit()

	return __IN_AUDITING__
end

--初始化各种url
AgentConfiger.initUrls()

return AgentConfiger