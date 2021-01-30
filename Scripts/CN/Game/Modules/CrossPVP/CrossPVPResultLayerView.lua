local CrossPVPResultLayerView,Super = class("CrossPVPResultLayerView", Window)

function CrossPVPResultLayerView:ctor()
	self._packName = "CrossPVP"
	self._compName = "CrossPVPResultLayerView"
	--self._rootDepth = LayerDepth.Window
	self.__reloadPacket = true
end

function CrossPVPResultLayerView:_initEvent()
	
end

function CrossPVPResultLayerView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossPVP.CrossPVPResultLayerView
	self.headItem1 = viewNode:getChildAutoType('headItem1')--resultPlay
		self.headItem1.headItem = viewNode:getChildAutoType('headItem1/headItem')--GButton
		self.headItem1.name = viewNode:getChildAutoType('headItem1/name')--GRichTextField
		self.headItem1.severName = viewNode:getChildAutoType('headItem1/severName')--GRichTextField
	self.headItem2 = viewNode:getChildAutoType('headItem2')--resultPlay
		self.headItem2.headItem = viewNode:getChildAutoType('headItem2/headItem')--GButton
		self.headItem2.name = viewNode:getChildAutoType('headItem2/name')--GRichTextField
		self.headItem2.severName = viewNode:getChildAutoType('headItem2/severName')--GRichTextField
	self.mark = viewNode:getChildAutoType('mark')--GRichTextField
	self.rank = viewNode:getChildAutoType('rank')--GRichTextField
	--{autoFieldsEnd}:CrossPVP.CrossPVPResultLayerView
	--Do not modify above code-------------
end

function CrossPVPResultLayerView:_initUI()
	self:_initVM()
	
	local hero = BindManager.bindPlayerCell(self.headItem1.headItem)
	hero:setHead(PlayerModel.head, PlayerModel.level,nil,nil,nil)
	self.headItem1.name:setText(PlayerModel.username)
	self.headItem1.severName:setText(CrossPVPModel:getSeverName(LoginModel:getUnitServerId()))

	local data = CrossPVPModel:getMatchingPlayer()
	local hero1 = BindManager.bindPlayerCell(self.headItem2.headItem)
	hero1:setHead(data.pkInfo.head, data.pkInfo.level,nil,nil,nil)
	self.headItem2.name:setText(data.pkInfo.name)
	self.headItem2.severName:setText(CrossPVPModel:getSeverName(data.pkInfo.serverId))
	
	local diff = math.abs(self._args.fightData.oldRank - self._args.fightData.newRank)
	self.mark:setText(string.format(Desc.CrossPVPDesc10,self._args.fightData.newRank,diff))
	self.rank:setText(string.format(Desc.CrossPVPDesc11,CrossPVPModel:getBaseMark(),self._args.fightData.score))
	
	self:_refreshView()
end


function CrossPVPResultLayerView:_refreshView()

end

function CrossPVPResultLayerView:onExit_()

end

return CrossPVPResultLayerView