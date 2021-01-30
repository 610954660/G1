--Date :2020-12-10
--Author : wyz
--Desc : 组队竞技  备战/战斗界面

local CrossTeamPVPAddTopView,Super = class("CrossTeamPVPAddTopView", Window)

function CrossTeamPVPAddTopView:ctor()
	--LuaLog("CrossTeamPVPAddTopView ctor")
	self._packName = "CrossTeamPVP"
	self._compName = "CrossTeamPVPAddTopView"
	--self._rootDepth = LayerDepth.PopWindow
	self.timer = false
end

function CrossTeamPVPAddTopView:_initEvent( )
	
end

function CrossTeamPVPAddTopView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossTeamPVP.CrossTeamPVPAddTopView
	self.checkState = viewNode:getController('checkState')--Controller
	self.item_1 = viewNode:getChildAutoType('item_1')--battleItem
	self.item_2 = viewNode:getChildAutoType('item_2')--battleItem
	self.item_3 = viewNode:getChildAutoType('item_3')--battleItem
	self.txt_timer = viewNode:getChildAutoType('txt_timer')--GTextField
	self.txt_tips = viewNode:getChildAutoType('txt_tips')--GTextField
	--{autoFieldsEnd}:CrossTeamPVP.CrossTeamPVPAddTopView
	--Do not modify above code-------------
end

function CrossTeamPVPAddTopView:_initUI( )
	self:_initVM()
	self:CrossTeamPVPAddTopView_refreshPanel()
end


function CrossTeamPVPAddTopView:CrossTeamPVPAddTopView_refreshPanel()
	printTable(8848,">>>>CrossTeamPVPModel.interfaceType>>>>>>",CrossTeamPVPModel.interfaceType)
	if CrossTeamPVPModel.interfaceType == 1 then 	-- 啥也不显示
		self.checkState:setSelectedIndex(2)
	elseif CrossTeamPVPModel.interfaceType == 2 then 	-- 显示倒计时
		self.checkState:setSelectedIndex(0)
		self:updateCountTimer()
	elseif CrossTeamPVPModel.interfaceType == 3 then 	-- 显示胜负
		self.checkState:setSelectedIndex(1)
	end
	self:refreshPanel()
end

function CrossTeamPVPAddTopView:refreshPanel()
	for i=1,3 do
		local item = self.view:getChildAutoType("item_"..i) 
		local checkWin = item:getController("checkWin") -- 0赢了 1输了 2啥也不显示
		local isInFight = item:getController("isInFight") -- 0不是 1是
		if CrossTeamPVPModel.fightIndex == i-1 then
			isInFight:setSelectedIndex(1)
			checkWin:setSelectedIndex(2)
		else
			isInFight:setSelectedIndex(0)
		end
		if CrossTeamPVPModel.fightData and CrossTeamPVPModel.fightIndex >= i then
			local data = CrossTeamPVPModel.fightData[i]
			if data then
				checkWin:setSelectedIndex(data.result and 0 or 1)
			else
				checkWin:setSelectedIndex(2)
			end
		else
			checkWin:setSelectedIndex(2)
		end
	end
end

-- 倒计时
function CrossTeamPVPAddTopView:updateCountTimer()
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
			CrossTeamPVPModel.interfaceType = 3
			Scheduler.unschedule(self.timer)
			self.timer = false
			-- 结束后须直接跳转进入战斗 -- 后续添加
		end
	end

	self.timer = Scheduler.schedule(function(dt)
		onCountDown(dt)
    end,0.1)
end

function CrossTeamPVPAddTopView:_exit()
	if CrossTeamPVPModel.interfaceType == 2 then
		CrossTeamPVPModel:reqAdjust()
	end

	if self.timer then
		Scheduler.unschedule(self.timer)
		self.timer = false
	end
	local requseInfo = {
        fightId	= 1070000,
        playerId = tonumber(PlayerModel.userid),
        gamePlay = GameDef.BattleArrayType.WorldTeamArena,
	}
	local tips = ModuleUtil.getModuleOpenTips(ModuleId.CrossTeamPVP.id)
    local function success(data)
        local array = data.array or {}
        local defenderNum = TableUtil.GetTableLen(array)
        print(8848,">>>>>defenderNum>>>>",defenderNum)
        if defenderNum > 0 and CrossTeamPVPModel.isFirstPrep then
            ModuleUtil.openModule(ModuleId.CrossTeamPVP.id, true);
		end
    end
	RPCReq.Battle_GetOpponentBattleArray(requseInfo,success)
end



return CrossTeamPVPAddTopView