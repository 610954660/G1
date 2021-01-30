local CrossFightAnimationView,Super = class("CrossFightAnimationView", Window)

function CrossFightAnimationView:ctor()
	self._packName = "CrossPVP"
	self._compName = "CrossFightAnimationView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
	self.spine = false
end

function CrossFightAnimationView:_initEvent()
	
end

function CrossFightAnimationView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossPVP.CrossFightAnimationView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.fightLeft = viewNode:getChildAutoType('fightLeft')--fightLeft
		self.fightLeft.group1 = viewNode:getChildAutoType('fightLeft/group1')--GGroup
		self.fightLeft.heroCell1 = viewNode:getChildAutoType('fightLeft/heroCell1')--heroInfoBattleItem
			self.fightLeft.heroCell1.heroCell = viewNode:getChildAutoType('fightLeft/heroCell1/heroCell')--GButton
			self.fightLeft.heroCell1.name = viewNode:getChildAutoType('fightLeft/heroCell1/name')--GTextField
			self.fightLeft.heroCell1.severName = viewNode:getChildAutoType('fightLeft/heroCell1/severName')--GTextField
	self.fightRight = viewNode:getChildAutoType('fightRight')--fightRight
		self.fightRight.group2 = viewNode:getChildAutoType('fightRight/group2')--GGroup
		self.fightRight.heroCell2 = viewNode:getChildAutoType('fightRight/heroCell2')--heroInfoBattleItem
			self.fightRight.heroCell2.heroCell = viewNode:getChildAutoType('fightRight/heroCell2/heroCell')--GButton
			self.fightRight.heroCell2.name = viewNode:getChildAutoType('fightRight/heroCell2/name')--GTextField
			self.fightRight.heroCell2.severName = viewNode:getChildAutoType('fightRight/heroCell2/severName')--GTextField
	self.leftpos = viewNode:getChildAutoType('leftpos')--fightLeft
		self.leftpos.group1 = viewNode:getChildAutoType('leftpos/group1')--GGroup
		self.leftpos.heroCell1 = viewNode:getChildAutoType('leftpos/heroCell1')--heroInfoBattleItem
			self.leftpos.heroCell1.heroCell = viewNode:getChildAutoType('leftpos/heroCell1/heroCell')--GButton
			self.leftpos.heroCell1.name = viewNode:getChildAutoType('leftpos/heroCell1/name')--GTextField
			self.leftpos.heroCell1.severName = viewNode:getChildAutoType('leftpos/heroCell1/severName')--GTextField
	self.rightpos = viewNode:getChildAutoType('rightpos')--fightRight
		self.rightpos.group2 = viewNode:getChildAutoType('rightpos/group2')--GGroup
		self.rightpos.heroCell2 = viewNode:getChildAutoType('rightpos/heroCell2')--heroInfoBattleItem
			self.rightpos.heroCell2.heroCell = viewNode:getChildAutoType('rightpos/heroCell2/heroCell')--GButton
			self.rightpos.heroCell2.name = viewNode:getChildAutoType('rightpos/heroCell2/name')--GTextField
			self.rightpos.heroCell2.severName = viewNode:getChildAutoType('rightpos/heroCell2/severName')--GTextField
	self.spineNode = viewNode:getChildAutoType('spineNode')--GLoader
	self.spineNode1 = viewNode:getChildAutoType('spineNode1')--GLoader
	--{autoFieldsEnd}:CrossPVP.CrossFightAnimationView
	--Do not modify above code-------------
end

function CrossFightAnimationView:_initUI()
	self:_initVM()
	self.blackbg:addClickListener(function()
		self:closeView()
		CrossPVPModel:fightBegin(self._args)
	end)

	local hero = BindManager.bindPlayerCell(self.fightLeft.heroCell1.heroCell)
	hero:setHead(PlayerModel.head, PlayerModel.level,nil,nil,nil)
	self.fightLeft.heroCell1.name:setText(PlayerModel.username)
	self.fightLeft.heroCell1.severName:setText(CrossPVPModel:getSeverName(LoginModel:getUnitServerId()))

	local data = CrossPVPModel:getMatchingPlayer()
	local hero1 = BindManager.bindPlayerCell(self.fightRight.heroCell2.heroCell)
	hero1:setHead(data.pkInfo.head, data.pkInfo.level,nil,nil,nil)
	self.fightRight.heroCell2.name:setText(data.pkInfo.name)
	self.fightRight.heroCell2.severName:setText(CrossPVPModel:getSeverName(data.pkInfo.serverId))
	

	local time = 0.3
	local node1 = self.fightLeft:displayObject()
	local initX = self.leftpos:displayObject():getPositionX()
	local arr = {}
	table.insert(arr,cc.DelayTime:create(0.3))
	table.insert(arr,cc.EaseOut:create(cc.MoveTo:create(time,cc.p(initX,node1:getPositionY())),time))
	table.insert(arr,cc.CallFunc:create(function()
		SpineUtil.createSpineObj(self.spineNode, vertex2(3,0), "ty_vs_baozha", "Spine/ui/CrossPVP", "tianyushilian_texiao", "tianyushilian_texiao",false)
		SpineUtil.createSpineObj(self.spineNode, vertex2(0,0), "ty_vs_xunhuan", "Spine/ui/CrossPVP", "tianyushilian_texiao", "tianyushilian_texiao",true)
		SpineUtil.createSpineObj(self.spineNode1, vertex2(0,0), "ty_ppcg", "Spine/ui/CrossPVP", "tianyushilian_texiao", "tianyushilian_texiao",true)
	end))
	node1:runAction(cc.Sequence:create(arr))

	local node2 = self.fightRight:displayObject()
	local initX = self.rightpos:displayObject():getPositionX()
	local arr1 = {}
	table.insert(arr1,cc.DelayTime:create(0.3))
	table.insert(arr1,cc.EaseOut:create(cc.MoveTo:create(time,cc.p(initX,node1:getPositionY())),time))
	table.insert(arr1,cc.DelayTime:create(3))
	table.insert(arr1,cc.CallFunc:create(function()
		self:closeView()
		CrossPVPModel:fightBegin(self._args)
	end))
	node2:runAction(cc.Sequence:create(arr1))

	
	

	self:_refreshView()
end


function CrossFightAnimationView:_refreshView()

end

function CrossFightAnimationView:onExit_()

end

return CrossFightAnimationView