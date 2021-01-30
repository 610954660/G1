--Date :2020-12-09
--Author : wyz
--Desc : 组队竞技 组队大厅界面

local CrossTeamPVPTeamHallView,Super = class("CrossTeamPVPTeamHallView", Window)

function CrossTeamPVPTeamHallView:ctor()
	--LuaLog("CrossTeamPVPTeamHallView ctor")
	self._packName = "CrossTeamPVP"
	self._compName = "CrossTeamPVPTeamHallView"
	self._rootDepth = LayerDepth.PopWindow
	self.reqType 	= 1  -- 1组队大厅推荐玩家 2 好友
	self.schedulerID = false
	self.nowTime 	= 5
end

function CrossTeamPVPTeamHallView:_initEvent( )
	
end

function CrossTeamPVPTeamHallView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossTeamPVP.CrossTeamPVPTeamHallView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.btn_invited = viewNode:getChildAutoType('btn_invited')--btn_invited
		self.btn_invited.img_red = viewNode:getChildAutoType('btn_invited/img_red')--GImage
	self.btn_page1 = viewNode:getChildAutoType('btn_page1')--btn_page
		self.btn_page1.img_red = viewNode:getChildAutoType('btn_page1/img_red')--GImage
	self.btn_page2 = viewNode:getChildAutoType('btn_page2')--btn_page
		self.btn_page2.img_red = viewNode:getChildAutoType('btn_page2/img_red')--GImage
	self.btn_refresh = viewNode:getChildAutoType('btn_refresh')--btn_seach
		self.btn_refresh.bg = viewNode:getChildAutoType('btn_refresh/bg')--GLoader
	self.btn_search = viewNode:getChildAutoType('btn_search')--btn_seach
		self.btn_search.bg = viewNode:getChildAutoType('btn_search/bg')--GLoader
	self.checkFriend = viewNode:getController('checkFriend')--Controller
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.haveNumCtrl = viewNode:getController('haveNumCtrl')--Controller
	self.list_player = viewNode:getChildAutoType('list_player')--GList
	self.txt_edittext = viewNode:getChildAutoType('txt_edittext')--GButton
	--{autoFieldsEnd}:CrossTeamPVP.CrossTeamPVPTeamHallView
	--Do not modify above code-------------
	self.txt_edittext = BindManager.bindTextInput(self.txt_edittext)
	-- self.txt_edittext:setText(data.name)
    -- self.txt_edittext:setMaxLength(6)
end

function CrossTeamPVPTeamHallView:_initUI( )
	self:_initVM()
	CrossTeamPVPModel:reqGetPlayerListByType(self.reqType)
	-- self:CrossTeamPVPTeamHallView_refreshPanel()
end

function CrossTeamPVPTeamHallView:refreshPanel()
	local haveInvited 	 = CrossTeamPVPModel:checkHaveInvited()
	local invited_imgRed = self.btn_invited:getChildAutoType("img_red")
	invited_imgRed:setVisible(haveInvited)
	self:setSeachInfo()
	self:setPlayerList()
end	

function CrossTeamPVPTeamHallView:CrossTeamPVPTeamHallView_refreshPanel()
	self:initClickLister()
	self:refreshPanel()
end

function CrossTeamPVPTeamHallView:initClickLister()
	-- 打开被邀请界面
	self.btn_invited:removeClickListener()
	self.btn_invited:addClickListener(function() 
		ViewManager.open("CrossTeamPVPInviteView")
	end)

	-- 页签
	self.btn_page1:removeClickListener(11)
	self.btn_page1:addClickListener(function()
		if self.reqType == GameDef.WorldTeamArenaPlayerListType.Hall then
			return
		end
		self.reqType = GameDef.WorldTeamArenaPlayerListType.Hall
		CrossTeamPVPModel:reqGetPlayerListByType(self.reqType)
		self:refreshPanel()
	end,11)
	self.btn_page2:removeClickListener(11)
	self.btn_page2:addClickListener(function()
		if self.reqType == GameDef.WorldTeamArenaPlayerListType.Friend then
			return
		end
		self.reqType = GameDef.WorldTeamArenaPlayerListType.Friend
		CrossTeamPVPModel:reqGetPlayerListByType(self.reqType)
		self:refreshPanel()
	end,11)
end

-- 设置搜索框
function CrossTeamPVPTeamHallView:setSeachInfo()
	-- if nametext ~= "" then
		-- 搜索
		self.btn_search:removeClickListener()
		self.btn_search:addClickListener(function() 
			CrossTeamPVPModel.isSeach = true
			local nametext = self.txt_edittext:getText();
			printTable(8848,">>>nametext>>",nametext)
			if nametext ~="" then
				CrossTeamPVPModel:reqSearch(nametext)
			else
				CrossTeamPVPModel:reqGetPlayerListByType(self.reqType)
			end
		end)
	-- else -- 为空的时候显示全部
		-- CrossTeamPVPModel:reqGetPlayerListByType(self.reqType)
	-- end

	-- 刷新
	self.btn_refresh:removeClickListener()
	self.btn_refresh:addClickListener(function() 
		local function onCountDown(dt)
			self.nowTime = self.nowTime - dt
			if self.nowTime <= 0 then
				self.nowTime = 5
				Scheduler.unschedule(self.schedulerID)
				self.schedulerID = false
			end
		end
		if self.schedulerID then
			RollTips.show(string.format(Desc.CrossTeamPVP_str2,math.floor(self.nowTime)))
			return
		end
		self.schedulerID = Scheduler.schedule(function(dt)
			onCountDown(dt)
		end,0.1)
		self.txt_edittext:setText("");
		CrossTeamPVPModel:reqGetPlayerListByType(self.reqType)
	end)	
