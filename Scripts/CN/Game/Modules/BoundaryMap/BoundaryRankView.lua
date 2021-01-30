local BoundaryRankView,Super = class("BoundaryRankView", Window)

function BoundaryRankView:ctor(args)
	self._packName = "BoundaryMap"
	self._compName = "BoundaryRankView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
	
	self.difficulty = args.difficulty
end

function BoundaryRankView:_initEvent()
	
end

function BoundaryRankView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:BoundaryMap.BoundaryRankView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.effet_str = viewNode:getChildAutoType('effet_str')--GRichTextField
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.list = viewNode:getChildAutoType('list')--GList
	self.myItem = viewNode:getChildAutoType('myItem')--myItem
		self.myItem.index = viewNode:getChildAutoType('myItem/index')--GRichTextField
		self.myItem.name = viewNode:getChildAutoType('myItem/name')--GRichTextField
		self.myItem.num1 = viewNode:getChildAutoType('myItem/num1')--GRichTextField
		self.myItem.num2 = viewNode:getChildAutoType('myItem/num2')--GRichTextField
		self.myItem.num3 = viewNode:getChildAutoType('myItem/num3')--GRichTextField
		self.myItem.playerIcon = viewNode:getChildAutoType('myItem/playerIcon')--GLoader
		self.myItem.str_zhanli = viewNode:getChildAutoType('myItem/str_zhanli')--GTextField
	self.noDataCtrl = viewNode:getController('noDataCtrl')--Controller
	--{autoFieldsEnd}:BoundaryMap.BoundaryRankView
	--Do not modify above code-------------
end

function BoundaryRankView:_initUI()
	self:_initVM()
	
	self.list:setItemRenderer(handler(self,self.listHandle))
	RPCReq.Rank_GetRankData({rankType = GameDef.RankType.Boundary}, function(data)
		self.list:setData(data.rankData)
		self.noDataCtrl:setSelectedIndex(next(data.rankData) and 1 or 0)

		local myRank = -1
		for key,value in pairs(data.rankData) do
			if value.id == data.myRankData.id then
				myRank = key
				data.myRankData = value
			end
		end
		local obj = self.view:getChildAutoType("myItem")
		obj:getChild("name"):setText(data.myRankData.name)
		local fight = ModelManager.CardLibModel:getFightVal() or 0
		obj:getChild("str_zhanli"):setText(StringUtil.transValue(fight))
		obj:getChild("playerIcon"):setURL(PlayerModel:getUserHeadURL(data.myRankData.head))
		obj:getChild("num1"):setText(data.myRankData.value or 0)
		obj:getChild("num2"):setText(data.myRankData.exParam and data.myRankData.exParam.param1 or 0)
		obj:getChild("num3"):setText(data.myRankData.exParam and data.myRankData.exParam.param2 or 0)
		obj:getChild("index"):setText(myRank == -1 and Desc.HeroBossActivityDesc2 or myRank)
	end)
	self:_refreshView()
	
	if self.difficulty ~= table.nums(DynamicConfigData.t_BoundaryNode) then
		local config = DynamicConfigData.t_BoundaryDifficulty[self.difficulty + 1].unlock
		self.effet_str:setText(string.format(Desc.Boundary_desc14,config[1],config[2]))
	else
		self.effet_str:setText(Desc.Boundary_desc15)
	end
end

function BoundaryRankView:listHandle(index, obj)
	local data = self.list._dataTemplate[index + 1]
	obj:getChild("name"):setText(data.name)
	obj:getChild("str_zhanli"):setText(StringUtil.transValue(data.combat))
	obj:getChild("playerIcon"):addClickListener(function()
		ViewManager.open("ViewPlayerView",{playerId = data.id})
	end,99)
	obj:getChild("index"):setText(index + 1)
	obj:getChild("num1"):setText(data.value or 0)
	obj:getChild("num2"):setText(data.exParam and data.exParam.param1 or 0)
	obj:getChild("num3"):setText(data.exParam and data.exParam.param2 or 0)
	local rankIcon = obj:getChild("rankIcon")
	rankIcon:setURL(string.format("%s%s.png","UI/Rank/Rank_img_",index  + 1))
	obj:getChild("playerIcon"):setURL(PlayerModel:getUserHeadURL(data.head))
	obj:getController("rankState"):setSelectedIndex(index + 1 <= 3 and 0 or 1)
	obj:getController("indexSelect"):setSelectedIndex(index + 1 <= 3 and index or 3)
end
function BoundaryRankView:_refreshView()

end

function BoundaryRankView:onExit_()

end

return BoundaryRankView