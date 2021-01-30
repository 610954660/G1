--Date :2020-12-10
--Author : wyz
--Desc : 组队竞技 阵容排序

local CrossTeamPVPSquadSortView,Super = class("CrossTeamPVPSquadSortView", Window)

function CrossTeamPVPSquadSortView:ctor()
	--LuaLog("CrossTeamPVPSquadSortView ctor")
	self._packName 	= "CrossTeamPVP"
	self._compName 	= "CrossTeamPVPSquadSortView"
	self._rootDepth = LayerDepth.PopWindow
	self.timer 		= false
	self.tempData 	= {}
end

function CrossTeamPVPSquadSortView:_initEvent( )
	
end

function CrossTeamPVPSquadSortView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossTeamPVP.CrossTeamPVPSquadSortView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.btn_array = viewNode:getChildAutoType('btn_array')--GButton
	self.btn_fight = viewNode:getChildAutoType('btn_fight')--GButton
	self.btn_save = viewNode:getChildAutoType('btn_save')--GButton
	self.list_mySquad = viewNode:getChildAutoType('list_mySquad')--GList
	self.list_otherSquad = viewNode:getChildAutoType('list_otherSquad')--GList
	self.txt_myTeam = viewNode:getChildAutoType('txt_myTeam')--GTextField
	self.txt_myTotalpower = viewNode:getChildAutoType('txt_myTotalpower')--GTextField
	self.txt_otherTeam = viewNode:getChildAutoType('txt_otherTeam')--GTextField
	self.txt_otherTotalpower = viewNode:getChildAutoType('txt_otherTotalpower')--GTextField
	self.txt_timer = viewNode:getChildAutoType('txt_timer')--GTextField
	self.txt_tips = viewNode:getChildAutoType('txt_tips')--GTextField
	--{autoFieldsEnd}:CrossTeamPVP.CrossTeamPVPSquadSortView
	--Do not modify above code-------------
	
end

function CrossTeamPVPSquadSortView:_initUI( )
	self:_initVM()
	CrossTeamPVPModel:reqAdjust()
	-- self:CrossTeamPVPSquadSortView_refreshPanel()
end

function CrossTeamPVPSquadSortView:CrossTeamPVPSquadSortView_refreshPanel()
	if self.timer then
		Scheduler.unschedule(self.timer)
		self.timer = false
	end
	self:initClickListener()
	self:refreshPanel()
end

function CrossTeamPVPSquadSortView:refreshPanel()
	self:setMyTeamList()
	self:setOtherTeamList()
	self:updateCountTimer()
end

function CrossTeamPVPSquadSortView:initClickListener()
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
			interfaceType = 2, -- 1从主界面进入布阵 2从排序界面进入布阵
		}
		Dispatcher.dispatchEvent(EventType.battle_requestFunc,battleHandler,args)
	end)

	self.btn_save:removeClickListener()
	self.btn_save:addClickListener(function() 
		printTable(8848,">>>self.tempData>>>调整后的阵容>>>",self.tempData)
		local reqInfo = {
			[1] = {
				pos = 1,
				playerId = self.tempData[1].playerId,
				serverId = self.tempData[1].serverId,
			},
			[2] = {
				pos = 2,
				playerId = self.tempData[2].playerId,
				serverId = self.tempData[2].serverId,
			},
			[3] = {
				pos = 3,
				playerId = self.tempData[3].playerId,
				serverId = self.tempData[3].serverId,
			},
		}
		CrossTeamPVPModel:reqAdjust(reqInfo)
	end)

	self.btn_fight:removeClickListener()
	self.btn_fight:addClickListener(function() 
		CrossTeamPVPModel:reqBattle()
	end)
end

