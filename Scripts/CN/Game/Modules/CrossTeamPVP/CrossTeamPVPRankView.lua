--Date :2020-12-09
--Author : wyz
--Desc : 排行榜

local CrossTeamPVPRankView,Super = class("CrossTeamPVPRankView", Window)

function CrossTeamPVPRankView:ctor()
	--LuaLog("CrossTeamPVPRankView ctor")
	self._packName = "CrossTeamPVP"
	self._compName = "CrossTeamPVPRankView"
	self._rootDepth = LayerDepth.PopWindow
	
	self.rankData = {}
	self.myRankData = {}
end

function CrossTeamPVPRankView:_initEvent( )
	
end

function CrossTeamPVPRankView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossTeamPVP.CrossTeamPVPRankView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.list_rank = viewNode:getChildAutoType('list_rank')--GList
	self.myRankItem = viewNode:getChildAutoType('myRankItem')--rankItem
		self.myRankItem.bgMask = viewNode:getChildAutoType('myRankItem/bgMask')--GLoader
		self.myRankItem.danIconLoader = viewNode:getChildAutoType('myRankItem/danIconLoader')--GLoader
		self.myRankItem.heroCell = viewNode:getChildAutoType('myRankItem/heroCell')--GButton
		self.myRankItem.rankIconLoader = viewNode:getChildAutoType('myRankItem/rankIconLoader')--GLoader
		self.myRankItem.txt_danName = viewNode:getChildAutoType('myRankItem/txt_danName')--GRichTextField
		self.myRankItem.txt_integral = viewNode:getChildAutoType('myRankItem/txt_integral')--GTextField
		self.myRankItem.txt_myRankTitle = viewNode:getChildAutoType('myRankItem/txt_myRankTitle')--GTextField
		self.myRankItem.txt_name = viewNode:getChildAutoType('myRankItem/txt_name')--GTextField
		self.myRankItem.txt_noDan = viewNode:getChildAutoType('myRankItem/txt_noDan')--GTextField
		self.myRankItem.txt_noRank = viewNode:getChildAutoType('myRankItem/txt_noRank')--GTextField
		self.myRankItem.txt_percent = viewNode:getChildAutoType('myRankItem/txt_percent')--GTextField
		self.myRankItem.txt_power = viewNode:getChildAutoType('myRankItem/txt_power')--GTextField
		self.myRankItem.txt_rank = viewNode:getChildAutoType('myRankItem/txt_rank')--GTextField
	self.rankCtrl = viewNode:getController('rankCtrl')--Controller
	self.txt_danTitle = viewNode:getChildAutoType('txt_danTitle')--GTextField
	self.txt_integralTitle = viewNode:getChildAutoType('txt_integralTitle')--GTextField
	self.txt_playerInfoTitle = viewNode:getChildAutoType('txt_playerInfoTitle')--GTextField
	self.txt_rankTitle = viewNode:getChildAutoType('txt_rankTitle')--GTextField
	--{autoFieldsEnd}:CrossTeamPVP.CrossTeamPVPRankView
	--Do not modify above code-------------
end

function CrossTeamPVPRankView:_initUI( )
	self:_initVM()
	CrossTeamPVPModel:reqGetRanks(false,function()
		self:CrossTeamPVPRankView_refreshPanel()
	end)
end

function CrossTeamPVPRankView:CrossTeamPVPRankView_refreshPanel()
	self:refreshPanel()
end	

