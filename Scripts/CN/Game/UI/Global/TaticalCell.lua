--added by wyang	
--阵法框封裝
local TaticalCell = class("TaticalCell",BindView)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local BagType = GameDef.BagType
function TaticalCell:ctor(view)
	self.iconLoader = false
end

function TaticalCell:init( ... )

	self.iconLoader = self.view:getChildAutoType("iconLoader")
end

function TaticalCell:setData(taticalCode)
	local info = DynamicConfigData.t_TacticalUnlock[taticalCode]
	if info then
		local path = PathConfiger.getTacticalIcon(taticalCode)
		print(1, path)
		self.iconLoader:setURL(path)
	end
end

--退出操作 在close执行之前 
function TaticalCell:__onExit()
end

return TaticalCell