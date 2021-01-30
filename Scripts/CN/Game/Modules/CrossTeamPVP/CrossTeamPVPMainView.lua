--Date :2020-12-09
--Author : wyz
--Desc : 跨服组队竞技主界面

local CrossTeamPVPMainView,Super = class("CrossTeamPVPMainView", Window)

function CrossTeamPVPMainView:ctor()
	--LuaLog("CrossTeamPVPMainView ctor")
	self._packName = "CrossTeamPVP"
	self._compName = "CrossTeamPVPMainView"
	--self._rootDepth = LayerDepth.Window
	
	self.timer1 = false
	self.timer2 = false
	self.timer3 = false
	self.myTeamInfo = {}
	self.onlyType = 0
	self.isEnd  = false
	self.flag = 1
end

function CrossTeamPVPMainView:_initEvent( )
	
end

function CrossTeamPVPMainView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossTeamPVP.CrossTeamPVPMainView
	self.btn_allow = viewNode:getChildAutoType('btn_allow')--btn_allow
		self.btn_allow.txt_title = viewNode:getChildAutoType('btn_allow/txt_title')--GTextField
	self.btn_array = viewNode:getChildAutoType('btn_array')--GButton
	self.btn_fight = viewNode:getChildAutoType('btn_fight')--GButton
	self.btn_help = viewNode:getChildAutoType('btn_help')--GButton
	self.btn_rank = viewNode:getChildAutoType('btn_rank')--GButton
	self.btn_rankReward = viewNode:getChildAutoType('btn_rankReward')--btn_rankReward
		self.btn_rankReward.img_red = viewNode:getChildAutoType('btn_rankReward/img_red')--GImage
	self.btn_rankReward2 = viewNode:getChildAutoType('btn_rankReward2')--GButton
	self.btn_record = viewNode:getChildAutoType('btn_record')--GButton
	self.btn_shop = viewNode:getChildAutoType('btn_shop')--GButton
	self.btn_teamHall = viewNode:getChildAutoType('btn_teamHall')--btn_teamHall
		self.btn_teamHall.img_red = viewNode:getChildAutoType('btn_teamHall/img_red')--GImage
	self.checkCaptain = viewNode:getController('checkCaptain')--Controller
	self.checkHaveTeam = viewNode:getController('checkHaveTeam')--Controller
	self.checkOpen = viewNode:getController('checkOpen')--Controller
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.isOpen = viewNode:getChildAutoType('isOpen')--GGroup
	self.isend = viewNode:getChildAutoType('isend')--GGroup
	self.mainRankItem1 = viewNode:getChildAutoType('mainRankItem1')--mainRankItem
		self.mainRankItem1.danIconLoader = viewNode:getChildAutoType('mainRankItem1/danIconLoader')--GLoader
		self.mainRankItem1.modelNode = viewNode:getChildAutoType('mainRankItem1/modelNode')--GComponent
		self.mainRankItem1.rankIconLoader = viewNode:getChildAutoType('mainRankItem1/rankIconLoader')--GLoader
		self.mainRankItem1.txt_integral = viewNode:getChildAutoType('mainRankItem1/txt_integral')--GTextField
		self.mainRankItem1.txt_lv = viewNode:getChildAutoType('mainRankItem1/txt_lv')--GTextField
		self.mainRankItem1.txt_playerName = viewNode:getChildAutoType('mainRankItem1/txt_playerName')--GTextField
		self.mainRankItem1.txt_power = viewNode:getChildAutoType('mainRankItem1/txt_power')--GTextField
	self.mainRankItem2 = viewNode:getChildAutoType('mainRankItem2')--mainRankItem
		self.mainRankItem2.danIconLoader = viewNode:getChildAutoType('mainRankItem2/danIconLoader')--GLoader
		self.mainRankItem2.modelNode = viewNode:getChildAutoType('mainRankItem2/modelNode')--GComponent
		self.mainRankItem2.rankIconLoader = viewNode:getChildAutoType('mainRankItem2/rankIconLoader')--GLoader
		self.mainRankItem2.txt_integral = viewNode:getChildAutoType('mainRankItem2/txt_integral')--GTextField
		self.mainRankItem2.txt_lv = viewNode:getChildAutoType('mainRankItem2/txt_lv')--GTextField
		self.mainRankItem2.txt_playerName = viewNode:getChildAutoType('mainRankItem2/txt_playerName')--GTextField
		self.mainRankItem2.txt_power = viewNode:getChildAutoType('mainRankItem2/txt_power')--GTextField
	self.mainRankItem3 = viewNode:getChildAutoType('mainRankItem3')--mainRankItem
		self.mainRankItem3.danIconLoader = viewNode:getChildAutoType('mainRankItem3/danIconLoader')--GLoader
		self.mainRankItem3.modelNode = viewNode:getChildAutoType('mainRankItem3/modelNode')--GComponent
		self.mainRankItem3.rankIconLoader = viewNode:getChildAutoType('mainRankItem3/rankIconLoader')--GLoader
		self.mainRankItem3.txt_integral = viewNode:getChildAutoType('mainRankItem3/txt_integral')--GTextField
		self.mainRankItem3.txt_lv = viewNode:getChildAutoType('mainRankItem3/txt_lv')--GTextField
		self.mainRankItem3.txt_playerName = viewNode:getChildAutoType('mainRankItem3/txt_playerName')--GTextField
		self.mainRankItem3.txt_power = viewNode:getChildAutoType('mainRankItem3/txt_power')--GTextField
	self.mainTeamItem1 = viewNode:getChildAutoType('mainTeamItem1')--mainTeamItem
		self.mainTeamItem1.btn_contact = viewNode:getChildAutoType('mainTeamItem1/btn_contact')--GButton
		self.mainTeamItem1.btn_exit = viewNode:getChildAutoType('mainTeamItem1/btn_exit')--GButton
		self.mainTeamItem1.btn_transfer = viewNode:getChildAutoType('mainTeamItem1/btn_transfer')--GButton
		self.mainTeamItem1.danIconLoader = viewNode:getChildAutoType('mainTeamItem1/danIconLoader')--GLoader
		self.mainTeamItem1.heroCell = viewNode:getChildAutoType('mainTeamItem1/heroCell')--GButton
		self.mainTeamItem1.img_leader = viewNode:getChildAutoType('mainTeamItem1/img_leader')--GImage
		self.mainTeamItem1.txt_countTimes = viewNode:getChildAutoType('mainTeamItem1/txt_countTimes')--GRichTextField
		self.mainTeamItem1.txt_danName = viewNode:getChildAutoType('mainTeamItem1/txt_danName')--GRichTextField
		self.mainTeamItem1.txt_integral = viewNode:getChildAutoType('mainTeamItem1/txt_integral')--GTextField
		self.mainTeamItem1.txt_online = viewNode:getChildAutoType('mainTeamItem1/txt_online')--GTextField
		self.mainTeamItem1.txt_playerName = viewNode:getChildAutoType('mainTeamItem1/txt_playerName')--GTextField
		self.mainTeamItem1.txt_power = viewNode:getChildAutoType('mainTeamItem1/txt_power')--GTextField
		self.mainTeamItem1.txt_rank = viewNode:getChildAutoType('mainTeamItem1/txt_rank')--GTextField
	self.mainTeamItem2 = viewNode:getChildAutoType('mainTeamItem2')--mainTeamItem
		self.mainTeamItem2.btn_contact = viewNode:getChildAutoType('mainTeamItem2/btn_contact')--GButton
		self.mainTeamItem2.btn_exit = viewNode:getChildAutoType('mainTeamItem2/btn_exit')--GButton
		self.mainTeamItem2.btn_transfer = viewNode:getChildAutoType('mainTeamItem2/btn_transfer')--GButton
		self.mainTeamItem2.danIconLoader = viewNode:getChildAutoType('mainTeamItem2/danIconLoader')--GLoader
		self.mainTeamItem2.heroCell = viewNode:getChildAutoType('mainTeamItem2/heroCell')--GButton
		self.mainTeamItem2.img_leader = viewNode:getChildAutoType('mainTeamItem2/img_leader')--GImage
		self.mainTeamItem2.txt_countTimes = viewNode:getChildAutoType('mainTeamItem2/txt_countTimes')--GRichTextField
		self.mainTeamItem2.txt_danName = viewNode:getChildAutoType('mainTeamItem2/txt_danName')--GRichTextField
		self.mainTeamItem2.txt_integral = viewNode:getChildAutoType('mainTeamItem2/txt_integral')--GTextField
		self.mainTeamItem2.txt_online = viewNode:getChildAutoType('mainTeamItem2/txt_online')--GTextField
		self.mainTeamItem2.txt_playerName = viewNode:getChildAutoType('mainTeamItem2/txt_playerName')--GTextField
		self.mainTeamItem2.txt_power = viewNode:getChildAutoType('mainTeamItem2/txt_power')--GTextField
		self.mainTeamItem2.txt_rank = viewNode:getChildAutoType('mainTeamItem2/txt_rank')--GTextField
	self.open = viewNode:getChildAutoType('open')--GGroup
	self.txt_myTeam = viewNode:getChildAutoType('txt_myTeam')--GTextField
	self.txt_timer1 = viewNode:getChildAutoType('txt_timer1')--GTextField
	self.txt_timer2 = viewNode:getChildAutoType('txt_timer2')--GTextField
	self.txt_timerTitle1 = viewNode:getChildAutoType('txt_timerTitle1')--GTextField
	self.txt_timerTitle2 = viewNode:getChildAutoType('txt_timerTitle2')--GTextField
	self.txt_timesTimer = viewNode:getChildAutoType('txt_timesTimer')--GTextField
	self.txt_timesTitle = viewNode:getChildAutoType('txt_timesTitle')--GTextField
	self.txt_tipsHall = viewNode:getChildAutoType('txt_tipsHall')--GTextField
	--{autoFieldsEnd}:CrossTeamPVP.CrossTeamPVPMainView
	--Do not modify above code-------------
