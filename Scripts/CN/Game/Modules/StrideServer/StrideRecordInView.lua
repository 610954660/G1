--Date :2020-12-27
--Author : added by xhd
--Desc : 竞猜页面

local StrideRecordInView,Super = class("StrideRecordInView", Window)

function StrideRecordInView:ctor()
	--LuaLog("StrideRecordInView ctor")
	self._packName = "StrideServer"
	self._compName = "StrideRecordInView"
	self.leftData = false
	self.rightData = false
	self.data =false
	self._rootDepth = LayerDepth.PopWindow
	self.timer = false
	self.fightData = {}
	self.recordIds = {}
	self.panelShowFlag = false
end

function StrideRecordInView:_initEvent( )
	
end

function StrideRecordInView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:StrideServer.StrideRecordInView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.btn_record = viewNode:getChildAutoType('btn_record')--GButton
	self.cost = viewNode:getChildAutoType('cost')--GGroup
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.itemicon = viewNode:getChildAutoType('itemicon')--GLoader
	self.itemnum = viewNode:getChildAutoType('itemnum')--GTextField
	self.jincaiBtn1 = viewNode:getChildAutoType('jincaiBtn1')--GButton
	self.jincaiBtn2 = viewNode:getChildAutoType('jincaiBtn2')--GButton
	self.leftGCtrl = viewNode:getController('leftGCtrl')--Controller
	self.leftName = viewNode:getChildAutoType('leftName')--GTextField
	self.leftPnum = viewNode:getChildAutoType('leftPnum')--GTextField
	self.leftPower = viewNode:getChildAutoType('leftPower')--GTextField
	self.leftRate = viewNode:getChildAutoType('leftRate')--GTextField
	self.leftSIcon = viewNode:getChildAutoType('leftSIcon')--GLoader
	self.leftScore = viewNode:getChildAutoType('leftScore')--GTextField
	self.leftServerName = viewNode:getChildAutoType('leftServerName')--GTextField
	self.leftgTxt = viewNode:getChildAutoType('leftgTxt')--GTextField
	self.list_group = viewNode:getChildAutoType('list_group')--GList
	self.lplayName = viewNode:getChildAutoType('lplayName')--GTextField
	self.lplayerCell = viewNode:getChildAutoType('lplayerCell')--GButton
	self.lserverName = viewNode:getChildAutoType('lserverName')--GTextField
	self.progressBar = viewNode:getChildAutoType('progressBar')--G1ProgressBar6
		self.progressBar.bg = viewNode:getChildAutoType('progressBar/bg')--GImage
	self.resultCtrl = viewNode:getController('resultCtrl')--Controller
	self.rightGCtrl = viewNode:getController('rightGCtrl')--Controller
	self.rightName = viewNode:getChildAutoType('rightName')--GTextField
	self.rightPnum = viewNode:getChildAutoType('rightPnum')--GTextField
	self.rightPower = viewNode:getChildAutoType('rightPower')--GTextField
	self.rightRate = viewNode:getChildAutoType('rightRate')--GTextField
	self.rightSIcon = viewNode:getChildAutoType('rightSIcon')--GLoader
	self.rightScore = viewNode:getChildAutoType('rightScore')--GTextField
	self.rightSeverName = viewNode:getChildAutoType('rightSeverName')--GTextField
	self.rightgTxt = viewNode:getChildAutoType('rightgTxt')--GTextField
	self.rplayName = viewNode:getChildAutoType('rplayName')--GTextField
	self.rplayerCell = viewNode:getChildAutoType('rplayerCell')--GButton
	self.rserverName = viewNode:getChildAutoType('rserverName')--GTextField
	self.statusCtrl = viewNode:getController('statusCtrl')--Controller
	self.time = viewNode:getChildAutoType('time')--GTextField
	self.winCtrl = viewNode:getController('winCtrl')--Controller
	--{autoFieldsEnd}:StrideServer.StrideRecordInView
	--Do not modify above code-------------
end

