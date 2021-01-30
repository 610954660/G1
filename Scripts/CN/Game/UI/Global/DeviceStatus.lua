--added by wyang
--道具框封裝
--local DeviceStatus = class("DeviceStatus")
local DeviceStatus,Super = class("DeviceStatus",BindView)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
function DeviceStatus:ctor(view)
	self.netStatusCtrl = false
	self.txt_ping = false
	self.lastUpdataNetTime = 0 --上一次更新网络类型时间
end


function DeviceStatus:_initUI( ... )
	self.netStatusCtrl = self.view:getController("netType")
	self.txt_ping = self.view:getChildAutoType("txt_ping")
	self:updateNetType()
end

function DeviceStatus:updateNetType()
	self.lastUpdataNetTime = cc.millisecondNow()
	local networkType = gy.GYDeviceStatusListener:getInstance():getNetStatus()
	if networkType == gy.NETWORK_STATUS_WIFI then
		self.netStatusCtrl:setSelectedIndex(0)
	elseif networkType == gy.NETWORK_STATUS_MOBILE then
		self.netStatusCtrl:setSelectedIndex(3)
	else
		self.netStatusCtrl:setSelectedIndex(0)
	end
	
end

function DeviceStatus:network_ping(evnt, data)
	self.txt_ping:setText(data.."ms")
	--10秒更新一次网络类型
	if cc.millisecondNow() - self.lastUpdataNetTime > 10000 then
		self:updateNetType()
	end
end


--退出操作 在close执行之前 
function DeviceStatus:_onExit()
    print(1,"DeviceStatus __onExit")
end

return DeviceStatus