end

function CrossTeamPVPMainView:_initUI( )
	self:_initVM()
	self:setBg("crossTeamBg.jpg")
	-- self.frame:getChildAutoType("fullScreen"):setIcon("Map/100013.jpg")
	self:CrossTeamPVPMainView_refreshPanel()
	CrossTeamPVPModel:reqGetPlayerInfo()
	CrossTeamPVPModel:reqGetRanks(3)
	self.btn_help:removeClickListener()
	self.btn_help:addClickListener(function()
		local info={}
		info['title']=Desc["help_StrTitle"..ModuleId.CrossTeamPVP.id]
		info['desc']=Desc["help_StrDesc"..ModuleId.CrossTeamPVP.id]
		ViewManager.open("GetPublicHelpView",info) 
	end)
end


function CrossTeamPVPMainView:CrossTeamPVPMainView_refreshPanel()
	self.flag = self.flag + 1
	printTable(8849,">>>>>>>>>>>" .. self.flag)
	self:refreshPanel()
end

function CrossTeamPVPMainView:refreshPanel()
	self:initClickListener()
	self:setRankInfo()
	self:setMyTeamInfo()
	self:checkPlayOpen()
	self:updateOpenTime()
	self:updateCloseTime()
	self:updateRecoverTime()
end


function CrossTeamPVPMainView:initClickListener()
	-- 打开排行榜
	self.btn_rank:removeClickListener()
	self.btn_rank:addClickListener(function() 
		ViewManager.open("CrossTeamPVPRankView")
	end)
	
	-- 打开商店
	self.btn_shop:removeClickListener()
	self.btn_shop:addClickListener(function() 
		ModuleUtil.openModule(ModuleId.Shop_CrossTeamPVP.id,true,{shopType = 20})
	end)

	-- 打开排名奖励
	local rewardImg_red = self.btn_rankReward:getChildAutoType("img_red")
	RedManager.register("V_CROSSTEAMPVP_REWARD",rewardImg_red)
	self.btn_rankReward:removeClickListener()
	self.btn_rankReward:addClickListener(function() 
		ViewManager.open("CrossTeamPVPRewardView")
	end)

	self.btn_rankReward2:removeClickListener()
	self.btn_rankReward2:addClickListener(function()  
		ViewManager.open("CrossTeamPVPRankRewardView")
	end)

	-- 打开记录
	self.btn_record:removeClickListener()
	self.btn_record:addClickListener(function() 
		ViewManager.open("CrossTeamPVPRecordOutView")
	end)

	-- 打开布阵界面
	self.btn_array:removeClickListener()
	self.btn_array:addClickListener(function() 
		local const = DynamicConfigData.t_arena[1]
		local function battleHandler(eventName)
			if eventName == "begin" then
			end
		end
		local args = {
			fightID= const.fightId,
			configType = GameDef.BattleArrayType.WorldTeamArena,
			interfaceType = 1, -- 1从主界面进入布阵 2从排序界面进入布阵
		}
		Dispatcher.dispatchEvent(EventType.battle_requestFunc,battleHandler,args)
	end)

	-- 挑战(匹配)
	local fightImg_red = self.btn_fight:getChildAutoType("img_red")
	RedManager.register("V_CROSSTEAMPVP_FIGHT",fightImg_red)
	self.btn_fight:removeClickListener()
	self.btn_fight:addClickListener(function() 
		printTable(8848,">>>>CrossTeamPVPModel.isEnd>>>>",CrossTeamPVPModel.isEnd)
		if (CrossTeamPVPModel.status == GameDef.WorldTeamArenaStatusType.END) or CrossTeamPVPModel.isEnd then
			RollTips.show(Desc.CrossTeamPVP_activityEnd) 
			return
		end
		if CrossTeamPVPModel.status == GameDef.WorldTeamArenaStatusType.PREPARE then
			RollTips.show(Desc.CrossTeamPVP_fightTips1) 
			return
		end
		if CrossTeamPVPModel.status == GameDef.WorldTeamArenaStatusType.OPEN then
		end

		local canFight,memberNum,isLeader,isLeadOfflineCanBattle = CrossTeamPVPModel:checkCanChallenge()
		if (not isLeader) and (not isLeadOfflineCanBattle) then
			RollTips.show(Desc.CrossTeamPVP_notFight3)
			return			
		end
		if not canFight and (memberNum == 1) then
			RollTips.show(Desc.CrossTeamPVP_notFight1)
			return
		end
		if not canFight and (memberNum > 1) then
			RollTips.show(Desc.CrossTeamPVP_notFight2)
			return
		end
		ViewManager.open("CrossTeamPVPMatchView")
	end)

	-- 打开组队大厅
	local teamHallImg_red = self.btn_teamHall:getChildAutoType("img_red")
	RedManager.register("V_CROSSTEAMPVP_INVITED",teamHallImg_red)
	self.btn_teamHall:removeClickListener()
	self.btn_teamHall:addClickListener(function() 
		if CrossTeamPVPModel.status == GameDef.WorldTeamArenaStatusType.END then
			RollTips.show(Desc.CrossTeamPVP_activityEnd) 
			return
		end
		ViewManager.open("CrossTeamPVPTeamHallView")
	end)
