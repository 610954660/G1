--�������
local TitleBoard = class("TitleBoard",BindView)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --�������ö�ȡ��
local FashionConfiger = require "Game.ConfigReaders.FashionConfiger"
local BagType = GameDef.BagType
function TitleBoard:ctor(view,noClick)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
end

function TitleBoard:init( ... )

end

--�˳����� ��closeִ��֮ǰ 
function TitleBoard:__onExit()
     print(086,"TitleBoard __onExit")
--   self:_exit() --ִ��������д
   --[[self:clearEventListeners()
   for k,v in pairs(self.baseCtlView) do
   		v:__onExit()
   end--]]
end

return TitleBoard