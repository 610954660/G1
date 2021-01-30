local FightInfoView = class("FightInfoView",Window)
function FightInfoView:ctor(args)
 	self._packName 	= "BoundaryMap"
 	self._compName 	= "FightInfoView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
	self.layer = args.layer
	self.difficulty = args.difficulty

	self.showReward = false
	self.bttleResult = false
	self.showData = false
	self.arg = args
	self.roud = args.roud
	
	self.battleArrayType = {}
	
	self.battleArrayType[1] = GameDef.BattleArrayType.BoundaryAssassin 	--刺客路
	self.battleArrayType[2] = GameDef.BattleArrayType.BoundaryStriker 	--射手路
	self.battleArrayType[3] = GameDef.BattleArrayType.BoundaryWarrior 	--战士路
	self.battleArrayType[4] = GameDef.BattleArrayType.BoundaryMage 	--法师路
	self.battleArrayType[5] = GameDef.BattleArrayType.Boundary 	--boss路
end
function FightInfoView:_initUI()
	self.roadCareer = BoundaryMapModel:getRoadCareer(self.roud)
	self.fightList = self.view:getChildAutoType("$list")
	self.view:getChildAutoType("closeBtn"):addClickListener(function()
		self:closeView()
	end)
	self.fightList:setItemRenderer(handler(self,self.monsetHandle))
	self.tittle = self.view:getChildAutoType("tittle")
	self.tittle:setText(string.format(Desc.Boundary_desc9,GuildModel:getGuildskillTypeName(self.roadCareer[1]),self.arg.index))


	self.windows = self.view:getChildAutoType("windows")
	self.tittle = self.windows:getChildAutoType("title")
	self.tittle:setText(string.format(Desc.Boundary_desc1,self.layer))
	self.awardList = self.view:getChildAutoType("$awardList")
	self.awardList:setItemRenderer(handler(self,self.awardListHandle))

	self.t_BoundaryNode = BoundaryMapModel:getBoundaryNode()
	self.t_BoundaryReward = BoundaryMapModel:getBoundaryReward()

	self:showFightInfo(self.arg.roud,self.arg.index)

	

	self.goBtn = self.view:getChildAutoType("$goBtn")
	self.goBtn:addClickListener(function()
		local node = false
		Dispatcher.dispatchEvent(EventType.battle_requestFunc,function( eventName )
			   	if eventName == "begin" then
					local arg = {layerId = self.arg.layer,node = self.arg.roud}
					RPCReq.Boundary_Battle(arg,function(data)
						self.bttleResult = data.bttleResult
						if data.bttleResult then
							self:closeView()
							BoundaryMapModel:setRouteNodeSucces(data.node)
						end
						node = data.node
					end)
				end
				if eventName=="end" then
					local function closefuc()
						if next(BoundaryMapModel:getBlessing()) then
							ViewManager.open("BlessingSelectView")
						end
						if self.bttleResult then
							Dispatcher.dispatchEvent("nodeMonster_refrush",node)
						end
					end
					local reward = clone(ModelManager.PlayerModel:get_awardData(GameDef.GamePlayType.Boundary))
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
				configType = self.battleArrayType[self.roud],--GameDef.BattleArrayType.Boundary,
				vocation = self.roadCareer or {},
				vocationLimit = true,
			})--fightID 战斗场景 
	end)
	self.str_career = self.view:getChildAutoType("str_career")
	self.str_career:setText(string.format(Desc.Boundary_desc8,
	GuildModel:getGuildskillTypeName(self.roadCareer[1]),
	GuildModel:getGuildskillTypeName(self.roadCareer[2]),
	GuildModel:getGuildskillTypeName(self.roadCareer[3])))
end
function FightInfoView:awardListHandle(index, obj)
	local itemcell = BindManager.bindItemCell(obj)
	local itemData = ItemsUtil.createItemData({data = self.showReward[index  + 1]})
	itemcell:setItemData(itemData)

end
function FightInfoView:monsetHandle(index, obj)
	local heroCell = BindManager.bindHeroCell(obj)
	heroCell:setData(self.showData[index + 1])
end
function FightInfoView:showFightInfo(i,j)
	self.showData = {}
	local t_fight = DynamicConfigData.t_fight
	self.view:setVisible(true)
	self.fightId = self.t_BoundaryNode[self.layer]["node"..i][j]
	
	local data = {}
	for k = 1,#t_fight[self.fightId].monsterStand do
		local i = t_fight[self.fightId].monsterStand[k]
		local config = DynamicConfigData.t_monster[t_fight[self.fightId]["monsterId"..i]]
		local showData = {}
		showData.code = config.monsterId
		showData.level = t_fight[self.fightId]["level"..i]
		showData.star = t_fight[self.fightId]["star"..i]
		showData.category = config.category
		table.insert(self.showData,showData)
	end
	self.fightList:setData(self.showData)
	self.showReward = self.t_BoundaryReward[self.difficulty][self.layer].monsterReward
	self.awardList:setData(self.showReward)
end
function FightInfoView:_exit()
end
return FightInfoView