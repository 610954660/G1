----------------------------------------------------
-- 本文件用于定义所有开关控制变量
----------------------------------------------------

--大渠道下的子渠道，主要用于跟php沟通
__AGENT_SUFFIX__ = "test"--"jinshanyunshance"--"test"
--登录渠道，在登录创号时传给服务端
__AGENT_LOGIN__ = "test"--"jinshanyunshance"--"test"
--Appstore版是否处于审核中
__IN_AUDITING__ = false
--是否关闭充值，交易
__CLOSE_PAY__ = false
--是否启用https
__USE_HTTPS__ = false --CC_TARGET_PLATFORM == CC_PLATFORM_IOS

--默认用户名
__DEFAULT_USERNAME__ = ""--"6086649"
--默认密码
__DEFAULT_PASSWORD__ = "123456"

--自定义服务器 定义格式如下
__TEST_LOGIN_SERVER__ = false

--__TEST_LOGIN_SERVER__ = {
	--health=2,
	--ip="192.168.9.95",
	--create_time=1520306730,
	--server_id=99082,
	--unit_server=99082,
	--name="自定义",
	--port=2022,
--}


__ENTER_GAME__ = false


