local CrossPVPTicketView,Super = class("CrossPVPTicketView", Window)

function CrossPVPTicketView:ctor()
	self._packName = "CrossPVP"
	self._compName = "CrossPVPTicketView"
	--self._rootDepth = LayerDepth.Window
	self.__reloadPacket = true
end

function CrossPVPTicketView:_initEvent()
	
end

function CrossPVPTicketView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossPVP.CrossPVPTicketView
	self.closeButton = viewNode:getChildAutoType('$closeButton')--GLabel
	self.buy = viewNode:getChildAutoType('buy')--GButton
	self.cancel = viewNode:getChildAutoType('cancel')--GButton
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.itemCell = viewNode:getChildAutoType('itemCell')--GButton
	--{autoFieldsEnd}:CrossPVP.CrossPVPTicketView
	--Do not modify above code-------------
end

function CrossPVPTicketView:_initUI()
	self:_initVM()
	
	
	
	
	
	
	
	
	self:_refreshView()
end


function CrossPVPTicketView:_refreshView()

end

function CrossPVPTicketView:onExit_()

end

return CrossPVPTicketView