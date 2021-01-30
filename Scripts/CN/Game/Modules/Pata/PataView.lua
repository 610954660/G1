local PataView,Super = class("PataView", Window)

local SeatItem=require "Game.Modules.Battle.Cell.SeatItem"
local HeroPos = ModelManager.BattleModel.HeroPos
local ItemCell = require "Game.UI.Global.ItemCell"
function PataView:ctor()
	LuaLogE("PataView ctor")
	self._packName = "Pata"
	self._compName = "PataView"
	self._rootDepth = LayerDepth.Window

	self.closeBtn = false
	self.floorList = false
	self.curFloor = 1
	self.realFloor = 1
	self.anctionHandler = false
	self.challenge=false
	self.enemyList =false
	self.towerList=false
	self.floorText=false
	self.heoList=false
	self.btnHelp=false
	self.btnSweep=false
	self.txtSweep = false
	self.btnRank = false
	self.headInfos = {}
	self.reqFriendTime = 0
	self.curTowerItem=false
	self.curTowerItemIndex=false
	self.nextTowerItem=false
	self.allTower=9999
	self.top = false
	self.bottom = false
	self.scrollTower = false
	self.itemList=false
	self.limitTime=false
	self.fog=false
	self.fogMoveDistance=0
	self.moveBg1=false
	self.moveBg2=false
	self.mapIcon=false
	self.haveBigReceive=false
	self.moveOffestY=0
	--self._hideCloseBtn = true
	self.remainTimes = 0
	self.sweepBuyCount = 0
	self.scrollTween = false
	self.rankInfo = false
	self.doorTimer = false
	self.isDoorPlaying = false
	self.skipArray=false
	self.skipToggle=false
	
	self.hadPassAll=false

end

function PataView:_initVM( )
	self.skipToggle=self.view:getChildAutoType("skipToggle")
	self.skipToggle:addClickListener(function ()
			self.skipArray = self.skipToggle:isSelected()
			PataModel:saveSkipArray(GameDef.BattleArrayType.Tower, self.skipArray)
	end)
	if PataModel:checkSkipArray(GameDef.BattleArrayType.Tower) then
		self.skipToggle:setSelected(true)
		self.skipArray =true
	end
	
	
end

