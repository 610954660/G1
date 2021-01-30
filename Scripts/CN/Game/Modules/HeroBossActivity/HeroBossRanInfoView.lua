local HeroBossRanInfoView, Super = class("HeroBossRanInfoView", Window)
function HeroBossRanInfoView:ctor(args)
	self._packName = "HeroBossActivity"
	self._compName = "HeroBossRanInfoView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
	self.moduleId = HeroBossActivityModel:getModuleId()
	self.t_ActivityRankReward = DynamicConfigData.t_ActivityRankReward[GameDef.ActivityType.NewHeroCopy][self.moduleId]
end

function HeroBossRanInfoView:_initUI()
	self.btn_go = self.view:getChildAutoType("closeButton")
	self.btn_go:addClickListener(function()
		self:closeView()
	end)
	self.list = self.view:getChildAutoType("list")
	self.list:setItemRenderer(handler(self,self.listHandle))
	RPCReq.Rank_GetRankData({rankType = GameDef.RankType.NewHeroCopy}, function(data)
		self.list:setData(data.rankData)
		local obj = self.view:getChildAutoType("myItem")
		obj:getChild("name"):setText(data.myRankData.name)
		local fight = ModelManager.CardLibModel:getFightVal() or 0
		obj:getChild("str_zhanli"):setText(StringUtil.transValue(fight))
		obj:getChild("btn_record"):addClickListener(function()
		    BattleModel:requestBattleRecord(data.myRankData.battleId)
		end)
		obj:getChild("playerIcon"):setURL(PlayerModel:getUserHeadURL(data.myRankData.head))
		obj:getChild("maxNum"):setText(data.myRankData.value)

		local reward = {}
		local myRank = -1
		local boxNum = "X"..0
		for key,value in pairs(data.rankData) do
			if value.id == data.myRankData.id then
				myRank = key
				data.myRankData.battleId = value.battleId
				boxNum = "X"..HeroBossActivityModel:getBoxNum(value.value)
			end
		end
		obj:getController("hasRecord"):setSelectedIndex(data.myRankData.battleId and 0 or 1)
		for key,value in pairs(self.t_ActivityRankReward) do
			if myRank >= value.min and myRank <= value.max then
				reward = value.reward
			end
		end
		local awardList = obj:getChildAutoType("$awardList")
		awardList:setItemRenderer(function(index, obj)
			local itemcell = BindManager.bindItemCell(obj)
			local itemData = ItemsUtil.createItemData({data = reward[index  + 1]})
			itemcell:setItemData(itemData)
			obj:getChild("num"):setFontSize(20)
		end)
		awardList:setData(reward)
		if not next(reward) then
			awardList:setVisible(false)
		end
		obj:getChild("index"):setText(myRank == -1 and Desc.HeroBossActivityDesc2 or myRank)
		obj:getChild("num"):setText(boxNum)
	end)

end
function HeroBossRanInfoView:listHandle(index, obj)
	obj:getChild("name"):setText(self.list._dataTemplate[index + 1].name)
	obj:getChild("str_zhanli"):setText(StringUtil.transValue(self.list._dataTemplate[index + 1].combat))
	obj:getChild("btn_record"):addClickListener(function()
		BattleModel:requestBattleRecord(self.list._dataTemplate[index + 1].battleId)
	end,999)
	obj:getChild("playerIcon"):addClickListener(function()
		ViewManager.open("ViewPlayerView",{playerId = self.list._dataTemplate[index + 1].id})
	end,99)
	obj:getChild("playerIcon"):setURL(PlayerModel:getUserHeadURL(self.list._dataTemplate[index + 1].head))
	obj:getChild("maxNum"):setText(self.list._dataTemplate[index + 1].value)
	obj:getChild("index"):setText(index + 1)
	local reward = {}
	for key,value in pairs(self.t_ActivityRankReward) do
		if index + 1 >= value.min and index + 1 <= value.max then
			reward = value.reward
		end
	end
	local awardList = obj:getChildAutoType("$awardList")
	awardList:setItemRenderer(function(index, obj)
		local itemcell = BindManager.bindItemCell(obj)
		local itemData = ItemsUtil.createItemData({data = reward[index  + 1]})
		itemcell:setItemData(itemData)
		obj:getChild("num"):setFontSize(20)
	end)
	awardList:setData(reward)
	local rankIcon = obj:getChild("rankIcon")
	rankIcon:setURL(string.format("%s%s.png","UI/Rank/Rank_img_",index  + 1))

	obj:getController("rankState"):setSelectedIndex(index + 1 <= 3 and 0 or 1)
	obj:getController("indexSelect"):setSelectedIndex(index + 1 <= 3 and index or 3)
	obj:getChild("num"):setText("X"..HeroBossActivityModel:getBoxNum(self.list._dataTemplate[index + 1].value))
end
function HeroBossRanInfoView:_exit()
end
return HeroBossRanInfoView