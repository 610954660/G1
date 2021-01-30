local DragDropManager = {
	call_move = false,
	call_end = false,
	dragDropManager=fgui.DragDropManager:getInstance()
}

local pInstance = nil;
function dragDropManager()
	if not pInstance then
		pInstance = DragDropManager;
		pInstance:init();
	end
	return pInstance;
end

function DragDropManager:init()
 	
 	local function moveCall()
 		if self.call_move  then
 			self.call_move()
 			--self.call_move = nil;
 		end
 	end

 	local function endCall()
 		if self.call_end  then
 			self.call_end()
 			self.call_end = nil;
 		end
 	end
	self.dragDropManager:getAgent():addEventListener(FUIEventType.DragMove, moveCall)
 	self.dragDropManager:getAgent():addEventListener(FUIEventType.DragEnd, endCall)
 end 

 function DragDropManager:addSingelEvent(eventType,event)
 	if eventType==FUIEventType.DragEnd then
 		self.call_end = event
 	end
	if eventType==FUIEventType.DragMove then
		self.call_move = event
	end

 end