function PataView:_initUI()
	LuaLogE("PataView _initUI")
	self:_initVM()

	self.curFloor = ModelManager.PataModel:getCurFloor()
	--self.closeBtn = self.view:getChildAutoType("frame/closeBtn")
	--self.floorList = self.view:getChildAutoType("floorList")
	self.itemList=self.view:getChildAutoType("itemList")
	self:setTitle(self._args.name)

	--self._titleLabel:setText("")
	self.enemyList = self.view:getChildAutoType("enemyList")
	self.towerList = self.view:getChildAutoType("towerList")
	self.floorText = self.view:getChildAutoType("floorText")
	self.txtLimitString=self.view:getChildAutoType("txtLimitString")
	if self._args.category then
		self.txtLimitString:setText(string.format(Desc.pata_desc5,self._args.category))
	end
	
	
	--self.towerList:getScrollPane():setTouchEffect(false)
	self.towerList:getScrollPane():setMouseWheelEnabled(false)
	self.towerList:setVisible(false)
	self.btnHelp = self.view:getChildAutoType("btn_help")
	self.btnSweep = self.view:getChildAutoType("btnSweep")
	--self.txtSweep = self.view:getChildAutoType("txt_sweep")
	self.btnRank = self.view:getChildAutoType("btn_rank")
	self.challenge = self.view:getChildAutoType("challenge")
	self.fightRecor = self.view:getChildAutoType("fightRecor")
	self.fog = self.view:getChildAutoType("fog")
	self.moveOffestY = self.fog:getPosition().y
	self.moveBg1 = self.view:getChildAutoType("moveBg1")
	self.moveBg2 = self.view:getChildAutoType("moveBg2")
	self.mapIcon = self.view:getChildAutoType("mapIcon")
	self.bigReward = self.view:getChildAutoType("bigReward")
	self.topFirst = self.view:getChildAutoType("topFirst")
	self.txtTopPlayerName = self.topFirst:getChildAutoType("txtTopPlayerName")
	self.txtTopLevelWait = self.topFirst:getChildAutoType("txtTopLevelWait")
	self.txtTopLevel = self.topFirst:getChildAutoType("txtTopLevel")
	self.fistPass=self.view:getChildAutoType("fistPass")
	
	
	self.topPlayerCell = BindManager.bindPlayerCell(self.topFirst:getChildAutoType("playerCell"))
	self.hadPass=self.view:getController("hadPass")
	
	
	self.topPlayerCell.playerName:setVisible(false)
	self.moveBg1:setURL(PathConfiger.getBg("pataMoveBg.jpg"))
	self.moveBg2:setURL(PathConfiger.getBg("pataMoveBg.jpg"))
	self.mapIcon:setIcon(PathConfiger.getMapBg(DynamicConfigData.t_towerType[self._args.activeType].uiBG))
	self.heoList = {}
	self.topFirst:setVisible(false)
	
	
	

	self.topFirst:addClickListener(function()
			Dispatcher.dispatchEvent(EventType.Friend_OpenInfoView,{playerId = self.topPlayerCell.playerId})
	end)
	
	self.btnSweep:addClickListener(function()
		if self.limitTime>0 and self.curFloor>1 then
			self:onSweepClick(function ()
				self:updateFloor()
			end)
		else
			ModelManager.PataModel:sweepTower(function ()
				self:updateFloor()
			end)
		end
		-- ModelManager.PataModel:setSuccess( self._args.activeType )
	end)

	self.challenge:addClickListener(function()
		 Dispatcher.dispatchEvent(EventType.pata_beginChallege)--继续挑战下一层
	end)

	self.bigReward:addClickListener(function()
		if self.haveBigReceive then
			local function success(data)
				local copyInfo = ModelManager.MaterialCopyModel:getCopyInfo( self._args.activeType )
				copyInfo.diffPass.bigReward=data.bigReward
				if tolua.isnull(self.view) then return end
				self:updateBigReward()
			end
			local params = {
				gamePlayType = self._args.activeType
			}
			RPCReq.Copy_GetTowerBigReward(params,success)
		else
			ViewManager.open("PataBigReWard")
		end
	end)

	self.fightRecor:addClickListener(function ()
		self:reRecordInfo(self.curFloor)
	end)

	self.btnRank:addClickListener(function()
		--打开rank界面
		local rankCount = ModelManager.MaterialCopyModel:getCopyCount( GameDef.GamePlayType.TowerTopInfo )
		print(1,'rank click excute' , rankCount)
		if self._args.activeType == 2000 and rankCount == 0 then
			self:reqPataRank()
		else
			ViewManager.open("PublicRankView", {type = self._args.rankType})
		end
	end)

	self.enemyList:setItemRenderer(function( index,child )
		local itemCell=false
		if self.heoList[index] then
			itemCell = self.heoList[index]
		else
			itemCell = BindManager.bindSeatItem(child)
			self.heoList[index]=itemCell
		end
		itemCell.index = index
		itemCell.heroPos = index == 0 and HeroPos.player or HeroPos.enemy
		if index == 0 then
			local heroInfo = DynamicConfigData.t_hero[ModelManager.HandbookModel.heroOpertion]
			itemCell:initItemCell(ModelManager.HandbookModel.heroOpertion,heroInfo.heroStar,1,1, ModelManager.HandbookModel.fashionCode)
			itemCell.controller:setSelectedIndex(0)
		elseif index == 1 then
			local cfg_tower = DynamicConfigData.t_tower[self._args.activeType]
			local cfg_Fight = DynamicConfigData.t_fight
			local floorInfo = cfg_tower[self.curFloor] or DT
			local fightInfo = cfg_Fight[floorInfo.fightId or 1]
			local enemyLevel = fightInfo.level1
			local monsterId = fightInfo.monsterId1

			for i = 1,8 do
				if fightInfo["level"..i] > enemyLevel then
					enemyLevel = fightInfo["level"..i]
					monsterId = fightInfo["monsterId"..i]
				end
			end

			local star= fightInfo["star"..(index+1)]
			if monsterId then
				itemCell:initItemCell(monsterId,star,enemyLevel,2)
			end
		end
	end)

	self.towerList:addEventListener(FUIEventType.Scroll,function()
		if not self.rankInfo or not self.rankInfo[1] then
			return
		end

		if self.curFloor >= self.rankInfo[1].value then
			self.topFirst:setVisible(false)
			return
		end

		local childIndex = self.towerList:itemIndexToChildIndex(self.towerList:getFirstChildInView())
		local child = self.towerList:getChildAt(childIndex)
		if child then
			local firstFloor = tonumber(child:getChildAutoType("title"..self._args.type):getText())
			self.topFirst:setVisible(firstFloor < self.rankInfo[1].value)
			self.topFirst:setVisible(firstFloor < self.rankInfo[1].value)	
	    end
	end,1)

	--PataModel.activeType = self._args.activeType
	PataModel:setViewArgs(self._args)
	
	PataModel:updateRed()
	self.towerList:setChildrenRenderOrder(1)
	if self._args.space then
		self.towerList:setLineGap(self._args.space)
	end
	self:setAllTower()
	self:updateFloor()
	self:loadMonster(false)
	self:reqFriends(self.curFloor)
