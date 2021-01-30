--Date :2021-01-03
--Author : added by xhd
--Desc : 巅峰赛排行

local StridePVPRankView,Super = class("StridePVPRankView", Window)

function StridePVPRankView:ctor()
	--LuaLog("StridePVPRankView ctor")
	self._packName = "StrideServer"
	self._compName = "StridePVPRankView"
	self._rootDepth = LayerDepth.PopWindow
	self.data = false
end

function StridePVPRankView:_initEvent( )
	
end

function StridePVPRankView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:StrideServer.StridePVPRankView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.list_rank = viewNode:getChildAutoType('list_rank')--GList
	self.myRankItem = viewNode:getChildAutoType('myRankItem')--rankItem
		self.myRankItem.allzanNum = viewNode:getChildAutoType('myRankItem/allzanNum')--GTextField
		self.myRankItem.bgMask = viewNode:getChildAutoType('myRankItem/bgMask')--GLoader
		self.myRankItem.heroCell = viewNode:getChildAutoType('myRankItem/heroCell')--GButton
		self.myRankItem.rankIconLoader = viewNode:getChildAutoType('myRankItem/rankIconLoader')--GLoader
		self.myRankItem.score = viewNode:getChildAutoType('myRankItem/score')--GTextField
		self.myRankItem.txt_myRankTitle = viewNode:getChildAutoType('myRankItem/txt_myRankTitle')--GTextField
		self.myRankItem.txt_name = viewNode:getChildAutoType('myRankItem/txt_name')--GTextField
		self.myRankItem.txt_noRank = viewNode:getChildAutoType('myRankItem/txt_noRank')--GTextField
		self.myRankItem.txt_power = viewNode:getChildAutoType('myRankItem/txt_power')--GTextField
		self.myRankItem.txt_rank = viewNode:getChildAutoType('myRankItem/txt_rank')--GTextField
		self.myRankItem.zanBtn = viewNode:getChildAutoType('myRankItem/zanBtn')--GButton
	self.rankCtrl = viewNode:getController('rankCtrl')--Controller
	self.txt_integralTitle = viewNode:getChildAutoType('txt_integralTitle')--GTextField
	self.txt_playerInfoTitle = viewNode:getChildAutoType('txt_playerInfoTitle')--GTextField
	self.txt_rankTitle = viewNode:getChildAutoType('txt_rankTitle')--GTextField
	--{autoFieldsEnd}:StrideServer.StridePVPRankView
	--Do not modify above code-------------
end

function StridePVPRankView:_initListener( )
	
	self.list_rank:setItemRenderer(function(index, obj)

	end)

end

function StridePVPRankView:_initUI( )
	self:_initVM()
	self:_initListener()
	StrideServerModel:reqRankListData()
end

function StridePVPRankView:update_stride_rank()
	self:refreshPanel()
end

