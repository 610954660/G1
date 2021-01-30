---------------------------------------------------------------
--内网测试环境中使用的变量
------------------------------------------------------------------package.cpath = package.cpath .. ";c:/Users/Administrator/.vscode/extensions/tangzx.emmylua-0.3.49/debugger/emmy/windows/x86/?.dll"


--测试环境 可以进入软件调试
if  ScriptType == ScriptTypeLua and not __IS_RELEASE__ and CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
	print(0,'LuaPerfect: try')
	local _, LuaDebuggee = pcall(require, 'LuaDebuggee')

	if LuaDebuggee and LuaDebuggee.StartDebug then
		if LuaDebuggee.StartDebug('127.0.0.1', 9826) then
			print(0,'LuaPerfect: Successfully connected to debugger!')
		else
			package.loaded["LuaDebuggee"] = nil
			print(0,'LuaPerfect: Failed to connect debugger!')
		end
	else
		print(0,'LuaPerfect: Check documents at: https://luaperfect.net')
	end
end
package.cpath = package.cpath .. ";c:/Users/Administrator/.vscode/extensions/tangzx.emmylua-0.3.49/debugger/emmy/windows/x86/?.dll"
local dbg = require("emmy_core")
dbg.tcpListen("localhost", 9966)

__DEBUG__ = true

__USE_LUASTUDIO__=false

__LJJ_PROJECT__ = false

__LJJ_BattleTest__ = false

--是否显示地图格子
__SHOW_MAP_GRID__ = false --true--

--是否显示广播格子
__SHOW_BROADCAST_GRID__ = false--true--

--是否略过登录，直接进游戏场景
__IGONRE_LOGIN__ = false--true--

--每个人定义一个自己的类型，用于屏蔽其他人写的打印log，为0时打印所有CN
__PRINT_TYPE__ = 2233
__PRINT_COLOR__ = 14

--调用print时是否显示文件和等号
__PRINT_WITH_FILE_LINE__ = false--true--


--显示登录信息 测试用
__IS_SHOW_LOGININFO__ = true

--------------------------------------------------
--默认用户名
__DEFAULT_USERNAME__ = ""

--默认密码
__DEFAULT_PASSWORD__ = "123456"

--服务器ip
__LOGIN_IP__ = ""
--端口
__LOGIN_PORT__ = ""


--帧率
__FPS__ = 60

--模型播放帧率
__MODEL_FPS__ = 30

--是否忽略锁定
__IGNORE_LOCK__ = false

__RES_URL__ = "" --更新资源路径
__SERVER_LIST_MD5__ = ""

--非技术要看具体改变接口的数据接口，请将__PRINT_TYPE__改成10000
__HACK_SEND__=""--填对应的文件路径如果不启用填"",发布模式无效。（打包的童鞋注意剔除这个目录，或者热更支持Scripts以外目录)


--是否显示地图格子
__SHOW_MAP_GRID__ = false --true--

__USE_TEST_SOUND__ = false --使用测试声音

if __IS_RELEASE__ then
	__SHOW_MAP_GRID__ = false
	__SHOW_BROADCAST_GRID__ = false
	__IGONRE_LOGIN__ = false
	__HACK_SEND__ = ""
end
