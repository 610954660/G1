--主界面控制器
--added by xhd
local MainUIController = class("MainUIController",Controller)

function MainUIController:__showReconnect(e, times)
	LuaLogE(DescAuto[185]) -- [185]="重新连接中........."
end

function MainUIController:init( ... )
end

function MainUIController:module_check(_, type , val )
	-- print(1 , "模块检测控制： ", type , val)
	GlobalUtil.delayCallOnce("MainUIController:module_check", function()
		ModuleUtil.checkModuleOpen(type , val)
	end)
end
--自动绑定方法
function MainUIController:bindMapFun( )
	return {}
end

-- 重连成功
function MainUIController:mainui_reconnectSuccess()

end

function MainUIController:__disconnect(_, initiativeClose)
end

return MainUIController
