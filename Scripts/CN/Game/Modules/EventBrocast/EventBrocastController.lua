--added by wyang
--事件播报控制器
local EventBrocastController = class("EventBrocastController",Controller)

function EventBrocastController:init()
end


function EventBrocastController:public_enterGame()
	EventBrocastModel:getInfo()
end

function EventBrocastController:NewsBoard_NotifyInfo()
	EventBrocastModel:getInfo()
end
return EventBrocastController