end

-- 设置玩家列表
function CrossTeamPVPTeamHallView:setPlayerList()
	local seachType =  self.checkFriend:getSelectedIndex() + 1
	if not CrossTeamPVPModel.teamHallInfo[seachType] then
		CrossTeamPVPModel.teamHallInfo[seachType] = {}
	end
	if not CrossTeamPVPModel.teamHallInfo[GameDef.WorldTeamArenaPlayerListType.Invited] then
		CrossTeamPVPModel.teamHallInfo[GameDef.WorldTeamArenaPlayerListType.Invited] = {}
	end
	if not CrossTeamPVPModel.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open] then
		CrossTeamPVPModel.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open] = {}
	end
	local mainInfo = CrossTeamPVPModel.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open]
	if mainInfo then
		mainInfo = mainInfo.members[tonumber(PlayerModel.userid)]
	end

	local teamHallInfo 	=  	self:initTeamHallInfo(seachType)
	local invitedInfo 	=  	CrossTeamPVPModel.teamHallInfo[GameDef.WorldTeamArenaPlayerListType.Invited].list or {} -- 已邀请列表
	local MydanInfo	 	= 	CrossTeamPVPModel:getCurDanInfoByIntegral(mainInfo.score or 0) 
	local haveNumCtrl 	= 	self.view:getController("haveNumCtrl")
	haveNumCtrl:setSelectedIndex(TableUtil.GetTableLen(teamHallInfo)>0 and 0 or 1)

	self.list_player:setVirtual()
	self.list_player:setItemRenderer(function(idx,obj)
		local index	= idx + 1
		local data	= teamHallInfo[index]
		local checkOnline	= obj:getController("checkOnline") 		-- 0 在线 1 不在线
		local checkInvite	= obj:getController("checkInvite") 		-- 0 没邀请 1 已邀请
		local checkInterface= obj:getController("checkInterface") 	-- 0 大厅 1 好友
		local txt_online 	= obj:getChildAutoType("txt_online")	-- 在线状态
		local txt_rank 		= obj:getChildAutoType("txt_rank") 		-- 排名
		local txt_integral 	= obj:getChildAutoType("txt_integral")	-- 积分
		local heroCell 		= BindManager.bindPlayerCell(obj:getChildAutoType("heroCell"))
		local txt_playerName= obj:getChildAutoType("txt_playerName")	-- 玩家名
		local txt_power 	= obj:getChildAutoType("txt_power")		-- 战力
		local danIconLoader = obj:getChildAutoType("danIconLoader")	-- 段位图标
		local btn_invite 	= obj:getChildAutoType("btn_invite") 	-- 邀请按钮
		local txt_invite 	= obj:getChildAutoType("txt_invite") 	-- 已邀请
		local btn_accept 	= obj:getChildAutoType("btn_accept")
		local btn_refused 	= obj:getChildAutoType("btn_refused")
		local txt_danName 	= obj:getChildAutoType("txt_danName")
		
		checkOnline:setSelectedIndex(data.isOnline and 0 or 1)
		checkInvite:setSelectedIndex(invitedInfo[data.playerId] and 1 or 0)
		checkInterface:setSelectedIndex(0)
		-- 如果有名次 显示名次 否则显示1000+名
		local danInfo = CrossTeamPVPModel:getCurDanInfoByIntegral(data.score or 0) 
		-- txt_danName:setText(string.format(Desc["HigherPvP_rankColor"..danInfo.icon], danInfo.name));
		txt_danName:setText(danInfo.name)
		danIconLoader:setIcon(string.format("Icon/rank/%s.png", danInfo.icon));		

		txt_rank:setText(string.format(Desc.CrossTeamPVP_teamHallRank,data.rank))  
		txt_integral:setText(string.format(Desc.CrossTeamPVP_integral,data.score))
		heroCell:setHead(data.head,data.level,data.playerId,nil,data.headBorder) 

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
		txt_playerName:setText(data.name)  
		txt_power:setText(string.format(Desc.CrossTeamPVP_power,StringUtil.transValue(data.totalCombat or 0)))
		btn_invite:removeClickListener()
		btn_invite:addClickListener(function()  
			if data.playerId == tonumber(PlayerModel.userid) then
				RollTips.show(Desc.CrossTeamPVP_selfInfo)
				return
			end
			if data.hasTeam then 	-- 已有队伍要剔除
				-- 把该玩家id传进去 剔除该玩家
				CrossTeamPVPModel:removePlayerByTypeAndId(seachType,data.playerId)
				RollTips.show(Desc.CrossTeamPVP_hasTeam)
				return
			end
			CrossTeamPVPModel:reqInvite(data.playerId,data.serverId)
		end)
	end)
	self.list_player:setData(teamHallInfo)
end

-- 初始化玩家列表
function CrossTeamPVPTeamHallView:initTeamHallInfo(seachType)
	local teamHallInfo = {}
	local initInfo = CrossTeamPVPModel.teamHallInfo[seachType].list or {}
	for k,v in pairs(initInfo) do
		v.onlineState = 1
		if not v.isOnline then
			v.onlineState = 2
		end
		table.insert(teamHallInfo,v)
	end
	local keys = {
		{key="onlineState",asc = false},
		{key="totalCombat",asc = true},
	}
	TableUtil.sortByMap(teamHallInfo,keys)
	return teamHallInfo
end

function CrossTeamPVPTeamHallView:_exit()
	Scheduler.unschedule(self.schedulerID)
end


return CrossTeamPVPTeamHallView