end

-- 设置前三名排行榜信息
function CrossTeamPVPMainView:setRankInfo()
	local rankData = CrossTeamPVPModel.rankInfo or {}
	local myRankData,inRank = CrossTeamPVPModel:getMyRankInfo()
	for i=1,3 do
		local data				= rankData[i]
		local item 				= self.view:getChildAutoType("mainRankItem" ..i)
		local checkRank 		= item:getController("checkRank")
		local checkBody 		= item:getController("checkBody") -- 0有人 1没人
		local rankIconLoader 	= item:getChildAutoType("rankIconLoader")
		local danIconLoader 	= item:getChildAutoType("danIconLoader")
		-- local heroCell 			= BindManager.bindPlayerCell(item:getChildAutoType("heroCell"))
		local txt_playerName 	= item:getChildAutoType("txt_playerName")
		local txt_integral 		= item:getChildAutoType("txt_integral")
		local txt_power 		= item:getChildAutoType("txt_power")
		local modelNode 		= item:getChildAutoType("modelNode")
		local txt_lv 			= item:getChildAutoType("txt_lv")

		if modelNode then
			modelNode:displayObject():removeAllChildren()
		end
		local skeletonNode
		checkRank:setSelectedIndex(i) 
		if data then
			danIconLoader:setURL("")
			-- heroCell:setData(data.head,data.level,data.playerId)
			txt_lv:setText("Lv." .. data.level)
			txt_playerName:setText(data.name)
			txt_integral:setText(string.format(Desc.CrossTeamPVP_integral,data.score or 0))
			txt_power:setText(string.format(Desc.CrossTeamPVP_power,StringUtil.transValue(data.totalCombat or 0)))
			checkBody:setSelectedIndex(0)
			-- item:getChildAutoType("heroCell"):removeClickListener()
			-- item:getChildAutoType("heroCell"):addClickListener(function(context) 
			-- 	context:stopPropagation()--阻止事件冒泡
			-- 	ViewManager.open("ViewPlayerView",{playerId = data.playerId})
			-- end)
			skeletonNode = SpineUtil.createModel(modelNode, {x = 0, y =0}, "stand", data.head,true,data.fashionCode)
		else
			checkBody:setSelectedIndex(1)
		end
	end