-- 我的队伍
function CrossTeamPVPSquadSortView:setMyTeamList()
	self.tempData = CrossTeamPVPModel.adjustInfo.attacker or {}
	local totalPower 		= 0
	for k,v in pairs(self.tempData) do
		for o,p in pairs(v.array) do
			totalPower = p.combat + totalPower
		end
	end
	self.txt_myTotalpower:setText(StringUtil.transValue(totalPower or 0))
	self.list_mySquad:setItemRenderer(function(idx,obj) 
		local index 	= idx + 1
		local data 		= self.tempData[index]
		local checkTeam = obj:getController("checkTeam")
		local checkState = obj:getController("checkState")
		local txt_playerName = obj:getChildAutoType("txt_playerName")
		local list_hero = obj:getChildAutoType("list_hero")
		local btn_left 	= obj:getChildAutoType("btn_left")
		local btn_right = obj:getChildAutoType("btn_right")
		local combat 	= 0 
		local txt_power = obj:getChildAutoType("txt_power")
		checkTeam:setSelectedIndex(0)
		checkState:setSelectedIndex(index - 1)
		list_hero:setItemRenderer(function(idx2,obj2)
			local heroCell = BindManager.bindHeroCell(obj2)
			heroCell:setData(data.array[idx2+1])
			combat = combat + data.array[idx2+1].combat
		end)
		
		list_hero:setData(data.array)
		txt_playerName:setText(data.name)  
		txt_power:setText(StringUtil.transValue(combat or 0))
		btn_right:removeClickListener(11)
		btn_right:addClickListener(function()  
			if index == 1 then
				self:changeHeroTemp(1,2)
			elseif index == 2 then
				self:changeHeroTemp(2,3)
			end
			self:setMyTeamList()
		end,11)

		btn_left:removeClickListener(11)
		btn_left:addClickListener(function()  
			if index == 3 then
				self:changeHeroTemp(2,3)
			elseif index == 2 then
				self:changeHeroTemp(1,2)
			end
			printTable(8848,">>>mySquadInfo>>",self.tempData)
			self:setMyTeamList()
		end,11)
	end)
	self.list_mySquad:setData(self.tempData)
end

function CrossTeamPVPSquadSortView:changeHeroTemp(p1,p2)
	if not p1 or not p2 then return false end
	local temp1 = self.tempData[p1]
	self.tempData[p1] = self.tempData[p2]
	self.tempData[p2] = temp1
end 


-- 敌人的队伍
function CrossTeamPVPSquadSortView:setOtherTeamList()
	local adjustInfo 		= CrossTeamPVPModel.adjustInfo or {}
	local otherSquadInfo 	= adjustInfo.defender 	or {}
	local totalPower 		= 0
	for k,v in pairs(otherSquadInfo) do
		for o,p in pairs(v.array) do
			totalPower = p.combat + totalPower
		end
	end
	self.txt_otherTotalpower:setText(StringUtil.transValue(totalPower or 0))

	self.list_otherSquad:setItemRenderer(function(idx,obj) 
		local index 	= idx + 1
		local data 		= otherSquadInfo[index]
		local checkTeam = obj:getController("checkTeam")
		local checkState = obj:getController("checkState")
		local txt_playerName = obj:getChildAutoType("txt_playerName")
		local list_hero = obj:getChildAutoType("list_hero")
		local btn_left 	= obj:getChildAutoType("btn_left")
		local btn_right = obj:getChildAutoType("btn_right")
		local combat 	= 0 
		local txt_power = obj:getChildAutoType("txt_power")
		checkTeam:setSelectedIndex(1)
		checkState:setSelectedIndex(index - 1)
		list_hero:setItemRenderer(function(idx2,obj2)
			local heroCell = BindManager.bindHeroCell(obj2)
			heroCell:setData(data.array[idx2+1])
			combat = combat + data.array[idx2+1].combat
		end)
		list_hero:setData(data.array)
		txt_power:setText(StringUtil.transValue(combat or 0))
		txt_playerName:setText(data.name)  
	end)
	self.list_otherSquad:setData(otherSquadInfo)
end

-- 倒计时
function CrossTeamPVPSquadSortView:updateCountTimer()
	local serverTime = ServerTimeModel:getServerTime()
	local reqTime  	= CrossTeamPVPModel.matchInfo.endMs or 0
	local limitTime  = math.floor(reqTime/1000) - serverTime
	self.txt_timer:setText(limitTime)
	local onCountDown = function(dt) 
		limitTime = limitTime - dt 
		if not tolua.isnull(self.txt_timer) then
			self.txt_timer:setText(math.floor(limitTime))
		end
		if limitTime <= 0 then
			if not tolua.isnull(self.txt_timer) then
				self.txt_timer:setText(0)
			end
			Scheduler.unschedule(self.timer)
			self.timer = false
			-- 结束后须直接跳转进入战斗 -- 后续添加
		end
	end

	self.timer = Scheduler.schedule(function(dt)
		onCountDown(dt)
    end,0.1)
end

function CrossTeamPVPSquadSortView:_exit()
	if self.timer then
		Scheduler.unschedule(self.timer)
		self.timer = false
	end
end

return CrossTeamPVPSquadSortView