end

--显示当前数据
function PataView:initData()
	local cfg_tower = DynamicConfigData.t_tower[self._args.activeType]
	local cfg_Fight = DynamicConfigData.t_fight
	local floorInfo = cfg_tower[self.curFloor] or DT
	local fightInfo = cfg_Fight[floorInfo.fightId or 1]

	self.floorText:setText(self.curFloor)
	self.towerList:setVirtual()
	self.towerList:setItemRenderer(function( index,child)
		local floorIndex = self.bottom + self.allTower - index - 1
		local floorCount = floorIndex % 2
		child:getChildAutoType("title"..self._args.type):setText(floorIndex)

		if floorIndex > self.curFloor then
			child:getController("hasPass"):setSelectedPage("false")
			child:getController("floortype"):setSelectedPage("next")
		end

		if floorIndex == self.curFloor then
			--self.curTowerItem=child
			self.curTowerItemIndex = index
			if not self.scrollTween then
				child:getController("hasPass"):setSelectedPage("false")
				child:getController("floortype"):setSelectedPage("cur")
			end
		end

		if floorIndex < self.curFloor or floorIndex  < self.realFloor or self.hadPassAll then
			child:getController("hasPass"):setSelectedPage("true")
			child:getController("floortype"):setSelectedPage("last")
		end

		child:getController("battleType"):setSelectedPage(tostring(self._args.type))
		child:getController("floorCount"):setSelectedIndex(floorCount)

		local pass = child:getChildAutoType("pass"..self._args.type)
		local headData = self.headInfos[floorIndex]
		local btnLevelInfo = pass:getChildAutoType("btnLevelInfo")
		local friendCount = pass:getChildAutoType("friendCount")

		if headData then
			local count =#headData
			friendCount:setText("x"..count)
			btnLevelInfo:setVisible(count>0)
			friendCount:setVisible(count>0)
			child:getChildAutoType("pass"..self._args.type):setVisible(count>0)
			btnLevelInfo:removeClickListener()
			btnLevelInfo:addClickListener(function()
				--打开关卡信息界面
				self:reqTowerFriendInfo(floorIndex)
			end)
		else
			btnLevelInfo:setVisible(false)
			friendCount:setVisible(false)
			child:getChildAutoType("pass"..self._args.type):setVisible(false)
		end

		local topInfo = self.rankInfo and self.rankInfo[1] or nil
		local towerRank = child:getChildAutoType("towerRank"..self._args.type)

		if self._args.type == 7 then
			towerRank:getController("pos"):setSelectedIndex(1 - floorIndex%2)
		else
			towerRank:getController("pos"):setSelectedIndex(1)
		end

		if topInfo and floorIndex == topInfo.value then
			local playerCell = BindManager.bindPlayerCell(towerRank:getChildAutoType("heroCell"))
			towerRank:setVisible(true)
			towerRank:getController("isFirst"):setSelectedIndex(self.curFloor == topInfo.value and 0 or 1)
			towerRank:getController("isReward"):setSelectedIndex(0)
			playerCell:setHead(topInfo.head,topInfo.level,topInfo.id,topInfo.name,topInfo.headBorder)
			playerCell.playerName:setVisible(false)
		elseif self.curFloor == floorIndex then
			local playerCell = BindManager.bindPlayerCell(towerRank:getChildAutoType("heroCell"))
			towerRank:setVisible(true)
			towerRank:getController("isFirst"):setSelectedIndex(0)
			towerRank:getController("isReward"):setSelectedIndex(0)
			playerCell:setHead(PlayerModel.head,PlayerModel.level,PlayerModel.userid,PlayerModel.username,PlayerModel.headBorder)
			playerCell.playerName:setVisible(false)
		else
			local allFloorReward = DynamicConfigData.t_towerBigReward[self._args.activeType]
			local currReward = nil
			if allFloorReward then
				for k,v in pairs(allFloorReward) do
					if v.level == floorIndex then
						currReward = v
						break
					end
				end
			end

			if currReward and self.curFloor < currReward.level then
				local itemCell = BindManager.bindItemCell(towerRank:getChildAutoType("itemCell"))
				local itemConfig = currReward.reward[1]
				towerRank:setVisible(true)
				towerRank:getController("isReward"):setSelectedIndex(1)
				itemCell:setData(itemConfig.code,itemConfig.amount,itemConfig.type)
			else
				towerRank:setVisible(false)
			end
		end
	end,1)
	self.towerList:setNumItems(self.allTower)
	self:pata_scrollToCurFloor()
	Scheduler.schedule(function()
		self:updateTopRank()
	end,0.1,1)