end


-- 队伍信息
function CrossTeamPVPMainView:setMyTeamInfo()
	if not CrossTeamPVPModel.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open] then
		CrossTeamPVPModel.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open] = {}
	end
	local mainInfo = CrossTeamPVPModel.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open]
	self.myTeamInfo = self:initTeamHallInfo(mainInfo.members or {})
	self:initTeamInfo()
	self.checkCaptain:setSelectedIndex(mainInfo.isLeader and 1 or 0)
	self.checkHaveTeam:setSelectedIndex(TableUtil.GetTableLen(self.myTeamInfo)>1 and 1 or 0)

	local leaderId = mainInfo.leaderId

	self.onlyType = mainInfo.isLeadOfflineCanBattle and 0 or 1
	self.txt_myTeam:setText(Desc.CrossTeamPVP_myTeamTitle)
	self.btn_allow:removeClickListener(11)
	self.btn_allow:getController("button"):setSelectedIndex(self.onlyType == 0 and 1 or 0)
	self.btn_allow:addClickListener(function() 
		self.onlyType = self.onlyType == 1 and 0 or 1
		self.btn_allow:getController("button"):setSelectedIndex(self.onlyType == 0 and 1 or 0)
		CrossTeamPVPModel:reqOnSetLeadOfflineCanBattle()
	end,11)

	local myId = tonumber(PlayerModel.userid)
	
	local membersNum 		= TableUtil.GetTableLen(self.myTeamInfo)
	local myRankInfo,inRank = CrossTeamPVPModel:getMyRankInfo()
	for i =1,membersNum do
		local obj = self.view:getChildAutoType("mainTeamItem" .. i)
		local index = i
		local data 	= self.myTeamInfo[index]
		local checkHaveTeam = obj:getController("checkHaveTeam") -- 0 没有队员 1 有队员
		local checkIsMe 	= obj:getController("checkIsMe") 	 -- 0 不是自己 1 是自己
		local checkCaptain 	= obj:getController("checkCaptain")  -- 0 不是队长 1 是队长
		local checkOnline 	= obj:getController("checkOnline") 	 -- 0 在线 1 离线
		local txt_rank 		= obj:getChildAutoType("txt_rank") 	 -- 排名
		local txt_integral 	= obj:getChildAutoType("txt_integral") -- 积分
		local heroCell 		= BindManager.bindPlayerCell(obj:getChildAutoType("heroCell")) 
		local txt_playerName = obj:getChildAutoType("txt_playerName") -- 玩家名
		local txt_power 	= obj:getChildAutoType("txt_power") 	-- 战力
		local danIconLoader = obj:getChildAutoType("danIconLoader") -- 段位图标
		local txt_countTimes = obj:getChildAutoType("txt_countTimes") -- 剩余挑战次数
		local btn_transfer 	= obj:getChildAutoType("btn_transfer") 	-- 转让队长
		local btn_exit 		= obj:getChildAutoType("btn_exit") 	 	-- 退出队伍
		local btn_contact 	= obj:getChildAutoType("btn_contact") 	-- 联系队友
		local txt_danName 	= obj:getChildAutoType("txt_danName") 	-- 段位名
		local img_leader  	= obj:getChildAutoType("img_leader")

		checkIsMe:setSelectedIndex(((myId == data.playerId)) and 1 or 0)
		checkHaveTeam:setSelectedIndex((membersNum > 1) and 1 or 0)
		checkCaptain:setSelectedIndex((mainInfo.isLeader) and 1 or 0)
		img_leader:setVisible(leaderId == data.playerId)

		local state1 = checkIsMe:getSelectedIndex()
		local state2 = checkCaptain:getSelectedIndex()


		checkOnline:setSelectedIndex(data.isOnline and 0 or 1) 
		local rank = CrossTeamPVPModel:getRankByPlayerId(data.playerId) and CrossTeamPVPModel:getRankByPlayerId(data.playerId) or 0
		if rank == 0 or rank > 100 then
			txt_rank:setText(Desc.CrossTeamPVP_fuzzyRank)
		else
			txt_rank:setText(string.format(Desc.CrossTeamPVP_rank,rank)) 			
		end

		local danInfo = CrossTeamPVPModel:getCurDanInfoByIntegral(data.score or 0) 
		txt_danName:setText(string.format(Desc["HigherPvP_rankColor"..danInfo.icon], danInfo.name));

		txt_integral:setText(string.format(Desc.CrossTeamPVP_integral,data.score)) 
		heroCell:setHead(data.head,data.level,data.playerId,nil,data.headBorder) 
		txt_playerName:setText(data.name) 
		
		txt_power:setText(string.format(Desc.CrossTeamPVP_power,StringUtil.transValue(data.totalCombat or 0)))
		danIconLoader:setIcon(string.format("Icon/rank/%s.png", danInfo.icon));
		-- if data.playerId == myId then 
		-- 	txt_countTimes:setText(string.format(Desc.CrossTeamPVP_challengeCountTimes,	CrossTeamPVPModel:getResidueNum()))
		-- else
			txt_countTimes:setText(string.format(Desc.CrossTeamPVP_challengeCountTimes,data.restTimes))
		-- end

		-- 转让队长
		btn_transfer:removeClickListener()
		btn_transfer:addClickListener(function() 
			local info = {}
			info.text = Desc.CrossTeamPVP_str6
			info.type = "yes_no"
			info.onYes = function()
				CrossTeamPVPModel:reqChangeLeader()
			end
			Alert.show(info);
		end)

		-- 退出队伍
		btn_exit:removeClickListener()
		btn_exit:addClickListener(function() 
			local info = {}
			info.text = Desc.CrossTeamPVP_str5
			info.type = "yes_no"
			info.onYes = function()
				CrossTeamPVPModel:reqLeaveTeam()
			end
			Alert.show(info);
		end)

		-- 联系队友
		btn_contact:removeClickListener()
		btn_contact:addClickListener(function() 
			Dispatcher.dispatchEvent(EventType.update_chatClientPrivte, data)
		end)

		obj:getChildAutoType("heroCell"):removeClickListener()
		obj:getChildAutoType("heroCell"):addClickListener(function(context) 
			context:stopPropagation()--阻止事件冒泡
			if data.playerId<0 then
				RollTips.show(Desc.Friend_cant_show)
				return
			end
			printTable(8848,">>>data.serverId>>>",data.serverId)
			ViewManager.open("ViewPlayerView",{playerId = data.playerId,serverId = data.serverId,arrayType = GameDef.BattleArrayType.WorldTeamArena})
		end)
	end