function StrideRecordInView:_initListener( )
	self.btn_record:addClickListener(function()
		ViewManager.open("StrideGuessRecordView")
	end)
	self.btn_help:removeClickListener()
	self.btn_help:addClickListener(function()
		local info={}
		info['title']=Desc["help_StrTitle269"]
		info['desc']=Desc["help_StrDesc269"]
		ViewManager.open("GetPublicHelpView",info) 
	end)

	self.list_group:setItemRenderer(function(index, obj)
		local visCtrl = obj:getController("visCtrl")
		local title = obj:getChildAutoType("title")
		title:setText("第"..(index+1).."队")
		local selfUI = obj:getChildAutoType("self")
		local otherUI = obj:getChildAutoType("other")
		local btn_details = obj:getChildAutoType("btn_details")
		btn_details:setVisible(false)
		--self
		local txt_power1 = selfUI:getChildAutoType("txt_power")
		local txt_playerName1 = selfUI:getChildAutoType("txt_playerName")
		local winVisCtrl1 = selfUI:getController("winVisCtrl")
		local teamCtrl1 = selfUI:getController("teamCtrl")
		local listHero1 = selfUI:getChildAutoType("list_hero")
		winVisCtrl1:setSelectedIndex(0)
		teamCtrl1:setSelectedIndex(1)

		--other
		local listHero2 = otherUI:getChildAutoType("list_hero")
		local txt_power2 = otherUI:getChildAutoType("txt_power")
		local txt_playerName2 = otherUI:getChildAutoType("txt_playerName")
		local checkWinCtrl2 = otherUI:getController("checkWin")
		local winVisCtrl2 = otherUI:getController("winVisCtrl")
		local teamCtrl2 = otherUI:getController("teamCtrl")
		winVisCtrl2:setSelectedIndex(0)
		teamCtrl2:setSelectedIndex(1)
		if not self.panelShowFlag then
			if index == 2 then
				visCtrl:setSelectedIndex(0)
				return
			else
				visCtrl:setSelectedIndex(1)
			end
			--可见 
			-- btn_details:removeClickListener(100)
			-- btn_details:addClickListener(function()
			-- end,100)
			local teamList = self.leftData.teamList
			local cellInfo = teamList[index+1]
			txt_power1:setText(cellInfo.combat) --战斗力
			txt_playerName1:setText(self.leftData.name) --玩家名字
			local heroInfos = cellInfo.heroInfos --英雄详情数据
			-- listHero1:setVirtual()
			listHero1:setItemRenderer(function(index2, obj2)
				--组织数据
				local heroInfo = heroInfos[index2 + 1]
				heroInfo.category = heroInfo.code > 100000 and DynamicConfigData.t_monster[heroInfo.code].category or DynamicConfigData.t_hero[heroInfo.code].category
				local heroCell = BindManager.bindHeroCell(obj2)
				heroCell:setBaseData(heroInfo)
				-- obj1:addClickListener(function ()
				-- 	if (heroInfo.uuid) then
				-- 		local data = {
				-- 			playerInfo = self.data,
				-- 			heroArray = heroList,
				-- 			index = idx1 + 1
				-- 		}
				-- 		Dispatcher.dispatchEvent(EventType.HeroInfo_Show, data)
				-- 	else
				-- 		RollTips.show(Desc.Friend_cant_show)
				-- 	end
				-- end)
			end)
			listHero1:setData(heroInfos)
			local teamList = self.rightData.teamList
			local cellInfo = teamList[index+1]
			txt_power2:setText(cellInfo.combat) --战斗力
			txt_playerName2:setText(self.rightData.name) --玩家名字
			local heroInfos = cellInfo.heroInfos --英雄详情数据
			listHero2:setVirtual()
			listHero2:setItemRenderer(function(index2, obj2)
				--组织数据
				local heroInfo = heroInfos[index2 + 1]
				heroInfo.category = heroInfo.code > 100000 and DynamicConfigData.t_monster[heroInfo.code].category or DynamicConfigData.t_hero[heroInfo.code].category
				local heroCell = BindManager.bindHeroCell(obj2)
				heroCell:setBaseData(heroInfo)
				-- obj1:addClickListener(function ()
				-- 	if (heroInfo.uuid) then
				-- 		local data = {
				-- 			playerInfo = self.data,
				-- 			heroArray = heroList,
				-- 			index = idx1 + 1
				-- 		}
				-- 		Dispatcher.dispatchEvent(EventType.HeroInfo_Show, data)
				-- 	else
				-- 		RollTips.show(Desc.Friend_cant_show)
				-- 	end
				-- end)
			end)
			listHero2:setData(heroInfos)
		else
			visCtrl:setSelectedIndex(1)
			btn_details:setVisible(true)
			btn_details:removeClickListener(100)
			btn_details:addClickListener(function()
				ViewManager.open("BattledataView",{isWin = self.fightData[index+1].result,isRecord = true,battleData = self.fightData[index+1]})
			end,100)
			local teamList = self.leftData.teamList
			local cellInfo = teamList[index+1]
			txt_power1:setText(cellInfo.combat) --战斗力
			txt_playerName1:setText(self.leftData.name) --玩家名字

			local fightData = self.fightData[index + 1]
			local data = fightData.battleObjSeq
			local selfHeros = {}
			local otherHeros = {}
			for _, d in pairs(data) do
				if (d.type~=3 and d.type~=4) then
					if d.id> BattleModel.HeroPos.enemy.pos then
						table.insert( otherHeros,d)
					else
						table.insert( selfHeros,d)
					end
				end
			end
			local heroInfos = selfHeros
			listHero1:setVirtual()
			listHero1:setItemRenderer(function(index2, obj2)
				--组织数据
				local hd = heroInfos[index2 + 1]
				local conf = hd.type == 1 and DynamicConfigData.t_hero[hd.code] or DynamicConfigData.t_monster[hd.code]
				if (conf) then
					hd.category = conf.category
					local heroCell = BindManager.bindHeroCell(obj2)
					heroCell:setBaseData(hd)
				end
				local isAlive = hd.finalHp > 0
				obj2:getController("grayCtrl"):setSelectedIndex(isAlive and 0 or 1)
				-- obj1:addClickListener(function ()
				-- 	if (heroInfo.uuid) then
				-- 		local data = {
				-- 			playerInfo = self.data,
				-- 			heroArray = heroList,
				-- 			index = idx1 + 1
				-- 		}
				-- 		Dispatcher.dispatchEvent(EventType.HeroInfo_Show, data)
				-- 	else
				-- 		RollTips.show(Desc.Friend_cant_show)
				-- 	end
				-- end)
			end)
			listHero1:setData(heroInfos)

			local teamList = self.rightData.teamList
			local cellInfo = teamList[index+1]
			txt_power2:setText(cellInfo.combat) --战斗力
			txt_playerName2:setText(self.rightData.name) --玩家名字
			local heroInfos = otherHeros
			-- listHero2:setVirtual()
			listHero2:setItemRenderer(function(index2, obj2)
				local hd = heroInfos[index2 + 1]
				local conf = hd.type == 1 and DynamicConfigData.t_hero[hd.code] or DynamicConfigData.t_monster[hd.code]
				if (conf) then
					hd.category = conf.category
					local heroCell = BindManager.bindHeroCell(obj2)
					heroCell:setBaseData(hd)
				end
				local isAlive = hd.finalHp > 0
				obj2:getController("grayCtrl"):setSelectedIndex(isAlive and 0 or 1)
				-- obj1:addClickListener(function ()
				-- 	if (heroInfo.uuid) then
				-- 		local data = {
				-- 			playerInfo = self.data,
				-- 			heroArray = heroList,
				-- 			index = idx1 + 1
				-- 		}
				-- 		Dispatcher.dispatchEvent(EventType.HeroInfo_Show, data)
				-- 	else
				-- 		RollTips.show(Desc.Friend_cant_show)
				-- 	end
				-- end)
			end)
			listHero2:setData(heroInfos)
		end
	end)