end


function PataView:pata_scrollToCurFloor()
	if self.curFloor > self._args.showCount - 2 then
		self.towerList:scrollToView(self:getCurrFloorIndex(false))
	else
		self.towerList:getScrollPane():scrollBottom()
	end
end

function PataView:nextFloorTest()
	if tolua.isnull(self.view) or self.curTowerItemIndex==false then
		return
	end
	if self.curFloor > self._args.showCount - 2 then
		self.towerList:scrollToView(self:getCurrFloorIndex(true))
	end

	local childIndex = self.towerList:itemIndexToChildIndex(self.curTowerItemIndex)
	self.nextTowerItem = self.towerList:getChildAt(childIndex) or false
	self.curTowerItem = self.towerList:getChildAt(childIndex + 1) or false
	
	if self.nextTowerItem then
		self.nextTowerItem:getController("hasPass"):setSelectedPage("false")
		self.nextTowerItem:getController("floortype"):setSelectedPage("next")
		self.nextTowerItem:getChildAutoType("door"):getTransition("doorOpen"):stop()
	end
	if self.curTowerItem then
		self.curTowerItem:getController("hasPass"):setSelectedPage("true")
		self.curTowerItem:getController("floortype"):setSelectedPage("last")
		self.curTowerItem:getChildAutoType("door"):getTransition("doorOpen"):stop()
	end
	--
	if self.curFloor > self._args.showCount - 2  then
		if not self.doorTimer then
			self.towerList:addEventListener(FUIEventType.ScrollEnd,function()
				print(999,"end")
				if not self.scrollTween then
					return
				end
				self.isDoorPlaying = true
				self.nextTowerItem:getChildAutoType("door"):getTransition("doorOpen"):playReverse()
				self.nextTowerItem:getChildAutoType("door"):getTransition("doorOpen"):stop()
				self.nextTowerItem:getChildAutoType("door"):getTransition("doorOpen"):play(function ()
					self.nextTowerItem:getController("hasPass"):setSelectedPage("false")
					self.nextTowerItem:getController("floortype"):setSelectedPage("cur")
					self.scrollTween = false
					self.isDoorPlaying = false
					self.towerList:removeEventListener(FUIEventType.ScrollEnd,1)
				end)
			end ,1)

			self.doorTimer = Scheduler.schedule(function()
				Scheduler.unschedule(self.doorTimer)
				self.doorTimer = false
				self.scrollTween = true
				self.towerList:scrollToView(self:getCurrFloorIndex(false),true)
			end,0.1,1)
		end
	else
		if not self.doorTimer then
			self.scrollTween = false
			self.towerList:removeEventListener(FUIEventType.ScrollEnd,1)
			self.doorTimer = Scheduler.schedule(function()
				Scheduler.unschedule(self.doorTimer)
				self.doorTimer = false
				self.isDoorPlaying = true
				print(999,"动画播放完")
				self.nextTowerItem:getChildAutoType("door"):getTransition("doorOpen"):playReverse()
				self.nextTowerItem:getChildAutoType("door"):getTransition("doorOpen"):stop()
				self.nextTowerItem:getChildAutoType("door"):getTransition("doorOpen"):play(function ()
					print(999,"动画播放完了")
					self.nextTowerItem:getController("hasPass"):setSelectedPage("false")
					self.nextTowerItem:getController("floortype"):setSelectedPage("cur")
					self.isDoorPlaying = false
				end)
			end,1,1)
		end
	end