end 

-- 队伍信息处理
function CrossTeamPVPMainView:initTeamInfo()
	local tempInfo = {}
	local myId = tonumber(PlayerModel.userid)
	for k,v in pairs(self.myTeamInfo) do
		v.leaderSort = 2
		if v.playerId == myId then
			v.leaderSort = 1
		end
		table.insert(tempInfo,v)
	end
	self.myTeamInfo = tempInfo
	local keys ={
		{key="leaderSort",false}
	}
	TableUtil.sortByMap(self.myTeamInfo,keys)
end


-- 判断玩法有没有开启
function CrossTeamPVPMainView:checkPlayOpen()
	local moduleIsOpen = (not ModuleUtil.getModuleOpenTips(ModuleId.CrossTeamPVP.id))
	local serVerOpen 	=( (CrossTeamPVPModel.status == GameDef.WorldTeamArenaStatusType.END) or (CrossTeamPVPModel.status == GameDef.WorldTeamArenaStatusType.RESET))
	if moduleIsOpen and (not serVerOpen) then 	-- 开启了
		self.checkOpen:setSelectedIndex(1)
		-- self.txt_timerTitle2:setText(Desc.CrossTeamPVP_openTimeTitle2)	
	else
		self.txt_timerTitle1:setText(Desc.CrossTeamPVP_openTimeTitle1)
		self.checkOpen:setSelectedIndex(0)
	end