end

--竞猜结果回调
function StrideRecordInView:update_stride_guessMain(_,params)
	self.data  =StrideServerModel:getGuessDataInfo()
	RollTips.show("下注成功")
	self:updateGuess()
end

function StrideRecordInView:update_stride_GuessPanelInfo(_,params)
	self.data  =StrideServerModel:getGuessDataInfo()
	if not self.data.flag then
		--没有竞猜数据
		self.statusCtrl:setSelectedIndex(0)
		return
	end
	local smallState = StrideServerModel:getSmallStage(  )
	if smallState == 1 then
		self.panelShowFlag = false
		self.statusCtrl:setSelectedIndex(1)
		self:updatePanel()
	elseif smallState == 3 then
		self.panelShowFlag = true
		self.statusCtrl:setSelectedIndex(2)
		if self.data.result ==1 then
			self.resultCtrl:setSelectedIndex(1) --成
		elseif self.data.result ==2 then
			self.resultCtrl:setSelectedIndex(2) --败
		elseif self.data.result ==3 then
			self.resultCtrl:setSelectedIndex(0) --未参与
		else
			--未结算
			self.resultCtrl:setSelectedIndex(0)
		end
		--如果已经结束 去请求战报数据
		self.recordIds = self.data.recordIdList
		for key,fightId in pairs(self.recordIds) do
			BattleModel:requestBattleRecord(fightId)
		end
	end 