end

function PataView:setAllTower()
	local max = #DynamicConfigData.t_tower[self._args.activeType]
	self.scrollTower = max > 50 and 50 or max

	self.bottom = self.curFloor - self.scrollTower + 1
	if self.bottom <= 0 then
		self.bottom = 1
	end

	self.top = self.curFloor + self.scrollTower - 1
	if self.top > max then
		self.top = max
	end

	self.allTower = self.top - self.bottom + 1
	self.scrollTower = self.allTower >= 50 and 50 or self.allTower
end

function PataView:getCurrFloorIndex(isNext)
	local ret = nil
	local diff = self._args.showCount - self._args.moveCount

	if not isNext then
		diff = diff + 1
	end

	if self.curFloor > self.scrollTower then
		ret = self.top - self.curFloor - diff
		ret = ret < 0 and 0 or ret
	else
		ret = self.allTower - self.curFloor - diff
	end
	return ret
end

function PataView:tweenFadeOut(time,finished)
	self.enemyList:displayObject():runAction(cc.Sequence:create(cc.FadeOut:create(time),cc.CallFunc:create(function()
		if finished then
			finished()
		end
	end)))
end

function PataView:tweenFadeIn(time,finished)
	self.enemyList:displayObject():runAction(cc.Sequence:create(cc.FadeIn:create(time),cc.CallFunc:create(function()
		if finished then
			finished()
		end
	end)))
end

function PataView:updateFloor(isFistLoad)
	if tolua.isnull(self.view) then return end
	local gameType = self._args.activeType
	self.curFloor = ModelManager.PataModel:getPataFloor(self._args.activeType,true)
	self.realFloor = ModelManager.PataModel:getPataFloor(self._args.activeType)
	local cfg_tower = DynamicConfigData.t_tower[self._args.activeType]
	if self.curFloor > #cfg_tower then
		self.curFloor = #cfg_tower
		self.hadPassAll=true --已通关
		self.hadPass:setSelectedIndex(1)
	end
	local floorInfo = cfg_tower[self.curFloor] or DT
	
	
	
	self.btnSweep:setVisible( gameType == 2000 and self.curFloor>1 )
	self.floorText:setText(self.curFloor)
	local sweepCount = ModelManager.MaterialCopyModel:getCopyCount( self._args.activeType )
	sweepCount = sweepCount ~= 1 and 1 or 0

	local remainTimes, maxTime = MaterialCopyModel:getRemainTumes(gameType)
	local daily = MaterialCopyModel:getCopyInfo(gameType).dailyInfo or {}
	self.remainTimes = remainTimes
	if self.remainTimes<1 then
		self.btnSweep:setText("扫  荡")
	else
		self.btnSweep:setText("免费扫荡")
	end
	local count = daily.times or 0
	local vipAdd = VipModel:getVipPrivilige(13)
	self.limitTime = maxTime + vipAdd - count
	self.sweepBuyCount = vipAdd - self.limitTime + 1
    self.fistPass:setVisible(true)
	self.itemList:setItemRenderer(function (index,obj)
		local itemcell = BindManager.bindItemCell(obj)
		local itemData = ItemsUtil.createItemData({data = floorInfo.rewardPre[index + 1]})
		itemcell:setItemData(itemData)
	end)
	self.itemList:setData(floorInfo.rewardPre)
	self:setAllTower()
	self:updateBigReward()
end