end

-- 挑战次数恢复
function CrossTeamPVPMainView:updateRecoverTime()
	local recoverTime =  CrossTeamPVPModel.crossTeamInfoByReason[GameDef.WorldTeamArenaReasonType.Open].nextAddTimesMs or 0
	recoverTime = (math.floor(recoverTime/1000) - ServerTimeModel:getServerTime())
	if recoverTime <= 0 then
		self.txt_timesTitle:setVisible(false)
		self.txt_timesTimer:setVisible(false)
		return
	end
	self.txt_timesTitle:setVisible(true)
	self.txt_timesTimer:setVisible(true)
	if not tolua.isnull(self.txt_timesTimer) then
		self.txt_timesTimer:setText(TimeLib.GetTimeFormatDay(recoverTime, 2))
	end
	local function onCountDown(time)
		if not tolua.isnull(self.txt_timesTimer) then
			self.txt_timesTimer:setText(TimeLib.GetTimeFormatDay(time, 2))
		end
	end
	local function onEnd(...)
		self.txt_timesTitle:setVisible(false)
		self.txt_timesTimer:setVisible(false)
		-- self:refreshPanel() 
	end
	if self.timer3 then
		TimeLib.clearCountDown(self.timer3)
	end
	self.timer3 = TimeLib.newCountDown(recoverTime, onCountDown, onEnd, false, false, false)