end

function StrideRecordInView:_initUI( )
	self:_initVM()
	self:_initListener()
	self.statusCtrl:setSelectedIndex(1)
	StrideServerModel:reqGetGuessPanelInfo( )
end

--更新巅峰币
function StrideRecordInView:updateCost( ... )
	if self.data.isGuess then
		self.itemnum:setText("0")
	else
		self.itemnum:setText(DynamicConfigData.t_TopArenaConfig[1].guessPoint)
	end
end

function StrideRecordInView:updatePanel( ... )
	self.data  =StrideServerModel:getGuessDataInfo()
	self.leftData = self.data.leftTeamInfo
	self.rightData = self.data.rightTeamInfo
	self.list_group:setNumItems(3)

	local lplayerCellObj= BindManager.bindPlayerCell(self.lplayerCell)
	local rplayerCellObj= BindManager.bindPlayerCell(self.rplayerCell)
	lplayerCellObj:setHead(self.data.playerInfo[1].head, self.data.playerInfo[1].level, self.data.playerInfo[1].playerId, self.data.playerInfo[1].name, self.data.playerInfo[1].headBorder)
	rplayerCellObj:setHead(self.data.playerInfo[2].head, self.data.playerInfo[2].level, self.data.playerInfo[2].playerId, self.data.playerInfo[2].name, self.data.playerInfo[2].headBorder)

	self.leftScore:setText(self.data.playerInfo[1].score)
	self.rightScore:setText(self.data.playerInfo[2].score)

	self.leftPower:setText(self.data.playerInfo[1].combat)
	self.rightPower:setText(self.data.playerInfo[2].combat)

	self.lplayName:setText(self.data.playerInfo[1].name)
	self.rplayName:setText(self.data.playerInfo[2].name)

	self:updateGuess()
end