function StridePVPRankView:refreshPanel()
	self.data = StrideServerModel:getRankListData()
	self.txt_rankTitle:setText(Desc.CrossTeamPVP_rankTitle)
	self.txt_playerInfoTitle:setText(Desc.CrossTeamPVP_playerInfoTitle)
	self.txt_integralTitle:setText("赛区选拔分数")
    self.list_rank:setVirtual()
	self.list_rank:setItemRenderer(function(idx,obj)
		local index = idx + 1
		local data = self.list_rank._dataTemplate[index] 
		local txt_rank = obj:getChildAutoType("txt_rank") --排名
		local heroCell = BindManager.bindPlayerCell( obj:getChildAutoType("heroCell"))
		local txt_name = obj:getChildAutoType("txt_name")
		local txt_power = obj:getChildAutoType("txt_power")

		local score = obj:getChildAutoType("score") --积分
		local allzanNum = obj:getChildAutoType("allzanNum") --总点赞数

		local rankCtrl 	= obj:getController("rankCtrl") 	-- 排名 4 除了前三以外的排名
		local haveRankCtrl 	= obj:getController("haveRankCtrl") 	-- 0没排名 1有排名
		local isMeCtrl 	= obj:getController("isMe") 	-- 是否是自己
		local zanCtrl = obj:getController("zanCtrl")

		haveRankCtrl:setSelectedIndex(1)
		isMeCtrl:setSelectedIndex(0)
		rankCtrl:setSelectedIndex((index <=3) and index or 4) --段位前4
	
		if data then
			txt_rank:setText(data.rank)
			heroCell:setHead(data.head,data.level,data.id,nil,data.headBorder) 
			txt_name:setText(data.name)
			txt_power:setText(string.format(Desc.CrossTeamPVP_power,StringUtil.transValue(data.combat or 0))) 
			score:setText(data.value)
			allzanNum:setText(data.exParam.param1)
		end

		obj:getChildAutoType("heroCell"):removeClickListener(100)
		obj:getChildAutoType("heroCell"):addClickListener(function(context) 
			context:stopPropagation()--阻止事件冒泡
			if data.id<0 then
				RollTips.show(Desc.Friend_cant_show)
				return
			end
			printTable(1,">>>data.serverId>>>>",data.serverId)
			ViewManager.open("ViewPlayerView",{playerId = data.id,serverId=data.serverId,arrayType = GameDef.BattleArrayType.TopArenaAckOne})
		end,100)
		if  StrideServerModel:checkInLikeList(data.id) then
			zanCtrl:setSelectedIndex(1)
		else
			zanCtrl:setSelectedIndex(0)
		end
		
		local zanBtn = obj:getChildAutoType("zanBtn")
		zanBtn:removeClickListener(100)
		zanBtn:addClickListener(function()
			if data.id == PlayerModel.userid then
				RollTips.show("不能为自己点赞")
				return
			end
			RPCReq.TopArena_Like({zoneId=StrideServerModel:getCurSelectZone(),playerId=data.id,serverId=data.serverId},function(params)
				if next(params) then
				    if tolua.isnull(self.view) then return end
					allzanNum:setText(data.exParam.param1+1)
					zanCtrl:setSelectedIndex(1)
					--顺便修改缓存数据
					StrideServerModel:modifyLikeListAndTimes(params.likeList,params.likeTimes)
					StrideServerModel:modifyRankdata(data.id,params.totalLike)
				end
			end)
		end,100)
	end)

	local rankData = self.data.rankData
	local myRankData = self.data.myRankData
	local inRank = self.data.inRank --是否在排行
	self.list_rank:setData(rankData)  
	self.rankCtrl:setSelectedIndex(TableUtil.GetTableLen(rankData) >0 and 0 or 1)
	self:setMyRankInfo(inRank,myRankData)
end

-- 我自己的排名信息
function StridePVPRankView:setMyRankInfo(inRank,myRankData,myRank)
	local item = self.myRankItem
	local rankCtrl 	= item:getController("rankCtrl") 	-- 排名 4 除了前三以外的排名
	local haveRankCtrl 	= item:getController("haveRankCtrl") 	-- 0没排名 1有排名
	local isMeCtrl 	= item:getController("isMe") 		-- 0 不是自己 1 是自己

	haveRankCtrl:setSelectedIndex(inRank and 1 or 0)
	isMeCtrl:setSelectedIndex(1)
	rankCtrl:setSelectedIndex(4)
	item.txt_rank:setText(myRankData.rank) 
	local heroCell = BindManager.bindPlayerCell(item.heroCell)
	heroCell:setHead(PlayerModel.head,PlayerModel.level,tonumber(PlayerModel.userid),nil,PlayerModel.headBorder) 

	item.txt_name:setText(PlayerModel.username) 
	item.txt_power:setText(string.format(Desc.CrossTeamPVP_power,StringUtil.transValue(myRankData.combat or 0)))
	item.score:setText(myRankData.value or 0)
	item.allzanNum:setColor({r=255,g=255,b=255})
	if myRankData.exParam and myRankData.exParam.param1>0 then
		item.allzanNum:setText(myRankData.exParam.param1)
	else
		item.allzanNum:setText(0)
	end
	

	item.heroCell:removeClickListener()
	item.heroCell:addClickListener(function(context) 
		context:stopPropagation()--阻止事件冒泡
		ViewManager.open("ViewPlayerView",{playerId = tonumber(PlayerModel.userid),serverId = LoginModel:getUnitServerId(),arrayType = GameDef.BattleArrayType.TopArenaAckOne})
	end)

	local zanBtn = item:getChildAutoType("zanBtn")
	zanBtn:removeClickListener(100)
	zanBtn:addClickListener(function()
		RollTips.show("不可为自己点赞")
	end)
end


return StridePVPRankView