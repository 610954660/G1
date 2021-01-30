local CrossPVPUpRankView,Super = class("CrossPVPUpRankView", Window)

function CrossPVPUpRankView:ctor()
	self._packName = "CrossPVP"
	self._compName = "CrossPVPUpRankView"
	--self._rootDepth = LayerDepth.Window
	self.__reloadPacket = true
end

function CrossPVPUpRankView:_initEvent()
	
end

function CrossPVPUpRankView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossPVP.CrossPVPUpRankView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.rankEff = viewNode:getChildAutoType('rankEff')--GLoader
	self.rankEffUp = viewNode:getChildAutoType('rankEffUp')--GLoader
	self.rankIcon = viewNode:getChildAutoType('rankIcon')--GLoader
	self.rankName = viewNode:getChildAutoType('rankName')--GRichTextField
	self.t0 = viewNode:getTransition('t0')--Transition
	self.titleEff = viewNode:getChildAutoType('titleEff')--GLoader
	--{autoFieldsEnd}:CrossPVP.CrossPVPUpRankView
	--Do not modify above code-------------
end

function CrossPVPUpRankView:_initUI()
	self:_initVM()
	
	
	
	
	
	
	
	
	self:_refreshView()
end


function CrossPVPUpRankView:_refreshView()

end

function CrossPVPUpRankView:onExit_()

end

return CrossPVPUpRankView