function CrossTeamPVPRankView:refreshPanel()
	self.txt_rankTitle:setText(Desc.CrossTeamPVP_rankTitle)
	self.txt_playerInfoTitle:setText(Desc.CrossTeamPVP_playerInfoTitle)
	self.txt_danTitle:setText(Desc.CrossTeamPVP_danTitle)
	self.txt_integralTitle:setText(Desc.CrossTeamPVP_integralTitle)
	self.list_rank:setVirtual()
	self.list_rank:setItemRenderer(function(idx,obj)
		local index = idx + 1
		local data = self.rankData[index] 
		local txt_rank = obj:getChildAutoType("txt_rank")
		local heroCell = BindManager.bindPlayerCell( obj:getChildAutoType("heroCell"))
		local txt_name = obj:getChildAutoType("txt_name")
		local txt_power = obj:getChildAutoType("txt_power")
		local danIconLoader = obj:getChildAutoType("danIconLoader")
		local txt_integral = obj:getChildAutoType("txt_integral")
		local rankCtrl 	= obj:getController("rankCtrl") 	-- 排名 4 除了前三以外的排名
		local danCtrl 	= obj:getController("danCtrl") 	-- 段位 0没有段位 1有段位
		local haveRankCtrl 	= obj:getController("haveRankCtrl") 	-- 0没排名 1有排名
		local txt_danName 	= obj:getChildAutoType("txt_danName") 
		txt_power.ssid = idx+1
		danCtrl:setSelectedIndex(1)
		haveRankCtrl:setSelectedIndex(1)
		rankCtrl:setSelectedIndex((index <=3) and index or 4)
	
		if data then
			local danInfo = CrossTeamPVPModel:getCurDanInfoByIntegral(data.score or 0) 
			-- txt_danName:setText(string.format(Desc["HigherPvP_rankColor"..danInfo.icon], danInfo.name));
			txt_danName:setText(danInfo.name)
			danIconLoader:setIcon(string.format("Icon/rank/%s.png", danInfo.icon));

			txt_rank:setText(index)
			heroCell:setHead(data.head,data.level,data.playerId,nil,data.headBorder) 
			txt_name:setText(data.name)
			-- txt_power:setText(string.format(Desc.CrossTeamPVP_power,StringUtil.transValue(data.totalCombat or 0))) 
			-- txt_integral:setText(string.format(Desc.CrossTeamPVP_integral,data.score or 0))
			txt_integral:setText(data.score or 0)
		end

		obj:getChildAutoType("heroCell"):removeClickListener()
		obj:getChildAutoType("heroCell"):addClickListener(function(context) 
			context:stopPropagation()--阻止事件冒泡
			if data.playerId<0 then
				RollTips.show(Desc.Friend_cant_show)
				return
			end
			printTable(8848,">>>data.serverId>>>>",data.serverId)
			ViewManager.open("ViewPlayerView",{playerId = data.playerId,serverId=data.serverId,arrayType = GameDef.BattleArrayType.WorldTeamArena})
		end)
		local requseInfo = {
                playerId = data.playerId,
                serverId = data.serverId,
				arrayType = GameDef.GamePlayType.WorldTeamArena,
            }
		local function success(params)
			if txt_power.ssid ==  index then
				self.rankData[index].totalCombat = params.totalCombat or 0
				txt_power:setText(string.format(Desc.CrossTeamPVP_power,StringUtil.transValue(params.totalCombat or 0))) 
			end
		end
		if not self.rankData[index].totalCombat then
			RPCReq.Battle_GetPlayerArrayTotalCombat(requseInfo,success)
		else
			txt_power:setText(string.format(Desc.CrossTeamPVP_power,StringUtil.transValue( self.rankData[index].totalCombat or 0)))
		end
	end)
	self.rankData 		= CrossTeamPVPModel.rankInfo or {}
	local myRankData,inRank,myRank 	= CrossTeamPVPModel:getMyRankInfo() 
	self.list_rank:setData(self.rankData)  

	self.rankCtrl:setSelectedIndex(TableUtil.GetTableLen(self.rankData) >0 and 0 or 1)
	self:setMyRankInfo(inRank,myRankData,myRank)
end

-- 我自己的排名信息
function CrossTeamPVPRankView:setMyRankInfo(inRank,myRankData,myRank)
	if not CrossTeamPVPModel.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open] then
		CrossTeamPVPModel.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open] = {}
	end
	local mainInfo = CrossTeamPVPModel.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open]
	local myInfo = {}
	if mainInfo and mainInfo.members and mainInfo.members[tonumber(PlayerModel.userid)] then
		myInfo = mainInfo.members[tonumber(PlayerModel.userid)] or {}
	end

	local item = self.myRankItem
	local rankCtrl 	= item:getController("rankCtrl") 	-- 排名 4 除了前三以外的排名
	local danCtrl 	= item:getController("danCtrl") 	-- 段位 0没有段位 1有段位
	local haveRankCtrl 	= item:getController("haveRankCtrl") 	-- 0没排名 1有排名
	local isMeCtrl 	= item:getController("isMe") 		-- 0 不是自己 1 是自己

	haveRankCtrl:setSelectedIndex(inRank and 1 or 0)
	-- rankCtrl:setSelectedIndex((myRank and myRank <=3) and myRank or 4)
	isMeCtrl:setSelectedIndex(1)
	rankCtrl:setSelectedIndex(4)
	danCtrl:setSelectedIndex(1)
	local score = myRankData.score or myInfo.score
	local danInfo = CrossTeamPVPModel:getCurDanInfoByIntegral(score or 0) 
	-- item.txt_danName:setText(string.format(Desc["HigherPvP_rankColor"..danInfo.icon], danInfo.name));
	item.txt_danName:setText(danInfo.name)
	item.danIconLoader:setIcon(string.format("Icon/rank/%s.png", danInfo.icon));

	local percent = myRankData.percent or myInfo.percent
	item.txt_percent:setText(string.format("前%s%%", percent or 0)) 
	item.txt_rank:setText(myRank or 0) 
	local heroCell = BindManager.bindPlayerCell(item.heroCell)
	heroCell:setHead(PlayerModel.head,PlayerModel.level,tonumber(PlayerModel.userid),nil,PlayerModel.headBorder) 
	item.txt_name:setText(PlayerModel.username) 
	item.txt_integral:setText(string.format(Desc.CrossTeamPVP_integral,score or 0))
	item.heroCell:removeClickListener()
	item.heroCell:addClickListener(function(context) 
		context:stopPropagation()--阻止事件冒泡
		ViewManager.open("ViewPlayerView",{playerId = tonumber(PlayerModel.userid),serverId = LoginModel:getUnitServerId(),arrayType = GameDef.BattleArrayType.WorldTeamArena})
	end)

	local requseInfo = {
		playerId = myRankData.playerId or tonumber(PlayerModel.userid),
		serverId = myRankData.serverId or LoginModel:getUnitServerId(),
		arrayType = GameDef.GamePlayType.WorldTeamArena,
	}
	local function success(params)
		item.txt_power:setText(string.format(Desc.CrossTeamPVP_power,StringUtil.transValue(params.totalCombat or 0)))
	end
	RPCReq.Battle_GetPlayerArrayTotalCombat(requseInfo,success)
end


return CrossTeamPVPRankView