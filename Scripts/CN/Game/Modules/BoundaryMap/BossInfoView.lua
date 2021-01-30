local BossInfoView = class("BossInfoView",Window)
function BossInfoView:ctor(args)
 	self._packName 	= "BoundaryMap"
 	self._compName 	= "BossInfoView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
	self.firstAward = false
	self.starReward = false
	self.skillObjList = {}
	self.skillSelectList = {}
	self.layer = args.layer
	self.difficulty = args.difficulty
	self.starIndex = 0
	self.bttleResult = false
	self.skillsList = false
	self.t_BoundaryNode = BoundaryMapModel:getBoundaryNode()
	self.fightId = self.t_BoundaryNode[self.layer].nodeBoss
	self.lastSelectDif = -1
end
function BossInfoView:_initUI()
	self.view:getChildAutoType("closeBtn"):addClickListener(function()
		self:closeView()
	end)

	self.awardList = self.view:getChildAutoType("$awardList")
	self.awardList:setItemRenderer(handler(self,self.awardListHandle))

	self.awardList1 = self.view:getChildAutoType("$awardList1")
	self.awardList1:setItemRenderer(handler(self,self.awardList1Handle))

	self.skillListObj = self.view:getChildAutoType("skillList")
	self.skillListObj:setItemRenderer(handler(self,self.skillListHandle))

	self.starListObj = self.view:getChildAutoType("starList")
	self.starListObj:setItemRenderer(handler(self,self.starListObjHandle))

	self.spineLoad = self.view:getChildAutoType("spineLoad")
	
	self.skills = self.view:getChildAutoType("_GList$skills")
	self.skills:setItemRenderer(handler(self,self.skillsListObjHandle))
	
	self.str_layer = self.view:getChildAutoType("str_layer")
	self.str_layer:setText(string.format(Desc.Boundary_desc1,self.layer))
	self.dif_str = self.view:getChildAutoType("dif_str")
	self.btn_right = self.view:getChildAutoType("btn_right")
	self.already_star = self.view:getChildAutoType("already_star")
	self.goBtn = self.view:getChildAutoType("$goBtn")

	local strongLevel = BoundaryMapModel:getBossStrongByLayer(#self.t_BoundaryNode)
	self.goBtn:addClickListener(function()
		local index = 0
		local node = BoundaryMapModel:getRouteNode()
		for key,roud in pairs(node) do
			if roud.pos >= 4 then
				index = key
			end
		end
		if index == 0 then return RollTips.show(Desc.Boundary_desc6) end
		Dispatcher.dispatchEvent(EventType.battle_requestFunc,function(eventName)
			if eventName == "begin" then
				local arg = {layerId = self.layer,node = index,boosId = self.boundaryNodeData.bossid}
				RPCReq.Boundary_Battle(arg,function(data)
					if tolua.isnull(self.view) then return end
					self.bttleResult = data.bttleResult
					if data.bttleResult then
						BoundaryMapModel:setMonsterMark()
						self:initBossInfo_Data()
						Dispatcher.dispatchEvent("boss_refush")
					end
					if self.bttleResult then
						self:closeView()
					end
				end)
			end
			if eventName=="end" then
				local function closefuc()
					if self.bttleResult and self.layer == #self.t_BoundaryNode and strongLevel == -1 then
						ViewManager.open("ClearanceView")
					end	
				end
				local reward = clone(ModelManager.PlayerModel:get_awardData(GameDef.GamePlayType.Boundary))
				if type(reward) == "boolean" then reward = {} end
				PlayerModel:set_awardByType(GameDef.GamePlayType.Boundary,{})
				ViewManager.open("ReWardView",{
					data = reward or {},
					isWin = self.bttleResult,
					page = 4,
					showNoReward = true,
					closefuc = closefuc,
				})
			end 
		end,{
			fightID = self.fightId,
			configType = GameDef.BattleArrayType.Boundary,
		})
	end)
	self.btn_history = self.view:getChildAutoType("btn_history")
	self.btn_history:addClickListener(function()
		ViewManager.open("CustomsRecordView")
	end)
	self.btn_skill = self.view:getChildAutoType("btn_skill")
	self.btn_skill:addClickListener(function()
		ViewManager.open("SkillPreviewView")
	end)

	self.btn_right:addClickListener(function()
		self.starIndex = self.starIndex + 1
		self.btn_left:setTouchable(true)
		self.btn_left:setGrayed(false)
		if self.starIndex >= 3 then
			self.starIndex = 3
			self.btn_right:setTouchable(false)
			self.btn_right:setGrayed(true)
		end
		self:refreshDiff()
	end)
	self.btn_left = self.view:getChildAutoType("btn_left")
	self.btn_left:addClickListener(function()
		self.starIndex = self.starIndex - 1
		self.btn_right:setTouchable(true)
		self.btn_right:setGrayed(false)
		if self.starIndex <= 0 then
			self.starIndex = 0
			self.btn_left:setTouchable(false)
			self.btn_left:setGrayed(true)
		end
		self:refreshDiff()
	end)
	self.skillListObj:setData(BoundaryMapModel:getBossBuff())
	self:initBossInfo_Data()
end

function BossInfoView:initBossInfo_Data()
	self.starIndex,self.strongLevel,self.skillSelectList = BoundaryMapModel:getBossStrongData()
	if self.starIndex <= 0 then
		self.btn_left:setTouchable(false)
		self.btn_left:setGrayed(true)
	elseif self.starIndex >= 3 then
		self.btn_right:setTouchable(false)
		self.btn_right:setGrayed(true)
	end
	self.view:getController("firstReward"):setSelectedIndex(self.strongLevel ~= -1 and 1 or 0)
	for key,value in pairs(self.skillSelectList) do
		if value == self.skillObjList[key].skillIndex then
			self.skillObjList[key]:getController("state"):setSelectedIndex(1)
		end	
	end
	self.boundaryReward = BoundaryMapModel:getBoundaryReward()[self.difficulty][self.layer]
	self.boundaryNodeData = BoundaryMapModel:getBoundaryNode()[self.layer]
	self.firstAward = self.boundaryReward.bossReward

	--------------------------------
	self.awardList:setData(self.firstAward)
	if self.strongLevel == -1 then
		self.already_star:setVisible(false)
	else
		self.already_star:setText(string.format(Desc.Boundary_desc4,self.strongLevel))
	end
	self.spineLoad:displayObject():removeAllChildren()
	local skeletonNode = SpineMnange.createSprineById(self.boundaryNodeData.bossid,false)
	skeletonNode:setAnimation(0, "stand", true);
	local size = self.spineLoad:getSize()
	skeletonNode:setPosition(size.width / 2,0)
	self.spineLoad:displayObject():addChild(skeletonNode)
	local t_fight = DynamicConfigData.t_fight
	local monster = DynamicConfigData.t_monster[self.boundaryNodeData.bossid]--读表的数据
	self.view:getChildAutoType("boss_name"):setText("LV."..t_fight[self.fightId]["level1"].."  "..monster.name)
	self.view:getChildAutoType("cardcategoryIcon"):setURL(PathConfiger.getCardCategoryColor(monster.category))
	--------------------------------

	local monster = DynamicConfigData.t_monster[self.boundaryNodeData.bossid]--读表的数据
	self.skillsList = monster.skill
	self.skills:setData(self.skillsList)

	self:refreshDiff(1)
end
function BossInfoView:refreshDiff(state)
	self:refreshReward()
	self.dif_str:setText("lv."..self.starIndex)
	local starData = {0,0,0,0,0,0}
	for i = 1,self.starIndex + #self.skillSelectList do
		starData[i] = 1
	end
	self.starListObj:setData(starData)
	self.lastSelectDif = self.starIndex + #self.skillSelectList
	if not state then
		local arg = {layerId = self.layer,value = self.starIndex,bossSkill = self.skillSelectList}
		RPCReq.Boundary_SetBossDifficult(arg,function(info)
			BoundaryMapModel:setBossDifficult(info.data,self.layer)
		end)
	end
end
function BossInfoView:getStarReward()
	self.starReward = {}
	if self.starIndex + #self.skillSelectList <= self.strongLevel then return end
	local startIndexReward = self.strongLevel <= 0 and 1 or self.strongLevel + 1
	for i = startIndexReward,self.starIndex + #self.skillSelectList do
		local info = clone(self.boundaryReward["reward"..i])
		for k,v in pairs(info) do
			local state = false
			for l,m in pairs(self.starReward) do
				if m.code == v.code and m.type == v.type then
					m.amount = m.amount + v.amount 
					state = true
				end
			end
			if not state then
				table.insert(self.starReward,v)
			end
		end
	end
end
function BossInfoView:refreshReward()
	self:getStarReward()
	if #self.starReward ~= 0 then
		self.awardList1:setData(self.starReward)
		self.view:getController("rewardState"):setSelectedIndex(0)
	else
		self.view:getController("rewardState"):setSelectedIndex(1)
	end
end

function BossInfoView:awardListHandle(index, obj)
	local itemcell = BindManager.bindItemCell(obj)
	local itemData = ItemsUtil.createItemData({data = self.firstAward[index  + 1]})
	itemcell:setItemData(itemData)

end
function BossInfoView:awardList1Handle(index, obj)
	local itemcell = BindManager.bindItemCell(obj)
	local itemData = ItemsUtil.createItemData({data = self.starReward[index  + 1]})
	itemcell:setItemData(itemData)
end

function BossInfoView:skillListHandle(index, obj)
	local t_skill = DynamicConfigData.t_skill
	local skill = t_skill[self.skillListObj._dataTemplate[index + 1]]
	obj:setText(skill.skillName)
	obj.skillIndex = self.skillListObj._dataTemplate[index + 1]
	local skillCellObj = obj:getChild("skillCell")
	local skillCell = BindManager.bindSkillCell(skillCellObj)
	skillCell:setData(skill.skillId)
	skillCellObj:addClickListener(function()
		ViewManager.open("ItemTips", {codeType = CodeType.SKILL, id = self.skillListObj._dataTemplate[index + 1],data = skill})
	end,99)
	obj:getChild("touch"):addClickListener(function()
		obj:getController("state"):setSelectedIndex(obj:getController("state"):getSelectedIndex() == 0 and 1 or 0)
		self.skillSelectList = {}
		for key,value in pairs(self.skillObjList) do
			if value:getController("state"):getSelectedIndex() == 1 then
				table.insert(self.skillSelectList,self.skillListObj._dataTemplate[key])
			end
		end
		self:refreshDiff()
	end,99)
	table.insert(self.skillObjList,obj)
end
function BossInfoView:skillsListObjHandle(index,obj)
    obj:removeClickListener(100)
    obj:addClickListener(function(context)
        local skillInfo = false
		skillInfo = DynamicConfigData.t_skill[self.skillsList[index + 1]]
		local monster = DynamicConfigData.t_monster[self.boundaryNodeData.bossid]--读表的数据
		local array = {
			codeType = CodeType.SKILL, 
			id = self.skillsList[index + 1], 
			heroId = monster.model
		}
		ViewManager.open("ItemTips", array)
    end,100)
	local skillCellObj = obj:getChild("skillCell")
	local skillCell = BindManager.bindSkillCell(skillCellObj)
	skillCell:setData(self.skillsList[index + 1])
end
function BossInfoView:starListObjHandle(index, obj)
	if self.lastSelectDif ~= - 1 and self.starIndex + #self.skillSelectList > self.lastSelectDif  and index + 1 == self.starIndex + #self.skillSelectList then
		local node = obj:getChildAutoType("icon"):displayObject()
		node:setScale(20)
		node:setOpacity(0)
		node:stopAllActions()
		local arr = {}
		table.insert(arr,cc.ScaleTo:create(0.25,1))
		table.insert(arr,cc.FadeIn:create(0.1))
		local action = cc.Sequence:create({cc.Spawn:create(arr),cc.CallFunc:create(function()
		
		end)})
		node:runAction(action)
	end
	obj:getController("state"):setSelectedIndex(self.starListObj._dataTemplate[index + 1])
end
function BossInfoView:_exit()
end
return BossInfoView