function PataView:updateBigReward(show)
	local copyInfo = ModelManager.MaterialCopyModel:getCopyInfo(self._args.activeType)
	printTable(086,"爬塔奖励",copyInfo)
	local allFloorReward = DynamicConfigData.t_towerBigReward[self._args.activeType]
	local bigReward = copyInfo.diffPass.bigReward

	if allFloorReward==nil or allFloorReward[bigReward]==nil then
		self.bigReward:setVisible(false)
		return
	end

	local bigReward = copyInfo.diffPass.bigReward

	printTable(086,bigReward,"copyInfo")

	self.haveBigReceive=false
	self.bigReward:getChildAutoType("itemList"):setItemRenderer(function (index,obj)
		local tempData = allFloorReward[bigReward]
		if tempData then
			self.haveBigReceive = self.curFloor > tempData.level or self.hadPassAll
			local itemcell = BindManager.bindItemCell(obj)
			local itemData = ItemsUtil.createItemData({data = tempData.reward[1]})
			local str = "可领取"
			if self.curFloor - 1 < tempData.level and not self.hadPassAll then
				local colorStr = ColorUtil.formatColorString1(tempData.level - self.curFloor + 1,"#6Aff60")
				str = string.format("再通%s层可领取",colorStr)
			end
			itemcell:setItemData(itemData)
			itemcell:setReceiveFrame(self.haveBigReceive)
			itemcell:setClickable(false)
			self.bigReward:getChildAutoType("txtCondition"):setText(str)
		end
	end)
	self.bigReward:getChildAutoType("itemList"):setNumItems(1)
	--self.bigReward:addClickListener(function()
         --ViewManager.open("PataBigReWard")
	--end)
	
	
end

function PataView:updateTopRank()
	RPCReq.Rank_GetRankData({rankType = self._args.rankType},function(res)
		self.rankInfo = res.rankData
		if tolua.isnull(self.view) then return end
		self.towerList:setNumItems(self.allTower)
		if not self.rankInfo or not self.rankInfo[1] or self.curFloor >= self.rankInfo[1].value then
			self.topFirst:setVisible(false)
			return
		end
		self.txtTopPlayerName:setText(self.rankInfo[1].name)
		self.txtTopLevelWait:setText(string.format("我在%s层等你",self.rankInfo[1].value))
		self.txtTopLevel:setText(string.format(self.rankInfo[1].level))
		self.topPlayerCell:setHead(self.rankInfo[1].head,self.rankInfo[1].level,self.rankInfo[1].id,self.rankInfo[1].name,self.rankInfo[1].headBorder)
		local childIndex = self.towerList:itemIndexToChildIndex(self.towerList:getFirstChildInView())
		local child = self.towerList:getChildAt(childIndex)
		local firstFloor = tonumber(child:getChildAutoType("title"..self._args.type):getText())
		self.topFirst:setVisible(firstFloor < self.rankInfo[1].value)
	end)
end

function PataView:loadMonster(needAnimation)
	if needAnimation then
		self:tweenFadeOut(1,function ()
			self:load()
			self:tweenFadeIn(1)
		end)
	else
		self:load()
		self.enemyList:setAlpha(1)
	end
end

function PataView:load()
	self.enemyList:setNumItems(2)
end



--获取好友、会员在某层信息
function PataView:reqTowerFriendInfo(floor)
	local params = {}
	params.gamePlayType = self._args.activeType
	params.level = floor

	RPCReq.Copy_GetTowerFriendInfo(params,function ( data )
		--printTable(PataPlayerView,"爬塔好友信息： ", data)
		if data and next(data.infos) then
			ViewManager.open("PataPlayerView" , data )
		end
	end)
end



--获取通关信息
function PataView:reqPassRank(floor)
	local params = {}
	params.gamePlayType = self._args.activeType
	params.level = floor
	RPCReq.Copy_GetTowerFriendInfo(params,function ( data )
		--printTable(1,"爬塔好友信息： ", data)
		ViewManager.open("PataLevelView" , data )
	end)
end

--获取战斗记录
function PataView:reRecordInfo(floor)
	local params = {}
	params.gamePlayType = self._args.activeType
	params.level = floor
	RPCReq.Copy_GetTowerRecordInfo(params, function ( data )
		printTable(999,"爬塔战斗信息", data)
		ViewManager.open("PataRecordView" , data )
	end)
end

--请求爬塔奖励
function PataView:reqPataRank()
	print(999,"排行奖励请求  ： ")
	RPCReq.Copy_GetTowerTopInfo({},function( data )
		ViewManager.open("PataRankView", {type = self._args.rankType})
		if #data.topInfo > 0 then
			ViewManager.open("PataRankReward" , data )
		end
		PataModel.topInfo=data.topInfo
	end)
end