function StrideRecordInView:updateGuess( ... )
	self:updateCost()
	--竞猜倒计时
	if self.timer then
		TimeLib.clearCountDown(self.timer)
		self.timer= false
	end
	local lastTime = self.data.endTime - ServerTimeModel:getServerTimeMS()
	lastTime = lastTime/1000
	self.time:setText(TimeLib.GetTimeFormatDay(lastTime,2))
	local function onCountDown(time)
		if not tolua.isnull(self.view) then
			self.time:setText(TimeLib.GetTimeFormatDay(lastTime, 2))
		end
	end
	local function onEnd(...)
		if not tolua.isnull(self.view) then
		self.time:setText("已结束") -- [1]="已结束"
		end
	end

	self.timer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
	local maxNum = self.data.guessNumList[1] + self.data.guessNumList[2]
	self.progressBar:setMax(maxNum)
	self.progressBar:setMin(0)
	if maxNum == 0 then
		self.progressBar:setMax(1)
		self.progressBar:setValue(0.5)
	else
		self.progressBar:setValue(self.data.guessNumList[1])
	end

	
	self.leftName:setText(self.data.playerInfo[1].name)
	self.rightName:setText(self.data.playerInfo[2].name)
	
	-- local serverName = ""
	-- local serverGroup = LoginModel:getServerGroups()
	-- for _, d in pairs(serverGroup) do
	-- 	for _, info in pairs(d) do
	-- 		if (info.unit_server == self.data.playerInfo[1].serverId) then
	-- 			serverName = info.name;
	-- 		end
	-- 	end
	-- end
	if not self.data.playerInfo[1].serverId then
		self.leftServerName:setText("")
		self.lserverName:setText("")
	else
		self.leftServerName:setText("[S."..self.data.playerInfo[1].serverId.."]")
		self.lserverName:setText("[S."..self.data.playerInfo[1].serverId.."]")
	end
	
	-- local serverGroup = LoginModel:getServerGroups()
	-- for _, d in pairs(serverGroup) do
	-- 	for _, info in pairs(d) do
	-- 		if (info.unit_server == self.data.playerInfo[2].serverId) then
	-- 			serverName = info.name;
	-- 		end
	-- 	end
	-- end
	if not self.data.playerInfo[2].serverId then
		self.rserverName:setText("")
		self.rightSeverName:setText("")
	else
		self.rserverName:setText("[S."..self.data.playerInfo[2].serverId.."]")
		self.rightSeverName:setText("[S."..self.data.playerInfo[2].serverId.."]")
	end


	self.leftRate:setText(string.format("%.2f",self.data.rateList[1]/100))
	self.rightRate:setText(string.format("%.2f",self.data.rateList[2]/100))

	self.leftPnum:setText(self.data.guessNumList[1])
	self.rightPnum:setText(self.data.guessNumList[2])
	
	self.jincaiBtn1:removeClickListener(88)
	self.jincaiBtn1:addClickListener(function( ... )
		local smallStage =  StrideServerModel:getSmallStage(  )
		if smallStage == 1 and self.data.isGuess then
			RollTips.show("今日已竞猜！")
			return
		end
		local info = {}
		local guessPoint = DynamicConfigData.t_TopArenaConfig[1].guessPoint
		info.text = "当前该玩家竞猜赔率为"..string.format("[color=#119717]%.2f",self.data.rateList[1]/100).."[/color]是否投入[color=#119717]"..guessPoint.."[/color]竞猜币猜他赢?"
		info.type = "yes_no"
		info.onYes = function( ... )
			-- body
			StrideServerModel:reqDoGuess( self.data.playerInfo[1].playerId )
		end
		Alert.show(info);
	end,88)

	self.jincaiBtn2:removeClickListener(88)
	self.jincaiBtn2:addClickListener(function( ... )
		local smallStage =  StrideServerModel:getSmallStage(  )
		if smallStage == 1 and self.data.isGuess then
			RollTips.show("今日已竞猜！")
			return
		end
		local info = {}
		local guessPoint = DynamicConfigData.t_TopArenaConfig[1].guessPoint
		info.text =  "当前该玩家竞猜赔率为"..string.format("[color=#119717]%.2f",self.data.rateList[2]/100).."[/color]是否投入[color=#119717]"..guessPoint.."[/color]竞猜币猜他赢?"
		info.type = "yes_no"
		info.onYes = function( ... )
			-- body
			StrideServerModel:reqDoGuess( self.data.playerInfo[2].playerId )
		end
		Alert.show(info);
	end,88)
	
	if self.data.isGuess and self.data.choosePlayerId == self.data.playerInfo[1].playerId then
		self.leftGCtrl:setSelectedIndex(1)
	else
		self.leftGCtrl:setSelectedIndex(0)
	end

	if self.data.isGuess and self.data.choosePlayerId == self.data.playerInfo[2].playerId then
		self.rightGCtrl:setSelectedIndex(1)
	else
		self.rightGCtrl:setSelectedIndex(0)
	end
end


function StrideRecordInView:_exit()
	if self.timer then
		TimeLib.clearCountDown(self.timer)
		self.timer = false
	end
	if self.scheduler then
		Scheduler.unschedule(self.scheduler)
		self.scheduler = false
	end
end

--战报回来
function StrideRecordInView:Battle_BattleRecordData(_, param)
    if (#self.fightData < #self.recordIds) then
		table.insert(self.fightData,param.battleData)
    end
    if (#self.fightData == #self.recordIds) then
        if (tolua.isnull(self.view)) then return end
        self:updatePanel()
	end
end


return StrideRecordInView