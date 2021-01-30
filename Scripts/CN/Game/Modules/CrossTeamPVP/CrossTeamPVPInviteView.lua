--Date :2020-12-09
--Author : wyz
--Desc : 组队竞技 邀请界面

local CrossTeamPVPInviteView,Super = class("CrossTeamPVPInviteView", Window)

function CrossTeamPVPInviteView:ctor()
	--LuaLog("CrossTeamPVPInviteView ctor")
	self._packName = "CrossTeamPVP"
	self._compName = "CrossTeamPVPInviteView"
	self._rootDepth = LayerDepth.PopWindow
	
end

function CrossTeamPVPInviteView:_initEvent( )
end

function CrossTeamPVPInviteView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossTeamPVP.CrossTeamPVPInviteView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.checkHaveInvite = viewNode:getController('checkHaveInvite')--Controller
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.list_invite = viewNode:getChildAutoType('list_invite')--GList
	--{autoFieldsEnd}:CrossTeamPVP.CrossTeamPVPInviteView
	--Do not modify above code-------------
end

function CrossTeamPVPInviteView:_initUI( )
	self:_initVM()
	CrossTeamPVPModel:reqGetPlayerListByType(GameDef.WorldTeamArenaPlayerListType.BeInvited)
end

function CrossTeamPVPInviteView:refreshPanel()
	self:setInviteList()
end

function CrossTeamPVPInviteView:CrossTeamPVPInviteView_refreshPanel()
	self:refreshPanel()
end

-- 设置邀请列表
function CrossTeamPVPInviteView:setInviteList()
	if not CrossTeamPVPModel.teamHallInfo[GameDef.WorldTeamArenaPlayerListType.BeInvited] then
		CrossTeamPVPModel.teamHallInfo[GameDef.WorldTeamArenaPlayerListType.BeInvited] = {}
	end
	local teamHallInfo = self:initTeamHallInfo()
	self.checkHaveInvite:setSelectedIndex((TableUtil.GetTableLen(teamHallInfo) == 0) and 1 or 0)
	self.list_invite:setVirtual()
	self.list_invite:setItemRenderer(function(idx,obj)
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
		-- checkInvite:setSelectedIndex(invitedInfo[data.playerId] and 1 or 0)
		checkInterface:setSelectedIndex(1)
		-- 如果有名次 显示名次 否则显示1000+名
		local danInfo = CrossTeamPVPModel:getCurDanInfoByIntegral(data.score or 0) 
		txt_danName:setText(string.format(Desc["HigherPvP_rankColor"..danInfo.icon], danInfo.name));
		danIconLoader:setIcon(string.format("Icon/rank/%s.png", danInfo.icon));		

		txt_rank:setText(string.format(Desc.CrossTeamPVP_teamHallRank,data.rank))  
		txt_integral:setText(string.format(Desc.CrossTeamPVP_integral,data.score))
		heroCell:setData(data.head,data.level,data.playerId) 
		txt_playerName:setText(data.name)  
		txt_power:setText(string.format(Desc.CrossTeamPVP_power,StringUtil.transValue(data.totalCombat or 0)))
		

		btn_accept:removeClickListener()
		btn_accept:addClickListener(function()  
			-- if data.hasTeam then 	-- 已有队伍要剔除
			-- 	-- 把该玩家id传进去 剔除该玩家 可以把类型也传进去 统一处理
			-- 	CrossTeamPVPModel:removePlayerByTypeAndId(GameDef.WorldTeamArenaPlayerListType.BeInvited,data.playerId)
			-- 	RollTips.show(Desc.CrossTeamPVP_hasTeam)
			-- 	return
			-- end
			CrossTeamPVPModel:reqAcceptInvite(data.playerId,data.serverId,true)
			
		end)

		btn_refused:removeClickListener()
		btn_refused:addClickListener(function()  
			-- 把该玩家id传进去 剔除该玩家 可以把类型也传进去 统一处理
			-- CrossTeamPVPModel:removePlayerByTypeAndId(GameDef.WorldTeamArenaPlayerListType.BeInvited,data.playerId)
			CrossTeamPVPModel:reqAcceptInvite(data.playerId,data.serverId,false)
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
	end)
	self.list_invite:setData(teamHallInfo)
end

-- 初始化玩家列表
function CrossTeamPVPInviteView:initTeamHallInfo()
	local teamHallInfo = {}
	local initInfo = CrossTeamPVPModel.teamHallInfo[GameDef.WorldTeamArenaPlayerListType.BeInvited].list or {}
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

function CrossTeamPVPInviteView:_exit()
	
end


return CrossTeamPVPInviteView