function PataView:pata_showNext()
	if tolua.isnull(self.view) then
	   return 	
	end
	local testFloor = ModelManager.PataModel:getPataFloor(self._args.activeType,true)
	
	print(5656,testFloor,"pata_showNext")
	local cfg_tower = DynamicConfigData.t_tower[self._args.activeType]
	if testFloor > #cfg_tower then
		self.hadPassAll=true --已通关
		self.hadPass:setSelectedIndex(1)
	end
	print(999,"pata_showNext",testFloor,PataModel:getSuccess())
	if PataModel:getSuccess() then
		PataModel:resetSuccess()
		self:updateFloor()
		self:loadMonster(true)
		self:setAllTower()
		self:initData()
		if self.curFloor <= ModelManager.PataModel:getPataFloor(self._args.activeType) then
			self:nextFloorTest()
		end
	end
end

function PataView:_initEvent( ... )
	--self:addEventListener(EventType.pata_showNext,self)
	self.btnHelp:addClickListener(function()
		local info={}
		info['title']= Desc.pata_title
		info['desc']=Desc.pata_desc
		ViewManager.open("GetPublicHelpView",info)
	end)
end

--添加红点
function PataView:_addRed( ... )
	local imgRed = self.btnRank:getChildAutoType("img_red")
	RedManager.register( "V_TOWER_RANK" , imgRed , self.view , ModuleId.Tower.id )
	local imgRed2 = self.btnSweep:getChildAutoType("img_red")
	RedManager.register( "V_TOWER_SWEEP" , imgRed2 , self.view , ModuleId.Tower.id )
end

--爬塔玩家信息
function PataView:reqFriends(floor)
	local curTime = ServerTimeModel:getServerTimeMS()
	if curTime - self.reqFriendTime < 500 then
		return
	end
	self.reqFriendTime = curTime
	local params = {}
	local fromLevel = floor - 7
	local toLevel = floor + 3
	local maxLevel = #DynamicConfigData.t_tower[self._args.activeType]
	if fromLevel < 1 then
		fromLevel = 1
	end

	if toLevel > maxLevel then
		toLevel = maxLevel
	end

	params.gamePlayType = self._args.activeType
	params.fromLevel = fromLevel
	params.toLevel = toLevel

	RPCReq.Copy_GetTowerHead(params,function ( data )
		if tolua.isnull(self.view) then
			return
		end
		if data then
			local heads = data.headInfos
			local headInfos = self.headInfos
			if heads ~= nil then
				for k,v in pairs( heads ) do
					headInfos[v.level] = v.heads
				end
			end
			self.headInfos = headInfos
			self:updateFloor()
		end
		self:initData()
		self:pata_scrollToCurFloor()
		Scheduler.schedule(function()
			if tolua.isnull(self.view) then
				return
			end
			self.towerList:setVisible(true)
		end,0.01,1)
	end)
end
--扫荡检测
function PataView:onSweepClick(finished)
	--检测扫荡处理
	local info = {}
	info.text = "已通关层数: "..(self.curFloor-1).."\n \n \n".."今日剩余次数: "..self.limitTime
	info.title = "扫荡"
	info.yesText=self.btnSweep:getText()
	info.activeType=self._args.activeType
	info.key ="AlertRewardView"
	info.noClose = "yes"
	info.type = "yes_no"
	info.leftTime=self.limitTime
	info.passFloor=self.curFloor-1
    info.btnCostType = 2
	info.onYes = function()
		if self.remainTimes > 0 then
			ModelManager.PataModel:sweepTower(function ()
				if finished then
					finished()
				end
			end)
		else
			ModelManager.MaterialCopyModel:spendForTopup(self._args.activeType,1, function ()
				ModelManager.PataModel:sweepTower(function ()
					if finished then
						finished()
					end
				end)
			end)
		end
	end

	if self.remainTimes < 1 then
		local conf = DynamicConfigData.t_TowerSweepCost[self.sweepBuyCount]
		if conf then
			local cost = conf.diamonds[1]
			info.yesCost = {code = cost.code, amount=cost.amount, type = cost.type}
		end
	end
	Alert.show(info)
end

function PataView:_exit()
	if self.anctionHandler then
		Scheduler.unschedule(self.anctionHandler)
		self.anctionHandler = false
	end

	if self.doorTimer then
		Scheduler.unschedule(self.doorTimer)
	end

	self.doorTimer = false
	self.rankInfo = false
	self.isDoorPlaying = false
	if not  ViewManager.isShow("BattleBeginView") then
		SpineMnange.clearAll()--爬塔界面退出清楚所有缓存
	end
end

return PataView