end

-- 挑战开启倒计时
function CrossTeamPVPMainView:updateOpenTime()
	local openTime =  CrossTeamPVPModel.activityEndMs or 0
	openTime = (math.floor(openTime/1000) - ServerTimeModel:getServerTime())

	if CrossTeamPVPModel.status == GameDef.WorldTeamArenaStatusType.RESET then
		self.txt_timer1:setText(Desc.CrossTeamPVP_str8) 
	end
	if openTime <= 0 then
		return
	end
	if not tolua.isnull(self.txt_timer1) then
		self.txt_timer1:setText(TimeLib.GetTimeFormatDay(openTime, 2))
	end
	local function onCountDown(time)
		if not tolua.isnull(self.txt_timer1) then
			self.txt_timer1:setText(TimeLib.GetTimeFormatDay(time, 2))
		end
	end
	local function onEnd(...)
		-- self:refreshPanel()
		self.txt_timer1:setText(Desc.CrossTeamPVP_str8) 
		CrossTeamPVPModel:reqGetCurMatchStatus()
	end
	if self.timer1 then
		TimeLib.clearCountDown(self.timer1)
	end
	self.timer1 = TimeLib.newCountDown(openTime, onCountDown, onEnd, false, false, false)
end

-- 挑战关闭倒计时
function CrossTeamPVPMainView:updateCloseTime()
	local closeTime =  CrossTeamPVPModel.activityEndMs or 0
	closeTime = (math.floor(closeTime/1000) - ServerTimeModel:getServerTime())
	if CrossTeamPVPModel.status == GameDef.WorldTeamArenaStatusType.END then
		self.txt_timer2:setText(Desc.CrossTeamPVP_activityEnd) 
		return
	elseif CrossTeamPVPModel.status == GameDef.WorldTeamArenaStatusType.PREPARE then
		self.txt_timerTitle2:setText(Desc.CrossTeamPVP_activityTitle1)
	elseif CrossTeamPVPModel.status == GameDef.WorldTeamArenaStatusType.OPEN then
		self.txt_timerTitle2:setText(Desc.CrossTeamPVP_activityTitle2)
	elseif CrossTeamPVPModel.status == GameDef.WorldTeamArenaStatusType.RESET then
		self.txt_timer2:setText(Desc.CrossTeamPVP_str8) 
		return
	end

	if closeTime <= 0 then
		self.txt_timer2:setText(Desc.CrossTeamPVP_activityEnd) 
		return
	end
	if not tolua.isnull(self.txt_timer2) then
		self.txt_timer2:setText(TimeLib.GetTimeFormatDay(closeTime, 2))
	end
	local function onCountDown(time)
		if not tolua.isnull(self.txt_timer2) then
			self.txt_timer2:setText(TimeLib.GetTimeFormatDay(time, 2))
		end
	end
	local function onEnd(...)
		printTable(8848,">>>11111111111>>>")
		if (CrossTeamPVPModel.status == GameDef.WorldTeamArenaStatusType.OPEN) then
			printTable(8848,">>>2222222222>>>")
			CrossTeamPVPModel.isEnd = true
			print(8848,"33333333333>>>",CrossTeamPVPModel.isEnd)
			CrossTeamPVPModel:updateRed()
		end
		self.txt_timer2:setText(Desc.CrossTeamPVP_activityEnd) 
	end
	if self.timer2 then
		TimeLib.clearCountDown(self.timer2)
	end
	self.timer2 = TimeLib.newCountDown(closeTime, onCountDown, onEnd, false, false, false)
end

-- 初始化玩家列表
function CrossTeamPVPMainView:initTeamHallInfo(initInfo)
	local teamHallInfo = {}
	for k,v in pairs(initInfo) do
		v.sort = 2
		if v.playerId == tonumber(PlayerModel.userid) then
			v.sort = 1
		end
		table.insert(teamHallInfo,v)
	end
	table.sort(teamHallInfo,function(a,b) 
		if a.sort then
			return a.sort < b.sort
		end
	end)
	return teamHallInfo
end

function CrossTeamPVPMainView:_exit()
	if self.timer1 then
		TimeLib.clearCountDown(self.timer1)
	end
	if self.timer2 then
		TimeLib.clearCountDown(self.timer2)
	end
	if self.timer3 then
		TimeLib.clearCountDown(self.timer3)
	end
end




return CrossTeamPVPMainView