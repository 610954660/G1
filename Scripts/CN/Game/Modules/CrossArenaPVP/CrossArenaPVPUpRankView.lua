local CrossArenaPVPUpRankView,Super = class("CrossArenaPVPUpRankView", Window)

function CrossArenaPVPUpRankView:ctor()
	self._packName = "CrossPVP"
	self._compName = "CrossArenaPVPUpRankView"
	--self._rootDepth = LayerDepth.Window
	self.__reloadPacket = true
end

function CrossArenaPVPUpRankView:_initEvent()
	
end

function CrossArenaPVPUpRankView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossPVP.CrossArenaPVPUpRankView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.rankEff = viewNode:getChildAutoType('rankEff')--GLoader
	self.rankEffUp = viewNode:getChildAutoType('rankEffUp')--GLoader
	self.rankIcon = viewNode:getChildAutoType('rankIcon')--GLoader
	self.rankName = viewNode:getChildAutoType('rankName')--GRichTextField
	self.t0 = viewNode:getTransition('t0')--Transition
	self.titleEff = viewNode:getChildAutoType('titleEff')--GLoader
	--{autoFieldsEnd}:CrossPVP.CrossArenaPVPUpRankView
	--Do not modify above code-------------
end

function CrossArenaPVPUpRankView:_initUI()
	self:_initVM()
	
	
	
	
	
	
	
	
	self:_refreshView()
end


function CrossArenaPVPUpRankView:_refreshView()

end

function CrossArenaPVPUpRankView:onExit_()

end

return CrossArenaPVPUpRankView