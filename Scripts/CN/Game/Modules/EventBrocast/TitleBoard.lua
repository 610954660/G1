--标题面板
local TitleBoard = class("TitleBoard",BindView)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local FashionConfiger = require "Game.ConfigReaders.FashionConfiger"
local BagType = GameDef.BagType
function TitleBoard:ctor(view,noClick)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
end

function TitleBoard:init( ... )

end

--退出操作 在close执行之前 
function TitleBoard:__onExit()
     print(086,"TitleBoard __onExit")
--   self:_exit() --执行子类重写
   --[[self:clearEventListeners()
   for k,v in pairs(self.baseCtlView) do
   		v:__onExit()
   end--]]
end

return TitleBoard